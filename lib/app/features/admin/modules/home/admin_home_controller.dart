import 'package:get/get.dart';
import '../../../../common/controllers/auth_controller.dart';

class AdminHomeController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  void signOut() async {
    await authController.signOut();
  }
}
