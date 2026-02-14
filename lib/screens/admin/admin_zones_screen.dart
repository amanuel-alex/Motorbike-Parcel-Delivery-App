import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/delivery_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';

class AdminZonesScreen extends StatefulWidget {
  const AdminZonesScreen({super.key});

  @override
  State<AdminZonesScreen> createState() => _AdminZonesScreenState();
}

class _AdminZonesScreenState extends State<AdminZonesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Ops Management', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const SizedBox.shrink(),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.black),
              onPressed: () => showLogoutDialog(context),
            ),
          ],
          bottom: const TabBar(
             labelColor: AppColors.primary,
             unselectedLabelColor: Colors.grey,
             indicatorColor: AppColors.primary,
             isScrollable: true,
             tabs: [
               Tab(text: "Pending Requests"),
               Tab(text: "Active Zones"),
               Tab(text: "Route Pricing"),
             ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRequestsTab(context),
            _buildZonesTab(context),
            _buildPricingTab(context),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
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
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text("No pending zone requests", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: ListTile(
                title: Text(req['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Requested: ${(req['requestedAt'] as dynamic)?.toDate().toString().split('.')[0] ?? 'Now'}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () async {
                        if (await showConfirmationDialog(context, "Approve Zone", "Add '${req['name']}' to active zones?")) {
                           await DeliveryService().approveZoneRequest(req['id'], req['name']);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        if (await showConfirmationDialog(context, "Reject Zone", "Reject request for '${req['name']}'?")) {
                           await DeliveryService().rejectZoneRequest(req['id']);
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildZonesTab(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search zones...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: DeliveryService().getZonesStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final dbZoneData = snapshot.data ?? [];
              final dbZones = dbZoneData.map((z) => z['name'] as String).toList();
              
              final Set<String> systemDefaults = {
                'Bole', 'Kirkos', 'Arada', 'Lideta', 'Yeka', 'Nifas Silk-Lafto', 'Akaki Kality', 'Addis Ketema', 'Gullele', 'Kolfe Keranio'
              };
              
              final Set<String> combined = {};
              combined.addAll(systemDefaults);
              combined.addAll(dbZones);
              
              final List<String> allZones = combined.toList()..sort();
              
              final filteredZones = allZones.where((zone) => 
                zone.toLowerCase().contains(_searchQuery.toLowerCase())
              ).toList();

              if (filteredZones.isEmpty) {
                return const Center(child: Text("No zones found"));
              }
              
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredZones.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final zone = filteredZones[index];
                  final isSystem = systemDefaults.contains(zone);
                  final zoneData = dbZoneData.firstWhere((z) => z['name'] == zone, orElse: () => {});
                  
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isSystem ? Colors.grey : AppColors.primary).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.location_on, color: isSystem ? Colors.grey : AppColors.primary),
                    ),
                    title: Text(zone, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: isSystem 
                      ? const Text("System Default", style: TextStyle(fontSize: 12)) 
                      : const Text("Custom Zone", style: TextStyle(fontSize: 12, color: Colors.green)),
                    trailing: isSystem ? null : IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _handleDeleteZone(context, zoneData),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPricingTab(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: DeliveryService().getZonePricesStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final prices = snapshot.data!;
        if (prices.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payments_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text("No pricing rules set", style: TextStyle(color: Colors.grey)),
                TextButton(onPressed: () => _showAddPriceDialog(context), child: const Text("Add First Rule")),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: prices.length,
          itemBuilder: (context, index) {
            final price = prices[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
              child: ListTile(
                title: Text("${price['pickup']} → ${price['dropoff']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Price: ETB ${price['price']}", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showEditPriceDialog(context, price)),
                    IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _handleDeletePrice(context, price)),
                  ],
                ),
              ),
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
          decoration: const InputDecoration(hintText: "Zone Name (e.g. Sarbet)"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
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

  void _showAddPriceDialog(BuildContext context) async {
    final zones = await DeliveryService().getZones();
    if (zones.length < 2) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Add more zones first")));
      return;
    }

    String? pickup = zones[0];
    String? dropoff = zones[1];
    final priceController = TextEditingController();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Add Price Rule"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: pickup,
                items: zones.map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(),
                onChanged: (v) => setDialogState(() => pickup = v),
                decoration: const InputDecoration(labelText: "From"),
              ),
              DropdownButtonFormField<String>(
                value: dropoff,
                items: zones.map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(),
                onChanged: (v) => setDialogState(() => dropoff = v),
                decoration: const InputDecoration(labelText: "To"),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Price (ETB)"),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                if (pickup != null && dropoff != null && priceController.text.isNotEmpty) {
                  await DeliveryService().addZonePrice(pickup!, dropoff!, double.parse(priceController.text));
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPriceDialog(BuildContext context, Map<String, dynamic> price) {
    final controller = TextEditingController(text: price['price'].toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Price"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "New Price"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await DeliveryService().updateZonePrice(price['id'], double.parse(controller.text));
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _handleDeleteZone(BuildContext context, Map<String, dynamic> zone) async {
    if (!await showConfirmationDialog(context, "Delete Zone", "Are you sure you want to delete '${zone['name']}'?")) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final id = zone['id'] as String;
    
    await DeliveryService().deleteZone(id);

    messenger.showSnackBar(
      SnackBar(
        content: Text("Zone ${zone['name']} deleted"),
        action: SnackBarAction(
          label: "UNDO",
          onPressed: () async {
            final data = Map<String, dynamic>.from(zone);
            data.remove('id');
            await FirebaseFirestore.instance.collection('Zones').doc(id).set(data);
          },
        ),
      ),
    );
  }

  void _handleDeletePrice(BuildContext context, Map<String, dynamic> price) async {
    if (!await showConfirmationDialog(context, "Delete Price Rule", "Are you sure you want to delete this pricing rule?")) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final id = price['id'] as String;
    
    await DeliveryService().deleteZonePrice(id);

    messenger.showSnackBar(
      SnackBar(
        content: Text("Price rule deleted"),
        action: SnackBarAction(
          label: "UNDO",
          onPressed: () async {
            final data = Map<String, dynamic>.from(price);
            data.remove('id');
            await FirebaseFirestore.instance.collection('ZonePrices').doc(id).set(data);
          },
        ),
      ),
    );
  }
}
