import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CostInputField extends StatefulWidget {
  final String? cost;
  final Function(String?) onCostChanged;

  const CostInputField({
    super.key,
    this.cost,
    required this.onCostChanged,
  });

  @override
  State<CostInputField> createState() => _CostInputFieldState();
}

class _CostInputFieldState extends State<CostInputField> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.cost ?? '');
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
    // Get raw numbers only
    String rawNumbers = _controller.text.replaceAll(RegExp(r'[^0-9]'), '');
    widget.onCostChanged(rawNumbers.isEmpty ? null : rawNumbers);
  }

  // Format number in Pakistani Rupee format (12,34,567)
  String _formatPakistaniRupees(String value) {
    // Remove all non-digits
    String numbers = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (numbers.isEmpty) {
      return '';
    }

    // Pakistani format: last 3 digits, then groups of 2
    String formatted = '';
    int length = numbers.length;
    
    if (length <= 3) {
      formatted = numbers;
    } else {
      // Get last 3 digits
      String lastThree = numbers.substring(length - 3);
      String remaining = numbers.substring(0, length - 3);
      
      // Add commas every 2 digits for remaining part
      List<String> parts = [];
      while (remaining.length > 2) {
        parts.insert(0, remaining.substring(remaining.length - 2));
        remaining = remaining.substring(0, remaining.length - 2);
      }
      if (remaining.isNotEmpty) {
        parts.insert(0, remaining);
      }
      
      formatted = '${parts.join(',')},${lastThree}';
    }

    return 'Rs $formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        const Text(
          'Cost (PKR)',
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
              FilteringTextInputFormatter.digitsOnly,
              _PakistaniRupeeFormatter(),
            ],
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: 'Enter cost',
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
                  Icons.account_balance_wallet_rounded,
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

// Custom TextInputFormatter for Pakistani Rupee format
class _PakistaniRupeeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Get only digits from new value
    String numbers = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (numbers.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Format the number
    String formatted = _formatWithCommas(numbers);
    
    // Add Rs prefix
    String finalText = 'Rs $formatted';

    return TextEditingValue(
      text: finalText,
      selection: TextSelection.collapsed(offset: finalText.length),
    );
  }

  String _formatWithCommas(String numbers) {
    int length = numbers.length;
    
    if (length <= 3) {
      return numbers;
    }

    // Pakistani format: last 3 digits, then groups of 2
    String lastThree = numbers.substring(length - 3);
    String remaining = numbers.substring(0, length - 3);
    
    List<String> parts = [];
    while (remaining.length > 2) {
      parts.insert(0, remaining.substring(remaining.length - 2));
      remaining = remaining.substring(0, remaining.length - 2);
    }
    if (remaining.isNotEmpty) {
      parts.insert(0, remaining);
    }
    
    return '${parts.join(',')},${lastThree}';
  }
}
