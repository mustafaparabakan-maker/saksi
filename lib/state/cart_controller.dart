import 'package:flutter/foundation.dart';

import '../models/product.dart';

/// Sepetteki bir satır: ürün + adet.
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.price * quantity;
}

/// Basit sepet yönetimi (simülasyon).
///
/// ChangeNotifier sayesinde sepet değiştiğinde onu dinleyen
/// widget'lar (ListenableBuilder) otomatik olarak yeniden çizilir.
class CartController extends ChangeNotifier {
  static const double freeShippingLimit = 750;
  static const double shippingFee = 49.90;

  final Map<int, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  bool get isEmpty => _items.isEmpty;

  int get totalCount =>
      _items.values.fold<int>(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.values.fold<double>(0, (sum, item) => sum + item.total);

  double get shipping =>
      isEmpty || subtotal >= freeShippingLimit ? 0 : shippingFee;

  double get total => subtotal + shipping;

  int quantityOf(Product product) => _items[product.id]?.quantity ?? 0;

  void add(Product product) {
    final existing = _items[product.id];
    if (existing == null) {
      _items[product.id] = CartItem(product: product);
    } else {
      existing.quantity++;
    }
    notifyListeners();
  }

  void decrease(Product product) {
    final existing = _items[product.id];
    if (existing == null) return;
    if (existing.quantity > 1) {
      existing.quantity--;
    } else {
      _items.remove(product.id);
    }
    notifyListeners();
  }

  void remove(Product product) {
    _items.remove(product.id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

/// Uygulama genelinde kullanılan tek sepet örneği.
final CartController cartController = CartController();
