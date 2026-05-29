import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/profile/profile_service.dart';

 class FirebaseProfileService implements IProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'profiles';

  @override
  Future<UserProfile?> getUserProfile(String token, String userId) async {
    try {
      // Ensure user is authenticated
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated - cannot access profile');
      }
      
      print('Authenticated user ${currentUser.uid} fetching profile for: $userId');
      
      final doc = await _firestore.collection(_collection).doc(userId).get();
      if (!doc.exists) {
        print('Profile does not exist for user: $userId');
        return null;
      }
      
      final data = doc.data()!;
      print('Profile found for user: $userId, onboarded: ${data['onboarded']}');
      return UserProfile.fromJson(data);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        print('FIRESTORE PERMISSION DENIED: Check your Firestore security rules');
        print('Current user: ${_auth.currentUser?.uid}');
        print('Requested userId: $userId');
        throw Exception('Permission denied accessing profile. Check Firestore security rules.');
      }
      print('Firebase error fetching user profile for $userId: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error fetching user profile for $userId: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateUserProfile(String token, UserProfile profile) async {
    try {
      // Ensure user is authenticated
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated - cannot save profile');
      }
      
      // Verify the user can only update their own profile
      if (currentUser.uid != profile.id) {
        throw Exception('User can only update their own profile');
      }
      
      print('Authenticated user ${currentUser.uid} saving profile for: ${profile.id}, onboarded: ${profile.onboarded}');

      profile.updateDate = DateTime.now();
      await _firestore
          .collection(_collection)
          .doc(profile.id)
          .set(profile.toJson(), SetOptions(merge: true));
          
      print('Profile saved successfully for user: ${profile.id}');
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        print('FIRESTORE PERMISSION DENIED: Check your Firestore security rules');
        print('Current user: ${_auth.currentUser?.uid}');
        print('Profile ID: ${profile.id}');
        throw Exception('Permission denied saving profile. Check Firestore security rules.');
      }
      print('Firebase error updating user profile for ${profile.id}: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error updating user profile for ${profile.id}: $e');
      rethrow;
    }
  }
}
