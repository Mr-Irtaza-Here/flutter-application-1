import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddFuelCostLogic {
  static const String _storageKey = 'fuel_cost_value';

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

  static Future<String?> getFuelCost() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_storageKey);
    } catch (e) {
      debugPrint('Error loading fuel cost: $e');
    }
    return null;
  }

  static Future<void> _saveFuelCost(String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, value);
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
