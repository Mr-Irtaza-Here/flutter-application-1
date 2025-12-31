import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart';
import 'add_client_logic.dart';
import 'storage_screen.dart';

/// ClientSheet handles the client selection dialog for sheet export
/// Accessed via the "Client Sheet" button in Sheet Options menu
class ClientSheet {
  /// Shows the client selection dialog with Export button instead of Done
  static Future<void> showClientSelectionDialog(BuildContext context) async {
    // Load the clients list
    final List<String> clientsList = await AddClientLogic.getClients();
    
    if (!context.mounted) return;
    
    String? tempSelectedClient;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              child: Container(
                padding: const EdgeInsets.all(24),
                constraints: const BoxConstraints(maxHeight: 400),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.grey.shade50,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.people_alt_rounded,
                            color: Colors.teal.shade700,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Select Client',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    // Clients List or Empty State
                    Flexible(
                      child: clientsList.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Text(
                                  'No Clients added yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: clientsList.length,
                              itemBuilder: (context, index) {
                                final client = clientsList[index];
                                final isSelected = tempSelectedClient == client;
                                return ListTile(
                                  title: Text(
                                    client,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color:
                                          isSelected ? Colors.teal : Colors.black87,
                                    ),
                                  ),
                                  leading: Icon(
                                    isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    color: isSelected ? Colors.teal : Colors.grey,
                                  ),
                                  onTap: () {
                                    setDialogState(() {
                                      tempSelectedClient = client;
                                    });
                                  },
                                );
                              },
                            ),
                    ),

                    const SizedBox(height: 16),

                    // Cancel and Export Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.grey.shade400),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (tempSelectedClient != null) {
                                Navigator.of(dialogContext).pop();
                                // Generate and share client-specific sheet
                                _generateClientSheet(context, tempSelectedClient!);
                              } else {
                                ScaffoldMessenger.of(dialogContext).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select a client first'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Export',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Generates and shares an Excel sheet containing only entries for the selected client
  static Future<void> _generateClientSheet(BuildContext context, String clientName) async {
    debugPrint('ClientSheet: Generating sheet for client: $clientName');
    
    try {
      // Fetch all entries from storage
      final List<StorageEntry> allEntries = await StorageLogic.getEntries();
      debugPrint('ClientSheet: Fetched ${allEntries.length} total entries');

      // Filter entries by client name (case-insensitive comparison)
      final List<StorageEntry> filteredEntries = allEntries.where((entry) {
        return entry.client != null && 
               entry.client!.toLowerCase() == clientName.toLowerCase();
      }).toList();

      debugPrint('ClientSheet: Found ${filteredEntries.length} entries for client: $clientName');

      if (filteredEntries.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No entries found for client: $clientName'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Show progress feedback
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exporting ${filteredEntries.length} entries for $clientName...'),
            backgroundColor: Colors.teal,
          ),
        );
      }

      // Create Excel workbook
      var excel = Excel.createExcel();
      String defaultSheet = excel.getDefaultSheet()!;
      excel.rename(defaultSheet, 'Data');
      Sheet sheetObject = excel['Data'];

      // Set column widths
      sheetObject.setColumnWidth(0, 20);  // Engineer_Name
      sheetObject.setColumnWidth(1, 12);  // Date
      sheetObject.setColumnWidth(2, 15);  // Cost (PKR)
      sheetObject.setColumnWidth(3, 15);  // Category
      sheetObject.setColumnWidth(4, 15);  // Type
      sheetObject.setColumnWidth(5, 15);  // Client
      sheetObject.setColumnWidth(6, 12);  // Status
      sheetObject.setColumnWidth(7, 15);  // Bike/Car-No.
      sheetObject.setColumnWidth(8, 25);  // Description
      sheetObject.setColumnWidth(9, 15);  // Fuel-Cost
      sheetObject.setColumnWidth(10, 12); // Start Time
      sheetObject.setColumnWidth(11, 12); // End Time
      sheetObject.setColumnWidth(12, 12); // Total Time
      sheetObject.setColumnWidth(13, 20); // Starting Location
      sheetObject.setColumnWidth(14, 20); // Ending Location
      sheetObject.setColumnWidth(15, 15); // Distance (km)

      // Add headers
      List<String> headers = [
        'Engineer_Name', 'Date', 'Cost (PKR)', 'Category', 'Type', 'Client', 'Status',
        'Bike/Car-No.', 'Description', 'Fuel-Cost', 'Start Time', 'End Time',
        'Total Time', 'Starting Location', 'Ending Location', 'Distance (km)'
      ];

      sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());

