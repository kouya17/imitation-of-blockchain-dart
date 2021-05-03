import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:back/config.dart';
import 'package:back/transaction.dart';
import 'package:json_annotation/json_annotation.dart';

part 'block.g.dart';

const DIFFICULTY_TARGET = 255;

@JsonSerializable()
class Block {
  int timestamp;
  String prevHash;
  int difficultyTarget;
  int nonce;
  List<Transaction> transactions;
  int miningDuration;

  factory Block.fromJson(Map<String, dynamic> json) => _$BlockFromJson(json);
  Map<String, dynamic> toJson() => _$BlockToJson(this);

  Block(this.timestamp, this.prevHash, this.difficultyTarget, this.nonce,
      this.transactions, this.miningDuration);
  
  @override
  bool operator ==(Object other) => (other is Block)
      ? (timestamp == other.timestamp && prevHash == other.prevHash && nonce == other.nonce && transactions == other.transactions && miningDuration == other.miningDuration) : false;
  
  static Block genesis() {
    return Block(0, '0' * 64, DIFFICULTY_TARGET, 0, [], Config.MINING_DURATION);
  }

  String hash() {
    return sha256.convert(utf8.encode(jsonEncode(this))).toString();
  }

  bool isValid() {
    final hash = this.hash();
    return hashToDouble(hash) < pow(2.0, difficultyTarget);
  }

  /*
  dynamic toJson() {
    return {
      'timestamp': timestamp,
      'prevHash': prevHash,
      'difficultyTarget': difficultyTarget,
      'nonce': nonce,
      'transactions': transactions,
      'miningDuration': miningDuration
    };
  }
  */

  double hashToDouble(String hash) {
    var number = 0.0;
    for (var i = 0; i <= hash.length - 8; i += 8) {
      final hex = hash.substring(i, i + 8);
      final subNumber = BigInt.parse(hex, radix: 16).toDouble();
      number += subNumber * pow(2, i);
    }
    return number;
  }
}
