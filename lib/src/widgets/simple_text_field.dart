import 'package:flutter/material.dart';
import 'package:sura_flutter/sura_flutter.dart';

class SimpleTextField extends StatelessWidget {
  final bool readOnly;
  final TextEditingController controller;
  final String hint;
  final VoidCallback? onPickPath;
  const SimpleTextField({
    Key? key,
    this.readOnly = false,
    required this.controller,
    required this.hint,
    this.onPickPath,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(hint, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SpaceY(),
          Row(
            children: [
              TextFormField(
                readOnly: readOnly,
                validator: (value) => SuraFormValidator.validateField(value!, field: hint),
                controller: controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ).expanded,
              SpaceX(16),
              if (onPickPath != null)
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
