import 'package:flutter/material.dart';

import '../models/product.dart';
import '../state/cart_controller.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/cart_button.dart';

/// Ürün detay sayfası. Ürün, rota argümanı (Route Arguments) olarak gelir.
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isFavorite = false;

  void _addToCart(Product product) {
    cartController.add(product);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${product.name} sepete eklendi'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as Product;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Favorilere ekle',
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? AppColors.accent : null,
            ),
          ),
          const CartButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Hero(
            tag: 'product-${product.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.asset(product.image, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.latinName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formatPrice(product.price),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoTag(icon: Icons.local_florist_outlined, text: product.category),
              if (product.petFriendly)
                const _InfoTag(icon: Icons.pets, text: 'Evcil hayvan dostu'),
            ],
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Bakım Bilgileri'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _CareTile(
                  icon: Icons.wb_sunny_outlined,
                  label: 'Işık',
                  value: product.light,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CareTile(
                  icon: Icons.water_drop_outlined,
                  label: 'Sulama',
                  value: product.water,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CareTile(
                  icon: Icons.eco_outlined,
                  label: 'Bakım',
                  value: product.difficulty,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Açıklama'),
          const SizedBox(height: 8),
          Text(
            product.description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.55,
              color: AppColors.text,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: ListenableBuilder(
            listenable: cartController,
            builder: (context, _) {
              final quantity = cartController.quantityOf(product);
              return FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => _addToCart(product),
                icon: const Icon(Icons.add_shopping_cart),
                label: Text(
                  quantity == 0
                      ? 'Sepete Ekle'
                      : 'Sepete Ekle  (sepette $quantity adet)',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoTag({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CareTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CareTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
