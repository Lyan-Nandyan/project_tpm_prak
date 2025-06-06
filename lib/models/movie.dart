class Movie {
  final String id;
  final String title;
  final String genre;
  final int duration;
  final String posterUrl;
  final String synopsis;
  final String releaseDate;
  final String director;
  final List<String> cast;
  final double rating;
  final String language;
  final String trailerUrl;

  Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.duration,
    required this.posterUrl,
    required this.synopsis,
    required this.releaseDate,
    required this.director,
    required this.cast,
    required this.rating,
    required this.language,
    required this.trailerUrl,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      genre: json['genre'] ?? '',
      duration: json['duration'] ?? 0,
      posterUrl: json['posterUrl'] ?? '',
      synopsis: json['synopsis'] ?? '',
      releaseDate: json['releaseDate'] ?? '',
      director: json['director'] ?? '',
      cast: List<String>.from(json['cast']),
      rating: (json['rating'] as num).toDouble(),
      language: json['language'] ?? '',
      trailerUrl: json['trailerUrl'] ?? '',
    );
  }
}
