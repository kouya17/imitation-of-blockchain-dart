// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Input _$InputFromJson(Map<String, dynamic> json) {
  return Input(
    json['timestamp'] as int,
    (json['amount'] as num).toDouble(),
    json['address'] as String,
    Input._signatureFromJson(json['signature'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$InputToJson(Input instance) => <String, dynamic>{
      'timestamp': instance.timestamp,
      'amount': instance.amount,
      'address': instance.address,
      'signature': Input._signatureToJson(instance.signature),
    };

Output _$OutputFromJson(Map<String, dynamic> json) {
  return Output(
    (json['amount'] as num).toDouble(),
    json['address'] as String,
  );
}

Map<String, dynamic> _$OutputToJson(Output instance) => <String, dynamic>{
      'amount': instance.amount,
      'address': instance.address,
    };

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return Transaction()
    ..id = json['id'] as String
    ..outputs = (json['outputs'] as List<dynamic>)
        .map((e) => Output.fromJson(e as Map<String, dynamic>))
        .toList()
    ..input = json['input'] == null
        ? null
        : Input.fromJson(json['input'] as Map<String, dynamic>)
    ..coinbase = json['coinbase'] as String?;
}

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'outputs': instance.outputs.map((e) => e.toJson()).toList(),
      'input': instance.input?.toJson(),
      'coinbase': instance.coinbase,
    };
