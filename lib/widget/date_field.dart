import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormDate extends StatelessWidget {
  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const FormDate({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      validator: validator,
      onTap: () async {
        DateTime now = DateTime.now();
        DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
        DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: now,
          firstDate: firstDayOfMonth,
          lastDate: lastDayOfMonth,
        );

        if (pickedDate != null) {
          String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
          controller.text = formattedDate;
        }
      },
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        suffixIcon: const Padding(
          padding: EdgeInsets.only(right: 12),
          child: Icon(Icons.calendar_today),
        ),
        filled: true,
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(
            color: Colors.black,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          borderSide: BorderSide(
            color: Colors.black,
            width: 2.0,
          ),
        ),
      ),
    );
  }
}
