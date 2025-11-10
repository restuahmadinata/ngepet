import 'package:get/get.dart';
import '../../../../routes/app_routes.dart'; // Wajib diimpor

class StarterController extends GetxController {
  void goToLogin() {
    // Pastikan menggunakan AppRoutes.login
    Get.toNamed(AppRoutes.login);
  }

  void goToRegister() {
    // Pastikan menggunakan AppRoutes.register
    Get.toNamed(AppRoutes.register);
  }
}
