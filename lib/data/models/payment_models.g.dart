// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPaymentAccountCollection on Isar {
  IsarCollection<PaymentAccount> get paymentAccounts => this.collection();
}

const PaymentAccountSchema = CollectionSchema(
  name: r'PaymentAccount',
  id: -5220307038641496286,
  properties: {
    r'accountName': PropertySchema(
      id: 0,
      name: r'accountName',
      type: IsarType.string,
    ),
    r'accountNumber': PropertySchema(
      id: 1,
      name: r'accountNumber',
      type: IsarType.string,
    ),
    r'accountType': PropertySchema(
      id: 2,
      name: r'accountType',
      type: IsarType.string,
      enumMap: _PaymentAccountaccountTypeEnumValueMap,
    ),
    r'bankName': PropertySchema(
      id: 3,
      name: r'bankName',
      type: IsarType.string,
    ),
    r'companyId': PropertySchema(
      id: 4,
      name: r'companyId',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 5,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'icon': PropertySchema(
      id: 6,
      name: r'icon',
      type: IsarType.string,
    ),
    r'ifscCode': PropertySchema(
      id: 7,
      name: r'ifscCode',
      type: IsarType.string,
    ),
    r'isActive': PropertySchema(
      id: 8,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'isDefault': PropertySchema(
      id: 9,
      name: r'isDefault',
      type: IsarType.bool,
    ),
    r'updatedAt': PropertySchema(
      id: 10,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _paymentAccountEstimateSize,
  serialize: _paymentAccountSerialize,
  deserialize: _paymentAccountDeserialize,
  deserializeProp: _paymentAccountDeserializeProp,
  idName: r'id',
  indexes: {
    r'companyId': IndexSchema(
      id: 482756417767355356,
      name: r'companyId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'companyId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'isActive': IndexSchema(
      id: 8092228061260947457,
      name: r'isActive',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isActive',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _paymentAccountGetId,
  getLinks: _paymentAccountGetLinks,
  attach: _paymentAccountAttach,
  version: '3.1.0+1',
);

int _paymentAccountEstimateSize(
  PaymentAccount object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.accountName.length * 3;
  {
    final value = object.accountNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.accountType.name.length * 3;
  {
    final value = object.bankName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.icon;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.ifscCode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _paymentAccountSerialize(
  PaymentAccount object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.accountName);
  writer.writeString(offsets[1], object.accountNumber);
  writer.writeString(offsets[2], object.accountType.name);
  writer.writeString(offsets[3], object.bankName);
  writer.writeLong(offsets[4], object.companyId);
  writer.writeDateTime(offsets[5], object.createdAt);
  writer.writeString(offsets[6], object.icon);
  writer.writeString(offsets[7], object.ifscCode);
  writer.writeBool(offsets[8], object.isActive);
  writer.writeBool(offsets[9], object.isDefault);
  writer.writeDateTime(offsets[10], object.updatedAt);
}

PaymentAccount _paymentAccountDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PaymentAccount();
  object.accountName = reader.readString(offsets[0]);
  object.accountNumber = reader.readStringOrNull(offsets[1]);
  object.accountType = _PaymentAccountaccountTypeValueEnumMap[
          reader.readStringOrNull(offsets[2])] ??
      PaymentAccountType.cash;
  object.bankName = reader.readStringOrNull(offsets[3]);
  object.companyId = reader.readLong(offsets[4]);
  object.createdAt = reader.readDateTime(offsets[5]);
  object.icon = reader.readStringOrNull(offsets[6]);
  object.id = id;
  object.ifscCode = reader.readStringOrNull(offsets[7]);
  object.isActive = reader.readBool(offsets[8]);
  object.isDefault = reader.readBool(offsets[9]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[10]);
  return object;
}

P _paymentAccountDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (_PaymentAccountaccountTypeValueEnumMap[
              reader.readStringOrNull(offset)] ??
          PaymentAccountType.cash) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PaymentAccountaccountTypeEnumValueMap = {
  r'cash': r'cash',
  r'cheque': r'cheque',
  r'bank': r'bank',
};
const _PaymentAccountaccountTypeValueEnumMap = {
  r'cash': PaymentAccountType.cash,
  r'cheque': PaymentAccountType.cheque,
  r'bank': PaymentAccountType.bank,
};

Id _paymentAccountGetId(PaymentAccount object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _paymentAccountGetLinks(PaymentAccount object) {
  return [];
}

void _paymentAccountAttach(
    IsarCollection<dynamic> col, Id id, PaymentAccount object) {
  object.id = id;
}

extension PaymentAccountQueryWhereSort
    on QueryBuilder<PaymentAccount, PaymentAccount, QWhere> {
  QueryBuilder<PaymentAccount, PaymentAccount, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterWhere> anyCompanyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'companyId'),
      );
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterWhere> anyIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isActive'),
      );
    });
  }
}

extension PaymentAccountQueryWhere
    on QueryBuilder<PaymentAccount, PaymentAccount, QWhereClause> {
  QueryBuilder<PaymentAccount, PaymentAccount, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterWhereClause> idBetween(
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

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterWhereClause>
      companyIdEqualTo(int companyId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'companyId',
        value: [companyId],
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterWhereClause>
      companyIdNotEqualTo(int companyId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'companyId',
              lower: [],
              upper: [companyId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'companyId',
              lower: [companyId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'companyId',
              lower: [companyId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'companyId',
              lower: [],
              upper: [companyId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterWhereClause>
      companyIdGreaterThan(
    int companyId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'companyId',
        lower: [companyId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterWhereClause>
      companyIdLessThan(
    int companyId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'companyId',
        lower: [],
        upper: [companyId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterWhereClause>
      companyIdBetween(
    int lowerCompanyId,
    int upperCompanyId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'companyId',
        lower: [lowerCompanyId],
        includeLower: includeLower,
        upper: [upperCompanyId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterWhereClause>
      isActiveEqualTo(bool isActive) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isActive',
        value: [isActive],
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterWhereClause>
      isActiveNotEqualTo(bool isActive) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isActive',
              lower: [],
              upper: [isActive],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isActive',
              lower: [isActive],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isActive',
              lower: [isActive],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isActive',
              lower: [],
              upper: [isActive],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PaymentAccountQueryFilter
    on QueryBuilder<PaymentAccount, PaymentAccount, QFilterCondition> {
  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accountName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'accountName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'accountName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'accountName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'accountName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'accountName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'accountName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'accountName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accountName',
        value: '',
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'accountName',
        value: '',
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'accountNumber',
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'accountNumber',
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accountNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'accountNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'accountNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'accountNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'accountNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'accountNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'accountNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'accountNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accountNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'accountNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountTypeEqualTo(
    PaymentAccountType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accountType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountTypeGreaterThan(
    PaymentAccountType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'accountType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountTypeLessThan(
    PaymentAccountType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'accountType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountTypeBetween(
    PaymentAccountType lower,
    PaymentAccountType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'accountType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'accountType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'accountType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'accountType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'accountType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accountType',
        value: '',
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      accountTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'accountType',
        value: '',
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      bankNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bankName',
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      bankNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bankName',
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      bankNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bankName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      bankNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bankName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      bankNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bankName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      bankNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bankName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      bankNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bankName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      bankNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bankName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      bankNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bankName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      bankNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bankName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      bankNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bankName',
        value: '',
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      bankNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bankName',
        value: '',
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      companyIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'companyId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      companyIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'companyId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      companyIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'companyId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      companyIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'companyId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      iconIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'icon',
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      iconIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'icon',
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      iconEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      iconGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      iconLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      iconBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'icon',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      iconStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      iconEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      iconContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'icon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      iconMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'icon',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      iconIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'icon',
        value: '',
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      iconIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'icon',
        value: '',
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
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

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
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

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      ifscCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ifscCode',
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      ifscCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ifscCode',
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      ifscCodeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ifscCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      ifscCodeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ifscCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      ifscCodeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ifscCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      ifscCodeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ifscCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      ifscCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ifscCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      ifscCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ifscCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      ifscCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ifscCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      ifscCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ifscCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      ifscCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ifscCode',
        value: '',
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      ifscCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ifscCode',
        value: '',
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      isActiveEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      isDefaultEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isDefault',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterFilterCondition>
      updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PaymentAccountQueryObject
    on QueryBuilder<PaymentAccount, PaymentAccount, QFilterCondition> {}

extension PaymentAccountQueryLinks
    on QueryBuilder<PaymentAccount, PaymentAccount, QFilterCondition> {}

extension PaymentAccountQuerySortBy
    on QueryBuilder<PaymentAccount, PaymentAccount, QSortBy> {
  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy>
      sortByAccountName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountName', Sort.asc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy>
      sortByAccountNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountName', Sort.desc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy>
      sortByAccountNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountNumber', Sort.asc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy>
      sortByAccountNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountNumber', Sort.desc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy>
      sortByAccountType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountType', Sort.asc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy>
      sortByAccountTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountType', Sort.desc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy> sortByBankName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bankName', Sort.asc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy>
      sortByBankNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bankName', Sort.desc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy> sortByCompanyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'companyId', Sort.asc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy>
      sortByCompanyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'companyId', Sort.desc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy> sortByIcon() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icon', Sort.asc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy> sortByIconDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icon', Sort.desc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy> sortByIfscCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ifscCode', Sort.asc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy>
      sortByIfscCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ifscCode', Sort.desc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy>
      sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy> sortByIsDefault() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDefault', Sort.asc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy>
      sortByIsDefaultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDefault', Sort.desc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PaymentAccountQuerySortThenBy
    on QueryBuilder<PaymentAccount, PaymentAccount, QSortThenBy> {
  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy>
      thenByAccountName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountName', Sort.asc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy>
      thenByAccountNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountName', Sort.desc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy>
      thenByAccountNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountNumber', Sort.asc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy>
      thenByAccountNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountNumber', Sort.desc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy>
      thenByAccountType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountType', Sort.asc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy>
      thenByAccountTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accountType', Sort.desc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy> thenByBankName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bankName', Sort.asc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy>
      thenByBankNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bankName', Sort.desc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy> thenByCompanyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'companyId', Sort.asc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy>
      thenByCompanyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'companyId', Sort.desc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy> thenByIcon() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icon', Sort.asc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy> thenByIconDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'icon', Sort.desc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy> thenByIfscCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ifscCode', Sort.asc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy>
      thenByIfscCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ifscCode', Sort.desc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy>
      thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy> thenByIsDefault() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDefault', Sort.asc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy>
      thenByIsDefaultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isDefault', Sort.desc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PaymentAccountQueryWhereDistinct
    on QueryBuilder<PaymentAccount, PaymentAccount, QDistinct> {
  QueryBuilder<PaymentAccount, PaymentAccount, QDistinct> distinctByAccountName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accountName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QDistinct>
      distinctByAccountNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accountNumber',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QDistinct> distinctByAccountType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accountType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QDistinct> distinctByBankName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bankName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QDistinct>
      distinctByCompanyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'companyId');
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QDistinct> distinctByIcon(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'icon', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QDistinct> distinctByIfscCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ifscCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QDistinct>
      distinctByIsDefault() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isDefault');
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccount, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension PaymentAccountQueryProperty
    on QueryBuilder<PaymentAccount, PaymentAccount, QQueryProperty> {
  QueryBuilder<PaymentAccount, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PaymentAccount, String, QQueryOperations> accountNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accountName');
    });
  }

  QueryBuilder<PaymentAccount, String?, QQueryOperations>
      accountNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accountNumber');
    });
  }

  QueryBuilder<PaymentAccount, PaymentAccountType, QQueryOperations>
      accountTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accountType');
    });
  }

  QueryBuilder<PaymentAccount, String?, QQueryOperations> bankNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bankName');
    });
  }

  QueryBuilder<PaymentAccount, int, QQueryOperations> companyIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'companyId');
    });
  }

  QueryBuilder<PaymentAccount, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PaymentAccount, String?, QQueryOperations> iconProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'icon');
    });
  }

  QueryBuilder<PaymentAccount, String?, QQueryOperations> ifscCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ifscCode');
    });
  }

  QueryBuilder<PaymentAccount, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<PaymentAccount, bool, QQueryOperations> isDefaultProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isDefault');
    });
  }

  QueryBuilder<PaymentAccount, DateTime?, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPaymentInCollection on Isar {
  IsarCollection<PaymentIn> get paymentIns => this.collection();
}

