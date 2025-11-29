// lib/features/marketplace/screens/marketplace_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kampus_koin_app/core/models/product_model.dart';
import 'package:kampus_koin_app/features/goals/widgets/smart_create_goal_form.dart';
import 'package:kampus_koin_app/features/marketplace/providers/order_notifier.dart';
import '../providers/products_provider.dart';
import 'dart:ui';

class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsData = ref.watch(productsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    // final textTheme = Theme.of(context).textTheme; // Not strictly needed here

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Consistent light grey background
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Marketplace',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(productsProvider.future),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  // 1. Taller Gradient Background
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                  ),
                  
                  // 2. Decorative elements
                  Positioned(
                    top: -50,
                    right: -50,
                    child: CircleAvatar(
                      radius: 100, 
                      backgroundColor: Colors.white.withOpacity(0.05)
                    ),
                  ),
                  
                  // 3. Header Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 110, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Exclusive Rewards',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Use your savings to unlock premium student gear.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Glassmorphic Stats Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: productsData.when(
                                loading: () => const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))),
                                error: (_, __) => const Text('Stats unavailable', style: TextStyle(color: Colors.white)),
                                data: (products) {
                                  final unlockedCount = products
                                      .where((p) => p.isUnlocked && !p.isAlreadyUnlocked)
                                      .length;
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatColumn(
                                          products.length.toString(),
                                          'Catalog',
                                        ),
                                      ),
                                      Container(height: 30, width: 1, color: Colors.white.withOpacity(0.3)),
                                      Expanded(
                                        child: _buildStatColumn(
                                          unlockedCount.toString(),
                                          'Unlocked',
                                        ),
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

            // Products List
            SliverPadding(
              padding: const EdgeInsets.all(24.0),
              sliver: productsData.when(
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (err, stack) => SliverToBoxAdapter(
                  child: Center(child: Text('Error: $err', style: const TextStyle(color: Colors.grey))),
                ),
                data: (products) {
                  if (products.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(child: Text('No products available')),
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
            
            // Bottom padding for scroll
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// --- REDESIGNED PRODUCT CARD (E-Commerce Style) ---
class ProductCard extends ConsumerWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_KE',
      symbol: 'Ksh ',
      decimalDigits: 0,
    );

    final orderStates = ref.watch(orderNotifierProvider);
    final productState = orderStates[product.id] ?? OrderState();

    // Configuration based on state
    String buttonText;
    Color buttonColor;
    Color buttonTextColor = Colors.white;
    VoidCallback? onPressed;
    bool isPrimaryAction = false;

    if (product.isAlreadyUnlocked) {
      buttonText = 'View Ticket';
      buttonColor = Colors.green;
      isPrimaryAction = true;
      onPressed = () {
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
      isPrimaryAction = true;
      onPressed = () async { 
        ScaffoldMessenger.of(context).clearSnackBars();
        final newOrder = await ref
            .read(orderNotifierProvider.notifier)
            .unlockProduct(product.id);
        
        if (newOrder != null && context.mounted) {
          context.push('/order-pickup', extra: newOrder);
        } else if (context.mounted) {
          final error = ref.read(orderNotifierProvider)[product.id]?.errorMessage;
          _showErrorDialog(context, error);
        }
      };
    } else {
      buttonText = 'Save for this';
      buttonColor = colorScheme.surface; // Light background
      buttonTextColor = colorScheme.primary;
      onPressed = () {
        final downPayment = product.price * 0.25;
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => Container(
             decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
            child: SmartCreateGoalForm(
              initialName: product.name,
              initialAmount: downPayment.toStringAsFixed(0),
            ),
          ),
        );
      };
    }

    if (productState.isLoading) onPressed = null;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9E9E9E).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Image Placeholder Area (Makes it look like a shop)
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Center(
              child: Icon(
                Icons.shopping_bag_outlined, // Placeholder icon
                size: 60,
                color: colorScheme.primary.withOpacity(0.3),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Title & Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                      ),
                    ),
                    if (product.isUnlocked || product.isAlreadyUnlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: product.isAlreadyUnlocked ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.isAlreadyUnlocked ? 'OWNED' : 'READY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: product.isAlreadyUnlocked ? Colors.green : Colors.orange,
                          ),
                        ),
                      )
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // 3. Description
                Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),

                const SizedBox(height: 20),

                // 4. Price & Koin Requirement Row
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PRICE', style: TextStyle(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.bold)),
                        Text(
                          currencyFormatter.format(product.price),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1), // Light Amber
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFE082)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.stars_rounded, color: Color(0xFFFFC107), size: 18),
                          const SizedBox(width: 6),
                          Text(
                            '${product.requiredKoinScore} Score',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFA000),
                              fontSize: 13
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 5. Action Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: buttonTextColor,
                      elevation: isPrimaryAction ? 4 : 0,
                      shadowColor: buttonColor.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: isPrimaryAction 
                            ? BorderSide.none 
                            : BorderSide(color: colorScheme.primary.withOpacity(0.2)),
                      ),
                    ),
                    child: productState.isLoading
                        ? SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: buttonTextColor))
                        : Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String? error) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cannot Unlock'),
        content: Text(error ?? 'An unknown error occurred.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }
}