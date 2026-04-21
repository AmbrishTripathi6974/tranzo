// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queued_transfer_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetQueuedTransferCollectionCollection on Isar {
  IsarCollection<QueuedTransferCollection> get queuedTransferCollections =>
      this.collection();
}

const QueuedTransferCollectionSchema = CollectionSchema(
  name: r'QueuedTransferCollection',
  id: 1944696369555128332,
  properties: {
    r'expiresAt': PropertySchema(
      id: 0,
      name: r'expiresAt',
      type: IsarType.dateTime,
    ),
    r'fileId': PropertySchema(id: 1, name: r'fileId', type: IsarType.string),
    r'queueKey': PropertySchema(
      id: 2,
      name: r'queueKey',
      type: IsarType.string,
    ),
    r'queuedAt': PropertySchema(
      id: 3,
      name: r'queuedAt',
      type: IsarType.dateTime,
    ),
    r'reason': PropertySchema(id: 4, name: r'reason', type: IsarType.string),
    r'status': PropertySchema(id: 5, name: r'status', type: IsarType.string),
    r'transferId': PropertySchema(
      id: 6,
      name: r'transferId',
      type: IsarType.string,
    ),
  },

  estimateSize: _queuedTransferCollectionEstimateSize,
  serialize: _queuedTransferCollectionSerialize,
  deserialize: _queuedTransferCollectionDeserialize,
  deserializeProp: _queuedTransferCollectionDeserializeProp,
  idName: r'id',
  indexes: {
    r'queueKey': IndexSchema(
      id: 8269283566244377845,
      name: r'queueKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'queueKey',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _queuedTransferCollectionGetId,
  getLinks: _queuedTransferCollectionGetLinks,
  attach: _queuedTransferCollectionAttach,
  version: '3.3.2',
);

int _queuedTransferCollectionEstimateSize(
  QueuedTransferCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.fileId.length * 3;
  bytesCount += 3 + object.queueKey.length * 3;
  {
    final value = object.reason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.transferId.length * 3;
  return bytesCount;
}

void _queuedTransferCollectionSerialize(
  QueuedTransferCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.expiresAt);
  writer.writeString(offsets[1], object.fileId);
  writer.writeString(offsets[2], object.queueKey);
  writer.writeDateTime(offsets[3], object.queuedAt);
  writer.writeString(offsets[4], object.reason);
  writer.writeString(offsets[5], object.status);
  writer.writeString(offsets[6], object.transferId);
}

QueuedTransferCollection _queuedTransferCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = QueuedTransferCollection();
  object.expiresAt = reader.readDateTime(offsets[0]);
  object.fileId = reader.readString(offsets[1]);
  object.id = id;
  object.queueKey = reader.readString(offsets[2]);
  object.queuedAt = reader.readDateTime(offsets[3]);
  object.reason = reader.readStringOrNull(offsets[4]);
  object.status = reader.readString(offsets[5]);
  object.transferId = reader.readString(offsets[6]);
  return object;
}

P _queuedTransferCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _queuedTransferCollectionGetId(QueuedTransferCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _queuedTransferCollectionGetLinks(
  QueuedTransferCollection object,
) {
  return [];
}

void _queuedTransferCollectionAttach(
  IsarCollection<dynamic> col,
  Id id,
  QueuedTransferCollection object,
) {
  object.id = id;
}

extension QueuedTransferCollectionByIndex
    on IsarCollection<QueuedTransferCollection> {
  Future<QueuedTransferCollection?> getByQueueKey(String queueKey) {
    return getByIndex(r'queueKey', [queueKey]);
  }

  QueuedTransferCollection? getByQueueKeySync(String queueKey) {
    return getByIndexSync(r'queueKey', [queueKey]);
  }

  Future<bool> deleteByQueueKey(String queueKey) {
    return deleteByIndex(r'queueKey', [queueKey]);
  }

  bool deleteByQueueKeySync(String queueKey) {
    return deleteByIndexSync(r'queueKey', [queueKey]);
  }

  Future<List<QueuedTransferCollection?>> getAllByQueueKey(
    List<String> queueKeyValues,
  ) {
    final values = queueKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'queueKey', values);
  }

  List<QueuedTransferCollection?> getAllByQueueKeySync(
    List<String> queueKeyValues,
  ) {
    final values = queueKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'queueKey', values);
  }

  Future<int> deleteAllByQueueKey(List<String> queueKeyValues) {
    final values = queueKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'queueKey', values);
  }

  int deleteAllByQueueKeySync(List<String> queueKeyValues) {
    final values = queueKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'queueKey', values);
  }

  Future<Id> putByQueueKey(QueuedTransferCollection object) {
    return putByIndex(r'queueKey', object);
  }

  Id putByQueueKeySync(
    QueuedTransferCollection object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(r'queueKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByQueueKey(List<QueuedTransferCollection> objects) {
    return putAllByIndex(r'queueKey', objects);
  }

  List<Id> putAllByQueueKeySync(
    List<QueuedTransferCollection> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'queueKey', objects, saveLinks: saveLinks);
  }
}

