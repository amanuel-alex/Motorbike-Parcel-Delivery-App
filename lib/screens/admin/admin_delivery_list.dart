import 'package:flutter/material.dart';
import '../../core/services/delivery_service.dart';
import '../../core/models/delivery_model.dart';
import '../customer/delivery_details_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/widgets/common_widgets.dart';


class AdminDeliveryListScreen extends StatefulWidget {
  const AdminDeliveryListScreen({super.key});

  @override
  State<AdminDeliveryListScreen> createState() => _AdminDeliveryListScreenState();
}

class _AdminDeliveryListScreenState extends State<AdminDeliveryListScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final DeliveryService _deliveryService = DeliveryService();

  Future<void> _handleDeleteDelivery(BuildContext context, Delivery delivery) async {
    if (!await showConfirmationDialog(context, "Delete Delivery", "Are you sure you want to delete this delivery? This action can be undone immediately via the snackbar.")) {
      return;
    }
    
    final messenger = ScaffoldMessenger.of(context);
    
    // Immediate Delete
    await _deliveryService.deleteDelivery(delivery.id);

    messenger.showSnackBar(
      SnackBar(
        content: Text("${delivery.packageType} deleted"),
        action: SnackBarAction(
          label: "UNDO",
          onPressed: () async {
            // Restore: re-create the delivery with same ID and data
            await _deliveryService.restoreDelivery(delivery);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Deliveries', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const SizedBox.shrink(),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () => showLogoutDialog(context),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          // Filter & Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search package or ID...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'pending', 'accepted', 'picked', 'completed', 'canceled'].map((status) {
                      final isSelected = _selectedFilter == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(status.toUpperCase(), style: TextStyle(fontSize: 10, color: isSelected ? Colors.white : Colors.black)),
                          selected: isSelected,
                          selectedColor: _getStatusColor(status),
                          onSelected: (selected) {
                            setState(() => _selectedFilter = status);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: StreamBuilder<List<Delivery>>(
              stream: DeliveryService().getAllDeliveries(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                var deliveries = snapshot.data ?? [];
                
                // Filter by status
                if (_selectedFilter != 'All') {
                  deliveries = deliveries.where((d) => d.status == _selectedFilter).toList();
                }
                
                // Filter by search
                if (_searchQuery.isNotEmpty) {
                  deliveries = deliveries.where((d) => 
                    d.packageType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    d.id.toLowerCase().contains(_searchQuery.toLowerCase())
                  ).toList();
                }

                if (deliveries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.inbox, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("No matching deliveries found", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: deliveries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final delivery = deliveries[index];
                    return _buildAdminDeliveryCard(context, delivery);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminDeliveryCard(BuildContext context, Delivery delivery) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => DeliveryDetailsScreen(delivery: delivery))
          );
        },
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor(delivery.status).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(_getStatusIcon(delivery.status), color: _getStatusColor(delivery.status), size: 20),
        ),
        title: Row(
          children: [
            Text(delivery.packageType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Spacer(),
            Text('ETB ${delivery.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              onPressed: () => _handleDeleteDelivery(context, delivery),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(delivery.dropoffAddress, maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildChip(delivery.status.toUpperCase(), _getStatusColor(delivery.status)),
                if (delivery.paymentStatus != null) ...[
                 const SizedBox(width: 8),
                 _buildChip(
                   delivery.paymentStatus == 'pending' ? 'PAYMENT PENDING' : 'PAID',
                   delivery.paymentStatus == 'pending' ? Colors.orange : Colors.green,
                 ),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getStatusColor(String status) {
     switch (status) {
       case 'pending': return Colors.orange;
       case 'completed': return Colors.green;
       case 'canceled': return Colors.red;
       case 'picked': return Colors.purple;
       case 'accepted': return Colors.blue;
       default: return Colors.grey;
     }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.hourglass_empty;
      case 'completed': return Icons.check_circle;
      case 'canceled': return Icons.cancel;
      case 'picked': return Icons.moped;
      case 'accepted': return Icons.thumb_up;
      default: return Icons.help;
    }
  }
}
