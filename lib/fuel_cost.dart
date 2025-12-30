import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FuelCostField extends StatefulWidget {
  final String? fuelCost;
  final Function(String?) onFuelCostChanged;

  const FuelCostField({
    super.key,
    this.fuelCost,
    required this.onFuelCostChanged,
  });

  @override
  State<FuelCostField> createState() => _FuelCostFieldState();
}

class _FuelCostFieldState extends State<FuelCostField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.fuelCost ?? '');
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(FuelCostField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync controller when external value changes (e.g., from Add Fuel-Cost dialog)
    if (widget.fuelCost != oldWidget.fuelCost && widget.fuelCost != _controller.text) {
      _controller.removeListener(_onTextChanged); // Prevent callback loop
      _controller.text = widget.fuelCost ?? '';
      _controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.onFuelCostChanged(_controller.text.isEmpty ? null : _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        const Text(
          'Fuel-Cost (per km)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        // Input Field
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')), // Allow digits and optional decimal point
            ],
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Enter Fuel Cost',
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
                  Icons.local_gas_station_rounded,
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
