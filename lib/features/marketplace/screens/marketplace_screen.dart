// lib/features/marketplace/screens/marketplace_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kampus_koin_app/core/models/product_model.dart';
import 'package:kampus_koin_app/core/models/goal_model.dart';
import 'package:kampus_koin_app/features/goals/widgets/smart_create_goal_form.dart';
import 'package:kampus_koin_app/features/marketplace/providers/order_notifier.dart';
import '../providers/products_provider.dart';
import 'package:kampus_koin_app/features/home/providers/goals_provider.dart'; 
import 'package:kampus_koin_app/core/services/notification_service.dart';
import 'dart:ui';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    await Future.wait([
      ref.refresh(productsProvider.future),
      ref.refresh(goalsProvider.future), 
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final productsData = ref.watch(productsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
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
        onRefresh: _refreshData,
        color: colorScheme.primary,
        backgroundColor: Colors.white,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.secondary],
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
                  
                  Positioned(
                    top: -50,
                    right: -50,
                    child: CircleAvatar(
                      radius: 100, 
                      backgroundColor: Colors.white.withOpacity(0.05)
                    ),
                  ),
                  
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

                        // Stats Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                              ),
                              child: productsData.when(
                                loading: () => const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))),
                                error: (_, __) => const Text('Stats unavailable', style: TextStyle(color: Colors.white)),
                                data: (products) {
                                  final unlockedCount = products.where((p) => p.isUnlocked && !p.isAlreadyUnlocked).length;
                                  return Row(
                                    children: [
                                      Expanded(child: _buildStatColumn(products.length.toString(), 'Catalog')),
                                      Container(height: 30, width: 1, color: Colors.white.withOpacity(0.3)),
                                      Expanded(child: _buildStatColumn(unlockedCount.toString(), 'Unlocked')),
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
                    return const SliverToBoxAdapter(child: Center(child: Text('No products available')));
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ProductCard(product: products[index]),
                      childCount: products.length,
                    ),
                  );
                },
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// --- REDESIGNED PRODUCT CARD (Multi-Select Logic) ---
class ProductCard extends ConsumerWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_KE', symbol: 'Ksh ', decimalDigits: 0,
    );

    final orderStates = ref.watch(orderNotifierProvider);
    final productState = orderStates[product.id] ?? OrderState();

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
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error loading ticket details.')));
        }
      };
    } else if (product.isUnlocked) {
      buttonText = 'Unlock Now';
      buttonColor = colorScheme.primary;
      isPrimaryAction = true;
      
      // --- SMART MULTI-SELECT DEDUCTION LOGIC ---
      onPressed = () async {
        
        // 1. Show Repayment Terms & Schedule Dialog
        final bool? agreed = await showDialog<bool>(
          context: context,
          builder: (ctx) => _RepaymentTermsDialog(product: product),
        );

        // If user cancelled or didn't agree, stop here.
        if (agreed != true) return;

        final downPayment = product.price * 0.25;
        
        // 2. Get current goals with ANY balance
        final allGoals = ref.read(goalsProvider).valueOrNull ?? [];
        final goalsWithFunds = allGoals.where((g) => g.currentAmount > 0).toList();
        
        // Calculate total available across all goals
        final totalAvailable = goalsWithFunds.fold(0.0, (sum, g) => sum + g.currentAmount);

        if (totalAvailable < downPayment) {
           _showErrorDialog(
             context, 
             "Insufficient Total Funds.\n\nYou have KES ${currencyFormatter.format(totalAvailable)} in total savings, but you need KES ${currencyFormatter.format(downPayment)} for the down payment."
           );
           return;
        }

        // 3. Show Multi-Select Bottom Sheet
        final selectedGoals = await showModalBottomSheet<List<Goal>>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (ctx) => _MultiGoalSelectionSheet(
            goals: goalsWithFunds, 
            requiredAmount: downPayment,
            colorScheme: colorScheme,
          ),
        );

        if (selectedGoals == null || selectedGoals.isEmpty) return; // User cancelled

        // 4. Proceed with selected IDs
        ScaffoldMessenger.of(context).clearSnackBars();
        
        // Pass List of IDs
        final newOrder = await ref
            .read(orderNotifierProvider.notifier)
            .unlockProduct(
              product.id, 
              goalIds: selectedGoals.map((g) => g.id).toList() // Pass list
            ); 
        
        if (newOrder != null && context.mounted) {
          // --- NEW NOTIFICATION LOGIC ---
          final notifService = ref.read(notificationServiceProvider);
          
          // 1. Show immediate success notification
          notifService.showOrderSuccess(product.name);
          
          // 2. Schedule repayment reminders (e.g. 7 days and 30 days from now)
          notifService.scheduleRepaymentReminders(product.name);

          context.push('/order-pickup', extra: newOrder);
        } else if (context.mounted) {
          final error = ref.read(orderNotifierProvider)[product.id]?.errorMessage;
          _showErrorDialog(context, error);
        }
      };

    } else {
      buttonText = 'Save for this';
      buttonColor = colorScheme.surface; 
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
          BoxShadow(color: const Color(0xFF9E9E9E).withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Center(child: Icon(Icons.shopping_bag_outlined, size: 60, color: colorScheme.primary.withOpacity(0.3))),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(product.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.2)),
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
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: product.isAlreadyUnlocked ? Colors.green : Colors.orange),
                        ),
                      )
                  ],
                ),
                const SizedBox(height: 8),
                Text(product.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PRICE', style: TextStyle(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.bold)),
                        Text(currencyFormatter.format(product.price), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: colorScheme.primary)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFE082)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.stars_rounded, color: Color(0xFFFFC107), size: 18),
                          const SizedBox(width: 6),
                          Text('${product.requiredKoinScore} Score', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFA000), fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
                        side: isPrimaryAction ? BorderSide.none : BorderSide(color: colorScheme.primary.withOpacity(0.2)),
                      ),
                    ),
                    child: productState.isLoading
                        ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: buttonTextColor))
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

