// lib/features/profile/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kampus_koin_app/core/models/order_model.dart';
import 'package:kampus_koin_app/core/models/transaction_model.dart';
import 'package:kampus_koin_app/features/home/providers/user_data_provider.dart';
import 'package:kampus_koin_app/features/profile/widgets/repayment_form.dart'; // <-- Make sure this import is here
import '../providers/orders_provider.dart'; // <-- Make sure this import is here
import '../providers/transactions_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userDataProvider);
    final ordersData = ref.watch(ordersProvider); // <-- WATCH THE ORDERS
    final transactionsData = ref.watch(transactionsProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userDataProvider);
          ref.invalidate(ordersProvider); // <-- REFRESH ORDERS
          ref.invalidate(transactionsProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // --- User Info Section ---
            SliverToBoxAdapter(
              child: userData.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error: $e')),
                data: (user) => Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: textTheme.displayLarge?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(user.email, style: textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      Text(
                        user.phoneNumber ?? 'No phone number',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- "My Financed Items" Section (This was missing) ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Text(
                  'My Financed Items',
                  style: textTheme.headlineMedium,
                ),
              ),
            ),
            ordersData.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, s) => SliverToBoxAdapter(
                child: Center(child: Text('Could not load orders: $e')),
              ),
              data: (orders) {
                if (orders.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          'You have no financed items yet. Visit the marketplace to get started!',
                        ),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 8.0,
                      ),
                      child: OrderListItem(order: orders[index]),
                    );
                  }, childCount: orders.length),
                );
              },
            ),
            // ---------------------------------

            // --- Transaction History Section ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Text(
                  'All Transactions',
                  style: textTheme.headlineMedium,
                ),
              ),
            ),
            transactionsData.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, s) => SliverToBoxAdapter(
                child: Center(child: Text('Could not load transactions: $e')),
              ),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(child: Text('No transactions yet.')),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return TransactionListItem(tx: transactions[index]);
                  }, childCount: transactions.length),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --- Order List Item (This was missing) ---
class OrderListItem extends StatelessWidget {
  final Order order;
  const OrderListItem({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_KE',
      symbol: 'KES ',
    );
    final double amountDue = order.amountFinanced - order.amountPaid;
    final double progress = order.amountFinanced > 0
        ? (order.amountPaid / order.amountFinanced).clamp(0.0, 1.0)
        : 1.0;
    final bool isPaid = order.status == 'PAID';

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.product,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Theme.of(context).colorScheme.background,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isPaid ? Colors.green : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${currencyFormatter.format(order.amountPaid)} paid',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isPaid
                        ? Colors.green
                        : Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isPaid
                      ? 'Paid in full 🎉'
                      : '${currencyFormatter.format(amountDue)} due',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isPaid ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            if (!isPaid) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  child: const Text('Make a Repayment'),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (ctx) => RepaymentForm(
                        orderId: order.id,
                        productName: order.product,
                        amountDue: amountDue,
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// --- Transaction List Item (This is the updated version) ---
class TransactionListItem extends StatelessWidget {
  final Transaction tx;
  const TransactionListItem({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_KE',
      symbol: 'KES ',
    );
    final dateFormat = DateFormat('MMM d, yyyy - h:mm a');

    IconData icon;
    Color color;
    String amountText;
    String title;

    final isDeposit = tx.transactionType == 'DEPOSIT';

    switch (tx.status) {
      case 'completed':
        icon = Icons.check_circle;
        color = isDeposit ? Colors.green : Colors.orange.shade700;
        amountText = (tx.amount ?? 0) > 0
            ? (isDeposit
                  ? '+ ${currencyFormatter.format(tx.amount)}'
                  : '- ${currencyFormatter.format(tx.amount)}')
            : currencyFormatter.format(tx.amount);
        title = isDeposit ? 'Goal Deposit' : 'Order Repayment';
        break;
      case 'pending':
        icon = Icons.pending;
        color = Colors.grey.shade500;
        amountText = '(Pending)';
        title = isDeposit ? 'Pending Deposit' : 'Pending Repayment';
        break;
      default: // 'failed'
        icon = Icons.cancel;
        color = Colors.red;
        amountText = '(Failed)';
        title = isDeposit ? 'Failed Deposit' : 'Failed Repayment';
    }

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        tx.mpesaReceiptNumber ??
            (tx.transactionDate != null
                ? dateFormat.format(tx.transactionDate!)
                : 'Processing...'),
      ),
      trailing: Text(
        amountText,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
          fontSize: 16,
        ),
      ),
    );
  }
}
