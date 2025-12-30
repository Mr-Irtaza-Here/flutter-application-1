import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart';
import 'storage_screen.dart';

class FullSheet {
  static Future<void> generateFullSheet(BuildContext context) async {
    debugPrint('FullSheet: generateFullSheet called');
    try {
      final List<StorageEntry> entries = await StorageLogic.getEntries();
      debugPrint('FullSheet: Fetched ${entries.length} entries');
      
      if (entries.isEmpty) {
        debugPrint('FullSheet: No entries found');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No data to export!'), backgroundColor: Colors.orange),
          );
        }
        return;
      }

      // 1. Create Excel Object
      var excel = Excel.createExcel();
      // Rename default sheet
      String defaultSheet = excel.getDefaultSheet()!;
      excel.rename(defaultSheet, 'Data');
      Sheet sheetObject = excel['Data'];

      // Set column widths to prevent "####" display issue
      // Column indices: A=0, B=1, C=2, etc.
      sheetObject.setColumnWidth(0, 20);  // Engineer_Name
      sheetObject.setColumnWidth(1, 12);  // Date
      sheetObject.setColumnWidth(2, 15);  // Cost (PKR) - wider for numbers
      sheetObject.setColumnWidth(3, 15);  // Category
      sheetObject.setColumnWidth(4, 15);  // Type
      sheetObject.setColumnWidth(5, 15);  // Client
      sheetObject.setColumnWidth(6, 12);  // Status
      sheetObject.setColumnWidth(7, 15);  // Bike/Car-No.
      sheetObject.setColumnWidth(8, 25);  // Description - wider for text
      sheetObject.setColumnWidth(9, 15);  // Fuel-Cost - wider for numbers
      sheetObject.setColumnWidth(10, 12); // Start Time
      sheetObject.setColumnWidth(11, 12); // End Time
      sheetObject.setColumnWidth(12, 12); // Total Time
      sheetObject.setColumnWidth(13, 20); // Starting Location
      sheetObject.setColumnWidth(14, 20); // Ending Location
      sheetObject.setColumnWidth(15, 15); // Distance (km) - wider for numbers

      // 2. Add Headers
      List<String> headers = [
        'Engineer_Name', 'Date', 'Cost (PKR)', 'Category', 'Type', 'Client', 'Status', 
        'Bike/Car-No.', 'Description', 'Fuel-Cost', 'Start Time', 'End Time', 
        'Total Time', 'Starting Location', 'Ending Location', 'Distance (km)'
      ];
      
      // We can't easily style bold logic in basic excel package without more code, 
      // but let's just append the row. styling is optional.
      // Actually excel ^4.0.0 supports CellStyle. 
      CellStyle headerStyle = CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
      );

      sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());
      
      // 3. Add Data Rows
      for (var entry in entries) {
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
      
      final String fileName = 'Full_Data_Sheet_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final Directory tempDir = await getTemporaryDirectory();
      debugPrint('FullSheet: Temp dir: ${tempDir.path}');
      
      final File file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(fileBytes);
      debugPrint('FullSheet: File saved at ${file.path}');

      // 5. Share the File
      if (context.mounted) {
        debugPrint('FullSheet: Attempting to share file...');
        final box = context.findRenderObject() as RenderBox?;
        
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Here is the Full Data Sheet (Excel)',
          subject: 'Full Data Sheet',
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
        );
        debugPrint('FullSheet: Share dialog requested');
      }

    } catch (e) {
      debugPrint('Error generating/sharing sheet: $e');
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

  static String _calculateTotalFuelCost(String? rateStr, String? distanceStr) {
    if (rateStr == null || distanceStr == null) return '-';
    try {
      final double rate = double.parse(rateStr);
      final double distance = double.parse(distanceStr);
      final double total = rate * distance;
      return total.toStringAsFixed(2);
    } catch (e) {
      return rateStr;
    }
  }
}
