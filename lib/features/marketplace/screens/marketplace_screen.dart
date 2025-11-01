// lib/features/marketplace/screens/marketplace_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kampus_koin_app/core/models/product_model.dart';
import 'package:kampus_koin_app/features/marketplace/providers/order_notifier.dart';
import '../providers/products_provider.dart';

// 1. Change to ConsumerWidget
class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. Watch the productsProvider
    final productsData = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(productsProvider.future),
        child: productsData.when(
          // 3. Handle the loading state
          loading: () => const Center(child: CircularProgressIndicator()),

          // 4. Handle the error state
          error: (err, stack) =>
              Center(child: Text('Error: ${err.toString()}')),

          // 5. Handle the success state
          data: (products) {
            if (products.isEmpty) {
              return const Center(
                child: Text('No products available right now.'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ProductCard(product: products[index]);
              },
            );
          },
        ),
      ),
    );
  }
}

// --- Custom Widget for the Product Card ---
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

    // --- 4. Listen for errors to show a snackbar ---
    ref.listen<Map<int, OrderState>>(orderNotifierProvider, (prev, next) {
      final newState = next[product.id];
      if (newState != null && newState.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newState.errorMessage!),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    });

    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Name
            Text(
              product.name,
              style: textTheme.headlineMedium?.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 8),

            // Product Description
            Text(
              product.description,
              style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            // Price and Koin Score
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currencyFormatter.format(product.price),
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Chip(
                  label: Text(
                    '${product.requiredKoinScore} Koins',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: colorScheme.secondary.withOpacity(0.1),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Unlock Button
            ElevatedButton(
              onPressed: (product.isUnlocked && !productState.isLoading)
                  ? () {
                      // Call the unlock method
                      ref
                          .read(orderNotifierProvider.notifier)
                          .unlockProduct(product.id);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: product.isUnlocked
                    ? colorScheme.primary
                    : Colors.grey[300],
              ),
              child: Text(product.isUnlocked ? 'UNLOCK NOW' : 'KEEP SAVING'),
            ),
          ],
        ),
      ),
    );
  }
}
