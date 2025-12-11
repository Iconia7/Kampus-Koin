import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kampus_koin_app/core/services/notification_service.dart';
import 'package:kampus_koin_app/features/goals/providers/deposit_notifier.dart';
import 'package:kampus_koin_app/features/home/providers/goals_provider.dart';
// IMPORTANT: Make sure this import points to the file we created in Phase 2
import 'package:kampus_koin_app/features/home/providers/payment_polling_service.dart'; 

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
    // Hide keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      // 1. Capture the current amount BEFORE the deposit
      // We need this so the Polling Service knows what "success" looks like (amount > startAmount)
      final goalsList = ref.read(goalsProvider).value;
      final currentGoal = goalsList?.firstWhere(
        (g) => g.id == widget.goalId, 
        orElse: () => throw Exception('Goal not found'),
      );
      // Determine the starting amount (handle nulls safely)
      final double startAmount = (currentGoal?.currentAmount ?? 0).toDouble();

      // 2. Send the STK Push Request
      final success = await ref
          .read(depositNotifierProvider.notifier)
          .depositToGoal(widget.goalId, _amountController.text.trim());

      if (success && mounted) {
        // FIX: Capture the ScaffoldMessenger BEFORE we pop the context.
        // Once we pop, 'context' might become detached or the widget unmounted.
        final messenger = ScaffoldMessenger.of(context);
        final amountText = _amountController.text; // Capture text for notification

        // 3. Close the modal immediately so the user can see the dashboard
        Navigator.of(context).pop();

        // 4. Show a "Waiting" SnackBar
        // We set a long duration because we might poll for up to 60 seconds
        messenger.showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                SizedBox(
                  width: 20, 
                  height: 20, 
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'STK push sent. Waiting for M-Pesa...',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.black87,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 60), // Keep it visible while polling
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );

        // 5. Start Polling (Wait for money to hit the db)
        // This runs in the background. It returns TRUE if balance increased.
        final isConfirmed = await ref
            .read(paymentPollingProvider)
            .waitForDepositConfirmation(widget.goalId, startAmount);

        // 6. Handle the result
        // FIX: Remove 'if (mounted)' check here. 
        // Since we popped the widget at step 3, 'mounted' is ALWAYS false now.
        // We must run this logic regardless to clean up the UI.
        
        // Remove the "Waiting" SnackBar immediately
        messenger.hideCurrentSnackBar();

        if (isConfirmed) {
          // SUCCESS: Backend confirmed receipt!
          messenger.showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    'Payment received! Dashboard updated.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              backgroundColor: Colors.green[700],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
          
          // Trigger the rich notification
          ref.read(notificationServiceProvider).showDepositSuccess(
            amountText, 
            widget.goalName
          );
        } else {
          // TIMEOUT: We stopped checking after 60s
          messenger.showSnackBar(
            SnackBar(
              content: const Text(
                'Still waiting for payment. Pull down to refresh later.',
              ),
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
    final depositState = ref.watch(depositNotifierProvider);
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
            const Text(
              'Add Deposit',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'to ${widget.goalName}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),

            // 3. Info Banner
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 20, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You\'ll receive an M-Pesa prompt on your phone shortly.',
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontSize: 13,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 4. Amount Input
            Text(
              'Deposit Amount',
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
                if (double.tryParse(value) == null || double.parse(value) <= 0) {
                  return 'Enter a valid amount';
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
                onPressed: depositState.isLoading ? null : _submitDeposit,
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
                child: depositState.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Send STK Push',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.send_rounded, size: 18),
                        ],
                      ),
              ),
            ),

            if (depositState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  depositState.errorMessage!,
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