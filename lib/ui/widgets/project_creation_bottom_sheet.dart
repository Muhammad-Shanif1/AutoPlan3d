import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/project_services.dart';
import '../controller/home_page_controller.dart';
import 'common_textfield.dart';

class ProjectCreationBottomSheet extends StatefulWidget {
  final Function(String projectId)? onProjectCreated;
  final VoidCallback? onCancel;

  const ProjectCreationBottomSheet({
    super.key,
    this.onProjectCreated,
    this.onCancel,
  });

  @override
  State<ProjectCreationBottomSheet> createState() => _ProjectCreationBottomSheetState();
}

class _ProjectCreationBottomSheetState extends State<ProjectCreationBottomSheet> {
  final TextEditingController namecontroller = TextEditingController();
  final TextEditingController descriptioncontroller = TextEditingController();
  final RxString selectedVisibility = 'Private'.obs;
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final HomePageController homecontroller = Get.find<HomePageController>();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final List<String> existingNames = ProjectService.instance.projects.map((p) => p.name).toList();

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Form(
        key: formkey,
        autovalidateMode: AutovalidateMode.disabled,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Create Project",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter project details to continue.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: CustomFormField(
                  controller: namecontroller,
                  label: "Project Name",
                  hint: "e.g. My Dream Home",
                  keyboardType: TextInputType.text,
                  maxLines: 1,
                  prefixIcon: const Icon(Icons.drive_file_rename_outline_rounded),
                  validator: (name) {
                    if (name == null || name.trim().isEmpty) {
                      return 'Project name cannot be empty';
                    }
                    if (existingNames.contains(name.trim())) {
                      return 'A project with this name already exists';
                    }
                    if (name.trim().length < 6) {
                      return 'Title must be at least 6 characters';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: CustomFormField(
                  controller: descriptioncontroller,
                  label: "Description",
                  hint: "Describe your vision...",
                  prefixIcon: const Icon(Icons.description_rounded),
                  keyboardType: TextInputType.text,
                  maxLines: 3,
                  validator: (description) {
                    if (description == null || description.trim().isEmpty) {
                      return 'Description cannot be empty';
                    }
                    if (description.length < 10) {
                      return 'Description must be at least 10 characters';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF1E293B) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedVisibility.value,
                        isExpanded: true,
                        dropdownColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            selectedVisibility.value = newValue;
                          }
                        },
                        items: <String>['Private', 'Public']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                Icon(
                                  value == 'Private' ? Icons.lock_rounded : Icons.public_rounded,
                                  size: 20,
                                  color: Colors.blueAccent,
                                ),
                                const SizedBox(width: 12),
                                Text(value),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          if (widget.onCancel != null) {
                            widget.onCancel!();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDarkMode ? Colors.white : Colors.grey[700],
                          side: BorderSide(
                            color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: () async {
                            if (formkey.currentState!.validate()) {
                              homecontroller.createloading.value = true;
                              try {
                                final project = await ProjectService.instance.createProject(
                                  name: namecontroller.text.trim(),
                                  description: descriptioncontroller.text.trim(),
                                  visibility: selectedVisibility.value,
                                );
                                homecontroller.createloading.value = false;
                                Navigator.pop(context);
                                if (widget.onProjectCreated != null) {
                                  widget.onProjectCreated!(project.id);
                                }
                              } catch (e) {
                                homecontroller.createloading.value = false;
                                // Error handling could be added here
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: homecontroller.createloading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Create Project',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

void showProjectCreationBottomSheet({
  required BuildContext context,
  Function(String projectId)? onProjectCreated,
  VoidCallback? onCancel,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ProjectCreationBottomSheet(
      onProjectCreated: onProjectCreated,
      onCancel: onCancel,
    ),
  );
}
