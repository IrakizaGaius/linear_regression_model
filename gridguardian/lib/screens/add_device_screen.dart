import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gridguardian/screens/devices_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _householdController = TextEditingController();
  DeviceType _selectedType = DeviceType.SelectType;
  Season _selectedSeason = Season.SelectSeason;
  bool _isActive = true;
  XFile? _capturedImage;
  bool _isProcessing = false;
  bool _isLoading = false;
  final logger = Logger();
  bool _showSuccessMessage = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DefaultTabController(
          length: 2,
          child: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Add New Device',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TabBar(
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).primaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey[600],
                      labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: [
                        SizedBox(
                          width: double.infinity,
                          child: Tab(text: 'Manual Entry'),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Tab(text: 'Camera Scan'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildManualForm(),
                        _buildCameraInterface(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        if (_isLoading || _showSuccessMessage)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'Device added successfully!',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w600),
                      ),
                    ),
            ),
          ),
      ],
    );
  }

  void _resetForm() {
    _nameController.clear();
    _householdController.clear();
    _selectedType = DeviceType.SelectType;
    _selectedSeason = Season.SelectSeason;
    _isActive = false;
    setState(() {});
  }

  Widget _buildManualForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Device Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.devices),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Required field';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<DeviceType>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Device Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.devices_other),
              ),
              items: DeviceType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getTypeLabel(type)),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedType = value!),
              validator: (value) {
                value == null ? 'Required field' : null;
                if (value == DeviceType.SelectType) {
                  return 'Please select a device type';
                }

                return null;
              },
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<Season>(
              value: _selectedSeason,
              decoration: InputDecoration(
                labelText: 'Season',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.sunny_snowing),
              ),
              items: Season.values.map((season) {
                return DropdownMenuItem(
                  value: season,
                  child: Text(_getSeasonLabel(season)),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedSeason = value!),
              validator: (value) {
                value == null ? 'Required field' : null;
                if (value == Season.SelectSeason) {
                  return 'Please select a season';
                }
                return null;
              },
            ),
            SizedBox(height: 20),
            TextFormField(
                controller: _householdController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter
                      .digitsOnly, // Restrict input to digits only
                ],
                decoration: InputDecoration(
                  labelText: 'Household Size',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Required field';
                  }
                  return null;
                }),
            SizedBox(height: 20),
            CheckboxListTile(
              title: Text('Device Active'),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value!),
              secondary: Icon(Icons.power_settings_new),
            ),
            SizedBox(height: 15),
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text('Save Device'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _isLoading ? null : _submitForm,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraInterface() {
    return Column(
      children: [
        Expanded(
          child: _capturedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(_capturedImage!.path),
                )
              : Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 60, color: Colors.grey),
                      Text('Scan Device or Upload Image',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                heroTag: 'camera',
                onPressed: _captureImage,
                child: Icon(Icons.camera_enhance),
              ),
              FloatingActionButton(
                heroTag: 'gallery',
                onPressed: _pickImage,
                child: Icon(Icons.photo_library),
              ),
              if (_capturedImage != null)
                ElevatedButton.icon(
                  icon: _isProcessing
                      ? CircularProgressIndicator()
                      : Icon(Icons.cloud_upload),
                  label: Text('Analyze'),
                  onPressed: _isProcessing ? null : _processImage,
                ),
            ],
          ),
        ),
      ],
    );
  }

  // === Helper Methods ===
  String _getTypeLabel(DeviceType type) {
    return type == DeviceType.SelectType
        ? 'Please select a device type'
        : type.toString().split('.').last;
  }

  String _getSeasonLabel(Season season) {
    return season == Season.SelectSeason
        ? 'Please select a season'
        : season.toString().split('.').last;
  }

  Future<void> _submitForm() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showSuccessMessage = false;
        });
      }
    });

    // Function to call the prediction API
    Future<double?> getPowerUsagePrediction(Device device) async {
      // Initialize the request body with zeros for all appliance types and seasons
      final Map<String, int> requestBody = {
        'Household_Size': 4, // Example: Replace with actual household size
        'Appliance_Type_Air Conditioning': 0,
        'Appliance_Type_Dishwasher': 0,
        'Appliance_Type_Microwave': 0,
        'Appliance_Type_Washing_Machine': 0,
        'Appliance_Type_Fridge': 0,
        'Appliance_Type_TV': 0,
        'Appliance_Type_Computer': 0,
        'Appliance_Type_Oven': 0,
        'Appliance_Type_Heater': 0,
        'Appliance_Type_Lights': 0,
        'Season_Fall': 0,
        'Season_Spring': 0,
        'Season_Summer': 0,
        'Season_Winter': 0,
      };

      // Set the appliance type for the selected device to 1
      if (device.type == DeviceType.Air_Conditioner) {
        requestBody['Appliance_Type_Air Conditioning'] = 1;
      } else if (device.type == DeviceType.DishWasher) {
        requestBody['Appliance_Type_Dishwasher'] = 1;
      } else if (device.type == DeviceType.Microwave) {
        requestBody['Appliance_Type_Microwave'] = 1;
      } else if (device.type == DeviceType.Washing_Machine) {
        requestBody['Appliance_Type_Washing_Machine'] = 1;
      } else if (device.type == DeviceType.Fridge) {
        requestBody['Appliance_Type_Fridge'] = 1;
      } else if (device.type == DeviceType.TV) {
        requestBody['Appliance_Type_TV'] = 1;
      } else if (device.type == DeviceType.Computer) {
        requestBody['Appliance_Type_Computer'] = 1;
      } else if (device.type == DeviceType.Oven) {
        requestBody['Appliance_Type_Oven'] = 1;
      } else if (device.type == DeviceType.Heater) {
        requestBody['Appliance_Type_Heater'] = 1;
      } else if (device.type == DeviceType.Lights) {
        requestBody['Appliance_Type_Lights'] = 1;
      }

      // Set the season based on the selected season
      if (device.season == Season.Fall) {
        requestBody['Season_Fall'] = 1;
      } else if (device.season == Season.Spring) {
        requestBody['Season_Spring'] = 1;
      } else if (device.season == Season.Summer) {
        requestBody['Season_Summer'] = 1;
      } else if (device.season == Season.Winter) {
        requestBody['Season_Winter'] = 1;
      }

      // Replace this with the actual call to your FastAPI prediction endpoint
      final url =
          'https://gridguardian-linear-regression-model.onrender.com/predict';
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(requestBody),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final prediction =
            responseBody['predicted_energy_consumption_kwh'] as double;
        return prediction; // Power usage in kWh
      } else {
        return null; // Prediction failed
      }
    }

