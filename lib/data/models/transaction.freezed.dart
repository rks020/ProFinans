// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Transaction {

@HiveField(0) String get id;@HiveField(1) String get groupId;@HiveField(2) String get title;@HiveField(3) double get amount;@HiveField(4) DateTime get date;@HiveField(5) TransactionType get type;@HiveField(6) String get category;@HiveField(7) int get colorCode;@HiveField(8) bool get isPaid;@HiveField(9) RecurrenceRule get recurrenceRule;@HiveField(10) int? get installmentTotal;@HiveField(11) int? get installmentCurrent;
/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionCopyWith<Transaction> get copyWith => _$TransactionCopyWithImpl<Transaction>(this as Transaction, _$identity);

  /// Serializes this Transaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Transaction&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.type, type) || other.type == type)&&(identical(other.category, category) || other.category == category)&&(identical(other.colorCode, colorCode) || other.colorCode == colorCode)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.recurrenceRule, recurrenceRule) || other.recurrenceRule == recurrenceRule)&&(identical(other.installmentTotal, installmentTotal) || other.installmentTotal == installmentTotal)&&(identical(other.installmentCurrent, installmentCurrent) || other.installmentCurrent == installmentCurrent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupId,title,amount,date,type,category,colorCode,isPaid,recurrenceRule,installmentTotal,installmentCurrent);

@override
String toString() {
  return 'Transaction(id: $id, groupId: $groupId, title: $title, amount: $amount, date: $date, type: $type, category: $category, colorCode: $colorCode, isPaid: $isPaid, recurrenceRule: $recurrenceRule, installmentTotal: $installmentTotal, installmentCurrent: $installmentCurrent)';
}


}

/// @nodoc
abstract mixin class $TransactionCopyWith<$Res>  {
  factory $TransactionCopyWith(Transaction value, $Res Function(Transaction) _then) = _$TransactionCopyWithImpl;
@useResult
$Res call({
@HiveField(0) String id,@HiveField(1) String groupId,@HiveField(2) String title,@HiveField(3) double amount,@HiveField(4) DateTime date,@HiveField(5) TransactionType type,@HiveField(6) String category,@HiveField(7) int colorCode,@HiveField(8) bool isPaid,@HiveField(9) RecurrenceRule recurrenceRule,@HiveField(10) int? installmentTotal,@HiveField(11) int? installmentCurrent
});




}
/// @nodoc
class _$TransactionCopyWithImpl<$Res>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._self, this._then);

  final Transaction _self;
  final $Res Function(Transaction) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? groupId = null,Object? title = null,Object? amount = null,Object? date = null,Object? type = null,Object? category = null,Object? colorCode = null,Object? isPaid = null,Object? recurrenceRule = null,Object? installmentTotal = freezed,Object? installmentCurrent = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,colorCode: null == colorCode ? _self.colorCode : colorCode // ignore: cast_nullable_to_non_nullable
