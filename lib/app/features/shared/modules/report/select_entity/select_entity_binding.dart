import 'package:get/get.dart';
import 'select_entity_controller.dart';

class SelectEntityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SelectEntityController>(() => SelectEntityController());
  }
}
