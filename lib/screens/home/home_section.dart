import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  _Header(profile: profile),
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: wide ? 1100 : double.infinity,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _NewsCarousel(wide: wide),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 25, 20, 10),
                            child: Text(
                              'Choose Membership',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          _PlansList(price: _price),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.profile});

  final UserProfile? profile;

  void _showEnlargedAvatar(BuildContext context) {
    final provider = profile?.profileImageProvider;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            CircleAvatar(
              radius: 110,
              backgroundColor: const Color(0xFF1A1A2E),
              backgroundImage: provider,
              child: provider == null
                  ? const Icon(Icons.person, size: 90, color: Colors.white24)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = (profile?.name.isEmpty ?? true) ? 'Member' : profile!.name;
    final gender = profile?.gender ?? '';
    final provider = profile?.profileImageProvider;
    final isMale = gender.toLowerCase() == 'male';

    return Container(
      color: appBarColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: provider != null ? () => _showEnlargedAvatar(context) : null,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: accentRed,
              backgroundImage: provider,
              child: provider == null
                  ? const Icon(Icons.person, color: Colors.white70)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $name',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (gender.isNotEmpty)
                Row(
                  children: [
                    Icon(
                      isMale ? Icons.male : Icons.female,
                      color: isMale ? Colors.blue : Colors.pink,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      gender,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NewsCarousel extends StatefulWidget {
  const _NewsCarousel({required this.wide});

  final bool wide;

  @override
  State<_NewsCarousel> createState() => _NewsCarouselState();
}

class _NewsCarouselState extends State<_NewsCarousel> {
  late PageController _controller;
  Timer? _timer;
  int _current = 0;
  int _count = 0;

  double get _viewportFraction => widget.wide ? 0.48 : 0.9;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: _viewportFraction);
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _autoSlide());
  }

  @override
  void didUpdateWidget(covariant _NewsCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.wide != widget.wide) {
      _controller.dispose();
      _controller = PageController(viewportFraction: _viewportFraction);
      _current = 0;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _autoSlide() {
    if (!_controller.hasClients || _count == 0) return;
    final next = (_current + 1) % _count;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: DatabaseService.newsStream(),
      builder: (context, snap) {
        if (!snap.hasData || snap.data!.snapshot.value == null) {
          return const SizedBox(
            height: 160,
            child: Center(child: Text('No news yet.')),
          );
        }
        final raw = Map<dynamic, dynamic>.from(
          snap.data!.snapshot.value as Map,
        );
        final items =
            raw.entries
                .map(
                  (e) => NewsItem.fromRTDB(
                    e.key.toString(),
                    Map<dynamic, dynamic>.from(e.value as Map),
                  ),
                )
                .toList()
              ..sort((a, b) => b.date.compareTo(a.date));
        _count = items.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Latest News',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _controller,
                itemCount: items.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (context, i) => _NewsCard(item: items[i]),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                items.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _current == index ? 20 : 8,
                  decoration: BoxDecoration(
                    color: _current == index
                        ? const Color.fromARGB(255, 103, 112, 172)
                        : Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.item});

  final NewsItem item;

  IconData get _icon {
    switch (item.category.toLowerCase()) {
      case 'promo':
        return Icons.local_offer_rounded;
      case 'event':
        return Icons.event_available_rounded;
      case 'class schedule':
        return Icons.calendar_month_rounded;
      case 'general':
        return Icons.info_outline_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color get _iconColor {
    switch (item.category.toLowerCase()) {
      case 'promo':
        return Colors.orangeAccent;
      case 'event':
        return Colors.cyanAccent;
      case 'class schedule':
        return Colors.lightGreenAccent;
      case 'general':
        return Colors.blueAccent;
      default:
        return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 54, 56, 68),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accentRed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: accentRed.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(_icon, color: _iconColor, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        item.category.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(item.date),
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              item.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
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
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 20,
                ),
                children: [
                  Text(
                    item.category.toUpperCase(),
                    style: const TextStyle(
                      color: accentRed,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    DateFormat('dd MMM yyyy').format(item.date),
                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: Colors.white10),
                  ),
                  Text(
                    item.content,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1F4D),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
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
        final plans =
            raw.entries
                .map(
                  (e) => MembershipPlan.fromRTDB(
                    e.key.toString(),
                    Map<dynamic, dynamic>.from(e.value as Map),
                  ),
                )
                .toList()
              ..sort((a, b) => a.price.compareTo(b.price));

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final plan in plans) _PlanCard(plan: plan, price: price),
            ],
          ),
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
        return const Color(0xFFFFD700);
      case 'Platinum':
        return const Color(0xFFB0C4DE);
      default:
        return const Color(0xFFC0C0C0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MembershipPage(plan: plan)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white24),
          image: DecorationImage(
            image: AssetImage(plan.image),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${plan.name} Member',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _accent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${price.format(plan.price)}/month',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
