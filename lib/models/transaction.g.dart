// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
  id: json['id'] as String?,
  userId: json['user_id'] as String,
  type: json['type'] as String,
  amount: (json['amount'] as num).toDouble(),
  category: json['category'] as String,
  description: json['description'] as String,
  date: DateTime.parse(json['date'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      if (instance.id case final value?) 'id': value,
      'user_id': instance.userId,
      'type': instance.type,
      'amount': instance.amount,
      'category': instance.category,
      'description': instance.description,
      'date': instance.date.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };
