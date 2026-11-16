import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/product.dart';

/// Ürün verilerini sağlayan katman.
///
/// Gerçek bir API yerine assets/data/products.json dosyası okunur ve
/// ağ gecikmesi kısa bir bekleme ile simüle edilir (JSON simülasyonu).
class ProductRepository {
  static const String _dataPath = 'assets/data/products.json';

  Future<List<Product>> fetchProducts() async {
    // Sunucudan veri geliyormuş gibi kısa bir gecikme
    await Future.delayed(const Duration(milliseconds: 700));

    final String raw = await rootBundle.loadString(_dataPath);
    final Map<String, dynamic> decoded = jsonDecode(raw) as Map<String, dynamic>;
    final List<dynamic> items = decoded['products'] as List<dynamic>;

    return items
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
