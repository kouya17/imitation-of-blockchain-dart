import 'package:back/block.dart';
import 'package:back/transaction.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

enum MessageType { BLOCK_CHAIN, TRANSACTION, MINED, INVALID }

@JsonSerializable()
class Message<T> {
  @JsonKey(fromJson: _stringToMessageType, toJson: _messageTypeToString)
  MessageType type;
  @_Converter()
  T payload;

  Message(this.type, this.payload);

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);

  static MessageType _stringToMessageType(String string) {
    return EnumToString.fromString(MessageType.values, string) ??
        MessageType.INVALID;
  }

  static String _messageTypeToString(MessageType messageType) {
    return EnumToString.convertToString(messageType);
  }
}

class _Converter<T> implements JsonConverter<T, Object?> {
  const _Converter();

  @override
  T fromJson(Object? json) {
    if (json is Map<String, dynamic> && json.containsKey('outputs')) {
      return Transaction.fromJson(json) as T;
    }
    return (json as List<dynamic>).map((e) => Block.fromJson(e)).toList() as T;
  }

  @override
  Object? toJson(T object) {
    return object;
  }
}
