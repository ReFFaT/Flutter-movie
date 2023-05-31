import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Поиск фильма',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  void _searchMovies(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    String searchText = _searchController.text;
    String apiUrl = 'https://imdb-api.com/ru/API/Search/k_qemcyij9/$searchText';

    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['results'] != null &&
          responseData['results'].length > 0) {
        List<dynamic> movies = responseData['results'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieListPage(movies: movies),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Нет Фильмов'),
            content: Text('По вашему запросу фильмы не найдены'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ошибка'),
          content: Text('ошибка загрузки фильма'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Поиск фильма'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Поиск Фильма',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Ведите название фильма',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              style: ButtonStyle(),
              onPressed: _isLoading ? null : () => _searchMovies(context),
              child: _isLoading ? CircularProgressIndicator() : Text('Поиск'),
            ),
          ],
        ),
      ),
    );
  }
}

class MovieListPage extends StatelessWidget {
  final List<dynamic> movies;

  MovieListPage({required this.movies});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Фильмы'),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10.0),
              ),
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(16.0),
              child: ListTile(
                leading: Image.network(
                  movie[
                      'image'], // Замените на поле с URL постера из вашего API
                  width: 50,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                title: Text(movie['title'],
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(movie['description']),
              ),
            );
          },
        ),
      ),
    );
  }
}
