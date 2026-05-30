// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_config.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBackupConfigCollection on Isar {
  IsarCollection<BackupConfig> get backupConfigs => this.collection();
}

const BackupConfigSchema = CollectionSchema(
  name: r'BackupConfig',
  id: -7359236994331025534,
  properties: {
    r'enabled': PropertySchema(id: 0, name: r'enabled', type: IsarType.bool),
    r'folderUri': PropertySchema(
      id: 1,
      name: r'folderUri',
      type: IsarType.string,
    ),
    r'frequency': PropertySchema(
      id: 2,
      name: r'frequency',
      type: IsarType.string,
    ),
    r'lastAttemptAt': PropertySchema(
      id: 3,
      name: r'lastAttemptAt',
      type: IsarType.dateTime,
    ),
    r'lastBackupAt': PropertySchema(
      id: 4,
      name: r'lastBackupAt',
      type: IsarType.dateTime,
    ),
    r'lastFailureReason': PropertySchema(
      id: 5,
      name: r'lastFailureReason',
      type: IsarType.string,
    ),
    r'retention': PropertySchema(
      id: 6,
      name: r'retention',
      type: IsarType.long,
    ),
  },

  estimateSize: _backupConfigEstimateSize,
  serialize: _backupConfigSerialize,
  deserialize: _backupConfigDeserialize,
  deserializeProp: _backupConfigDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _backupConfigGetId,
  getLinks: _backupConfigGetLinks,
  attach: _backupConfigAttach,
  version: '3.3.2',
);

int _backupConfigEstimateSize(
  BackupConfig object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.folderUri;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.frequency.length * 3;
  {
    final value = object.lastFailureReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _backupConfigSerialize(
  BackupConfig object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.enabled);
  writer.writeString(offsets[1], object.folderUri);
  writer.writeString(offsets[2], object.frequency);
  writer.writeDateTime(offsets[3], object.lastAttemptAt);
  writer.writeDateTime(offsets[4], object.lastBackupAt);
  writer.writeString(offsets[5], object.lastFailureReason);
  writer.writeLong(offsets[6], object.retention);
}

BackupConfig _backupConfigDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BackupConfig();
  object.enabled = reader.readBool(offsets[0]);
  object.folderUri = reader.readStringOrNull(offsets[1]);
  object.frequency = reader.readString(offsets[2]);
  object.id = id;
  object.lastAttemptAt = reader.readDateTimeOrNull(offsets[3]);
  object.lastBackupAt = reader.readDateTimeOrNull(offsets[4]);
  object.lastFailureReason = reader.readStringOrNull(offsets[5]);
  object.retention = reader.readLong(offsets[6]);
  return object;
}

P _backupConfigDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _backupConfigGetId(BackupConfig object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _backupConfigGetLinks(BackupConfig object) {
  return [];
}

void _backupConfigAttach(
  IsarCollection<dynamic> col,
  Id id,
  BackupConfig object,
) {
  object.id = id;
}

extension BackupConfigQueryWhereSort
    on QueryBuilder<BackupConfig, BackupConfig, QWhere> {
  QueryBuilder<BackupConfig, BackupConfig, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BackupConfigQueryWhere
    on QueryBuilder<BackupConfig, BackupConfig, QWhereClause> {
  QueryBuilder<BackupConfig, BackupConfig, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<BackupConfig, BackupConfig, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterWhereClause> idBetween(
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
}

extension BackupConfigQueryFilter
    on QueryBuilder<BackupConfig, BackupConfig, QFilterCondition> {
  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  enabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'enabled', value: value),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  folderUriIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'folderUri'),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  folderUriIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'folderUri'),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  folderUriEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'folderUri',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  folderUriGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'folderUri',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  folderUriLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'folderUri',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  folderUriBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'folderUri',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  folderUriStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'folderUri',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  folderUriEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'folderUri',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  folderUriContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'folderUri',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  folderUriMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'folderUri',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  folderUriIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'folderUri', value: ''),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  folderUriIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'folderUri', value: ''),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  frequencyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'frequency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  frequencyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'frequency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  frequencyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'frequency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  frequencyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'frequency',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  frequencyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'frequency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  frequencyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'frequency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  frequencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'frequency',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  frequencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'frequency',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  frequencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'frequency', value: ''),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  frequencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'frequency', value: ''),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
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

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition> idBetween(
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

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  lastAttemptAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastAttemptAt'),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  lastAttemptAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastAttemptAt'),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  lastAttemptAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastAttemptAt', value: value),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  lastAttemptAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastAttemptAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  lastAttemptAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastAttemptAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  lastAttemptAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastAttemptAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  lastBackupAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastBackupAt'),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  lastBackupAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastBackupAt'),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  lastBackupAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastBackupAt', value: value),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  lastBackupAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastBackupAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  lastBackupAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastBackupAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  lastBackupAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastBackupAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  lastFailureReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastFailureReason'),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  lastFailureReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastFailureReason'),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  lastFailureReasonEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lastFailureReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  lastFailureReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastFailureReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  lastFailureReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastFailureReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  lastFailureReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastFailureReason',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  lastFailureReasonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'lastFailureReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  lastFailureReasonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'lastFailureReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  lastFailureReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'lastFailureReason',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  lastFailureReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'lastFailureReason',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  lastFailureReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastFailureReason', value: ''),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  lastFailureReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'lastFailureReason', value: ''),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  retentionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'retention', value: value),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  retentionGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'retention',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  retentionLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'retention',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterFilterCondition>
  retentionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'retention',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension BackupConfigQueryObject
    on QueryBuilder<BackupConfig, BackupConfig, QFilterCondition> {}

