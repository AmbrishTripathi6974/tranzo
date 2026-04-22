// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sender_trust_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSenderTrustCollectionCollection on Isar {
  IsarCollection<SenderTrustCollection> get senderTrustCollections =>
      this.collection();
}

const SenderTrustCollectionSchema = CollectionSchema(
  name: r'SenderTrustCollection',
  id: 2287319394690026191,
  properties: {
    r'senderId': PropertySchema(
      id: 0,
      name: r'senderId',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 1,
      name: r'status',
      type: IsarType.byte,
      enumMap: _SenderTrustCollectionstatusEnumValueMap,
    ),
    r'trustedUntil': PropertySchema(
      id: 2,
      name: r'trustedUntil',
      type: IsarType.dateTime,
    ),
    r'updatedAt': PropertySchema(
      id: 3,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _senderTrustCollectionEstimateSize,
  serialize: _senderTrustCollectionSerialize,
  deserialize: _senderTrustCollectionDeserialize,
  deserializeProp: _senderTrustCollectionDeserializeProp,
  idName: r'id',
  indexes: {
    r'senderId': IndexSchema(
      id: -1619654757968658561,
      name: r'senderId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'senderId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _senderTrustCollectionGetId,
  getLinks: _senderTrustCollectionGetLinks,
  attach: _senderTrustCollectionAttach,
  version: '3.3.2',
);

int _senderTrustCollectionEstimateSize(
  SenderTrustCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.senderId.length * 3;
  return bytesCount;
}

void _senderTrustCollectionSerialize(
  SenderTrustCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.senderId);
  writer.writeByte(offsets[1], object.status.index);
  writer.writeDateTime(offsets[2], object.trustedUntil);
  writer.writeDateTime(offsets[3], object.updatedAt);
}

SenderTrustCollection _senderTrustCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SenderTrustCollection();
  object.id = id;
  object.senderId = reader.readString(offsets[0]);
  object.status =
      _SenderTrustCollectionstatusValueEnumMap[reader.readByteOrNull(
        offsets[1],
      )] ??
      SenderTrustStatus.unknown;
  object.trustedUntil = reader.readDateTimeOrNull(offsets[2]);
  object.updatedAt = reader.readDateTime(offsets[3]);
  return object;
}

P _senderTrustCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (_SenderTrustCollectionstatusValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              SenderTrustStatus.unknown)
          as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SenderTrustCollectionstatusEnumValueMap = {
  'unknown': 0,
  'trusted': 1,
  'blocked': 2,
};
const _SenderTrustCollectionstatusValueEnumMap = {
  0: SenderTrustStatus.unknown,
  1: SenderTrustStatus.trusted,
  2: SenderTrustStatus.blocked,
};

Id _senderTrustCollectionGetId(SenderTrustCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _senderTrustCollectionGetLinks(
  SenderTrustCollection object,
) {
  return [];
}

void _senderTrustCollectionAttach(
  IsarCollection<dynamic> col,
  Id id,
  SenderTrustCollection object,
) {
  object.id = id;
}

extension SenderTrustCollectionByIndex
    on IsarCollection<SenderTrustCollection> {
  Future<SenderTrustCollection?> getBySenderId(String senderId) {
    return getByIndex(r'senderId', [senderId]);
  }

  SenderTrustCollection? getBySenderIdSync(String senderId) {
    return getByIndexSync(r'senderId', [senderId]);
  }

  Future<bool> deleteBySenderId(String senderId) {
    return deleteByIndex(r'senderId', [senderId]);
  }

  bool deleteBySenderIdSync(String senderId) {
    return deleteByIndexSync(r'senderId', [senderId]);
  }

  Future<List<SenderTrustCollection?>> getAllBySenderId(
    List<String> senderIdValues,
  ) {
    final values = senderIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'senderId', values);
  }

  List<SenderTrustCollection?> getAllBySenderIdSync(
    List<String> senderIdValues,
  ) {
    final values = senderIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'senderId', values);
  }

  Future<int> deleteAllBySenderId(List<String> senderIdValues) {
    final values = senderIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'senderId', values);
  }

  int deleteAllBySenderIdSync(List<String> senderIdValues) {
    final values = senderIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'senderId', values);
  }

  Future<Id> putBySenderId(SenderTrustCollection object) {
    return putByIndex(r'senderId', object);
  }

  Id putBySenderIdSync(SenderTrustCollection object, {bool saveLinks = true}) {
    return putByIndexSync(r'senderId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySenderId(List<SenderTrustCollection> objects) {
    return putAllByIndex(r'senderId', objects);
  }

  List<Id> putAllBySenderIdSync(
    List<SenderTrustCollection> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'senderId', objects, saveLinks: saveLinks);
  }
}

