import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service to handle follower-related operations
/// Handles follow/unfollow operations and follower queries
class FollowerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check if the current user is following a shelter
  Future<bool> isFollowing(String shelterId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final snapshot = await _firestore
          .collection('followers')
          .where('userId', isEqualTo: userId)
          .where('shelterId', isEqualTo: shelterId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking follow status: $e');
      return false;
    }
  }

  /// Stream to check if user is following a shelter (real-time)
  Stream<bool> isFollowingStream(String shelterId) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value(false);
    }

    return _firestore
        .collection('followers')
        .where('userId', isEqualTo: userId)
        .where('shelterId', isEqualTo: shelterId)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty);
  }

  /// Follow a shelter
  Future<bool> followShelter(String shelterId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('Error: User not authenticated');
        return false;
      }

      // Check if already following
      final existing = await _firestore
          .collection('followers')
          .where('userId', isEqualTo: userId)
          .where('shelterId', isEqualTo: shelterId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        print('Already following this shelter');
        return true;
      }

      // Create new follower document
      await _firestore.collection('followers').add({
        'userId': userId,
        'shelterId': shelterId,
        'followedAt': FieldValue.serverTimestamp(),
      });

      print('Successfully followed shelter: $shelterId');
      return true;
    } catch (e) {
      print('Error following shelter: $e');
      return false;
    }
  }

  /// Unfollow a shelter
  Future<bool> unfollowShelter(String shelterId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('Error: User not authenticated');
        return false;
      }

      // Find the follower document
      final snapshot = await _firestore
          .collection('followers')
          .where('userId', isEqualTo: userId)
          .where('shelterId', isEqualTo: shelterId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        print('Not following this shelter');
        return true;
      }

      // Delete the follower document
      await snapshot.docs.first.reference.delete();

      print('Successfully unfollowed shelter: $shelterId');
      return true;
    } catch (e) {
      print('Error unfollowing shelter: $e');
      return false;
    }
  }

  /// Get follower count for a shelter
  Future<int> getFollowerCount(String shelterId) async {
    try {
      final snapshot = await _firestore
          .collection('followers')
          .where('shelterId', isEqualTo: shelterId)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error getting follower count: $e');
      return 0;
    }
  }

  /// Stream of follower count for a shelter (real-time)
  Stream<int> getFollowerCountStream(String shelterId) {
    return _firestore
        .collection('followers')
        .where('shelterId', isEqualTo: shelterId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Get following count for current user
  Future<int> getFollowingCount() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return 0;

      final snapshot = await _firestore
          .collection('followers')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error getting following count: $e');
      return 0;
    }
  }

  /// Stream of following count for current user (real-time)
  Stream<int> getFollowingCountStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection('followers')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Get list of shelters that the current user follows
  Future<List<String>> getFollowedShelterIds() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('followers')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['shelterId'] as String)
          .toList();
    } catch (e) {
      print('Error getting followed shelters: $e');
      return [];
    }
  }

  /// Stream of followed shelter IDs (real-time)
  Stream<List<String>> getFollowedShelterIdsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('followers')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data()['shelterId'] as String)
            .toList());
  }

  /// Get list of followers (users) for a shelter
  Future<List<Map<String, dynamic>>> getFollowers(String shelterId) async {
    try {
      print('🔍 Getting followers for shelter: $shelterId');
      
      final snapshot = await _firestore
          .collection('followers')
          .where('shelterId', isEqualTo: shelterId)
          .get();

      print('📊 Found ${snapshot.docs.length} follower documents');

      // Get user details for each follower
      List<Map<String, dynamic>> followers = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final userId = data['userId'] as String;
        
        print('👤 Fetching user data for userId: $userId');
        
        // Fetch user data
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          print('✅ User found: ${userData['fullName']}');
          followers.add({
            'followerId': doc.id,
            'userId': userId,
            'fullName': userData['fullName'] ?? 'Unknown User',
            'profilePhoto': userData['profilePhoto'],
            'followedAt': data['followedAt'],
          });
        } else {
          print('❌ User not found for userId: $userId');
        }
      }

      print('✅ Total followers retrieved: ${followers.length}');
      return followers;
    } catch (e) {
      print('❌ Error getting followers: $e');
      return [];
    }
  }

  /// Get list of shelters that the current user follows with details
  Future<List<Map<String, dynamic>>> getFollowedShelters() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('❌ No authenticated user');
        return [];
      }

      print('🔍 Getting followed shelters for user: $userId');

      final snapshot = await _firestore
          .collection('followers')
          .where('userId', isEqualTo: userId)
          .get();

      print('📊 Found ${snapshot.docs.length} followed shelter documents');

      // Get shelter details for each followed shelter
      List<Map<String, dynamic>> shelters = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final shelterId = data['shelterId'] as String;
        
        print('🏠 Fetching shelter data for shelterId: $shelterId');
        
        // Fetch shelter data
        final shelterDoc = await _firestore.collection('shelters').doc(shelterId).get();
        if (shelterDoc.exists) {
          final shelterData = shelterDoc.data() as Map<String, dynamic>;
          print('✅ Shelter found: ${shelterData['shelterName']}');
          shelters.add({
            'followerId': doc.id,
            'shelterId': shelterId,
            'shelterName': shelterData['shelterName'] ?? 'Unknown Shelter',
            'shelterPhoto': shelterData['shelterPhoto'],
            'city': shelterData['city'] ?? '',
            'description': shelterData['description'] ?? '',
            'followedAt': data['followedAt'],
          });
        } else {
          print('❌ Shelter not found for shelterId: $shelterId');
        }
      }

      print('✅ Total followed shelters retrieved: ${shelters.length}');
      return shelters;
    } catch (e) {
      print('❌ Error getting followed shelters: $e');
      return [];
    }
  }

  /// Remove a follower (for shelter owners)
  Future<bool> removeFollower(String followerId) async {
    try {
      await _firestore.collection('followers').doc(followerId).delete();
      print('Successfully removed follower: $followerId');
      return true;
    } catch (e) {
      print('Error removing follower: $e');
      return false;
    }
  }
}
