import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../providers/auth_provider.dart';
import '../../core/services/delivery_service.dart';
import '../../core/models/delivery_model.dart';
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
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Text(
                    'Need something\ndelivered today?',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Send a Parcel',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreateDeliveryScreen()),
                      );
                    },
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
}
