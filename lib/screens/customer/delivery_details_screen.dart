import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/delivery_model.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/services/delivery_service.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';


class DeliveryDetailsScreen extends StatelessWidget {
  final Delivery delivery;

  const DeliveryDetailsScreen({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    final userRole = Provider.of<AuthProvider>(context).userRole;
    final isPendingPayment = delivery.paymentStatus == 'pending';
    final isCustomer = userRole == 'customer';
    final isAdmin = userRole == 'admin';
    final bool canConfirmReceipt = isCustomer && delivery.status == 'completed' && delivery.customerConfirmedAt == null;
    final bool showPayoutControls = isAdmin && delivery.customerConfirmedAt != null;

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
                  
                  // Customer Confirmation
                  if (canConfirmReceipt) ...[
                    const SizedBox(height: 32),
                    Center(
                      child: CustomButton(
                        text: 'Confirm Package Received',
                        icon: Icons.check_circle,
                        backgroundColor: Colors.green,
                        onPressed: () async {
                           await DeliveryService().confirmReceipt(delivery.id);
                           if (context.mounted) Navigator.pop(context);
                        },
                      ),
                    ),
                  ],

                  if (isAdmin) ...[
                     const SizedBox(height: 32),
                     _buildSectionTitle('Admin Controls'),
                     const SizedBox(height: 16),
                     
                     // Payment Approval Section
                     if (isPendingPayment) ...[
                       Container(
                         padding: const EdgeInsets.all(16),
                         decoration: BoxDecoration(
                           color: Colors.white,
                           borderRadius: BorderRadius.circular(12),
                           border: Border.all(color: Colors.orange.withOpacity(0.5)),
                         ),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             const Text("Verify Payment", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)),
                             const SizedBox(height: 12),
                             _buildInfoRow("Provider", delivery.paymentProvider ?? "Unknown"),
                             const SizedBox(height: 8),
                             _buildInfoRow("Transaction ID", delivery.paymentRef ?? "N/A"),
                             const SizedBox(height: 12),
                             if (delivery.paymentScreenshotUrl != null) ...[
                               const Text("Payment Proof:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                               const SizedBox(height: 8),
                               GestureDetector(
                                 onTap: () {
                                   showDialog(
                                     context: context,
                                     builder: (_) => Dialog(
                                       child: InteractiveViewer(
                                         child: Image.network(delivery.paymentScreenshotUrl!),
                                       ),
                                     ),
                                   );
                                 },
                                 child: ClipRRect(
                                   borderRadius: BorderRadius.circular(8),
                                   child: Image.network(
                                     delivery.paymentScreenshotUrl!,
                                     height: 200,
                                     width: double.infinity,
                                     fit: BoxFit.cover,
                                     errorBuilder: (ctx, err, stack) => Container(
                                       height: 100,
                                       color: Colors.grey[200],
                                       child: const Center(child: Text("Image Load Failed")),
                                     ),
                                   ),
                                 ),
                               ),
                               const SizedBox(height: 16),
                             ],
                             Row(
                               children: [
                                 Expanded(
                                   child: CustomButton(
                                     text: 'Approve',
                                     backgroundColor: Colors.green,
                                     textColor: Colors.white,
                                     onPressed: () async {
                                       await DeliveryService().updatePaymentStatus(delivery.id, 'approved');
                                       if (context.mounted) Navigator.pop(context);
                                     },
                                   ),
                                 ),
                                 const SizedBox(width: 12),
                                 Expanded(
                                   child: CustomButton(
                                     text: 'Reject',
                                     backgroundColor: Colors.red,
                                     textColor: Colors.white,
                                     onPressed: () async {
                                       await DeliveryService().updatePaymentStatus(delivery.id, 'canceled');
                                       if (context.mounted) Navigator.pop(context);
                                     },
                                   ),
                                 ),
                               ],
                             ),
                           ],
                         ),
                       ),
                       const SizedBox(height: 24),
                     ],

                     // Payout Controls
                     if (showPayoutControls) _buildPayoutSection(context),

                     CustomButton(
                        text: 'Force Cancel Order',
                        onPressed: () async {
                          await DeliveryService().cancelDelivery(delivery.id);
                          if (context.mounted) Navigator.pop(context);
                        },
                        backgroundColor: Colors.red.withOpacity(0.1),
                        textColor: Colors.red,
                      ),
                  ] else if (delivery.status == 'pending')
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

  Widget _buildPayoutSection(BuildContext context) {
    if (delivery.expectedDeliveryTime == null || delivery.customerConfirmedAt == null) {
      return const SizedBox.shrink(); 
    }

    final expected = delivery.expectedDeliveryTime!;
    final actual = delivery.customerConfirmedAt!;
    final basePrice = delivery.price;
    final diff = expected.difference(actual); // Positive if early, Negative if late
    
    double bonus = 0;
    String note = "On Time (Exact Bill)";
    Color noteColor = Colors.orange;

    if (diff.inMinutes >= 5) { // Early by 5+ mins
       bonus = basePrice * 0.10;
       note = "Early Reward (+10%)";
       noteColor = Colors.green;
    } else if (diff.inMinutes < 0) { // Late
       bonus = -(basePrice * 0.10);
       note = "Late Penalty (-10%)";
       noteColor = Colors.red;
    }

    final totalPayout = basePrice + bonus;

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Rider Payout Calculation", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _buildInfoRow("Expected Time", _formatTime(expected)),
          const SizedBox(height: 4),
          _buildInfoRow("Actual Time", _formatTime(actual)),
           const SizedBox(height: 8),
          const Divider(),
           const SizedBox(height: 8),
          _buildInfoRow("Base Bill", "ETB ${basePrice.toStringAsFixed(0)}"),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text("Adjustment", style: TextStyle(color: noteColor, fontWeight: FontWeight.bold)),
               Text(note, style: TextStyle(color: noteColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Payout", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              Text("ETB ${totalPayout.toStringAsFixed(0)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 16),
          if (delivery.riderPaid)
             Container(
               width: double.infinity,
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
               child: const Center(child: Text("PAID", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, letterSpacing: 2))),
             )
          else
            CustomButton(
              text: "Pay Rider",
              backgroundColor: AppColors.primary,
              onPressed: () async {
                 await DeliveryService().payRider(delivery.id, totalPayout);
                 if (context.mounted) Navigator.pop(context);
              },
            )
        ],
      ),
    );
  }

  String _formatTime(DateTime t) {
    return "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
  }
}
