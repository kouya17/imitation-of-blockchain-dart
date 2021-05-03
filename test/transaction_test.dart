import 'dart:convert';
import 'package:back/router.dart';
import 'package:crypto/crypto.dart';
import 'package:back/blockchain.dart';
import 'package:back/config.dart';
import 'package:back/miner.dart';
import 'package:back/transaction.dart';
import 'package:back/wallet.dart';
import 'package:secp256k1/secp256k1.dart';
import 'package:test/test.dart';

void main() {
  late Blockchain blockchain;
  late Wallet wallet;
  late Transaction tx;
  late Miner miner;
  late Router router;

  setUp(() {
    blockchain = Blockchain();
    router = Router(blockchain);
    wallet = Wallet(blockchain, router);
    miner = Miner(blockchain, wallet.pubKey.toHex(), router);
    miner.mine();
    tx = Transaction.createTransaction(wallet, 'recipient-address', 10);
  });

  test('createOutputs()', () {
    // occur change
    expect(tx.outputs[0], Output(10, 'recipient-address'));
    expect(tx.outputs[1],
        Output(Config.MINING_REWARD - 10, wallet.pubKey.toHex()));

    // no change
    final tx2 = Transaction.createTransaction(
        wallet, 'recipient-address', Config.MINING_REWARD.toDouble());
    expect(tx2.outputs[0],
        Output(Config.MINING_REWARD.toDouble(), 'recipient-address'));
  });

  test('signTransaction()', () {
    //final hash = sha256.convert(utf8.encode(jsonEncode(tx.outputs))).toString();
    expect(tx.input!.address, wallet.pubKey.toHex());
    //expect(tx.input.signature.toString(), pk.signature(hash).toString());
  });

  test('verifyTransaction()', () {
    expect(tx.verifyTransaction(), true);

    tx.outputs[0].address = 'kaizanzumi';
    expect(tx.verifyTransaction(), false);
  });

  test('rawardTransaction()', () {
    final tx = Transaction.rewardTransaction('reward-address');
    expect(tx.outputs[0].address, 'reward-address');
    expect(tx.outputs[0].amount, Config.MINING_REWARD);
    expect(tx.coinbase!.length, greaterThan(1));
  });

  test('toJson()', () {
    final tx = Transaction.createTransaction(wallet, 'recipient-address', 10);
    expect(tx.toJson(), {
      'id': tx.id,
      'outputs': [tx.outputs[0].toJson(), tx.outputs[1].toJson()],
      'input': tx.input?.toJson(),
      'coinbase': tx.coinbase
    });
  });

  test('fromJson()', () {
    final tx = Transaction.createTransaction(wallet, 'recipient-address', 10);
    final tx2 = Transaction.fromJson(tx.toJson());
    expect(tx2.id, tx.id);
    expect(tx2.outputs, tx.outputs);
    expect(tx2.input, tx.input);
    expect(tx2.coinbase, tx.coinbase);
  });
}
