// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Block _$BlockFromJson(Map<String, dynamic> json) {
  return Block(
    json['timestamp'] as int,
    json['prevHash'] as String,
    json['difficultyTarget'] as int,
    json['nonce'] as int,
    (json['transactions'] as List<dynamic>)
        .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList(),
    json['miningDuration'] as int,
  );
}

Map<String, dynamic> _$BlockToJson(Block instance) => <String, dynamic>{
      'timestamp': instance.timestamp,
      'prevHash': instance.prevHash,
      'difficultyTarget': instance.difficultyTarget,
      'nonce': instance.nonce,
      'transactions': instance.transactions,
      'miningDuration': instance.miningDuration,
    };
