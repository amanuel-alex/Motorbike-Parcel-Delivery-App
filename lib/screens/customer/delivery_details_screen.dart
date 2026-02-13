import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/delivery_model.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/services/delivery_service.dart';

class DeliveryDetailsScreen extends StatelessWidget {
  final Delivery delivery;

  const DeliveryDetailsScreen({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text('Order Details', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Map Visualization (Gradient Placeholder)
            Container(
              width: double.infinity,
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_getStatusIcon(delivery.status), size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      delivery.status.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Live Tracking Mode', style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1)),
                    ),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Delivery Information'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppColors.subtleShadow,
                    ),
                    child: Column(
                      children: [
                        _buildLocationRow(Icons.radio_button_checked, AppColors.primary, 'PICKUP', delivery.pickupAddress),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(),
                        ),
                        _buildLocationRow(Icons.location_on, Colors.red, 'DROP-OFF', delivery.dropoffAddress),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('Package & Payment'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppColors.subtleShadow,
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow('Package Type', delivery.packageType),
                        const Divider(height: 24),
                        _buildInfoRow('Price', 'ETB ${delivery.price.toStringAsFixed(0)}'),
                        const Divider(height: 24),
                        _buildInfoRow('Payment', delivery.paymentStatus?.toUpperCase() ?? 'PENDING', 
                          valueColor: _getPaymentColor(delivery.paymentStatus)),
                        if (delivery.paymentRef != null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text('Ref: ${delivery.paymentRef}', style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),
                  
                  if (delivery.status == 'pending')
                    CustomButton(
                      text: 'Cancel Order',
                      onPressed: () async {
                        try {
                          await DeliveryService().cancelDelivery(delivery.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order canceled successfully'), backgroundColor: Colors.red));
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to cancel: $e'), backgroundColor: Colors.red));
                          }
                        }
                      },
                      backgroundColor: Colors.red.withOpacity(0.1),
                      textColor: Colors.red,
                    )
                  else if (delivery.status == 'picked')
                    Center(
                      child: Text(
                        'Your package is on the way!',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.hourglass_empty;
      case 'accepted': return Icons.thumb_up;
      case 'picked': return Icons.moped;
      case 'completed': return Icons.check_circle;
      case 'canceled': return Icons.cancel;
      default: return Icons.help_outline;
    }
  }

  Color _getPaymentColor(String? status) {
    switch (status) {
      case 'approved': return Colors.green;
      case 'canceled': return Colors.red;
      default: return Colors.orange;
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
    );
  }

  Widget _buildLocationRow(IconData icon, Color color, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textTertiary)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: valueColor ?? AppColors.textPrimary)),
      ],
    );
  }
}
