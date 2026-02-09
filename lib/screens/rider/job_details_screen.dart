import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import 'confirm_pickup_screen.dart';
import '../../core/services/delivery_service.dart';
import '../../core/models/delivery_model.dart';
import '../../providers/auth_provider.dart';

class JobDetailsScreen extends StatefulWidget {
  final String deliveryId;

  const JobDetailsScreen({super.key, required this.deliveryId});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final DeliveryService _deliveryService = DeliveryService();
  bool _isAccepting = false;

  Future<void> _handleAcceptJob(Delivery delivery) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    setState(() => _isAccepting = true);

    try {
      final success = await _deliveryService.acceptJob(
        widget.deliveryId, 
        authProvider.user?.uid ?? 'unknown_rider',
        authProvider.user?.phoneNumber ?? 'N/A',
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job accepted successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmPickupScreen(
              orderId: widget.deliveryId,
              customerName: delivery.customerPhone ?? 'Customer',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job already taken by another rider.'), backgroundColor: Colors.red),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isAccepting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Job Details',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Delivery>>(
        // Filtering in stream is better for reactive UI
        stream: _deliveryService.getPendingDeliveries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final delivery = snapshot.data?.firstWhere((d) => d.id == widget.deliveryId, 
              orElse: () => throw Exception('Job no longer available'));

          if (delivery == null) {
            return const Center(child: Text('Job no longer available'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: SafeNetworkImage(
                    imageUrl: 'https://api.placeholder.com/400/200?text=Live+Route+Map',
                    height: 200,
                    width: double.infinity,
                    borderRadius: 24,
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Locations
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: AppColors.subtleShadow,
                        ),
                        child: Column(
                          children: [
                            _buildLocationItem(
                              label: 'PICKUP',
                              title: delivery.pickupZoneName ?? 'Unknown',
                              subtitle: delivery.pickupAddress,
                              icon: Icons.circle,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 20),
                            _buildLocationItem(
                              label: 'DROP-OFF',
                              title: delivery.dropZoneName ?? 'Unknown',
                              subtitle: delivery.dropoffAddress,
                              icon: Icons.radio_button_unchecked,
                              color: Colors.orange,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Earnings
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: AppColors.subtleShadow,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total Earnings', style: TextStyle(color: AppColors.textSecondary)),
                                const SizedBox(height: 8),
                                Text(
                                  'ETB ${delivery.price.toStringAsFixed(0)}',
                                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                              ],
                            ),
                            const Icon(Icons.payments_outlined, color: AppColors.primary, size: 40),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      _isAccepting 
                        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                        : CustomButton(
                            text: 'Accept Job',
                            onPressed: () => _handleAcceptJob(delivery),
                            icon: Icons.check_circle_outline,
                          ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildLocationItem({
    required String label,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textTertiary)),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(subtitle, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}
