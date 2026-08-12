import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/membership_plan.dart';
import '../../models/news_item.dart';
import '../../models/user_profile.dart';
import '../../services/database_service.dart';
import 'membership_page.dart';

class HomeSection extends StatefulWidget {
  const HomeSection({super.key});

  @override
  State<HomeSection> createState() => _HomeSectionState();
}

class _HomeSectionState extends State<HomeSection> {
  final _price = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    final uid = user.uid;
    return StreamBuilder<DatabaseEvent>(
      stream: DatabaseService.singleUserStream(uid),
      builder: (context, snap) {
        UserProfile? profile;
        if (snap.hasData && snap.data!.snapshot.value is Map) {
          profile = UserProfile.fromRTDB(
            uid,
            Map<dynamic, dynamic>.from(snap.data!.snapshot.value as Map),
          );
        }

        return SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: () => Future.delayed(const Duration(milliseconds: 400)),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                _Header(profile: profile, uid: uid),
                const SizedBox(height: 8),
                _MembershipBanner(profile: profile),
                const _SectionHeader('Berita Terbaru'),
                _NewsCarousel(),
                const _SectionHeader('Pilih Keanggotaan'),
                _PlansList(price: _price),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.profile, required this.uid});

  final UserProfile? profile;
  final String uid;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Image.asset('images/gymlife.png', width: 44, height: 44),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'GymLife',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF3357A4),
                ),
              ),
              Text(
                'Halo, ${profile?.name.isEmpty ?? true ? 'Member' : profile!.name}!',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE8EEFF),
            backgroundImage: profile?.profileImageProvider,
            child: profile?.profileImageProvider == null
                ? const Icon(Icons.person, color: Color(0xFF4C7FFF))
                : null,
          ),
        ],
      ),
    );
  }
}

class _MembershipBanner extends StatelessWidget {
  const _MembershipBanner({required this.profile});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final p = profile;
    if (p == null || !p.hasMembership) {
      return Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4C7FFF), Color(0xFF3357A4)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.fitness_center, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Upgrade keanggotaanmu sekarang dan nikmati berbagai fasilitas eksklusif!',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    final active = p.isMembershipActive;
    final date = p.membershipExpiry != null
        ? DateFormat('dd MMM yyyy').format(p.membershipExpiry!)
        : '-';
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
            p.membershipImage!,
            width: 56,
            height: 56,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${p.activeMembership} Member',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  active ? 'Berlaku hingga $date' : 'Status: Kadaluarsa',
                  style: TextStyle(
                    color: active ? Colors.white70 : Colors.orangeAccent,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: active ? Colors.green : Colors.orange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              active ? 'Aktif' : 'Expired',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
    );
  }
}

class _NewsCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: DatabaseService.newsStream(),
      builder: (context, snap) {
        if (!snap.hasData || snap.data!.snapshot.value == null) {
          return const SizedBox(
            height: 140,
            child: Center(child: Text('Belum ada berita.')),
          );
        }
        final raw = Map<dynamic, dynamic>.from(
          snap.data!.snapshot.value as Map,
        );
        final items = raw.entries
            .map(
              (e) => NewsItem.fromRTDB(
                e.key.toString(),
                Map<dynamic, dynamic>.from(e.value as Map),
              ),
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        return SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            itemBuilder: (context, i) => _NewsCard(item: items[i]),
          ),
        );
      },
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.item});

  final NewsItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFE8EEFF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF4C7FFF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item.category,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Spacer(),
            Text(
              DateFormat('dd MMM yyyy').format(item.date),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF4C7FFF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item.category,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd MMM yyyy').format(item.date),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 14),
            Text(item.content),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _PlansList extends StatelessWidget {
  const _PlansList({required this.price});

  final NumberFormat price;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: DatabaseService.plansStream(),
      builder: (context, snap) {
        if (!snap.hasData || snap.data!.snapshot.value == null) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final raw = Map<dynamic, dynamic>.from(
          snap.data!.snapshot.value as Map,
        );
        final plans = raw.entries
            .map(
              (e) => MembershipPlan.fromRTDB(
                e.key.toString(),
                Map<dynamic, dynamic>.from(e.value as Map),
              ),
            )
            .toList()
          ..sort((a, b) => a.price.compareTo(b.price));

        return Column(
          children: [
            for (final plan in plans) _PlanCard(plan: plan, price: price),
          ],
        );
      },
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.price});

  final MembershipPlan plan;
  final NumberFormat price;

  Color get _accent {
    switch (plan.name) {
      case 'Gold':
        return const Color(0xFFD4A017);
      case 'Platinum':
        return const Color(0xFF7B68EE);
      default:
        return const Color(0xFF8D99AE);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        elevation: 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MembershipPage(plan: plan),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: _accent.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Image.asset(
                  plan.image,
                  width: 56,
                  height: 56,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${price.format(plan.price)} / ${plan.durationDays} hari',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        plan.benefits.join(' • '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
