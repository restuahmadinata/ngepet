import 'package:get/get.dart';
import 'user_navigation_controller.dart';
import '../home/home_controller.dart';

class UserNavigationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserNavigationController>(() => UserNavigationController());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
