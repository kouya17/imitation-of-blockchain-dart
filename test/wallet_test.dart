import 'dart:convert';

import 'package:back/router.dart';
import 'package:crypto/crypto.dart';
import 'package:back/blockchain.dart';
import 'package:back/config.dart';
import 'package:back/miner.dart';
import 'package:back/transaction.dart';
import 'package:back/wallet.dart';
import 'package:test/test.dart';

void main() {
  late Blockchain blockchain;
  late Miner miner;
  late Wallet wallet;
  late Router router;

  setUp(() {
    blockchain = Blockchain();
    router = Router(blockchain);
    wallet = Wallet(blockchain, router);
    miner = Miner(blockchain, wallet.pubKey.toHex(), router);
  });

  test('balance()', () {
    expect(wallet.balance(), INITIAL_BALANCE);

    miner.mine();
    expect(wallet.balance(), Config.MINING_REWARD);

    final tx = Transaction.createTransaction(wallet, 'recipient-address', 10.0);
    miner.pushTransaction(tx);
    miner.mine();
    expect(wallet.balance(), Config.MINING_REWARD * 2 - 10);
  });

  test('sign()', () {
    final hash =
        sha256.convert(utf8.encode(DateTime.now().toString())).toString();
    final signature = wallet.sign(hash);
    expect(signature.verify(wallet.pubKey, hash), true);
  });
}
