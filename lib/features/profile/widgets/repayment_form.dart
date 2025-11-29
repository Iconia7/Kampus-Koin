// lib/features/profile/widgets/repayment_form.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kampus_koin_app/features/profile/providers/repayment_notifier.dart';

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
      final success = await ref
          .read(repaymentNotifierProvider.notifier)
          .repayOrder(widget.orderId, _amountController.text.trim());

      if (success && mounted) {
        Navigator.of(context).pop(); // Close the bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Repayment STK push sent! Check your phone to enter your PIN.',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
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
            // 1. Drag Handle
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

            // 2. Header
            Text(
              'Make Repayment',
              style: const TextStyle(
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

            // 3. Balance Indicator
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED), // Light orange background
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFEDD5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: colorScheme.secondary),
                  const SizedBox(width: 8),
                  Text(
                    'Outstanding Balance: ',
                    style: TextStyle(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'KES ${widget.amountDue.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 4. Amount Input Field
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
                prefixIcon: const Icon(Icons.attach_money_rounded, color: Colors.grey), // Or 'KES' text prefix
                prefixText: 'KES ',
                prefixStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                filled: true,
                fillColor: const Color(0xFFF8FAFC), // Very light grey fill
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

            // 5. Submit Button
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