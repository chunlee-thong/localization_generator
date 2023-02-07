import 'package:hive/hive.dart';

part 'project_model.g.dart';

@HiveType(typeId: 1)
class ProjectModel {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String excelPath;

  @HiveField(2)
  final String jsonPath;

  @HiveField(3)
  final String localeKeyPath;

  @HiveField(4)
  final String sheetName;

  @HiveField(5)
  final int? timestamp;

  ProjectModel(
    this.name,
    this.excelPath,
    this.jsonPath,
    this.localeKeyPath,
    this.sheetName,
    this.timestamp,
  );
}
