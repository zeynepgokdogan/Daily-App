import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Calendar extends StatefulWidget {
  final ValueChanged<DateTime?> onDateChanged;

  const Calendar({Key? key, required this.onDateChanged}) : super(key: key);

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime? _selectedDate;
  bool _isLeftArrowPressed = false;
  bool _isRightArrowPressed = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        widget.onDateChanged(_selectedDate);
        print(
            "Selected date in Calendar: ${DateFormat('dd MMM yyyy').format(_selectedDate!)}"); // Debug print
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String displayDate = _selectedDate != null
        ? DateFormat('dd MMM yyyy').format(_selectedDate!)
        : DateFormat('dd MMM yyyy').format(DateTime.now());

    return Container(
      width: 359,
      height: 50,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      margin: const EdgeInsets.only(top: 101, left: 22),
      decoration: const BoxDecoration(
        color: Color(0xFFF26950),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTapDown: (_) {
              setState(() {
                _isLeftArrowPressed = true;
              });
            },
            onTapUp: (_) {
              setState(() {
                _isLeftArrowPressed = false;
                _selectedDate = (_selectedDate ?? DateTime.now())
                    .subtract(const Duration(days: 1));
                widget.onDateChanged(_selectedDate);
                print(
                    "Date changed to: ${DateFormat('dd MMM yyyy').format(_selectedDate!)}"); // Debug print
              });
            },
            onTapCancel: () {
              setState(() {
                _isLeftArrowPressed = false;
              });
            },
            child: Icon(
              Icons.arrow_left,
              color: _isLeftArrowPressed ? Colors.grey : Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Text(
              displayDate,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTapDown: (_) {
              setState(() {
                _isRightArrowPressed = true;
              });
            },
            onTapUp: (_) {
              setState(() {
                _isRightArrowPressed = false;
                _selectedDate = (_selectedDate ?? DateTime.now())
                    .add(const Duration(days: 1));
                widget.onDateChanged(_selectedDate);
                print(
                    "Date changed to: ${DateFormat('dd MMM yyyy').format(_selectedDate!)}"); // Debug print
              });
            },
            onTapCancel: () {
              setState(() {
                _isRightArrowPressed = false;
              });
            },
            child: Icon(
              Icons.arrow_right,
              color: _isRightArrowPressed ? Colors.grey : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
