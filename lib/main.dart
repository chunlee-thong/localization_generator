import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'src/model/project_model.dart';
import 'src/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory supportDir = kReleaseMode ? await getApplicationSupportDirectory() : await getTemporaryDirectory();
  //Window: ~/Appdata/roaming/com.chunlee/localization_generator
  //MAC: ~/Library/Application support/com.chunlee.localization_generator
  await Hive.initFlutter(supportDir.path);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    Hive.registerAdapter(ProjectModelAdapter());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Localization generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
