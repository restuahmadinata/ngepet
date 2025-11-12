import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShelterVerificationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final verificationRequests = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchVerificationRequests();
  }

  Future<void> fetchVerificationRequests() async {
    try {
      isLoading.value = true;

      // Ambil semua shelter dengan status verifikasi 'pending' dari koleksi shelters
      final snapshot = await _firestore
          .collection('shelters')
          .where('verificationStatus', isEqualTo: 'pending')
          .get();

      verificationRequests.value = snapshot.docs.map((doc) {
        return {'uid': doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil data verifikasi: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveVerification(String uid, String shelterName) async {
    try {
      // Get the shelter data from shelters collection
      final shelterDoc = await _firestore.collection('shelters').doc(uid).get();
      
      if (!shelterDoc.exists) {
        Get.snackbar(
          'Error',
          'Data shelter tidak ditemukan',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Update shelter with approved status
      await _firestore.collection('shelters').doc(uid).update({
        'verificationStatus': 'approved',
        'isVerified': true,
        'approvedAt': FieldValue.serverTimestamp(),
        'rejectionReason': FieldValue.delete(), // Remove rejection reason if any
      });

      Get.snackbar(
        'Sukses',
        'Shelter "$shelterName" telah disetujui',
        snackPosition: SnackPosition.BOTTOM,
      );

      fetchVerificationRequests(); // Refresh data
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyetujui verifikasi: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> rejectVerification(
    String uid,
    String shelterName,
    String reason,
  ) async {
    try {
      // Update shelter document with rejected status
      await _firestore.collection('shelters').doc(uid).update({
        'verificationStatus': 'rejected',
        'isVerified': false,
        'rejectionReason': reason,
        'rejectedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Sukses',
        'Verifikasi shelter "$shelterName" ditolak',
        snackPosition: SnackPosition.BOTTOM,
      );

      fetchVerificationRequests(); // Refresh data
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menolak verifikasi: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> fetchAllShelters() async {
    try {
      isLoading.value = true;

      // Ambil semua shelter dari koleksi shelters
      final snapshot = await _firestore
          .collection('shelters')
          .get();

      verificationRequests.value = snapshot.docs.map((doc) {
        return {'uid': doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil data shelter: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
