import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/models/delivery_model.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/services/delivery_service.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_constants.dart';
import 'order_chat_screen.dart';


class DeliveryDetailsScreen extends StatelessWidget {
  final Delivery delivery;

  const DeliveryDetailsScreen({super.key, required this.delivery});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Delivery>(
      stream: DeliveryService().getDeliveryStream(delivery.id),
      initialData: delivery,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(appBar: AppBar(), body: Center(child: Text('Error: ${snapshot.error}')));
        }
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final currentDelivery = snapshot.data!;
        final userRole = Provider.of<AuthProvider>(context).userRole;
        final isPendingPayment = currentDelivery.paymentStatus == 'pending';
        final isCustomer = userRole == 'customer';
        final isAdmin = userRole == 'admin';
        final bool canConfirmReceipt = isCustomer && currentDelivery.status == 'completed' && currentDelivery.customerConfirmedAt == null;
        final bool showPayoutControls = isAdmin && currentDelivery.customerConfirmedAt != null;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FB),
          appBar: AppBar(
            title: const Text('Order Details', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const BackButton(color: AppColors.textPrimary),
            actions: [
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, color: AppColors.textPrimary),
                onPressed: () {
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (_) => OrderChatScreen(
                       deliveryId: currentDelivery.id, 
                       title: "Order #${currentDelivery.id.length > 4 ? currentDelivery.id.substring(0, 4) : currentDelivery.id}"
                     )),
                   );
                },
              ),
            ],
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
                          child: Icon(_getStatusIcon(currentDelivery.status), size: 40, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currentDelivery.status.toUpperCase(),
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
                            _buildLocationRow(Icons.radio_button_checked, AppColors.primary, 'PICKUP', currentDelivery.pickupAddress),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(),
                            ),
                            _buildLocationRow(Icons.location_on, Colors.red, 'DROP-OFF', currentDelivery.dropoffAddress),
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
                            _buildInfoRow('Package Type', currentDelivery.packageType),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Price', style: TextStyle(color: AppColors.textSecondary)),
                                Row(
                                  children: [
                                    Text('ETB ${currentDelivery.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                                    if (isAdmin && currentDelivery.status != 'completed' && currentDelivery.status != 'canceled')
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 16, color: AppColors.primary),
                                        onPressed: () => _showEditPriceDialog(context, currentDelivery),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            _buildInfoRow('Payment', currentDelivery.paymentStatus?.toUpperCase() ?? 'PENDING', 
                              valueColor: _getPaymentColor(currentDelivery.paymentStatus)),
                            if (currentDelivery.paymentRef != null) ...[
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text('Ref: ${currentDelivery.paymentRef}', style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
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
                               final confirm = await showConfirmationDialog(context, "Confirm Receipt", "Have you received the package?");
                               if (confirm) {
                                  await DeliveryService().confirmReceipt(currentDelivery.id);
                               }
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
                                 _buildInfoRow("Provider", currentDelivery.paymentProvider ?? "Unknown"),
                                 const SizedBox(height: 8),
                                 _buildInfoRow("Transaction ID", currentDelivery.paymentRef ?? "N/A"),
                                 const SizedBox(height: 12),
                                 if (currentDelivery.paymentScreenshotUrl != null) ...[
                                   const Text("Payment Proof:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                   const SizedBox(height: 8),
                                   GestureDetector(
                                     onTap: () {
                                       showDialog(
                                         context: context,
                                         builder: (_) => Dialog(
                                           child: InteractiveViewer(
                                             child: Image.network(currentDelivery.paymentScreenshotUrl!),
                                           ),
                                         ),
                                       );
                                     },
                                     child: ClipRRect(
                                       borderRadius: BorderRadius.circular(8),
                                       child: Image.network(
                                         currentDelivery.paymentScreenshotUrl!,
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
                                           if (await showConfirmationDialog(context, "Approve Payment", "Are you sure you want to approve this payment?")) {
                                              await DeliveryService().updatePaymentStatus(currentDelivery.id, 'approved');
                                           }
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
                                           if (await showConfirmationDialog(context, "Reject Payment", "Are you sure you want to reject this payment?")) {
                                              await DeliveryService().updatePaymentStatus(currentDelivery.id, 'canceled');
                                           }
                                         },
                                       ),
                                     ),
                                   ],
                                 ),
                               ],
                             ),
                           ),
                           const SizedBox(height: 24),
                         ] else if (currentDelivery.paymentStatus != 'approved' && currentDelivery.status != 'canceled' && currentDelivery.status != 'completed') ...[
                           // Manual Approval Fallback
                           Container(
                             padding: const EdgeInsets.all(16),
                             decoration: BoxDecoration(
                               color: Colors.white,
                               borderRadius: BorderRadius.circular(12),
                               border: Border.all(color: Colors.grey.withOpacity(0.3)),
                             ),
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 const Text("Manual Action", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                 const SizedBox(height: 8),
                                 const Text("No digital payment proof submitted yet.", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                 const SizedBox(height: 12),
                                 CustomButton(
                                   text: 'Mark as Paid (Cash/External)',
                                   backgroundColor: Colors.blue,
                                   textColor: Colors.white,
                                   onPressed: () async {
                                     if (await showConfirmationDialog(context, "Approve Payment", "Confirm manual payment?")) {
                                        await DeliveryService().updatePaymentStatus(currentDelivery.id, 'approved');
                                     }
                                   },
                                 ),
                               ],
                             ),
                           ),
                           const SizedBox(height: 24),
                         ],

                         // Payout Controls
                         if (showPayoutControls) _buildPayoutSection(context, currentDelivery),

                         CustomButton(
                            text: 'Force Cancel Order',
                            onPressed: () async {
                              if (await showConfirmationDialog(context, "Cancel Order", "Are you sure you want to cancel this order? This cannot be undone.")) {
                                 await DeliveryService().cancelDelivery(currentDelivery.id);
                              }
                            },
                            backgroundColor: Colors.red.withOpacity(0.1),
                            textColor: Colors.red,
                          ),
                      ] else if (currentDelivery.status == 'pending')
                        CustomButton(
                          text: 'Cancel Order',
                          onPressed: () async {
                            if (await showConfirmationDialog(context, "Cancel Order", "Cancel your delivery request?")) {
                                try {
                                  await DeliveryService().cancelDelivery(currentDelivery.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order canceled successfully'), backgroundColor: Colors.red));
                                    Navigator.pop(context);
                                  }
                                } catch (e) {
                                  // Error handling
                                }
                            }
                          },
                          backgroundColor: Colors.red.withOpacity(0.1),
                          textColor: Colors.red,
                        )
                      else if (currentDelivery.status == 'picked')
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
      },
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

  Widget _buildPayoutSection(BuildContext context, Delivery delivery) {
    if (delivery.expectedDeliveryTime == null || delivery.customerConfirmedAt == null) {
      return const SizedBox.shrink(); 
    }

    final expected = delivery.expectedDeliveryTime!;
    final actual = delivery.customerConfirmedAt!;
    final totalBill = delivery.price;
    
    // Revenue Split Calculation
    final platformCut = totalBill * AppConstants.platformCommissionRate;
    final riderBase = totalBill * AppConstants.riderRate;
    
    final diff = expected.difference(actual);
    double performanceAdjustment = 0;
    String note = "Standard (40%)";
    Color noteColor = AppColors.textTertiary;

    if (diff.inMinutes >= 5) { // Early by 5+ mins
       performanceAdjustment = totalBill * 0.05; // 5% Bonus from Org to Rider
       note = "Efficiency Bonus (+5%)";
       noteColor = Colors.green;
    } else if (diff.inMinutes < 0) { // Late
       performanceAdjustment = -(totalBill * 0.05); // 5% Deduction
       note = "Delay Penalty (-5%)";
       noteColor = Colors.red;
    }

    final finalRiderPayout = riderBase + performanceAdjustment;
    final platformNetProfit = platformCut - performanceAdjustment;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Earnings Breakdown", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: const Text("60/40 SPLIT", style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow("Customer Paid", "ETB ${totalBill.toStringAsFixed(0)}"),
          const SizedBox(height: 8),
          _buildInfoRow("Org Commission (60%)", "ETB ${platformCut.toStringAsFixed(0)}", valueColor: AppColors.textSecondary),
          _buildInfoRow("Rider Base Share (40%)", "ETB ${riderBase.toStringAsFixed(0)}", valueColor: AppColors.textSecondary),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               Text(note, style: TextStyle(color: noteColor, fontWeight: FontWeight.bold, fontSize: 13)),
               Text("${performanceAdjustment >= 0 ? '+' : ''}ETB ${performanceAdjustment.abs().toStringAsFixed(0)}", 
                 style: TextStyle(color: noteColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          // Total Payout Row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Org Net Profit", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    Text("ETB ${platformNetProfit.toStringAsFixed(0)}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.blueGrey)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Final Rider Payout", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                    Text("ETB ${finalRiderPayout.toStringAsFixed(0)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (delivery.riderPaid)
             Container(
               width: double.infinity,
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
               child: const Center(child: Text("PAID TO RIDER", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, letterSpacing: 2))),
             )
          else
            CustomButton(
              text: "Pay Rider",
              backgroundColor: AppColors.primary,
              onPressed: () async {
                 if (await showConfirmationDialog(context, "Pay Rider", "Confirm payout of ETB ${finalRiderPayout.toStringAsFixed(0)}?")) {
                    await DeliveryService().payRider(delivery.id, finalRiderPayout);
                 }
              },
            )
        ],
      ),
    );
  }

  String _formatTime(DateTime t) {
    return "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
  }

  void _showEditPriceDialog(BuildContext context, Delivery delivery) {
    final controller = TextEditingController(text: delivery.price.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Update Price"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "New Price (ETB)"),
        ),
        actions: [
           TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
           ElevatedButton(
             onPressed: () async {
               final double? newPrice = double.tryParse(controller.text);
               if (newPrice != null) {
                 // Confirmation for price update? User didn't ask explicitly but good practice.
                 // "update delivery price is not interactive or fast update" -> Updating stream fixes interactive part.
                 Navigator.pop(context); // Close dialog first
                 await DeliveryService().updateDeliveryPrice(delivery.id, newPrice);
               }
             },
             child: const Text("Update"),
           )
        ],
      ),
    );
  }
}
