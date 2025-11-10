import 'package:get/get.dart';
import 'login_controller.dart';
// Asumsi LoginController sudah ada

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Memastikan LoginController dibuat saat halaman Login diakses
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
