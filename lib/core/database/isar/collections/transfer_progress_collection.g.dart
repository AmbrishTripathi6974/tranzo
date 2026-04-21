// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_progress_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTransferProgressCollectionCollection on Isar {
  IsarCollection<TransferProgressCollection> get transferProgressCollections =>
      this.collection();
}

const TransferProgressCollectionSchema = CollectionSchema(
  name: r'TransferProgressCollection',
  id: 4710386982292604459,
  properties: {
    r'completedChunkIndexes': PropertySchema(
      id: 0,
      name: r'completedChunkIndexes',
      type: IsarType.longList,
    ),
    r'direction': PropertySchema(
      id: 1,
      name: r'direction',
      type: IsarType.long,
    ),
    r'fileId': PropertySchema(id: 2, name: r'fileId', type: IsarType.string),
    r'fileName': PropertySchema(
      id: 3,
      name: r'fileName',
      type: IsarType.string,
    ),
    r'lastErrorCode': PropertySchema(
      id: 4,
      name: r'lastErrorCode',
      type: IsarType.string,
    ),
    r'nextRetryAt': PropertySchema(
      id: 5,
      name: r'nextRetryAt',
      type: IsarType.dateTime,
    ),
    r'progressKey': PropertySchema(
      id: 6,
      name: r'progressKey',
      type: IsarType.string,
    ),
    r'retryAttempt': PropertySchema(
      id: 7,
      name: r'retryAttempt',
      type: IsarType.long,
    ),
    r'status': PropertySchema(id: 8, name: r'status', type: IsarType.string),
    r'totalBytes': PropertySchema(
      id: 9,
      name: r'totalBytes',
      type: IsarType.long,
    ),
    r'totalChunks': PropertySchema(
      id: 10,
      name: r'totalChunks',
      type: IsarType.long,
    ),
    r'transferId': PropertySchema(
      id: 11,
      name: r'transferId',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 12,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _transferProgressCollectionEstimateSize,
  serialize: _transferProgressCollectionSerialize,
  deserialize: _transferProgressCollectionDeserialize,
  deserializeProp: _transferProgressCollectionDeserializeProp,
  idName: r'id',
  indexes: {
    r'progressKey': IndexSchema(
      id: 8097696484264715587,
      name: r'progressKey',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'progressKey',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'transferId': IndexSchema(
      id: -3874495609261714017,
      name: r'transferId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'transferId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'fileId': IndexSchema(
      id: -2092632783237962250,
      name: r'fileId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'fileId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _transferProgressCollectionGetId,
  getLinks: _transferProgressCollectionGetLinks,
  attach: _transferProgressCollectionAttach,
  version: '3.3.2',
);

int _transferProgressCollectionEstimateSize(
  TransferProgressCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.completedChunkIndexes.length * 8;
  bytesCount += 3 + object.fileId.length * 3;
  bytesCount += 3 + object.fileName.length * 3;
  {
    final value = object.lastErrorCode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.progressKey.length * 3;
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.transferId.length * 3;
  return bytesCount;
}

void _transferProgressCollectionSerialize(
  TransferProgressCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLongList(offsets[0], object.completedChunkIndexes);
  writer.writeLong(offsets[1], object.direction);
  writer.writeString(offsets[2], object.fileId);
  writer.writeString(offsets[3], object.fileName);
  writer.writeString(offsets[4], object.lastErrorCode);
  writer.writeDateTime(offsets[5], object.nextRetryAt);
  writer.writeString(offsets[6], object.progressKey);
  writer.writeLong(offsets[7], object.retryAttempt);
  writer.writeString(offsets[8], object.status);
  writer.writeLong(offsets[9], object.totalBytes);
  writer.writeLong(offsets[10], object.totalChunks);
  writer.writeString(offsets[11], object.transferId);
  writer.writeDateTime(offsets[12], object.updatedAt);
}

TransferProgressCollection _transferProgressCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TransferProgressCollection();
  object.completedChunkIndexes = reader.readLongList(offsets[0]) ?? [];
  object.direction = reader.readLong(offsets[1]);
  object.fileId = reader.readString(offsets[2]);
  object.fileName = reader.readString(offsets[3]);
  object.id = id;
  object.lastErrorCode = reader.readStringOrNull(offsets[4]);
  object.nextRetryAt = reader.readDateTimeOrNull(offsets[5]);
  object.progressKey = reader.readString(offsets[6]);
  object.retryAttempt = reader.readLong(offsets[7]);
  object.status = reader.readString(offsets[8]);
  object.totalBytes = reader.readLong(offsets[9]);
  object.totalChunks = reader.readLong(offsets[10]);
  object.transferId = reader.readString(offsets[11]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[12]);
  return object;
}

P _transferProgressCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongList(offset) ?? []) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _transferProgressCollectionGetId(TransferProgressCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _transferProgressCollectionGetLinks(
  TransferProgressCollection object,
) {
  return [];
}

void _transferProgressCollectionAttach(
  IsarCollection<dynamic> col,
  Id id,
  TransferProgressCollection object,
) {
  object.id = id;
}

extension TransferProgressCollectionByIndex
    on IsarCollection<TransferProgressCollection> {
  Future<TransferProgressCollection?> getByProgressKey(String progressKey) {
    return getByIndex(r'progressKey', [progressKey]);
  }

  TransferProgressCollection? getByProgressKeySync(String progressKey) {
    return getByIndexSync(r'progressKey', [progressKey]);
  }

  Future<bool> deleteByProgressKey(String progressKey) {
    return deleteByIndex(r'progressKey', [progressKey]);
  }

  bool deleteByProgressKeySync(String progressKey) {
    return deleteByIndexSync(r'progressKey', [progressKey]);
  }

  Future<List<TransferProgressCollection?>> getAllByProgressKey(
    List<String> progressKeyValues,
  ) {
    final values = progressKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'progressKey', values);
  }

  List<TransferProgressCollection?> getAllByProgressKeySync(
    List<String> progressKeyValues,
  ) {
    final values = progressKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'progressKey', values);
  }

  Future<int> deleteAllByProgressKey(List<String> progressKeyValues) {
    final values = progressKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'progressKey', values);
  }

  int deleteAllByProgressKeySync(List<String> progressKeyValues) {
    final values = progressKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'progressKey', values);
  }

  Future<Id> putByProgressKey(TransferProgressCollection object) {
    return putByIndex(r'progressKey', object);
  }

  Id putByProgressKeySync(
    TransferProgressCollection object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(r'progressKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByProgressKey(
    List<TransferProgressCollection> objects,
  ) {
    return putAllByIndex(r'progressKey', objects);
  }

  List<Id> putAllByProgressKeySync(
    List<TransferProgressCollection> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'progressKey', objects, saveLinks: saveLinks);
  }
}

extension TransferProgressCollectionQueryWhereSort
    on
        QueryBuilder<
          TransferProgressCollection,
          TransferProgressCollection,
          QWhere
        > {
  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterWhere
  >
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TransferProgressCollectionQueryWhere
    on
        QueryBuilder<
          TransferProgressCollection,
          TransferProgressCollection,
          QWhereClause
        > {
  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterWhereClause
  >
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterWhereClause
  >
  progressKeyEqualTo(String progressKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'progressKey',
          value: [progressKey],
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterWhereClause
  >
  progressKeyNotEqualTo(String progressKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'progressKey',
                lower: [],
                upper: [progressKey],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'progressKey',
                lower: [progressKey],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'progressKey',
                lower: [progressKey],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'progressKey',
                lower: [],
                upper: [progressKey],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterWhereClause
  >
  transferIdEqualTo(String transferId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'transferId', value: [transferId]),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterWhereClause
  >
  transferIdNotEqualTo(String transferId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transferId',
                lower: [],
                upper: [transferId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transferId',
                lower: [transferId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transferId',
                lower: [transferId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'transferId',
                lower: [],
                upper: [transferId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterWhereClause
  >
  fileIdEqualTo(String fileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'fileId', value: [fileId]),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterWhereClause
  >
  fileIdNotEqualTo(String fileId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'fileId',
                lower: [],
                upper: [fileId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'fileId',
                lower: [fileId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'fileId',
                lower: [fileId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'fileId',
                lower: [],
                upper: [fileId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension TransferProgressCollectionQueryFilter
    on
        QueryBuilder<
          TransferProgressCollection,
          TransferProgressCollection,
          QFilterCondition
        > {
  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  completedChunkIndexesElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'completedChunkIndexes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  completedChunkIndexesElementGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'completedChunkIndexes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  completedChunkIndexesElementLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'completedChunkIndexes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  completedChunkIndexesElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'completedChunkIndexes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  completedChunkIndexesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedChunkIndexes',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  completedChunkIndexesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'completedChunkIndexes', 0, true, 0, true);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  completedChunkIndexesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'completedChunkIndexes', 0, false, 999999, true);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  completedChunkIndexesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedChunkIndexes',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  completedChunkIndexesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedChunkIndexes',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  completedChunkIndexesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'completedChunkIndexes',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  directionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'direction', value: value),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  directionGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'direction',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  directionLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'direction',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  directionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'direction',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  fileNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  fileNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  fileNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  fileNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fileName',
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
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  fileNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  fileNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  fileNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'fileName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  fileNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'fileName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  fileNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fileName', value: ''),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  fileNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'fileName', value: ''),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  lastErrorCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastErrorCode'),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  lastErrorCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastErrorCode'),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  lastErrorCodeEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lastErrorCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  lastErrorCodeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastErrorCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  lastErrorCodeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastErrorCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  lastErrorCodeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastErrorCode',
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
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  lastErrorCodeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'lastErrorCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  lastErrorCodeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'lastErrorCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  lastErrorCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'lastErrorCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  lastErrorCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'lastErrorCode',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  lastErrorCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastErrorCode', value: ''),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  lastErrorCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'lastErrorCode', value: ''),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  nextRetryAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'nextRetryAt'),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  nextRetryAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'nextRetryAt'),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  nextRetryAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nextRetryAt', value: value),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  nextRetryAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nextRetryAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  nextRetryAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nextRetryAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  nextRetryAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nextRetryAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  progressKeyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'progressKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  progressKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'progressKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  progressKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'progressKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  progressKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'progressKey',
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
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  progressKeyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'progressKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  progressKeyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'progressKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  progressKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'progressKey',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  progressKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'progressKey',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  progressKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'progressKey', value: ''),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  progressKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'progressKey', value: ''),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  retryAttemptEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'retryAttempt', value: value),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  retryAttemptGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'retryAttempt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  retryAttemptLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'retryAttempt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  retryAttemptBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'retryAttempt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  totalBytesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'totalBytes', value: value),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  totalBytesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totalBytes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  totalBytesLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totalBytes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  totalBytesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totalBytes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  totalChunksEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'totalChunks', value: value),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  totalChunksGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totalChunks',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  totalChunksLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totalChunks',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  totalChunksBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totalChunks',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
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
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  transferIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'transferId', value: ''),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  updatedAtGreaterThan(DateTime? value, {bool include = false}) {
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
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  updatedAtLessThan(DateTime? value, {bool include = false}) {
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
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterFilterCondition
  >
  updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
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

extension TransferProgressCollectionQueryObject
    on
        QueryBuilder<
          TransferProgressCollection,
          TransferProgressCollection,
          QFilterCondition
        > {}

extension TransferProgressCollectionQueryLinks
    on
        QueryBuilder<
          TransferProgressCollection,
          TransferProgressCollection,
          QFilterCondition
        > {}

extension TransferProgressCollectionQuerySortBy
    on
        QueryBuilder<
          TransferProgressCollection,
          TransferProgressCollection,
          QSortBy
        > {
  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  sortByDirection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.asc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  sortByDirectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.desc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  sortByFileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileId', Sort.asc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  sortByFileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileId', Sort.desc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  sortByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  sortByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  sortByLastErrorCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastErrorCode', Sort.asc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  sortByLastErrorCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastErrorCode', Sort.desc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  sortByNextRetryAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextRetryAt', Sort.asc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  sortByNextRetryAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextRetryAt', Sort.desc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  sortByProgressKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressKey', Sort.asc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  sortByProgressKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressKey', Sort.desc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  sortByRetryAttempt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryAttempt', Sort.asc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  sortByRetryAttemptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryAttempt', Sort.desc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  sortByTotalBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBytes', Sort.asc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  sortByTotalBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBytes', Sort.desc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  sortByTotalChunks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalChunks', Sort.asc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  sortByTotalChunksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalChunks', Sort.desc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  sortByTransferId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transferId', Sort.asc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  sortByTransferIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transferId', Sort.desc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension TransferProgressCollectionQuerySortThenBy
    on
        QueryBuilder<
          TransferProgressCollection,
          TransferProgressCollection,
          QSortThenBy
        > {
  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  thenByDirection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.asc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  thenByDirectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direction', Sort.desc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  thenByFileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileId', Sort.asc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  thenByFileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileId', Sort.desc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  thenByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  thenByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  thenByLastErrorCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastErrorCode', Sort.asc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  thenByLastErrorCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastErrorCode', Sort.desc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  thenByNextRetryAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextRetryAt', Sort.asc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  thenByNextRetryAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextRetryAt', Sort.desc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  thenByProgressKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressKey', Sort.asc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  thenByProgressKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressKey', Sort.desc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  thenByRetryAttempt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryAttempt', Sort.asc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  thenByRetryAttemptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retryAttempt', Sort.desc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  thenByTotalBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBytes', Sort.asc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  thenByTotalBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBytes', Sort.desc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  thenByTotalChunks() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalChunks', Sort.asc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  thenByTotalChunksDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalChunks', Sort.desc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  thenByTransferId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transferId', Sort.asc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  thenByTransferIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transferId', Sort.desc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QAfterSortBy
  >
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension TransferProgressCollectionQueryWhereDistinct
    on
        QueryBuilder<
          TransferProgressCollection,
          TransferProgressCollection,
          QDistinct
        > {
  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QDistinct
  >
  distinctByCompletedChunkIndexes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedChunkIndexes');
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QDistinct
  >
  distinctByDirection() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'direction');
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QDistinct
  >
  distinctByFileId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QDistinct
  >
  distinctByFileName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QDistinct
  >
  distinctByLastErrorCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'lastErrorCode',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QDistinct
  >
  distinctByNextRetryAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextRetryAt');
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QDistinct
  >
  distinctByProgressKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'progressKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QDistinct
  >
  distinctByRetryAttempt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'retryAttempt');
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QDistinct
  >
  distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QDistinct
  >
  distinctByTotalBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalBytes');
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QDistinct
  >
  distinctByTotalChunks() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalChunks');
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QDistinct
  >
  distinctByTransferId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'transferId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<
    TransferProgressCollection,
    TransferProgressCollection,
    QDistinct
  >
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension TransferProgressCollectionQueryProperty
    on
        QueryBuilder<
          TransferProgressCollection,
          TransferProgressCollection,
          QQueryProperty
        > {
  QueryBuilder<TransferProgressCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TransferProgressCollection, List<int>, QQueryOperations>
  completedChunkIndexesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedChunkIndexes');
    });
  }

  QueryBuilder<TransferProgressCollection, int, QQueryOperations>
  directionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'direction');
    });
  }

  QueryBuilder<TransferProgressCollection, String, QQueryOperations>
  fileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileId');
    });
  }

  QueryBuilder<TransferProgressCollection, String, QQueryOperations>
  fileNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileName');
    });
  }

  QueryBuilder<TransferProgressCollection, String?, QQueryOperations>
  lastErrorCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastErrorCode');
    });
  }

  QueryBuilder<TransferProgressCollection, DateTime?, QQueryOperations>
  nextRetryAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextRetryAt');
    });
  }

  QueryBuilder<TransferProgressCollection, String, QQueryOperations>
  progressKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'progressKey');
    });
  }

  QueryBuilder<TransferProgressCollection, int, QQueryOperations>
  retryAttemptProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'retryAttempt');
    });
  }

  QueryBuilder<TransferProgressCollection, String, QQueryOperations>
  statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<TransferProgressCollection, int, QQueryOperations>
  totalBytesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalBytes');
    });
  }

  QueryBuilder<TransferProgressCollection, int, QQueryOperations>
  totalChunksProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalChunks');
    });
  }

  QueryBuilder<TransferProgressCollection, String, QQueryOperations>
  transferIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transferId');
    });
  }

  QueryBuilder<TransferProgressCollection, DateTime?, QQueryOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
