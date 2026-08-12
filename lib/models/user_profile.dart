import 'dart:convert';

import 'package:flutter/material.dart';

import '../constants.dart';

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String description;
  final String gender;
  final String profileImage;
  final String activeMembership;
  final String membershipId;
  final DateTime? membershipExpiry;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.description,
    required this.gender,
    required this.profileImage,
    required this.activeMembership,
    required this.membershipId,
    required this.membershipExpiry,
  });

  factory UserProfile.fromRTDB(String uid, Map<dynamic, dynamic> data) {
    final expiryRaw = data['membershipExpiry']?.toString();
    return UserProfile(
      uid: uid,
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      gender: data['gender']?.toString() ?? '',
      profileImage: data['profileImage']?.toString() ?? '',
      activeMembership: data['activeMembership']?.toString() ?? 'None',
      membershipId: data['membershipId']?.toString() ?? '',
      membershipExpiry:
          (expiryRaw != null && expiryRaw.isNotEmpty)
              ? DateTime.tryParse(expiryRaw)
              : null,
    );
  }

  bool get hasMembership => membershipLevels.contains(activeMembership);

  bool get isMembershipActive =>
      hasMembership &&
      (membershipExpiry == null || membershipExpiry!.isAfter(DateTime.now()));

  String? get membershipImage {
    switch (activeMembership) {
      case 'Silver':
        return 'images/silver.png';
      case 'Gold':
        return 'images/gold.png';
      case 'Platinum':
        return 'images/platinum.png';
      default:
        return null;
    }
  }

  ImageProvider? get profileImageProvider {
    if (profileImage.isEmpty) return null;
    try {
      return MemoryImage(base64Decode(profileImage));
    } catch (_) {
      return null;
    }
  }
}
