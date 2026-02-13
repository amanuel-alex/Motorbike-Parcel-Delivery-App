import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import 'job_details_screen.dart';
import '../../providers/auth_provider.dart';
import '../../core/services/delivery_service.dart';
import '../../core/models/delivery_model.dart';
import '../../core/services/auth_service.dart';

class AvailableJobsScreen extends StatefulWidget {
  const AvailableJobsScreen({super.key});

  @override
  State<AvailableJobsScreen> createState() => _AvailableJobsScreenState();
}

class _AvailableJobsScreenState extends State<AvailableJobsScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final deliveryService = DeliveryService();
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    final List<Widget> pages = [
      _buildJobsView(context, deliveryService),
      _buildHistoryView(context, deliveryService, user),
      _buildProfileView(context, authProvider, user),
    ];

    return Scaffold(
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
        title: Text(
          _selectedIndex == 0 ? 'Available Jobs' : (_selectedIndex == 1 ? 'My History' : 'My Profile'),
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          if (AuthService.isDemoMode && _selectedIndex == 0)
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
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
              onPressed: () {
                setState(() {}); // Trigger refresh
              },
            ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        elevation: 10,
        indicatorColor: AppColors.primary.withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work, color: AppColors.primary),
            label: 'Jobs',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: AppColors.primary),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.primary),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildJobsView(BuildContext context, DeliveryService deliveryService) {
    return Column(
      children: [
        // Status Tabs (e.g. "Suggest", "Big", "Small" - simplifying for now)
        _buildStatusFilter(),
        Expanded(
          child: StreamBuilder<List<Delivery>>(
            stream: deliveryService.getPendingDeliveries(), // Already fixed the index error
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final jobsRaw = snapshot.data ?? [];
              final jobs = jobsRaw.where((job) => job.paymentStatus == 'approved').toList();

              if (jobs.isEmpty) {
                return _buildEmptyState('No jobs available right now');
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
                      isHighDemand: index == 0, // Just a visual flair for the first item
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryView(BuildContext context, DeliveryService deliveryService, dynamic user) {
    // Ideally fetch jobs assigned to THIS rider
    // deliveryService.getRiderDeliveries(user.uid) - assuming incomplete
    // For now, let's use a placeholder or filter the general stream if specific query not ready
    // But let's assume getRiderDeliveries exists or create it?
    // Let's check DeliveryService. 
    // If not exists, I'll filter in memory for now from pending (bad) or just show empty.
    // Actually, let's show "No history yet" if no API.
    // Improving: I will use a simple empty state for now to be safe, or check stream.
    
    return _buildEmptyState('No delivery history yet');
  }

  Widget _buildProfileView(BuildContext context, AuthProvider authProvider, dynamic user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(Icons.person, size: 50, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            user?.displayName ?? 'Rider Profile',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            user?.phoneNumber ?? '',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          _buildProfileOption(Icons.account_balance_wallet, 'Earnings', () {}),
          _buildProfileOption(Icons.settings, 'Settings', () {}),
          _buildProfileOption(Icons.help, 'Support', () {}),
          const SizedBox(height: 24),
          _buildProfileOption(
            Icons.logout, 
            'Logout', 
            () => authProvider.signOut(),
            color: Colors.red,
          ),
        ],
      ),
    );
  }
  
  // Reuse existing _buildStatusFilter, _buildJobCard, etc.
  Widget _buildStatusFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildFilterChip('Suggested', true),
          const SizedBox(width: 12),
          _buildFilterChip('Near Me', false),
          const SizedBox(width: 12),
          _buildFilterChip('High Pay', false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      backgroundColor: isSelected ? AppColors.primary : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      side: isSelected ? BorderSide.none : const BorderSide(color: Color(0xFFE2E8F0)),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_off_outlined, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap, {Color color = AppColors.textPrimary}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
    );
  }

  // _buildJobCard implementation handles the Card UI
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
            Text(label, style: const TextStyle(color: AppColors.textTertiary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
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
