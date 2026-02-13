import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import 'job_details_screen.dart';
import '../../providers/auth_provider.dart';
import '../../core/services/delivery_service.dart';
import '../../core/models/delivery_model.dart';
import '../../core/services/auth_service.dart';

class AvailableJobsScreen extends StatelessWidget {
  const AvailableJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deliveryService = DeliveryService();
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF9F2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.menu, color: AppColors.primary),
          ),
          title: const Text(
            'Available Jobs',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          centerTitle: false,
          actions: [
            if (AuthService.isDemoMode)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Center(
                  child: ActionChip(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    label: const Text('DEMO: CUSTOMER', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                    onPressed: () => Provider.of<AuthProvider>(context, listen: false).setRole('customer'),
                    avatar: const Icon(Icons.person, color: AppColors.primary, size: 14),
                  ),
                ),
              ),
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.refresh, color: AppColors.textPrimary, size: 20),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: AppColors.textSecondary),
              onPressed: () => Provider.of<AuthProvider>(context, listen: false).signOut(),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'All Nearby'),
              Tab(text: 'High Earnings'),
              Tab(text: 'Short Trips'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildJobsList(context, deliveryService),
            _buildJobsList(context, deliveryService),
            _buildJobsList(context, deliveryService),
          ],
        ),
        bottomNavigationBar: _buildRiderBottomNav(),
      ),
    );
  }

  Widget _buildJobsList(BuildContext context, DeliveryService deliveryService) {
    return StreamBuilder<List<Delivery>>(
      stream: deliveryService.getPendingDeliveries(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final jobs = snapshot.data ?? [];

        if (jobs.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildJobCard(
                context,
                id: job.id,
                pickup: job.pickupAddress,
                dropoff: job.dropoffAddress,
                price: 'ETB ${job.price.toStringAsFixed(0)}',
                packageType: job.packageType,
                createdAt: job.createdAt,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.moped_outlined, size: 80, color: AppColors.textTertiary.withOpacity(0.2)),
          const SizedBox(height: 24),
          const Text(
            'No available jobs right now',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'New delivery requests will appear here.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(
    BuildContext context, {
    required String id,
    required String pickup,
    required String dropoff,
    required String price,
    required String packageType,
    required DateTime createdAt,
    bool isHighDemand = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.subtleShadow,
        border: isHighDemand ? Border.all(color: AppColors.primary, width: 2) : null,
      ),
      child: Column(
        children: [
          if (isHighDemand)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.whatshot, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'HIGH DEMAND',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLocationRow(Icons.radio_button_checked, AppColors.primary, 'PICKUP', pickup),
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: SizedBox(height: 10, child: VerticalDivider(color: AppColors.border)),
                          ),
                          _buildLocationRow(Icons.location_on, Colors.grey[600]!, 'DROP-OFF', dropoff),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDFBF5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        price,
                        style: const TextStyle(
                          color: AppColors.delivered,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$packageType • ${_getTimeAgo(createdAt)}',
                    style: const TextStyle(color: AppColors.textTertiary, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.05),
                        Colors.blue.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildRouteStep(Icons.my_location, 'Pickup', AppColors.primary),
                      Expanded(
                        child: Divider(
                          color: Colors.grey.withOpacity(0.3),
                          thickness: 1,
                          indent: 10,
                          endIndent: 10,
                        ),
                      ),
                      _buildRouteStep(Icons.flag, 'Dropoff', Colors.blue),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'ACCEPT JOB',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => JobDetailsScreen(deliveryId: id)),
                    );
                  },
                  icon: Icons.bolt,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, Color color, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textTertiary),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRiderBottomNav() {
    return BottomAppBar(
      height: 80,
      elevation: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.list_alt, 'JOBS', true),
          _buildNavItem(Icons.map_outlined, 'MAP', false),
          _buildNavItem(Icons.account_balance_wallet_outlined, 'EARNINGS', false),
          _buildNavItem(Icons.person_outline, 'PROFILE', false),
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
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }

  Widget _buildRouteStep(IconData icon, String label, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
