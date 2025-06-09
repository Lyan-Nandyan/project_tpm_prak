import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_tpm_prak/models/boxes.dart';
import 'package:project_tpm_prak/models/favorite.dart';
import 'package:project_tpm_prak/models/movie.dart';
import 'package:project_tpm_prak/pages/detail.dart';
import 'package:project_tpm_prak/pages/login_page.dart';
import 'package:project_tpm_prak/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Favoritepage extends StatefulWidget {
  const Favoritepage({super.key});

  @override
  State<Favoritepage> createState() => _FavoritepageState();
}

class _FavoritepageState extends State<Favoritepage> {
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString('userId');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Favorites'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.login, size: 80, color: Colors.grey),
              const SizedBox(height: 20),
              const Text(
                'Silakan login untuk melihat daftar favorit Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text('Login Sekarang'),
              )
            ],
          ),
        ),
      );
    }

    final favoriteBox = Hive.box<Favorite>(HiveBoxes.favorites);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorite Movies'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<Box<Favorite>>(
        valueListenable: favoriteBox.listenable(),
        builder: (context, box, _) {
          final userFavoriteMovies =
              box.values.where((fav) => fav.userId == _currentUserId).toList();

          if (userFavoriteMovies.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.movie_filter_outlined,
                      size: 100, color: Colors.grey),
                  SizedBox(height: 20),
                  Text('Anda belum menambahkan film favorit.',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: userFavoriteMovies.length,
            itemBuilder: (context, index) {
              final favorite = userFavoriteMovies[index];
              return FavoriteMovieCard(movieId: favorite.movieId);
            },
          );
        },
      ),
    );
  }
}

class FavoriteMovieCard extends StatelessWidget {
  final String movieId;
  const FavoriteMovieCard({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService.getMoviesDetail(movieId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: ListTile(title: LinearProgressIndicator(minHeight: 10)),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.error_outline, color: Colors.red),
              title: Text('Gagal memuat film ID: $movieId',
                  style: const TextStyle(color: Colors.redAccent)),
              subtitle: Text(snapshot.error.toString(),
                  style: const TextStyle(fontSize: 10)),
            ),
          );
        }

        final movie = Movie.fromJson(snapshot.data!);

        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: Image.network(
                movie.posterUrl,
                width: 60,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 90,
                    color: Colors.grey[800],
                    child: const Icon(Icons.movie_creation_outlined,
                        color: Colors.white30)),
              ),
            ),
            title: Text(movie.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movie.genre),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(movie.rating.toString()),
                  ],
                )
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Detail(id: movie.id)),
              );
            },
          ),
        );
      },
    );
  }
}
