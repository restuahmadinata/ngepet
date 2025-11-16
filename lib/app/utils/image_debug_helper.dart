import 'package:cloud_firestore/cloud_firestore.dart';

/// Helper class to debug image loading issues
class ImageDebugHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check all pets in database and their image structure
  static Future<void> debugAllPets() async {
    print('\n========== DEBUGGING ALL PETS ==========');
    
    try {
      final petsSnapshot = await _firestore.collection('pets').get();
      
      print('Total pets found: ${petsSnapshot.docs.length}\n');
      
      for (var doc in petsSnapshot.docs) {
        final data = doc.data();
        final petId = doc.id;
        final petName = data['petName'] ?? 'Unknown';
        
        print('--- Pet: $petName (ID: $petId) ---');
        print('Has imageUrls field: ${data.containsKey('imageUrls')}');
        
        if (data.containsKey('imageUrls')) {
          final imageUrls = data['imageUrls'];
          print('imageUrls type: ${imageUrls.runtimeType}');
          
          if (imageUrls is List) {
            print('imageUrls length: ${imageUrls.length}');
            for (int i = 0; i < imageUrls.length; i++) {
              final url = imageUrls[i];
              print('  [$i]: $url');
              print('       Type: ${url.runtimeType}');
              print('       Valid URL: ${_isValidUrl(url.toString())}');
            }
          } else {
            print('ERROR: imageUrls is not a List!');
          }
        }
        
        // Check for old imageUrl field
        if (data.containsKey('imageUrl')) {
          print('Has old imageUrl field: ${data['imageUrl']}');
        }
        
        // Check subcollection
        final photosSnapshot = await _firestore
            .collection('pets')
            .doc(petId)
            .collection('photos')
            .get();
        
        print('Photos subcollection count: ${photosSnapshot.docs.length}');
        if (photosSnapshot.docs.isNotEmpty) {
          for (var photo in photosSnapshot.docs) {
            final photoData = photo.data();
            print('  Photo: ${photoData['url']}');
            print('    isPrimary: ${photoData['isPrimary']}');
            print('    order: ${photoData['order']}');
          }
        }
        
        print('');
      }
      
      print('========== END DEBUG ==========\n');
    } catch (e) {
      print('ERROR debugging pets: $e');
    }
  }

  /// Check all events in database
  static Future<void> debugAllEvents() async {
    print('\n========== DEBUGGING ALL EVENTS ==========');
    
    try {
      final eventsSnapshot = await _firestore.collection('events').get();
      
      print('Total events found: ${eventsSnapshot.docs.length}\n');
      
      for (var doc in eventsSnapshot.docs) {
        final data = doc.data();
        final eventId = doc.id;
        final eventTitle = data['eventTitle'] ?? 'Unknown';
        
        print('--- Event: $eventTitle (ID: $eventId) ---');
        print('Has imageUrls field: ${data.containsKey('imageUrls')}');
        
        if (data.containsKey('imageUrls')) {
          final imageUrls = data['imageUrls'];
          print('imageUrls type: ${imageUrls.runtimeType}');
          
          if (imageUrls is List) {
            print('imageUrls length: ${imageUrls.length}');
            for (int i = 0; i < imageUrls.length; i++) {
              final url = imageUrls[i];
              print('  [$i]: $url');
              print('       Type: ${url.runtimeType}');
              print('       Valid URL: ${_isValidUrl(url.toString())}');
            }
          } else {
            print('ERROR: imageUrls is not a List!');
          }
        }
        
        // Check for old imageUrl field
        if (data.containsKey('imageUrl')) {
          print('Has old imageUrl field: ${data['imageUrl']}');
        }
        
        print('');
      }
      
      print('========== END DEBUG ==========\n');
    } catch (e) {
      print('ERROR debugging events: $e');
    }
  }

  /// Check specific pet by ID
  static Future<void> debugPet(String petId) async {
    print('\n========== DEBUGGING PET: $petId ==========');
    
    try {
      final doc = await _firestore.collection('pets').doc(petId).get();
      
      if (!doc.exists) {
        print('ERROR: Pet not found!');
        return;
      }
      
      final data = doc.data()!;
      print('Pet data: ${data.keys.toList()}');
      print('\nFull data:');
      data.forEach((key, value) {
        print('  $key: $value (${value.runtimeType})');
      });
      
      print('========== END DEBUG ==========\n');
    } catch (e) {
      print('ERROR: $e');
    }
  }

  /// Validate URL format
  static bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Fix all pets that have wrong image structure
  static Future<void> fixAllPetsImageStructure() async {
    print('\n========== FIXING ALL PETS IMAGE STRUCTURE ==========');
    
    try {
      final petsSnapshot = await _firestore.collection('pets').get();
      
      for (var doc in petsSnapshot.docs) {
        final data = doc.data();
        final petId = doc.id;
        bool needsUpdate = false;
        Map<String, dynamic> updateData = {};
        
        // Check if imageUrls exists and is a List
        if (!data.containsKey('imageUrls') || data['imageUrls'] is! List) {
          // Try to migrate from old imageUrl field
          if (data.containsKey('imageUrl')) {
            updateData['imageUrls'] = [data['imageUrl']];
            needsUpdate = true;
            print('Migrating $petId from imageUrl to imageUrls');
          } else {
            // Set placeholder
            updateData['imageUrls'] = ['https://via.placeholder.com/300x300?text=Pet'];
            needsUpdate = true;
            print('Adding placeholder to $petId');
          }
        }
        
        if (needsUpdate) {
          await _firestore.collection('pets').doc(petId).update(updateData);
          print('Updated $petId');
        }
      }
      
      print('========== FIX COMPLETE ==========\n');
    } catch (e) {
      print('ERROR fixing pets: $e');
    }
  }

  /// Fix all events that have wrong image structure
  static Future<void> fixAllEventsImageStructure() async {
    print('\n========== FIXING ALL EVENTS IMAGE STRUCTURE ==========');
    
    try {
      final eventsSnapshot = await _firestore.collection('events').get();
      
      for (var doc in eventsSnapshot.docs) {
        final data = doc.data();
        final eventId = doc.id;
        bool needsUpdate = false;
        Map<String, dynamic> updateData = {};
        
        // Check if imageUrls exists and is a List
        if (!data.containsKey('imageUrls') || data['imageUrls'] is! List) {
          // Try to migrate from old imageUrl field
          if (data.containsKey('imageUrl')) {
            updateData['imageUrls'] = [data['imageUrl']];
            needsUpdate = true;
            print('Migrating $eventId from imageUrl to imageUrls');
          } else {
            // Set placeholder
            updateData['imageUrls'] = ['https://via.placeholder.com/400x200?text=Event'];
            needsUpdate = true;
            print('Adding placeholder to $eventId');
          }
        }
        
        if (needsUpdate) {
          await _firestore.collection('events').doc(eventId).update(updateData);
          print('Updated $eventId');
        }
      }
      
      print('========== FIX COMPLETE ==========\n');
    } catch (e) {
      print('ERROR fixing events: $e');
    }
  }
}
