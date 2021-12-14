import 'dart:io';

import 'package:flutter/material.dart';
import 'package:localization_generator/src/pages/widgets/saved_project_list.dart';
import 'package:sura_flutter/sura_flutter.dart';
import 'package:sura_manager/sura_manager.dart';
import 'package:toast/toast.dart';

import '../model/project_model.dart';
import '../services/local_storage_service.dart';
import '../util/generator.dart';
import '../widgets/app_info_dialog.dart';
import '../widgets/simple_text_field.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SuraFormMixin {
  late TextEditingController excelOrGoogleSheetTC, jsonPathTC, localeKeyPathTC, projectNameTC;

  FutureManager<List<ProjectModel>> projectManager = FutureManager();

  Future<void> onGenerateFile() async {
    if (isFormValidated) {
      String projectName = projectNameTC.text.trim();
      String jsonPath = jsonPathTC.text.trim();
      String localeClassPath = localeKeyPathTC.text.trim();
      String excelOrGoogleSheet = excelOrGoogleSheetTC.text.trim();

      try {
        await LocalizationGenerator(
          excelFilePathOrGoogleSheetId: excelOrGoogleSheet,
          saveJsonPath: jsonPath,
          saveLocaleKeyClassPath: localeClassPath,
        ).generate();
        //
        await LocalStorageService.saveProject(ProjectModel(
          projectName,
          excelOrGoogleSheet,
          jsonPath,
          localeClassPath,
          DateTime.now().millisecondsSinceEpoch,
        ));
        projectManager.refresh(reloading: false);
        Toast.show("Generated", context);
      } catch (e) {
        if (e is FileSystemException) {
          Toast.show(e.message, context, duration: 3);
        } else {
          Toast.show(e.toString(), context, duration: 3);
        }
      }
    }
  }

  void onPickExcelFile() async {
    //final file = picker.OpenFilePicker();
    // if (path != null) {
    //   excelOrGoogleSheetTC.text = path;
    // }
  }

  void onSelectProject(ProjectModel project) {
    projectNameTC.text = project.name;
    excelOrGoogleSheetTC.text = project.excelPath;
    jsonPathTC.text = project.jsonPath;
    localeKeyPathTC.text = project.localeKeyPath;
  }

  @override
  void initState() {
    projectManager.asyncOperation(() async {
      List<ProjectModel> projects = await LocalStorageService.getSavedProject();
      if (projects.isNotEmpty) onSelectProject(projects.first);
      return projects;
    });
    excelOrGoogleSheetTC = TextEditingController();
    projectNameTC = TextEditingController();
    jsonPathTC = TextEditingController();
    localeKeyPathTC = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    excelOrGoogleSheetTC.dispose();
    projectNameTC.dispose();
    jsonPathTC.dispose();
    localeKeyPathTC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset("assets/images/app-icon.png"),
        ),
        title: const Text("Localization Generator"),
        //backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(context: context, builder: (_) => const AppInfoDialog());
            },
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 1600, minWidth: 768),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SavedProjectList(
              projectManager: projectManager,
              onSelectProject: onSelectProject,
            ),
            const SpaceX(16),
            const VerticalDivider(),
            _buildForm(),
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _buildForm() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
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
                controller: excelOrGoogleSheetTC,
                hint: "Excel file or Sheet ID",
                //onPickPath: onPickExcelFile,
                readOnly: false,
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
                child: const Text("Generate And Save"),
                height: 40,
                color: Colors.blue,
                textColor: Colors.white,
                margin: const EdgeInsets.fromLTRB(0, 16, 16, 0),
              )
            ],
          ),
        ),
      ),
    );
  }
}