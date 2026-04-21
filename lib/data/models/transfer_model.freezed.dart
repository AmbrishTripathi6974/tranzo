// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transfer_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TransferModel {

 String get id; String get senderId; String get receiverId; String? get senderUsername; String? get receiverUsername; String get fileName; int get fileSize;@JsonKey(fromJson: _statusFromJson, toJson: _statusToJson) TransferStatus get status; DateTime get createdAt; DateTime? get expiresAt;
/// Create a copy of TransferModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransferModelCopyWith<TransferModel> get copyWith => _$TransferModelCopyWithImpl<TransferModel>(this as TransferModel, _$identity);

  /// Serializes this TransferModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransferModel&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.receiverId, receiverId) || other.receiverId == receiverId)&&(identical(other.senderUsername, senderUsername) || other.senderUsername == senderUsername)&&(identical(other.receiverUsername, receiverUsername) || other.receiverUsername == receiverUsername)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderId,receiverId,senderUsername,receiverUsername,fileName,fileSize,status,createdAt,expiresAt);

@override
String toString() {
  return 'TransferModel(id: $id, senderId: $senderId, receiverId: $receiverId, senderUsername: $senderUsername, receiverUsername: $receiverUsername, fileName: $fileName, fileSize: $fileSize, status: $status, createdAt: $createdAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $TransferModelCopyWith<$Res>  {
  factory $TransferModelCopyWith(TransferModel value, $Res Function(TransferModel) _then) = _$TransferModelCopyWithImpl;
@useResult
$Res call({
 String id, String senderId, String receiverId, String? senderUsername, String? receiverUsername, String fileName, int fileSize,@JsonKey(fromJson: _statusFromJson, toJson: _statusToJson) TransferStatus status, DateTime createdAt, DateTime? expiresAt
});




}
/// @nodoc
class _$TransferModelCopyWithImpl<$Res>
    implements $TransferModelCopyWith<$Res> {
  _$TransferModelCopyWithImpl(this._self, this._then);

  final TransferModel _self;
  final $Res Function(TransferModel) _then;

/// Create a copy of TransferModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? senderId = null,Object? receiverId = null,Object? senderUsername = freezed,Object? receiverUsername = freezed,Object? fileName = null,Object? fileSize = null,Object? status = null,Object? createdAt = null,Object? expiresAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,receiverId: null == receiverId ? _self.receiverId : receiverId // ignore: cast_nullable_to_non_nullable
as String,senderUsername: freezed == senderUsername ? _self.senderUsername : senderUsername // ignore: cast_nullable_to_non_nullable
as String?,receiverUsername: freezed == receiverUsername ? _self.receiverUsername : receiverUsername // ignore: cast_nullable_to_non_nullable
as String?,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,fileSize: null == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransferStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TransferModel].
extension TransferModelPatterns on TransferModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransferModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransferModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransferModel value)  $default,){
final _that = this;
switch (_that) {
case _TransferModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransferModel value)?  $default,){
final _that = this;
switch (_that) {
case _TransferModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String senderId,  String receiverId,  String? senderUsername,  String? receiverUsername,  String fileName,  int fileSize, @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)  TransferStatus status,  DateTime createdAt,  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransferModel() when $default != null:
return $default(_that.id,_that.senderId,_that.receiverId,_that.senderUsername,_that.receiverUsername,_that.fileName,_that.fileSize,_that.status,_that.createdAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String senderId,  String receiverId,  String? senderUsername,  String? receiverUsername,  String fileName,  int fileSize, @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)  TransferStatus status,  DateTime createdAt,  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _TransferModel():
return $default(_that.id,_that.senderId,_that.receiverId,_that.senderUsername,_that.receiverUsername,_that.fileName,_that.fileSize,_that.status,_that.createdAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String senderId,  String receiverId,  String? senderUsername,  String? receiverUsername,  String fileName,  int fileSize, @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)  TransferStatus status,  DateTime createdAt,  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _TransferModel() when $default != null:
return $default(_that.id,_that.senderId,_that.receiverId,_that.senderUsername,_that.receiverUsername,_that.fileName,_that.fileSize,_that.status,_that.createdAt,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransferModel extends TransferModel {
  const _TransferModel({required this.id, required this.senderId, required this.receiverId, this.senderUsername, this.receiverUsername, required this.fileName, required this.fileSize, @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson) required this.status, required this.createdAt, this.expiresAt}): super._();
  factory _TransferModel.fromJson(Map<String, dynamic> json) => _$TransferModelFromJson(json);

@override final  String id;
@override final  String senderId;
@override final  String receiverId;
@override final  String? senderUsername;
@override final  String? receiverUsername;
@override final  String fileName;
@override final  int fileSize;
@override@JsonKey(fromJson: _statusFromJson, toJson: _statusToJson) final  TransferStatus status;
@override final  DateTime createdAt;
@override final  DateTime? expiresAt;

/// Create a copy of TransferModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransferModelCopyWith<_TransferModel> get copyWith => __$TransferModelCopyWithImpl<_TransferModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransferModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransferModel&&(identical(other.id, id) || other.id == id)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.receiverId, receiverId) || other.receiverId == receiverId)&&(identical(other.senderUsername, senderUsername) || other.senderUsername == senderUsername)&&(identical(other.receiverUsername, receiverUsername) || other.receiverUsername == receiverUsername)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,senderId,receiverId,senderUsername,receiverUsername,fileName,fileSize,status,createdAt,expiresAt);

@override
String toString() {
  return 'TransferModel(id: $id, senderId: $senderId, receiverId: $receiverId, senderUsername: $senderUsername, receiverUsername: $receiverUsername, fileName: $fileName, fileSize: $fileSize, status: $status, createdAt: $createdAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$TransferModelCopyWith<$Res> implements $TransferModelCopyWith<$Res> {
  factory _$TransferModelCopyWith(_TransferModel value, $Res Function(_TransferModel) _then) = __$TransferModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String senderId, String receiverId, String? senderUsername, String? receiverUsername, String fileName, int fileSize,@JsonKey(fromJson: _statusFromJson, toJson: _statusToJson) TransferStatus status, DateTime createdAt, DateTime? expiresAt
});




}
/// @nodoc
class __$TransferModelCopyWithImpl<$Res>
    implements _$TransferModelCopyWith<$Res> {
  __$TransferModelCopyWithImpl(this._self, this._then);

  final _TransferModel _self;
  final $Res Function(_TransferModel) _then;

/// Create a copy of TransferModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? senderId = null,Object? receiverId = null,Object? senderUsername = freezed,Object? receiverUsername = freezed,Object? fileName = null,Object? fileSize = null,Object? status = null,Object? createdAt = null,Object? expiresAt = freezed,}) {
  return _then(_TransferModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,receiverId: null == receiverId ? _self.receiverId : receiverId // ignore: cast_nullable_to_non_nullable
as String,senderUsername: freezed == senderUsername ? _self.senderUsername : senderUsername // ignore: cast_nullable_to_non_nullable
as String?,receiverUsername: freezed == receiverUsername ? _self.receiverUsername : receiverUsername // ignore: cast_nullable_to_non_nullable
as String?,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,fileSize: null == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransferStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
