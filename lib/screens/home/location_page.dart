import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants.dart';
import '../../models/gym_location.dart';
import '../../services/database_service.dart';
import '../../widgets/responsive_center.dart';

class LocationPage extends StatelessWidget {
  const LocationPage({super.key});

  void _showLocationDetail(BuildContext context, GymLocation location) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, color: Colors.white24),
            ),
            const SizedBox(height: 20),
            Text(
              location.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.redAccent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    location.address,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: Colors.blueAccent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Hours: ${location.hours}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _openMaps(location),
              icon: const Icon(Icons.map),
              label: const Text(
                'Open in Google Maps',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentRed,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openMaps(GymLocation location) async {
    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': '${location.name}, ${location.address}',
    });
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: const Text(
            'GYM LOCATIONS',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: ResponsiveCenter(
          child: StreamBuilder<DatabaseEvent>(
            stream: DatabaseService.locationsStream(),
            builder: (context, snap) {
              if (!snap.hasData || snap.data!.snapshot.value == null) {
                return const Center(child: CircularProgressIndicator());
              }
              final raw = Map<dynamic, dynamic>.from(
                snap.data!.snapshot.value as Map,
              );
              final locations = raw.entries
                  .map(
                    (e) => GymLocation.fromRTDB(
                      e.key.toString(),
                      Map<dynamic, dynamic>.from(e.value as Map),
                    ),
                  )
                  .toList();

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  final loc = locations[index];
                  return GestureDetector(
                    onTap: () => _showLocationDetail(context, loc),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: NetworkImage(loc.imageUrl),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withValues(alpha: 0.4),
                            BlendMode.darken,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              loc.address,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
