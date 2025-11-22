import 'package:get/get.dart';

class UserNavigationController extends GetxController {
  final currentIndex = 2.obs; // Default to Home (index 2)

  void changePage(int index) {
    currentIndex.value = index;
  }
}
