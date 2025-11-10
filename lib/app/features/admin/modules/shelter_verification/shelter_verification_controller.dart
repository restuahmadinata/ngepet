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

      // Ambil semua user dengan role 'shelter' dan status verifikasi 'pending'
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'shelter')
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
      // Get the shelter data from user document
      final userDoc = await _firestore.collection('users').doc(uid).get();
      
      if (!userDoc.exists) {
        Get.snackbar(
          'Error',
          'Data user tidak ditemukan',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final userData = userDoc.data()!;

      // Update user with approved status and shelter data
      await _firestore.collection('users').doc(uid).update({
        'verificationStatus': 'approved',
        'isVerified': true,
        'role': 'shelter',
        // Keep the shelter data that was submitted
        'name': userData['shelterName'] ?? userData['name'],
        'phone': userData['shelterPhone'] ?? userData['phone'],
        'address': userData['shelterAddress'] ?? userData['address'],
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
      await _firestore.collection('users').doc(uid).update({
        'verificationStatus': 'rejected',
        'isVerified': false,
        'rejectionReason': reason,
        'role': 'user', // Kembalikan ke user biasa
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

      // Ambil semua user dengan role 'shelter'
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'shelter')
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
