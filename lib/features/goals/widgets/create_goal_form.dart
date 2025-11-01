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
    // Hide keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      final success = await ref
          .read(goalNotifierProvider.notifier)
          .createGoal(
            _nameController.text.trim(),
            _amountController.text.trim(),
          );

      // Check if the widget is still mounted before using context
      if (success && mounted) {
        // Use the standard Navigator to pop the bottom sheet
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the state for loading and errors
    final goalState = ref.watch(goalNotifierProvider);

    // Add padding to avoid the keyboard
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
          mainAxisSize:
              MainAxisSize.min, // Make the sheet only as tall as its content
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Create New Goal',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Goal Name',
                hintText: 'e.g., New Laptop',
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Please enter a name'
                  : null,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Target Amount',
                hintText: 'e.g., 85000',
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
                  : const Text('SAVE GOAL'),
            ),

            if (goalState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  goalState.errorMessage!,
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
