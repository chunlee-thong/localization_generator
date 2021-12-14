import 'package:flutter/material.dart';
import 'package:localization_generator/src/model/project_model.dart';
import 'package:localization_generator/src/services/local_storage_service.dart';
import 'package:localization_generator/src/widgets/project_card.dart';
import 'package:sura_flutter/sura_flutter.dart';
import 'package:sura_manager/sura_manager.dart';

class SavedProjectList extends StatelessWidget {
  final FutureManager<List<ProjectModel>> projectManager;
  final void Function(ProjectModel) onSelectProject;
  const SavedProjectList({Key? key, required this.projectManager, required this.onSelectProject}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureManagerBuilder<List<ProjectModel>>(
        futureManager: projectManager,
        ready: (context, projects) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Saved Projects",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    label: const Text("Clear"),
                    style: TextButton.styleFrom(
                      primary: Colors.red,
                    ),
                    onPressed: () async {
                      await LocalStorageService.clearAll();
                      projectManager.refresh();
                    },
                    icon: const Icon(
                      Icons.delete_outline_outlined,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ConditionalWidget(
                  condition: projects.isEmpty,
                  onTrue: () => Center(
                    child: Text(
                      "Empty",
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                  onFalse: () => ListView.builder(
                    itemCount: projects.length,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemBuilder: (BuildContext context, int index) {
                      final ProjectModel project = projects[index];
                      return ProjectCard(
                        onSelect: () {
                          onSelectProject(project);
                        },
                        onDelete: () async {
                          await LocalStorageService.deleteProject(project);
                          projectManager.refresh();
                        },
                        project: project,
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
}
