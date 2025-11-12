import 'package:get/get.dart';
import 'edit_shelter_profile_controller.dart';

class EditShelterProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditShelterProfileController>(
      () => EditShelterProfileController(),
    );
  }
}
