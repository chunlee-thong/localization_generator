import 'package:flutter/material.dart';
import 'package:localization_generator/model/project_model.dart';
import 'package:sura_flutter/sura_flutter.dart';

class ProjectCard extends StatelessWidget {
  final VoidCallback onSelect;
  final VoidCallback onDelete;
  final ProjectModel project;
  const ProjectCard({
    Key? key,
    required this.onSelect,
    required this.onDelete,
    required this.project,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.5,
      margin: const EdgeInsets.only(bottom: 16),
      child: SuraListTile(
        leading: Icon(Icons.book),
        onTap: onSelect,
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
        trailing: IconButton(
          onPressed: onDelete,
          icon: Icon(Icons.delete, color: Colors.red),
        ),
      ),
    );
  }
}
