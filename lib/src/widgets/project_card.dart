import 'package:flutter/material.dart';
import 'package:localization_generator/src/model/project_model.dart';
import 'package:skadi/skadi.dart';

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
      child: ListTile(
        leading: const Icon(Icons.book),
        onTap: onSelect,
        title: Text(project.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SpaceY(),
            Text(project.excelPath),
            Text(project.jsonPath),
            Text(project.localeKeyPath),
          ],
        ),
        trailing: IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete, color: Colors.red),
        ),
      ),
    );
  }
}
