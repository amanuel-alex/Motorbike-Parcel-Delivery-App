import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';

import 'confirm_delivery_screen.dart';

class ConfirmPickupScreen extends StatelessWidget {
  final String? orderId;
  final String? customerName;

  const ConfirmPickupScreen({super.key, this.orderId, this.customerName});

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
          'Confirm Pickup',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Order Info Header
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.subtleShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ORDER ID',
                        style: TextStyle(fontSize: 10, color: AppColors.textTertiary, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        orderId ?? '#ZG-88214-X',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text(
                        'ITEMS',
                        style: TextStyle(fontSize: 10, color: AppColors.textTertiary, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '2 Parcels',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Proof of Pickup',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Please take a clear photo of the parcel at the pickup location to proceed. Ensure labels are visible.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  
                  // Empty Photo State / Camera Mock
                  Container(
                    height: 400,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF9F2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: AppColors.primary, size: 48),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No photo captured',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the button below to open your camera',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.textTertiary, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Photo required for automated verification system.',
                        style: TextStyle(color: AppColors.textTertiary, fontSize: 11, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Pickup Photo'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      side: const BorderSide(color: AppColors.primary, width: 2),
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  CustomButton(
                    text: 'Confirm Pickup',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ConfirmDeliveryScreen()),
                      );
                    },
                    icon: Icons.check_circle_outline,
                    // Disabled state simulation if needed, but for UI demo we leave it active
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'By confirming, you agree that you have the package in your possession.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
