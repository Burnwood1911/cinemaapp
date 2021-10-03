// ignore_for_file: prefer_const_constructors, unrelated_type_equality_checks

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cinemaapp/models/movie_images.dart';
import 'package:cinemaapp/views/paymet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cinemaapp/apiservice.dart';
import 'package:cinemaapp/models/movie.dart';
import 'package:cinemaapp/models/movie_detail.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models/genre.dart';

void main() {
  runApp(const MyApp());
}

ApiService apiService = ApiService();
ValueNotifier valueNotifier = ValueNotifier(0);
int? selectedGenre = 28;

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
        theme: ThemeData(brightness: Brightness.light),
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
                "COMING SOON",
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
                            children: [
                              KappaWidget(),
                              SizedBox(
                                height: 10,
                              ),
                              GenreWidget(),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                  padding: EdgeInsets.only(left: 15),
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    "Now Showing".toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black45),
                                  )),
                              SizedBox(
                                height: 5,
                              ),
                              GenreShowcase(),
                              Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: Colors.black45, width: 1),
                                      borderRadius: BorderRadius.circular(10)),
                                  height: 40,
                                  width: 120,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text("Buy Ticket",
                                          style:
                                              TextStyle(color: Colors.black45)),
                                      Padding(
                                        padding: EdgeInsets.only(left: 8.0),
                                        child: Icon(Icons.movie_creation,
                                            color: Colors.black45),
                                      )
                                    ],
                                  )),
                            ],
                          ),
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
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Movie>>(
        future: apiService.getTopRatedMovies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
                height: 200,
                child: const Center(child: CupertinoActivityIndicator()));
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

class GenreWidget extends StatefulWidget {
  const GenreWidget({Key? key}) : super(key: key);

  @override
  _GenreWidgetState createState() => _GenreWidgetState();
}

