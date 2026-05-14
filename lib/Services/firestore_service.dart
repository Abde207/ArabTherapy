import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> fetchUsersOnce() async {
    final currentUid = _auth.currentUser!.uid;
    print('CURRENT UID: $currentUid');

    final snapshot = await _firestore.collection('users').get();

    print('DOCS COUNT: ${snapshot.docs.length}');

    for (final doc in snapshot.docs) {
      print('DOC ID: ${doc.id}');
      print('DOC DATA: ${doc.data()}');
    }

    final filteredUsers = snapshot.docs
        .map((doc) => doc.data())
        .where((user) => user['uid'] != currentUid)
        .toList();

    print('FILTERED USERS: $filteredUsers');

    return filteredUsers;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> bookingsStream() {
    final currentUid = _auth.currentUser!.uid;

    return _firestore
        .collection('bookings')
        .where('participants', arrayContains: currentUid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> createBooking({
    required String targetUserId,
    required String targetUserName,
  }) async {
    final currentUser = _auth.currentUser!;
    final currentUserDoc = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .get();

    final currentUserData = currentUserDoc.data();
    if (currentUserData == null) {
      throw Exception('Current user data not found in Firestore');
    }

    final bookingRef = _firestore.collection('bookings').doc();

    await bookingRef.set({
      'id': bookingRef.id,
      'createdBy': currentUser.uid,
      'createdByName': currentUserData['name'],
      'targetUserId': targetUserId,
      'targetUserName': targetUserName,
      'participants': [currentUser.uid, targetUserId],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
