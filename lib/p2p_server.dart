import 'dart:convert';
import 'dart:io';

import 'package:back/block.dart';
import 'package:back/blockchain.dart';
import 'package:alfred/src/type_handlers/websocket_type_handler.dart';
import 'package:back/message.dart';
import 'package:back/transaction.dart';

typedef MessageHandler = void Function(dynamic message);

class P2pServer {
  Blockchain blockchain;
  MessageHandler messageHandler;
  List<WebSocket> sockets = [];

  P2pServer(this.blockchain, this.messageHandler,
      {List<String> peers = const []}) {
    connect2Peers(peers);
  }

  void connect2Peers(List<String> peers) {
    peers.forEach((peer) async {
      if (peer != '') {
        final socket = await WebSocket.connect(peer);
        connect2Socket(socket);
      }
    });
  }

  WebSocketSession webSocketSession() {
    return WebSocketSession(onOpen: (ws) {
      sockets.add(ws);
      sendBlockChain(ws);
    }, onMessage: (ws, dynamic data) async {
      print('recieved from peer: $data');
      messageHandler(data);
    });
  }

  void connect2Socket(WebSocket socket) {
    sockets.add(socket);
    print('Socket connected');
    socket.listen((data) {
      print('received from peer: $data');
      messageHandler(data);
    });
    sendBlockChain(socket);
  }

  void broadcastTransaction(Transaction transaction) {
    sockets.forEach((socket) {
      sendData(
          socket, Message<Transaction>(MessageType.TRANSACTION, transaction));
    });
  }

  void broadcastMined() {
    sockets.forEach((socket) {
      sendData(
          socket, Message<List<Block>>(MessageType.MINED, blockchain.chain));
    });
  }

  void sendBlockChain(WebSocket socket) {
    sendData(socket,
        Message<List<Block>>(MessageType.BLOCK_CHAIN, blockchain.chain));
  }

  static void sendData(WebSocket socket, Message data) {
    socket.send(jsonEncode(data));
  }
}
