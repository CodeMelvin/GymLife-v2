import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const List<String> _genders = ['', 'Laki-Laki', 'Perempuan'];

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> _pickAndSaveImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Ambil Foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      imageQuality: 25,
      maxWidth: 500,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    final uid = _uid;
    if (uid == null) return;
    await DatabaseService.updateProfileImage(
      uid: uid,
      base64Image: base64Encode(bytes),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil diperbarui.')),
      );
    }
  }

  Future<void> _openEditProfile(UserProfile profile) async {
    final nameCtrl = TextEditingController(text: profile.name);
    final descCtrl = TextEditingController(text: profile.description);
    var gender = profile.gender;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: StatefulBuilder(
          builder: (context, setSheetState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Edit Profil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi / Bio',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: gender,
                decoration: const InputDecoration(
                  labelText: 'Jenis Kelamin',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final g in _genders)
                    DropdownMenuItem(value: g, child: Text(g.isEmpty ? 'Pilih' : g)),
                ],
                onChanged: (value) => setSheetState(() => gender = value ?? ''),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  final uid = _uid;
                  if (uid == null) return;
                  DatabaseService.updateProfile(
                    uid: uid,
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    gender: gender,
                  );
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4C7FFF),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openChangePassword() async {
    final passCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ganti Password',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Baru',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Konfirmasi Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                final pass = passCtrl.text;
                final confirm = confirmCtrl.text;
                if (pass.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password minimal 6 karakter.'),
                    ),
                  );
                  return;
                }
                if (pass != confirm) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Konfirmasi password tidak sama.'),
                    ),
                  );
                  return;
                }
                try {
                  await FirebaseAuth.instance.currentUser!.updatePassword(pass);
                  if (context.mounted) Navigator.pop(context);
                } on FirebaseAuthException {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gagal: Perlu login ulang.'),
                      ),
                    );
                  }
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4C7FFF),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Ganti Password'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await AuthService.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final uid = _uid;
    if (uid == null) return const SizedBox.shrink();

    return SafeArea(
      child: StreamBuilder<DatabaseEvent>(
        stream: DatabaseService.singleUserStream(uid),
        builder: (context, snap) {
          UserProfile? profile;
          if (snap.hasData && snap.data!.snapshot.value is Map) {
            profile = UserProfile.fromRTDB(
              uid,
              Map<dynamic, dynamic>.from(snap.data!.snapshot.value as Map),
            );
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Profil',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ),
              if (profile != null) ...[
                _ProfileHeader(
                  profile: profile,
                  onZoom: () => _zoomAvatar(profile!),
                  onEdit: () => _openEditProfile(profile!),
                  onChangePhoto: _pickAndSaveImage,
                ),
                const SizedBox(height: 16),
                _MembershipCard(profile: profile),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.lock_reset, color: Color(0xFF4C7FFF)),
                  title: const Text('Ubah Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _openChangePassword,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: Colors.white,
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onTap: _logout,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: Colors.white,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _zoomAvatar(UserProfile profile) {
    final provider = profile.profileImageProvider;
    if (provider == null) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: InteractiveViewer(
          child: Image(image: provider),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.profile,
    required this.onZoom,
    required this.onEdit,
    required this.onChangePhoto,
  });

  final UserProfile profile;
  final VoidCallback onZoom;
  final VoidCallback onEdit;
  final VoidCallback onChangePhoto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: onZoom,
            child: CircleAvatar(
              radius: 36,
              backgroundColor: const Color(0xFFE8EEFF),
              backgroundImage: profile.profileImageProvider,
              child: profile.profileImageProvider == null
                  ? const Icon(Icons.person, size: 40, color: Color(0xFF4C7FFF))
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name.isEmpty ? 'Member' : profile.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.email,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.description.isEmpty
                      ? 'Belum ada bio.'
                      : profile.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Edit profil',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF4C7FFF)),
          ),
          IconButton(
            tooltip: 'Ganti foto',
            onPressed: onChangePhoto,
            icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFF4C7FFF)),
          ),
        ],
      ),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  const _MembershipCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    if (!profile.hasMembership) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Row(
          children: [
            Icon(Icons.badge_outlined, color: Colors.grey),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Belum memiliki keanggotaan aktif. Pilih paket di halaman Beranda.',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ],
        ),
      );
    }

    final active = profile.isMembershipActive;
    final date = profile.membershipExpiry != null
        ? DateFormat('dd MMM yyyy').format(profile.membershipExpiry!)
        : '-';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3357A4), Color(0xFF1F2A6B)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Image.asset(
            profile.membershipImage!,
            width: 64,
            height: 64,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${profile.activeMembership} Member',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Berlaku hingga $date',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  active ? 'Status: Aktif' : 'Status: Kadaluarsa',
                  style: TextStyle(
                    color: active ? Colors.greenAccent : Colors.orangeAccent,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