      // Add data rows
      for (var entry in filteredEntries) {
        List<CellValue> row = [];
        row.add(TextCellValue(entry.engineerName ?? ''));
        row.add(TextCellValue(entry.date ?? ''));
        row.add(_parseAsNumber(entry.cost));
        row.add(TextCellValue(entry.category ?? ''));
        row.add(TextCellValue(entry.type ?? ''));
        row.add(TextCellValue(entry.client ?? ''));
        row.add(TextCellValue(entry.status ?? ''));
        row.add(TextCellValue(entry.carBikeNo ?? ''));
        row.add(TextCellValue(entry.description ?? ''));
        row.add(_calculateTotalFuelCostAsNumber(entry.fuelCost, entry.distance));
        row.add(TextCellValue(entry.startTime ?? ''));
        row.add(TextCellValue(entry.endTime ?? ''));
        row.add(TextCellValue(entry.totalTime ?? ''));
        row.add(TextCellValue(entry.startLocation ?? ''));
        row.add(TextCellValue(entry.endLocation ?? ''));
        row.add(_parseAsNumber(entry.distance));

        sheetObject.appendRow(row);
      }

      // Save to temp directory
      var fileBytes = excel.save();
      if (fileBytes == null) {
        throw Exception('Failed to generate Excel file bytes.');
      }

      // Create filename with client name (sanitize for file system)
      String sanitizedClientName = clientName.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
      final String fileName = 'Client_Sheet_${sanitizedClientName}_${DateTime.now().millisecondsSinceEpoch}.xlsx';

      final Directory tempDir = await getTemporaryDirectory();
      debugPrint('ClientSheet: Temp dir: ${tempDir.path}');

      final File file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(fileBytes);
      debugPrint('ClientSheet: File saved at ${file.path}');

      // Share the file
      debugPrint('ClientSheet: Attempting to share file...');
      final RenderBox? box = context.mounted ? context.findRenderObject() as RenderBox? : null;
      final Rect? shareOrigin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Here is the Client Data Sheet for $clientName (Excel)',
        subject: 'Client Sheet - $clientName',
        sharePositionOrigin: shareOrigin,
      );
      debugPrint('ClientSheet: Share dialog requested');

    } catch (e) {
      debugPrint('Error generating/sharing client sheet: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Parses a string value as a number and returns DoubleCellValue.
  /// Falls back to TextCellValue if parsing fails.
  static CellValue _parseAsNumber(String? value) {
    if (value == null || value.isEmpty) return TextCellValue('');
    try {
      String cleanedValue = value.replaceAll(RegExp(r'[^\d.-]'), '');
      if (cleanedValue.isEmpty) return TextCellValue(value);

      final double number = double.parse(cleanedValue);
      return DoubleCellValue(number);
    } catch (e) {
      return TextCellValue(value);
    }
  }

  /// Calculates total fuel cost and returns as DoubleCellValue for Excel calculations.
  static CellValue _calculateTotalFuelCostAsNumber(String? rateStr, String? distanceStr) {
    if (rateStr == null || distanceStr == null || rateStr.isEmpty || distanceStr.isEmpty) {
      return TextCellValue('-');
    }
    try {
      final double rate = double.parse(rateStr);
      final double distance = double.parse(distanceStr);
      final double total = rate * distance;
      return DoubleCellValue(total);
    } catch (e) {
      return TextCellValue(rateStr);
    }
  }
}
