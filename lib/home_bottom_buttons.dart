import 'package:flutter/material.dart';

class HomeBottomButtons extends StatelessWidget {
  final VoidCallback onOpenMaps;
  final VoidCallback onAddData;
  final VoidCallback onCheckUpdates;

  const HomeBottomButtons({
    super.key,
    required this.onOpenMaps,
    required this.onAddData,
    required this.onCheckUpdates,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildButton(
          label: 'Open Maps',
          icon: Icons.map_rounded,
          color: Colors.blue.shade600,
          onPressed: onOpenMaps,
        ),
        const SizedBox(height: 12),
        _buildButton(
          label: 'Add Data to storage',
          icon: Icons.save_rounded,
          color: Colors.teal.shade600,
          onPressed: onAddData,
        ),
        const SizedBox(height: 12),
        _buildButton(
          label: 'Check for updates',
          icon: Icons.system_update_rounded,
          color: Colors.orange.shade700, // Distinct color for system action
          onPressed: onCheckUpdates,
        ),
      ],
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
