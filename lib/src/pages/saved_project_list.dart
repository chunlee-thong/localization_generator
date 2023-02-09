
import 'package:flutter/material.dart';
import 'package:future_manager/future_manager.dart';
import 'package:localization_generator/src/model/project_model.dart';
import 'package:localization_generator/src/services/local_storage_service.dart';
import 'package:localization_generator/src/widgets/project_card.dart';
import 'package:skadi/skadi.dart';

class SavedProjectList extends StatelessWidget {
  final FutureManager<List<ProjectModel>> projectManager;
  final void Function(ProjectModel) onSelectProject;
  const SavedProjectList({Key? key, required this.projectManager, required this.onSelectProject}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
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
                  foregroundColor: Colors.red,
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
            child: FutureManagerBuilder<List<ProjectModel>>(
              futureManager: projectManager,
              error: (error) {
                if (error.exception is TypeError) {
                  return _buildErrorWidget("Type conflicting with previous version. Please delete older projects");
                }
                return _buildErrorWidget(error.exception.toString());
              },
              ready: (context, projects) {
                return ConditionalWidget(
                  condition: projects.isEmpty,
                  onTrue: () => Center(
                    child: Text(
                      "Empty",
                      style: Theme.of(context).textTheme.headlineSmall,
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error,
            size: 24,
            color: Colors.red,
          ),
          const SpaceY(24),
          Text(message),
        ],
      ),
    );
  }
}
