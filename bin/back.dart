import 'dart:convert';
import 'dart:io';

import 'package:alfred/alfred.dart';
import 'package:alfred/src/middleware/cors.dart';
import 'package:back/router.dart';
import 'package:pedantic/pedantic.dart';
import 'package:back/blockchain.dart';
import 'package:back/miner.dart';
import 'package:back/wallet.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:args/args.dart';

part 'back.g.dart';

@JsonSerializable()
class TransactRequest {
  String? recipient;
  double? amount;

  TransactRequest(this.recipient, this.amount);
  factory TransactRequest.fromJson(Map<String, dynamic> json) =>
      _$TransactRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TransactRequestToJson(this);
}

void main(List<String> args) async {
  var portEnv = Platform.environment['PORT'];

  var parser = ArgParser();
  parser.addOption('port', abbr: 'p', defaultsTo: portEnv ?? 'port');
  parser.addOption('peer', abbr: 'e', defaultsTo: '');
  final parsedArgs = parser.parse(args);
  final port = parsedArgs['port'];

  final app = Alfred();
  final blockchain = Blockchain();
  final router = Router(blockchain);
  final wallet = Wallet(blockchain, router);
  final miner = Miner(blockchain, wallet.pubKey.toHex(), router);

  app.all('*', cors());

  app.get('/ws', (req, res) {
    return router.p2pServer.webSocketSession();
  });

  router.p2pServer.connect2Peers([parsedArgs['peer']]);

  app.get('/public/*', (req, res) => Directory('public'));

  app.get('/blocks', (req, res) {
    final response = blockchain.chain.asMap().entries.map((entry) {
      final block = entry.value.toJson();
      block['hash'] = entry.value.hash();
      block['height'] = entry.key;
      return block;
    });
    res.json(List.from(response.toList().reversed));
  });

  app.get('/transactions', (req, res) {
    res.json(miner.transactionPool);
  });

  app.post('/transact', (req, res) async {
    final body = await req.body;
    print(body);
    if (body == null) {
      res.statusCode = 400;
      return {
        'error': {'message': 'empty body'}
      };
    }
    final transactRequest =
        TransactRequest.fromJson(jsonDecode(body as String));
    if (transactRequest.recipient == null || transactRequest.amount == null) {
      res.statusCode = 400;
      return {
        'error': {'message': 'invalid body'}
      };
    }
    wallet.createTransaction(
        transactRequest.recipient!, transactRequest.amount!);
    unawaited(res.redirect(
        Uri.https('dart-blockchain-test-app.herokuapp.com:' + port, '/transactions')));
  });

  app.get('/wallet', (req, res) {
    res.json({'address': wallet.pubKey.toHex(), 'balance': wallet.balance()});
  });

  app.post('/mine', (req, res) {
    miner.mine();
    res.redirect(Uri.https(
        'dart-blockchain-test-app.herokuapp.com:' + port,
        '/blocks'));
  });

  await app.listen(int.parse(parsedArgs['port']));
}