class _GenreWidgetState extends State<GenreWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Genre>>(
        future: apiService.getGenreList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
                height: 35,
                child: const Center(child: CupertinoActivityIndicator()));
          } else {
            List<Genre> genres = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 35,
                      child: ListView.separated(
                        separatorBuilder: (context, index) => VerticalDivider(
                          color: Colors.transparent,
                          width: 5,
                        ),
                        itemCount: snapshot.data!.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          Genre genre = genres[index];
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedGenre = genre.id;
                                    valueNotifier.value++;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black45),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25)),
                                    color: (genre.id == selectedGenre)
                                        ? Colors.black45
                                        : Colors.white,
                                  ),
                                  child: Text(
                                    genre.name!.toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: (genre.id == selectedGenre)
                                            ? Colors.white
                                            : Colors.black45),
                                  ),
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    )
                  ]),
            );
          }
        });
  }
}

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
              return Container(
                  height: 200,
                  child: const Center(child: CupertinoActivityIndicator()));
            } else {
              List<Movie> movielist = snapshot.data!;

              return Container(
                  padding: EdgeInsets.only(left: 10),
                  height: 200,
                  child: ListView.separated(
                    separatorBuilder: (context, index) => VerticalDivider(
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
                                    height: 150,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12)),
                                        image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover)),
                                  );
                                },
                                placeholder: (context, url) => SizedBox(
                                  width: 100,
                                  height: 150,
                                  child: Center(
                                    child: CupertinoActivityIndicator(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          SizedBox(
                            width: 100,
                            child: Text(
                              movie.title!.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black45,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.yellow,
                                size: 12,
                              ),
                              Icon(
                                Icons.star,
                                color: Colors.yellow,
                                size: 12,
                              ),
                              Icon(
                                Icons.star,
                                color: Colors.yellow,
                                size: 12,
                              ),
                              Icon(
                                Icons.star,
                                color: Colors.yellow,
                                size: 12,
                              ),
                              Icon(
                                Icons.star,
                                color: Colors.yellow,
                                size: 12,
                              ),
                              Text(
                                '${movie.voteAverage}',
                                style: TextStyle(
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
                            CupertinoActivityIndicator(),
                      ),
                      borderRadius: BorderRadius.only(
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
                          padding: EdgeInsets.only(top: 8),
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
                        SizedBox(
                          height: 100,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
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
                              SizedBox(
                                height: 5,
                              ),
                              SizedBox(
                                  height: 35,
                                  child: Text(
                                    movieDetail.overview!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                              SizedBox(
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
                                      Text(
                                        "RELEASE DATE",
                                        style: TextStyle(
                                            color: Colors.black45,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        movieDetail.releaseDate!,
                                        style: TextStyle(
                                            color: Color.fromRGBO(
                                                232, 22, 103, 75)),
                                      )
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "RUNTIME",
                                        style: TextStyle(color: Colors.black45),
                                      ),
                                      Text(
                                        '${movieDetail.runtime!.toString()} MINS',
                                        style: TextStyle(
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
                                      Text(
                                        "BUDGET",
                                        style: TextStyle(
                                            color: Colors.black45,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        '\$${movieDetail.budget!.toString()}',
                                        style: TextStyle(
                                            color: Color.fromRGBO(
                                                232, 22, 103, 75)),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: const [
                                  Text("Cast:",
                                      style: TextStyle(
                                          color: Colors.black45,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text(" to implement feature soon")
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              // Row(
                              //   children: [
                              //     Text(
                              //       'Rated-R: ${movieDetail.adult! ? 'YES' : 'NO'}',
                              //       style:
                              //           TextStyle(color: Colors.purpleAccent),
                              //       overflow: TextOverflow.ellipsis,
                              //     )
                              //   ],
                              // ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
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
                                                  VerticalDivider(
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
                                                                  Center(
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SeatSelectorView()));
                          },
                          child: Container(
                              alignment: Alignment.center,
                              height: 60,
                              color: Color.fromRGBO(232, 22, 103, 60),
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

class SeatSelectorView extends StatefulWidget {
  const SeatSelectorView({Key? key}) : super(key: key);

  @override
  _SeatSelectorViewState createState() => _SeatSelectorViewState();
}

class _SeatSelectorViewState extends State<SeatSelectorView> {
  // final List<Map> myProducts =
  //     List.generate(18, (index) => {"id": index, "name": "${index + 1}"})
  //         .toList();

  bool isReserved = false;
  List<int> reserved = [15, 22];

  bool isSelected = false;

  int selectedIndex = 0;

  int moviePrice = 12000;

  List<int> selectedIndexes = [];

  int seatsNum = 0;
  int price = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose Seats".toUpperCase(),
            style: TextStyle(color: Color.fromRGBO(55, 32, 131, 20))),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Color.fromRGBO(55, 32, 131, 20)),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 30),
            height: 50,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: const [
                  Icon(
                    Icons.check_box_outline_blank,
                  ),
                  Text("Availabe"),
                ]),
                Row(children: [
                  Container(
                      width: 15,
                      height: 15,
                      color: Color.fromRGBO(55, 32, 131, 20)),
                  SizedBox(
                    width: 5,
                  ),
                  Text("Selected"),
                ]),
                Row(children: [
                  Container(width: 15, height: 15, color: Colors.red[300]),
                  SizedBox(
                    width: 6,
                  ),
                  Text("Sold Out"),
                ])
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(bottom: 30, top: 5),
            height: 300,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 2,
                ),
                Container(
                  height: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("P"),
                      Text("N"),
                      Text("M"),
                      Text("L"),
                      Text("K"),
                      Text("J"),
                      Text("H"),
                      Text("G"),
                      Text("F"),
                      Text("E"),
                      Text("D"),
                      Text("C"),
                      Text("B"),
                      Text("A"),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      height: 300,
                      width: 310,
                      child: GridView.count(
                          crossAxisSpacing: 0,
                          shrinkWrap: true,
                          crossAxisCount: 18,
                          mainAxisSpacing: 4.55,
                          children: List.generate(
                              252,
                              (index) => Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (reserved.contains(index)) {
                                          showDialog(
                                              context: context,
                                              builder: (contex) => AlertDialog(
                                                    actionsAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    actions: [
                                                      TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context),
                                                          child: Text("Close"))
                                                    ],
                                                    content: Text(
                                                        "Seat Taken Please Select Another Seat",
                                                        textAlign:
                                                            TextAlign.center),
                                                    contentTextStyle: TextStyle(
                                                        color: Colors.black),
                                                  ));
                                        } else if (selectedIndexes
                                            .contains(index)) {
                                          setState(() {
                                            selectedIndexes.remove(index);
                                          });
                                        } else {
                                          setState(() {
                                            selectedIndexes.add(index);
                                          });
                                        }
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: reserved.contains(index)
                                                  ? Colors.red[200]
                                                  : selectedIndexes
                                                          .contains(index)
                                                      ? Color.fromRGBO(
                                                          103, 33, 255, 100)
                                                      : Colors.white,
                                              border: Border.all(
                                                  color: Colors.black45,
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(3)),
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 1),
                                          alignment: Alignment.center,
                                          width: 14,
                                          height: 14,
                                          child: Text(
                                            index < 18
                                                ? '${index + 1}'
                                                : index < 36
                                                    ? '${index + 1 - 18}'
                                                    : index < 54
                                                        ? '${index + 1 - 36}'
                                                        : index < 72
                                                            ? '${index + 1 - 54}'
                                                            : index < 90
                                                                ? '${index + 1 - 72}'
                                                                : index < 108
                                                                    ? '${index + 1 - 90}'
                                                                    : index <
                                                                            126
                                                                        ? '${index + 1 - 108}'
                                                                        : index <
                                                                                144
                                                                            ? '${index + 1 - 126}'
                                                                            : index < 162
                                                                                ? '${index + 1 - 144}'
                                                                                : index < 180
                                                                                    ? '${index + 1 - 162}'
                                                                                    : index < 198
                                                                                        ? '${index + 1 - 180}'
                                                                                        : index < 216
                                                                                            ? '${index + 1 - 198}'
                                                                                            : index < 234
                                                                                                ? '${index + 1 - 216}'
                                                                                                : '${index + 1 - 234}',
                                            style: TextStyle(fontSize: 8),
                                            textAlign: TextAlign.center,
                                          )),
                                    ),
                                  ))),
                    ),
                  ],
                ),
                Container(
                  height: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("P"),
                      Text("N"),
                      Text("M"),
                      Text("L"),
                      Text("K"),
                      Text("J"),
                      Text("H"),
                      Text("G"),
                      Text("F"),
                      Text("E"),
                      Text("D"),
                      Text("C"),
                      Text("B"),
                      Text("A"),
                    ],
                  ),
                ),
                SizedBox(
                  width: 2,
                ),
              ],
            ),
          ),

          Expanded(child: Container()),

          Container(
            color: Colors.transparent,
            transform: Matrix4.rotationX(180),
            height: 40,
            width: 300,
            child: Stack(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 320 / 41,
                  child: CustomPaint(
                    painter: CurveScreenPainter(),
                  ),
                ),
              ],
            ),
          ),
          // Container(
          //   width: 250,
          //   height: 20,
          //   decoration: BoxDecoration(
          //       color: Color.fromRGBO(103, 33, 255, 80),
          //       border: Border.all(color: Colors.black45, width: 1),
          //       borderRadius: BorderRadius.only(
          //           topLeft: Radius.circular(10),
          //           topRight: Radius.circular(10),
          //           bottomLeft: Radius.circular(50),
          //           bottomRight: Radius.circular(50))),
          // ),
          Container(
              margin: EdgeInsets.only(top: 40),
              height: 70,
              width: MediaQuery.of(context).size.width,
              child: Row(children: [
                Container(
                    padding: EdgeInsets.only(top: 15, left: 15),
                    height: 70,
                    width: MediaQuery.of(context).size.width / 2,
                    color: Color.fromRGBO(55, 32, 131, 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("TSH ${moviePrice * selectedIndexes.length}",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w300)),
                        SizedBox(
                          height: 3,
                        ),
                        Text("${selectedIndexes.length} Selected",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w300))
                      ],
                    )),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PaymentScreen()));
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 70,
                    width: MediaQuery.of(context).size.width / 2,
                    color: Color.fromRGBO(103, 33, 255, 100),
                    child: Text(
                      "CHECKOUT",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w300),
                    ),
                  ),
                ),
              ]))
        ],
      ),
    );
  }
}

class CurveScreenPainter extends CustomPainter {
  var strokeWidth = 8.0;
  var offset = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.purple;
    paint.style = PaintingStyle.stroke;
    paint.isAntiAlias = true;
    paint.strokeCap = StrokeCap.round;
    paint.strokeWidth = strokeWidth;

    var path = Path();
    path.moveTo(offset, size.height - offset);
    path.quadraticBezierTo(size.width / 2, -size.height + offset,
        size.width - offset, size.height - offset);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.green[800]!;
    paint.style = PaintingStyle.fill;

    var path = Path();
    path.lineTo(size.width, size.height);

    path.moveTo(0, size.height * 0.25);
    path.quadraticBezierTo(
        size.width / 2, size.height / 2, size.width, size.height * 0.25);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