extension SenderTrustCollectionQueryWhereSort
    on QueryBuilder<SenderTrustCollection, SenderTrustCollection, QWhere> {
  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SenderTrustCollectionQueryWhere
    on
        QueryBuilder<
          SenderTrustCollection,
          SenderTrustCollection,
          QWhereClause
        > {
  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QAfterWhereClause>
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QAfterWhereClause>
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QAfterWhereClause>
  senderIdEqualTo(String senderId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'senderId', value: [senderId]),
      );
    });
  }

  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QAfterWhereClause>
  senderIdNotEqualTo(String senderId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'senderId',
                lower: [],
                upper: [senderId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'senderId',
                lower: [senderId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'senderId',
                lower: [senderId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'senderId',
                lower: [],
                upper: [senderId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension SenderTrustCollectionQueryFilter
    on
        QueryBuilder<
          SenderTrustCollection,
          SenderTrustCollection,
          QFilterCondition
        > {
  QueryBuilder<
    SenderTrustCollection,
    SenderTrustCollection,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    SenderTrustCollection,
    SenderTrustCollection,
    QAfterFilterCondition
  >
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SenderTrustCollection,
    SenderTrustCollection,
    QAfterFilterCondition
  >
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SenderTrustCollection,
    SenderTrustCollection,
    QAfterFilterCondition
  >
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    SenderTrustCollection,
    SenderTrustCollection,
    QAfterFilterCondition
  >
  senderIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'senderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SenderTrustCollection,
    SenderTrustCollection,
    QAfterFilterCondition
  >
  senderIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'senderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SenderTrustCollection,
    SenderTrustCollection,
    QAfterFilterCondition
  >
  senderIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'senderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SenderTrustCollection,
    SenderTrustCollection,
    QAfterFilterCondition
  >
  senderIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'senderId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SenderTrustCollection,
    SenderTrustCollection,
    QAfterFilterCondition
  >
  senderIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'senderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SenderTrustCollection,
    SenderTrustCollection,
    QAfterFilterCondition
  >
  senderIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'senderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SenderTrustCollection,
    SenderTrustCollection,
    QAfterFilterCondition
  >
  senderIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'senderId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SenderTrustCollection,
    SenderTrustCollection,
    QAfterFilterCondition
  >
  senderIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'senderId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    SenderTrustCollection,
    SenderTrustCollection,
    QAfterFilterCondition
  >
  senderIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'senderId', value: ''),
      );
    });
  }

  QueryBuilder<
    SenderTrustCollection,
    SenderTrustCollection,
    QAfterFilterCondition
  >
  senderIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'senderId', value: ''),
      );
    });
  }

  QueryBuilder<
    SenderTrustCollection,
    SenderTrustCollection,
    QAfterFilterCondition
  >
  statusEqualTo(SenderTrustStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: value),
      );
    });
  }

  QueryBuilder<
    SenderTrustCollection,
    SenderTrustCollection,
    QAfterFilterCondition
  >
  statusGreaterThan(SenderTrustStatus value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SenderTrustCollection,
    SenderTrustCollection,
    QAfterFilterCondition
  >
  statusLessThan(SenderTrustStatus value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SenderTrustCollection,
    SenderTrustCollection,
    QAfterFilterCondition
  >
  statusBetween(
    SenderTrustStatus lower,
    SenderTrustStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    SenderTrustCollection,
    SenderTrustCollection,
    QAfterFilterCondition
  >
  trustedUntilIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'trustedUntil'),
      );
    });
  }

  QueryBuilder<
    SenderTrustCollection,
    SenderTrustCollection,
    QAfterFilterCondition
  >
  trustedUntilIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'trustedUntil'),
      );
    });
  }

  QueryBuilder<
    SenderTrustCollection,
    SenderTrustCollection,
    QAfterFilterCondition
  >
  trustedUntilEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'trustedUntil', value: value),
      );
    });
  }

  QueryBuilder<
    SenderTrustCollection,
    SenderTrustCollection,
    QAfterFilterCondition
  >
  trustedUntilGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'trustedUntil',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SenderTrustCollection,
    SenderTrustCollection,
    QAfterFilterCondition
  >
  trustedUntilLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'trustedUntil',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SenderTrustCollection,
    SenderTrustCollection,
    QAfterFilterCondition
  >
  trustedUntilBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'trustedUntil',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    SenderTrustCollection,
    SenderTrustCollection,
    QAfterFilterCondition
  >
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<
    SenderTrustCollection,
    SenderTrustCollection,
    QAfterFilterCondition
  >
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SenderTrustCollection,
    SenderTrustCollection,
    QAfterFilterCondition
  >
  updatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    SenderTrustCollection,
    SenderTrustCollection,
    QAfterFilterCondition
  >
  updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension SenderTrustCollectionQueryObject
    on
        QueryBuilder<
          SenderTrustCollection,
          SenderTrustCollection,
          QFilterCondition
        > {}

