import 'package:flutter/material.dart';

class DescriptionField extends StatefulWidget {
  final String? description;
  final Function(String?) onDescriptionChanged;

  const DescriptionField({
    super.key,
    this.description,
    required this.onDescriptionChanged,
  });

  @override
  State<DescriptionField> createState() => _DescriptionFieldState();
}

class _DescriptionFieldState extends State<DescriptionField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.description ?? '');
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.onDescriptionChanged(_controller.text.isEmpty ? null : _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        const Text(
          'Description',
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
            maxLines: 3, // Allow multiple lines for description
            minLines: 1,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Enter Description',
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
                  Icons.description_rounded,
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
