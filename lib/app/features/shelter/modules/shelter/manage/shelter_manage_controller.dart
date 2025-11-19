import 'package:get/get.dart';
import '../../../../../routes/app_routes.dart';

class ShelterManageController extends GetxController {
  void goToManagePets() {
    Get.toNamed(AppRoutes.shelterManagePets);
  }

  void goToManageEvents() {
    Get.toNamed(AppRoutes.shelterManageEvents);
  }

  void goToAdoptionRequests() {
    Get.toNamed(AppRoutes.shelterAdoptionManagement);
  }
}
