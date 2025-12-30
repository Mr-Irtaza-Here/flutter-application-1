import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StartEndDistanceField extends StatefulWidget {
  final String? startLocation;
  final String? endLocation;
  final String? distance;
  final Function(String?) onStartLocationChanged;
  final Function(String?) onEndLocationChanged;
  final Function(String?) onDistanceChanged;

  const StartEndDistanceField({
    super.key,
    this.startLocation,
    this.endLocation,
    this.distance,
    required this.onStartLocationChanged,
    required this.onEndLocationChanged,
    required this.onDistanceChanged,
  });

  @override
  State<StartEndDistanceField> createState() => _StartEndDistanceFieldState();
}

class _StartEndDistanceFieldState extends State<StartEndDistanceField> {
  late TextEditingController _startController;
  late TextEditingController _endController;
  late TextEditingController _distanceController;

  @override
  void initState() {
    super.initState();
    _startController = TextEditingController(text: widget.startLocation ?? '');
    _endController = TextEditingController(text: widget.endLocation ?? '');
    _distanceController = TextEditingController(text: widget.distance ?? '');

    _startController.addListener(_onStartChanged);
    _endController.addListener(_onEndChanged);
    _distanceController.addListener(_onDistanceChanged);
  }

  @override
  void dispose() {
    _startController.removeListener(_onStartChanged);
    _endController.removeListener(_onEndChanged);
    _distanceController.removeListener(_onDistanceChanged);
    
    _startController.dispose();
    _endController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  void _onStartChanged() {
    widget.onStartLocationChanged(_startController.text.isEmpty ? null : _startController.text);
  }

  void _onEndChanged() {
    widget.onEndLocationChanged(_endController.text.isEmpty ? null : _endController.text);
  }

  void _onDistanceChanged() {
    widget.onDistanceChanged(_distanceController.text.isEmpty ? null : _distanceController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Starting Location
        _buildTextField(
          label: 'Starting Location',
          controller: _startController,
          icon: Icons.my_location_rounded,
          hint: 'Enter Starting Location',
        ),
        const SizedBox(height: 16),
        
        // Ending Location
        _buildTextField(
          label: 'Ending Location',
          controller: _endController,
          icon: Icons.location_on_rounded,
          hint: 'Enter Ending Location',
        ),
        const SizedBox(height: 16),
        
        // Distance
        _buildTextField(
          label: 'Distance (km)',
          controller: _distanceController,
          icon: Icons.straighten_rounded,
          hint: 'Enter Distance',
          isNumeric: true,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isNumeric = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumeric 
                ? const TextInputType.numberWithOptions(decimal: true) 
                : TextInputType.text,
            inputFormatters: isNumeric
                ? [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')), // Numbers and dot only
                  ]
                : [],
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: InputBorder.none,
              prefixIcon: Container(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Icon(
                  icon,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
