import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Results {
  List<Result> results;

  Results({required this.results});

  factory Results.fromJson(Map<String, dynamic> json) {
    var resultsList = json['results'] as List;
    List<Result> results = resultsList.map((i) => Result.fromJson(i)).toList();

    return Results(
      results: results,
    );
  }
}

class Result {
  String releaseDate;
  String title;
  String poster;

  Result({required this.releaseDate, required this.title, required this.poster});

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      releaseDate: json['release_date'],
      title: json['title'],
      poster: "https://image.tmdb.org/t/p/w500${json['backdrop_path']}"
    );
  }
}


class MoviesList extends StatefulWidget {
  const MoviesList({Key? key}) : super(key: key);

  @override
  _MoviesListState createState() => _MoviesListState();
}

class _MoviesListState extends State<MoviesList> {
  late Results results;
  Future<void> fetchMovies() async {
    final response = await http.get(Uri.parse('https://api.themoviedb.org/3/movie/upcoming?api_key=use_your_key_here'));
    final data = json.decode(response.body);
    setState(() {
      results = Results.fromJson(data);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MoviesApp'),
      ),
      body: ListView.builder(
        itemCount: results.results.length,
        itemBuilder: (context, index) {
          final movie = results.results[index];
          return Container(
              margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              child : Ink(
                height: 150.0,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                  image: DecorationImage(
                    image: NetworkImage(movie.poster),
                    fit: BoxFit.cover,
                  ),
                ),
                child: ListTile(
                  title: Text(movie.title),
                  subtitle: Text(movie.releaseDate),
                  onTap: () {
                  },
                ),
              )
          );
        },
      ),
    );
  }

}