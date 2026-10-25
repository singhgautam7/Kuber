// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule.dart';

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const ScheduleSchema = Schema(
  name: r'Schedule',
  id: 6369058706800408146,
  properties: {
    r'anchorDay': PropertySchema(
      id: 0,
      name: r'anchorDay',
      type: IsarType.long,
    ),
    r'anchorMonth': PropertySchema(
      id: 1,
      name: r'anchorMonth',
      type: IsarType.long,
    ),
    r'autoRecord': PropertySchema(
      id: 2,
      name: r'autoRecord',
      type: IsarType.bool,
    ),
    r'compat': PropertySchema(id: 3, name: r'compat', type: IsarType.string),
    r'endCount': PropertySchema(id: 4, name: r'endCount', type: IsarType.long),
    r'endDate': PropertySchema(
      id: 5,
      name: r'endDate',
      type: IsarType.dateTime,
    ),
    r'endType': PropertySchema(
      id: 6,
      name: r'endType',
      type: IsarType.string,
      enumMap: _ScheduleendTypeEnumValueMap,
    ),
    r'intervalCount': PropertySchema(
      id: 7,
      name: r'intervalCount',
      type: IsarType.long,
    ),
    r'intervalUnit': PropertySchema(
      id: 8,
      name: r'intervalUnit',
      type: IsarType.string,
      enumMap: _ScheduleintervalUnitEnumValueMap,
    ),
    r'legacyNextDue': PropertySchema(
      id: 9,
      name: r'legacyNextDue',
      type: IsarType.dateTime,
    ),
    r'migrationNote': PropertySchema(
      id: 10,
      name: r'migrationNote',
      type: IsarType.string,
    ),
    r'paused': PropertySchema(id: 11, name: r'paused', type: IsarType.bool),
    r'pausedOn': PropertySchema(
      id: 12,
      name: r'pausedOn',
      type: IsarType.dateTime,
    ),
    r'postedCount': PropertySchema(
      id: 13,
      name: r'postedCount',
      type: IsarType.long,
    ),
    r'processedThrough': PropertySchema(
      id: 14,
      name: r'processedThrough',
      type: IsarType.long,
    ),
    r'skippedDates': PropertySchema(
      id: 15,
      name: r'skippedDates',
      type: IsarType.longList,
    ),
    r'startDate': PropertySchema(
      id: 16,
      name: r'startDate',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _scheduleEstimateSize,
  serialize: _scheduleSerialize,
  deserialize: _scheduleDeserialize,
  deserializeProp: _scheduleDeserializeProp,
);

int _scheduleEstimateSize(
  Schedule object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.compat;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.endType.name.length * 3;
  bytesCount += 3 + object.intervalUnit.name.length * 3;
  {
    final value = object.migrationNote;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.skippedDates.length * 8;
  return bytesCount;
}

void _scheduleSerialize(
  Schedule object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.anchorDay);
  writer.writeLong(offsets[1], object.anchorMonth);
  writer.writeBool(offsets[2], object.autoRecord);
  writer.writeString(offsets[3], object.compat);
  writer.writeLong(offsets[4], object.endCount);
  writer.writeDateTime(offsets[5], object.endDate);
  writer.writeString(offsets[6], object.endType.name);
  writer.writeLong(offsets[7], object.intervalCount);
  writer.writeString(offsets[8], object.intervalUnit.name);
  writer.writeDateTime(offsets[9], object.legacyNextDue);
  writer.writeString(offsets[10], object.migrationNote);
  writer.writeBool(offsets[11], object.paused);
  writer.writeDateTime(offsets[12], object.pausedOn);
  writer.writeLong(offsets[13], object.postedCount);
  writer.writeLong(offsets[14], object.processedThrough);
  writer.writeLongList(offsets[15], object.skippedDates);
  writer.writeDateTime(offsets[16], object.startDate);
}

Schedule _scheduleDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Schedule();
  object.anchorDay = reader.readLongOrNull(offsets[0]);
  object.anchorMonth = reader.readLongOrNull(offsets[1]);
  object.autoRecord = reader.readBool(offsets[2]);
  object.compat = reader.readStringOrNull(offsets[3]);
  object.endCount = reader.readLongOrNull(offsets[4]);
  object.endDate = reader.readDateTimeOrNull(offsets[5]);
  object.endType =
      _ScheduleendTypeValueEnumMap[reader.readStringOrNull(offsets[6])] ??
      ScheduleEnd.never;
  object.intervalCount = reader.readLong(offsets[7]);
  object.intervalUnit =
      _ScheduleintervalUnitValueEnumMap[reader.readStringOrNull(offsets[8])] ??
      ScheduleUnit.day;
  object.legacyNextDue = reader.readDateTimeOrNull(offsets[9]);
  object.migrationNote = reader.readStringOrNull(offsets[10]);
  object.paused = reader.readBool(offsets[11]);
  object.pausedOn = reader.readDateTimeOrNull(offsets[12]);
  object.postedCount = reader.readLong(offsets[13]);
  object.processedThrough = reader.readLong(offsets[14]);
  object.skippedDates = reader.readLongList(offsets[15]) ?? [];
  object.startDate = reader.readDateTimeOrNull(offsets[16]);
  return object;
}

P _scheduleDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (_ScheduleendTypeValueEnumMap[reader.readStringOrNull(offset)] ??
              ScheduleEnd.never)
          as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (_ScheduleintervalUnitValueEnumMap[reader.readStringOrNull(
                offset,
              )] ??
              ScheduleUnit.day)
          as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    case 14:
      return (reader.readLong(offset)) as P;
    case 15:
      return (reader.readLongList(offset) ?? []) as P;
    case 16:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ScheduleendTypeEnumValueMap = {
  r'never': r'never',
  r'onDate': r'onDate',
  r'afterCount': r'afterCount',
};
const _ScheduleendTypeValueEnumMap = {
  r'never': ScheduleEnd.never,
  r'onDate': ScheduleEnd.onDate,
  r'afterCount': ScheduleEnd.afterCount,
};
const _ScheduleintervalUnitEnumValueMap = {
  r'day': r'day',
  r'week': r'week',
  r'month': r'month',
  r'year': r'year',
};
const _ScheduleintervalUnitValueEnumMap = {
  r'day': ScheduleUnit.day,
  r'week': ScheduleUnit.week,
  r'month': ScheduleUnit.month,
  r'year': ScheduleUnit.year,
};

extension ScheduleQueryFilter
    on QueryBuilder<Schedule, Schedule, QFilterCondition> {
  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> anchorDayIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'anchorDay'),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> anchorDayIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'anchorDay'),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> anchorDayEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'anchorDay', value: value),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> anchorDayGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'anchorDay',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> anchorDayLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'anchorDay',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> anchorDayBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'anchorDay',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> anchorMonthIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'anchorMonth'),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  anchorMonthIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'anchorMonth'),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> anchorMonthEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'anchorMonth', value: value),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  anchorMonthGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'anchorMonth',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> anchorMonthLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'anchorMonth',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> anchorMonthBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'anchorMonth',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> autoRecordEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'autoRecord', value: value),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> compatIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'compat'),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> compatIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'compat'),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> compatEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'compat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> compatGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'compat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> compatLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'compat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> compatBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'compat',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> compatStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'compat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> compatEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'compat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> compatContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'compat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> compatMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'compat',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> compatIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'compat', value: ''),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> compatIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'compat', value: ''),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> endCountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'endCount'),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> endCountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'endCount'),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> endCountEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'endCount', value: value),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> endCountGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'endCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> endCountLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'endCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> endCountBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'endCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> endDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'endDate'),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> endDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'endDate'),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> endDateEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'endDate', value: value),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> endDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'endDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> endDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'endDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> endDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'endDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> endTypeEqualTo(
    ScheduleEnd value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'endType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> endTypeGreaterThan(
    ScheduleEnd value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'endType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> endTypeLessThan(
    ScheduleEnd value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'endType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> endTypeBetween(
    ScheduleEnd lower,
    ScheduleEnd upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'endType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> endTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'endType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> endTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'endType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> endTypeContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'endType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> endTypeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'endType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> endTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'endType', value: ''),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> endTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'endType', value: ''),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> intervalCountEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'intervalCount', value: value),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  intervalCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'intervalCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> intervalCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'intervalCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> intervalCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'intervalCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> intervalUnitEqualTo(
    ScheduleUnit value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'intervalUnit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  intervalUnitGreaterThan(
    ScheduleUnit value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'intervalUnit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> intervalUnitLessThan(
    ScheduleUnit value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'intervalUnit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> intervalUnitBetween(
    ScheduleUnit lower,
    ScheduleUnit upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'intervalUnit',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  intervalUnitStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'intervalUnit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> intervalUnitEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'intervalUnit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> intervalUnitContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'intervalUnit',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> intervalUnitMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'intervalUnit',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  intervalUnitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'intervalUnit', value: ''),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  intervalUnitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'intervalUnit', value: ''),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  legacyNextDueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'legacyNextDue'),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  legacyNextDueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'legacyNextDue'),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> legacyNextDueEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'legacyNextDue', value: value),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  legacyNextDueGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'legacyNextDue',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> legacyNextDueLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'legacyNextDue',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> legacyNextDueBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'legacyNextDue',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  migrationNoteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'migrationNote'),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  migrationNoteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'migrationNote'),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> migrationNoteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'migrationNote',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  migrationNoteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'migrationNote',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> migrationNoteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'migrationNote',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> migrationNoteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'migrationNote',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  migrationNoteStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'migrationNote',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> migrationNoteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'migrationNote',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> migrationNoteContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'migrationNote',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> migrationNoteMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'migrationNote',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  migrationNoteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'migrationNote', value: ''),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  migrationNoteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'migrationNote', value: ''),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> pausedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'paused', value: value),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> pausedOnIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'pausedOn'),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> pausedOnIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'pausedOn'),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> pausedOnEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'pausedOn', value: value),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> pausedOnGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'pausedOn',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> pausedOnLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'pausedOn',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> pausedOnBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'pausedOn',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> postedCountEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'postedCount', value: value),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  postedCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'postedCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> postedCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'postedCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> postedCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'postedCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  processedThroughEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'processedThrough', value: value),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  processedThroughGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'processedThrough',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  processedThroughLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'processedThrough',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  processedThroughBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'processedThrough',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  skippedDatesElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'skippedDates', value: value),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  skippedDatesElementGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'skippedDates',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  skippedDatesElementLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'skippedDates',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  skippedDatesElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'skippedDates',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  skippedDatesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'skippedDates', length, true, length, true);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  skippedDatesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'skippedDates', 0, true, 0, true);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  skippedDatesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'skippedDates', 0, false, 999999, true);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  skippedDatesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'skippedDates', 0, true, length, include);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  skippedDatesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'skippedDates', length, include, 999999, true);
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition>
  skippedDatesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'skippedDates',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> startDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'startDate'),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> startDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'startDate'),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> startDateEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startDate', value: value),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> startDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> startDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Schedule, Schedule, QAfterFilterCondition> startDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension ScheduleQueryObject
    on QueryBuilder<Schedule, Schedule, QFilterCondition> {}
