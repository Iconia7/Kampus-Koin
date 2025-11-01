// lib/features/goals/widgets/deposit_form.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kampus_koin_app/features/goals/providers/deposit_notifier.dart';

class DepositForm extends ConsumerStatefulWidget {
  final int goalId;
  final String goalName;

  const DepositForm({super.key, required this.goalId, required this.goalName});

  @override
  ConsumerState<DepositForm> createState() => _DepositFormState();
}

class _DepositFormState extends ConsumerState<DepositForm> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submitDeposit() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      final success = await ref
          .read(depositNotifierProvider.notifier)
          .depositToGoal(widget.goalId, _amountController.text.trim());

      if (success && mounted) {
        Navigator.of(context).pop(); // Close the bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('STK push sent! Check your phone to enter your PIN.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final depositState = ref.watch(depositNotifierProvider);

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
              'Deposit to ${widget.goalName}',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount to Deposit',
                hintText: 'e.g., 500',
                prefixText: 'KES ',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please enter an amount';
                if (double.tryParse(value) == null)
                  return 'Please enter a valid number';
                if (double.parse(value) <= 0)
                  return 'Amount must be greater than zero';
                return null;
              },
            ),
            const SizedBox(height: 48),

            ElevatedButton(
              onPressed: depositState.isLoading ? null : _submitDeposit,
              child: depositState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('SEND STK PUSH'),
            ),

            if (depositState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  depositState.errorMessage!,
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
