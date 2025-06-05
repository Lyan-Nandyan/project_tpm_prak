// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:project_tpm_prak/pages/detail.dart'; //
import 'package:project_tpm_prak/models/movie.dart'; //
import 'package:project_tpm_prak/services/api_service.dart'; //
import 'package:project_tpm_prak/widgets/movie_carousel_banner.dart'; // Import widget baru
import 'package:project_tpm_prak/widgets/search_bar_widget.dart'; // Import widget baru

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<List<Movie>> fetchAllMovies() async {
    final rawList = await ApiService.fetchMovies(''); //
    return rawList.map((e) => Movie.fromJson(e)).toList(); //
  }

  // Pertahankan _durationBadge di sini karena tidak dipisah
  Widget _durationBadge(int duration) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(9),
          bottomRight: Radius.circular(9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '$duration min',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Pertahankan _ratingBadge di sini karena tidak dipisah
  Widget _ratingBadge(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(9),
          bottomLeft: Radius.circular(9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 12, color: Colors.amber),
          const SizedBox(width: 2),
          Text(
            '$rating',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Movie App'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: SearchBarWidget(), // Gunakan widget SearchBarWidget
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Random Movies ',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                      child:
                          MovieCarouselBanner()), // Gunakan widget MovieCarouselBanner
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "All Movies",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  FutureBuilder<List<Movie>>(
                    future: fetchAllMovies(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(50.0),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(50.0),
                              child: Text('Error: ${snapshot.error}'),
                            ),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(50.0),
                              child: Text('No movies found.'),
                            ),
                          ),
                        );
                      } else {
                        final movies = snapshot.data!;
                        return SliverPadding(
                          padding: const EdgeInsets.all(6.0),
                          sliver: SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final movie = movies[index]; //
                                return Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(9),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(9),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              Detail(id: movie.id), //
                                        ),
                                      );
                                    },
                                    child: Card(
                                      color: Colors.white10,
                                      elevation: 8,
                                      shadowColor: Colors.black26,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 5,
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                      top: Radius.circular(9)),
                                              child: Stack(
                                                children: [
                                                  Image.network(
                                                    movie.posterUrl, //
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        const Center(
                                                      child: Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        color: Colors.white,
                                                        size: 50,
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 0,
                                                    left: 0,
                                                    child: _durationBadge(movie
                                                        .duration), // Gunakan fungsi lokal
                                                  ),
                                                  Positioned(
                                                    top: 0,
                                                    right: 0,
                                                    child: _ratingBadge(movie
                                                        .rating), // Gunakan fungsi lokal
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                movie.title, //
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: movies.length,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1 / 1.3,
                              crossAxisSpacing: 6,
                              mainAxisSpacing: 6,
                            ),
                          ),
                        );
                      }
                    },
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
