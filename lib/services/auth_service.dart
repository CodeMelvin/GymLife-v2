import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthService {
  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = cred.user!.uid;
    final timestamp = ServerValue.timestamp;
    await FirebaseDatabase.instance
        .ref('accounts/$uid')
        .set({'email': email.trim(), 'username': name.trim(), 'role': 'user', 'createdAt': timestamp});
    await FirebaseDatabase.instance
        .ref('users/$uid')
        .set({
          'name': name.trim(),
          'email': email.trim(),
          'description': '',
          'gender': '',
          'profileImage': '',
          'activeMembership': 'None',
          'membershipId': '',
          'membershipExpiry': '',
          'createdAt': timestamp,
        });
    return cred;
  }

  static Future<void> signOut() => FirebaseAuth.instance.signOut();

  static Future<void> resetPassword(String email) {
    return FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
  }

  /// Reads the role of the given user from `accounts/{uid}/role`.
  static Future<String?> getRole(String uid) async {
    final snap = await FirebaseDatabase.instance
        .ref('accounts/$uid/role')
        .get();
    if (snap.exists && snap.value != null) return snap.value.toString();
    return null;
  }
}
