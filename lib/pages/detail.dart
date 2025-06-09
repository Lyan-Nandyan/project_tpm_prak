import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:project_tpm_prak/models/boxes.dart';
import 'package:project_tpm_prak/models/favorite.dart';
import 'package:project_tpm_prak/models/movie.dart';
import 'package:project_tpm_prak/services/api_service.dart';
import 'package:project_tpm_prak/widgets/movie_trailer_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Detail extends StatefulWidget {
  final String id;
  const Detail({super.key, required this.id});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  bool isFav = false;
  Movie? _currentMovie;
  String? _userId;
  Box<Favorite>? _favoriteBox;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndInitialize();
  }

  Future<void> _loadUserDataAndInitialize() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    _favoriteBox = Hive.box<Favorite>(HiveBoxes.favorites);

    // Setelah mendapatkan userId dan membuka box, baru ambil detail film
    // dan cek status favorit awal
    if (_userId != null && _favoriteBox != null) {
      await _fetchMovieDetails(); // _checkInitialFavoriteStatus dipanggil di dalam _fetchMovieDetails
    } else {
      // Handle kasus jika userId tidak ditemukan atau box gagal dibuka
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Gagal memuat data pengguna untuk favorit.')),
      );
      // Tetap coba load movie details meskipun favorit mungkin tidak berfungsi
      await _fetchMovieDetails();
    }
  }

  Future<void> _fetchMovieDetails() async {
    try {
      final movieData = await ApiService.getMoviesDetail(widget.id);
      if (!mounted) return;

      setState(() {
        _currentMovie = Movie.fromJson(movieData);
      });

      if (_currentMovie != null) {
        _checkInitialFavoriteStatus();
      }
    } catch (e) {
      debugPrint('Error fetching movie details: $e');
      if (!mounted) return;
      setState(() {
        _currentMovie = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat detail film: $e')),
      );
    }
  }

  void _checkInitialFavoriteStatus() {
    if (_currentMovie == null || _userId == null || _favoriteBox == null) {
      return;
    }
    // Menggunakan composite key untuk memeriksa favorit
    final favoriteKey = '${_userId}_${_currentMovie!.id}';
    if (_favoriteBox!.containsKey(favoriteKey)) {
      if (!mounted) return;
      setState(() {
        isFav = true;
      });
    } else {
      if (!mounted) return;
      setState(() {
        isFav = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_currentMovie == null || _userId == null || _favoriteBox == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Tidak dapat mengubah status favorit saat ini.')),
      );
      return;
    }

    final movie = _currentMovie!;
    final favoriteKey =
        '${_userId}_${movie.id}'; // Composite key: userId + movieId

    setState(() {
      isFav = !isFav;
    });

    if (isFav) {
      // Tambahkan ke favorit
      final newFavorite = Favorite(userId: _userId!, movieId: movie.id);
      await _favoriteBox!.put(favoriteKey, newFavorite);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ditambahkan ke favorit!'),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      // Hapus dari favorit
      await _favoriteBox!.delete(favoriteKey);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dihapus dari favorit!'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: const TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        movie.genre,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  padding: const EdgeInsets.only(left: 8.0, top: 0),
                  constraints: const BoxConstraints(),
                  onPressed: _toggleFavorite, // Panggil fungsi _toggleFavorite
                  icon: Icon(
                    isFav ? Icons.star : Icons.star_border,
                    color: isFav ? Colors.amber : Colors.grey,
                    size: 30,
                  ),
                  tooltip: isFav ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                ),
              ],
            ),
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
            MovieTrailerPlayer(trailerUrl: movie.trailerUrl),
          ],
        ),
      ),
    );
  }
}
