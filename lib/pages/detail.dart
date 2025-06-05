import 'package:flutter/material.dart';
import 'package:project_tpm_prak/models/movie.dart';
import 'package:project_tpm_prak/services/api_service.dart';
import 'package:project_tpm_prak/widgets/movie_trailer_player.dart';

class Detail extends StatefulWidget {
  final String id;
  const Detail({super.key, required this.id});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  bool isFav = false;
  Movie? _currentMovie;

  @override
  void initState() {
    super.initState();
    _fetchMovieDetails();
  }

  // Fungsi untuk mengambil data film
  Future<void> _fetchMovieDetails() async {
    try {
      final movie =
          await ApiService.getMoviesDetail(widget.id).then(Movie.fromJson);

      if (!mounted) return;

      setState(() {
        _currentMovie = movie;
      });
    } catch (e) {
      debugPrint('Error fetching movie details: $e');
      if (!mounted) return;

      setState(() {
        _currentMovie = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load movie details: $e')),
        );
      }
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
            MovieTrailerPlayer(
                trailerUrl: movie.trailerUrl), // Gunakan widget baru
          ],
        ),
      ),
    );
  }
}
