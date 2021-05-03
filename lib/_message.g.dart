// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message<T> _$MessageFromJson<T>(Map<String, dynamic> json) {
  return Message<T>(
    Message._stringToMessageType(json['type'] as String),
    _Converter<T>().fromJson(json['payload']),
  );
}

Map<String, dynamic> _$MessageToJson<T>(Message<T> instance) =>
    <String, dynamic>{
      'type': Message._messageTypeToString(instance.type),
      'payload': _Converter<T>().toJson(instance.payload),
    };
