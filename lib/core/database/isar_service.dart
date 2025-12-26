import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/account_models.dart';
import '../../data/models/company_model.dart';
import '../../data/models/inventory_models.dart';
import '../../data/models/invoice_stock_models.dart';
import '../../data/models/party_model.dart';
import '../../data/models/payment_models.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/user_model.dart';

class IsarService {
  Isar? _isar;

  Isar get isar {
    if (_isar == null) {
      throw Exception('Isar not initialized yet');
    }
    return _isar!;
  }

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();

    _isar ??= await Isar.open(
      [
        CompanySchema,
        UserSchema,
        CompanyUserSchema,
        PartySchema,
        UnitOfMeasureSchema,
        ItemCategorySchema,
        ProductSchema,
        TransactionSchema,
        TransactionLineSchema,
        InvoiceSchema,
        StockLedgerSchema,
        PaymentAccountSchema,
        PaymentInSchema,
        PaymentInLineSchema,
        PaymentOutSchema,
        PaymentOutLineSchema,
        AccountSchema,
        AccountTransactionSchema,
      ],
      directory: dir.path,
      inspector: kDebugMode,
    );
  }
}
