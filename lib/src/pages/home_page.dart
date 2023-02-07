import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_desktop_folder_picker/flutter_desktop_folder_picker.dart';
import 'package:future_manager/future_manager.dart';
import 'package:localization_generator/src/pages/widgets/saved_project_list.dart';
import 'package:oktoast/oktoast.dart';
import 'package:skadi/skadi.dart';

import '../model/project_model.dart';
import '../services/local_storage_service.dart';
import '../util/generator.dart';
import '../widgets/app_info_dialog.dart';
import '../widgets/simple_text_field.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SkadiFormMixin, DeferDispose {
  late TextEditingController excelOrGoogleSheetTC = createDefer(() => TextEditingController());
  late TextEditingController jsonPathTC = createDefer(() => TextEditingController());
  late TextEditingController localeKeyPathTC = createDefer(() => TextEditingController());
  late TextEditingController sheetNameTC = createDefer(() => TextEditingController());
  late TextEditingController projectNameTC = createDefer(() => TextEditingController());

  FutureManager<List<ProjectModel>> projectManager = FutureManager();

  Future<void> onGenerateFile() async {
    if (isFormValidated) {
      String projectName = projectNameTC.text.trim();
      String jsonPath = jsonPathTC.text.trim();
      String localeClassPath = localeKeyPathTC.text.trim();
      String sheetName = sheetNameTC.text.trim();
      String excelOrGoogleSheet = excelOrGoogleSheetTC.text.trim();

      try {
        await LocalizationGenerator(
          excelFilePathOrGoogleSheetId: excelOrGoogleSheet,
          saveJsonPath: jsonPath,
          saveLocaleKeyClassPath: localeClassPath,
          sheetName: sheetName,
        ).generate();
        //
        await LocalStorageService.saveProject(ProjectModel(
          projectName,
          excelOrGoogleSheet,
          jsonPath,
          localeClassPath,
          sheetName,
          DateTime.now().millisecondsSinceEpoch,
        ));
        projectManager.refresh(reloading: false);
        showToast("Generated");
      } catch (e) {
        if (e is FileSystemException) {
          showToast(e.message);
        } else {
          showToast(e.toString());
        }
      }
    }
  }

  void onSelectProject(ProjectModel project) {
    projectNameTC.text = project.name;
    excelOrGoogleSheetTC.text = project.excelPath;
    jsonPathTC.text = project.jsonPath;
    localeKeyPathTC.text = project.localeKeyPath;
    sheetNameTC.text = project.sheetName;
  }

  @override
  void initState() {
    projectManager.execute(() async {
      List<ProjectModel> projects = await LocalStorageService.getSavedProject();
      if (projects.isNotEmpty) onSelectProject(projects.first);
      return projects;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
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
              ),
              SimpleTextField(
                controller: excelOrGoogleSheetTC,
                hint: "Excel file or Sheet ID",
              ),
              SimpleTextField(
                controller: sheetNameTC,
                hint: "Sheet name",
              ),
              SimpleTextField(
                controller: jsonPathTC,
                onPickPath: () async {
                  String? path = await FlutterDesktopFolderPicker.openFolderPickerDialog();
                  if (path != null) {
                    jsonPathTC.text = path;
                  }
                },
                hint: "Save json path",
              ),
              SimpleTextField(
                controller: localeKeyPathTC,
                onPickPath: () async {
                  String? path = await FlutterDesktopFolderPicker.openFolderPickerDialog();
                  if (path != null) {
                    localeKeyPathTC.text = path;
                  }
                },
                hint: "Save locale key class path",
              ),
              SkadiAsyncButton(
                onPressed: onGenerateFile,
                height: 40,
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                margin: const EdgeInsets.fromLTRB(0, 16, 16, 0),
                child: const Text("Generate And Save"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
