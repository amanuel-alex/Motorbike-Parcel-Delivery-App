import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/services/delivery_service.dart';
import '../../core/services/storage_service.dart';
import 'earnings_dashboard_screen.dart';

class ConfirmDeliveryScreen extends StatefulWidget {
  final String orderId;
  final String customerName;

  const ConfirmDeliveryScreen({
    super.key, 
    required this.orderId, 
    required this.customerName,
  });

  @override
  State<ConfirmDeliveryScreen> createState() => _ConfirmDeliveryScreenState();
}

class _ConfirmDeliveryScreenState extends State<ConfirmDeliveryScreen> {
  final DeliveryService _deliveryService = DeliveryService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  bool _isPhotoCaptured = false;
  bool _isUploading = false;
  String? _photoUrl;
  File? _imageFile;

  Future<void> _captureAndUploadPhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (photo == null) return;

      setState(() {
        _isUploading = true;
        _imageFile = File(photo.path);
      });

      final String downloadUrl = await _storageService.uploadDeliveryPhoto(
        file: _imageFile!,
        deliveryId: widget.orderId,
        type: 'dropoff',
      );

      if (mounted) {
        setState(() {
          _isPhotoCaptured = true;
          _isUploading = false;
          _photoUrl = downloadUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Delivery proof saved to storage!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  Future<void> _handleComplete() async {
    if (!_isPhotoCaptured) return;

    setState(() => _isUploading = true);

    try {
      await _deliveryService.confirmDelivery(widget.orderId, _photoUrl!);
      
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delivery completed successfully!'), backgroundColor: Colors.green),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const EarningsDashboardScreen()),
        (route) => false,
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
        title: const Text('Stage 2: Confirm Delivery', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppColors.subtleShadow,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('DROP-OFF TO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textTertiary)),
                          Text(widget.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Photo Preview
              _isPhotoCaptured 
                ? SafeNetworkImage(
                    imageUrl: _photoUrl!,
                    height: 350,
                    width: double.infinity,
                    borderRadius: 32,
                  )
                : Container(
                    height: 350,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.add_a_photo_outlined, color: AppColors.textTertiary, size: 60),
                    ),
                  ),

              const SizedBox(height: 32),

              _isUploading 
                ? const CircularProgressIndicator(color: AppColors.primary)
                : Column(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _captureAndUploadPhoto,
                        icon: const Icon(Icons.camera_alt),
                        label: Text(_isPhotoCaptured ? 'Retake Photo' : 'Capture Drop Photo'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          side: const BorderSide(color: AppColors.primary, width: 2),
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Mark as Completed',
                        onPressed: _isPhotoCaptured ? _handleComplete : null,
                        icon: Icons.check_circle_outline,
                      ),
                    ],
                  ),
              const SizedBox(height: 24),
              Text(
                'Professional status machine enforces photo proof.',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
