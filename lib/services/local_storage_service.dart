import 'package:hive/hive.dart';
import 'package:localization_generator/model/project_model.dart';

class LocalStorageService {
  static late Box<ProjectModel> box;
  //
  static Future<List<ProjectModel>> getSavedProject() async {
    box = await Hive.openBox<ProjectModel>('projects');
    List<ProjectModel> projects = box.values.toList();
    projects.sort((p1, p2) => p2.timestamp.compareTo(p1.timestamp));
    return projects;
  }

  static Future saveProject(ProjectModel project) async {
    await box.put(project.name, project);
  }

  static Future clearAll() async {
    await box.clear();
  }
}
