import 'dart:convert';

import 'package:cinemaapp/models/genre.dart';
import 'package:cinemaapp/models/movie.dart';
import 'package:flutter/cupertino.dart';

import 'package:http/http.dart' as http;

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

      debugPrint('$movieId');

      var movies = await jsonDecode(response.body)['results'] as List;

      List<Movie> movielist = movies.map((e) => Movie.fromJson(e)).toList();

      return movielist;
    } catch (error, stack) {
      throw Exception('Exception occured: $error with stacktrace: $stack');
    }
  }
}
