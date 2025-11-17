import 'package:get/get.dart';
import 'adoption_status_controller.dart';

class AdoptionStatusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdoptionStatusController>(
      () => AdoptionStatusController(),
    );
  }
}
