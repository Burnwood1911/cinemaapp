import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemaapp/main.dart';
import 'package:cinemaapp/models/movie.dart';
import 'package:cinemaapp/widgets/moviedetail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GenreShowcase extends StatefulWidget {
  const GenreShowcase({Key? key}) : super(key: key);

  @override
  _GenreShowcaseState createState() => _GenreShowcaseState();
}

class _GenreShowcaseState extends State<GenreShowcase> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: valueNotifier,
      builder: (context, child, value) => FutureBuilder<List<Movie>>(
          future: apiService.getMoviesByGenre(selectedGenre!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                  height: 165,
                  child: Center(child: CupertinoActivityIndicator()));
            } else {
              List<Movie> movielist = snapshot.data!;

              return Container(
                  padding: const EdgeInsets.only(left: 10),
                  height: 165,
                  child: ListView.separated(
                    separatorBuilder: (context, index) => const VerticalDivider(
                      color: Colors.transparent,
                      width: 8,
                    ),
                    itemCount: movielist.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      Movie movie = movielist[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                imageBuilder: (context, imageProvider) {
                                  return Container(
                                    width: 100,
                                    height: 135,
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(12)),
                                        image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover)),
                                  );
                                },
                                placeholder: (context, url) => const SizedBox(
                                  width: 100,
                                  height: 135,
                                  child: Center(
                                    child: CupertinoActivityIndicator(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          SizedBox(
                            width: 100,
                            child: Text(
                              movie.title!.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black45,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.yellow,
                                size: 12,
                              ),
                              const Icon(
                                Icons.star,
                                color: Colors.yellow,
                                size: 12,
                              ),
                              const Icon(
                                Icons.star,
                                color: Colors.yellow,
                                size: 12,
                              ),
                              const Icon(
                                Icons.star,
                                color: Colors.yellow,
                                size: 12,
                              ),
                              const Icon(
                                Icons.star,
                                color: Colors.yellow,
                                size: 12,
                              ),
                              Text(
                                '${movie.voteAverage}',
                                style: const TextStyle(
                                    color: Colors.black45, fontSize: 10),
                              )
                            ],
                          )
                        ],
                      );
                    },
                  ));
            }
          }),
    );
  }
}
