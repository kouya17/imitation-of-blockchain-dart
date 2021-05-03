import 'package:back/config.dart';
import 'package:back/wallet.dart';
import 'package:uuid/uuid.dart';
import 'package:secp256k1/secp256k1.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'transaction.g.dart';

@JsonSerializable()
class Input {
  int timestamp;
  double amount;
  String address;
  @JsonKey(fromJson: _signatureFromJson, toJson: _signatureToJson)
  Signature signature;

  Input(this.timestamp, this.amount, this.address, this.signature);

  factory Input.fromJson(Map<String, dynamic> json) => _$InputFromJson(json);
  Map<String, dynamic> toJson() => _$InputToJson(this);

  static Signature _signatureFromJson(Map<String, dynamic> sig) {
    return Signature.fromHexes(sig['r'] as String, sig['s'] as String);
  }

  static Map<String, String> _signatureToJson(Signature signature) {
    return {'r': signature.toHexes()[0], 's': signature.toHexes()[1]};
  }

  /*
  dynamic toJson() {
    return {
      'timestamp': timestamp,
      'amount': amount,
      'address': address,
      'signature': signature.toString()
    };
  }
  */

  @override
  bool operator ==(Object other) => (other is Input)
      ? (timestamp == other.timestamp &&
          amount == other.amount &&
          address == other.address &&
          signature == other.signature)
      : false;

  @override
  String toString() {
    return 'timestamp: $timestamp, amount: $amount, address: $address, signature: $signature';
  }
}

@JsonSerializable()
class Output {
  double amount;
  String address;

  Output(this.amount, this.address);

  factory Output.fromJson(Map<String, dynamic> json) => _$OutputFromJson(json);
  Map<String, dynamic> toJson() => _$OutputToJson(this);

  /*
  dynamic toJson() {
    return {'amount': amount, 'address': address};
  }
  */

  @override
  String toString() {
    return 'Output: {amount: $amount, address: $address}';
  }

  @override
  bool operator ==(Object other) => (other is Output)
      ? (amount == other.amount && address == other.address)
      : false;
}

@JsonSerializable(explicitToJson: true)
class Transaction {
  late String id;
  late List<Output> outputs;
  Input? input;
  String? coinbase;

  Transaction();

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);

  void createOutputs(Wallet senderWallet, String recipient, double amount) {
    final balance = senderWallet.balance();
    outputs = [Output(amount, recipient)];
    if (balance > amount) {
      outputs.add(Output(balance - amount, senderWallet.pubKey.toHex()));
    }
  }

  void signTransaction(Wallet senderWallet) {
    final hash = sha256.convert(utf8.encode(jsonEncode(outputs))).toString();
    input = Input(DateTime.now().millisecondsSinceEpoch, senderWallet.balance(),
        senderWallet.pubKey.toHex(), senderWallet.pk.signature(hash));
  }

  bool verifyTransaction() {
    if (input == null) {
      throw Exception('input is null');
    }
    final hash = sha256.convert(utf8.encode(jsonEncode(outputs))).toString();
    return input!.signature.verify(PublicKey.fromHex(input!.address), hash);
  }

  static Transaction createTransaction(
      Wallet senderWallet, String recipient, double amount) {
    final tx = Transaction();
    tx.id = Uuid().v1();
    tx.createOutputs(senderWallet, recipient, amount);
    tx.signTransaction(senderWallet);
    return tx;
  }

  /*
  dynamic toJson() {
    var map = {'id': id, 'outputs': outputs};
    if (input != null) {
      map.addAll({'input': input!});
    }
    if (coinbase != null) {
      map.addAll({'coinbase': coinbase!});
    }
    return map;
  }
  */

  void createCoinbase(String recipient) {
    outputs = [Output(Config.MINING_REWARD.toDouble(), recipient)];
    coinbase = 'This is coinbase created at ${DateTime.now().toString()}';
  }

  static Transaction rewardTransaction(String rewardAddress) {
    final tx = Transaction();
    tx.id = Uuid().v1();
    tx.createCoinbase(rewardAddress);
    return tx;
  }
}
