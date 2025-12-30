import 'package:flutter/material.dart';
import 'storage_screen.dart';
import 'engineer_names.dart';
import 'calendar.dart';
import 'cost.dart';
import 'category.dart';
import 'type.dart';
import 'client.dart';
import 'status.dart';
import 'car_bike_no.dart';
import 'description.dart';
import 'fuel_cost.dart';
import 'time_consumed.dart';
import 'start_end_distance.dart';
import 'add_engineer_logic.dart';
import 'add_client_logic.dart';
import 'add_fuel_cost.dart';

/// Edit Logic for Storage Entries
class EditLogic {
  /// Show edit dialog for a storage entry
  static Future<void> showEditDialog({
    required BuildContext context,
    required StorageEntry entry,
    required int index,
    required int entryNumber,
    required VoidCallback onEntryUpdated,
  }) async {
    // Load data for dropdowns
    final engineersList = await AddEngineerLogic.getEngineers();
    final clientsList = await AddClientLogic.getClients();
    // ignore: unused_local_variable
    final defaultFuelCost = await AddFuelCostLogic.getFuelCost(); // Just to load if needed, though we use entry's value

    // Initialize state variables from entry
    List<String> selectedEngineers = entry.engineerName?.split(', ') ?? [];
    // Handle case where split might create empty string if original is null/empty
    if (selectedEngineers.length == 1 && selectedEngineers[0].isEmpty) {
        selectedEngineers = [];
    }
    
    DateTime? selectedDate = entry.date != null ? DateTime.tryParse(entry.date!) : null;
    String? cost = entry.cost;
    String? selectedCategory = entry.category;
    String? selectedType = entry.type;
    String? selectedClient = entry.client;
    String? selectedStatus = entry.status;
    String? carBikeNo = entry.carBikeNo;
    String? description = entry.description;
    String? fuelCost = entry.fuelCost;
    
    // Parse time strings back to TimeOfDay
    TimeOfDay? startTime = _parseTimeOfDay(entry.startTime);
    TimeOfDay? endTime = _parseTimeOfDay(entry.endTime);
    
    // Parse total time (remove ' hrs')
    double totalTime = 0.0;
    if (entry.totalTime != null && entry.totalTime!.contains(' hrs')) {
      totalTime = double.tryParse(entry.totalTime!.replaceAll(' hrs', '')) ?? 0.0;
    }

    String? startLocation = entry.startLocation;
    String? endLocation = entry.endLocation;
    String? distance = entry.distance;

    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental closing
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 24),
              title: Text('Edit Entry #$entryNumber'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Engineer Names Field
                      EngineerNamesField(
                        engineersList: engineersList,
                        selectedEngineers: selectedEngineers,
                        onEngineersSelected: (engineers) {
                          setState(() {
                            selectedEngineers = engineers;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Date Picker Field
                      DatePickerField(
                        selectedDate: selectedDate,
                        onDateSelected: (date) {
                          setState(() {
                            selectedDate = date;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Cost Input Field
                      CostInputField(
                        cost: cost,
                        onCostChanged: (val) {
                          setState(() {
                            cost = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Category Field
                      CategoryField(
                        selectedCategory: selectedCategory,
                        onCategorySelected: (val) {
                          setState(() {
                            selectedCategory = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Type Field
                      TypeField(
                        selectedType: selectedType,
                        onTypeSelected: (val) {
                          setState(() {
                            selectedType = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Client Field
                      ClientField(
                        clientsList: clientsList,
                        selectedClient: selectedClient,
                        onClientSelected: (val) {
                          setState(() {
                            selectedClient = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Status Field
                      StatusField(
                        selectedStatus: selectedStatus,
                        onStatusSelected: (val) {
                          setState(() {
                            selectedStatus = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Car/Bike No Field
                      CarBikeNoField(
                        number: carBikeNo,
                        onNumberChanged: (val) {
                          setState(() {
                            carBikeNo = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Description Field
                      DescriptionField(
                        description: description,
                        onDescriptionChanged: (val) {
                          setState(() {
                            description = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Fuel Cost Field
                      FuelCostField(
                        fuelCost: fuelCost,
                        onFuelCostChanged: (val) {
                          setState(() {
                            fuelCost = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Time Consumed Field
                      TimeConsumedField(
                        startTime: startTime,
                        endTime: endTime,
                        onTimeChanged: (start, end, duration) {
                          setState(() {
                            startTime = start;
                            endTime = end;
                            totalTime = duration;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Start/End Distance Field
                      StartEndDistanceField(
                        startLocation: startLocation,
                        endLocation: endLocation,
                        distance: distance,
                        onStartLocationChanged: (val) {
                          setState(() {
                            startLocation = val;
                          });
                        },
                        onEndLocationChanged: (val) {
                          setState(() {
                            endLocation = val;
                          });
                        },
                        onDistanceChanged: (val) {
                          setState(() {
                            distance = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    // Create updated entry
                    final updatedEntry = StorageEntry(
                      engineerName: selectedEngineers.join(', '),
                      date: selectedDate?.toString().split(' ')[0], // Format YYYY-MM-DD
                      cost: cost,
                      category: selectedCategory,
                      type: selectedType,
                      client: selectedClient,
                      status: selectedStatus,
                      carBikeNo: carBikeNo,
                      description: description,
                      fuelCost: fuelCost,
                      startTime: startTime?.format(context),
                      endTime: endTime?.format(context),
                      totalTime: totalTime > 0 ? '${totalTime.toStringAsFixed(2)} hrs' : null,
                      startLocation: startLocation,
                      endLocation: endLocation,
                      distance: distance,
                      timestamp: entry.timestamp,
                    );
                    
                    Navigator.of(dialogContext).pop();
                    await StorageLogic.updateEntry(index, updatedEntry);
                    onEntryUpdated();
                    
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Entry #$entryNumber updated'),
                          backgroundColor: Colors.teal,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.teal),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Helper to parse "10:30 AM" back to TimeOfDay
  static TimeOfDay? _parseTimeOfDay(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;
    try {
      // timeString is expected to be "10:30 AM" or similar
      // Remove AM/PM for parsing logic if needed, or simply assume standard format
      // Flutter's TimeOfDay doesn't parse string directly.
      // We need to parse manually.
      // Format is likely generated by TimeOfDay.format() which is localized.
      // Assuming "h:mm a" or "HH:mm" depending on locale.
      // A robust parsing might be needed if locale varies, but for now we try basic parsing.
      
      // Basic parser for "10:30 AM" format
      final parts = timeString.split(' ');
      if (parts.length != 2) return null; // unexpected format
      
      final timeParts = parts[0].split(':');
      if (timeParts.length != 2) return null;
      
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      final period = parts[1].toUpperCase(); // AM or PM
      
      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }
      
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      debugPrint('Error parsing time: $e');
      return null;
    }
  }
}
