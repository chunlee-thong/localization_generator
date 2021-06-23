import 'package:flutter/material.dart';
import 'package:localization_generator/constant/app_config.dart';

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
      applicationVersion: AppConfig.APP_VERSION,
      children: [
        Text("Maintainer: Chunlee Thong"),
      ],
    );
  }
}
