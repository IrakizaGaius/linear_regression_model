import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 24),

              // Analytics Grid
              _buildAnalyticsGrid(context),
              const SizedBox(height: 24),

              // Device Consumption Chart
              _buildConsumptionSection(),
              const SizedBox(height: 24),

              // Device List
              _buildDeviceList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Device Analytics Dashboard",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("Last updated: ${DateTime.now().toString().substring(0, 10)}",
            style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildAnalyticsGrid(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('devices').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No devices found.'));
        }

        var devices = snapshot.data!.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        int activeCount = devices.where((d) => d['status'] == 'active').length;
        int inactiveCount = devices.length - activeCount;
        double totalEnergy = devices.fold(
            0, (sum, d) => sum + (d['powerUsage']['daily'] ?? 0.0));

        return GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
          children: [
            AnalyticsTile(
              title: 'Active Devices',
              value: '$activeCount',
              subtitle: 'Currently Online',
              color: Colors.blue,
              icon: Icons.power_settings_new,
            ),
            AnalyticsTile(
              title: 'Inactive Devices',
              value: '$inactiveCount',
              subtitle: 'Needs Attention',
              color: Colors.orange,
              icon: Icons.power_off,
            ),
            AnalyticsTile(
              title: 'Estimated Total Energy',
              value: '${totalEnergy.toStringAsFixed(1)} kWh',
              subtitle: 'Today\'s Usage',
              color: Colors.green,
              icon: Icons.bolt,
            ),
            AnalyticsTile(
              title: 'Estimated Savings',
              value:
                  '\$${(totalEnergy * 0.1).toStringAsFixed(2)}', // Example calc
              subtitle: 'Monthly Projection',
              color: Colors.purple,
              icon: Icons.savings,
            ),
          ],
        );
      },
    );
  }

  Widget _buildConsumptionSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('devices').snapshots(),
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

        var devices = snapshot.data!.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Energy Distribution by Device",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              height: 300,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: DeviceContributionChart(devices: devices),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDeviceList() {
    Color getColorBasedOnUsage(double dailyUsage) {
      if (dailyUsage < 20) {
        return Colors.green; // For usage below 20
      } else if (dailyUsage >= 20 && dailyUsage <= 50) {
        return Colors.blue; // For usage between 20 and 50
      } else {
        return Colors.red;
      }
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('devices').snapshots(),
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

        var devices = snapshot.data!.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Device Performance Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...devices.map((device) => DeviceDetailTile(
                  deviceName: device['name'],
                  status: device['status'].toString().capitalize(),
                  energyUsage:
                      '${device['powerUsage']['daily'].toStringAsFixed(1)} kWh',
                  icon: _getDeviceIcon(device['type']) ?? Icons.device_unknown,
                  color: getColorBasedOnUsage(device['powerUsage']['daily']),
                ))
          ],
        );
      },
    );
  }
}

class AnalyticsTile extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  const AnalyticsTile({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}

class DeviceDetailTile extends StatelessWidget {
  final String deviceName;
  final String status;
  final String energyUsage;
  final IconData icon;
  final Color color;

  const DeviceDetailTile({
    super.key,
    required this.deviceName,
    required this.status,
    required this.energyUsage,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(deviceName),
        subtitle: Text("Status: $status"),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(energyUsage,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            Text("24h usage",
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class DeviceContributionChart extends StatelessWidget {
  final List<dynamic> devices;

  Color getColorBasedOnUsage(double dailyUsage) {
    if (dailyUsage < 20) {
      return Colors.green; // For usage below 20
    } else if (dailyUsage >= 20 && dailyUsage <= 50) {
      return Colors.blue; // For usage between 20 and 50
    } else {
      return Colors.red; // For usage above 50
    }
  }

  String _abbreviate(String name) {
    var words = name.split(' ');
    if (words.length > 1) {
      return words
          .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
          .join();
    } else {
      return name.isNotEmpty ? name.substring(0, 2).toUpperCase() : '';
    }
  }

  const DeviceContributionChart({super.key, required this.devices});

  @override
  Widget build(BuildContext context) {
    final total = devices.fold(
            0.0, (sum, device) => sum + device['powerUsage']['daily']) *
        1.2;

    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(
                  top: 7.0,
                ),
                child: Text(
                  _abbreviate(devices[value.toInt()]['name']),
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        barGroups: devices.asMap().entries.map((entry) {
          final index = entry.key;
          final device = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: device['powerUsage']['daily'],
                color: getColorBasedOnUsage(device['powerUsage']['daily']),
                width: 25,
                borderRadius: BorderRadius.circular(4),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: total,
                  color: Colors.grey[200],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class DeviceData {
  final String name;
  final double value;
  final Color color;

  DeviceData(this.name, this.value, this.color);
}

extension StringExtension on String {
  String capitalize() =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
}

IconData? _getDeviceIcon(String deviceType) {
  switch (deviceType) {
    case 'Lights':
      return Icons.lightbulb;
    case 'TV':
      return Icons.tv;
    case 'DishWasher':
      return FaIcon(FontAwesomeIcons.sink).icon;
    case 'Microwave':
      return Icons.microwave;
    case 'Washing_Machine':
      return Icons.water;
    case 'Fridge':
      return Icons.kitchen;
    case 'Oven':
      return Icons.fireplace;
    case 'Heater':
      return Icons.heat_pump_rounded;
    case 'Computer':
      return Icons.computer;
    case 'Air_Conditioner':
      return Icons.air_outlined;
    default:
      return Icons.device_unknown;
  }
}
