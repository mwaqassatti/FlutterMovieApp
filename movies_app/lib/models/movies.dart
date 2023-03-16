import 'dart:convert';
import 'package:flutter/foundation.dart';
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
  late Results _results;
  late ScrollController _controller;

  int _page = 1;
  bool _isLoadMoreRunning = false;
  bool _hasNextPage = true;

  Future<void> fetchMovies() async {
    final response = await http.get(Uri.parse('https://api.themoviedb.org/3/movie/upcoming?api_key=key&page=$_page'));
    final data = json.decode(response.body);
    setState(() {
      _results = Results.fromJson(data);
    });
  }

  @override
  void initState() {
    _controller = ScrollController()..addListener(_loadMore);
    fetchMovies();
    super.initState();
  }

  void _loadMore() async {
    if(_hasNextPage == true &&
       _isLoadMoreRunning == false &&
       _controller.position.extentAfter < 300) {
      _page += 1;
      setState(() {
        _isLoadMoreRunning = true;
      });
      try {
        final response = await http.get(Uri.parse('https://api.themoviedb.org/3/movie/upcoming?api_key=9d934681296ecaf3e57d3cbb62332a4e&page=$_page'));
        final data = json.decode(response.body);
        if(data != null) {
          setState(() {
            _isLoadMoreRunning = false;
            _results.results.addAll(Results.fromJson(data).results);
          }); 
        } else {
          setState(() {
            _hasNextPage = false;
          });
        }
      } catch(err) {
        if (kDebugMode) {
          print('Something went wrong');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MoviesApp'),
      ),
      body: ListView.builder(
        controller: _controller,
        itemCount: _results.results.length,
        itemBuilder: (context, index) {
          final movie = _results.results[index];
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