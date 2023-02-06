import 'package:flutter/material.dart';
import 'package:skadi/skadi.dart';

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
          Text(
            hint,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SpaceY(),
          Row(
            children: [
              TextFormField(
                readOnly: readOnly,
                validator: (value) => SkadiFormValidator.validateField(value!, field: hint),
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ).expanded,
              const SpaceX(16),
              if (onPickPath != null)
                IconButton(
                  icon: const Icon(Icons.folder_open),
                  onPressed: onPickPath,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
