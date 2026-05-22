import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:tracker/core/error/exceptions.dart';
import 'package:tracker/features/auth/data/models/user_model.dart';
import 'package:tracker/features/auth/data/models/auth_event_model.dart';

/// The ONLY class that directly touches Firebase.
/// All Firebase interactions are isolated here.
class FirebaseAuthDatasource {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  FirebaseAuthDatasource({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Performs the full Google Sign-In flow.
  /// Throws [AuthCancelledException] if the user dismisses the picker.
  Future<UserModel> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();

    // User cancelled the sign-in dialog
    if (googleUser == null) {
      throw const AuthCancelledException();
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    return UserModel.fromFirebaseUser(userCredential.user!);
  }

  /// Signs out of both Google and Firebase.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Logs an auth event to the 'auth_events' Firestore collection.
  Future<void> logEvent(AuthEventModel event) async {
    await _firestore.collection('auth_events').add(event.toMap());
  }

  /// Stream of auth state changes mapped to our UserModel.
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().map(
          (user) => user != null ? UserModel.fromFirebaseUser(user) : null,
        );
  }
}
