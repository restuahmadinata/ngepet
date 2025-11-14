import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper class for pet photos operations
/// Photos are now stored as an array in the pet document
class PetPhotoHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all photos for a specific pet
  Future<List<String>> getPetPhotos(String petId) async {
    try {
      final doc = await _firestore
          .collection('pets')
          .doc(petId)
          .get();

      if (!doc.exists) return [];

      final data = doc.data() as Map<String, dynamic>;
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

  /// Get primary/thumbnail photo for pet
  /// Returns the first photo from imageUrls array (index 0)
  Future<String?> getPrimaryPhotoUrl(String petId) async {
    try {
      final doc = await _firestore
          .collection('pets')
          .doc(petId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      
      // Get first photo from array (index 0 = primary/thumbnail)
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

  /// Get all photo URLs for pet (for compatibility with old code)
  Future<List<String>> getPetPhotoUrls(String petId) async {
    return await getPetPhotos(petId);
  }

  /// Stream to get pet photos in real-time
  Stream<List<String>> streamPetPhotos(String petId) {
    return _firestore
        .collection('pets')
        .doc(petId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return <String>[];
          
          final data = doc.data() as Map<String, dynamic>;
          final imageUrls = data['imageUrls'] as List<dynamic>?;
          
          if (imageUrls != null) {
            return imageUrls.map((url) => url.toString()).toList();
          }

          return <String>[];
        });
  }

  /// Add photo to pet
  Future<void> addPhoto(String petId, String photoUrl) async {
    try {
      await _firestore.collection('pets').doc(petId).update({
        'imageUrls': FieldValue.arrayUnion([photoUrl]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding photo: $e');
      rethrow;
    }
  }

  /// Delete specific photo
  Future<void> deletePhoto(String petId, String photoUrl) async {
    try {
      await _firestore.collection('pets').doc(petId).update({
        'imageUrls': FieldValue.arrayRemove([photoUrl]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error deleting photo: $e');
      rethrow;
    }
  }

  /// Set photo as primary by moving it to index 0
  /// Rearranges the imageUrls array so the specified photo is first
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

  /// Update all photos (replace array)
  Future<void> updatePhotos(String petId, List<String> imageUrls) async {
    try {
      await _firestore.collection('pets').doc(petId).update({
        'imageUrls': imageUrls,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating photos: $e');
      rethrow;
    }
  }
}
