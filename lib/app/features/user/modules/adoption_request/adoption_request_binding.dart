import 'package:get/get.dart';
import 'adoption_request_controller.dart';

class AdoptionRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdoptionRequestController>(
      () => AdoptionRequestController(),
    );
  }
}
