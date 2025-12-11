import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kampus_koin_app/features/profile/providers/repayment_notifier.dart';
import 'package:kampus_koin_app/features/profile/providers/orders_provider.dart';
import 'package:kampus_koin_app/features/home/providers/payment_polling_service.dart'; 
import 'package:kampus_koin_app/core/services/notification_service.dart'; 

class RepaymentForm extends ConsumerStatefulWidget {
  final int orderId;
  final String productName;
  final double amountDue;

  const RepaymentForm({
    super.key,
    required this.orderId,
    required this.productName,
    required this.amountDue,
  });

  @override
  ConsumerState<RepaymentForm> createState() => _RepaymentFormState();
}

class _RepaymentFormState extends ConsumerState<RepaymentForm> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submitRepayment() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      // 1. Capture current amount paid BEFORE repayment
      final ordersList = ref.read(ordersProvider).value;
      final currentOrder = ordersList?.firstWhere(
        (o) => o.id == widget.orderId, 
        orElse: () => throw Exception('Order not found'),
      );
      final double startPaidAmount = (currentOrder?.amountPaid ?? 0).toDouble();

      // 2. Send STK Push Request
      final success = await ref
          .read(repaymentNotifierProvider.notifier)
          .repayOrder(widget.orderId, _amountController.text.trim());

      if (success && mounted) {
        // FIX 1: Capture ALL dependencies BEFORE popping context.
        // Once popped, 'ref' and 'context' become unsafe to access.
        final messenger = ScaffoldMessenger.of(context);
        ref.read(notificationServiceProvider); // Capture Service

        // 3. Close the bottom sheet immediately
        Navigator.of(context).pop(); 
        
        // 4. Show "Waiting" SnackBar
        messenger.showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                SizedBox(
                  width: 20, height: 20, 
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Repayment initiated. Waiting for M-Pesa...',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.black87,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 60), 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );

        // 5. Start Polling
        // (Note: We still use 'ref' here because we haven't yielded execution yet, 
        // but it's safer to use the ref we read earlier if we had captured the provider itself)
        final isConfirmed = await ref
            .read(paymentPollingProvider)
            .waitForRepaymentConfirmation(widget.orderId, startPaidAmount);

        messenger.clearSnackBars();

        if (isConfirmed) {
          // FIX 2: Removed 'ref.invalidate(...)' calls.
          // The PaymentPollingService now handles invalidation internally.
          // Calling it here caused the "Bad State" error.

          messenger.showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Payment confirmed! Balance updated.'),
                ],
              ),
              backgroundColor: Colors.green[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        } else {
          // TIMEOUT
          messenger.showSnackBar(
            SnackBar(
              content: const Text('Still waiting. Pull down to refresh history later.'),
              backgroundColor: Colors.orange[800],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repaymentState = ref.watch(repaymentNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Header
            const Text(
              'Make Repayment',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'For ${widget.productName}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),

            // Balance Indicator
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED), 
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFEDD5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: colorScheme.secondary),
                  const SizedBox(width: 8),
                  const Text(
                    'Outstanding Balance: ',
                    style: TextStyle(
                      color: Color(0xFFC2410C), 
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'KES ${widget.amountDue.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Color(0xFFC2410C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Amount Input Field
            Text(
              'Amount to Repay',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'e.g., 500',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.attach_money_rounded, color: Colors.grey), 
                prefixText: 'KES ',
                prefixStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                filled: true,
                fillColor: const Color(0xFFF8FAFC), 
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null) return 'Invalid number';
                if (amount <= 0) return 'Amount must be greater than zero';
                if (amount > widget.amountDue) {
                  return 'Cannot exceed outstanding balance';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: repaymentState.isLoading ? null : _submitRepayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: colorScheme.primary.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: repaymentState.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Confirm Repayment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),

            if (repaymentState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  repaymentState.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}