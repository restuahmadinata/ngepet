// Temporary helper to update user role to shelter
// Run this once in Flutter app to update current user's role to 'shelter'

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> updateCurrentUserToShelter() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {
          'role': 'shelter',
          'shelterName': 'Test Shelter', // Add shelter name
        },
      );
      print('User role updated to shelter');
    } catch (e) {
      print('Error updating user role: $e');

      // If document doesn't exist, create it
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'role': 'shelter',
        'shelterName': 'Test Shelter',
        'name': 'Test User',
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('User document created with shelter role');
    }
  }
}
