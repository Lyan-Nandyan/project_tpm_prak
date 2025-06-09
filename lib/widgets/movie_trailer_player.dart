
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MovieTrailerPlayer extends StatefulWidget {
  final String trailerUrl;

  const MovieTrailerPlayer({super.key, required this.trailerUrl});

  @override
  State<MovieTrailerPlayer> createState() => _MovieTrailerPlayerState();
}

class _MovieTrailerPlayerState extends State<MovieTrailerPlayer> {
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    _initializeYoutubeController();
  }

  void _initializeYoutubeController() {
    String? videoId = YoutubePlayer.convertUrlToId(widget.trailerUrl);

    if (videoId != null && videoId.isNotEmpty) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          forceHD: false,
          enableCaption: true,
        ),
      );
    } else {
      _youtubeController = null;
    }
  }

  void _launchUrlExternal(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!mounted) return;
        if (!launched) throw 'Could not launch $url';
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka link: $e')),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL tidak valid')),
      );
    }
  }

  @override
  void didUpdateWidget(covariant MovieTrailerPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trailerUrl != widget.trailerUrl) {
      _youtubeController?.dispose(); // Dispose old controller
      _initializeYoutubeController(); // Initialize new controller
    }
  }

  @override
  void deactivate() {
    _youtubeController?.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _youtubeController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Trailer:',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (_youtubeController != null)
          YoutubePlayer(
            controller: _youtubeController!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.amber,
            progressColors: const ProgressBarColors(
              playedColor: Colors.amber,
              handleColor: Colors.amberAccent,
            ),
            onReady: () {
              debugPrint('YouTube Player is ready.');
            },
            bottomActions: [
              CurrentPosition(),
              ProgressBar(),
              const RemainingDuration(),
              FullScreenButton(),
            ],
          )
        else
          ElevatedButton.icon(
            onPressed: () {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Trailer tidak tersedia atau URL tidak valid.')),
                );
              }
            },
            icon: const Icon(Icons.info_outline),
            label: const Text("Trailer Not Available"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              minimumSize: const Size.fromHeight(40),
            ),
          ),
        const SizedBox(height: 10),
        if (_youtubeController !=
            null) // Hanya tampilkan tombol jika trailer tersedia
          ElevatedButton.icon(
            onPressed: () => _launchUrlExternal(context, widget.trailerUrl),
            icon: const Icon(Icons.open_in_new),
            label: const Text("Open Trailer in Browser"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
            ),
          )
        else
          const SizedBox.shrink(), // Sembunyikan jika tidak ada trailer
      ],
    );
  }
}
