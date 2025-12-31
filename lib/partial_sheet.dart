import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart';
import 'storage_screen.dart';

class PartialSheet {
  static DateTime? _startDate;
  static DateTime? _endDate;

  static Future<void> showDateRangeDialog(BuildContext context) async {
    final TextEditingController startDateController = TextEditingController();
    final TextEditingController endDateController = TextEditingController();
    _startDate = null;
    _endDate = null;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                const Text(
                  'Partial Sheet Export',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Starting Date Field
                const Text(
                  'Starting Date',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: startDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Select starting date',
                    prefixIcon: const Icon(Icons.calendar_today, color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.teal, width: 2),
                    ),
                  ),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: dialogContext,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      _startDate = picked;
                      startDateController.text = 
                          '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Ending Date Field
                const Text(
                  'Ending Date',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: endDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Select ending date',
                    prefixIcon: const Icon(Icons.calendar_today, color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.teal, width: 2),
                    ),
                  ),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: dialogContext,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      _endDate = picked;
                      endDateController.text = 
                          '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Buttons Row
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[400],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Export Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Validate dates are selected
                          if (_startDate == null || _endDate == null) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text('Please select both starting and ending dates'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          // Validate start date is before or equal to end date
                          if (_startDate!.isAfter(_endDate!)) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text('Starting date must be before or equal to ending date'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          Navigator.pop(dialogContext);
                          await _generatePartialSheet(context, _startDate!, _endDate!);
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
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
  }

  /// Generate partial sheet with entries filtered by date range
  static Future<void> _generatePartialSheet(
    BuildContext context,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Normalize range dates to remove time components
    final normalizedStart = DateTime(startDate.year, startDate.month, startDate.day);
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);

    debugPrint('PartialSheet: generatePartialSheet called');
    debugPrint('PartialSheet: Start Range: $normalizedStart, End Range: $normalizedEnd');
    
    try {
      final List<StorageEntry> allEntries = await StorageLogic.getEntries();
      debugPrint('PartialSheet: Fetched ${allEntries.length} total entries');

      // Filter entries by date range (inclusive)
      final List<StorageEntry> filteredEntries = [];
      
      for (var entry in allEntries) {
        if (entry.date == null || entry.date!.isEmpty) {
          debugPrint('PartialSheet: Skipping entry with null/empty date');
          continue;
        }
        
        final DateTime? entryDateRaw = _parseDate(entry.date!);
        if (entryDateRaw == null) {
          debugPrint('PartialSheet: FAILED TO PARSE date: "${entry.date}"');
          continue;
        }

        // Normalize entry date
        final entryDate = DateTime(entryDateRaw.year, entryDateRaw.month, entryDateRaw.day);

        // Check if entry date is within range (inclusive)
        final bool isAfterStart = !entryDate.isBefore(normalizedStart);
        final bool isBeforeEnd = !entryDate.isAfter(normalizedEnd);
        
        debugPrint('PartialSheet: Entry Date: $entryDate | In Range: ${isAfterStart && isBeforeEnd} (isAfterStart: $isAfterStart, isBeforeEnd: $isBeforeEnd)');

        if (isAfterStart && isBeforeEnd) {
          filteredEntries.add(entry);
        }
      }

      debugPrint('PartialSheet: Filtered to ${filteredEntries.length} entries in date range');

      // 1. Capture render box before any awaiting if possible, 
      // or use a more robust check. We'll use the result of allEntries to show feedback.
      if (filteredEntries.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No matches found (Checked ${allEntries.length} total entries)'),
              backgroundColor: Colors.orange,
              action: SnackBarAction(
                label: 'Details',
                textColor: Colors.white,
                onPressed: () {
                  debugPrint('--- DIAGNOSTIC: ALL STORED DATES ---');
                  for (var e in allEntries) {
                    debugPrint('Stored Date: "${e.date}" -> Parsed As: ${_parseDate(e.date ?? "")}');
                  }
                  debugPrint('------------------------------------');
                },
              ),
            ),
          );
        }
        return;
      }

      // If we have entries, proceed to export
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exporting ${filteredEntries.length} entries...'),
            backgroundColor: Colors.teal,
          ),
        );
      }

      // 1. Create Excel Object
      var excel = Excel.createExcel();
      // Rename default sheet
      String defaultSheet = excel.getDefaultSheet()!;
      excel.rename(defaultSheet, 'Data');
      Sheet sheetObject = excel['Data'];

      // Set column widths to prevent "####" display issue
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

      // 2. Add Headers (same as full_sheet.dart)
      List<String> headers = [
        'Engineer_Name', 'Date', 'Cost (PKR)', 'Category', 'Type', 'Client', 'Status',
        'Bike/Car-No.', 'Description', 'Fuel-Cost', 'Start Time', 'End Time',
        'Total Time', 'Starting Location', 'Ending Location', 'Distance (km)'
      ];

      sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());

      // 3. Add Data Rows
      for (var entry in filteredEntries) {
        List<CellValue> row = [];
        row.add(TextCellValue(entry.engineerName ?? ''));
        row.add(TextCellValue(entry.date ?? ''));
        
        // Cost (PKR) - parse as number for Excel calculations
        row.add(_parseAsNumber(entry.cost));
        
        row.add(TextCellValue(entry.category ?? ''));
        row.add(TextCellValue(entry.type ?? ''));
        row.add(TextCellValue(entry.client ?? ''));
        row.add(TextCellValue(entry.status ?? ''));
        row.add(TextCellValue(entry.carBikeNo ?? ''));
        row.add(TextCellValue(entry.description ?? ''));
        
        // Calculated Fuel Cost - as number for Excel calculations
        row.add(_calculateTotalFuelCostAsNumber(entry.fuelCost, entry.distance));
        
        row.add(TextCellValue(entry.startTime ?? ''));
        row.add(TextCellValue(entry.endTime ?? ''));
        row.add(TextCellValue(entry.totalTime ?? ''));
        row.add(TextCellValue(entry.startLocation ?? ''));
        row.add(TextCellValue(entry.endLocation ?? ''));
        
        // Distance (km) - parse as number for Excel calculations
        row.add(_parseAsNumber(entry.distance));

        sheetObject.appendRow(row);
      }

      // 4. Save to Temp Directory
      var fileBytes = excel.save();
      if (fileBytes == null) {
        throw Exception('Failed to generate Excel file bytes.');
      }

      // Format date range for filename
      String startStr = '${startDate.day.toString().padLeft(2, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.year}';
      String endStr = '${endDate.day.toString().padLeft(2, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.year}';
      final String fileName = 'Partial_Data_Sheet_${startStr}_to_${endStr}.xlsx';
      
      final Directory tempDir = await getTemporaryDirectory();
      debugPrint('PartialSheet: Temp dir: ${tempDir.path}');

      final File file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(fileBytes);
      debugPrint('PartialSheet: File saved at ${file.path}');

      // 5. Share the File
      debugPrint('PartialSheet: Attempting to share file...');
      
      // We check mounted again, but if it's false, we attempt to share without origin
      // which often works on Android but might need origin on iOS/iPad.
      final RenderBox? box = context.mounted ? context.findRenderObject() as RenderBox? : null;
      final Rect? shareOrigin = box != null 
          ? box.localToGlobal(Offset.zero) & box.size 
          : null;

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Here is the Partial Data Sheet (Excel) from $startStr to $endStr',
        subject: 'Partial Data Sheet',
        sharePositionOrigin: shareOrigin,
      );
      debugPrint('PartialSheet: Share dialog requested');

    } catch (e) {
      debugPrint('Error generating/sharing partial sheet: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Parse date string in various formats to DateTime with heuristics for day/month order
  static DateTime? _parseDate(String dateStr) {
    try {
      final trimmedDate = dateStr.trim();
      
      // 1. Try standard ISO format (YYYY-MM-DD)
      final isoParsed = DateTime.tryParse(trimmedDate);
      if (isoParsed != null) {
        // Double check for YYYY-DD-MM if isoParsed exists but might be flipped
        // (though tryParse usually strictly expects YYYY-MM-DD)
        return isoParsed;
      }

      // 2. Manual parsing with heuristics
      final parts = trimmedDate.split(RegExp(r'[-/ .]'));
      if (parts.length >= 3) {
        int year, month, day;
        
        if (parts[0].length == 4) {
          // Format looks like YYYY-??-??
          year = int.parse(parts[0]);
          int p1 = int.parse(parts[1]);
          int p2 = int.parse(parts[2]);
          
          if (p1 > 12) {
            // p1 must be day, p2 must be month (YYYY-DD-MM)
            day = p1;
            month = p2;
          } else if (p2 > 12) {
            // p2 must be day, p1 must be month (YYYY-MM-DD)
            day = p2;
            month = p1;
          } else {
            // Ambiguous (both <= 12), default to YYYY-MM-DD
            month = p1;
            day = p2;
          }
        } else if (parts[2].length == 4) {
          // Format looks like ??-??-YYYY
          year = int.parse(parts[2]);
          int p0 = int.parse(parts[0]);
          int p1 = int.parse(parts[1]);
          
          if (p0 > 12) {
            // p0 must be day, p1 must be month (DD-MM-YYYY)
            day = p0;
            month = p1;
          } else if (p1 > 12) {
            // p1 must be day, p0 must be month (MM-DD-YYYY)
            day = p1;
            month = p0;
          } else {
            // Ambiguous (both <= 12), default to DD-MM-YYYY
            day = p0;
            month = p1;
          }
        } else {
          debugPrint('PartialSheet: Unknown date format: $trimmedDate');
          return null;
        }
        
        return DateTime(year, month, day);
      }
    } catch (e) {
      debugPrint('PartialSheet: Error parsing date: $dateStr - $e');
    }
    return null;
  }

  /// Parses a string value as a number and returns DoubleCellValue.
  /// Falls back to TextCellValue if parsing fails.
  static CellValue _parseAsNumber(String? value) {
    if (value == null || value.isEmpty) return TextCellValue('');
    try {
      // Remove any non-numeric characters except decimal point and minus sign
      String cleanedValue = value.replaceAll(RegExp(r'[^\d.-]'), '');
      if (cleanedValue.isEmpty) return TextCellValue(value);

      final double number = double.parse(cleanedValue);
      return DoubleCellValue(number);
    } catch (e) {
      // If parsing fails, return as text
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
