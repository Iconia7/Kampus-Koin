// lib/features/marketplace/screens/order_pickup_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kampus_koin_app/core/models/order_model.dart';
import 'package:qr_flutter/qr_flutter.dart';

class OrderPickupScreen extends StatelessWidget {
  final Order order;
  const OrderPickupScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Order Ready for Pickup'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          // Go back to the main app, not just the marketplace
          onPressed: () => context.go('/home'), 
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Congratulations!',
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Your item is ready for pickup.',
                style: textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),

            // --- The QR Code ---

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  )
                ]
              ),
              child: QrImageView(
                data: order.pickupQrCode, // The UUID from our backend
                version: QrVersions.auto,
                size: 250.0,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Present this code to the vendor',
                style: textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 40),

            // --- Order Details ---
            Text('Order Details', style: textTheme.headlineMedium),
            const SizedBox(height: 16),
            _buildDetailRow(
              context,
              icon: Icons.shopping_bag_outlined,
              title: 'Item',
              subtitle: order.product.name,
            ),
            _buildDetailRow(
              context,
              icon: Icons.store_outlined,
              title: 'Vendor',
              subtitle: order.product.vendorName ?? 'N/A',
            ),
            _buildDetailRow(
              context,
              icon: Icons.location_on_outlined,
              title: 'Pickup Location',
              subtitle: order.product.vendorLocation ?? 'Contact vendor for details',
            ),
            _buildDetailRow(
              context,
              icon: Icons.payment_outlined,
              title: 'Down Payment',
              subtitle: 'KES ${order.downPayment.toStringAsFixed(2)} (Paid)',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, {required IconData icon, required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}