extension BackupConfigQueryLinks
    on QueryBuilder<BackupConfig, BackupConfig, QFilterCondition> {}

extension BackupConfigQuerySortBy
    on QueryBuilder<BackupConfig, BackupConfig, QSortBy> {
  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy> sortByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy> sortByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy> sortByFolderUri() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'folderUri', Sort.asc);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy> sortByFolderUriDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'folderUri', Sort.desc);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy> sortByFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.asc);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy> sortByFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.desc);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy> sortByLastAttemptAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAttemptAt', Sort.asc);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy>
  sortByLastAttemptAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAttemptAt', Sort.desc);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy> sortByLastBackupAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupAt', Sort.asc);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy>
  sortByLastBackupAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupAt', Sort.desc);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy>
  sortByLastFailureReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFailureReason', Sort.asc);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy>
  sortByLastFailureReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFailureReason', Sort.desc);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy> sortByRetention() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retention', Sort.asc);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy> sortByRetentionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retention', Sort.desc);
    });
  }
}

extension BackupConfigQuerySortThenBy
    on QueryBuilder<BackupConfig, BackupConfig, QSortThenBy> {
  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy> thenByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy> thenByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy> thenByFolderUri() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'folderUri', Sort.asc);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy> thenByFolderUriDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'folderUri', Sort.desc);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy> thenByFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.asc);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy> thenByFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frequency', Sort.desc);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy> thenByLastAttemptAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAttemptAt', Sort.asc);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy>
  thenByLastAttemptAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastAttemptAt', Sort.desc);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy> thenByLastBackupAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupAt', Sort.asc);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy>
  thenByLastBackupAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastBackupAt', Sort.desc);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy>
  thenByLastFailureReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFailureReason', Sort.asc);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy>
  thenByLastFailureReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFailureReason', Sort.desc);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy> thenByRetention() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retention', Sort.asc);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QAfterSortBy> thenByRetentionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'retention', Sort.desc);
    });
  }
}

extension BackupConfigQueryWhereDistinct
    on QueryBuilder<BackupConfig, BackupConfig, QDistinct> {
  QueryBuilder<BackupConfig, BackupConfig, QDistinct> distinctByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enabled');
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QDistinct> distinctByFolderUri({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'folderUri', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QDistinct> distinctByFrequency({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'frequency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QDistinct>
  distinctByLastAttemptAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastAttemptAt');
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QDistinct> distinctByLastBackupAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastBackupAt');
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QDistinct>
  distinctByLastFailureReason({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'lastFailureReason',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<BackupConfig, BackupConfig, QDistinct> distinctByRetention() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'retention');
    });
  }
}

extension BackupConfigQueryProperty
    on QueryBuilder<BackupConfig, BackupConfig, QQueryProperty> {
  QueryBuilder<BackupConfig, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BackupConfig, bool, QQueryOperations> enabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enabled');
    });
  }

  QueryBuilder<BackupConfig, String?, QQueryOperations> folderUriProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'folderUri');
    });
  }

  QueryBuilder<BackupConfig, String, QQueryOperations> frequencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'frequency');
    });
  }

  QueryBuilder<BackupConfig, DateTime?, QQueryOperations>
  lastAttemptAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastAttemptAt');
    });
  }

  QueryBuilder<BackupConfig, DateTime?, QQueryOperations>
  lastBackupAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastBackupAt');
    });
  }

  QueryBuilder<BackupConfig, String?, QQueryOperations>
  lastFailureReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastFailureReason');
    });
  }

  QueryBuilder<BackupConfig, int, QQueryOperations> retentionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'retention');
    });
  }
}
