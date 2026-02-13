import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/services/delivery_service.dart';
import '../../core/models/delivery_model.dart';
import '../../core/utils/error_handler.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../payment/payment_instructions_screen.dart';

class CreateDeliveryScreen extends StatefulWidget {
  const CreateDeliveryScreen({super.key});

  @override
  State<CreateDeliveryScreen> createState() => _CreateDeliveryScreenState();
}

class _CreateDeliveryScreenState extends State<CreateDeliveryScreen> {
  final DeliveryService _deliveryService = DeliveryService();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _pickupDetailController = TextEditingController();
  final TextEditingController _dropDetailController = TextEditingController();
  final TextEditingController _receiverPhoneController = TextEditingController();

  String? selectedPickupZone;
  String? selectedDropZone;
  String selectedPackageType = 'Document';
  double? estimatedPrice;
  
  bool _isCalculating = false;
  bool _isSubmitting = false;
  bool _isRouteAvailable = true;
  List<String> _zones = AppConstants.availableZones;

  @override
  void initState() {
    super.initState();
    _fetchZones();
  }

  Future<void> _fetchZones() async {
    final fetchedZones = await _deliveryService.getZones();
    if (fetchedZones.isNotEmpty && mounted) {
      setState(() {
        _zones = fetchedZones;
      });
    }
  }

  Future<void> _calculatePrice() async {
    if (selectedPickupZone != null && selectedDropZone != null) {
      setState(() => _isCalculating = true);
      try {
        if (selectedPickupZone == selectedDropZone) {
          setState(() {
            estimatedPrice = AppConstants.baseSameZonePrice;
            _isRouteAvailable = true;
          });
        } else {
          final price = await _deliveryService.getEstimatedPrice(selectedPickupZone!, selectedDropZone!);
          if (price != null) {
            setState(() {
              estimatedPrice = price;
              _isRouteAvailable = true;
            });
          } else {
            // Fallback
            final localPrice = AppConstants.zonePrices[selectedPickupZone]?[selectedDropZone];
            setState(() {
              estimatedPrice = localPrice;
              _isRouteAvailable = localPrice != null;
            });
          }
        }
      } finally {
        if (mounted) setState(() => _isCalculating = false);
      }
    }
  }

  Future<void> _handleCreateRequest() async {
    if (selectedPickupZone == null || selectedDropZone == null || estimatedPrice == null) return;
    if (_pickupDetailController.text.trim().isEmpty || _dropDetailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter specific address details')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _isSubmitting = true);

    try {
      final pickupFull = '${_pickupDetailController.text.trim()}, $selectedPickupZone';
      final dropFull = '${_dropDetailController.text.trim()}, $selectedDropZone';
      
      // If receiver phone is provided, append to notes
      String notes = _notesController.text.trim();
      if (_receiverPhoneController.text.isNotEmpty) {
        notes += '\nReceiver Phone: ${_receiverPhoneController.text.trim()}';
      }

      final delivery = Delivery(
        id: '',
        customerId: authProvider.user?.uid ?? 'anonymous',
        customerPhone: authProvider.user?.phoneNumber ?? 'N/A',
        pickupAddress: pickupFull,
        dropoffAddress: dropFull,
        pickupZoneName: selectedPickupZone,
        dropZoneName: selectedDropZone,
        status: 'pending',
        price: estimatedPrice!,
        packageType: selectedPackageType,
        createdAt: DateTime.now(),
      );

      final String deliveryId = await _deliveryService.createDelivery(delivery);
      
      if (!mounted) return;
      
      // Navigate to Payment instructions as required
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentInstructionsScreen(
            deliveryId: deliveryId,
            amount: estimatedPrice!,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'RETRY',
              textColor: Colors.white,
              onPressed: _handleCreateRequest,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book a Moped',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Zone Selection Section
              _buildSectionTitle('Pickup Location'),
              const SizedBox(height: 12),
              _buildZoneDropdown(
                label: 'PICKUP ZONE',
                value: selectedPickupZone,
                icon: Icons.map,
                iconColor: AppColors.primary,
                onChanged: (val) {
                  setState(() => selectedPickupZone = val);
                  _calculatePrice();
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(_pickupDetailController, 'Building, Street Name, Landmark...'),
              
              const SizedBox(height: 24),
              
              _buildSectionTitle('Drop-off Location'),
              const SizedBox(height: 12),
               _buildZoneDropdown(
                label: 'DROP-OFF ZONE',
                value: selectedDropZone,
                icon: Icons.map,
                iconColor: Colors.redAccent,
                onChanged: (val) {
                  setState(() => selectedDropZone = val);
                  _calculatePrice();
                },
              ),
              const SizedBox(height: 12),
              _buildTextField(_dropDetailController, 'Building, Street Name, Landmark...'),

              const SizedBox(height: 24),

              _buildSectionTitle('Receiver Info (Optional)'),
              const SizedBox(height: 12),
              _buildTextField(_receiverPhoneController, 'Receiver Phone Number', icon: Icons.phone),
              
              const SizedBox(height: 32),
              
              // Package Info Selection
              _buildSectionTitle('Package Information'),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildPackageChip('Document', Icons.description_outlined),
                    const SizedBox(width: 12),
                    _buildPackageChip('Small Box', Icons.inventory_2_outlined),
                    const SizedBox(width: 12),
                    _buildPackageChip('Food', Icons.restaurant_outlined),
                    const SizedBox(width: 12),
                    _buildPackageChip('Medical', Icons.medical_services_outlined),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              _buildSectionTitle('Delivery Notes'),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Any special instructions for the rider...',
                  fillColor: const Color(0xFFF8FAFC),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),

              const SizedBox(height: 32),
              
              // Pricing Result
              if (!_isRouteAvailable)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.error_outline, color: AppColors.error),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text('Service currently unavailable for this route.', 
                          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                )
              else if (estimatedPrice != null)
                _buildPriceCard()
              else
                _buildIntroCard(),

              const SizedBox(height: 40),
              
              _isSubmitting
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : CustomButton(
                    text: 'Confirm & Request Delivery',
                    onPressed: (estimatedPrice != null && _isRouteAvailable) ? _handleCreateRequest : null,
                    icon: Icons.bolt,
                  ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {IconData? icon}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, color: AppColors.textTertiary) : null,
        fillColor: const Color(0xFFF8FAFC),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildZoneDropdown({
    required String label,
    required String? value,
    required IconData icon,
    required Color iconColor,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                hint: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textTertiary)),
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textTertiary),
                items: _zones.map((zone) {
                  return DropdownMenuItem(value: zone, child: Text(zone, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)));
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageChip(String title, IconData icon) {
    bool isSelected = selectedPackageType == title;
    return GestureDetector(
      onTap: () => setState(() => selectedPackageType = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        children: [
          const Text('GUARANTEED LOWEST PRICE', 
            style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          _isCalculating 
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('ETB', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 6),
                  Text(estimatedPrice!.toStringAsFixed(0), 
                    style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900)),
                ],
              ),
        ],
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        children: [
          Icon(Icons.moped, size: 48, color: AppColors.textTertiary),
          SizedBox(height: 12),
          Text('Select pickup and destination zones followed by specific address details.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
