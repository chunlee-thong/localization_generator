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
    return Material(
      elevation: 3.0,
      color: Colors.white,
      shape: SkadiDecoration.roundRect(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: CircleAvatar(child: Text(project.name)),
            ),
            const SpaceX(16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SpaceY(),
                Text(project.excelPath),
                const Divider(),
                Text(project.jsonPath),
                const Divider(),
                Text(project.localeKeyPath),
              ],
            ).expanded,
            const SpaceX(16),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
