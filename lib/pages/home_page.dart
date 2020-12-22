import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:filepicker_windows/filepicker_windows.dart' as picker;
import 'package:flutter/material.dart';
import 'package:jin_widget_helper/jin_widget_helper.dart';
import 'package:localization_generator/services/local_storage_service.dart';
import 'package:localization_generator/util/generator.dart';
import 'package:localization_generator/widgets/simple_text_field.dart';
import 'package:toast/toast.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with FormPageMixin {
  TextEditingController excelPathTC;
  TextEditingController jsonPathTC;
  TextEditingController localeKeyPathTC;

  Future<bool> dataFuture;

  Future<bool> getRecentList() async {
    await LocalStorageService.init();
    if (LocalStorageService.previousPath.isNotEmpty) {
      excelPathTC.text = LocalStorageService.previousPath[0];
      jsonPathTC.text = LocalStorageService.previousPath[1];
      localeKeyPathTC.text = LocalStorageService.previousPath[2];
    }
    return true;
  }

  Future<void> onGenerateFile() async {
    if (isFormValidated) {
      String jsonPath = jsonPathTC.text.trim();
      String localeClassPath = localeKeyPathTC.text.trim();
      String excelFilePath = excelPathTC.text.trim();

      try {
        await LocalizationGenerator.generate(
          excelFilePath: excelFilePath,
          saveJSONPath: jsonPath,
          saveLocaleKeyClassPath: localeClassPath,
        );
        await LocalStorageService.save(excelFilePath);
        await LocalStorageService.save(jsonPath);
        await LocalStorageService.save(localeClassPath);
        await LocalStorageService.savePreviousPath(
            excelFilePath, jsonPath, localeClassPath);
        refreshList();
        Toast.show("Success", context);
      } catch (e) {
        if (e is FileSystemException) {
          Toast.show(e.osError.message, context, duration: 3);
        } else
          Toast.show(e.toString(), context, duration: 3);
      }
    }
  }

  void refreshList() {
    setState(() {});
  }

  void onPickExcelFile() async {
    final file = picker.OpenFilePicker();
    file.hidePinnedPlaces = true;
    file.forcePreviewPaneOn = true;
    file.filterSpecification = {'Excel file': '*.xlsx'};
    file.title = 'Select an image';
    final result = file.getFile();
    if (result != null) {
      excelPathTC.text = result.path;
    }
  }

  @override
  void initState() {
    dataFuture = getRecentList();
    excelPathTC = TextEditingController();
    jsonPathTC = TextEditingController();
    localeKeyPathTC = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    excelPathTC.dispose();
    jsonPathTC.dispose();
    localeKeyPathTC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Localization Generator"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () async {
              await LocalStorageService.clearAll();
              refreshList();
            },
          )
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(24),
        constraints: BoxConstraints(maxWidth: 1600, minWidth: 720),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildRecentPathList(),
            SpaceX(32),
            buildForm(),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget buildRecentPathList() {
    return Expanded(
      child: FutureHandler<bool>(
          future: dataFuture,
          ready: (_) {
            return Column(
              children: [
                Text(
                  "Recent path",
                  style: TextStyle(fontSize: 32),
                ),
                Expanded(
                  child: ConditionalWidget(
                    condition: LocalStorageService.recentPath.isEmpty,
                    onTrue: Center(child: Text("Empty")),
                    onFalse: ListView.builder(
                      itemCount: LocalStorageService.recentPath.length,
                      padding: EdgeInsets.only(top: 32),
                      itemBuilder: (BuildContext context, int index) {
                        final String path =
                            LocalStorageService.recentPath[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 32),
                          child: ListTile(
                            onTap: () {
                              FlutterClipboard.copy(path).then(
                                (value) => Toast.show('copied', context),
                              );
                            },
                            title: Text(path),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }

  Widget buildForm() {
    return Expanded(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Save Path",
              style: TextStyle(fontSize: 32),
            ),
            SpaceY(32),
            SimpleTextField(
              controller: excelPathTC,
              hint: "Excel file",
              onPickPath: onPickExcelFile,
              readOnly: true,
            ),
            SimpleTextField(
              controller: jsonPathTC,
              hint: "Save json path",
              readOnly: false,
            ),
            SimpleTextField(
              controller: localeKeyPathTC,
              hint: "save localekey class path",
              readOnly: false,
            ),
            JinLoadingButton(
              onPressed: onGenerateFile,
              child: Text("Generate"),
              color: Colors.red,
              textColor: Colors.white,
              margin: EdgeInsets.fromLTRB(0, 24, 54, 0),
            )
          ],
        ),
      ),
    );
  }
}
