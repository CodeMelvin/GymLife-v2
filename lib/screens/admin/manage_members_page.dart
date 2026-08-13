import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';
import '../../models/user_profile.dart';
import '../../services/database_service.dart';
import '../../widgets/responsive_center.dart';

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
          (u) =>
              u.name.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q),
        )
        .toList();
  }

  List<UserProfile> _activeMembers(List<UserProfile> users) =>
      users.where((u) => u.hasMembership).toList();

  List<UserProfile> _regularUsers(List<UserProfile> users) =>
      users.where((u) => !u.hasMembership).toList();

  Future<void> _updateLevel(UserProfile profile, int delta) async {
    final index = membershipLevels.indexOf(profile.activeMembership);
    final newIndex = (index + delta)
        .clamp(0, membershipLevels.length - 1)
        .toInt();
    final newLevel = membershipLevels[newIndex];
    if (newLevel == profile.activeMembership) return;
    await DatabaseService.setMembershipLevel(uid: profile.uid, level: newLevel);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${profile.name} -> $newLevel')));
    }
  }

  Future<void> _confirmRemove(UserProfile profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: appBarColor,
        title: const Text(
          'Cancel Membership',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Are you sure you want to cancel ${profile.name}'s membership (${profile.activeMembership})?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseService.cancelMembership(profile.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${profile.name}'s membership has been canceled."),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: const Text(
            'MANAGE USERS & MEMBERS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
          foregroundColor: Colors.white,
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: accentRed,
            tabs: [
              Tab(text: 'ACTIVE MEMBERS', icon: Icon(Icons.stars_rounded)),
              Tab(text: 'REGULAR USERS', icon: Icon(Icons.people_alt_outlined)),
            ],
          ),
        ),
        body: StreamBuilder<DatabaseEvent>(
          stream: DatabaseService.allUsersStream(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final users = _parseUsers(snap.data!);
            final active = _activeMembers(users);
            final regular = _regularUsers(users);

            return TabBarView(
              children: [_buildActiveTab(active), _buildRegularTab(regular)],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActiveTab(List<UserProfile> members) {
    return ResponsiveCenter(
      child: Column(
        children: [
          _buildStatHeader(members),
          Expanded(
            child: members.isEmpty
                ? const Center(
                    child: Text(
                      'No active members yet.',
                      style: TextStyle(color: Colors.white24),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: members.length,
                    itemBuilder: (context, i) => _buildMemberCard(members[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegularTab(List<UserProfile> users) {
    return ResponsiveCenter(
      child: Column(
        children: [
          _buildSearchHeader(users.length),
          Expanded(
            child: users.isEmpty
                ? const Center(
                    child: Text(
                      'No regular users.',
                      style: TextStyle(color: Colors.white24),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: users.length,
                    itemBuilder: (context, i) => _buildUserCard(users[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Color _getMembershipColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'gold':
        return const Color(0xFFFFD700);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'platinum':
        return const Color(0xFFB0C4DE);
      default:
        return Colors.blueGrey;
    }
  }

  Widget _buildUserCard(UserProfile user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: accentRed.withValues(alpha: 0.1),
          backgroundImage: user.profileImageProvider,
          child: user.profileImageProvider == null
              ? Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: accentRed,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(
          user.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          user.email,
          style: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
      ),
    );
  }

  Widget _buildSearchHeader(int count) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CUSTOMER LIST',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: accentRed.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count Users',
                  style: const TextStyle(
                    color: accentRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) => setState(() => _query = value),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search name or email...',
              hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: accentRed, size: 20),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.white38,
                        size: 18,
                      ),
                      onPressed: () => setState(() => _query = ''),
                    )
                  : null,
              filled: true,
              fillColor: appBarColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatHeader(List<UserProfile> members) {
    int count(String level) =>
        members.where((m) => m.activeMembership == level).length;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: appBarColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statBox('SILVER', count('Silver'), const Color(0xFFC0C0C0)),
          _statBox('GOLD', count('Gold'), const Color(0xFFFFD700)),
          _statBox('PLATINUM', count('Platinum'), const Color(0xFFB0C4DE)),
        ],
      ),
    );
  }

  Widget _statBox(String label, int val, Color color) {
    return Column(
      children: [
        Text(
          val.toString(),
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildMemberCard(UserProfile user) {
    final mColor = _getMembershipColor(user.activeMembership);
    final date = user.membershipExpiry != null
        ? DateFormat('dd MMM yyyy').format(user.membershipExpiry!)
        : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [mColor.withValues(alpha: 0.15), cardColor],
          begin: Alignment.topLeft,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: mColor.withValues(alpha: 0.4), width: 1.2),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: mColor.withValues(alpha: 0.2),
          backgroundImage: user.profileImageProvider,
          child: user.profileImageProvider == null
              ? Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'M',
                  style: TextStyle(color: mColor, fontWeight: FontWeight.bold),
                )
              : null,
        ),
        title: Text(
          user.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Type: ${user.activeMembership} • Exp: $date',
          style: TextStyle(color: mColor.withValues(alpha: 0.8), fontSize: 11),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (user.activeMembership != 'Silver')
              IconButton(
                tooltip: 'Downgrade',
                icon: const Icon(
                  Icons.arrow_circle_down_rounded,
                  color: Colors.orangeAccent,
                  size: 26,
                ),
                onPressed: () => _updateLevel(user, -1),
              ),
            if (user.activeMembership != 'Platinum')
              IconButton(
                tooltip: 'Upgrade',
                icon: const Icon(
                  Icons.arrow_circle_up_rounded,
                  color: Colors.greenAccent,
                  size: 26,
                ),
                onPressed: () => _updateLevel(user, 1),
              ),
            IconButton(
              tooltip: 'Cancel membership',
              icon: const Icon(
                Icons.delete_forever_rounded,
                color: Colors.redAccent,
                size: 24,
              ),
              onPressed: () => _confirmRemove(user),
            ),
          ],
        ),
      ),
    );
  }
}
