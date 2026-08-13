import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../constants.dart';
import '../../widgets/responsive_center.dart';

class ExercisePage extends StatelessWidget {
  const ExercisePage({super.key});

  static const List<Map<String, String>> _exercises = [
    {
      'title': 'Push Up',
      'subtitle': 'Chest & Arms',
      'videoId': 'fMKBfvsltAQ',
      'thumb':
          'https://media.istockphoto.com/id/1455998438/id/vektor/manusia-melakukan-latihan-push-up-ilustrasi-terisolasi-vektor-2d.jpg?s=612x612&w=0&k=20&c=-10NuzeJpUw6R-J7QQ-wxLYdvlWUcNwqv6TZwzu3xCQ=',
      'color': '0xFFFF4B2B',
    },
    {
      'title': 'Sit Up',
      'subtitle': 'Core Strength',
      'videoId': 'JjxM9CLjtLs',
      'thumb':
          'https://st4.depositphotos.com/1173077/38640/v/450/depositphotos_386400086-stock-illustration-simple-flat-cartoon-illustration-woman.jpg',
      'color': '0xFF4776E6',
    },
    {
      'title': 'Pull Up',
      'subtitle': 'Back Strength',
      'videoId': 'xf7ctwjcYjo',
      'thumb':
          'https://www.shutterstock.com/shutterstock/videos/1070098513/thumb/1.jpg?ip=x480',
      'color': '0xFFF09819',
    },
  ];

  void _openVideo(BuildContext context, String videoId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoFullScreenPage(videoId: videoId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: const Text(
            'WORKOUT GUIDES',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontSize: 18,
            ),
          ),
        ),
        body: ResponsiveCenter(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _exercises.length,
            itemBuilder: (context, i) => _PremiumCard(
              item: _exercises[i],
              onPlay: () => _openVideo(context, _exercises[i]['videoId']!),
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({required this.item, required this.onPlay});

  final Map<String, String> item;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final themeColor = Color(int.parse(item['color']!));

    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPlay,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: themeColor.withValues(alpha: 0.6),
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        item['thumb']!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.fitness_center,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title']!.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          item['subtitle']!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: themeColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'WATCH',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VideoFullScreenPage extends StatefulWidget {
  final String videoId;
  const VideoFullScreenPage({super.key, required this.videoId});

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
        mute: false,
        showFullscreenButton: true,
        playsInline: false,
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
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: YoutubePlayer(controller: _controller),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 30,
              ),
              style: IconButton.styleFrom(backgroundColor: Colors.white24),
            ),
          ),
        ],
      ),
    );
  }
}
