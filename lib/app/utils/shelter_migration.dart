import 'package:cloud_firestore/cloud_firestore.dart';

/// Script for migrating shelter data from 'users' collection to 'shelters'
/// 
/// WARNING: This script must be run carefully!
/// It's recommended to backup data before running the migration.
/// 
/// How to use:
/// 1. Import this file to main.dart or create a separate file
/// 2. Call migrateSheltersToNewCollection() when app first runs
/// 3. After migration completes, remove the function call code

class ShelterMigration {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Main function for migrating shelter data
  Future<void> migrateSheltersToNewCollection() async {
    print('🚀 Starting shelter data migration...');
    
    try {
      // 1. Get all users with role 'shelter'
      final shelterUsers = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'shelter')
          .get();

      print('📊 Found ${shelterUsers.docs.length} shelters to migrate');

      int successCount = 0;
      int failCount = 0;

      // 2. Loop each shelter and move to new collection
      for (var doc in shelterUsers.docs) {
        try {
          final data = doc.data();
          final uid = doc.id;

          // 3. Create new document in 'shelters' collection
          await _firestore.collection('shelters').doc(uid).set({
            'uid': uid,
            'email': data['email'] ?? '',
            'shelterName': data['shelterName'] ?? data['name'] ?? '',
            'address': data['shelterAddress'] ?? data['address'] ?? '',
            'phone': data['shelterPhone'] ?? data['phone'] ?? '',
            'legalNumber': data['shelterLegalNumber'] ?? '',
            'description': data['shelterDescription'] ?? '',
            'verificationStatus': data['verificationStatus'] ?? 'pending',
            'isVerified': data['isVerified'] ?? false,
            'submittedAt': data['submittedAt'],
            'approvedAt': data['approvedAt'],
            'rejectedAt': data['rejectedAt'],
            'rejectionReason': data['rejectionReason'],
            'createdAt': data['created_at'] ?? FieldValue.serverTimestamp(),
          });

          // 4. Delete shelter data from 'users' collection
          // OPTIONAL: Comment out if you want to keep in users
          await _firestore.collection('users').doc(uid).delete();

          successCount++;
          print('✅ Successfully migrated shelter: ${data['shelterName'] ?? uid}');
        } catch (e) {
          failCount++;
          print('❌ Failed to migrate shelter ${doc.id}: $e');
        }
      }

      print('');
      print('=' * 50);
      print('📊 MIGRATION RESULTS:');
      print('✅ Success: $successCount shelters');
      print('❌ Failed: $failCount shelters');
      print('=' * 50);

      if (failCount == 0) {
        print('🎉 Migration completed successfully!');
      } else {
        print('⚠️ Migration completed with some errors. Check log above.');
      }
    } catch (e) {
      print('❌ Error during migration: $e');
    }
  }

  /// Function to verify migration results
  Future<void> verifyMigration() async {
    print('🔍 Verifying migration results...');
    
    try {
      // Count shelters in new collection
      final newShelters = await _firestore.collection('shelters').get();
      print('📊 Total shelters in new collection: ${newShelters.docs.length}');

      // Count remaining users with shelter role
      final remainingShelterUsers = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'shelter')
          .get();
      print('📊 Shelters remaining in users: ${remainingShelterUsers.docs.length}');

      if (remainingShelterUsers.docs.isEmpty) {
        print('✅ Verification successful! All shelters have been moved.');
      } else {
        print('⚠️ Still ${remainingShelterUsers.docs.length} shelters in users collection.');
      }

      // Display sample data
      if (newShelters.docs.isNotEmpty) {
        print('\n📋 Sample successfully migrated shelter data:');
        for (var doc in newShelters.docs.take(3)) {
          final data = doc.data();
          print('  - ${data['shelterName']} (${data['email']})');
          print('    Status: ${data['verificationStatus']}');
        }
      }
    } catch (e) {
      print('❌ Error during verification: $e');
    }
  }

  /// Function for rollback (if needed)
  /// WARNING: Only use if migration fails and want to restore data
  Future<void> rollbackMigration() async {
    print('⏮️ Starting migration rollback...');
    print('⚠️ WARNING: Make sure you want to rollback!');
    
    // Wait 5 seconds to cancel
    await Future.delayed(Duration(seconds: 5));
    
    try {
      // Get all shelters from new collection
      final shelters = await _firestore.collection('shelters').get();
      
      int successCount = 0;
      int failCount = 0;

      for (var doc in shelters.docs) {
        try {
          final data = doc.data();
          final uid = doc.id;

          // Return to users collection
          await _firestore.collection('users').doc(uid).set({
            'uid': uid,
            'email': data['email'],
            'name': data['shelterName'],
            'role': 'shelter',
            'shelterName': data['shelterName'],
            'shelterAddress': data['address'],
            'shelterPhone': data['phone'],
            'shelterLegalNumber': data['legalNumber'],
            'shelterDescription': data['description'],
            'verificationStatus': data['verificationStatus'],
            'isVerified': data['isVerified'],
            'submittedAt': data['submittedAt'],
            'approvedAt': data['approvedAt'],
            'rejectedAt': data['rejectedAt'],
            'rejectionReason': data['rejectionReason'],
            'created_at': data['createdAt'],
          });

          // Delete from shelters collection
          await _firestore.collection('shelters').doc(uid).delete();

          successCount++;
          print('✅ Successfully rolled back: ${data['shelterName']}');
        } catch (e) {
          failCount++;
          print('❌ Failed to rollback ${doc.id}: $e');
        }
      }

      print('');
      print('📊 ROLLBACK RESULTS:');
      print('✅ Success: $successCount');
      print('❌ Failed: $failCount');
    } catch (e) {
      print('❌ Error during rollback: $e');
    }
  }
}

/// Usage example:
/// 
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Firebase.initializeApp();
///   
///   // Run migration (only once)
///   final migration = ShelterMigration();
///   await migration.migrateSheltersToNewCollection();
///   
///   // Verify results
///   await migration.verifyMigration();
///   
///   // If there's a problem, rollback
///   // await migration.rollbackMigration();
///   
///   runApp(MyApp());
/// }
