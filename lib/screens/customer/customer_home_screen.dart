import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../providers/auth_provider.dart';
import '../../core/services/delivery_service.dart';
import '../../core/models/delivery_model.dart';
import '../../core/services/auth_service.dart';
import 'create_delivery_screen.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final deliveryService = DeliveryService();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Premium Header with User Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 32),
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (AuthService.isDemoMode)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: ActionChip(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        label: const Text('DEMO: SWITCH TO RIDER', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        onPressed: () => Provider.of<AuthProvider>(context, listen: false).setRole('rider'),
                        avatar: const Icon(Icons.moped, color: Colors.white, size: 14),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HELLO,',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            user?.phoneNumber ?? 'Valued Customer',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: () => authProvider.signOut(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Hero Banner
                  Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/f-de.webp'),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Send Packages\nAnywhere, Anytime',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 120,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const CreateDeliveryScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 0),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Book Now', style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quick Actions Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildServiceCard(
                          context, 
                          'Send Parcel', 
                          Icons.local_shipping_outlined, 
                          AppColors.primary,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CreateDeliveryScreen()),
                          )
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildServiceCard(
                          context, 
                          'Track Order', 
                          Icons.location_searching, 
                          Colors.blue,
                          () {} // TODO: Implement Tracking Screen
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Live Deliveries Stream
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Deliveries',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('See All', style: TextStyle(color: AppColors.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<List<Delivery>>(
                    stream: deliveryService.getCustomerDeliveries(user?.uid ?? ''),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                      }

                      final deliveries = snapshot.data ?? [];

                      if (deliveries.isEmpty) {
                        return _buildEmptyState();
                      }

                      return Column(
                        children: deliveries.map((d) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildDeliveryCard(d),
                        )).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateDeliveryScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.textTertiary.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text('No deliveries yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Text('Create your first delivery above!', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(Delivery d) {
    Color statusColor;
    IconData statusIcon;

    switch (d.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.timer_outlined;
        break;
      case 'accepted':
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'picked':
        statusColor = Colors.purple;
        statusIcon = Icons.moped;
        break;
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.verified;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.subtleShadow,
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(statusIcon, color: statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.status.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1)),
                  Text(d.packageType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  if (d.paymentStatus != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getPaymentStatusColor(d.paymentStatus!).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Payment: ${d.paymentStatus!.toUpperCase()}',
                          style: TextStyle(
                            color: _getPaymentStatusColor(d.paymentStatus!),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text('ETB ${d.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          const Divider(height: 32),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 8),
              Expanded(child: Text('${d.pickupZoneName} → ${d.dropZoneName}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12))),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildServiceCard(
    BuildContext context, 
    String title, 
    IconData icon, 
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
