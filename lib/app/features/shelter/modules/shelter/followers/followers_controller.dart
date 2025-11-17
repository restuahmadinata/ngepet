import 'package:get/get.dart';
import '../../../../../services/follower_service.dart';

class FollowersController extends GetxController {
  final FollowerService _followerService = FollowerService();

  final RxList<Map<String, dynamic>> followers = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    final shelterId = Get.arguments;
    print('🏠 FollowersController initialized with shelterId: $shelterId');
    loadFollowers();
  }

  Future<void> loadFollowers() async {
    try {
      isLoading.value = true;
      final shelterId = Get.arguments ?? '';
      print('📋 Loading followers for shelter: $shelterId');
      final result = await _followerService.getFollowers(shelterId);
      print('✅ Loaded ${result.length} followers');
      followers.value = result;
    } catch (e) {
      print('❌ Error loading followers: $e');
      Get.snackbar('Error', 'Failed to load followers');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeFollower(String followerId, String followerName) async {
    try {
      final confirm = await Get.defaultDialog<bool>(
        title: 'Remove Follower',
        middleText: 'Are you sure you want to remove $followerName from your followers?',
        textConfirm: 'Remove',
        textCancel: 'Cancel',
        confirmTextColor: Get.theme.colorScheme.onError,
        buttonColor: Get.theme.colorScheme.error,
        onConfirm: () => Get.back(result: true),
        onCancel: () => Get.back(result: false),
      );

      if (confirm != true) return;

      final success = await _followerService.removeFollower(followerId);
      
      if (success) {
        Get.snackbar(
          'Success',
          'Follower removed successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        await loadFollowers();
      } else {
        Get.snackbar(
          'Error',
          'Failed to remove follower',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error removing follower: $e');
      Get.snackbar('Error', 'Failed to remove follower');
    }
  }

  Future<void> refreshFollowers() async {
    await loadFollowers();
  }
}
