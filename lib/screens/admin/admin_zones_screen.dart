import 'package:flutter/material.dart';
import '../../core/services/delivery_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';

class AdminZonesScreen extends StatelessWidget {
  const AdminZonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Zone Management', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const SizedBox.shrink(),
          bottom: const TabBar(
             labelColor: AppColors.primary,
             unselectedLabelColor: Colors.grey,
             tabs: [
               Tab(text: "Pending Requests"),
               Tab(text: "Active Zones"),
             ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRequestsTab(context),
            _buildZonesTab(context),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => _showAddZoneDialog(context),
        ),
      ),
    );
  }

  Widget _buildRequestsTab(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: DeliveryService().getZoneRequests(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final requests = snapshot.data!;
        if (requests.isEmpty) return const Center(child: Text("No new zone requests"));

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            return ListTile(
              title: Text(req['name']),
              subtitle: Text("Requested: ${(req['requestedAt'] as dynamic)?.toDate() ?? 'Now'}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => DeliveryService().approveZoneRequest(req['id'], req['name']),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => DeliveryService().rejectZoneRequest(req['id']),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildZonesTab(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: DeliveryService().getZonesStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final dbZones = snapshot.data ?? [];
        // Combine with hardcoded
        final Set<String> combined = {};
        combined.addAll([
          'Bole', 'Kirkos', 'Arada', 'Lideta', 'Yeka', 'Nifas Silk-Lafto', 'Akaki Kality', 'Addis Ketema', 'Gullele', 'Kolfe Keranio'
        ]);
        combined.addAll(dbZones);
        final zones = combined.toList()..sort();
        
        return ListView.builder(
          itemCount: zones.length,
          itemBuilder: (context, index) {
            final isDefault = !dbZones.contains(zones[index]);
            return ListTile(
              leading: Icon(Icons.location_on, color: isDefault ? Colors.grey : AppColors.primary),
              title: Text(zones[index]),
              subtitle: isDefault ? const Text("System Default", style: TextStyle(fontSize: 10)) : const Text("Custom Zone", style: TextStyle(fontSize: 10, color: Colors.green)),
            );
          },
        );
      },
    );
  }

  void _showAddZoneDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add New Zone"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Zone Name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await DeliveryService().addZone(controller.text.trim());
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }
}