as int,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,recurrenceRule: null == recurrenceRule ? _self.recurrenceRule : recurrenceRule // ignore: cast_nullable_to_non_nullable
as RecurrenceRule,installmentTotal: freezed == installmentTotal ? _self.installmentTotal : installmentTotal // ignore: cast_nullable_to_non_nullable
as int?,installmentCurrent: freezed == installmentCurrent ? _self.installmentCurrent : installmentCurrent // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Transaction].
extension TransactionPatterns on Transaction {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Transaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Transaction value)  $default,){
final _that = this;
switch (_that) {
case _Transaction():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Transaction value)?  $default,){
final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@HiveField(0)  String id, @HiveField(1)  String groupId, @HiveField(2)  String title, @HiveField(3)  double amount, @HiveField(4)  DateTime date, @HiveField(5)  TransactionType type, @HiveField(6)  String category, @HiveField(7)  int colorCode, @HiveField(8)  bool isPaid, @HiveField(9)  RecurrenceRule recurrenceRule, @HiveField(10)  int? installmentTotal, @HiveField(11)  int? installmentCurrent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that.id,_that.groupId,_that.title,_that.amount,_that.date,_that.type,_that.category,_that.colorCode,_that.isPaid,_that.recurrenceRule,_that.installmentTotal,_that.installmentCurrent);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@HiveField(0)  String id, @HiveField(1)  String groupId, @HiveField(2)  String title, @HiveField(3)  double amount, @HiveField(4)  DateTime date, @HiveField(5)  TransactionType type, @HiveField(6)  String category, @HiveField(7)  int colorCode, @HiveField(8)  bool isPaid, @HiveField(9)  RecurrenceRule recurrenceRule, @HiveField(10)  int? installmentTotal, @HiveField(11)  int? installmentCurrent)  $default,) {final _that = this;
switch (_that) {
case _Transaction():
return $default(_that.id,_that.groupId,_that.title,_that.amount,_that.date,_that.type,_that.category,_that.colorCode,_that.isPaid,_that.recurrenceRule,_that.installmentTotal,_that.installmentCurrent);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@HiveField(0)  String id, @HiveField(1)  String groupId, @HiveField(2)  String title, @HiveField(3)  double amount, @HiveField(4)  DateTime date, @HiveField(5)  TransactionType type, @HiveField(6)  String category, @HiveField(7)  int colorCode, @HiveField(8)  bool isPaid, @HiveField(9)  RecurrenceRule recurrenceRule, @HiveField(10)  int? installmentTotal, @HiveField(11)  int? installmentCurrent)?  $default,) {final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that.id,_that.groupId,_that.title,_that.amount,_that.date,_that.type,_that.category,_that.colorCode,_that.isPaid,_that.recurrenceRule,_that.installmentTotal,_that.installmentCurrent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Transaction extends Transaction {
   _Transaction({@HiveField(0) required this.id, @HiveField(1) required this.groupId, @HiveField(2) required this.title, @HiveField(3) required this.amount, @HiveField(4) required this.date, @HiveField(5) required this.type, @HiveField(6) required this.category, @HiveField(7) required this.colorCode, @HiveField(8) this.isPaid = false, @HiveField(9) this.recurrenceRule = RecurrenceRule.none, @HiveField(10) this.installmentTotal, @HiveField(11) this.installmentCurrent}): super._();
  factory _Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);

@override@HiveField(0) final  String id;
@override@HiveField(1) final  String groupId;
@override@HiveField(2) final  String title;
@override@HiveField(3) final  double amount;
@override@HiveField(4) final  DateTime date;
@override@HiveField(5) final  TransactionType type;
@override@HiveField(6) final  String category;
@override@HiveField(7) final  int colorCode;
@override@JsonKey()@HiveField(8) final  bool isPaid;
@override@JsonKey()@HiveField(9) final  RecurrenceRule recurrenceRule;
@override@HiveField(10) final  int? installmentTotal;
@override@HiveField(11) final  int? installmentCurrent;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionCopyWith<_Transaction> get copyWith => __$TransactionCopyWithImpl<_Transaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Transaction&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.type, type) || other.type == type)&&(identical(other.category, category) || other.category == category)&&(identical(other.colorCode, colorCode) || other.colorCode == colorCode)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.recurrenceRule, recurrenceRule) || other.recurrenceRule == recurrenceRule)&&(identical(other.installmentTotal, installmentTotal) || other.installmentTotal == installmentTotal)&&(identical(other.installmentCurrent, installmentCurrent) || other.installmentCurrent == installmentCurrent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,groupId,title,amount,date,type,category,colorCode,isPaid,recurrenceRule,installmentTotal,installmentCurrent);

@override
String toString() {
  return 'Transaction(id: $id, groupId: $groupId, title: $title, amount: $amount, date: $date, type: $type, category: $category, colorCode: $colorCode, isPaid: $isPaid, recurrenceRule: $recurrenceRule, installmentTotal: $installmentTotal, installmentCurrent: $installmentCurrent)';
}


}

/// @nodoc
abstract mixin class _$TransactionCopyWith<$Res> implements $TransactionCopyWith<$Res> {
  factory _$TransactionCopyWith(_Transaction value, $Res Function(_Transaction) _then) = __$TransactionCopyWithImpl;
@override @useResult
$Res call({
@HiveField(0) String id,@HiveField(1) String groupId,@HiveField(2) String title,@HiveField(3) double amount,@HiveField(4) DateTime date,@HiveField(5) TransactionType type,@HiveField(6) String category,@HiveField(7) int colorCode,@HiveField(8) bool isPaid,@HiveField(9) RecurrenceRule recurrenceRule,@HiveField(10) int? installmentTotal,@HiveField(11) int? installmentCurrent
});




}
/// @nodoc
class __$TransactionCopyWithImpl<$Res>
    implements _$TransactionCopyWith<$Res> {
  __$TransactionCopyWithImpl(this._self, this._then);

  final _Transaction _self;
  final $Res Function(_Transaction) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? groupId = null,Object? title = null,Object? amount = null,Object? date = null,Object? type = null,Object? category = null,Object? colorCode = null,Object? isPaid = null,Object? recurrenceRule = null,Object? installmentTotal = freezed,Object? installmentCurrent = freezed,}) {
  return _then(_Transaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,colorCode: null == colorCode ? _self.colorCode : colorCode // ignore: cast_nullable_to_non_nullable
as int,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,recurrenceRule: null == recurrenceRule ? _self.recurrenceRule : recurrenceRule // ignore: cast_nullable_to_non_nullable
as RecurrenceRule,installmentTotal: freezed == installmentTotal ? _self.installmentTotal : installmentTotal // ignore: cast_nullable_to_non_nullable
as int?,installmentCurrent: freezed == installmentCurrent ? _self.installmentCurrent : installmentCurrent // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
