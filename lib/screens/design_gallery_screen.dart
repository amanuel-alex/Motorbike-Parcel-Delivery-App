import 'package:flutter/material.dart';
import 'login/phone_number_login_screen.dart';
import 'login/otp_verification_screen.dart';
import 'login/role_selection_screen.dart';
import 'customer/customer_home_screen.dart';
import 'customer/create_delivery_screen.dart';
import 'customer/delivery_details_form.dart';
import 'customer/my_deliveries_screen.dart';
import 'rider/available_jobs_screen.dart';
import 'rider/job_details_screen.dart';
import 'rider/earnings_dashboard_screen.dart';
import 'rider/rider_profile_screen.dart';
import 'rider/confirm_delivery_screen.dart';
import 'rider/confirm_pickup_screen.dart';
import 'payment/payment_instructions_screen.dart';

class DesignGalleryScreen extends StatelessWidget {
  const DesignGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zipp&Go Design System'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildCategory(context, 'Authentication', [
            _buildItem(
              context,
              'Phone Number Login',
              const PhoneNumberLoginScreen(),
              Icons.phone_android,
            ),
            _buildItem(
              context,
              'OTP Verification',
              const OtpVerificationScreen(
                verificationId: 'mock-id',
                phoneNumber: '+234 812 345 6789',
              ),
              Icons.password,
            ),
            _buildItem(
              context,
              'Role Selection',
              const RoleSelectionScreen(),
              Icons.person_pin_circle_outlined,
            ),
          ]),
          _buildCategory(context, 'Customer Flow', [
            _buildItem(
              context,
              'Home Dashboard',
              const CustomerHomeScreen(),
              Icons.dashboard,
            ),
            _buildItem(
              context,
              'Quick Delivery Step 1',
              const CreateDeliveryScreen(),
              Icons.add_location,
            ),
            _buildItem(
              context,
              'Delivery Details Form',
              const DeliveryDetailsForm(),
              Icons.assignment,
            ),
            _buildItem(
              context,
              'My Deliveries List',
              const MyDeliveriesScreen(),
              Icons.list_alt,
            ),
          ]),
          _buildCategory(context, 'Rider Flow', [
            _buildItem(
              context,
              'Available Jobs',
              const AvailableJobsScreen(),
              Icons.moped,
            ),
            _buildItem(
              context,
              'Job Details (Acceptance)',
              const JobDetailsScreen(deliveryId: 'MOCK-123'),
              Icons.info_outline,
            ),
            _buildItem(
              context,
              'Earnings Dashboard',
              const EarningsDashboardScreen(),
              Icons.payments,
            ),
            _buildItem(
              context,
              'Rider Profile & Vehicle',
              const RiderProfileScreen(),
              Icons.person,
            ),
            _buildItem(
              context,
              'Confirm Pickup',
              const ConfirmPickupScreen(orderId: 'MOCK-123', customerName: 'John Doe'),
              Icons.inventory,
            ),
            _buildItem(
              context,
              'Confirm Delivery (Proof)',
              const ConfirmDeliveryScreen(orderId: 'MOCK-123', customerName: 'John Doe'),
              Icons.camera_alt,
            ),
          ]),
          _buildCategory(context, 'Payments', [
            _buildItem(
              context,
              'Payment Instructions',
              const PaymentInstructionsScreen(),
              Icons.payment,
            ),
          ]),
          // Add more categories as we implement more screens
        ],
      ),
    );
  }

  Widget _buildCategory(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ),
        ...items,
        const Divider(height: 40),
      ],
    );
  }

  Widget _buildItem(BuildContext context, String title, Widget target, IconData icon) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => target),
          );
        },
      ),
    );
  }
}
