import 'package:get/get.dart';
import '../../../../routes/app_routes.dart'; // Wajib diimpor

class StarterController extends GetxController {
  void goToLogin() {
    Get.toNamed(AppRoutes.login);
  }

  void goToRegister() {
    Get.toNamed(AppRoutes.register);
  }

  void goToShelterRegistration() {
    Get.toNamed(AppRoutes.verification);
  }
}