// Function to store the device in Firebase
    Future<void> storeDeviceInFirebase(Device device) async {
      final deviceCollection = FirebaseFirestore.instance.collection('devices');

      // Add the device data to Firebase
      await deviceCollection.add({
        'name': device.name,
        'type': device.type.toString().split('.').last, // Store the device type
        'status':
            device.status.toString().split('.').last, // Store the device status
        'season':
            device.season.toString().split('.').last, // Store the season data
        'powerUsage': {
          'daily': device.powerUsage.daily,
          'monthly': device.powerUsage.monthly,
          'yearly': device.powerUsage.yearly,
        },
        'householdSize': device.householdSize,
      });
    }

    //Create a new device object
    if (_formKey.currentState!.validate()) {
      // Create the new device object
      var newDevice = Device(
        name: _nameController.text,
        type: _selectedType,
        status: _isActive ? DeviceStatus.active : DeviceStatus.inactive,
        season: _selectedSeason,
        powerUsage: EnergyUsage(daily: 0, monthly: 0, yearly: 0),
        householdSize: int.parse(_householdController.text),
      );
      logger.i('New device created: $newDevice');
      // Call the prediction API to get energy usage in kWh
      final prediction = await getPowerUsagePrediction(newDevice);
      logger.i('Power usage prediction: $prediction kWh');
      if (prediction != null) {
        // Calculate daily, monthly, and yearly usage based on the prediction
        final dailyUsage = prediction * 24;
        final monthlyUsage = dailyUsage * 30;
        final yearlyUsage = dailyUsage * 365;

        // Update the device's power usage
        newDevice.powerUsage = EnergyUsage(
          daily: dailyUsage,
          monthly: monthlyUsage,
          yearly: yearlyUsage,
        );

        try {
          // Store the device data in Firebase
          await storeDeviceInFirebase(newDevice);
          if (mounted) {
            setState(() {
              _isLoading = false;
              _showSuccessMessage = true;
            });
            // Show message for 2 seconds, then reset form and hide message
            Future.delayed(Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _showSuccessMessage = false;
                });
                _resetForm();
              }
            });
          }
        } catch (e) {
          logger.e('Save failed: $e');
          if (mounted) {
            // Handle the error case when prediction fails
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Failed to fetch power usage prediction")),
            );
          }
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _captureImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) setState(() => _capturedImage = image);
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _capturedImage = image);
  }

  Future<void> _processImage() async {
    setState(() => _isProcessing = true);
    // Implement ML model integration for device recognition
    await Future.delayed(Duration(seconds: 2)); // Mock processing

    // Example mock response
    final mockDevice = Device(
      name: 'Smart LED Bulb (Detected)',
      type: DeviceType.Lights,
      status: DeviceStatus.active,
      powerUsage: EnergyUsage(
        daily: 1.2,
        monthly: 36.5,
        yearly: 438.0,
      ),
      season: Season.SelectSeason,
      householdSize: 4,
    );

    setState(() => _isProcessing = false);
    Navigator.pop(context, mockDevice);
  }
}
