import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';

class MyDeliveriesScreen extends StatelessWidget {
  const MyDeliveriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'My Deliveries',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.tune, color: AppColors.textPrimary),
              onPressed: () {},
            ),
          ],
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDeliveriesList(),
            _buildDeliveriesList(filter: 'active'),
            _buildDeliveriesList(filter: 'completed'),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  Widget _buildDeliveriesList({String? filter}) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildDeliveryCard(
          orderId: 'ZG-9821',
          date: 'TODAY',
          status: 'PENDING',
          statusColor: AppColors.pending,
          price: '\$14.50',
          pickup: 'Downtown Hub',
          dropoff: '123 Maple St, North Wing',
          actionLabel: 'Track Order',
          actionIcon: Icons.near_me,
        ),
        const SizedBox(height: 20),
        _buildDeliveryCard(
          orderId: 'ZG-7742',
          date: 'YESTERDAY',
          status: 'COMPLETED',
          statusColor: AppColors.delivered,
          price: '\$22.00',
          pickup: 'West End Plaza',
          dropoff: 'Sunset Blvd, Apt 4B',
          isCompleted: true,
        ),
        const SizedBox(height: 20),
        _buildDeliveryCard(
          orderId: 'ZG-1209',
          date: 'TODAY',
          status: 'IN TRANSIT',
          statusColor: AppColors.inProgress,
          price: '\$9.80',
          pickup: 'North Plaza Market',
          dropoff: 'Oak Road, Business Park',
          actionLabel: 'Live Track',
          actionIcon: Icons.local_shipping,
        ),
      ],
    );
  }

  Widget _buildDeliveryCard({
    required String orderId,
    required String date,
    required String status,
    required Color statusColor,
    required String price,
    required String pickup,
    required String dropoff,
    String? actionLabel,
    IconData? actionIcon,
    bool isCompleted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.subtleShadow,
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
                    'ORDER ID: #$orderId • $date',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      StatusBadge(
                        label: status,
                        color: statusColor,
                        icon: isCompleted ? Icons.check_circle : Icons.sensors,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SafeNetworkImage(
                imageUrl: 'https://api.placeholder.com/100/100?text=Map',
                height: 50,
                width: 50,
                borderRadius: 12,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildLocationPoint(Icons.radio_button_checked, AppColors.primary, 'Pickup', pickup),
          const Padding(
            padding: EdgeInsets.only(left: 11),
            child: SizedBox(height: 10, child: VerticalDivider(color: AppColors.border, thickness: 1.5)),
          ),
          _buildLocationPoint(Icons.location_on, Colors.orange, 'Drop-off', dropoff),
          const SizedBox(height: 24),
          if (isCompleted)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.receipt_long, size: 18),
                    label: const Text('Receipt'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.history, size: 18),
                    label: const Text('Reorder'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            )
          else if (actionLabel != null)
            CustomButton(
              text: actionLabel,
              onPressed: () {},
              icon: actionIcon,
            ),
        ],
      ),
    );
  }

  Widget _buildLocationPoint(IconData icon, Color color, String type, String addr) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              type,
              style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
            ),
            Text(
              addr,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      height: 80,
      elevation: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, 'Home', false),
          _buildNavItem(Icons.inventory_2, 'Deliveries', true),
          const SizedBox(width: 40),
          _buildNavItem(Icons.account_balance_wallet_outlined, 'Wallet', false),
          _buildNavItem(Icons.person_outline, 'Profile', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? AppColors.primary : AppColors.textTertiary),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.primary : AppColors.textTertiary,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
