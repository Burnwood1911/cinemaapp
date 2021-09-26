import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cinemaapp/apiservice.dart';
import 'package:cinemaapp/models/movie.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(brightness: Brightness.dark),
        title: 'CinemaApp',
        home: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: const Icon(
                Icons.menu,
                color: Colors.black54,
              ),
              centerTitle: true,
              title: const Text(
                "CINEMA",
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              actions: [
                Container(
                    margin: const EdgeInsets.only(right: 15),
                    child: const Icon(
                      Icons.logout,
                      color: Colors.black54,
                    ))
              ],
            ),
            body: LayoutBuilder(builder: (context, boxconstraints) {
              return SingleChildScrollView(
                  child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: boxconstraints.maxHeight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [KappaWidget()],
                          )
                        ],
                      )));
            })));
  }
}

class KappaWidget extends StatefulWidget {
  const KappaWidget({Key? key}) : super(key: key);

  @override
  _KappaWidgetState createState() => _KappaWidgetState();
}

class _KappaWidgetState extends State<KappaWidget> {
  ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Movie>>(
        future: apiService.getTopRatedMovies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return CarouselSlider.builder(
                options: CarouselOptions(
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  enableInfiniteScroll: true,
                  pauseAutoPlayOnTouch: true,
                  enlargeCenterPage: true,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index, tdr) {
                  Movie movie = snapshot.data![index];
                  return Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      ClipRRect(
                        child: CachedNetworkImage(
                          imageUrl:
                              'https://image.tmdb.org/t/p/original${movie.backdropPath}',
                          height: MediaQuery.of(context).size.height / 3,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15, left: 15),
                        child: Text(
                          movie.title!,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      )
                    ],
                  );
                });
          }
        });
  }
}
