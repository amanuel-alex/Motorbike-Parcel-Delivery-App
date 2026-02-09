import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../payment/payment_instructions_screen.dart';

class DeliveryDetailsForm extends StatefulWidget {
  const DeliveryDetailsForm({super.key});

  @override
  State<DeliveryDetailsForm> createState() => _DeliveryDetailsFormState();
}

class _DeliveryDetailsFormState extends State<DeliveryDetailsForm> {
  String? selectedPickupZone;
  String? selectedDropZone;
  double? estimatedPrice;
  bool isRouteAvailable = true;

  final Map<String, Map<String, double>> zonePrices = {
    'Bole': {'Arada': 150.0, 'Kirkos': 120.0, 'Yeka': 180.0},
    'Arada': {'Bole': 155.0, 'Kirkos': 100.0, 'Yeka': 130.0},
    'Kirkos': {'Bole': 110.0, 'Arada': 95.0, 'Yeka': 160.0},
  };

  void _calculatePrice() {
    if (selectedPickupZone != null && selectedDropZone != null) {
      if (selectedPickupZone == selectedDropZone) {
        setState(() {
          estimatedPrice = 80.0; // Same zone delivery
          isRouteAvailable = true;
        });
      } else {
        final price = zonePrices[selectedPickupZone]?[selectedDropZone];
        setState(() {
          estimatedPrice = price;
          isRouteAvailable = price != null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text(
              'Create Delivery',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            ),
            Text(
              'Step 1 of 2',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Where should we pick up and deliver?',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            
            _buildZoneSelector(
              'Pickup Zone',
              selectedPickupZone ?? 'Select pickup location',
              Icons.location_on,
              AppColors.primary,
              onTap: () => _showZonePicker(true),
            ),
            const SizedBox(height: 24),
            _buildZoneSelector(
              'Drop Zone',
              selectedDropZone ?? 'Select destination location',
              Icons.local_shipping,
              Colors.orange,
              onTap: () => _showZonePicker(false),
            ),
            
            const SizedBox(height: 40),
            
            if (!isRouteAvailable) 
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.error),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.error_outline, color: AppColors.error),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Route not available. Please choose a different zone.',
                        style: TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              )
            else if (estimatedPrice != null)
              _buildPriceCard()
            else
              _buildPlaceholderCard(),

            const Spacer(),
            CustomButton(
              text: 'Continue to Payment',
              onPressed: (isRouteAvailable && estimatedPrice != null) 
                ? () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PaymentInstructionsScreen()),
                  )
                : null, // Disabled if no route or price
              icon: Icons.arrow_forward,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF48C25), Color(0xFFD3761B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
           Text(
            'ESTIMATED TOTAL',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 4),
                child: Text(
                  'ETB',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                estimatedPrice!.toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Standard delivery (45-60 min)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.border, style: BorderStyle.none),
        boxShadow: AppColors.subtleShadow,
      ),
      child: Column(
        children: [
          Icon(Icons.calculate_outlined, size: 48, color: AppColors.textTertiary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Select zones to see pricing',
            style: TextStyle(color: AppColors.textTertiary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneSelector(
    String label,
    String value,
    IconData icon,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: value.contains('Select') ? AppColors.textTertiary : AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: AppColors.textTertiary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showZonePicker(bool isPickup) {
    final zones = ['Bole', 'Arada', 'Kirkos', 'Yeka', 'Kolfe'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Zone',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: zones.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(zones[index]),
                      onTap: () {
                        setState(() {
                          if (isPickup) {
                            selectedPickupZone = zones[index];
                          } else {
                            selectedDropZone = zones[index];
                          }
                          _calculatePrice();
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