// --- NEW WIDGET: REPAYMENT TERMS DIALOG ---
class _RepaymentTermsDialog extends StatelessWidget {
  final Product product;
  const _RepaymentTermsDialog({required this.product});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_KE', symbol: 'Ksh ', decimalDigits: 0);
    final dateFormat = DateFormat('MMM d, y');
    
    final downPayment = product.price * 0.25;
    final financedAmount = product.price - downPayment;
    final monthlyInstallment = financedAmount / 6;
    final today = DateTime.now();

    return AlertDialog(
      title: const Text('Repayment Plan', style: TextStyle(fontWeight: FontWeight.bold)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You are unlocking ${product.name}. Please review and accept the 6-month repayment schedule.',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 16),
              
              // Summary Table
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Total Price', currencyFormatter.format(product.price), true),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Down Payment (25%)', currencyFormatter.format(downPayment), false, isHighlight: true),
                    const Divider(height: 24),
                    _buildSummaryRow('Financed Amount', currencyFormatter.format(financedAmount), false),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Schedule
              const Text('Installment Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              
              // List months
              for (int i = 1; i <= 6; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Month $i (${dateFormat.format(today.add(Duration(days: 30 * i)))})', style: TextStyle(fontSize: 13, color: Colors.grey[800])),
                      Text(currencyFormatter.format(monthlyInstallment), style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('I Agree'),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isBold, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 14)),
        Text(
          value, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 14,
            color: isHighlight ? Colors.green[700] : Colors.black87
          )
        ),
      ],
    );
  }
}

// --- EXISTING MULTI-SELECT SHEET ---
class _MultiGoalSelectionSheet extends StatefulWidget {
  final List<Goal> goals;
  final double requiredAmount;
  final ColorScheme colorScheme;

  const _MultiGoalSelectionSheet({
    required this.goals,
    required this.requiredAmount,
    required this.colorScheme,
  });

  @override
  State<_MultiGoalSelectionSheet> createState() => _MultiGoalSelectionSheetState();
}

class _MultiGoalSelectionSheetState extends State<_MultiGoalSelectionSheet> {
  final Set<Goal> _selectedGoals = {};

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_KE', symbol: 'Ksh ', decimalDigits: 0);
    
    // Calculate total selected amount
    double totalSelected = 0;
    for (var goal in _selectedGoals) {
      totalSelected += goal.currentAmount;
    }
    
    final bool isEnough = totalSelected >= widget.requiredAmount;
    final double shortfall = widget.requiredAmount - totalSelected;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      // Use constrained height so it doesn't take full screen if list is short
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
             child: Container(
               width: 40, height: 4, 
               decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))
             )
          ),
          const SizedBox(height: 20),
          Text(
            "Select Payment Sources", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])
          ),
          const SizedBox(height: 4),
          Text(
            "Required: ${currencyFormatter.format(widget.requiredAmount)}", 
            style: TextStyle(color: widget.colorScheme.primary, fontWeight: FontWeight.w600)
          ),
          const SizedBox(height: 16),
          
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.goals.length,
              separatorBuilder: (_,__) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final goal = widget.goals[index];
                final isSelected = _selectedGoals.contains(goal);
                
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  activeColor: widget.colorScheme.primary,
                  title: Text(goal.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text("Balance: ${currencyFormatter.format(goal.currentAmount)}", style: TextStyle(color: Colors.green[700])),
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedGoals.add(goal);
                      } else {
                        _selectedGoals.remove(goal);
                      }
                    });
                  },
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Status & Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isEnough ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isEnough ? Icons.check_circle : Icons.warning_rounded,
                  color: isEnough ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEnough ? "Funds Sufficient" : "Insufficient Funds",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isEnough ? Colors.green[800] : Colors.red[800],
                        ),
                      ),
                      if (!isEnough)
                        Text(
                          "Add ${currencyFormatter.format(shortfall)} more",
                          style: TextStyle(fontSize: 12, color: Colors.red[600]),
                        ),
                    ],
                  ),
                ),
                Text(
                  currencyFormatter.format(totalSelected),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isEnough ? Colors.green[800] : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: isEnough 
                ? () => Navigator.pop(context, _selectedGoals.toList()) 
                : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: const Text("Confirm & Pay", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}