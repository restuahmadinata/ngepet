import 'package:get/get.dart';
import 'suspended_account_controller.dart';

class SuspendedAccountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SuspendedAccountController>(
      () => SuspendedAccountController(),
    );
  }
}
