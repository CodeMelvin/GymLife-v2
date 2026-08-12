import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class ExercisePage extends StatelessWidget {
  const ExercisePage({super.key});

  static const List<Map<String, String>> _exercises = [
    {
      'title': 'Push Up',
      'subtitle': 'Melatih Dada & Lengan',
      'videoId': 'fMKBfvsltAQ',
      'thumb':
          'https://media.istockphoto.com/id/1455998438/id/vektor/manusia-melakukan-latihan-push-up-ilustrasi-terisolasi-vektor-2d.jpg?s=612x612&w=0&k=20&c=-10NuzeJpUw6R-J7QQ-wxLYdvlWUcNwqv6TZwzu3xCQ=',
    },
    {
      'title': 'Sit Up',
      'subtitle': 'Membentuk Otot Perut',
      'videoId': 'JjxM9CLjtLs',
      'thumb':
          'https://st4.depositphotos.com/1173077/38640/v/450/depositphotos_386400086-stock-illustration-simple-flat-cartoon-illustration-woman.jpg',
    },
    {
      'title': 'Pull Up',
      'subtitle': 'Kekuatan Punggung',
      'videoId': 'xf7ctwjcYjo',
      'thumb':
          'https://www.shutterstock.com/shutterstock/videos/1070098513/thumb/1.jpg?ip=x480',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Text(
              'Panduan Latihan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              'Ikuti video panduan dari para ahli untuk berolahraga mandiri di rumah.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          for (final exercise in _exercises)
            _ExerciseCard(exercise: exercise),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise});

  final Map<String, String> exercise;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
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
                builder: (_) => VideoFullScreenPage(
                  videoId: exercise['videoId']!,
                  title: exercise['title']!,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    exercise['thumb']!,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 72,
                      height: 72,
                      color: const Color(0xFFE8EEFF),
                      child: const Icon(Icons.fitness_center),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise['title']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exercise['subtitle']!,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFF4C7FFF),
                  child: Icon(Icons.play_arrow, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VideoFullScreenPage extends StatefulWidget {
  const VideoFullScreenPage({super.key, required this.videoId, required this.title});

  final String videoId;
  final String title;

  @override
  State<VideoFullScreenPage> createState() => _VideoFullScreenPageState();
}

class _VideoFullScreenPageState extends State<VideoFullScreenPage> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        strictRelatedVideos: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: YoutubePlayer(controller: _controller),
        ),
      ),
    );
  }
}
