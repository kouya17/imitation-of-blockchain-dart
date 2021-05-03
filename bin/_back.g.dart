// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'back.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactRequest _$TransactRequestFromJson(Map<String, dynamic> json) {
  return TransactRequest(
    json['recipient'] as String?,
    (json['amount'] as num?)?.toDouble(),
  );
}

Map<String, dynamic> _$TransactRequestToJson(TransactRequest instance) =>
    <String, dynamic>{
      'recipient': instance.recipient,
      'amount': instance.amount,
    };
