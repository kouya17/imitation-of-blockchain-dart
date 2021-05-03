import 'package:back/blockchain.dart';
import 'package:back/miner.dart';
import 'package:back/router.dart';
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

  test('mine()', () {
    miner.mine();
    expect(blockchain.chain.length, equals(2));
    expect(Blockchain.isValidChain(blockchain.chain), equals(true));

    miner.mine();
    expect(blockchain.chain.length, equals(3));
    expect(Blockchain.isValidChain(blockchain.chain), equals(true));
  });

  test('pushTransaction()', () {
    final wallet = Wallet(blockchain, router);
    final tx = Transaction.createTransaction(wallet, 'recipient-address', 100);

    miner.pushTransaction(tx);
    expect(miner.transactionPool.length, 1);

    // same address
    final tx2 = Transaction.createTransaction(wallet, 'recipient-address', 200);
    miner.pushTransaction(tx2);
    expect(miner.transactionPool.length, 1);

    // manipulation
    final tx3 = Transaction.createTransaction(wallet, 'recipient-address', 300);
    tx3.outputs[0].address = 'kaizan';
    miner.pushTransaction(tx3);
    expect(miner.transactionPool.length, 1);

    // clearTransaction()
    miner.clearTransactions();
    expect(miner.transactionPool.length, 0);
  });
}
