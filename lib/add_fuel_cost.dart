import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddFuelCostLogic {
  static const String _storageKey = 'fuel_cost_data';

  Future<void> showAddFuelCostDialog(
    BuildContext context,
    Function(String) onFuelCostAdded,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _AddFuelCostDialog(onFuelCostAdded: onFuelCostAdded);
      },
    );
  }

  /// Get the current fuel cost value (returns just the value string for compatibility)
  static Future<String?> getFuelCost() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_storageKey);
      
      if (data != null) {
        // Try to parse as JSON first (new format)
        try {
          final Map<String, dynamic> decoded = jsonDecode(data);
          return decoded['value']?.toString();
        } catch (_) {
          // Fallback: might be old plain string format, migrate it
          await _migrateLegacyData(prefs, data);
          return data;
        }
      }
      
      // Check for legacy key and migrate if exists
      final String? legacyData = prefs.getString('fuel_cost_value');
      if (legacyData != null) {
        await _migrateLegacyData(prefs, legacyData);
        return legacyData;
      }
    } catch (e) {
      debugPrint('Error loading fuel cost: $e');
    }
    return null;
  }

  /// Get the full fuel cost data as JSON map (for server sync)
  static Future<Map<String, dynamic>?> getFuelCostData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_storageKey);
      if (data != null) {
        return jsonDecode(data) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error loading fuel cost data: $e');
    }
    return null;
  }

  /// Migrate legacy plain string data to new JSON format
  static Future<void> _migrateLegacyData(SharedPreferences prefs, String legacyValue) async {
    try {
      final Map<String, dynamic> fuelCostData = {
        'value': legacyValue,
        'timestamp': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_storageKey, jsonEncode(fuelCostData));
      // Remove old key if exists
      await prefs.remove('fuel_cost_value');
      debugPrint('Migrated legacy fuel cost data to JSON format');
    } catch (e) {
      debugPrint('Error migrating fuel cost data: $e');
    }
  }

  /// Save fuel cost in JSON format
  static Future<void> _saveFuelCost(String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing data to preserve creation timestamp
      Map<String, dynamic>? existingData;
      final String? existingJson = prefs.getString(_storageKey);
      if (existingJson != null) {
        try {
          existingData = jsonDecode(existingJson) as Map<String, dynamic>;
        } catch (_) {
          // Ignore parsing errors
        }
      }
      
      final Map<String, dynamic> fuelCostData = {
        'value': value,
        'timestamp': existingData?['timestamp'] ?? DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      await prefs.setString(_storageKey, jsonEncode(fuelCostData));
      debugPrint('Saved fuel cost: ${jsonEncode(fuelCostData)}');
    } catch (e) {
      debugPrint('Error saving fuel cost: $e');
    }
  }
}

class _AddFuelCostDialog extends StatefulWidget {
  final Function(String) onFuelCostAdded;

  const _AddFuelCostDialog({required this.onFuelCostAdded});

  @override
  State<_AddFuelCostDialog> createState() => _AddFuelCostDialogState();
}

class _AddFuelCostDialogState extends State<_AddFuelCostDialog> {
  final TextEditingController _costController = TextEditingController();
  bool _isValueEmpty = true;

  @override
  void initState() {
    super.initState();
    _costController.addListener(() {
      setState(() {
        _isValueEmpty = _costController.text.trim().isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _costController.dispose();
    super.dispose();
  }

  Future<void> _handleAdd() async {
    final value = _costController.text.trim();
    if (value.isNotEmpty) {
      await AddFuelCostLogic._saveFuelCost(value);
      widget.onFuelCostAdded(value);
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Fuel Cost',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _costController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                // Only allow digits and a single decimal point
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: 'Fuel Cost (Price)',
                prefixIcon: const Icon(Icons.local_gas_station, color: Colors.orange),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isValueEmpty ? null : _handleAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
