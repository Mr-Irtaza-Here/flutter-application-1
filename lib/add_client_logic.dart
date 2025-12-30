import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddClientLogic {
  static const String _storageKey = 'clients_list';

  Future<void> showAddClientDialog(
    BuildContext context,
    Function(String) onClientAdded,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _AddClientDialog(onClientAdded: onClientAdded);
      },
    );
  }

  static Future<List<String>> getClients() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_storageKey);
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (e) {
      debugPrint('Error loading clients: $e');
    }
    return [];
  }

  static Future<void> _saveClient(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> currentList = await getClients();
      
      if (!currentList.contains(name)) {
        currentList.add(name);
        await prefs.setString(_storageKey, jsonEncode(currentList));
      }
    } catch (e) {
      debugPrint('Error saving client: $e');
    }
  }
}

class _AddClientDialog extends StatefulWidget {
  final Function(String) onClientAdded;

  const _AddClientDialog({required this.onClientAdded});

  @override
  State<_AddClientDialog> createState() => _AddClientDialogState();
}

class _AddClientDialogState extends State<_AddClientDialog> {
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
      await AddClientLogic._saveClient(name);
      widget.onClientAdded(name);
      
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
              'Add New Client',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Client Name',
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
                    'Back',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isNameEmpty ? null : _handleAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
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
