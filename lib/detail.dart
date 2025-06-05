import 'package:flutter/material.dart';
import 'package:project_tpm_prak/models/movie.dart';
import 'package:project_tpm_prak/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Detail extends StatefulWidget {
  final String id;
  const Detail({super.key, required this.id});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  bool isFav = false;
  YoutubePlayerController? _youtubeController; // Tetap nullable
  Movie? _currentMovie;

  @override
  void initState() {
    super.initState();
    _fetchAndInitializeMovieData();
  }

  // Fungsi untuk mengambil data film dan menginisialisasi controller
  Future<void> _fetchAndInitializeMovieData() async {
    try {
      final movie =
          await ApiService.getMoviesDetail(widget.id).then(Movie.fromJson);

      if (!mounted) return; // Pastikan widget masih mounted setelah async gap

      // Inisialisasi controller di sini
      YoutubePlayerController? tempYoutubeController;
      String? videoId = YoutubePlayer.convertUrlToId(movie.trailerUrl);

      if (videoId != null && videoId.isNotEmpty) {
        // Hanya buat controller baru jika ID video berubah atau belum ada controller
        if (_youtubeController == null ||
            _youtubeController!.initialVideoId != videoId) {
          // *** Penting: Buang controller lama SEBELUM membuat yang baru ***
          _youtubeController?.dispose();
          tempYoutubeController = YoutubePlayerController(
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
          // Jika ID video sama, gunakan controller yang sudah ada
          tempYoutubeController = _youtubeController;
        }
      } else {
        // Jika URL trailer tidak valid, buang controller lama dan set ke null
        _youtubeController?.dispose(); // Pastikan controller lama dibuang
        tempYoutubeController = null;
      }

      setState(() {
        _currentMovie = movie;
        _youtubeController =
            tempYoutubeController; // Tetapkan controller yang baru/diperbarui
      });
    } catch (e) {
      debugPrint('Error fetching movie details: $e');
      if (!mounted) return; // Pastikan widget masih mounted

      setState(() {
        _currentMovie = null; // Tandai bahwa data gagal dimuat
        // *** Penting: Buang controller jika ada error saat inisialisasi/pembaruan ***
        _youtubeController?.dispose();
        _youtubeController = null;
      });

      if (mounted) {
        // Cek mounted sebelum mengakses BuildContext
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load movie details: $e')),
        );
      }
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
  void deactivate() {
    // *** Penting: Jeda video saat widget tidak lagi aktif (misalnya, menekan tombol back) ***
    _youtubeController?.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    // *** Penting: Buang sumber daya controller saat widget dihancurkan ***
    _youtubeController?.dispose();
    _youtubeController = null; // Set ke null setelah dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan indikator loading jika data film masih null
    if (_currentMovie == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.blueGrey,
          title: const Text("Movie Detail"),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Gunakan data film yang sudah dimuat
    final movie = _currentMovie!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text("Movie Detail"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                movie.posterUrl,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.movie, size: 150, color: Colors.white70),
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    movie.title,
                    style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  alignment: Alignment.bottomRight,
                  onPressed: () {
                    setState(() {
                      isFav = !isFav;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isFav
                            ? 'Ditambahkan ke favorit!'
                            : 'Dihapus dari favorit!'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: Icon(
                    isFav ? Icons.star : Icons.star_border,
                    color: isFav ? Colors.amber : Colors.grey,
                  ),
                  tooltip: isFav ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                ),
              ],
            ),
            Text(movie.genre,
                style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 16),
            const Text('Synopsis:',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(movie.synopsis,
                style: const TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 16),
            Text('Director: ${movie.director}',
                style: const TextStyle(color: Colors.white)),
            Text('Duration: ${movie.duration} min',
                style: const TextStyle(color: Colors.white)),
            Text('Language: ${movie.language}',
                style: const TextStyle(color: Colors.white)),
            Text('Release: ${movie.releaseDate}',
                style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            const Text('Cast:',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: movie.cast
                  .map((actor) => Chip(
                        label: Text(actor,
                            style: const TextStyle(color: Colors.white)),
                        backgroundColor: Colors.blueGrey.withOpacity(0.4),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            // Tampilkan YoutubePlayer hanya jika _youtubeController tidak null
            if (_youtubeController != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Trailer:',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  YoutubePlayer(
                    controller:
                        _youtubeController!, // Operator '!' tetap diperlukan di sini
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
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () =>
                        _launchUrlExternal(context, movie.trailerUrl),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text("Open Trailer in Browser"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                    ),
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: () {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Trailer tidak tersedia atau URL tidak valid.')),
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
          ],
        ),
      ),
    );
  }
}
