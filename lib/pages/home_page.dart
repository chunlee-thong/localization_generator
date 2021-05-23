import 'dart:io';

import 'package:filepicker_windows/filepicker_windows.dart' as picker;
import 'package:flutter/material.dart';
import 'package:localization_generator/model/project_model.dart';
import 'package:localization_generator/services/local_storage_service.dart';
import 'package:localization_generator/util/generator.dart';
import 'package:localization_generator/widgets/custom_card.dart';
import 'package:localization_generator/widgets/simple_text_field.dart';
import 'package:sura_flutter/sura_flutter.dart';
import 'package:toast/toast.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SuraFormMixin {
  late TextEditingController excelPathTC;
  late TextEditingController jsonPathTC;
  late TextEditingController localeKeyPathTC;
  late TextEditingController projectNameTC;

  FutureManager<List<ProjectModel>> projectManager = FutureManager();

  Future<void> onGenerateFile() async {
    if (isFormValidated) {
      String projectName = projectNameTC.text.trim();
      String jsonPath = jsonPathTC.text.trim();
      String localeClassPath = localeKeyPathTC.text.trim();
      String excelFilePath = excelPathTC.text.trim();

      try {
        await LocalizationGenerator(
          excelFilePath: excelFilePath,
          saveJsonPath: jsonPath,
          saveLocaleKeyClassPath: localeClassPath,
        ).generate();
        await LocalStorageService.saveProject(ProjectModel(
          projectName,
          excelFilePath,
          jsonPath,
          localeClassPath,
        ));
        projectManager.refresh(reloading: false);
        Toast.show("Generated", context);
      } catch (e) {
        if (e is FileSystemException) {
          Toast.show(e.osError!.message, context, duration: 3);
        } else
          Toast.show(e.toString(), context, duration: 3);
      }
    }
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

  void onSelectProject(ProjectModel project) {
    projectNameTC.text = project.name;
    excelPathTC.text = project.excelPath;
    jsonPathTC.text = project.jsonPath;
    localeKeyPathTC.text = project.localeKeyPath;
  }

  // void onPickJsonPath() async {
  //   String? pickedPath = await FilesystemPicker.open(context: context, rootDirectory: initialDir);
  //   if (pickedPath != null) {
  //     jsonPathTC.text = pickedPath;
  //   }
  // }

  // void onPickLocaleKeyPath() async {
  //   String? pickedPath = await FilesystemPicker.open(context: context, rootDirectory: initialDir);
  //   if (pickedPath != null) {
  //     localeKeyPathTC.text = pickedPath;
  //   }
  // }

  @override
  void initState() {
    projectManager.asyncOperation(() async {
      List<ProjectModel> projects = await LocalStorageService.getSavedProject();
      if (projects.isNotEmpty) onSelectProject(projects.first);
      return projects;
    });
    excelPathTC = TextEditingController();
    projectNameTC = TextEditingController();
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Localization Generator V2.0.0"),
        centerTitle: true,
        actions: [
          SuraFlatButton(
            onPressed: () async {
              await LocalStorageService.clearAll();
              projectManager.refresh();
            },
            textColor: Colors.white,
            icon: Icon(Icons.delete_forever_outlined),
            child: Text("Clear All Saved Project"),
            margin: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(24),
        constraints: BoxConstraints(maxWidth: 1600, minWidth: 768),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSavedProjectList(),
            SpaceX(16),
            VerticalDivider(),
            buildForm(),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget buildSavedProjectList() {
    return Expanded(
      child: FutureManagerBuilder<List<ProjectModel>>(
        futureManager: projectManager,
        ready: (context, projects) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Saved Projects",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ConditionalWidget(
                  condition: projects.isEmpty,
                  onTrue: () => Center(child: Text("Empty")),
                  onFalse: () => ListView.separated(
                    separatorBuilder: (context, index) => Divider(height: 0),
                    itemCount: projects.length,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemBuilder: (BuildContext context, int index) {
                      final ProjectModel project = projects[index];
                      return CustomCard(
                        child: SuraListTile(
                          leading: Icon(Icons.book),
                          onTap: () => onSelectProject(project),
                          title: Text(project.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SpaceY(),
                              Text(project.excelPath),
                              Text(project.jsonPath),
                              Text(project.localeKeyPath),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildForm() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SimpleTextField(
                controller: projectNameTC,
                hint: "Project Name",
                readOnly: false,
              ),
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
                hint: "Save locale key class path",
                readOnly: false,
              ),
              SuraAsyncButton(
                onPressed: onGenerateFile,
                child: Text("Generate And Save"),
                height: 40,
                color: Colors.blue,
                textColor: Colors.white,
                margin: EdgeInsets.fromLTRB(0, 24, 54, 0),
              )
            ],
          ),
        ),
      ),
    );
  }
}
