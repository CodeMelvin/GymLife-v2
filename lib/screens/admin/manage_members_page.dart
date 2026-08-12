import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';
import '../../models/user_profile.dart';
import '../../services/database_service.dart';

class ManageMembersPage extends StatefulWidget {
  const ManageMembersPage({super.key});

  @override
  State<ManageMembersPage> createState() => _ManageMembersPageState();
}

class _ManageMembersPageState extends State<ManageMembersPage> {
  String _query = '';

  List<UserProfile> _parseUsers(DatabaseEvent event) {
    if (!event.snapshot.exists || event.snapshot.value == null) return [];
    final raw = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
    final users = raw.entries
        .map(
          (e) => UserProfile.fromRTDB(
            e.key.toString(),
            Map<dynamic, dynamic>.from(e.value as Map),
          ),
        )
        .toList();
    final q = _query.toLowerCase();
    if (q.isEmpty) return users;
    return users
        .where(
          (u) => u.name.toLowerCase().contains(q) || u.email.toLowerCase().contains(q),
        )
        .toList();
  }

  List<UserProfile> _activeMembers(List<UserProfile> users) =>
      users.where((u) => u.hasMembership).toList();

  List<UserProfile> _regularUsers(List<UserProfile> users) =>
      users.where((u) => !u.hasMembership).toList();

  Future<void> _updateLevel(UserProfile profile, int delta) async {
    final index = membershipLevels.indexOf(profile.activeMembership);
    final newIndex =
        (index + delta).clamp(0, membershipLevels.length - 1).toInt();
    final newLevel = membershipLevels[newIndex];
    if (newLevel == profile.activeMembership) return;
    await DatabaseService.setMembershipLevel(uid: profile.uid, level: newLevel);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${profile.name} -> $newLevel')),
      );
    }
  }

  Future<void> _confirmRemove(UserProfile profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Keanggotaan'),
        content: Text(
          'Yakin ingin membatalkan keanggotaan ${profile.name} (${profile.activeMembership})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseService.cancelMembership(profile.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Keanggotaan ${profile.name} dibatalkan.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List Member')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Cari nama atau email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: DatabaseService.allUsersStream(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final users = _parseUsers(snap.data!);
                final active = _activeMembers(users);
                final regular = _regularUsers(users);

                return DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        tabs: [
                          Tab(text: 'Member Aktif (${active.length})'),
                          Tab(text: 'User Biasa (${regular.length})'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _ActiveMembersTab(
                              members: active,
                              onUpgrade: (p) => _updateLevel(p, 1),
                              onDowngrade: (p) => _updateLevel(p, -1),
                              onRemove: _confirmRemove,
                            ),
                            _RegularUsersTab(users: regular),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveMembersTab extends StatelessWidget {
  const _ActiveMembersTab({
    required this.members,
    required this.onUpgrade,
    required this.onDowngrade,
    required this.onRemove,
  });

  final List<UserProfile> members;
  final ValueChanged<UserProfile> onUpgrade;
  final ValueChanged<UserProfile> onDowngrade;
  final ValueChanged<UserProfile> onRemove;

  @override
  Widget build(BuildContext context) {
    int count(String level) =>
        members.where((m) => m.activeMembership == level).length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatChip(label: 'Silver', count: count('Silver'), color: Colors.blueGrey),
              _StatChip(label: 'Gold', count: count('Gold'), color: const Color(0xFFD4A017)),
              _StatChip(label: 'Platinum', count: count('Platinum'), color: const Color(0xFF7B68EE)),
            ],
          ),
        ),
        Expanded(
          child: members.isEmpty
              ? const Center(child: Text('Belum ada member aktif.'))
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: members.length,
                  itemBuilder: (context, i) {
                    final m = members[i];
                    final levelIndex = membershipLevels.indexOf(m.activeMembership);
                    final date = m.membershipExpiry != null
                        ? DateFormat('dd MMM yyyy').format(m.membershipExpiry!)
                        : '-';
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFE8EEFF),
                          backgroundImage: m.profileImageProvider,
                          child: m.profileImageProvider == null
                              ? const Icon(Icons.person, color: Color(0xFF4C7FFF))
                              : null,
                        ),
                        title: Text(
                          m.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('$m.email\n$date'),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _LevelBadge(level: m.activeMembership),
                            if (levelIndex > 0)
                              IconButton(
                                tooltip: 'Turunkan',
                                icon: const Icon(Icons.arrow_downward),
                                onPressed: () => onDowngrade(m),
                              ),
                            if (levelIndex < membershipLevels.length - 1)
                              IconButton(
                                tooltip: 'Naikkan',
                                icon: const Icon(Icons.arrow_upward),
                                onPressed: () => onUpgrade(m),
                              ),
                            IconButton(
                              tooltip: 'Batalkan keanggotaan',
                              icon: const Icon(
                                Icons.block,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => onRemove(m),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _RegularUsersTab extends StatelessWidget {
  const _RegularUsersTab({required this.users});

  final List<UserProfile> users;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(child: Text('Tidak ada user biasa.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: users.length,
      itemBuilder: (context, i) {
        final u = users[i];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFE8EEFF),
              backgroundImage: u.profileImageProvider,
              child: u.profileImageProvider == null
                  ? const Icon(Icons.person, color: Color(0xFF4C7FFF))
                  : null,
            ),
            title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(u.email),
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.count, required this.color});

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text('$count ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(label),
        ],
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level});

  final String level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF4C7FFF).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        level,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF3357A4),
        ),
      ),
    );
  }
}