const PaymentInSchema = CollectionSchema(
  name: r'PaymentIn',
  id: 2596864719055355786,
  properties: {
    r'attachmentPath': PropertySchema(
      id: 0,
      name: r'attachmentPath',
      type: IsarType.string,
    ),
    r'companyId': PropertySchema(
      id: 1,
      name: r'companyId',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'createdByUserId': PropertySchema(
      id: 3,
      name: r'createdByUserId',
      type: IsarType.long,
    ),
    r'description': PropertySchema(
      id: 4,
      name: r'description',
      type: IsarType.string,
    ),
    r'partyId': PropertySchema(
      id: 5,
      name: r'partyId',
      type: IsarType.long,
    ),
    r'receiptDate': PropertySchema(
      id: 6,
      name: r'receiptDate',
      type: IsarType.dateTime,
    ),
    r'receiptNo': PropertySchema(
      id: 7,
      name: r'receiptNo',
      type: IsarType.string,
    ),
    r'totalAmount': PropertySchema(
      id: 8,
      name: r'totalAmount',
      type: IsarType.double,
    ),
    r'updatedAt': PropertySchema(
      id: 9,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _paymentInEstimateSize,
  serialize: _paymentInSerialize,
  deserialize: _paymentInDeserialize,
  deserializeProp: _paymentInDeserializeProp,
  idName: r'id',
  indexes: {
    r'companyId': IndexSchema(
      id: 482756417767355356,
      name: r'companyId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'companyId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'partyId': IndexSchema(
      id: 5656384584959416297,
      name: r'partyId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'partyId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _paymentInGetId,
  getLinks: _paymentInGetLinks,
  attach: _paymentInAttach,
  version: '3.1.0+1',
);

int _paymentInEstimateSize(
  PaymentIn object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.attachmentPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.receiptNo.length * 3;
  return bytesCount;
}

void _paymentInSerialize(
  PaymentIn object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.attachmentPath);
  writer.writeLong(offsets[1], object.companyId);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeLong(offsets[3], object.createdByUserId);
  writer.writeString(offsets[4], object.description);
  writer.writeLong(offsets[5], object.partyId);
  writer.writeDateTime(offsets[6], object.receiptDate);
  writer.writeString(offsets[7], object.receiptNo);
  writer.writeDouble(offsets[8], object.totalAmount);
  writer.writeDateTime(offsets[9], object.updatedAt);
}

PaymentIn _paymentInDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PaymentIn();
  object.attachmentPath = reader.readStringOrNull(offsets[0]);
  object.companyId = reader.readLong(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.createdByUserId = reader.readLongOrNull(offsets[3]);
  object.description = reader.readStringOrNull(offsets[4]);
  object.id = id;
  object.partyId = reader.readLong(offsets[5]);
  object.receiptDate = reader.readDateTime(offsets[6]);
  object.receiptNo = reader.readString(offsets[7]);
  object.totalAmount = reader.readDouble(offsets[8]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[9]);
  return object;
}

P _paymentInDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _paymentInGetId(PaymentIn object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _paymentInGetLinks(PaymentIn object) {
  return [];
}

void _paymentInAttach(IsarCollection<dynamic> col, Id id, PaymentIn object) {
  object.id = id;
}

extension PaymentInQueryWhereSort
    on QueryBuilder<PaymentIn, PaymentIn, QWhere> {
  QueryBuilder<PaymentIn, PaymentIn, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterWhere> anyCompanyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'companyId'),
      );
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterWhere> anyPartyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'partyId'),
      );
    });
  }
}