extension SenderTrustCollectionQueryLinks
    on
        QueryBuilder<
          SenderTrustCollection,
          SenderTrustCollection,
          QFilterCondition
        > {}

extension SenderTrustCollectionQuerySortBy
    on QueryBuilder<SenderTrustCollection, SenderTrustCollection, QSortBy> {
  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QAfterSortBy>
  sortBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QAfterSortBy>
  sortBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }

  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QAfterSortBy>
  sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QAfterSortBy>
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QAfterSortBy>
  sortByTrustedUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trustedUntil', Sort.asc);
    });
  }

  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QAfterSortBy>
  sortByTrustedUntilDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trustedUntil', Sort.desc);
    });
  }

  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SenderTrustCollectionQuerySortThenBy
    on QueryBuilder<SenderTrustCollection, SenderTrustCollection, QSortThenBy> {
  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QAfterSortBy>
  thenBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QAfterSortBy>
  thenBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }

  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QAfterSortBy>
  thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QAfterSortBy>
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QAfterSortBy>
  thenByTrustedUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trustedUntil', Sort.asc);
    });
  }

  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QAfterSortBy>
  thenByTrustedUntilDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trustedUntil', Sort.desc);
    });
  }

  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SenderTrustCollectionQueryWhereDistinct
    on QueryBuilder<SenderTrustCollection, SenderTrustCollection, QDistinct> {
  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QDistinct>
  distinctBySenderId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QDistinct>
  distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QDistinct>
  distinctByTrustedUntil() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trustedUntil');
    });
  }

  QueryBuilder<SenderTrustCollection, SenderTrustCollection, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension SenderTrustCollectionQueryProperty
    on
        QueryBuilder<
          SenderTrustCollection,
          SenderTrustCollection,
          QQueryProperty
        > {
  QueryBuilder<SenderTrustCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SenderTrustCollection, String, QQueryOperations>
  senderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderId');
    });
  }

  QueryBuilder<SenderTrustCollection, SenderTrustStatus, QQueryOperations>
  statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<SenderTrustCollection, DateTime?, QQueryOperations>
  trustedUntilProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trustedUntil');
    });
  }

  QueryBuilder<SenderTrustCollection, DateTime, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
