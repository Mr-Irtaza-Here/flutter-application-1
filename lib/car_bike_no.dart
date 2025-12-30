import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CarBikeNoField extends StatefulWidget {
  final String? number;
  final Function(String?) onNumberChanged;

  const CarBikeNoField({
    super.key,
    this.number,
    required this.onNumberChanged,
  });

  @override
  State<CarBikeNoField> createState() => _CarBikeNoFieldState();
}

class _CarBikeNoFieldState extends State<CarBikeNoField> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.number ?? '');
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.onNumberChanged(_controller.text.isEmpty ? null : _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        const Text(
          'Bike/Car-No.',
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
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Only Allow numbers
              LengthLimitingTextInputFormatter(4), // Max 4 digits
            ],
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Enter Number',
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
                  Icons.directions_car_rounded,
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
