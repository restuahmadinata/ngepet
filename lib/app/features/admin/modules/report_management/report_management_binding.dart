import 'package:get/get.dart';
import 'report_management_controller.dart';

class ReportManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportManagementController>(() => ReportManagementController());
  }
}
