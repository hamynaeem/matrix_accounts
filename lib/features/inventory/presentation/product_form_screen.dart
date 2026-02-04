// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';
import '../../../data/models/inventory_models.dart';
import '../logic/product_master_provider.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _nameCtrl = TextEditingController();
  final _openingCtrl = TextEditingController();

  UnitOfMeasure? _uom;
  bool _trackStock = true;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    if (p != null) {
      _nameCtrl.text = p.name;
      _openingCtrl.text = p.openingQty.toString();
      _trackStock = p.isTracked;

      // Load unit data
      _loadProductData(p);
    }
  }

  Future<void> _loadProductData(Product product) async {
    final unitAsync = ref.read(productUnitProvider);

    unitAsync.whenData((units) {
      if (product.uomId != null) {
        _uom = units.firstWhere(
          (unit) => unit.id == product.uomId,
          orElse: () => units.first,
        );
      }
    });

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final company = ref.read(currentCompanyProvider)!;
    final dao = ref.read(productMasterDaoProvider);

    final unitAsync = ref.watch(productUnitProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Product'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                company.name,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _field(_nameCtrl, 'Product Name'),
            const SizedBox(height: 16),
            unitAsync.when(
              data: (units) => DropdownButtonFormField<UnitOfMeasure>(
                initialValue: _uom,
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: units
                    .map((u) =>
                        DropdownMenuItem(value: u, child: Text(u.abbrev)))
                    .toList(),
                onChanged: (v) => setState(() => _uom = v),
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('UOM error'),
            ),
            const SizedBox(height: 8),
            if (_trackStock) ...[
              _field(_openingCtrl, 'Opening Stock', isNumber: true),
              const SizedBox(height: 8),
            ],
            SwitchListTile(
              dense: true,
              value: _trackStock,
              onChanged: (v) {
                setState(() {
                  _trackStock = v;
                  // Clear opening stock when stock tracking is disabled
                  if (!v) {
                    _openingCtrl.clear();
                  }
                });
              },
              title: const Text('Track Stock'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final p = widget.product ?? Product();

                  p.companyId = company.id;
                  p.name = _nameCtrl.text.trim();
                  p.sku = '';
                  p.salePrice = 0;
                  p.lastCost = 0;
                  p.isTracked = _trackStock;
                  p.openingQty = double.tryParse(_openingCtrl.text) ?? 0;
                  p.categoryId = null;
                  p.uomId = _uom?.id;

                  await dao.saveProduct(p);

                  if (widget.product == null &&
                      _trackStock &&
                      p.openingQty > 0) {
                    await dao.insertOpeningStock(
                      companyId: company.id,
                      productId: p.id,
                      qty: p.openingQty,
                    );
                  }

                  ref.invalidate(productListProvider);
                  Navigator.pop(context);
                },
                child: const Text('Save Product'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
      {bool isNumber = false}) {
    return TextField(
      controller: c,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      onChanged: label == 'Opening Stock'
          ? (value) {
              // Automatically enable stock tracking if opening stock is entered
              if (value.isNotEmpty &&
                  double.tryParse(value) != null &&
                  double.tryParse(value)! > 0) {
                if (!_trackStock) {
                  setState(() => _trackStock = true);
                }
              }
            }
          : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}
