// lib/features/goals/widgets/smart_create_goal_form.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kampus_koin_app/features/goals/providers/goal_notifier.dart';

class SmartCreateGoalForm extends ConsumerStatefulWidget {
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
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalState = ref.watch(goalNotifierProvider);
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
              widget.initialName != null ? 'Save for ${widget.initialName}' : 'Create New Goal',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Set up your savings plan instantly',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),

            // 3. Info Banner (If calculations are present)
            if (widget.initialAmount != null)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF), // Light blue
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDBEAFE)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 20, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'We\'ve calculated the 25% down payment for you.',
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontSize: 13,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // 4. Inputs
            Text(
              'Goal Name',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'e.g., New Phone',
                prefixIcon: const Icon(Icons.flag_outlined, color: Colors.grey),
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
              validator: (value) => (value == null || value.isEmpty) ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 24),

            Text(
              'Target Amount',
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
                hintText: 'e.g., 20000',
                prefixIcon: const Icon(Icons.monetization_on_outlined, color: Colors.grey),
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
                if (value == null || value.isEmpty) return 'Enter amount';
                return null;
              },
            ),

            const SizedBox(height: 40),

            // 5. Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: goalState.isLoading ? null : _submitGoal,
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
                child: goalState.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Create Goal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
            
            if (goalState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  goalState.errorMessage!,
                  style: TextStyle(color: colorScheme.error, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}