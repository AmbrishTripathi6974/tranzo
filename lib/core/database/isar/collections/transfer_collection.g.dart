// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTransferCollectionCollection on Isar {
  IsarCollection<TransferCollection> get transferCollections =>
      this.collection();
}

const TransferCollectionSchema = CollectionSchema(
  name: r'TransferCollection',
  id: -6489140405640320089,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'expiresAt': PropertySchema(
      id: 1,
      name: r'expiresAt',
      type: IsarType.dateTime,
    ),
    r'fileHash': PropertySchema(
      id: 2,
      name: r'fileHash',
      type: IsarType.string,
    ),
    r'fileName': PropertySchema(
      id: 3,
      name: r'fileName',
      type: IsarType.string,
    ),
    r'fileSize': PropertySchema(id: 4, name: r'fileSize', type: IsarType.long),
    r'intentExpiry': PropertySchema(
      id: 5,
      name: r'intentExpiry',
      type: IsarType.dateTime,
    ),
    r'intentScore': PropertySchema(
      id: 6,
      name: r'intentScore',
      type: IsarType.double,
    ),
    r'receiverId': PropertySchema(
      id: 7,
      name: r'receiverId',
      type: IsarType.string,
    ),
    r'senderId': PropertySchema(
      id: 8,
      name: r'senderId',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 9,
      name: r'status',
      type: IsarType.byte,
      enumMap: _TransferCollectionstatusEnumValueMap,
    ),
    r'storagePath': PropertySchema(
      id: 10,
      name: r'storagePath',
      type: IsarType.string,
    ),
    r'transferId': PropertySchema(
      id: 11,
      name: r'transferId',
      type: IsarType.string,
    ),
  },

  estimateSize: _transferCollectionEstimateSize,
  serialize: _transferCollectionSerialize,
  deserialize: _transferCollectionDeserialize,
  deserializeProp: _transferCollectionDeserializeProp,
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

  getId: _transferCollectionGetId,
  getLinks: _transferCollectionGetLinks,
  attach: _transferCollectionAttach,
  version: '3.3.2',
);

int _transferCollectionEstimateSize(
  TransferCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.fileHash;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.fileName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.receiverId.length * 3;
  bytesCount += 3 + object.senderId.length * 3;
  {
    final value = object.storagePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.transferId.length * 3;
  return bytesCount;
}

void _transferCollectionSerialize(
  TransferCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeDateTime(offsets[1], object.expiresAt);
  writer.writeString(offsets[2], object.fileHash);
  writer.writeString(offsets[3], object.fileName);
  writer.writeLong(offsets[4], object.fileSize);
  writer.writeDateTime(offsets[5], object.intentExpiry);
  writer.writeDouble(offsets[6], object.intentScore);
  writer.writeString(offsets[7], object.receiverId);
  writer.writeString(offsets[8], object.senderId);
  writer.writeByte(offsets[9], object.status.index);
  writer.writeString(offsets[10], object.storagePath);
  writer.writeString(offsets[11], object.transferId);
}

TransferCollection _transferCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TransferCollection();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.expiresAt = reader.readDateTimeOrNull(offsets[1]);
  object.fileHash = reader.readStringOrNull(offsets[2]);
  object.fileName = reader.readStringOrNull(offsets[3]);
  object.fileSize = reader.readLongOrNull(offsets[4]);
  object.id = id;
  object.intentExpiry = reader.readDateTimeOrNull(offsets[5]);
  object.intentScore = reader.readDoubleOrNull(offsets[6]);
  object.receiverId = reader.readString(offsets[7]);
  object.senderId = reader.readString(offsets[8]);
  object.status =
      _TransferCollectionstatusValueEnumMap[reader.readByteOrNull(
        offsets[9],
      )] ??
      TransferStatus.pending;
  object.storagePath = reader.readStringOrNull(offsets[10]);
  object.transferId = reader.readString(offsets[11]);
  return object;
}

P _transferCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readDoubleOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (_TransferCollectionstatusValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              TransferStatus.pending)
          as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _TransferCollectionstatusEnumValueMap = {
  'pending': 0,
  'uploading': 1,
  'downloading': 2,
  'completed': 3,
  'failed': 4,
  'cancelled': 5,
};
const _TransferCollectionstatusValueEnumMap = {
  0: TransferStatus.pending,
  1: TransferStatus.uploading,
  2: TransferStatus.downloading,
  3: TransferStatus.completed,
  4: TransferStatus.failed,
  5: TransferStatus.cancelled,
};

