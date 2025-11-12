import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper class untuk operasi terkait pet photos
/// Photos sekarang disimpan sebagai array dalam pet document
class PetPhotoHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Ambil semua foto untuk pet tertentu
  Future<List<String>> getPetPhotos(String petId) async {
    try {
      final doc = await _firestore
          .collection('pets')
          .doc(petId)
          .get();

      if (!doc.exists) return [];

      final data = doc.data() as Map<String, dynamic>;
      final fotoUrls = data['fotoUrls'] as List<dynamic>?;
      
      if (fotoUrls != null) {
        return fotoUrls.map((url) => url.toString()).toList();
      }

      // Fallback untuk data lama
      final imageUrls = data['imageUrls'] as List<dynamic>?;
      if (imageUrls != null) {
        return imageUrls.map((url) => url.toString()).toList();
      }

      return [];
    } catch (e) {
      print('Error fetching pet photos: $e');
      return [];
    }
  }

  /// Ambil foto primary/thumbnail untuk pet
  /// Returns the first photo from fotoUrls array (index 0)
  Future<String?> getPrimaryPhotoUrl(String petId) async {
    try {
      final doc = await _firestore
          .collection('pets')
          .doc(petId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      
      // Get first photo from array (index 0 = primary/thumbnail)
      final fotoUrls = data['fotoUrls'] as List<dynamic>?;
      if (fotoUrls != null && fotoUrls.isNotEmpty) {
        return fotoUrls.first.toString();
      }

      // Fallback untuk data lama
      final imageUrls = data['imageUrls'] as List<dynamic>?;
      if (imageUrls != null && imageUrls.isNotEmpty) {
        return imageUrls.first.toString();
      }

      return null;
    } catch (e) {
      print('Error fetching primary photo: $e');
      return null;
    }
  }

  /// Ambil semua URL foto untuk pet (untuk kompatibilitas dengan kode lama)
  Future<List<String>> getPetPhotoUrls(String petId) async {
    return await getPetPhotos(petId);
  }

  /// Stream untuk mendapatkan foto pet secara real-time
  Stream<List<String>> streamPetPhotos(String petId) {
    return _firestore
        .collection('pets')
        .doc(petId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return <String>[];
          
          final data = doc.data() as Map<String, dynamic>;
          final fotoUrls = data['fotoUrls'] as List<dynamic>?;
          
          if (fotoUrls != null) {
            return fotoUrls.map((url) => url.toString()).toList();
          }

          // Fallback untuk data lama
          final imageUrls = data['imageUrls'] as List<dynamic>?;
          if (imageUrls != null) {
            return imageUrls.map((url) => url.toString()).toList();
          }

          return <String>[];
        });
  }

  /// Tambah foto ke pet
  Future<void> addPhoto(String petId, String photoUrl) async {
    try {
      await _firestore.collection('pets').doc(petId).update({
        'fotoUrls': FieldValue.arrayUnion([photoUrl]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding photo: $e');
      rethrow;
    }
  }

  /// Hapus foto tertentu
  Future<void> deletePhoto(String petId, String photoUrl) async {
    try {
      await _firestore.collection('pets').doc(petId).update({
        'fotoUrls': FieldValue.arrayRemove([photoUrl]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error deleting photo: $e');
      rethrow;
    }
  }

  /// Set foto sebagai primary dengan memindahkannya ke index 0
  /// Rearranges the fotoUrls array so the specified photo is first
  Future<void> setPrimaryPhoto(String petId, String photoUrl) async {
    try {
      final photos = await getPetPhotos(petId);
      if (!photos.contains(photoUrl)) {
        throw Exception('Photo not found in pet photos');
      }

      // Remove the photo from its current position
      photos.remove(photoUrl);
      // Insert it at the beginning (index 0)
      photos.insert(0, photoUrl);

      await updatePhotos(petId, photos);
    } catch (e) {
      print('Error setting primary photo: $e');
      rethrow;
    }
  }

  /// Update semua foto (replace array)
  Future<void> updatePhotos(String petId, List<String> photoUrls) async {
    try {
      await _firestore.collection('pets').doc(petId).update({
        'fotoUrls': photoUrls,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating photos: $e');
      rethrow;
    }
  }
}
