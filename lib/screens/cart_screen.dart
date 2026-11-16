import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../state/cart_controller.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

/// Sepet sayfası (simülasyon): adet artır/azalt, kaydırarak sil, toplam.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sepetim',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListenableBuilder(
        listenable: cartController,
        builder: (context, _) {
          if (cartController.isEmpty) {
            return const _EmptyCart();
          }
          final items = cartController.items;
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Dismissible(
                      key: ValueKey(item.product.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => cartController.remove(item.product),
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.only(right: 24),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB3412F),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.white),
                      ),
                      child: _CartItemTile(item: item),
                    );
                  },
                ),
              ),
              const _CartSummary(),
            ],
          );
        },
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(product.image, width: 68, height: 68, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  formatPrice(item.total),
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          _QuantityStepper(item: item),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final CartItem item;

  const _QuantityStepper({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Azalt',
            visualDensity: VisualDensity.compact,
            onPressed: () => cartController.decrease(item.product),
            icon: Icon(item.quantity == 1 ? Icons.delete_outline : Icons.remove, size: 18),
          ),
          Text(
            '${item.quantity}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          IconButton(
            tooltip: 'Artır',
            visualDensity: VisualDensity.compact,
            onPressed: () => cartController.add(item.product),
            icon: const Icon(Icons.add, size: 18),
          ),
        ],
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary();

  void _completeOrder(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: AppColors.primary, size: 48),
        title: const Text('Siparişin alındı!'),
        content: const Text(
          'Bu bir simülasyondur; gerçek bir ödeme alınmadı. '
          'Bitkilerin yeni evlerine kavuşmak için hazırlanıyor.',
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            onPressed: () {
              final navigator = Navigator.of(dialogContext);
              cartController.clear();
              navigator.pop(); // diyaloğu kapat
              navigator.popUntil(ModalRoute.withName(AppRoutes.home));
            },
            child: const Text('Alışverişe dön'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Özet kendi ListenableBuilder'ı ile dinler; adet değişince toplamlar güncellenir.
    return ListenableBuilder(
      listenable: cartController,
      builder: (context, _) => _buildSummary(context),
    );
  }

  Widget _buildSummary(BuildContext context) {
    final remaining = CartController.freeShippingLimit - cartController.subtotal;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (remaining > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '${formatPrice(remaining)} daha ekle, kargo bedava olsun!',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            _SummaryRow(label: 'Ara toplam', value: formatPrice(cartController.subtotal)),
            _SummaryRow(
              label: 'Kargo',
              value: cartController.shipping == 0 ? 'Ücretsiz' : formatPrice(cartController.shipping),
            ),
            const Divider(height: 20),
            _SummaryRow(
              label: 'Toplam',
              value: formatPrice(cartController.total),
              isBold: true,
            ),
            const SizedBox(height: 14),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => _completeOrder(context),
              child: const Text(
                'Siparişi Tamamla',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: isBold ? 18 : 15,
      fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
      color: isBold ? AppColors.text : AppColors.muted,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label, style: style),
          const Spacer(),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_florist_outlined, size: 64, color: AppColors.muted),
            const SizedBox(height: 16),
            const Text(
              'Sepetin henüz boş',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Sana uygun bir bitki bulmak için kataloğa göz at.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            FilledButton.tonal(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kataloğa dön'),
            ),
          ],
        ),
      ),
    );
  }
}
