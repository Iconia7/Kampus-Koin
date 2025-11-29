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
      backgroundColor: const Color(0xFFF5F7FA), // Consistent light grey
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.black87, size: 28),
          onPressed: () => context.go('/home'),
        ),
        centerTitle: true,
        title: const Text(
          'Pickup Ticket',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1. Success Header
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 60),
            ),
            const SizedBox(height: 16),
            Text(
              'Order Ready!',
              style: textTheme.headlineMedium?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Show this QR code to the vendor\nto collect your item.',
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 32),

            // 2. QR Code Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: Colors.grey[100]!),
              ),
              child: Column(
                children: [
                  QrImageView(
                    data: order.pickupQrCode,
                    version: QrVersions.auto,
                    size: 220.0,
                    backgroundColor: Colors.white,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: colorScheme.primary,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.qr_code_scanner, size: 18, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Scan to verify',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 3. Order Details "Receipt" Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Details',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildDetailRow(
                    context,
                    icon: Icons.inventory_2_outlined,
                    title: 'Item',
                    subtitle: order.product.name,
                  ),
                  Divider(height: 24, color: Colors.grey[100]),
                  
                  _buildDetailRow(
                    context,
                    icon: Icons.storefront_outlined,
                    title: 'Vendor',
                    subtitle: order.product.vendorName ?? 'N/A',
                  ),
                  Divider(height: 24, color: Colors.grey[100]),
                  
                  _buildDetailRow(
                    context,
                    icon: Icons.location_on_outlined,
                    title: 'Pickup Location',
                    subtitle: order.product.vendorLocation ?? 'Contact vendor',
                    isHighlight: true, // Make location stand out
                  ),
                  Divider(height: 24, color: Colors.grey[100]),
                  
                  _buildDetailRow(
                    context,
                    icon: Icons.receipt_long_outlined,
                    title: 'Down Payment',
                    subtitle: 'KES ${order.downPayment.toStringAsFixed(2)}',
                    statusText: 'PAID',
                    statusColor: Colors.green,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    bool isHighlight = false,
    String? statusText,
    Color? statusColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: isHighlight ? Theme.of(context).colorScheme.primary : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (statusText != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor?.withOpacity(0.1) ?? Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor ?? Colors.grey[700],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}