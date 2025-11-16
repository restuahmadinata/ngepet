import 'package:get/get.dart';
import 'manage_events_controller.dart';

class ManageEventsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManageEventsController>(() => ManageEventsController());
  }
}
