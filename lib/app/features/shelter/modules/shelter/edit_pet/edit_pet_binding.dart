import 'package:get/get.dart';
import 'edit_pet_controller.dart';

class EditPetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditPetController>(() => EditPetController());
  }
}
