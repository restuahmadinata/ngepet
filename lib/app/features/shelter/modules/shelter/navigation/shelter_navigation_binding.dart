import 'package:get/get.dart';
import 'shelter_navigation_controller.dart';
import '../dashboard/shelter_dashboard_controller.dart';
import '../manage/shelter_manage_controller.dart';
import '../profile/shelter_profile_controller.dart';

class ShelterNavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShelterNavigationController>(() => ShelterNavigationController());
    Get.lazyPut<ShelterDashboardController>(() => ShelterDashboardController());
    Get.lazyPut<ShelterManageController>(() => ShelterManageController());
    Get.lazyPut<ShelterProfileController>(() => ShelterProfileController());
  }
}
