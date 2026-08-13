import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../widgets/responsive_center.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const List<String> _genders = ['', 'Male', 'Female'];

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> _pickAndSaveImage(ImageSource source) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 25,
        maxWidth: 500,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      await DatabaseService.updateProfileImage(
        uid: uid,
        base64Image: base64Encode(bytes),
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile photo updated.')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile photo.')),
        );
      }
    }
  }

  void _showImageSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: appBarColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.white),
            title: const Text(
              'Choose from Gallery',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              _pickAndSaveImage(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.white),
            title: const Text(
              'Take Photo',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              _pickAndSaveImage(ImageSource.camera);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _openEditProfile(UserProfile profile) async {
    final nameCtrl = TextEditingController(text: profile.name);
    final descCtrl = TextEditingController(text: profile.description);
    var gender = profile.gender;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: appBarColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          top: 30,
          left: 25,
          right: 25,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'EDIT PROFILE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle('Full Name'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: descCtrl,
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle('Bio'),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              dropdownColor: appBarColor,
              initialValue: _genders.contains(gender) ? gender : null,
              items: [
                for (final g in _genders)
                  DropdownMenuItem(
                    value: g,
                    child: Text(
                      g.isEmpty ? 'Select' : g,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
              ],
              onChanged: (v) => gender = v ?? '',
              decoration: _inputStyle('Gender'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                final uid = _uid;
                if (uid == null) return;
                DatabaseService.updateProfile(
                  uid: uid,
                  name: nameCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  gender: gender,
                );
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentTeal,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'SAVE',
                style: TextStyle(
                  color: Color(0xFF0F0F1E),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    nameCtrl.dispose();
    descCtrl.dispose();
  }

  Future<void> _openChangePassword() async {
    final passCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: appBarColor,
        title: const Text(
          'Change Password',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle('New Password'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: _inputStyle('Confirm Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final pass = passCtrl.text;
              final confirm = confirmCtrl.text;
              final messenger = ScaffoldMessenger.of(context);
              if (pass.length < 6) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Password must be at least 6 characters.'),
                  ),
                );
                return;
              }
              if (pass != confirm) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Passwords do not match.')),
                );
                return;
              }
              try {
                await FirebaseAuth.instance.currentUser!.updatePassword(pass);
                if (ctx.mounted) Navigator.pop(ctx);
              } on FirebaseAuthException {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Failed: Please sign in again.'),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    passCtrl.dispose();
    confirmCtrl.dispose();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: appBarColor,
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await AuthService.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    }
  }

  InputDecoration _inputStyle(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white54),
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.05),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white12),
      borderRadius: BorderRadius.circular(15),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: accentTeal),
      borderRadius: BorderRadius.circular(15),
    ),
  );

  Widget _buildAvatarHeader(UserProfile profile) {
    final provider = profile.profileImageProvider;
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [accentRed, Color(0xFF0F3460)]),
          ),
          child: CircleAvatar(
            radius: 65,
            backgroundColor: appBarColor,
            backgroundImage: provider,
            child: provider == null
                ? const Icon(Icons.person, size: 65, color: Colors.white24)
                : null,
          ),
        ),
        Positioned(
          bottom: 5,
          right: 5,
          child: InkWell(
            onTap: _showImageSourcePicker,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentRed,
                shape: BoxShape.circle,
                border: Border.all(color: bgColor, width: 3),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMembershipCard(UserProfile profile) {
    final premium = profile.hasMembership;
    final active = profile.isMembershipActive;
    final date = profile.membershipExpiry != null
        ? DateFormat('dd MMM yyyy').format(profile.membershipExpiry!)
        : '-';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: premium
            ? const LinearGradient(colors: [accentRed, appBarColor])
            : const LinearGradient(colors: [Colors.white10, Colors.white10]),
        boxShadow: premium
            ? [
                BoxShadow(
                  color: accentRed.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : const [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                premium ? 'MEMBERSHIP' : 'NO ACTIVE MEMBERSHIP',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              Icon(
                Icons.workspace_premium,
                color: premium ? Colors.amber : Colors.white24,
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            profile.activeMembership,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (premium) ...[
            const SizedBox(height: 8),
            Text(
              active ? 'Valid until: $date' : 'Status: Expired',
              style: TextStyle(
                color: active ? Colors.white70 : Colors.orangeAccent,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: accentTeal, size: 22),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideButton(
    String text,
    IconData icon,
    VoidCallback onTap,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E1E2E),
          foregroundColor: color,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = _uid;
    if (uid == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'MY PROFILE',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        foregroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: DatabaseService.singleUserStream(uid),
        builder: (context, snap) {
          UserProfile? profile;
          if (snap.hasData && snap.data!.snapshot.value is Map) {
            profile = UserProfile.fromRTDB(
              uid,
              Map<dynamic, dynamic>.from(snap.data!.snapshot.value as Map),
            );
          }
          if (profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            color: accentRed,
            onRefresh: () async {},
            child: ResponsiveCenter(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildAvatarHeader(profile),
                    const SizedBox(height: 16),
                    Text(
                      profile.name.isEmpty ? 'Member' : profile.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      profile.email,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildMembershipCard(profile),
                    const SizedBox(height: 25),
                    _buildInfoTile(
                      'Bio',
                      profile.description.isEmpty
                          ? 'No bio yet.'
                          : profile.description,
                      Icons.info_outline,
                    ),
                    _buildInfoTile(
                      'Gender',
                      profile.gender.isEmpty ? '-' : profile.gender,
                      Icons.face,
                    ),
                    const SizedBox(height: 35),
                    _buildWideButton(
                      'Edit Profile',
                      Icons.edit_note_rounded,
                      () => _openEditProfile(profile!),
                      accentTeal,
                    ),
                    _buildWideButton(
                      'Change Password',
                      Icons.lock_outline,
                      _openChangePassword,
                      Colors.white70,
                    ),
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      label: const Text(
                        'LOG OUT',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
