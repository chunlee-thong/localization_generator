import 'package:flutter/material.dart';
import 'package:jin_widget_helper/jin_widget_helper.dart';

class SimpleTextField extends StatelessWidget {
  final bool readOnly;
  final TextEditingController controller;
  final String hint;
  final VoidCallback onPickPath;
  const SimpleTextField({
    Key key,
    this.readOnly,
    this.controller,
    this.hint,
    this.onPickPath,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(hint, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          SpaceY(),
          Row(
            children: [
              TextFormField(
                readOnly: readOnly,
                validator: (value) => JinFormValidator.validateField(value, hint),
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ).expanded,
              SpaceX(16),
              IconButton(
                icon: Icon(Icons.folder_open),
                onPressed: onPickPath,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
