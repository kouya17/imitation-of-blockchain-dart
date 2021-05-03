import 'package:back/block.dart';
import 'package:back/blockchain.dart';
import 'package:back/router.dart';
import 'package:back/transaction.dart';

class Miner {
  List<Transaction> transactionPool = [];
  Blockchain blockchain;
  String rewardAddress;
  Router router;

  Miner(this.blockchain, this.rewardAddress, this.router) {
    router.subscribe(this);
  }

  void mine() {
    final miningStartTimestamp = DateTime.now().millisecondsSinceEpoch;
    final prevHash = blockchain.lastHash();
    final target = blockchain.nextDifficultyTarget();
    final rewardTx = Transaction.rewardTransaction(rewardAddress);

    transactionPool.add(rewardTx);

    var nonce = 0;
    Block block;
    int timestamp;

    do {
      timestamp = DateTime.now().millisecondsSinceEpoch;
      nonce += 1;
      block = Block(timestamp, prevHash, target, nonce, transactionPool,
          timestamp - miningStartTimestamp);
    } while (!block.isValid());

    blockchain.addBlock(block);
    clearTransactions();
    router.mineDone();
  }

  void pushTransaction(Transaction tx) {
    if (!tx.verifyTransaction()) {
      print('署名検証失敗');
      return;
    }
    transactionPool = transactionPool
        .where((t) => t.input != null && t.input!.address != tx.input!.address)
        .toList();
    transactionPool.add(tx);
    print('トランザクション追加');
  }

  void clearTransactions() {
    transactionPool = [];
    print('トランザクション削除');
  }
}