Id _transferCollectionGetId(TransferCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _transferCollectionGetLinks(
  TransferCollection object,
) {
  return [];
}

void _transferCollectionAttach(
  IsarCollection<dynamic> col,
  Id id,
  TransferCollection object,
) {
  object.id = id;
}

extension TransferCollectionByIndex on IsarCollection<TransferCollection> {
  Future<TransferCollection?> getByTransferId(String transferId) {
    return getByIndex(r'transferId', [transferId]);
  }

  TransferCollection? getByTransferIdSync(String transferId) {
    return getByIndexSync(r'transferId', [transferId]);
  }

  Future<bool> deleteByTransferId(String transferId) {
    return deleteByIndex(r'transferId', [transferId]);
  }

  bool deleteByTransferIdSync(String transferId) {
    return deleteByIndexSync(r'transferId', [transferId]);
  }

  Future<List<TransferCollection?>> getAllByTransferId(
    List<String> transferIdValues,
  ) {
    final values = transferIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'transferId', values);
  }

  List<TransferCollection?> getAllByTransferIdSync(
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

  Future<Id> putByTransferId(TransferCollection object) {
    return putByIndex(r'transferId', object);
  }

  Id putByTransferIdSync(TransferCollection object, {bool saveLinks = true}) {
    return putByIndexSync(r'transferId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByTransferId(List<TransferCollection> objects) {
    return putAllByIndex(r'transferId', objects);
  }

  List<Id> putAllByTransferIdSync(
    List<TransferCollection> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'transferId', objects, saveLinks: saveLinks);
  }
}

extension TransferCollectionQueryWhereSort
    on QueryBuilder<TransferCollection, TransferCollection, QWhere> {
  QueryBuilder<TransferCollection, TransferCollection, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TransferCollectionQueryWhere
    on QueryBuilder<TransferCollection, TransferCollection, QWhereClause> {
  QueryBuilder<TransferCollection, TransferCollection, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterWhereClause>
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterWhereClause>
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterWhereClause>
  transferIdEqualTo(String transferId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'transferId', value: [transferId]),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterWhereClause>
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

extension TransferCollectionQueryFilter
    on QueryBuilder<TransferCollection, TransferCollection, QFilterCondition> {
  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  expiresAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'expiresAt'),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  expiresAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'expiresAt'),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  expiresAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'expiresAt', value: value),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  expiresAtGreaterThan(DateTime? value, {bool include = false}) {
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  expiresAtLessThan(DateTime? value, {bool include = false}) {
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  expiresAtBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  fileHashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'fileHash'),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  fileHashIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'fileHash'),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  fileHashEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'fileHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  fileHashGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fileHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  fileHashLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fileHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  fileHashBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fileHash',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  fileHashStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'fileHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  fileHashEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'fileHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  fileHashContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'fileHash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  fileHashMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'fileHash',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  fileHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fileHash', value: ''),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  fileHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'fileHash', value: ''),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  fileNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'fileName'),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  fileNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'fileName'),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  fileNameEqualTo(String? value, {bool caseSensitive = true}) {
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  fileNameGreaterThan(
    String? value, {
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  fileNameLessThan(
    String? value, {
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  fileNameBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  fileNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fileName', value: ''),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  fileNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'fileName', value: ''),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  fileSizeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'fileSize'),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  fileSizeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'fileSize'),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  fileSizeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fileSize', value: value),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  fileSizeGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fileSize',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  fileSizeLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fileSize',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  fileSizeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fileSize',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  intentExpiryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'intentExpiry'),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  intentExpiryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'intentExpiry'),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  intentExpiryEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'intentExpiry', value: value),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  intentExpiryGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'intentExpiry',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  intentExpiryLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'intentExpiry',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  intentExpiryBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'intentExpiry',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  intentScoreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'intentScore'),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  intentScoreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'intentScore'),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  intentScoreEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'intentScore',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  intentScoreGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'intentScore',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  intentScoreLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'intentScore',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  intentScoreBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'intentScore',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  receiverIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'receiverId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  receiverIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'receiverId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  receiverIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'receiverId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  receiverIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'receiverId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  receiverIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'receiverId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  receiverIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'receiverId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  receiverIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'receiverId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  receiverIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'receiverId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  receiverIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'receiverId', value: ''),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  receiverIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'receiverId', value: ''),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  senderIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'senderId', value: ''),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  senderIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'senderId', value: ''),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  statusEqualTo(TransferStatus value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: value),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  statusGreaterThan(TransferStatus value, {bool include = false}) {
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  statusLessThan(TransferStatus value, {bool include = false}) {
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  statusBetween(
    TransferStatus lower,
    TransferStatus upper, {
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  storagePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'storagePath'),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  storagePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'storagePath'),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  storagePathEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'storagePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  storagePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'storagePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  storagePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'storagePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  storagePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'storagePath',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  storagePathStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'storagePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  storagePathEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'storagePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  storagePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'storagePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  storagePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'storagePath',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  storagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'storagePath', value: ''),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  storagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'storagePath', value: ''),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
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

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  transferIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'transferId', value: ''),
      );
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterFilterCondition>
  transferIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'transferId', value: ''),
      );
    });
  }
}