extension PaymentInQueryWhere
    on QueryBuilder<PaymentIn, PaymentIn, QWhereClause> {
  QueryBuilder<PaymentIn, PaymentIn, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<PaymentIn, PaymentIn, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterWhereClause> idBetween(
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

  QueryBuilder<PaymentIn, PaymentIn, QAfterWhereClause> companyIdEqualTo(
      int companyId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'companyId',
        value: [companyId],
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterWhereClause> companyIdNotEqualTo(
      int companyId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'companyId',
              lower: [],
              upper: [companyId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'companyId',
              lower: [companyId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'companyId',
              lower: [companyId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'companyId',
              lower: [],
              upper: [companyId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterWhereClause> companyIdGreaterThan(
    int companyId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'companyId',
        lower: [companyId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterWhereClause> companyIdLessThan(
    int companyId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'companyId',
        lower: [],
        upper: [companyId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterWhereClause> companyIdBetween(
    int lowerCompanyId,
    int upperCompanyId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'companyId',
        lower: [lowerCompanyId],
        includeLower: includeLower,
        upper: [upperCompanyId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterWhereClause> partyIdEqualTo(
      int partyId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'partyId',
        value: [partyId],
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterWhereClause> partyIdNotEqualTo(
      int partyId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'partyId',
              lower: [],
              upper: [partyId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'partyId',
              lower: [partyId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'partyId',
              lower: [partyId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'partyId',
              lower: [],
              upper: [partyId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterWhereClause> partyIdGreaterThan(
    int partyId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'partyId',
        lower: [partyId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterWhereClause> partyIdLessThan(
    int partyId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'partyId',
        lower: [],
        upper: [partyId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterWhereClause> partyIdBetween(
    int lowerPartyId,
    int upperPartyId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'partyId',
        lower: [lowerPartyId],
        includeLower: includeLower,
        upper: [upperPartyId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PaymentInQueryFilter
    on QueryBuilder<PaymentIn, PaymentIn, QFilterCondition> {
  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      attachmentPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'attachmentPath',
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      attachmentPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'attachmentPath',
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      attachmentPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'attachmentPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      attachmentPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'attachmentPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      attachmentPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'attachmentPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      attachmentPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'attachmentPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      attachmentPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'attachmentPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      attachmentPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'attachmentPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      attachmentPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'attachmentPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      attachmentPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'attachmentPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      attachmentPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'attachmentPath',
        value: '',
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      attachmentPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'attachmentPath',
        value: '',
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> companyIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'companyId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      companyIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'companyId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> companyIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'companyId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> companyIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'companyId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      createdByUserIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdByUserId',
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      createdByUserIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdByUserId',
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      createdByUserIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdByUserId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      createdByUserIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdByUserId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      createdByUserIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdByUserId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      createdByUserIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdByUserId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> descriptionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> descriptionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> partyIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'partyId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> partyIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'partyId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> partyIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'partyId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> partyIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'partyId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> receiptDateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receiptDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      receiptDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'receiptDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> receiptDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'receiptDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> receiptDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'receiptDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> receiptNoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receiptNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      receiptNoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'receiptNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> receiptNoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'receiptNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> receiptNoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'receiptNo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> receiptNoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'receiptNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> receiptNoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'receiptNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> receiptNoContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'receiptNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> receiptNoMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'receiptNo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> receiptNoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'receiptNo',
        value: '',
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      receiptNoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'receiptNo',
        value: '',
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> totalAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      totalAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> totalAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> totalAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> updatedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> updatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterFilterCondition> updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PaymentInQueryObject
    on QueryBuilder<PaymentIn, PaymentIn, QFilterCondition> {}

extension PaymentInQueryLinks
    on QueryBuilder<PaymentIn, PaymentIn, QFilterCondition> {}

extension PaymentInQuerySortBy on QueryBuilder<PaymentIn, PaymentIn, QSortBy> {
  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> sortByAttachmentPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachmentPath', Sort.asc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> sortByAttachmentPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachmentPath', Sort.desc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> sortByCompanyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'companyId', Sort.asc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> sortByCompanyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'companyId', Sort.desc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> sortByCreatedByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByUserId', Sort.asc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> sortByCreatedByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByUserId', Sort.desc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> sortByPartyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partyId', Sort.asc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> sortByPartyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partyId', Sort.desc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> sortByReceiptDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptDate', Sort.asc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> sortByReceiptDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptDate', Sort.desc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> sortByReceiptNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptNo', Sort.asc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> sortByReceiptNoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptNo', Sort.desc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> sortByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.asc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> sortByTotalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.desc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PaymentInQuerySortThenBy
    on QueryBuilder<PaymentIn, PaymentIn, QSortThenBy> {
  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> thenByAttachmentPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachmentPath', Sort.asc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> thenByAttachmentPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachmentPath', Sort.desc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> thenByCompanyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'companyId', Sort.asc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> thenByCompanyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'companyId', Sort.desc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> thenByCreatedByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByUserId', Sort.asc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> thenByCreatedByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByUserId', Sort.desc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> thenByPartyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partyId', Sort.asc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> thenByPartyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partyId', Sort.desc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> thenByReceiptDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptDate', Sort.asc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> thenByReceiptDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptDate', Sort.desc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> thenByReceiptNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptNo', Sort.asc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> thenByReceiptNoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'receiptNo', Sort.desc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> thenByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.asc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> thenByTotalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.desc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PaymentInQueryWhereDistinct
    on QueryBuilder<PaymentIn, PaymentIn, QDistinct> {
  QueryBuilder<PaymentIn, PaymentIn, QDistinct> distinctByAttachmentPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'attachmentPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QDistinct> distinctByCompanyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'companyId');
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QDistinct> distinctByCreatedByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdByUserId');
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QDistinct> distinctByPartyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'partyId');
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QDistinct> distinctByReceiptDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'receiptDate');
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QDistinct> distinctByReceiptNo(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'receiptNo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QDistinct> distinctByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalAmount');
    });
  }

  QueryBuilder<PaymentIn, PaymentIn, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension PaymentInQueryProperty
    on QueryBuilder<PaymentIn, PaymentIn, QQueryProperty> {
  QueryBuilder<PaymentIn, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PaymentIn, String?, QQueryOperations> attachmentPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attachmentPath');
    });
  }

  QueryBuilder<PaymentIn, int, QQueryOperations> companyIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'companyId');
    });
  }

  QueryBuilder<PaymentIn, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PaymentIn, int?, QQueryOperations> createdByUserIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdByUserId');
    });
  }

  QueryBuilder<PaymentIn, String?, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<PaymentIn, int, QQueryOperations> partyIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'partyId');
    });
  }

  QueryBuilder<PaymentIn, DateTime, QQueryOperations> receiptDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'receiptDate');
    });
  }

  QueryBuilder<PaymentIn, String, QQueryOperations> receiptNoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'receiptNo');
    });
  }

  QueryBuilder<PaymentIn, double, QQueryOperations> totalAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalAmount');
    });
  }

  QueryBuilder<PaymentIn, DateTime?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPaymentInLineCollection on Isar {
  IsarCollection<PaymentInLine> get paymentInLines => this.collection();
}

const PaymentInLineSchema = CollectionSchema(
  name: r'PaymentInLine',
  id: 8539094471648590633,
  properties: {
    r'amount': PropertySchema(
      id: 0,
      name: r'amount',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'paymentAccountId': PropertySchema(
      id: 2,
      name: r'paymentAccountId',
      type: IsarType.long,
    ),
    r'paymentInId': PropertySchema(
      id: 3,
      name: r'paymentInId',
      type: IsarType.long,
    ),
    r'referenceNo': PropertySchema(
      id: 4,
      name: r'referenceNo',
      type: IsarType.string,
    )
  },
  estimateSize: _paymentInLineEstimateSize,
  serialize: _paymentInLineSerialize,
  deserialize: _paymentInLineDeserialize,
  deserializeProp: _paymentInLineDeserializeProp,
  idName: r'id',
  indexes: {
    r'paymentInId': IndexSchema(
      id: 813334909202225752,
      name: r'paymentInId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'paymentInId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'paymentAccountId': IndexSchema(
      id: -2040224812189840708,
      name: r'paymentAccountId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'paymentAccountId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _paymentInLineGetId,
  getLinks: _paymentInLineGetLinks,
  attach: _paymentInLineAttach,
  version: '3.1.0+1',
);

int _paymentInLineEstimateSize(
  PaymentInLine object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.referenceNo;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _paymentInLineSerialize(
  PaymentInLine object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeLong(offsets[2], object.paymentAccountId);
  writer.writeLong(offsets[3], object.paymentInId);
  writer.writeString(offsets[4], object.referenceNo);
}

PaymentInLine _paymentInLineDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PaymentInLine();
  object.amount = reader.readDouble(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.paymentAccountId = reader.readLong(offsets[2]);
  object.paymentInId = reader.readLong(offsets[3]);
  object.referenceNo = reader.readStringOrNull(offsets[4]);
  return object;
}

P _paymentInLineDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _paymentInLineGetId(PaymentInLine object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _paymentInLineGetLinks(PaymentInLine object) {
  return [];
}

void _paymentInLineAttach(
    IsarCollection<dynamic> col, Id id, PaymentInLine object) {
  object.id = id;
}

extension PaymentInLineQueryWhereSort
    on QueryBuilder<PaymentInLine, PaymentInLine, QWhere> {
  QueryBuilder<PaymentInLine, PaymentInLine, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterWhere> anyPaymentInId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'paymentInId'),
      );
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterWhere>
      anyPaymentAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'paymentAccountId'),
      );
    });
  }
}

