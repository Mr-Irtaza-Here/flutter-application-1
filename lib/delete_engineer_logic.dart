import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'add_engineer_logic.dart'; // To reuse getEngineers if possible, or we can duplicate get logic to be independent.
// Actually AddEngineerLogic has static getEngineers, let's use it to single source truth.

class DeleteEngineerLogic {
  static const String _storageKey = 'engineers_list';

  Future<void> showDeleteEngineerDialog(
    BuildContext context,
    VoidCallback onEngineersUpdated,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: true, // Can click outside to close
      builder: (BuildContext context) {
        return _DeleteEngineerDialog(onEngineersUpdated: onEngineersUpdated);
      },
    );
  }

  static Future<void> _deleteEngineer(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Reuse getEngineers from AddEngineerLogic to ensure consistent reading
      final List<String> currentList = await AddEngineerLogic.getEngineers();
      
      if (currentList.contains(name)) {
        currentList.remove(name);
        await prefs.setString(_storageKey, jsonEncode(currentList));
      }
    } catch (e) {
      debugPrint('Error deleting engineer: $e');
    }
  }
}

class _DeleteEngineerDialog extends StatefulWidget {
  final VoidCallback onEngineersUpdated;

  const _DeleteEngineerDialog({required this.onEngineersUpdated});

  @override
  State<_DeleteEngineerDialog> createState() => _DeleteEngineerDialogState();
}

class _DeleteEngineerDialogState extends State<_DeleteEngineerDialog> {
  List<String> _engineers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEngineers();
  }

  Future<void> _loadEngineers() async {
    setState(() => _isLoading = true);
    final list = await AddEngineerLogic.getEngineers();
    if (mounted) {
      setState(() {
        _engineers = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmDelete(String name) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Do you want to delete ($name)?'),
          actionsAlignment: MainAxisAlignment.center,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No', style: TextStyle(color: Colors.grey, fontSize: 16)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close confirmation dialog
                await _performDelete(name);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Yes', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performDelete(String name) async {
    await DeleteEngineerLogic._deleteEngineer(name);
    // Refresh local list
    await _loadEngineers();
    // Notify parent to refresh their list (e.g. Home Screen)
    widget.onEngineersUpdated();
  }

  @override
  Widget build(BuildContext context) {
    // Similar styling to AddEngineerDialog for consistency
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 300,
        height: 400, // Fixed height to allow scrolling list
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          children: [
            const Text(
              'Delete Engineer',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tap name to delete',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _engineers.isEmpty
                      ? const Center(child: Text('No engineers added'))
                      : ListView.separated(
                          itemCount: _engineers.length,
                          separatorBuilder: (ctx, i) => const Divider(),
                          itemBuilder: (context, index) {
                            final name = _engineers[index];
                            return ListTile(
                              title: Text(name),
                              trailing: const Icon(Icons.delete_outline, color: Colors.red),
                              onTap: () => _confirmDelete(name),
                            );
                          },
                        ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Back',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
