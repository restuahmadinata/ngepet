import 'package:get/get.dart';
import '../../../../services/follower_service.dart';

class FollowingController extends GetxController {
  final FollowerService _followerService = FollowerService();

  final RxList<Map<String, dynamic>> followingShelters = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    print('👤 FollowingController initialized');
    loadFollowing();
  }

  Future<void> loadFollowing() async {
    try {
      isLoading.value = true;
      print('📋 Loading followed shelters...');
      final result = await _followerService.getFollowedShelters();
      print('✅ Loaded ${result.length} followed shelters');
      followingShelters.value = result;
    } catch (e) {
      print('❌ Error loading following: $e');
      Get.snackbar('Error', 'Failed to load following shelters');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> unfollowShelter(String shelterId, String shelterName) async {
    try {
      final confirm = await Get.defaultDialog<bool>(
        title: 'Unfollow Shelter',
        middleText: 'Are you sure you want to unfollow $shelterName?',
        textConfirm: 'Unfollow',
        textCancel: 'Cancel',
        confirmTextColor: Get.theme.colorScheme.onError,
        buttonColor: Get.theme.colorScheme.error,
        onConfirm: () => Get.back(result: true),
        onCancel: () => Get.back(result: false),
      );

      if (confirm != true) return;

      final success = await _followerService.unfollowShelter(shelterId);
      
      if (success) {
        Get.snackbar(
          'Success',
          'Unfollowed $shelterName',
          snackPosition: SnackPosition.BOTTOM,
        );
        await loadFollowing();
      } else {
        Get.snackbar(
          'Error',
          'Failed to unfollow shelter',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error unfollowing shelter: $e');
      Get.snackbar('Error', 'Failed to unfollow shelter');
    }
  }

  void navigateToShelterProfile(String shelterId) {
    Get.toNamed('/shelter-profile', arguments: shelterId);
  }

  Future<void> refreshFollowing() async {
    await loadFollowing();
  }
}
