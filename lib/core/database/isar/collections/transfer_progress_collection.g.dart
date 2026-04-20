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
    r'fileName': PropertySchema(
      id: 2,
      name: r'fileName',
      type: IsarType.string,
    ),
    r'totalBytes': PropertySchema(
      id: 3,
      name: r'totalBytes',
      type: IsarType.long,
    ),
    r'transferId': PropertySchema(
      id: 4,
      name: r'transferId',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 5,
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
    r'transferId': IndexSchema(
      id: -3874495609261714017,
      name: r'transferId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'transferId',
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
  bytesCount += 3 + object.fileName.length * 3;
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
  writer.writeString(offsets[2], object.fileName);
  writer.writeLong(offsets[3], object.totalBytes);
  writer.writeString(offsets[4], object.transferId);
  writer.writeDateTime(offsets[5], object.updatedAt);
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
  object.fileName = reader.readString(offsets[2]);
  object.id = id;
  object.totalBytes = reader.readLong(offsets[3]);
  object.transferId = reader.readString(offsets[4]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[5]);
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
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
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
  Future<TransferProgressCollection?> getByTransferId(String transferId) {
    return getByIndex(r'transferId', [transferId]);
  }

  TransferProgressCollection? getByTransferIdSync(String transferId) {
    return getByIndexSync(r'transferId', [transferId]);
  }

  Future<bool> deleteByTransferId(String transferId) {
    return deleteByIndex(r'transferId', [transferId]);
  }

  bool deleteByTransferIdSync(String transferId) {
    return deleteByIndexSync(r'transferId', [transferId]);
  }

  Future<List<TransferProgressCollection?>> getAllByTransferId(
    List<String> transferIdValues,
  ) {
    final values = transferIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'transferId', values);
  }

  List<TransferProgressCollection?> getAllByTransferIdSync(
    List<String> transferIdValues,
  ) {
    final values = transferIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'transferId', values);
  }

  Future<int> deleteAllByTransferId(List<String> transferIdValues) {
    final values = transferIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'transferId', values);
  }

  int deleteAllByTransferIdSync(List<String> transferIdValues) {
    final values = transferIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'transferId', values);
  }

  Future<Id> putByTransferId(TransferProgressCollection object) {
    return putByIndex(r'transferId', object);
  }

  Id putByTransferIdSync(
    TransferProgressCollection object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(r'transferId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByTransferId(
    List<TransferProgressCollection> objects,
  ) {
    return putAllByIndex(r'transferId', objects);
  }

  List<Id> putAllByTransferIdSync(
    List<TransferProgressCollection> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'transferId', objects, saveLinks: saveLinks);
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
  fileNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileName');
    });
  }

  QueryBuilder<TransferProgressCollection, int, QQueryOperations>
  totalBytesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalBytes');
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
