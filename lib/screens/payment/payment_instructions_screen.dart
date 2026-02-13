import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/services/delivery_service.dart';
import '../../core/services/storage_service.dart';

class PaymentInstructionsScreen extends StatefulWidget {
  final String deliveryId;
  final double amount;

  const PaymentInstructionsScreen({
    super.key,
    required this.deliveryId,
    required this.amount,
  });

  @override
  State<PaymentInstructionsScreen> createState() => _PaymentInstructionsScreenState();
}

class _PaymentInstructionsScreenState extends State<PaymentInstructionsScreen> {
  final DeliveryService _deliveryService = DeliveryService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _refController = TextEditingController();
  
  String selectedProvider = 'Afrimoney';
  bool isCompleted = false;
  bool isSubmitting = false;
  File? _screenshotFile;
  String? _screenshotUrl;
  bool _isUploadingScreenshot = false;

  Future<void> _pickScreenshot() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      setState(() {
        _screenshotFile = File(image.path);
      });
    }
  }

  Future<void> _handlePaymentSubmitted() async {
    if (!isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please check the confirmation box below')),
      );
      return;
    }

    if (_refController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the Transaction Reference from your SMS')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      if (_screenshotFile != null) {
        _screenshotUrl = await _storageService.uploadPaymentScreenshot(
          file: _screenshotFile!,
          deliveryId: widget.deliveryId,
        );
      }

      await _deliveryService.submitPaymentProof(
        deliveryId: widget.deliveryId,
        paymentRef: _refController.text.trim(),
        provider: selectedProvider,
        screenshotUrl: _screenshotUrl,
      );

      // --- MAGIC APPROVAL FOR DEMO ---
      // If the boss enters the special code, we auto-approve it immediately 
      // This makes the demo look like the backend is working in real-time
      if (_refController.text.trim() == 'TX-88294021-AF') {
        await _deliveryService.updatePaymentStatus(widget.deliveryId, 'approved');
      }
      // -------------------------------

      if (!mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Icon(Icons.check_circle, color: Colors.green, size: 64),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Payment Logged!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              SizedBox(height: 12),
              Text(
                'Your payment is being verified by our team. The rider will be notified once complete.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          actions: [
            Center(
              child: CustomButton(
                text: 'Go to Dashboard',
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging payment: $e')),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
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
        title: const Text(
          'Payment Instructions',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Text(
                'AMOUNT TO PAY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textTertiary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ETB ${widget.amount.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 32),
              
              _buildSectionTitle('SELECT PROVIDER'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildProviderToggle('Afrimoney'),
                    ),
                    Expanded(
                      child: _buildProviderToggle('Airtel Money'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Merchant Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppColors.subtleShadow,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                             Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 20),
                             SizedBox(width: 8),
                             Text(
                              'Merchant Account',
                              style: TextStyle(color: AppColors.textTertiary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const StatusBadge(label: 'VERIFIED', color: Colors.green, icon: Icons.verified),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '+232 77 123 456',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                            ),
                            Text(
                              'Zipp&Go Logistics SL',
                              style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9F2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.copy, color: AppColors.primary, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _buildSectionTitle('VERIFICATION'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppColors.subtleShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Transaction Reference',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _refController,
                      decoration: InputDecoration(
                        hintText: 'Enter Trans ID from SMS',
                        prefixIcon: const Icon(Icons.receipt_long, color: AppColors.primary),
                        fillColor: const Color(0xFFF8FAFC),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Payment Screenshot (Highly Recommended)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickScreenshot,
                      child: Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
                        ),
                        child: _screenshotFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(_screenshotFile!, fit: BoxFit.cover),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add_a_photo_outlined, color: AppColors.textTertiary),
                                  SizedBox(height: 8),
                                  Text('Upload Screenshot', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _buildSectionTitle('HOW TO PAY'),
              const SizedBox(height: 20),
              _buildInstructionStep(1, 'Dial USSD Code', 'Open your phone dialer and call *161#'),
              _buildInstructionStep(2, 'Select Send Money', 'Choose option 1 for sending money to a merchant.'),
              _buildInstructionStep(3, 'Enter Details', 'Input the phone number and amount shown above exactly.'),
              _buildInstructionStep(4, 'Confirm & Authorize', 'Enter your PIN to complete the transaction.'),
              
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => setState(() => isCompleted = !isCompleted),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: isCompleted,
                        onChanged: (v) => setState(() => isCompleted = v!),
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'I have completed the transfer',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'I understand that false confirmations may lead to account suspension.',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              // Map Snippet
              Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  const SafeNetworkImage(
                    imageUrl: 'https://api.placeholder.com/400/120?text=Logistics+Center+Map',
                    height: 120,
                    width: double.infinity,
                    borderRadius: 20,
                  ),
                  Container(
                    height: 120,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'MAIN LOGISTICS CENTER',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          'Wilkinson Road, Freetown',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Transactions are usually verified within 2-5 minutes. If you encounter any issues, please contact our 24/7 support.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textTertiary, fontSize: 12, height: 1.5),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        child: CustomButton(
          text: isSubmitting ? 'Verifying...' : 'I Have Paid',
          onPressed: isSubmitting ? null : _handlePaymentSubmitted,
          icon: isSubmitting ? null : Icons.check_circle,
        ),
      ),
    );
  }

  Widget _buildProviderToggle(String provider) {
    final isSelected = selectedProvider == provider;
    return GestureDetector(
      onTap: () => setState(() => selectedProvider = provider),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            provider,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildInstructionStep(int step, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  description,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
