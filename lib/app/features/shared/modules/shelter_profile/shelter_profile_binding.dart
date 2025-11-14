import 'package:get/get.dart';
import 'shelter_profile_controller.dart';

class ShelterProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShelterProfileController>(
      () => ShelterProfileController(),
    );
  }
}
