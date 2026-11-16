import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../data/product_repository.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/cart_button.dart';
import '../widgets/product_card.dart';

/// Ana sayfa: banner, arama, kategori filtresi ve ürün ızgarası.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _allCategories = 'Tümü';

  final ProductRepository _repository = ProductRepository();
  final TextEditingController _searchController = TextEditingController();

  late final Future<List<Product>> _productsFuture;
  String _query = '';
  String _selectedCategory = _allCategories;

  @override
  void initState() {
    super.initState();
    _productsFuture = _repository.fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Seçili kategoriye ve arama metnine göre ürünleri süzer.
  List<Product> _filterProducts(List<Product> products) {
    final query = normalizeForSearch(_query.trim());
    return products.where((product) {
      final matchesCategory = _selectedCategory == _allCategories ||
          product.category == _selectedCategory;
      final matchesQuery = query.isEmpty ||
          normalizeForSearch(product.name).contains(query) ||
          normalizeForSearch(product.latinName).contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void _openDetail(Product product) {
    // Route Arguments: seçilen ürün detay sayfasına taşınır.
    Navigator.pushNamed(context, AppRoutes.detail, arguments: product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const _Logo(),
        actions: const [CartButton(), SizedBox(width: 8)],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Ürünler yüklenemedi.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final products = snapshot.data ?? <Product>[];
          final categories = <String>[
            _allCategories,
            ...products.map((p) => p.category).toSet(),
          ];
          final visibleProducts = _filterProducts(products);

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Greeting(),
                const _PromoBanner(),
                _buildSearchField(),
                _buildCategoryChips(categories),
                _buildSectionTitle(visibleProducts.length),
                if (visibleProducts.isEmpty)
                  const _EmptyResult()
                else
                  _buildProductGrid(visibleProducts),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onChanged: (value) => setState(() => _query = value),
        decoration: InputDecoration(
          hintText: 'Bitki ara (ör. orkide)',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Temizle',
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                ),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(List<String> categories) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = category == _selectedCategory;
          return ChoiceChip(
            label: Text(category),
            selected: selected,
            showCheckmark: false,
            onSelected: (_) => setState(() => _selectedCategory = category),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            side: BorderSide(
              color: selected ? AppColors.primary : AppColors.primaryLight,
            ),
            shape: const StadiumBorder(),
            labelStyle: TextStyle(
              color: selected ? Colors.white : AppColors.text,
              fontWeight: FontWeight.w600,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          const Text(
            'Bitkiler',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const Spacer(),
          Text(
            '$count bitki',
            style: const TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.66,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () => _openDetail(product),
        );
      },
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.spa, color: AppColors.primary),
        SizedBox(width: 8),
        Text(
          'Saksı',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Merhaba!',
            style: TextStyle(fontSize: 15, color: AppColors.muted),
          ),
          SizedBox(height: 2),
          Text(
            'Bugün hangi bitkiyi\nsahipleniyorsun?',
            style: TextStyle(
              fontSize: 24,
              height: 1.25,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Image.asset(
              'assets/images/banner.png',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
            const Positioned(
              left: 20,
              top: 22,
              right: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EVİNE YEŞİL KAT',
                    style: TextStyle(
                      color: Color(0xFFEEE4D2),
                      fontSize: 12,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Bakımı kolay bitkiler seçkisi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '₺750 üzeri kargo bedava',
                    style: TextStyle(color: Color(0xFFEEE4D2), fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off, size: 48, color: AppColors.muted),
            SizedBox(height: 12),
            Text(
              'Aradığın bitki bulunamadı',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 4),
            Text(
              'Farklı bir isim ya da kategori dene.',
              style: TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
