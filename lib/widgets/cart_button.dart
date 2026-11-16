import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../state/cart_controller.dart';
import '../theme/app_theme.dart';

/// AppBar'da duran, sepetteki ürün sayısını rozet olarak gösteren buton.
class CartButton extends StatelessWidget {
  const CartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: cartController,
      builder: (context, _) {
        final count = cartController.totalCount;
        return IconButton(
          tooltip: 'Sepetim',
          onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
          icon: Badge(
            isLabelVisible: count > 0,
            backgroundColor: AppColors.accent,
            label: Text('$count'),
            child: const Icon(Icons.shopping_bag_outlined),
          ),
        );
      },
    );
  }
}
