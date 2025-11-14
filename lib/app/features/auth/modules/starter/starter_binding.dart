import 'package:get/get.dart';
import 'starter_controller.dart';

class StarterBinding extends Bindings {
  @override
  void dependencies() {
    // Inisialisasi StarterController agar tersedia untuk StarterView
    Get.lazyPut<StarterController>(() => StarterController());
  }
}