extension PaymentInLineQueryWhere
    on QueryBuilder<PaymentInLine, PaymentInLine, QWhereClause> {
  QueryBuilder<PaymentInLine, PaymentInLine, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterWhereClause> idBetween(
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

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterWhereClause>
      paymentInIdEqualTo(int paymentInId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'paymentInId',
        value: [paymentInId],
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterWhereClause>
      paymentInIdNotEqualTo(int paymentInId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'paymentInId',
              lower: [],
              upper: [paymentInId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'paymentInId',
              lower: [paymentInId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'paymentInId',
              lower: [paymentInId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'paymentInId',
              lower: [],
              upper: [paymentInId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterWhereClause>
      paymentInIdGreaterThan(
    int paymentInId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'paymentInId',
        lower: [paymentInId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterWhereClause>
      paymentInIdLessThan(
    int paymentInId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'paymentInId',
        lower: [],
        upper: [paymentInId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterWhereClause>
      paymentInIdBetween(
    int lowerPaymentInId,
    int upperPaymentInId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'paymentInId',
        lower: [lowerPaymentInId],
        includeLower: includeLower,
        upper: [upperPaymentInId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterWhereClause>
      paymentAccountIdEqualTo(int paymentAccountId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'paymentAccountId',
        value: [paymentAccountId],
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterWhereClause>
      paymentAccountIdNotEqualTo(int paymentAccountId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'paymentAccountId',
              lower: [],
              upper: [paymentAccountId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'paymentAccountId',
              lower: [paymentAccountId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'paymentAccountId',
              lower: [paymentAccountId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'paymentAccountId',
              lower: [],
              upper: [paymentAccountId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterWhereClause>
      paymentAccountIdGreaterThan(
    int paymentAccountId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'paymentAccountId',
        lower: [paymentAccountId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterWhereClause>
      paymentAccountIdLessThan(
    int paymentAccountId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'paymentAccountId',
        lower: [],
        upper: [paymentAccountId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterWhereClause>
      paymentAccountIdBetween(
    int lowerPaymentAccountId,
    int upperPaymentAccountId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'paymentAccountId',
        lower: [lowerPaymentAccountId],
        includeLower: includeLower,
        upper: [upperPaymentAccountId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PaymentInLineQueryFilter
    on QueryBuilder<PaymentInLine, PaymentInLine, QFilterCondition> {
  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition>
      amountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition>
      amountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition>
      amountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition>
      amountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition>
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

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition>
      paymentAccountIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition>
      paymentAccountIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paymentAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition>
      paymentAccountIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paymentAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition>
      paymentAccountIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paymentAccountId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition>
      paymentInIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentInId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition>
      paymentInIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paymentInId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition>
      paymentInIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paymentInId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition>
      paymentInIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paymentInId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition>
      referenceNoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'referenceNo',
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition>
      referenceNoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'referenceNo',
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition>
      referenceNoEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'referenceNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition>
      referenceNoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'referenceNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition>
      referenceNoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'referenceNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition>
      referenceNoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'referenceNo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition>
      referenceNoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'referenceNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition>
      referenceNoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'referenceNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition>
      referenceNoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'referenceNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition>
      referenceNoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'referenceNo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition>
      referenceNoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'referenceNo',
        value: '',
      ));
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterFilterCondition>
      referenceNoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'referenceNo',
        value: '',
      ));
    });
  }
}

extension PaymentInLineQueryObject
    on QueryBuilder<PaymentInLine, PaymentInLine, QFilterCondition> {}

extension PaymentInLineQueryLinks
    on QueryBuilder<PaymentInLine, PaymentInLine, QFilterCondition> {}

extension PaymentInLineQuerySortBy
    on QueryBuilder<PaymentInLine, PaymentInLine, QSortBy> {
  QueryBuilder<PaymentInLine, PaymentInLine, QAfterSortBy> sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterSortBy> sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterSortBy>
      sortByPaymentAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentAccountId', Sort.asc);
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterSortBy>
      sortByPaymentAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentAccountId', Sort.desc);
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterSortBy> sortByPaymentInId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentInId', Sort.asc);
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterSortBy>
      sortByPaymentInIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentInId', Sort.desc);
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterSortBy> sortByReferenceNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceNo', Sort.asc);
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterSortBy>
      sortByReferenceNoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceNo', Sort.desc);
    });
  }
}

extension PaymentInLineQuerySortThenBy
    on QueryBuilder<PaymentInLine, PaymentInLine, QSortThenBy> {
  QueryBuilder<PaymentInLine, PaymentInLine, QAfterSortBy> thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterSortBy> thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterSortBy>
      thenByPaymentAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentAccountId', Sort.asc);
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterSortBy>
      thenByPaymentAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentAccountId', Sort.desc);
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterSortBy> thenByPaymentInId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentInId', Sort.asc);
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterSortBy>
      thenByPaymentInIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentInId', Sort.desc);
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterSortBy> thenByReferenceNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceNo', Sort.asc);
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QAfterSortBy>
      thenByReferenceNoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceNo', Sort.desc);
    });
  }
}

extension PaymentInLineQueryWhereDistinct
    on QueryBuilder<PaymentInLine, PaymentInLine, QDistinct> {
  QueryBuilder<PaymentInLine, PaymentInLine, QDistinct> distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QDistinct>
      distinctByPaymentAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paymentAccountId');
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QDistinct>
      distinctByPaymentInId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paymentInId');
    });
  }

  QueryBuilder<PaymentInLine, PaymentInLine, QDistinct> distinctByReferenceNo(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'referenceNo', caseSensitive: caseSensitive);
    });
  }
}

extension PaymentInLineQueryProperty
    on QueryBuilder<PaymentInLine, PaymentInLine, QQueryProperty> {
  QueryBuilder<PaymentInLine, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PaymentInLine, double, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<PaymentInLine, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PaymentInLine, int, QQueryOperations>
      paymentAccountIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentAccountId');
    });
  }

  QueryBuilder<PaymentInLine, int, QQueryOperations> paymentInIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentInId');
    });
  }

  QueryBuilder<PaymentInLine, String?, QQueryOperations> referenceNoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'referenceNo');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPaymentOutCollection on Isar {
  IsarCollection<PaymentOut> get paymentOuts => this.collection();
}

const PaymentOutSchema = CollectionSchema(
  name: r'PaymentOut',
  id: 675701522069431027,
  properties: {
    r'attachmentPath': PropertySchema(
      id: 0,
      name: r'attachmentPath',
      type: IsarType.string,
    ),
    r'companyId': PropertySchema(
      id: 1,
      name: r'companyId',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'createdByUserId': PropertySchema(
      id: 3,
      name: r'createdByUserId',
      type: IsarType.long,
    ),
    r'description': PropertySchema(
      id: 4,
      name: r'description',
      type: IsarType.string,
    ),
    r'partyId': PropertySchema(
      id: 5,
      name: r'partyId',
      type: IsarType.long,
    ),
    r'totalAmount': PropertySchema(
      id: 6,
      name: r'totalAmount',
      type: IsarType.double,
    ),
    r'updatedAt': PropertySchema(
      id: 7,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'voucherDate': PropertySchema(
      id: 8,
      name: r'voucherDate',
      type: IsarType.dateTime,
    ),
    r'voucherNo': PropertySchema(
      id: 9,
      name: r'voucherNo',
      type: IsarType.string,
    )
  },
  estimateSize: _paymentOutEstimateSize,
  serialize: _paymentOutSerialize,
  deserialize: _paymentOutDeserialize,
  deserializeProp: _paymentOutDeserializeProp,
  idName: r'id',
  indexes: {
    r'companyId': IndexSchema(
      id: 482756417767355356,
      name: r'companyId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'companyId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'partyId': IndexSchema(
      id: 5656384584959416297,
      name: r'partyId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'partyId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _paymentOutGetId,
  getLinks: _paymentOutGetLinks,
  attach: _paymentOutAttach,
  version: '3.1.0+1',
);

int _paymentOutEstimateSize(
  PaymentOut object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.attachmentPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.voucherNo.length * 3;
  return bytesCount;
}

void _paymentOutSerialize(
  PaymentOut object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.attachmentPath);
  writer.writeLong(offsets[1], object.companyId);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeLong(offsets[3], object.createdByUserId);
  writer.writeString(offsets[4], object.description);
  writer.writeLong(offsets[5], object.partyId);
  writer.writeDouble(offsets[6], object.totalAmount);
  writer.writeDateTime(offsets[7], object.updatedAt);
  writer.writeDateTime(offsets[8], object.voucherDate);
  writer.writeString(offsets[9], object.voucherNo);
}

PaymentOut _paymentOutDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PaymentOut();
  object.attachmentPath = reader.readStringOrNull(offsets[0]);
  object.companyId = reader.readLong(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.createdByUserId = reader.readLongOrNull(offsets[3]);
  object.description = reader.readStringOrNull(offsets[4]);
  object.id = id;
  object.partyId = reader.readLong(offsets[5]);
  object.totalAmount = reader.readDouble(offsets[6]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[7]);
  object.voucherDate = reader.readDateTime(offsets[8]);
  object.voucherNo = reader.readString(offsets[9]);
  return object;
}

P _paymentOutDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _paymentOutGetId(PaymentOut object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _paymentOutGetLinks(PaymentOut object) {
  return [];
}

void _paymentOutAttach(IsarCollection<dynamic> col, Id id, PaymentOut object) {
  object.id = id;
}

extension PaymentOutQueryWhereSort
    on QueryBuilder<PaymentOut, PaymentOut, QWhere> {
  QueryBuilder<PaymentOut, PaymentOut, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterWhere> anyCompanyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'companyId'),
      );
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterWhere> anyPartyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'partyId'),
      );
    });
  }
}

