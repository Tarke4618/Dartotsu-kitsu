// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TrackerMapping.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTrackerMappingCollection on Isar {
  IsarCollection<TrackerMapping> get trackerMappings => this.collection();
}

const TrackerMappingSchema = CollectionSchema(
  name: r'TrackerMapping',
  id: 8493712847291038456,
  properties: {
    r'key': PropertySchema(
      id: 0,
      name: r'key',
      type: IsarType.string,
    ),
    r'mediaType': PropertySchema(
      id: 1,
      name: r'mediaType',
      type: IsarType.string,
    ),
    r'sourceId': PropertySchema(
      id: 2,
      name: r'sourceId',
      type: IsarType.long,
    ),
    r'sourceTracker': PropertySchema(
      id: 3,
      name: r'sourceTracker',
      type: IsarType.string,
    ),
    r'targets': PropertySchema(
      id: 4,
      name: r'targets',
      type: IsarType.objectList,
      target: r'MappingTarget',
    )
  },
  estimateSize: _trackerMappingEstimateSize,
  serialize: _trackerMappingSerialize,
  deserialize: _trackerMappingDeserialize,
  deserializeProp: _trackerMappingDeserializeProp,
  idName: r'id',
  indexes: {
    r'key': IndexSchema(
      id: -4906094122524121629,
      name: r'key',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'key',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'MappingTarget': MappingTargetSchema},
  getId: _trackerMappingGetId,
  getLinks: _trackerMappingGetLinks,
  attach: _trackerMappingAttach,
  version: '3.3.0-dev.3',
);

int _trackerMappingEstimateSize(
  TrackerMapping object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.key.length * 3;
  bytesCount += 3 + object.mediaType.length * 3;
  bytesCount += 3 + object.sourceTracker.length * 3;
  bytesCount += 3 + object.targets.length * 3;
  {
    final offsets = allOffsets[MappingTarget]!;
    for (var i = 0; i < object.targets.length; i++) {
      final value = object.targets[i];
      bytesCount += MappingTargetSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  return bytesCount;
}

void _trackerMappingSerialize(
  TrackerMapping object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.key);
  writer.writeString(offsets[1], object.mediaType);
  writer.writeLong(offsets[2], object.sourceId);
  writer.writeString(offsets[3], object.sourceTracker);
  writer.writeObjectList<MappingTarget>(
    offsets[4],
    allOffsets,
    MappingTargetSchema.serialize,
    object.targets,
  );
}

TrackerMapping _trackerMappingDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TrackerMapping();
  object.id = id;
  object.key = reader.readString(offsets[0]);
  object.mediaType = reader.readString(offsets[1]);
  object.sourceId = reader.readLong(offsets[2]);
  object.sourceTracker = reader.readString(offsets[3]);
  object.targets = reader.readObjectList<MappingTarget>(
        offsets[4],
        MappingTargetSchema.deserialize,
        allOffsets,
        MappingTarget(),
      ) ??
      [];
  return object;
}

P _trackerMappingDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readObjectList<MappingTarget>(
            offset,
            MappingTargetSchema.deserialize,
            allOffsets,
            MappingTarget(),
          ) ??
          []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _trackerMappingGetId(TrackerMapping object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _trackerMappingGetLinks(TrackerMapping object) {
  return [];
}

void _trackerMappingAttach(
    IsarCollection<dynamic> col, Id id, TrackerMapping object) {
  object.id = id;
}

extension TrackerMappingByIndex on IsarCollection<TrackerMapping> {
  Future<TrackerMapping?> getByKey(String key) {
    return getByIndex(r'key', [key]);
  }

  TrackerMapping? getByKeySync(String key) {
    return getByIndexSync(r'key', [key]);
  }

  Future<bool> deleteByKey(String key) {
    return deleteByIndex(r'key', [key]);
  }

  bool deleteByKeySync(String key) {
    return deleteByIndexSync(r'key', [key]);
  }

  Future<List<TrackerMapping?>> getAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndex(r'key', values);
  }

  List<TrackerMapping?> getAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'key', values);
  }

  Future<int> deleteAllByKey(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'key', values);
  }

  int deleteAllByKeySync(List<String> keyValues) {
    final values = keyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'key', values);
  }

  Future<Id> putByKey(TrackerMapping object) {
    return putByIndex(r'key', object);
  }

  Id putByKeySync(TrackerMapping object, {bool saveLinks = true}) {
    return putByIndexSync(r'key', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByKey(List<TrackerMapping> objects) {
    return putAllByIndex(r'key', objects);
  }

  List<Id> putAllByKeySync(List<TrackerMapping> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'key', objects, saveLinks: saveLinks);
  }
}

