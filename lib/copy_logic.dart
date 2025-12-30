import 'package:flutter/material.dart';
import 'storage_screen.dart';

/// Copy Logic for Storage Entries
class CopyLogic {
  /// Show copy confirmation dialog for a storage entry
  static void showCopyDialog({
    required BuildContext context,
    required StorageEntry entry,
    required int entryNumber,
    required VoidCallback onEntryCopied,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Copy Entry'),
          content: Text('Do you want to copy Entry #$entryNumber?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                
                // Create a copy of the entry with new timestamp
                final copiedEntry = StorageEntry(
                  engineerName: entry.engineerName,
                  date: entry.date,
                  cost: entry.cost,
                  category: entry.category,
                  type: entry.type,
                  client: entry.client,
                  status: entry.status,
                  carBikeNo: entry.carBikeNo,
                  description: entry.description,
                  fuelCost: entry.fuelCost,
                  startTime: entry.startTime,
                  endTime: entry.endTime,
                  totalTime: entry.totalTime,
                  startLocation: entry.startLocation,
                  endLocation: entry.endLocation,
                  distance: entry.distance,
                  timestamp: DateTime.now().toIso8601String(),
                );
                
                await StorageLogic.saveEntry(copiedEntry);
                onEntryCopied();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Entry #$entryNumber copied'),
                    backgroundColor: Colors.blue,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
