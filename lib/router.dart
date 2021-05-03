import 'dart:convert';
import 'dart:io';

import 'package:back/block.dart';
import 'package:back/blockchain.dart';
import 'package:back/message.dart';
import 'package:back/miner.dart';
import 'package:back/p2p_server.dart';
import 'package:back/transaction.dart';
import 'package:enum_to_string/enum_to_string.dart';

class Router {
  Blockchain blockchain;
  Miner? miner;
  List<WebSocket> sockets = [];
  late P2pServer p2pServer;

  Router(this.blockchain) {
    p2pServer = P2pServer(blockchain, messageHandler);
  }

  void subscribe(Miner subscriber) {
    miner = subscriber;
  }

  void pushTransaction(Transaction tx) {
    if (miner != null) {
      miner!.pushTransaction(tx);
    }
    p2pServer.broadcastTransaction(tx);
  }

  void mineDone() {
    p2pServer.broadcastMined();
  }

  void messageHandler(dynamic data) {
    var jsonDecodedData = jsonDecode(data);
    switch (
        EnumToString.fromString(MessageType.values, jsonDecodedData['type'])) {
      case MessageType.BLOCK_CHAIN:
        blockchain.replaceChain(
            Message<List<Block>>.fromJson(jsonDecodedData).payload);
        break;
      case MessageType.TRANSACTION:
        if (miner != null) {
          miner!.pushTransaction(
              Message<Transaction>.fromJson(jsonDecodedData).payload);
        }
        break;
      case MessageType.MINED:
        blockchain.replaceChain(Message<List<Block>>.fromJson(jsonDecodedData).payload);
        if (miner != null) {
          miner!.clearTransactions();
        }
        break;
      default:
        break;
    }
  }
}
