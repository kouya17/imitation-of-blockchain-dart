import 'package:back/blockchain.dart';
import 'package:back/router.dart';
import 'package:back/transaction.dart';
import 'package:secp256k1/secp256k1.dart';

const INITIAL_BALANCE = 0;

class Wallet {
  late Blockchain blockchain;
  late PrivateKey pk;
  late PublicKey pubKey;
  Router router;

  Wallet(this.blockchain, this.router) {
    pk = PrivateKey.generate();
    pubKey = pk.publicKey;
  }

  void createTransaction(String recipient, double amount) {
    if (amount > balance()) {
      print('残高不足');
      throw Exception('Insufficient funds');
    }
    final tx = Transaction.createTransaction(this, recipient, amount);
    router.pushTransaction(tx);
  }

  double balance() {
    final transactions = blockchain.chain
        .fold<List<Transaction>>([], (a, block) => a + block.transactions);
    final inputs = transactions.fold<double>(
        0.0,
        (a, tx) => tx.input != null && tx.input!.address == pubKey.toHex()
            ? a + tx.input!.amount
            : a);
    final outputs = transactions.fold<double>(
        0.0,
        (a, tx) =>
            a +
            tx.outputs.fold<double>(0.0,
                (a2, o) => o.address == pubKey.toHex() ? a2 + o.amount : a2));
    return outputs - inputs + INITIAL_BALANCE;
  }

  Signature sign(String hash) {
    return pk.signature(hash);
  }
}
