// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppGroup {

@HiveField(0) String get id;@HiveField(1) String get name;@HiveField(2) String get icon;@HiveField(3) List<String> get members;
/// Create a copy of AppGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppGroupCopyWith<AppGroup> get copyWith => _$AppGroupCopyWithImpl<AppGroup>(this as AppGroup, _$identity);

  /// Serializes this AppGroup to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&const DeepCollectionEquality().equals(other.members, members));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,icon,const DeepCollectionEquality().hash(members));

@override
String toString() {
  return 'AppGroup(id: $id, name: $name, icon: $icon, members: $members)';
}


}

/// @nodoc
abstract mixin class $AppGroupCopyWith<$Res>  {
  factory $AppGroupCopyWith(AppGroup value, $Res Function(AppGroup) _then) = _$AppGroupCopyWithImpl;
@useResult
$Res call({
@HiveField(0) String id,@HiveField(1) String name,@HiveField(2) String icon,@HiveField(3) List<String> members
});




}
/// @nodoc
class _$AppGroupCopyWithImpl<$Res>
    implements $AppGroupCopyWith<$Res> {
  _$AppGroupCopyWithImpl(this._self, this._then);

  final AppGroup _self;
  final $Res Function(AppGroup) _then;

/// Create a copy of AppGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? icon = null,Object? members = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [AppGroup].
extension AppGroupPatterns on AppGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppGroup value)  $default,){
final _that = this;
switch (_that) {
case _AppGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppGroup value)?  $default,){
final _that = this;
switch (_that) {
case _AppGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@HiveField(0)  String id, @HiveField(1)  String name, @HiveField(2)  String icon, @HiveField(3)  List<String> members)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppGroup() when $default != null:
return $default(_that.id,_that.name,_that.icon,_that.members);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@HiveField(0)  String id, @HiveField(1)  String name, @HiveField(2)  String icon, @HiveField(3)  List<String> members)  $default,) {final _that = this;
switch (_that) {
case _AppGroup():
return $default(_that.id,_that.name,_that.icon,_that.members);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@HiveField(0)  String id, @HiveField(1)  String name, @HiveField(2)  String icon, @HiveField(3)  List<String> members)?  $default,) {final _that = this;
switch (_that) {
case _AppGroup() when $default != null:
return $default(_that.id,_that.name,_that.icon,_that.members);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppGroup extends AppGroup {
   _AppGroup({@HiveField(0) required this.id, @HiveField(1) required this.name, @HiveField(2) required this.icon, @HiveField(3) final  List<String> members = const []}): _members = members,super._();
  factory _AppGroup.fromJson(Map<String, dynamic> json) => _$AppGroupFromJson(json);

@override@HiveField(0) final  String id;
@override@HiveField(1) final  String name;
@override@HiveField(2) final  String icon;
 final  List<String> _members;
@override@JsonKey()@HiveField(3) List<String> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}


/// Create a copy of AppGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppGroupCopyWith<_AppGroup> get copyWith => __$AppGroupCopyWithImpl<_AppGroup>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppGroupToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&const DeepCollectionEquality().equals(other._members, _members));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,icon,const DeepCollectionEquality().hash(_members));

@override
String toString() {
  return 'AppGroup(id: $id, name: $name, icon: $icon, members: $members)';
}


}

/// @nodoc
abstract mixin class _$AppGroupCopyWith<$Res> implements $AppGroupCopyWith<$Res> {
  factory _$AppGroupCopyWith(_AppGroup value, $Res Function(_AppGroup) _then) = __$AppGroupCopyWithImpl;
@override @useResult
$Res call({
@HiveField(0) String id,@HiveField(1) String name,@HiveField(2) String icon,@HiveField(3) List<String> members
});




}
/// @nodoc
class __$AppGroupCopyWithImpl<$Res>
    implements _$AppGroupCopyWith<$Res> {
  __$AppGroupCopyWithImpl(this._self, this._then);

  final _AppGroup _self;
  final $Res Function(_AppGroup) _then;

/// Create a copy of AppGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? icon = null,Object? members = null,}) {
  return _then(_AppGroup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