extension PaymentOutQueryWhere
    on QueryBuilder<PaymentOut, PaymentOut, QWhereClause> {
  QueryBuilder<PaymentOut, PaymentOut, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<PaymentOut, PaymentOut, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterWhereClause> idBetween(
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

  QueryBuilder<PaymentOut, PaymentOut, QAfterWhereClause> companyIdEqualTo(
      int companyId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'companyId',
        value: [companyId],
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterWhereClause> companyIdNotEqualTo(
      int companyId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'companyId',
              lower: [],
              upper: [companyId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'companyId',
              lower: [companyId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'companyId',
              lower: [companyId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'companyId',
              lower: [],
              upper: [companyId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterWhereClause> companyIdGreaterThan(
    int companyId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'companyId',
        lower: [companyId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterWhereClause> companyIdLessThan(
    int companyId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'companyId',
        lower: [],
        upper: [companyId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterWhereClause> companyIdBetween(
    int lowerCompanyId,
    int upperCompanyId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'companyId',
        lower: [lowerCompanyId],
        includeLower: includeLower,
        upper: [upperCompanyId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterWhereClause> partyIdEqualTo(
      int partyId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'partyId',
        value: [partyId],
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterWhereClause> partyIdNotEqualTo(
      int partyId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'partyId',
              lower: [],
              upper: [partyId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'partyId',
              lower: [partyId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'partyId',
              lower: [partyId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'partyId',
              lower: [],
              upper: [partyId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterWhereClause> partyIdGreaterThan(
    int partyId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'partyId',
        lower: [partyId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterWhereClause> partyIdLessThan(
    int partyId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'partyId',
        lower: [],
        upper: [partyId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterWhereClause> partyIdBetween(
    int lowerPartyId,
    int upperPartyId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'partyId',
        lower: [lowerPartyId],
        includeLower: includeLower,
        upper: [upperPartyId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PaymentOutQueryFilter
    on QueryBuilder<PaymentOut, PaymentOut, QFilterCondition> {
  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      attachmentPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'attachmentPath',
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      attachmentPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'attachmentPath',
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      attachmentPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'attachmentPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      attachmentPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'attachmentPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      attachmentPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'attachmentPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      attachmentPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'attachmentPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      attachmentPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'attachmentPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      attachmentPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'attachmentPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      attachmentPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'attachmentPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      attachmentPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'attachmentPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      attachmentPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'attachmentPath',
        value: '',
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      attachmentPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'attachmentPath',
        value: '',
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition> companyIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'companyId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      companyIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'companyId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition> companyIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'companyId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition> companyIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'companyId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      createdByUserIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdByUserId',
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      createdByUserIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdByUserId',
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      createdByUserIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdByUserId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      createdByUserIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdByUserId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      createdByUserIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdByUserId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      createdByUserIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdByUserId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition> partyIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'partyId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      partyIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'partyId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition> partyIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'partyId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition> partyIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'partyId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      totalAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      totalAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      totalAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      totalAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition> updatedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition> updatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition> updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      voucherDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'voucherDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      voucherDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'voucherDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      voucherDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'voucherDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      voucherDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'voucherDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition> voucherNoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'voucherNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      voucherNoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'voucherNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition> voucherNoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'voucherNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition> voucherNoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'voucherNo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      voucherNoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'voucherNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition> voucherNoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'voucherNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition> voucherNoContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'voucherNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition> voucherNoMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'voucherNo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      voucherNoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'voucherNo',
        value: '',
      ));
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterFilterCondition>
      voucherNoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'voucherNo',
        value: '',
      ));
    });
  }
}

extension PaymentOutQueryObject
    on QueryBuilder<PaymentOut, PaymentOut, QFilterCondition> {}

extension PaymentOutQueryLinks
    on QueryBuilder<PaymentOut, PaymentOut, QFilterCondition> {}

extension PaymentOutQuerySortBy
    on QueryBuilder<PaymentOut, PaymentOut, QSortBy> {
  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> sortByAttachmentPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachmentPath', Sort.asc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy>
      sortByAttachmentPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachmentPath', Sort.desc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> sortByCompanyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'companyId', Sort.asc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> sortByCompanyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'companyId', Sort.desc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> sortByCreatedByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByUserId', Sort.asc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy>
      sortByCreatedByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByUserId', Sort.desc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> sortByPartyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partyId', Sort.asc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> sortByPartyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partyId', Sort.desc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> sortByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.asc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> sortByTotalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.desc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> sortByVoucherDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voucherDate', Sort.asc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> sortByVoucherDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voucherDate', Sort.desc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> sortByVoucherNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voucherNo', Sort.asc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> sortByVoucherNoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voucherNo', Sort.desc);
    });
  }
}

extension PaymentOutQuerySortThenBy
    on QueryBuilder<PaymentOut, PaymentOut, QSortThenBy> {
  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> thenByAttachmentPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachmentPath', Sort.asc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy>
      thenByAttachmentPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attachmentPath', Sort.desc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> thenByCompanyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'companyId', Sort.asc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> thenByCompanyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'companyId', Sort.desc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> thenByCreatedByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByUserId', Sort.asc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy>
      thenByCreatedByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdByUserId', Sort.desc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> thenByPartyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partyId', Sort.asc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> thenByPartyIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'partyId', Sort.desc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> thenByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.asc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> thenByTotalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.desc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> thenByVoucherDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voucherDate', Sort.asc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> thenByVoucherDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voucherDate', Sort.desc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> thenByVoucherNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voucherNo', Sort.asc);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QAfterSortBy> thenByVoucherNoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voucherNo', Sort.desc);
    });
  }
}

extension PaymentOutQueryWhereDistinct
    on QueryBuilder<PaymentOut, PaymentOut, QDistinct> {
  QueryBuilder<PaymentOut, PaymentOut, QDistinct> distinctByAttachmentPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'attachmentPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QDistinct> distinctByCompanyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'companyId');
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QDistinct> distinctByCreatedByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdByUserId');
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QDistinct> distinctByPartyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'partyId');
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QDistinct> distinctByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalAmount');
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QDistinct> distinctByVoucherDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'voucherDate');
    });
  }

  QueryBuilder<PaymentOut, PaymentOut, QDistinct> distinctByVoucherNo(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'voucherNo', caseSensitive: caseSensitive);
    });
  }
}

extension PaymentOutQueryProperty
    on QueryBuilder<PaymentOut, PaymentOut, QQueryProperty> {
  QueryBuilder<PaymentOut, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PaymentOut, String?, QQueryOperations> attachmentPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attachmentPath');
    });
  }

  QueryBuilder<PaymentOut, int, QQueryOperations> companyIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'companyId');
    });
  }

  QueryBuilder<PaymentOut, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PaymentOut, int?, QQueryOperations> createdByUserIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdByUserId');
    });
  }

  QueryBuilder<PaymentOut, String?, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<PaymentOut, int, QQueryOperations> partyIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'partyId');
    });
  }

  QueryBuilder<PaymentOut, double, QQueryOperations> totalAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalAmount');
    });
  }

  QueryBuilder<PaymentOut, DateTime?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<PaymentOut, DateTime, QQueryOperations> voucherDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'voucherDate');
    });
  }

  QueryBuilder<PaymentOut, String, QQueryOperations> voucherNoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'voucherNo');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPaymentOutLineCollection on Isar {
  IsarCollection<PaymentOutLine> get paymentOutLines => this.collection();
}

