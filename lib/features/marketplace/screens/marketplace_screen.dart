// lib/features/marketplace/screens/marketplace_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kampus_koin_app/core/models/product_model.dart';
import 'package:kampus_koin_app/features/marketplace/providers/order_notifier.dart';
import '../providers/products_provider.dart';
import 'dart:ui';

class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsData = ref.watch(productsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Marketplace',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(productsProvider.future),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  // Gradient Background
                  Container(
                    height: 340,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withOpacity(0.8),
                          colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
      bottomLeft: Radius.circular(80),
      bottomRight: Radius.circular(80),
    ),
                    ),
                  ),
                  // Decorative circles
                  Positioned(
                    top: -30,
                    right: -40,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 80,
                    left: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 80),
                        // Header Text
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.shopping_bag_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Exclusive Rewards',
                                    style: textTheme.headlineMedium?.copyWith(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Unlock amazing products with your savings',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Stats Card
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: productsData.when(
                                loading: () => const SizedBox(
                                  height: 40,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                error: (_, __) => const SizedBox.shrink(),
                                data: (products) {
                                  final unlockedCount = products
                                      .where((p) => p.isUnlocked && !p.isAlreadyUnlocked)
                                      .length;
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildStatItem(
                                        icon: Icons.inventory_2_rounded,
                                        label: 'Total Products',
                                        value: products.length.toString(),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 40,
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                      _buildStatItem(
                                        icon: Icons.lock_open_rounded,
                                        label: 'Available Now',
                                        value: unlockedCount.toString(),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Products Section
            SliverPadding(
              padding: const EdgeInsets.all(24.0),
              sliver: productsData.when(
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => SliverToBoxAdapter(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Oops! Something went wrong',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          err.toString(),
                          style: TextStyle(color: Colors.grey[500]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                data: (products) {
                  if (products.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No products available',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Check back later for exciting rewards',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return ProductCard(product: products[index]);
                      },
                      childCount: products.length,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// --- REDESIGNED PRODUCT CARD ---
class ProductCard extends ConsumerWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_KE',
      symbol: 'KES ',
    );

    final orderStates = ref.watch(orderNotifierProvider);
    final productState = orderStates[product.id] ?? OrderState();


    // Determine button state
    String buttonText;
    Color buttonColor;
    IconData buttonIcon;
    VoidCallback? onPressed;
    bool showGlow = false;

    if (product.isAlreadyUnlocked) {
      buttonText = 'View Ticket';
      buttonColor = Colors.green;
      buttonIcon = Icons.qr_code_rounded;
      showGlow = true;
      onPressed = () {
        // We need to pass an Order object to the next screen.
        // Since the backend now returns 'active_order' in the Product model,
        // we can use that (assuming your Product model in Dart handles the mapping),
        // OR we map it manually here if the Product model isn't fully updated yet.
        
        // *Assumes product.activeOrder is available via your Dart Model*
        if (product.activeOrder != null) {
           context.push('/order-pickup', extra: product.activeOrder);
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Error loading ticket details.')),
           );
        }
      };
    } else if (product.isUnlocked) {
      buttonText = 'Unlock Now';
      buttonColor = colorScheme.primary;
      buttonIcon = Icons.lock_open_rounded;
      onPressed = () async { 
        ScaffoldMessenger.of(context).clearSnackBars();// <-- MAKE onPresse'd async
        final newOrder = await ref
            .read(orderNotifierProvider.notifier)
            .unlockProduct(product.id);
        
        // --- ADD NAVIGATION LOGIC ---
        if (newOrder != null && context.mounted) {
          // On success, push to the new screen
          context.push('/order-pickup', extra: newOrder);
        }
        // If it failed, the notifier will set an error
        // and we can show a snackbar (optional)
        else if (context.mounted) {
           // This handles the "Koin score not high enough" error
          final error = ref.read(orderNotifierProvider)[product.id]?.errorMessage;
          
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Cannot Unlock'),
              content: Text(error ?? 'An unknown error occurred.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      };
      showGlow = true;
    } else {
      buttonText = 'Keep Saving';
      buttonColor = Colors.grey[400]!;
      buttonIcon = Icons.lock_rounded;
      onPressed = null;
    }

    if (productState.isLoading) {
      onPressed = null;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: showGlow
                ? (product.isAlreadyUnlocked ? Colors.green.withOpacity(0.2) : colorScheme.primary.withOpacity(0.2))
                : Colors.black.withOpacity(0.08),
            blurRadius: showGlow ? 20 : 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Subtle gradient overlay for unlockable products
            if (product.isUnlocked && !product.isAlreadyUnlocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withOpacity(0.05),
                        Colors.transparent,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            
            // Status Badge
            if (product.isAlreadyUnlocked || product.isUnlocked)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: product.isAlreadyUnlocked
                        ? Colors.grey[300]
                        : colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        product.isAlreadyUnlocked
                            ? Icons.check_circle
                            : Icons.stars_rounded,
                        size: 14,
                        color: product.isAlreadyUnlocked
                            ? Colors.grey[600]
                            : colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.isAlreadyUnlocked ? 'Owned' : 'Ready',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: product.isAlreadyUnlocked
                              ? Colors.grey[600]
                              : colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Icon & Name
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.card_giftcard_rounded,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    product.description,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Divider
                  Divider(color: Colors.grey[200]),
                  const SizedBox(height: 16),

                  // Price and Koin Score
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price',
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currencyFormatter.format(product.price),
                              style: textTheme.titleLarge?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.secondary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.stars_rounded,
                              color: colorScheme.secondary,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${product.requiredKoinScore}',
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Koins',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: buttonColor.withOpacity(0.7),
                        disabledForegroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: showGlow ? 4 : 0,
                        shadowColor: buttonColor.withOpacity(0.5),
                      ),
                      child: productState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(buttonIcon, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  buttonText,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                    ),
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