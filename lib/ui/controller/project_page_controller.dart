import 'package:get/get.dart';
import '../services/project_services.dart';

class ProjectPageController extends GetxController {
  RxBool currentdesign = true.obs;
  RxBool isLoading = false.obs;
  
  var selectedSortOption = 'last_modified'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    isLoading.value = true;
    try {
      // Projects are now synced at Splash screen
      // No extra action needed here as HomePageController is permanent and synced
    } catch (e) {
      print('Fetch projects error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setSortOption(String option) {
    selectedSortOption.value = option;
  }

  String getSortLabel() {
    switch (selectedSortOption.value) {
      case 'name': return 'Name';
      case 'created_at': return 'Created Date';
      case 'last_modified': return 'Last Modified';
      default: return 'Date';
    }
  }
}