extension TransferCollectionQueryObject
    on QueryBuilder<TransferCollection, TransferCollection, QFilterCondition> {}

extension TransferCollectionQueryLinks
    on QueryBuilder<TransferCollection, TransferCollection, QFilterCondition> {}

extension TransferCollectionQuerySortBy
    on QueryBuilder<TransferCollection, TransferCollection, QSortBy> {
  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  sortByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.asc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  sortByExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.desc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  sortByFileHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileHash', Sort.asc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  sortByFileHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileHash', Sort.desc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  sortByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  sortByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  sortByFileSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSize', Sort.asc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  sortByFileSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSize', Sort.desc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  sortByIntentExpiry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intentExpiry', Sort.asc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  sortByIntentExpiryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intentExpiry', Sort.desc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  sortByIntentScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intentScore', Sort.asc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  sortByIntentScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intentScore', Sort.desc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  sortByReceiverId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiverId', Sort.asc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  sortByReceiverIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiverId', Sort.desc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  sortBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  sortBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  sortByStoragePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storagePath', Sort.asc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  sortByStoragePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storagePath', Sort.desc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  sortByTransferId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transferId', Sort.asc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  sortByTransferIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transferId', Sort.desc);
    });
  }
}

extension TransferCollectionQuerySortThenBy
    on QueryBuilder<TransferCollection, TransferCollection, QSortThenBy> {
  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  thenByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.asc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  thenByExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.desc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  thenByFileHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileHash', Sort.asc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  thenByFileHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileHash', Sort.desc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  thenByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  thenByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  thenByFileSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSize', Sort.asc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  thenByFileSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileSize', Sort.desc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  thenByIntentExpiry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intentExpiry', Sort.asc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  thenByIntentExpiryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intentExpiry', Sort.desc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  thenByIntentScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intentScore', Sort.asc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  thenByIntentScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'intentScore', Sort.desc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  thenByReceiverId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiverId', Sort.asc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  thenByReceiverIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiverId', Sort.desc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  thenBySenderId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.asc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  thenBySenderIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'senderId', Sort.desc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  thenByStoragePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storagePath', Sort.asc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  thenByStoragePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storagePath', Sort.desc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  thenByTransferId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transferId', Sort.asc);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QAfterSortBy>
  thenByTransferIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transferId', Sort.desc);
    });
  }
}

extension TransferCollectionQueryWhereDistinct
    on QueryBuilder<TransferCollection, TransferCollection, QDistinct> {
  QueryBuilder<TransferCollection, TransferCollection, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QDistinct>
  distinctByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expiresAt');
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QDistinct>
  distinctByFileHash({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileHash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QDistinct>
  distinctByFileName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QDistinct>
  distinctByFileSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileSize');
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QDistinct>
  distinctByIntentExpiry() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'intentExpiry');
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QDistinct>
  distinctByIntentScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'intentScore');
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QDistinct>
  distinctByReceiverId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'receiverId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QDistinct>
  distinctBySenderId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'senderId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QDistinct>
  distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QDistinct>
  distinctByStoragePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'storagePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransferCollection, TransferCollection, QDistinct>
  distinctByTransferId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'transferId', caseSensitive: caseSensitive);
    });
  }
}

extension TransferCollectionQueryProperty
    on QueryBuilder<TransferCollection, TransferCollection, QQueryProperty> {
  QueryBuilder<TransferCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TransferCollection, DateTime, QQueryOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<TransferCollection, DateTime?, QQueryOperations>
  expiresAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expiresAt');
    });
  }

  QueryBuilder<TransferCollection, String?, QQueryOperations>
  fileHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileHash');
    });
  }

  QueryBuilder<TransferCollection, String?, QQueryOperations>
  fileNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileName');
    });
  }

  QueryBuilder<TransferCollection, int?, QQueryOperations> fileSizeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileSize');
    });
  }

  QueryBuilder<TransferCollection, DateTime?, QQueryOperations>
  intentExpiryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'intentExpiry');
    });
  }

  QueryBuilder<TransferCollection, double?, QQueryOperations>
  intentScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'intentScore');
    });
  }

  QueryBuilder<TransferCollection, String, QQueryOperations>
  receiverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'receiverId');
    });
  }

  QueryBuilder<TransferCollection, String, QQueryOperations>
  senderIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'senderId');
    });
  }

  QueryBuilder<TransferCollection, TransferStatus, QQueryOperations>
  statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<TransferCollection, String?, QQueryOperations>
  storagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'storagePath');
    });
  }

  QueryBuilder<TransferCollection, String, QQueryOperations>
  transferIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transferId');
    });
  }
}
