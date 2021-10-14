import 'package:cached_network_image/cached_network_image.dart';
import 'package:cinemaapp/main.dart';
import 'package:cinemaapp/models/movie_detail.dart';
import 'package:cinemaapp/models/movie_images.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieDetalView extends StatefulWidget {
  final int movieId;
  const MovieDetalView({
    Key? key,
    required this.movieId,
  }) : super(key: key);

  //const MovieDetalView({Key? key}) : super(key: key);

  @override
  _MovieDetalViewState createState() => _MovieDetalViewState();
}

class _MovieDetalViewState extends State<MovieDetalView> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MovieDetail>(
        future: apiService.movieDetail(widget.movieId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
                color: Colors.white,
                child: const Center(child: CupertinoActivityIndicator()));
          } else {
            MovieDetail movieDetail = snapshot.data!;
            return Scaffold(
              body: Stack(
                children: [
                  ClipPath(
                    child: ClipRRect(
                      child: CachedNetworkImage(
                        imageUrl:
                            'https://image.tmdb.org/t/p/original${movieDetail.backdropPath}',
                        height: MediaQuery.of(context).size.height / 2.7,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const CupertinoActivityIndicator(),
                      ),
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30)),
                    ),
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppBar(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 8),
                          child: GestureDetector(
                            onTap: () async {
                              final youtueUrl =
                                  'https://www.youtube.com/embed/${movieDetail.trailerId}';

                              if (await canLaunch(youtueUrl)) {
                                await launch(youtueUrl);
                              }
                            },
                            child: Center(
                              child: Column(
                                children: const [
                                  Icon(
                                    Icons.play_circle_outline,
                                    color: Colors.yellow,
                                    size: 65,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 100,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text("OVERVIEW",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.black45))
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              SizedBox(
                                  height: 35,
                                  child: Text(
                                    movieDetail.overview!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "RELEASE DATE",
                                        style: TextStyle(
                                            color: Colors.black45,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        movieDetail.releaseDate!,
                                        style: const TextStyle(
                                            color: Color.fromRGBO(
                                                232, 22, 103, 75)),
                                      )
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "RUNTIME",
                                        style: TextStyle(color: Colors.black45),
                                      ),
                                      Text(
                                        '${movieDetail.runtime!.toString()} MINS',
                                        style: const TextStyle(
                                            color: Color.fromRGBO(
                                                232, 22, 103, 75),
                                            fontWeight: FontWeight.w500),
                                      )
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "BUDGET",
                                        style: TextStyle(
                                            color: Colors.black45,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        '\$${movieDetail.budget!.toString()}',
                                        style: const TextStyle(
                                            color: Color.fromRGBO(
                                                232, 22, 103, 75)),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text.rich(
                                  TextSpan(children: [
                                    const TextSpan(
                                        text: 'CAST: ',
                                        style: TextStyle(
                                            color: Colors.black45,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    TextSpan(
                                        text: movieDetail.castList!.join(', '))
                                  ]),
                                  overflow: TextOverflow.visible,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "SREENSHOTS",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black45),
                              ),
                              FutureBuilder<List<Backdrops>>(
                                  future:
                                      apiService.movieImages(widget.movieId),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CupertinoActivityIndicator());
                                    } else {
                                      List<Backdrops> backs = snapshot.data!;
                                      return SizedBox(
                                          height: 155,
                                          child: ListView.separated(
                                              scrollDirection: Axis.horizontal,
                                              separatorBuilder: (context,
                                                      index) =>
                                                  const VerticalDivider(
                                                      color: Colors.transparent,
                                                      width: 5),
                                              itemCount: backs.length,
                                              itemBuilder: (context, index) =>
                                                  GestureDetector(
                                                    onLongPress: () async {
                                                      final screenUrl =
                                                          'https://image.tmdb.org/t/p/original${backs[index].filePath}';

                                                      if (await canLaunch(
                                                          screenUrl)) {
                                                        await launch(screenUrl);
                                                      }
                                                    },
                                                    child: Card(
                                                        elevation: 3,
                                                        borderOnForeground:
                                                            true,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12)),
                                                        child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl:
                                                                  'https://image.tmdb.org/t/p/w500${backs[index].filePath}',
                                                              placeholder: (context,
                                                                      url) =>
                                                                  const Center(
                                                                      child:
                                                                          CupertinoActivityIndicator()),
                                                              fit: BoxFit.cover,
                                                            ))),
                                                  )));
                                    }
                                  }),
                            ],
                          ),
                        ),
                        Expanded(child: Container()),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                        child: Material(
                                      elevation: 0,
                                      borderRadius: BorderRadius.circular(10),
                                      child: const BookDetainScreen(),
                                    )));
                          },
                          child: Container(
                              alignment: Alignment.center,
                              height: 60,
                              color: const Color.fromRGBO(232, 22, 103, 60),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text("Book Your Seat",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Icon(
                                    Icons.chair,
                                    color: Colors.white,
                                  )
                                ],
                              )),
                        ),
                      ])
                ],
              ),
            );
          }
        });
  }
}