const PaymentOutLineSchema = CollectionSchema(
  name: r'PaymentOutLine',
  id: 4340229674461795090,
  properties: {
    r'amount': PropertySchema(
      id: 0,
      name: r'amount',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'paymentAccountId': PropertySchema(
      id: 2,
      name: r'paymentAccountId',
      type: IsarType.long,
    ),
    r'paymentOutId': PropertySchema(
      id: 3,
      name: r'paymentOutId',
      type: IsarType.long,
    ),
    r'referenceNo': PropertySchema(
      id: 4,
      name: r'referenceNo',
      type: IsarType.string,
    )
  },
  estimateSize: _paymentOutLineEstimateSize,
  serialize: _paymentOutLineSerialize,
  deserialize: _paymentOutLineDeserialize,
  deserializeProp: _paymentOutLineDeserializeProp,
  idName: r'id',
  indexes: {
    r'paymentOutId': IndexSchema(
      id: 1783159545625875236,
      name: r'paymentOutId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'paymentOutId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'paymentAccountId': IndexSchema(
      id: -2040224812189840708,
      name: r'paymentAccountId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'paymentAccountId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _paymentOutLineGetId,
  getLinks: _paymentOutLineGetLinks,
  attach: _paymentOutLineAttach,
  version: '3.1.0+1',
);

int _paymentOutLineEstimateSize(
  PaymentOutLine object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.referenceNo;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _paymentOutLineSerialize(
  PaymentOutLine object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeLong(offsets[2], object.paymentAccountId);
  writer.writeLong(offsets[3], object.paymentOutId);
  writer.writeString(offsets[4], object.referenceNo);
}

PaymentOutLine _paymentOutLineDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PaymentOutLine();
  object.amount = reader.readDouble(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.paymentAccountId = reader.readLong(offsets[2]);
  object.paymentOutId = reader.readLong(offsets[3]);
  object.referenceNo = reader.readStringOrNull(offsets[4]);
  return object;
}

P _paymentOutLineDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _paymentOutLineGetId(PaymentOutLine object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _paymentOutLineGetLinks(PaymentOutLine object) {
  return [];
}

void _paymentOutLineAttach(
    IsarCollection<dynamic> col, Id id, PaymentOutLine object) {
  object.id = id;
}

extension PaymentOutLineQueryWhereSort
    on QueryBuilder<PaymentOutLine, PaymentOutLine, QWhere> {
  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterWhere> anyPaymentOutId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'paymentOutId'),
      );
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterWhere>
      anyPaymentAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'paymentAccountId'),
      );
    });
  }
}

