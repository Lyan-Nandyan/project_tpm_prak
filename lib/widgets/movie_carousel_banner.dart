
import 'package:flutter/material.dart';
import 'package:project_tpm_prak/pages/detail.dart'; 
import 'package:project_tpm_prak/models/movie.dart'; 
import 'package:project_tpm_prak/services/api_service.dart'; 
import 'dart:math';

class MovieCarouselBanner extends StatefulWidget {
  const MovieCarouselBanner({super.key});

  @override
  State<MovieCarouselBanner> createState() => _MovieCarouselBannerState();
}

class _MovieCarouselBannerState extends State<MovieCarouselBanner> {
  final PageController _pageController = PageController(viewportFraction: 0.85);

  Future<List<Movie>> _fetchRandomFeaturedMovies() async {
    try {
      final rawList = await ApiService.fetchMovies(''); //
      final allMovies = rawList.map((e) => Movie.fromJson(e)).toList(); //
      allMovies.shuffle(Random());
      return allMovies.take(5).toList();
    } catch (e) {
      debugPrint('Error loading random featured movies: $e');
      return [];
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Movie>>(
      future: _fetchRandomFeaturedMovies(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 180,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return const SizedBox(
              height: 180,
              child: Center(
                  child: Text("Gagal memuat film unggulan.",
                      style: TextStyle(color: Colors.red))));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(
              height: 180,
              child: Center(
                  child: Text("Tidak ada film unggulan ditemukan.",
                      style: TextStyle(color: Colors.white))));
        }

        final featuredMovies = snapshot.data!;
        return SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: featuredMovies.length,
            itemBuilder: (context, index) {
              final movie = featuredMovies[index]; //
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  try {
                    if (_pageController.hasClients &&
                        _pageController.position.haveDimensions) {
                      value = (_pageController.page! - index).abs();
                      value = (1 - (value * 0.3)).clamp(0.0, 1.0);
                    }
                  } catch (_) {}

                  return Center(
                    child: Transform.scale(
                      scale: value,
                      child: child,
                    ),
                  );
                },
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Detail(id: movie.id), //
                      ),
                    );
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        )
                      ],
                      image: DecorationImage(
                        image: NetworkImage(movie.posterUrl), //
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          debugPrint('Error loading image: $exception');
                        },
                      ),
                    ),
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(12)),
                        color: Colors.black45,
                      ),
                      child: Text(
                        movie.title, //
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
