import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import 'confirm_delivery_screen.dart';
import 'earnings_dashboard_screen.dart';
import 'available_jobs_screen.dart';
import 'confirm_pickup_screen.dart';
import 'job_details_screen.dart';
import '../../providers/auth_provider.dart';

class AvailableJobsScreen extends StatelessWidget {
  const AvailableJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            _buildJobsList(context),
            _buildJobsList(context),
            _buildJobsList(context),
          ],
        ),
        bottomNavigationBar: _buildRiderBottomNav(),
      ),
    );
  }

  Widget _buildJobsList(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildJobCard(
          context,
          pickup: 'Downtown Hub - Warehouse B',
          dropoff: '452 Oak Avenue, Penthouse 4',
          price: '\$14.50',
          distance: '5.2 km',
          time: '15 min',
          showMap: true,
        ),
        const SizedBox(height: 20),
        _buildJobCard(
          context,
          pickup: 'Sushi Zen - Midtown',
          dropoff: 'Westside Residences',
          price: '\$9.25',
          distance: '2.8 km',
          time: '8 min',
        ),
        const SizedBox(height: 20),
        _buildJobCard(
          context,
          pickup: 'The Wine Shop - Hillside',
          dropoff: 'North Point Estates',
          price: '\$22.80',
          distance: '11.4 km',
          time: '24 min',
          isHighDemand: true,
        ),
        const SizedBox(height: 20),
        _buildJobCard(
          context,
          pickup: 'Green Grocery Express',
          dropoff: 'South Station Plaza',
          price: '\$10.00',
          distance: '4.1 km',
          time: '12 min',
        ),
      ],
    );
  }

  Widget _buildJobCard(
    BuildContext context, {
    required String pickup,
    required String dropoff,
    required String price,
    required String distance,
    required String time,
    bool showMap = false,
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
                    '$distance • $time',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                  ),
                ),
                if (showMap) ...[
                  const SizedBox(height: 16),
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: NetworkImage('https://api.placeholder.com/400/120?text=Job+Map'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                CustomButton(
                  text: 'ACCEPT JOB',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const JobDetailsScreen()),
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
}
