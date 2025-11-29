// lib/features/profile/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kampus_koin_app/core/models/order_model.dart';
import 'package:kampus_koin_app/core/models/transaction_model.dart';
import 'package:kampus_koin_app/features/home/providers/user_data_provider.dart';
import 'package:kampus_koin_app/features/profile/widgets/repayment_form.dart';
import '../providers/orders_provider.dart';
import '../providers/transactions_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userDataProvider);
    final ordersData = ref.watch(ordersProvider);
    final transactionsData = ref.watch(transactionsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Consistent light grey background
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.edit_rounded, color: Colors.white),
              tooltip: 'Edit Profile',
              onPressed: () => context.push('/edit-profile'),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.settings_rounded, color: Colors.white),
              onPressed: () => context.push('/settings'),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userDataProvider);
          ref.invalidate(ordersProvider);
          ref.invalidate(transactionsProvider);
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // --- User Header Section ---
            SliverToBoxAdapter(
              child: userData.when(
                loading: () => const SizedBox(
                  height: 350,
                  child: Center(child: CircularProgressIndicator(color: Colors.white)),
                ),
                error: (e, s) => Container(
                  height: 200,
                  color: colorScheme.primary,
                  child: Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
                ),
                data: (user) => Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1. Gradient Background
                    Container(
                      height: 360,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary,
                            const Color(0xFF4A00E0), // Deep blue/purple
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
                    
                    // 2. Decorative Circles
                    Positioned(
                      top: -60,
                      left: -40,
                      child: CircleAvatar(radius: 80, backgroundColor: Colors.white.withOpacity(0.05)),
                    ),
                    Positioned(
                      bottom: 60,
                      right: -30,
                      child: CircleAvatar(radius: 60, backgroundColor: Colors.white.withOpacity(0.05)),
                    ),

                    // 3. User Info
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          // Avatar with border
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Name
                          Text(
                            user.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Chips for Email/Phone
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.email_outlined, color: Colors.white70, size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      user.email,
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              if (user.phoneNumber != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.phone_outlined, color: Colors.white70, size: 14),
                                      const SizedBox(width: 6),
                                      Text(
                                        user.phoneNumber!,
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Financed Items Header ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Financed Items',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                    ordersData.when(
                      data: (orders) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${orders.length} Active',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),

            // --- Financed Items List ---
            ordersData.when(
              loading: () => const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))),
              error: (e, s) => SliverToBoxAdapter(child: Center(child: Text('Error loading orders'))),
              data: (orders) {
                if (orders.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          Text(
                            'No active orders',
                            style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => OrderListItem(order: orders[index]),
                      childCount: orders.length,
                    ),
                  ),
                );
              },
            ),

            // --- Transaction History Header ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: const Text(
                  'Transaction History',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            // --- Transaction List ---
            transactionsData.when(
              loading: () => const SliverToBoxAdapter(child: SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))),
              error: (e, s) => const SliverToBoxAdapter(child: SizedBox.shrink()),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text("No transaction history yet.", style: TextStyle(color: Colors.grey[500])),
                    )),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => TransactionListItem(tx: transactions[index]),
                      childCount: transactions.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --- MODERN ORDER CARD ---
class OrderListItem extends StatelessWidget {
  final Order order;
  const OrderListItem({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_KE', symbol: 'KES ', decimalDigits: 0);
    final double amountDue = order.amountFinanced - order.amountPaid;
    final double progress = order.amountFinanced > 0
        ? (order.amountPaid / order.amountFinanced).clamp(0.0, 1.0)
        : 1.0;
    final bool isPaid = order.status == 'PAID';
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isPaid ? Colors.green.withOpacity(0.1) : colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isPaid ? Icons.check_circle_outline : Icons.inventory_2_outlined,
                    color: isPaid ? Colors.green : colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ordered on ${order.orderDate != null ? DateFormat('MMM d').format(order.orderDate!) : 'Unknown Date'}',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (isPaid)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('PAID', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
              ],
            ),
            
            const SizedBox(height: 20),

            // Progress Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Paid: ${currencyFormatter.format(order.amountPaid)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
                Text(currencyFormatter.format(order.amountFinanced), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey[100],
                valueColor: AlwaysStoppedAnimation<Color>(isPaid ? Colors.green : colorScheme.primary),
              ),
            ),

            if (!isPaid) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: RepaymentForm(
                          orderId: order.id,
                          productName: order.product.name,
                          amountDue: amountDue,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.surface, // Light background
                    foregroundColor: colorScheme.primary, // Dark text
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: colorScheme.primary.withOpacity(0.2)),
                    ),
                  ),
                  child: const Text('Make Repayment', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

// --- MODERN TRANSACTION ITEM ---
class TransactionListItem extends StatelessWidget {
  final Transaction tx;
  const TransactionListItem({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_KE', symbol: 'KES ', decimalDigits: 0);
    final dateFormat = DateFormat('MMM d, h:mm a');
    final isDeposit = tx.transactionType == 'DEPOSIT';
    
    // Config based on status
    Color iconBg;
    Color iconColor;
    IconData icon;
    
    if (tx.status == 'failed') {
      iconBg = Colors.red.withOpacity(0.1);
      iconColor = Colors.red;
      icon = Icons.close;
    } else if (isDeposit) {
      iconBg = Colors.green.withOpacity(0.1);
      iconColor = Colors.green;
      icon = Icons.arrow_downward_rounded;
    } else {
      iconBg = Colors.orange.withOpacity(0.1);
      iconColor = Colors.orange;
      icon = Icons.arrow_upward_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDeposit ? 'Goal Deposit' : 'Loan Repayment',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  tx.transactionDate != null ? dateFormat.format(tx.transactionDate!) : 'Processing',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${isDeposit ? '+' : '-'} ${currencyFormatter.format(tx.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isDeposit ? Colors.green : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}