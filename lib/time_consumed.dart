import 'package:flutter/material.dart';

class TimeConsumedField extends StatefulWidget {
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final Function(TimeOfDay?, TimeOfDay?, double) onTimeChanged;

  const TimeConsumedField({
    super.key,
    this.startTime,
    this.endTime,
    required this.onTimeChanged,
  });

  @override
  State<TimeConsumedField> createState() => _TimeConsumedFieldState();
}

class _TimeConsumedFieldState extends State<TimeConsumedField> {
  // Store times as double values (0.0 to 24.0)
  // 0.0 = 12:00 AM, 12.0 = 12:00 PM, 24.0 = 12:00 AM (next day)
  double _startTimeValue = 0.0; // Default 12:00 AM
  double _endTimeValue = 0.0;   // Default 12:00 AM

  @override
  void initState() {
    super.initState();
    if (widget.startTime != null) {
      _startTimeValue = _timeOfDayToDouble(widget.startTime!);
    }
    if (widget.endTime != null) {
      _endTimeValue = _timeOfDayToDouble(widget.endTime!);
    }
  }

  double _timeOfDayToDouble(TimeOfDay time) {
    return time.hour + time.minute / 60.0;
  }

  TimeOfDay _doubleToTimeOfDay(double value) {
    int hour = value.floor();
    int minute = ((value - hour) * 60).round();
    if (hour >= 24) hour -= 24;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(double value) {
    final time = _doubleToTimeOfDay(value);
    // Use standard formatting logic
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _updateValues() {
    final start = _doubleToTimeOfDay(_startTimeValue);
    final end = _doubleToTimeOfDay(_endTimeValue);
    
    // Calculate difference
    // If end time is before start time, assume it's the next day (add 24 hours to end time)
    double endVal = _endTimeValue;
    if (endVal < _startTimeValue) {
      endVal += 24;
    }
    
    final diff = endVal - _startTimeValue;
    
    widget.onTimeChanged(start, end, diff);
  }

  @override
  Widget build(BuildContext context) {
    // Calculate difference for display
    double endVal = _endTimeValue;
    if (endVal < _startTimeValue) {
      endVal += 24;
    }
    final difference = endVal - _startTimeValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Time Consumed',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            children: [
              // Start Time Slider
              _buildTimeSlider(
                label: 'Start Time',
                value: _startTimeValue,
                color: Colors.green,
                onChanged: (val) {
                  setState(() {
                    _startTimeValue = val;
                  });
                  _updateValues();
                },
              ),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              // End Time Slider
              _buildTimeSlider(
                label: 'End Time',
                value: _endTimeValue,
                color: Colors.red,
                onChanged: (val) {
                  setState(() {
                    _endTimeValue = val;
                  });
                  _updateValues();
                },
              ),
              
              const SizedBox(height: 24),
              
              // Calculated Result Field
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.timer_rounded,
                          color: Colors.teal.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Total Time:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${difference.toStringAsFixed(2)} hrs',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlider({
    required String label,
    required double value,
    required Color color,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            Row(
              children: [
                // Decrement Button
                IconButton(
                  icon: Icon(Icons.remove_circle_outline, color: color, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    double newValue = value - (1.0 / 60.0);
                    if (newValue < 0) newValue = 24.0 + newValue; // Wrap around 0->24
                    onChanged(newValue);
                  },
                ),
                const SizedBox(width: 8),
                // Time Display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _formatTime(value),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Increment Button
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: color, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    double newValue = value + (1.0 / 60.0);
                    if (newValue >= 24.0) newValue = newValue - 24.0; // Wrap around 24->0
                    onChanged(newValue);
                  },
                ),
              ],
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.2),
            thumbColor: color,
            overlayColor: color.withOpacity(0.2),
            trackHeight: 4.0,
          ),
          child: Slider(
            value: value,
            min: 0.0,
            max: 24.0, // 24 hours
            divisions: 1440, // Every 1 minute (24 * 60)
            label: _formatTime(value),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
