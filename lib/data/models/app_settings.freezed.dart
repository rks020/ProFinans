// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppSettings {

@HiveField(0) String? get activeGroupId;@HiveField(1) String get selectedCurrency;@HiveField(2) String get themePreference;@HiveField(3) bool get isPrivacyMode;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);

  /// Serializes this AppSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.activeGroupId, activeGroupId) || other.activeGroupId == activeGroupId)&&(identical(other.selectedCurrency, selectedCurrency) || other.selectedCurrency == selectedCurrency)&&(identical(other.themePreference, themePreference) || other.themePreference == themePreference)&&(identical(other.isPrivacyMode, isPrivacyMode) || other.isPrivacyMode == isPrivacyMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,activeGroupId,selectedCurrency,themePreference,isPrivacyMode);

@override
String toString() {
  return 'AppSettings(activeGroupId: $activeGroupId, selectedCurrency: $selectedCurrency, themePreference: $themePreference, isPrivacyMode: $isPrivacyMode)';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
@HiveField(0) String? activeGroupId,@HiveField(1) String selectedCurrency,@HiveField(2) String themePreference,@HiveField(3) bool isPrivacyMode
});




}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? activeGroupId = freezed,Object? selectedCurrency = null,Object? themePreference = null,Object? isPrivacyMode = null,}) {
  return _then(_self.copyWith(
activeGroupId: freezed == activeGroupId ? _self.activeGroupId : activeGroupId // ignore: cast_nullable_to_non_nullable
as String?,selectedCurrency: null == selectedCurrency ? _self.selectedCurrency : selectedCurrency // ignore: cast_nullable_to_non_nullable
as String,themePreference: null == themePreference ? _self.themePreference : themePreference // ignore: cast_nullable_to_non_nullable
as String,isPrivacyMode: null == isPrivacyMode ? _self.isPrivacyMode : isPrivacyMode // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettings value)  $default,){
final _that = this;
switch (_that) {
case _AppSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@HiveField(0)  String? activeGroupId, @HiveField(1)  String selectedCurrency, @HiveField(2)  String themePreference, @HiveField(3)  bool isPrivacyMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.activeGroupId,_that.selectedCurrency,_that.themePreference,_that.isPrivacyMode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@HiveField(0)  String? activeGroupId, @HiveField(1)  String selectedCurrency, @HiveField(2)  String themePreference, @HiveField(3)  bool isPrivacyMode)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.activeGroupId,_that.selectedCurrency,_that.themePreference,_that.isPrivacyMode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@HiveField(0)  String? activeGroupId, @HiveField(1)  String selectedCurrency, @HiveField(2)  String themePreference, @HiveField(3)  bool isPrivacyMode)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.activeGroupId,_that.selectedCurrency,_that.themePreference,_that.isPrivacyMode);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppSettings extends AppSettings {
   _AppSettings({@HiveField(0) this.activeGroupId, @HiveField(1) this.selectedCurrency = 'TRY', @HiveField(2) this.themePreference = 'dark', @HiveField(3) this.isPrivacyMode = false}): super._();
  factory _AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);

@override@HiveField(0) final  String? activeGroupId;
@override@JsonKey()@HiveField(1) final  String selectedCurrency;
@override@JsonKey()@HiveField(2) final  String themePreference;
@override@JsonKey()@HiveField(3) final  bool isPrivacyMode;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.activeGroupId, activeGroupId) || other.activeGroupId == activeGroupId)&&(identical(other.selectedCurrency, selectedCurrency) || other.selectedCurrency == selectedCurrency)&&(identical(other.themePreference, themePreference) || other.themePreference == themePreference)&&(identical(other.isPrivacyMode, isPrivacyMode) || other.isPrivacyMode == isPrivacyMode));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,activeGroupId,selectedCurrency,themePreference,isPrivacyMode);

@override
String toString() {
  return 'AppSettings(activeGroupId: $activeGroupId, selectedCurrency: $selectedCurrency, themePreference: $themePreference, isPrivacyMode: $isPrivacyMode)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
@HiveField(0) String? activeGroupId,@HiveField(1) String selectedCurrency,@HiveField(2) String themePreference,@HiveField(3) bool isPrivacyMode
});




}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? activeGroupId = freezed,Object? selectedCurrency = null,Object? themePreference = null,Object? isPrivacyMode = null,}) {
  return _then(_AppSettings(
activeGroupId: freezed == activeGroupId ? _self.activeGroupId : activeGroupId // ignore: cast_nullable_to_non_nullable
as String?,selectedCurrency: null == selectedCurrency ? _self.selectedCurrency : selectedCurrency // ignore: cast_nullable_to_non_nullable
as String,themePreference: null == themePreference ? _self.themePreference : themePreference // ignore: cast_nullable_to_non_nullable
as String,isPrivacyMode: null == isPrivacyMode ? _self.isPrivacyMode : isPrivacyMode // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
