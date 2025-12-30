import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddEngineerLogic {
  static const String _storageKey = 'engineers_list';

  Future<void> showAddEngineerDialog(
    BuildContext context,
    Function(String) onEngineerAdded,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside to ensure Back button is used
      builder: (BuildContext context) {
        return _AddEngineerDialog(onEngineerAdded: onEngineerAdded);
      },
    );
  }

  static Future<List<String>> getEngineers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_storageKey);
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (e) {
      debugPrint('Error loading engineers: $e');
    }
    return [];
  }

  static Future<void> _saveEngineer(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> currentList = await getEngineers();
      
      if (!currentList.contains(name)) {
        currentList.add(name);
        await prefs.setString(_storageKey, jsonEncode(currentList));
      }
    } catch (e) {
      debugPrint('Error saving engineer: $e');
    }
  }
}

class _AddEngineerDialog extends StatefulWidget {
  final Function(String) onEngineerAdded;

  const _AddEngineerDialog({required this.onEngineerAdded});

  @override
  State<_AddEngineerDialog> createState() => _AddEngineerDialogState();
}

class _AddEngineerDialogState extends State<_AddEngineerDialog> {
  final TextEditingController _nameController = TextEditingController();
  bool _isNameEmpty = true;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {
        _isNameEmpty = _nameController.text.trim().isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleAdd() async {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      // Save to SharedPreferences
      await AddEngineerLogic._saveEngineer(name);
      
      // Notify parent
      widget.onEngineerAdded(name);
      
      if (mounted) {
        Navigator.of(context).pop(); // Close Add Dialog
        // Note: The user wanted to go back to "Manage Engineer" menu.
        // Since this dialog is on top of Manage Engineer dialog (if not closed), popping works.
        // If Manage Engineer was closed, we might need to reopen it, but usually standard is to stack dialogs
        // or close existing before opening new.
        // The user request: "if the user cahnges his mind and presses the "Back" button then user will go back to "Manage Engineer" menu"
        // This implies the standard navigation stack behavior is sufficient if we didn't close Manage Engineer.
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
        width: 300, // Constrain width for "box" look
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add New Engineer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Engineer Name',
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
                    Navigator.of(context).pop(); // Back to previous menu
                  },
                  child: const Text(
                    'Back',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isNameEmpty ? null : _handleAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
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
