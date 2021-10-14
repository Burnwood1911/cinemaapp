import 'package:cinemaapp/main.dart';
import 'package:cinemaapp/models/genre.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GenreWidget extends StatefulWidget {
  const GenreWidget({Key? key}) : super(key: key);

  @override
  _GenreWidgetState createState() => _GenreWidgetState();
}

class _GenreWidgetState extends State<GenreWidget> {
  late Future<List<Genre>> myFuture;

  @override
  void initState() {
    super.initState();

    myFuture = apiService.getGenreList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Genre>>(
        future: myFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
                height: 35, child: Center(child: CupertinoActivityIndicator()));
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
                        separatorBuilder: (context, index) =>
                            const VerticalDivider(
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
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black45),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(25)),
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
