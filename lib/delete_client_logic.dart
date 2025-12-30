import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'add_client_logic.dart';

class DeleteClientLogic {
  static const String _storageKey = 'clients_list';

  Future<void> showDeleteClientDialog(
    BuildContext context,
    VoidCallback onClientsUpdated,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return _DeleteClientDialog(onClientsUpdated: onClientsUpdated);
      },
    );
  }

  static Future<void> _deleteClient(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> currentList = await AddClientLogic.getClients();
      
      if (currentList.contains(name)) {
        currentList.remove(name);
        await prefs.setString(_storageKey, jsonEncode(currentList));
      }
    } catch (e) {
      debugPrint('Error deleting client: $e');
    }
  }
}

class _DeleteClientDialog extends StatefulWidget {
  final VoidCallback onClientsUpdated;

  const _DeleteClientDialog({required this.onClientsUpdated});

  @override
  State<_DeleteClientDialog> createState() => _DeleteClientDialogState();
}

class _DeleteClientDialogState extends State<_DeleteClientDialog> {
  List<String> _clients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() => _isLoading = true);
    final list = await AddClientLogic.getClients();
    if (mounted) {
      setState(() {
        _clients = list;
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
                Navigator.of(context).pop();
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
    await DeleteClientLogic._deleteClient(name);
    await _loadClients();
    widget.onClientsUpdated();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 300,
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          children: [
            const Text(
              'Delete Client',
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
                  : _clients.isEmpty
                      ? const Center(child: Text('No clients added'))
                      : ListView.separated(
                          itemCount: _clients.length,
                          separatorBuilder: (ctx, i) => const Divider(),
                          itemBuilder: (context, index) {
                            final name = _clients[index];
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
