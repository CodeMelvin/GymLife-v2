import 'package:firebase_database/firebase_database.dart';

import '../models/membership_plan.dart';

class DatabaseService {
  static const String usersPath = 'users';
  static const String newsPath = 'gym_news';
  static const String plansPath = 'membership_plans';
  static const String locationsPath = 'gym_locations';
  static const String ordersPath = 'membership_orders';

  static DatabaseReference _root() => FirebaseDatabase.instance.ref();

  // ---------- live streams ----------

  static Stream<DatabaseEvent> newsStream() => _root().child(newsPath).onValue;

  static Stream<DatabaseEvent> plansStream() =>
      _root().child(plansPath).onValue;

  static Stream<DatabaseEvent> locationsStream() =>
      _root().child(locationsPath).onValue;

  static Stream<DatabaseEvent> allUsersStream() =>
      _root().child(usersPath).onValue;

  static Stream<DatabaseEvent> singleUserStream(String uid) =>
      _root().child('$usersPath/$uid').onValue;

  // ---------- profile ----------

  static Future<void> updateProfile({
    required String uid,
    required String name,
    required String description,
    required String gender,
  }) {
    return _root().child('$usersPath/$uid').update({
      'name': name,
      'description': description,
      'gender': gender,
    });
  }

  static Future<void> updateProfileImage({
    required String uid,
    required String base64Image,
  }) {
    return _root().child('$usersPath/$uid').update({
      'profileImage': base64Image,
    });
  }

  static Future<void> activateMembership({
    required String uid,
    required MembershipPlan plan,
  }) {
    final expiry = DateTime.now().add(Duration(days: plan.durationDays));
    return _root().child('$usersPath/$uid').update({
      'activeMembership': plan.name,
      'membershipId': plan.id,
      'membershipExpiry': expiry.toIso8601String(),
    });
  }

  /// Appends an immutable audit record of a completed order for the user.
  static Future<void> recordOrder({
    required String uid,
    required MembershipPlan plan,
  }) {
    return _root().child('$ordersPath/$uid').push().set({
      'planId': plan.id,
      'planName': plan.name,
      'price': plan.price,
      'status': 'paid',
      'createdAt': ServerValue.timestamp,
    });
  }

  // ---------- news (admin) ----------

  static Future<void> addNews({
    required String title,
    required String content,
    required String category,
  }) {
    return _root().child(newsPath).push().set({
      'title': title,
      'content': content,
      'category': category,
      'date': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> updateNews({
    required String newsId,
    required String title,
    required String content,
    required String category,
  }) {
    return _root().child('$newsPath/$newsId').update({
      'title': title,
      'content': content,
      'category': category,
    });
  }

  static Future<void> deleteNews(String newsId) {
    return _root().child('$newsPath/$newsId').remove();
  }

  // ---------- members (admin) ----------

  static Future<void> setMembershipLevel({
    required String uid,
    required String level,
  }) {
    return _root().child('$usersPath/$uid').update({'activeMembership': level});
  }

  static Future<void> cancelMembership(String uid) {
    return _root().child('$usersPath/$uid').update({
      'activeMembership': 'None',
      'membershipId': '',
      'membershipExpiry': '',
    });
  }
}
