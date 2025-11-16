import 'package:get/get.dart';
import 'manage_pets_controller.dart';

class ManagePetsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManagePetsController>(() => ManagePetsController());
  }
}
