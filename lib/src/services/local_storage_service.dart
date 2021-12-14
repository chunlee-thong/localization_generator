import 'package:hive/hive.dart';

import '../model/project_model.dart';

class LocalStorageService {
  static late Box<ProjectModel> box;
  //
  static Future<List<ProjectModel>> getSavedProject() async {
    box = await Hive.openBox<ProjectModel>('projects');
    List<ProjectModel> projects = box.values.toList();
    projects.sort((p1, p2) {
      if (p1.timestamp != null && p2.timestamp != null) {
        return p2.timestamp!.compareTo(p1.timestamp!);
      }
      return 0;
    });
    return projects;
  }

  static Future saveProject(ProjectModel project) async {
    await box.put(project.name, project);
  }

  static Future deleteProject(ProjectModel project) async {
    await box.delete(project.name);
  }

  static Future clearAll() async {
    await box.clear();
  }
}
