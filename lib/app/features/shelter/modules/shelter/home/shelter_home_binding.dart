import 'package:get/get.dart';
import 'shelter_home_controller.dart';

class ShelterHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShelterHomeController>(() => ShelterHomeController());
  }
}
