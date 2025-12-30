import 'package:flutter/material.dart';
import 'full_sheet.dart';
import 'partial_sheet.dart';

class SheetButton extends StatelessWidget {
  const SheetButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
      backgroundColor: Colors.teal,
      child: const Icon(Icons.grid_on, color: Colors.white),
    );
  }
}

class SheetSideMenu extends StatelessWidget {
  const SheetSideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 250,
      child: Column(
        children: [
          Container(
            height: 120, // Adjust header height as needed
            color: Colors.teal,
            width: double.infinity,
            alignment: Alignment.center,
            child: const Text(
              'Sheet Options',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildMenuButton(context, 'Full Sheet', Icons.table_chart, () {
            Navigator.pop(context); // Close the drawer
            debugPrint('SheetButton: Full Sheet pressed');
            FullSheet.generateFullSheet(context);
          }),
          _buildMenuButton(context, 'Partial Sheet', Icons.grid_goldenratio, () {
            Navigator.pop(context); // Close the drawer
            debugPrint('SheetButton: Partial Sheet pressed');
            PartialSheet.showDateRangeDialog(context);
          }),
          _buildMenuButton(context, 'Client Sheet', Icons.person_search, () {
            // TODO: Implement Client Sheet navigation/logic
            Navigator.pop(context);
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  elevation: 2,
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        width: double.infinity, // extend width
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, color: Colors.teal),
          label: Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            elevation: 2,
          ),
        ),
      ),
    );
  }
}
