import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cinemaapp/main.dart';
import 'package:cinemaapp/models/movie.dart';
import 'package:cinemaapp/widgets/moviedetail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class KappaWidget extends StatefulWidget {
  const KappaWidget({Key? key}) : super(key: key);

  @override
  _KappaWidgetState createState() => _KappaWidgetState();
}

class _KappaWidgetState extends State<KappaWidget> {
  late Future<List<Movie>> myFuture;

  @override
  void initState() {
    super.initState();

    myFuture = apiService.getTopRatedMovies();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Movie>>(
        future: myFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
                height: 200,
                child: Center(child: CupertinoActivityIndicator()));
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
                      GestureDetector(
                        onLongPress: () async {
                          final posterUrl =
                              'https://image.tmdb.org/t/p/original${movie.posterPath}';

                          if (await canLaunch(posterUrl)) {
                            await launch(posterUrl);
                          }
                        },
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MovieDetalView(
                                        movieId: movie.id!,
                                      )));
                        },
                        child: ClipRRect(
                          child: CachedNetworkImage(
                            imageUrl:
                                'https://image.tmdb.org/t/p/original${movie.backdropPath}',
                            height: 200,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                                child: CupertinoActivityIndicator()),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
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
