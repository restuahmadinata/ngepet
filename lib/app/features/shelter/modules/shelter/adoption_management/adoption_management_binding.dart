import 'package:get/get.dart';
import 'adoption_management_controller.dart';

class ShelterAdoptionManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShelterAdoptionManagementController>(
      () => ShelterAdoptionManagementController(),
    );
  }
}
