import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'edit_logic.dart';
import 'copy_logic.dart';
import 'sheet_button.dart';

/// Model class for a single data entry
class StorageEntry {
  final String? engineerName;
  final String? date;
  final String? cost;
  final String? category;
  final String? type;
  final String? client;
  final String? status;
  final String? carBikeNo;
  final String? description;
  final String? fuelCost;
  final String? startTime;
  final String? endTime;
  final String? totalTime;
  final String? startLocation;
  final String? endLocation;
  final String? distance;
  final String timestamp; // When this entry was created

  StorageEntry({
    this.engineerName,
    this.date,
    this.cost,
    this.category,
    this.type,
    this.client,
    this.status,
    this.carBikeNo,
    this.description,
    this.fuelCost,
    this.startTime,
    this.endTime,
    this.totalTime,
    this.startLocation,
    this.endLocation,
    this.distance,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'engineerName': engineerName,
    'date': date,
    'cost': cost,
    'category': category,
    'type': type,
    'client': client,
    'status': status,
    'carBikeNo': carBikeNo,
    'description': description,
    'fuelCost': fuelCost,
    'startTime': startTime,
    'endTime': endTime,
    'totalTime': totalTime,
    'startLocation': startLocation,
    'endLocation': endLocation,
    'distance': distance,
    'timestamp': timestamp,
  };

  factory StorageEntry.fromJson(Map<String, dynamic> json) => StorageEntry(
    engineerName: json['engineerName'],
    date: json['date'],
    cost: json['cost'],
    category: json['category'],
    type: json['type'],
    client: json['client'],
    status: json['status'],
    carBikeNo: json['carBikeNo'],
    description: json['description'],
    fuelCost: json['fuelCost'],
    startTime: json['startTime'],
    endTime: json['endTime'],
    totalTime: json['totalTime'],
    startLocation: json['startLocation'],
    endLocation: json['endLocation'],
    distance: json['distance'],
    timestamp: json['timestamp'] ?? '',
  );
}

/// Logic class for storage operations
class StorageLogic {
  static const String _storageKey = 'storage_entries';

  /// Save a new entry to storage
  static Future<void> saveEntry(StorageEntry entry) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<StorageEntry> entries = await getEntries();
      entries.add(entry);
      final String jsonData = jsonEncode(entries.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, jsonData);
    } catch (e) {
      debugPrint('Error saving entry: $e');
    }
  }

  /// Get all entries from storage
  static Future<List<StorageEntry>> getEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_storageKey);
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        return decoded.map((e) => StorageEntry.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error loading entries: $e');
    }
    return [];
  }

  /// Delete an entry at specific index
  static Future<void> deleteEntry(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<StorageEntry> entries = await getEntries();
      if (index >= 0 && index < entries.length) {
        entries.removeAt(index);
        final String jsonData = jsonEncode(entries.map((e) => e.toJson()).toList());
        await prefs.setString(_storageKey, jsonData);
      }
    } catch (e) {
      debugPrint('Error deleting entry: $e');
    }
  }

  /// Update an entry at specific index
  static Future<void> updateEntry(int index, StorageEntry updatedEntry) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<StorageEntry> entries = await getEntries();
      if (index >= 0 && index < entries.length) {
        entries[index] = updatedEntry;
        final String jsonData = jsonEncode(entries.map((e) => e.toJson()).toList());
        await prefs.setString(_storageKey, jsonData);
      }
    } catch (e) {
      debugPrint('Error updating entry: $e');
    }
  }
}

/// Storage Screen Widget
class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  List<StorageEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    final entries = await StorageLogic.getEntries();
    if (mounted) {
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SheetSideMenu(),
      floatingActionButton: const SheetButton(),
      appBar: AppBar(
        title: const Text(
          'Storage Screen',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? const Center(
                  child: Text(
                    'No data stored yet.\nAdd data from HomeScreen.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadEntries,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      return _buildEntryCard(_entries[index], index + 1, index);
                    },
                  ),
                ),
    );
  }

  Widget _buildEntryCard(StorageEntry entry, int entryNumber, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          // Bottom shadow (full intensity)
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
          // Top shadow (half intensity)
          BoxShadow(
            color: Colors.black.withOpacity(0.075),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
          // Left shadow (half intensity)
          BoxShadow(
            color: Colors.black.withOpacity(0.075),
            offset: const Offset(-2, 0),
            blurRadius: 4,
          ),
          // Right shadow (half intensity)
          BoxShadow(
            color: Colors.black.withOpacity(0.075),
            offset: const Offset(2, 0),
            blurRadius: 4,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Entry Header with Edit and Delete buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Entry #$entryNumber',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                ),
                Row(
                  children: [
                    // Edit Button
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue.shade600, size: 22),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Edit Entry',
                      onPressed: () => EditLogic.showEditDialog(
                        context: context,
                        entry: entry,
                        index: index,
                        entryNumber: entryNumber,
                        onEntryUpdated: _loadEntries,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Copy Button
                    IconButton(
                      icon: Icon(Icons.copy, color: Colors.green.shade600, size: 22),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Copy Entry',
                      onPressed: () => CopyLogic.showCopyDialog(
                        context: context,
                        entry: entry,
                        entryNumber: entryNumber,
                        onEntryCopied: _loadEntries,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Delete Button
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red.shade600, size: 22),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Delete Entry',
                      onPressed: () => _showDeleteConfirmation(index, entryNumber),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            // Data Rows with EXACT HomeScreen Headings
            _buildDataRow('Engineer_Name', entry.engineerName),
            _buildDataRow('Date', entry.date),
            _buildDataRow('Cost (PKR)', entry.cost),
            _buildDataRow('Category', entry.category),
            _buildDataRow('Type', entry.type),
            _buildDataRow('Client', entry.client),
            _buildDataRow('Status', entry.status),
            _buildDataRow('Bike/Car-No.', entry.carBikeNo),
            _buildDataRow('Description', entry.description),
            _buildDataRow('Fuel-Cost', _calculateTotalFuelCost(entry.fuelCost, entry.distance)),
            _buildDataRow('Start Time', entry.startTime),
            _buildDataRow('End Time', entry.endTime),
            _buildDataRow('Total Time', entry.totalTime),
            _buildDataRow('Starting Location', entry.startLocation),
            _buildDataRow('Ending Location', entry.endLocation),
            _buildDataRow('Distance (km)', entry.distance),
          ],
        ),
      ),
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(int index, int entryNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Entry'),
          content: Text('Do you want to Delete (Entry #$entryNumber)?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await StorageLogic.deleteEntry(index);
                _loadEntries();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Entry #$entryNumber deleted'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }


  Widget _buildDataRow(String heading, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              heading,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value ?? '-',
              style: TextStyle(
                color: value != null ? Colors.black87 : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateTotalFuelCost(String? rateStr, String? distanceStr) {
    if (rateStr == null || distanceStr == null) return '-';
    
    try {
      final double rate = double.parse(rateStr);
      final double distance = double.parse(distanceStr);
      final double total = rate * distance;
      return total.toStringAsFixed(2); // Keep 2 decimal places
    } catch (e) {
      return rateStr; // Fallback to original if parsing fails
    }
  }
}
