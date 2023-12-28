// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$StoreData {
  List<StoryType> get storyList => throw _privateConstructorUsedError;
  Uint8List? get logo => throw _privateConstructorUsedError;
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String get businessHours => throw _privateConstructorUsedError;
  List<String> get searchWord => throw _privateConstructorUsedError;
  List<EventType> get eventList => throw _privateConstructorUsedError;
  LatLng get location => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $StoreDataCopyWith<StoreData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoreDataCopyWith<$Res> {
  factory $StoreDataCopyWith(StoreData value, $Res Function(StoreData) then) =
      _$StoreDataCopyWithImpl<$Res, StoreData>;
  @useResult
  $Res call(
      {List<StoryType> storyList,
      Uint8List? logo,
      String id,
      String name,
      String address,
      String businessHours,
      List<String> searchWord,
      List<EventType> eventList,
      LatLng location});
}

/// @nodoc
class _$StoreDataCopyWithImpl<$Res, $Val extends StoreData>
    implements $StoreDataCopyWith<$Res> {
  _$StoreDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? storyList = null,
    Object? logo = freezed,
    Object? id = null,
    Object? name = null,
    Object? address = null,
    Object? businessHours = null,
    Object? searchWord = null,
    Object? eventList = null,
    Object? location = null,
  }) {
    return _then(_value.copyWith(
      storyList: null == storyList
          ? _value.storyList
          : storyList // ignore: cast_nullable_to_non_nullable
              as List<StoryType>,
      logo: freezed == logo
          ? _value.logo
          : logo // ignore: cast_nullable_to_non_nullable
              as Uint8List?,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      businessHours: null == businessHours
          ? _value.businessHours
          : businessHours // ignore: cast_nullable_to_non_nullable
              as String,
      searchWord: null == searchWord
          ? _value.searchWord
          : searchWord // ignore: cast_nullable_to_non_nullable
              as List<String>,
      eventList: null == eventList
          ? _value.eventList
          : eventList // ignore: cast_nullable_to_non_nullable
              as List<EventType>,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as LatLng,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StoreDataImplCopyWith<$Res>
    implements $StoreDataCopyWith<$Res> {
  factory _$$StoreDataImplCopyWith(
          _$StoreDataImpl value, $Res Function(_$StoreDataImpl) then) =
      __$$StoreDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<StoryType> storyList,
      Uint8List? logo,
      String id,
      String name,
      String address,
      String businessHours,
      List<String> searchWord,
      List<EventType> eventList,
      LatLng location});
}

/// @nodoc
class __$$StoreDataImplCopyWithImpl<$Res>
    extends _$StoreDataCopyWithImpl<$Res, _$StoreDataImpl>
    implements _$$StoreDataImplCopyWith<$Res> {
  __$$StoreDataImplCopyWithImpl(
      _$StoreDataImpl _value, $Res Function(_$StoreDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? storyList = null,
    Object? logo = freezed,
    Object? id = null,
    Object? name = null,
    Object? address = null,
    Object? businessHours = null,
    Object? searchWord = null,
    Object? eventList = null,
    Object? location = null,
  }) {
    return _then(_$StoreDataImpl(
      storyList: null == storyList
          ? _value._storyList
          : storyList // ignore: cast_nullable_to_non_nullable
              as List<StoryType>,
      logo: freezed == logo
          ? _value.logo
          : logo // ignore: cast_nullable_to_non_nullable
              as Uint8List?,
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      businessHours: null == businessHours
          ? _value.businessHours
          : businessHours // ignore: cast_nullable_to_non_nullable
              as String,
      searchWord: null == searchWord
          ? _value._searchWord
          : searchWord // ignore: cast_nullable_to_non_nullable
              as List<String>,
      eventList: null == eventList
          ? _value._eventList
          : eventList // ignore: cast_nullable_to_non_nullable
              as List<EventType>,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as LatLng,
    ));
  }
}

/// @nodoc

class _$StoreDataImpl implements _StoreData {
  const _$StoreDataImpl(
      {required final List<StoryType> storyList,
      required this.logo,
      required this.id,
      required this.name,
      required this.address,
      required this.businessHours,
      required final List<String> searchWord,
      required final List<EventType> eventList,
      required this.location})
      : _storyList = storyList,
        _searchWord = searchWord,
        _eventList = eventList;

  final List<StoryType> _storyList;
  @override
  List<StoryType> get storyList {
    if (_storyList is EqualUnmodifiableListView) return _storyList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_storyList);
  }

  @override
  final Uint8List? logo;
  @override
  final String id;
  @override
  final String name;
  @override
  final String address;
  @override
  final String businessHours;
  final List<String> _searchWord;
  @override
  List<String> get searchWord {
    if (_searchWord is EqualUnmodifiableListView) return _searchWord;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_searchWord);
  }

  final List<EventType> _eventList;
  @override
  List<EventType> get eventList {
    if (_eventList is EqualUnmodifiableListView) return _eventList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_eventList);
  }

  @override
  final LatLng location;

  @override
  String toString() {
    return 'StoreData(storyList: $storyList, logo: $logo, id: $id, name: $name, address: $address, businessHours: $businessHours, searchWord: $searchWord, eventList: $eventList, location: $location)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoreDataImpl &&
            const DeepCollectionEquality()
                .equals(other._storyList, _storyList) &&
            const DeepCollectionEquality().equals(other.logo, logo) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.businessHours, businessHours) ||
                other.businessHours == businessHours) &&
            const DeepCollectionEquality()
                .equals(other._searchWord, _searchWord) &&
            const DeepCollectionEquality()
                .equals(other._eventList, _eventList) &&
            (identical(other.location, location) ||
                other.location == location));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_storyList),
      const DeepCollectionEquality().hash(logo),
      id,
      name,
      address,
      businessHours,
      const DeepCollectionEquality().hash(_searchWord),
      const DeepCollectionEquality().hash(_eventList),
      location);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StoreDataImplCopyWith<_$StoreDataImpl> get copyWith =>
      __$$StoreDataImplCopyWithImpl<_$StoreDataImpl>(this, _$identity);
}

abstract class _StoreData implements StoreData {
  const factory _StoreData(
      {required final List<StoryType> storyList,
      required final Uint8List? logo,
      required final String id,
      required final String name,
      required final String address,
      required final String businessHours,
      required final List<String> searchWord,
      required final List<EventType> eventList,
      required final LatLng location}) = _$StoreDataImpl;

  @override
  List<StoryType> get storyList;
  @override
  Uint8List? get logo;
  @override
  String get id;
  @override
  String get name;
  @override
  String get address;
  @override
  String get businessHours;
  @override
  List<String> get searchWord;
  @override
  List<EventType> get eventList;
  @override
  LatLng get location;
  @override
  @JsonKey(ignore: true)
  _$$StoreDataImplCopyWith<_$StoreDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