extension TrackerMappingQueryWhereSort
    on QueryBuilder<TrackerMapping, TrackerMapping, QWhere> {
  QueryBuilder<TrackerMapping, TrackerMapping, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TrackerMappingQueryWhere
    on QueryBuilder<TrackerMapping, TrackerMapping, QWhereClause> {
  QueryBuilder<TrackerMapping, TrackerMapping, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TrackerMapping, TrackerMapping, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<TrackerMapping, TrackerMapping, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TrackerMapping, TrackerMapping, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TrackerMapping, TrackerMapping, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TrackerMapping, TrackerMapping, QAfterWhereClause> keyEqualTo(
      String key) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'key',
        value: [key],
      ));
    });
  }

  QueryBuilder<TrackerMapping, TrackerMapping, QAfterWhereClause> keyNotEqualTo(
      String key) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [],
              upper: [key],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [key],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [key],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'key',
              lower: [],
              upper: [key],
              includeUpper: false,
            ));
      }
    });
  }
}

extension TrackerMappingQueryFilter
    on QueryBuilder<TrackerMapping, TrackerMapping, QFilterCondition> {
  QueryBuilder<TrackerMapping, TrackerMapping, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TrackerMapping, TrackerMapping, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TrackerMapping, TrackerMapping, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TrackerMapping, TrackerMapping, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TrackerMapping, TrackerMapping, QAfterFilterCondition>
      keyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrackerMapping, TrackerMapping, QAfterFilterCondition>
      sourceIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceId',
        value: value,
      ));
    });
  }

  QueryBuilder<TrackerMapping, TrackerMapping, QAfterFilterCondition>
      sourceTrackerEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceTracker',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrackerMapping, TrackerMapping, QAfterFilterCondition>
      mediaTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mediaType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrackerMapping, TrackerMapping, QAfterFilterCondition>
      targetsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'targets',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<TrackerMapping, TrackerMapping, QAfterFilterCondition>
      targetsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'targets',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<TrackerMapping, TrackerMapping, QAfterFilterCondition>
      targetsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'targets',
        0,
        false,
        999999,
        true,
      );
    });
  }
}

extension TrackerMappingQueryObject
    on QueryBuilder<TrackerMapping, TrackerMapping, QFilterCondition> {
  QueryBuilder<TrackerMapping, TrackerMapping, QAfterFilterCondition>
      targetsElement(FilterQuery<MappingTarget> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'targets');
    });
  }
}

extension TrackerMappingQueryLinks
    on QueryBuilder<TrackerMapping, TrackerMapping, QFilterCondition> {}

extension TrackerMappingQuerySortBy
    on QueryBuilder<TrackerMapping, TrackerMapping, QSortBy> {
  QueryBuilder<TrackerMapping, TrackerMapping, QAfterSortBy> sortByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }

  QueryBuilder<TrackerMapping, TrackerMapping, QAfterSortBy> sortByKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.desc);
    });
  }

  QueryBuilder<TrackerMapping, TrackerMapping, QAfterSortBy>
      sortBySourceTracker() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceTracker', Sort.asc);
    });
  }

  QueryBuilder<TrackerMapping, TrackerMapping, QAfterSortBy> sortBySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.asc);
    });
  }
}

