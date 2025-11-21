import 'package:get/get.dart';
import 'report_form_controller.dart';

class ReportFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportFormController>(() => ReportFormController());
  }
}
