import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/services/delivery_service.dart';
import 'confirm_delivery_screen.dart';

class ConfirmPickupScreen extends StatefulWidget {
  final String orderId;
  final String customerName;

  const ConfirmPickupScreen({
    super.key, 
    required this.orderId, 
    required this.customerName,
  });

  @override
  State<ConfirmPickupScreen> createState() => _ConfirmPickupScreenState();
}

class _ConfirmPickupScreenState extends State<ConfirmPickupScreen> {
  final DeliveryService _deliveryService = DeliveryService();
  bool _isPhotoCaptured = false;
  bool _isUploading = false;
  String? _photoUrl;

  void _simulateCamera() {
    setState(() {
      _isUploading = true;
    });

    // Simulate upload delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isPhotoCaptured = true;
          _isUploading = false;
          _photoUrl = 'https://api.placeholder.com/400/600?text=Pickup+Proof';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo uploaded successfully!'), backgroundColor: Colors.green),
        );
      }
    });
  }

  Future<void> _handleConfirm() async {
    if (!_isPhotoCaptured) return;

    setState(() => _isUploading = true);

    try {
      await _deliveryService.confirmPickup(widget.orderId, _photoUrl!);
      
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmDeliveryScreen(
            orderId: widget.orderId,
            customerName: widget.customerName,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
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
        title: const Text('Stage 1: Confirm Pickup', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status Header
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Rider must upload pickup photo before proceeding.',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Photo Box
                  Container(
                    height: 350,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: _isPhotoCaptured ? AppColors.delivered : const Color(0xFFE2E8F0), width: 2),
                      image: _isPhotoCaptured ? DecorationImage(
                        image: NetworkImage(_photoUrl!),
                        fit: BoxFit.cover,
                      ) : null,
                    ),
                    child: !_isPhotoCaptured ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt, color: AppColors.textTertiary, size: 64),
                        const SizedBox(height: 16),
                        Text('No photo captured', style: TextStyle(color: AppColors.textTertiary, fontWeight: FontWeight.bold)),
                      ],
                    ) : null,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _isUploading 
                    ? const CircularProgressIndicator(color: AppColors.primary)
                    : Column(
                        children: [
                          OutlinedButton.icon(
                            onPressed: _simulateCamera,
                            icon: const Icon(Icons.camera_alt),
                            label: Text(_isPhotoCaptured ? 'Retake Photo' : 'Take Pickup Photo'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 56),
                              side: const BorderSide(color: AppColors.primary, width: 2),
                              foregroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: 'Confirm & Start Delivery',
                            onPressed: _isPhotoCaptured ? _handleConfirm : null,
                            icon: Icons.check_circle_outline,
                          ),
                        ],
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
