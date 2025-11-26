// lib/features/goals/widgets/smart_create_goal_form.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kampus_koin_app/features/goals/providers/goal_notifier.dart';

class SmartCreateGoalForm extends ConsumerStatefulWidget {
  // Add these parameters
  final String? initialName;
  final String? initialAmount;

  const SmartCreateGoalForm({
    super.key, 
    this.initialName, 
    this.initialAmount
  });

  @override
  ConsumerState<SmartCreateGoalForm> createState() => _SmartCreateGoalFormState();
}

class _SmartCreateGoalFormState extends ConsumerState<SmartCreateGoalForm> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize with the passed values (or empty if null)
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _amountController = TextEditingController(text: widget.initialAmount ?? '');
  }

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goal created! Start saving now.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalState = ref.watch(goalNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            
            // --- Dynamic Title ---
            Text(
              widget.initialName != null ? 'Save for ${widget.initialName}' : 'Create New Goal',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            
            // --- Helper Text ---
            if (widget.initialAmount != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'We calculated the 25% down payment for you.',
                  style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 32),

            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Goal Name',
                prefixIcon: Icon(Icons.flag_outlined, color: colorScheme.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true, fillColor: Colors.grey[50],
              ),
              validator: (value) => (value == null || value.isEmpty) ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Target Amount',
                prefixText: 'KES ',
                prefixIcon: Icon(Icons.monetization_on_outlined, color: colorScheme.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true, fillColor: Colors.grey[50],
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter amount';
                return null;
              },
            ),

            const SizedBox(height: 40),

            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: goalState.isLoading ? null : _submitGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: goalState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('CREATE GOAL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}