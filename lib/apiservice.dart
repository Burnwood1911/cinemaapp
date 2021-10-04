import 'dart:convert';

import 'package:cinemaapp/models/genre.dart';
import 'package:cinemaapp/models/movie.dart';
import 'package:cinemaapp/models/movie_images.dart';

import 'package:http/http.dart' as http;

import 'models/movie_detail.dart';

class ApiService {
  final String baseUrl = 'https://api.themoviedb.org/3';
  final String apiKey = '3a5a4ffaa8e90b1b48c448d9c96637da';

  Future<List<Movie>> getTopRatedMovies() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/movie/now_playing?api_key=$apiKey'));

      var movies = await jsonDecode(response.body)['results'] as List;

      List<Movie> movielist = movies.map((e) => Movie.fromJson(e)).toList();

      return movielist;
    } catch (error, stack) {
      throw Exception('Exception occured: $error with stacktrace $stack');
    }
  }

  Future<List<Genre>> getGenreList() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/genre/movie/list?api_key=$apiKey'));

      var genres = await jsonDecode(response.body)['genres'] as List;

      List<Genre> genrelist = genres.map((e) => Genre.fromJson(e)).toList();

      return genrelist;
    } catch (error, stack) {
      throw Exception('Exception occured: $error with stacktrace $stack');
    }
  }

  Future<List<Movie>> getMoviesByGenre(int movieId) async {
    try {
      final response = await http.get(Uri.parse(
          '$baseUrl/discover/movie?api_key=$apiKey&with_genres=$movieId'));

      //debugPrint('$movieId');

      var movies = await jsonDecode(response.body)['results'] as List;

      List<Movie> movielist = movies.map((e) => Movie.fromJson(e)).toList();

      return movielist;
    } catch (error, stack) {
      throw Exception('Exception occured: $error with stacktrace: $stack');
    }
  }

  Future<MovieDetail> movieDetail(int movieId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/movie/$movieId?api_key=$apiKey'));

      // debugPrint('$movieId');

      MovieDetail movieDetail = MovieDetail.fromJson(jsonDecode(response.body));
      movieDetail.trailerId = await getYoutubeId(movieId);
      movieDetail.castList = await getCasts(movieId);

      return movieDetail;
    } catch (error, stack) {
      throw Exception('Exception occured: $error with stacktrace: $stack');
    }
  }

  Future<String> getYoutubeId(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/movie/$id/videos?api_key=$apiKey'));

      var youtubeId = jsonDecode(response.body)['results'][0]['key'];

      return youtubeId;
    } catch (e) {
      return '';
    }
  }

  Future<List<Backdrops>> movieImages(int movieId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/movie/$movieId/images?api_key=$apiKey'));

      // debugPrint('$movieId');

      var backdrops = await jsonDecode(response.body)['backdrops'] as List;

      List<Backdrops> backdroplist =
          backdrops.map((e) => Backdrops.fromJson(e)).toList();

      return backdroplist;
    } catch (error, stack) {
      throw Exception('Exception occured: $error with stacktrace: $stack');
    }
  }

  Future<List> getCasts(int id) async {
    try {
      List<String> finalCast = [];
      final response = await http
          .get(Uri.parse('$baseUrl/movie/$id/credits?api_key=$apiKey'));

      var casts = await jsonDecode(response.body)['cast'];

      casts.forEach((element) {
        finalCast.add(element['name']);
      });

      return finalCast;
    } catch (error, stack) {
      throw Exception('Exception occured: $error with stacktrace: $stack');
    }
  }
}
