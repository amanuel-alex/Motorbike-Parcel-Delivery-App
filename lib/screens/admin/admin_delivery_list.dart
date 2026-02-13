import 'package:flutter/material.dart';
import '../../core/services/delivery_service.dart';
import '../../core/models/delivery_model.dart';
import '../customer/delivery_details_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';


class AdminDeliveryListScreen extends StatelessWidget {
  const AdminDeliveryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF8F9FB),
      body: StreamBuilder<List<Delivery>>(
        stream: DeliveryService().getAllDeliveries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final deliveries = snapshot.data ?? [];
          
          if (deliveries.isEmpty) {
            return const Center(child: Text("No deliveries found"));
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
    );
  }

  Widget _buildAdminDeliveryCard(BuildContext context, Delivery delivery) {
    final bool isPaymentPending = delivery.paymentStatus == 'pending';
    
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