extension PaymentOutLineQueryWhere
    on QueryBuilder<PaymentOutLine, PaymentOutLine, QWhereClause> {
  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterWhereClause> idBetween(
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

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterWhereClause>
      paymentOutIdEqualTo(int paymentOutId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'paymentOutId',
        value: [paymentOutId],
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterWhereClause>
      paymentOutIdNotEqualTo(int paymentOutId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'paymentOutId',
              lower: [],
              upper: [paymentOutId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'paymentOutId',
              lower: [paymentOutId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'paymentOutId',
              lower: [paymentOutId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'paymentOutId',
              lower: [],
              upper: [paymentOutId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterWhereClause>
      paymentOutIdGreaterThan(
    int paymentOutId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'paymentOutId',
        lower: [paymentOutId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterWhereClause>
      paymentOutIdLessThan(
    int paymentOutId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'paymentOutId',
        lower: [],
        upper: [paymentOutId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterWhereClause>
      paymentOutIdBetween(
    int lowerPaymentOutId,
    int upperPaymentOutId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'paymentOutId',
        lower: [lowerPaymentOutId],
        includeLower: includeLower,
        upper: [upperPaymentOutId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterWhereClause>
      paymentAccountIdEqualTo(int paymentAccountId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'paymentAccountId',
        value: [paymentAccountId],
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterWhereClause>
      paymentAccountIdNotEqualTo(int paymentAccountId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'paymentAccountId',
              lower: [],
              upper: [paymentAccountId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'paymentAccountId',
              lower: [paymentAccountId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'paymentAccountId',
              lower: [paymentAccountId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'paymentAccountId',
              lower: [],
              upper: [paymentAccountId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterWhereClause>
      paymentAccountIdGreaterThan(
    int paymentAccountId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'paymentAccountId',
        lower: [paymentAccountId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterWhereClause>
      paymentAccountIdLessThan(
    int paymentAccountId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'paymentAccountId',
        lower: [],
        upper: [paymentAccountId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterWhereClause>
      paymentAccountIdBetween(
    int lowerPaymentAccountId,
    int upperPaymentAccountId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'paymentAccountId',
        lower: [lowerPaymentAccountId],
        includeLower: includeLower,
        upper: [upperPaymentAccountId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PaymentOutLineQueryFilter
    on QueryBuilder<PaymentOutLine, PaymentOutLine, QFilterCondition> {
  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
      amountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
      amountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
      amountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
      amountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
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

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
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

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
      paymentAccountIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
      paymentAccountIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paymentAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
      paymentAccountIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paymentAccountId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
      paymentAccountIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paymentAccountId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
      paymentOutIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentOutId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
      paymentOutIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paymentOutId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
      paymentOutIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paymentOutId',
        value: value,
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
      paymentOutIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paymentOutId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
      referenceNoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'referenceNo',
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
      referenceNoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'referenceNo',
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
      referenceNoEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'referenceNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
      referenceNoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'referenceNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
      referenceNoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'referenceNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
      referenceNoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'referenceNo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
      referenceNoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'referenceNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
      referenceNoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'referenceNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
      referenceNoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'referenceNo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
      referenceNoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'referenceNo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
      referenceNoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'referenceNo',
        value: '',
      ));
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterFilterCondition>
      referenceNoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'referenceNo',
        value: '',
      ));
    });
  }
}

extension PaymentOutLineQueryObject
    on QueryBuilder<PaymentOutLine, PaymentOutLine, QFilterCondition> {}

extension PaymentOutLineQueryLinks
    on QueryBuilder<PaymentOutLine, PaymentOutLine, QFilterCondition> {}

extension PaymentOutLineQuerySortBy
    on QueryBuilder<PaymentOutLine, PaymentOutLine, QSortBy> {
  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterSortBy> sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterSortBy>
      sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterSortBy>
      sortByPaymentAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentAccountId', Sort.asc);
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterSortBy>
      sortByPaymentAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentAccountId', Sort.desc);
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterSortBy>
      sortByPaymentOutId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentOutId', Sort.asc);
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterSortBy>
      sortByPaymentOutIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentOutId', Sort.desc);
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterSortBy>
      sortByReferenceNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceNo', Sort.asc);
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterSortBy>
      sortByReferenceNoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceNo', Sort.desc);
    });
  }
}

extension PaymentOutLineQuerySortThenBy
    on QueryBuilder<PaymentOutLine, PaymentOutLine, QSortThenBy> {
  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterSortBy> thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterSortBy>
      thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterSortBy>
      thenByPaymentAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentAccountId', Sort.asc);
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterSortBy>
      thenByPaymentAccountIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentAccountId', Sort.desc);
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterSortBy>
      thenByPaymentOutId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentOutId', Sort.asc);
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterSortBy>
      thenByPaymentOutIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentOutId', Sort.desc);
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterSortBy>
      thenByReferenceNo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceNo', Sort.asc);
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QAfterSortBy>
      thenByReferenceNoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceNo', Sort.desc);
    });
  }
}

extension PaymentOutLineQueryWhereDistinct
    on QueryBuilder<PaymentOutLine, PaymentOutLine, QDistinct> {
  QueryBuilder<PaymentOutLine, PaymentOutLine, QDistinct> distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QDistinct>
      distinctByPaymentAccountId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paymentAccountId');
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QDistinct>
      distinctByPaymentOutId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paymentOutId');
    });
  }

  QueryBuilder<PaymentOutLine, PaymentOutLine, QDistinct> distinctByReferenceNo(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'referenceNo', caseSensitive: caseSensitive);
    });
  }
}

extension PaymentOutLineQueryProperty
    on QueryBuilder<PaymentOutLine, PaymentOutLine, QQueryProperty> {
  QueryBuilder<PaymentOutLine, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PaymentOutLine, double, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<PaymentOutLine, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PaymentOutLine, int, QQueryOperations>
      paymentAccountIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentAccountId');
    });
  }

  QueryBuilder<PaymentOutLine, int, QQueryOperations> paymentOutIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentOutId');
    });
  }

  QueryBuilder<PaymentOutLine, String?, QQueryOperations>
      referenceNoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'referenceNo');
    });
  }
}
