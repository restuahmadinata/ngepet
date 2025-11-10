import 'package:get/get.dart';

class HomeController extends GetxController {
  var currentIndex = 2.obs; // Default ke Home (index 2)

  void changePage(int index) {
    currentIndex.value = index;
  }
}