extension QueuedTransferCollectionQueryWhereSort
    on
        QueryBuilder<
          QueuedTransferCollection,
          QueuedTransferCollection,
          QWhere
        > {
  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension QueuedTransferCollectionQueryWhere
    on
        QueryBuilder<
          QueuedTransferCollection,
          QueuedTransferCollection,
          QWhereClause
        > {
  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterWhereClause
  >
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

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterWhereClause
  >
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterWhereClause
  >
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterWhereClause
  >
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

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterWhereClause
  >
  queueKeyEqualTo(String queueKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'queueKey', value: [queueKey]),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterWhereClause
  >
  queueKeyNotEqualTo(String queueKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'queueKey',
                lower: [],
                upper: [queueKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'queueKey',
                lower: [queueKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'queueKey',
                lower: [queueKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'queueKey',
                lower: [],
                upper: [queueKey],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension QueuedTransferCollectionQueryFilter
    on
        QueryBuilder<
          QueuedTransferCollection,
          QueuedTransferCollection,
          QFilterCondition
        > {
  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  expiresAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'expiresAt', value: value),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  expiresAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'expiresAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  expiresAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'expiresAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  expiresAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'expiresAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  fileIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'fileId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  fileIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fileId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  fileIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fileId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  fileIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fileId',
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
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  fileIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'fileId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  fileIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'fileId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  fileIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'fileId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  fileIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'fileId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  fileIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fileId', value: ''),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  fileIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'fileId', value: ''),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
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
    QueuedTransferCollection,
    QueuedTransferCollection,
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
    QueuedTransferCollection,
    QueuedTransferCollection,
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
    QueuedTransferCollection,
    QueuedTransferCollection,
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
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  queueKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'queueKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  queueKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'queueKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  queueKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'queueKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  queueKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'queueKey',
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
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  queueKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'queueKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  queueKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'queueKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  queueKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'queueKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  queueKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'queueKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  queueKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'queueKey', value: ''),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  queueKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'queueKey', value: ''),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  queuedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'queuedAt', value: value),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  queuedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'queuedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  queuedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'queuedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  queuedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'queuedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  reasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'reason'),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  reasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'reason'),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  reasonEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'reason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  reasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'reason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  reasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'reason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  reasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'reason',
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
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  reasonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'reason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  reasonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'reason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  reasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'reason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  reasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'reason',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  reasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'reason', value: ''),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  reasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'reason', value: ''),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  statusEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
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
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  statusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  statusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'status',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  transferIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'transferId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  transferIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'transferId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  transferIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'transferId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  transferIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'transferId',
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
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  transferIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'transferId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  transferIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'transferId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  transferIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'transferId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  transferIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'transferId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  transferIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'transferId', value: ''),
      );
    });
  }

  QueryBuilder<
    QueuedTransferCollection,
    QueuedTransferCollection,
    QAfterFilterCondition
  >
  transferIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'transferId', value: ''),
      );
    });
  }
}

extension QueuedTransferCollectionQueryObject
    on
        QueryBuilder<
          QueuedTransferCollection,
          QueuedTransferCollection,
          QFilterCondition
        > {}

extension QueuedTransferCollectionQueryLinks
    on
        QueryBuilder<
          QueuedTransferCollection,
          QueuedTransferCollection,
          QFilterCondition
        > {}

extension QueuedTransferCollectionQuerySortBy
    on
        QueryBuilder<
          QueuedTransferCollection,
          QueuedTransferCollection,
          QSortBy
        > {
  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  sortByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.asc);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  sortByExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.desc);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  sortByFileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileId', Sort.asc);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  sortByFileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileId', Sort.desc);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  sortByQueueKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queueKey', Sort.asc);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  sortByQueueKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queueKey', Sort.desc);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  sortByQueuedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queuedAt', Sort.asc);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  sortByQueuedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queuedAt', Sort.desc);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  sortByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  sortByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  sortByTransferId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transferId', Sort.asc);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  sortByTransferIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transferId', Sort.desc);
    });
  }
}

extension QueuedTransferCollectionQuerySortThenBy
    on
        QueryBuilder<
          QueuedTransferCollection,
          QueuedTransferCollection,
          QSortThenBy
        > {
  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  thenByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.asc);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  thenByExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.desc);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  thenByFileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileId', Sort.asc);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  thenByFileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileId', Sort.desc);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  thenByQueueKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queueKey', Sort.asc);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  thenByQueueKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queueKey', Sort.desc);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  thenByQueuedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queuedAt', Sort.asc);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  thenByQueuedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queuedAt', Sort.desc);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  thenByReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.asc);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  thenByReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reason', Sort.desc);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  thenByTransferId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transferId', Sort.asc);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QAfterSortBy>
  thenByTransferIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transferId', Sort.desc);
    });
  }
}

extension QueuedTransferCollectionQueryWhereDistinct
    on
        QueryBuilder<
          QueuedTransferCollection,
          QueuedTransferCollection,
          QDistinct
        > {
  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QDistinct>
  distinctByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expiresAt');
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QDistinct>
  distinctByFileId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QDistinct>
  distinctByQueueKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'queueKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QDistinct>
  distinctByQueuedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'queuedAt');
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QDistinct>
  distinctByReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QDistinct>
  distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QueuedTransferCollection, QueuedTransferCollection, QDistinct>
  distinctByTransferId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'transferId', caseSensitive: caseSensitive);
    });
  }
}

extension QueuedTransferCollectionQueryProperty
    on
        QueryBuilder<
          QueuedTransferCollection,
          QueuedTransferCollection,
          QQueryProperty
        > {
  QueryBuilder<QueuedTransferCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<QueuedTransferCollection, DateTime, QQueryOperations>
  expiresAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expiresAt');
    });
  }

  QueryBuilder<QueuedTransferCollection, String, QQueryOperations>
  fileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileId');
    });
  }

  QueryBuilder<QueuedTransferCollection, String, QQueryOperations>
  queueKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'queueKey');
    });
  }

  QueryBuilder<QueuedTransferCollection, DateTime, QQueryOperations>
  queuedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'queuedAt');
    });
  }

  QueryBuilder<QueuedTransferCollection, String?, QQueryOperations>
  reasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reason');
    });
  }

  QueryBuilder<QueuedTransferCollection, String, QQueryOperations>
  statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<QueuedTransferCollection, String, QQueryOperations>
  transferIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transferId');
    });
  }
}