extension TrackerMappingQuerySortThenBy
    on QueryBuilder<TrackerMapping, TrackerMapping, QSortThenBy> {
  QueryBuilder<TrackerMapping, TrackerMapping, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TrackerMapping, TrackerMapping, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TrackerMapping, TrackerMapping, QAfterSortBy> thenByKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'key', Sort.asc);
    });
  }
}

extension TrackerMappingQueryWhereDistinct
    on QueryBuilder<TrackerMapping, TrackerMapping, QDistinct> {
  QueryBuilder<TrackerMapping, TrackerMapping, QDistinct> distinctByKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'key', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TrackerMapping, TrackerMapping, QDistinct>
      distinctBySourceTracker({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceTracker', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TrackerMapping, TrackerMapping, QDistinct> distinctBySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceId');
    });
  }

  QueryBuilder<TrackerMapping, TrackerMapping, QDistinct> distinctByMediaType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaType', caseSensitive: caseSensitive);
    });
  }
}

extension TrackerMappingQueryProperty
    on QueryBuilder<TrackerMapping, TrackerMapping, QQueryProperty> {
  QueryBuilder<TrackerMapping, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TrackerMapping, String, QQueryOperations> keyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'key');
    });
  }

  QueryBuilder<TrackerMapping, String, QQueryOperations>
      sourceTrackerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceTracker');
    });
  }

  QueryBuilder<TrackerMapping, int, QQueryOperations> sourceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceId');
    });
  }

  QueryBuilder<TrackerMapping, String, QQueryOperations> mediaTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaType');
    });
  }

  QueryBuilder<TrackerMapping, List<MappingTarget>, QQueryOperations>
      targetsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targets');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const MappingTargetSchema = Schema(
  name: r'MappingTarget',
  id: 7892134567890123456,
  properties: {
    r'offset': PropertySchema(
      id: 0,
      name: r'offset',
      type: IsarType.long,
    ),
    r'segment': PropertySchema(
      id: 1,
      name: r'segment',
      type: IsarType.string,
    ),
    r'targetId': PropertySchema(
      id: 2,
      name: r'targetId',
      type: IsarType.string,
    ),
    r'targetTitle': PropertySchema(
      id: 3,
      name: r'targetTitle',
      type: IsarType.string,
    ),
    r'targetTracker': PropertySchema(
      id: 4,
      name: r'targetTracker',
      type: IsarType.string,
    )
  },
  estimateSize: _mappingTargetEstimateSize,
  serialize: _mappingTargetSerialize,
  deserialize: _mappingTargetDeserialize,
  deserializeProp: _mappingTargetDeserializeProp,
);

int _mappingTargetEstimateSize(
  MappingTarget object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.segment;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.targetId.length * 3;
  {
    final value = object.targetTitle;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.targetTracker.length * 3;
  return bytesCount;
}

void _mappingTargetSerialize(
  MappingTarget object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.offset);
  writer.writeString(offsets[1], object.segment);
  writer.writeString(offsets[2], object.targetId);
  writer.writeString(offsets[3], object.targetTitle);
  writer.writeString(offsets[4], object.targetTracker);
}

MappingTarget _mappingTargetDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MappingTarget();
  object.offset = reader.readLong(offsets[0]);
  object.segment = reader.readStringOrNull(offsets[1]);
  object.targetId = reader.readString(offsets[2]);
  object.targetTitle = reader.readStringOrNull(offsets[3]);
  object.targetTracker = reader.readString(offsets[4]);
  return object;
}

P _mappingTargetDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension MappingTargetQueryFilter
    on QueryBuilder<MappingTarget, MappingTarget, QFilterCondition> {
  QueryBuilder<MappingTarget, MappingTarget, QAfterFilterCondition>
      offsetEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'offset',
        value: value,
      ));
    });
  }

  QueryBuilder<MappingTarget, MappingTarget, QAfterFilterCondition>
      targetIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MappingTarget, MappingTarget, QAfterFilterCondition>
      targetTrackerEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetTracker',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }
}
