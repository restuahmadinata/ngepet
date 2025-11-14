import 'package:get/get.dart';
import 'shelter_verification_controller.dart';

class ShelterVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShelterVerificationController>(
      () => ShelterVerificationController(),
    );
  }
}
