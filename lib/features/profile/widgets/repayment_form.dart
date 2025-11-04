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
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repaymentState = ref.watch(repaymentNotifierProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 32,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Repay for ${widget.productName}',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Amount Due: KES ${widget.amountDue.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount to Repay',
                hintText: 'e.g., 500',
                prefixText: 'KES ',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                final amount = double.parse(value);
                if (amount <= 0) return 'Amount must be greater than zero';
                if (amount > widget.amountDue) {
                  return 'Amount cannot be greater than the amount due';
                }
                return null;
              },
            ),
            const SizedBox(height: 48),

            ElevatedButton(
              onPressed: repaymentState.isLoading ? null : _submitRepayment,
              child: repaymentState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('SUBMIT REPAYMENT'),
            ),

            if (repaymentState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  repaymentState.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
