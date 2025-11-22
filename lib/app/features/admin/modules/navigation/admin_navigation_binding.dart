import 'package:get/get.dart';
import 'admin_navigation_controller.dart';
import '../dashboard/admin_dashboard_controller.dart';
import '../manage/admin_manage_controller.dart';
import '../profile/admin_profile_controller.dart';

class AdminNavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminNavigationController>(() => AdminNavigationController());
    Get.lazyPut<AdminDashboardController>(() => AdminDashboardController());
    Get.lazyPut<AdminManageController>(() => AdminManageController());
    Get.lazyPut<AdminProfileController>(() => AdminProfileController());
  }
}
