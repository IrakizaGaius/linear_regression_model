import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('devices').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No devices available.'));
              }

              // Convert Firestore data into list of Device objects
              List<Device> devices = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Device(
                  name: data['name'],
                  type: _getDeviceTypeFromString(data['type']),
                  status: _getDeviceStatusFromString(data['status']),
                  powerUsage: EnergyUsage(
                    daily: data['powerUsage']['daily'],
                    monthly: data['powerUsage']['monthly'],
                    yearly: data['powerUsage']['yearly'],
                  ),
                  season: _getSeasonFromString(data['season']),
                  householdSize: data['householdSize'],
                );
              }).toList();

              // Display the devices in a ListView
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("Smart Home Devices",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => DeviceTile(device: devices[index]),
                      childCount: devices.length,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Function to map Firestore device type string to DeviceType enum
  DeviceType _getDeviceTypeFromString(String type) {
    switch (type) {
      case 'Lights':
        return DeviceType.Lights;
      case 'TV':
        return DeviceType.TV;
      case 'DishWasher':
        return DeviceType.DishWasher;
      case 'Microwave':
        return DeviceType.Microwave;
      case 'Washing_Machine':
        return DeviceType.Washing_Machine;
      case 'Fridge':
        return DeviceType.Fridge;
      case 'Oven':
        return DeviceType.Oven;
      case 'Heater':
        return DeviceType.Heater;
      case 'Computer':
        return DeviceType.Computer;
      case 'Air_Conditioner':
        return DeviceType.Air_Conditioner;
      default:
        return DeviceType.SelectType;
    }
  }

  // Function to map Firestore device status string to DeviceStatus enum
  DeviceStatus _getDeviceStatusFromString(String status) {
    return status == 'active' ? DeviceStatus.active : DeviceStatus.inactive;
  }

  // Function to map Firestore season string to Season enum
  Season _getSeasonFromString(String season) {
    switch (season) {
      case 'Winter':
        return Season.Winter;
      case 'Spring':
        return Season.Spring;
      case 'Summer':
        return Season.Summer;
      case 'Fall':
        return Season.Fall;
      default:
        return Season.SelectSeason;
    }
  }
}

class DeviceTile extends StatelessWidget {
  final Device device;

  const DeviceTile({required this.device, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {/* Add device detail navigation */},
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _deviceIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(device.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        _statusIndicator(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _energyMetrics(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deviceIcon() {
    final iconData = switch (device.type) {
      DeviceType.Lights => Icons.lightbulb_outline,
      DeviceType.TV => Icons.tv,
      DeviceType.Air_Conditioner => Icons.air,
      DeviceType.Computer => Icons.computer,
      DeviceType.DishWasher => FaIcon(FontAwesomeIcons.sink).icon,
      DeviceType.Fridge => Icons.kitchen,
      DeviceType.Heater => Icons.fireplace,
      DeviceType.Microwave => Icons.microwave,
      DeviceType.Oven => 'assets/icons/oven.png',
      DeviceType.Washing_Machine => 'assets/icons/washing_machine.png',
      _ => Icons.device_unknown, // Default icon if type is unknown
    };

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: device.status.color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData as IconData?, size: 28, color: device.status.color),
    );
  }

  Widget _statusIndicator() {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: device.status.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          device.status.label.toUpperCase(),
          style: TextStyle(
            color: device.status.color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _energyMetrics() {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _metricTile(
              'Daily', '${device.powerUsage.daily.toStringAsFixed(1)} kWh'),
          const VerticalDivider(indent: 8, endIndent: 8),
          _metricTile(
              'Monthly', '${device.powerUsage.monthly.toStringAsFixed(1)} kWh'),
          const VerticalDivider(indent: 8, endIndent: 8),
          _metricTile(
              'Yearly', '${device.powerUsage.yearly.toStringAsFixed(1)} kWh'),
        ],
      ),
    );
  }

  Widget _metricTile(String period, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(period, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

// Data Models
enum DeviceType {
  SelectType,
  Lights,
  TV,
  DishWasher,
  Microwave,
  Washing_Machine,
  Fridge,
  Oven,
  Heater,
  Computer,
  Air_Conditioner
}

enum Season { SelectSeason, Winter, Summer, Spring, Fall }

enum DeviceStatus {
  active(Colors.green, 'Active'),
  inactive(Colors.orange, 'Inactive');

  final Color color;
  final String label;
  const DeviceStatus(this.color, this.label);
}

class EnergyUsage {
  final double daily;
  final double monthly;
  final double yearly;

  const EnergyUsage({
    required this.daily,
    required this.monthly,
    required this.yearly,
  });
}

class Device {
  final String name;
  final DeviceType type;
  final DeviceStatus status;
  late EnergyUsage powerUsage;
  final Season season;
  final int householdSize;

  Device({
    required this.name,
    required this.type,
    required this.status,
    required this.powerUsage,
    required this.season,
    required this.householdSize,
  });
  // Add to your Device class
  @override
  String toString() {
    return 'Device{name: $name, type: $type, status: $status, season: $season, householdSize: $householdSize}';
  }
}
