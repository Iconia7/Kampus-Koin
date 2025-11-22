// lib/features/goals/widgets/create_goal_form.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/goal_notifier.dart';

class CreateGoalForm extends ConsumerStatefulWidget {
  const CreateGoalForm({super.key});

  @override
  ConsumerState<CreateGoalForm> createState() => _CreateGoalFormState();
}

class _CreateGoalFormState extends ConsumerState<CreateGoalForm> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitGoal() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      final success = await ref
          .read(goalNotifierProvider.notifier)
          .createGoal(
            _nameController.text.trim(),
            _amountController.text.trim(),
          );

      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalState = ref.watch(goalNotifierProvider);
    final theme = Theme.of(context);

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
            // --- Header Section ---
            Text(
              'Create New Goal',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Start saving for something amazing',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // --- Goal Name Input ---
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Goal Name',
                hintText: 'e.g., New Laptop',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Please enter a name'
                  : null,
            ),
            const SizedBox(height: 24),

            // --- Target Amount Input ---
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Target Amount',
                hintText: 'e.g., 85000',
                prefixText: 'KES ',
                prefixIcon: Icon(Icons.attach_money),
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
                if (double.parse(value) <= 0) {
                  return 'Amount must be greater than zero';
                }
                return null;
              },
            ),

            const SizedBox(height: 48),

            // --- Submit Button ---
            ElevatedButton(
              onPressed: goalState.isLoading ? null : _submitGoal,
              child: goalState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('CREATE GOAL'),
            ),

            // --- Error Message ---
            if (goalState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  goalState.errorMessage!,
                  style: TextStyle(color: theme.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}