import 'package:flutter/material.dart';

class AppInfoDialog extends StatelessWidget {
  const AppInfoDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AboutDialog(
      applicationName: "Localization Generator",
      applicationIcon: Image.asset(
        "assets/images/app-icon.png",
        width: 64,
      ),
      applicationVersion: "2.3",
      children: const [
        Text("Maintainer: Chunlee Thong"),
      ],
    );
  }
}
