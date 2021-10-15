import 'package:cinemaapp/main.dart';
import 'package:cinemaapp/models/search.dart';
import 'package:cinemaapp/widgets/moviedetail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({Key? key}) : super(key: key);

  @override
  _SearchTabState createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  Future<List<SearchResults>>? myFuture;
  String? query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leadingWidth: 40,
          title: SizedBox(
              height: 40,
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      query = value;
                    });
                  }
                },
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                    hintText: 'Enter Movie..',
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.all(0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              )),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: query!.isEmpty
            ? const Center(
                child: Text(
                  "No Results Found",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                ),
              )
            : Container(
                margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
                child: FutureBuilder<List<SearchResults>>(
                    future: apiService.getSearchResults(query!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CupertinoActivityIndicator());
                      } else {
                        if (snapshot.data!.isNotEmpty) {
                          List<SearchResults> mySearches = snapshot.data!;

                          return ListView.separated(
                            separatorBuilder: (context, index) =>
                                const Divider(color: Colors.black45),
                            itemCount: mySearches.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onLongPress: () async {
                                  final posterUrl =
                                      'https://image.tmdb.org/t/p/original${mySearches[index].posterPath}';

                                  if (await canLaunch(posterUrl)) {
                                    await launch(posterUrl);
                                  }
                                },
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MovieDetalView(
                                                movieId: mySearches[index].id!,
                                              )));
                                },
                                child: SizedBox(
                                  height: 20,
                                  width: 200,
                                  child: Text(mySearches[index].title!),
                                ),
                              );
                            },
                          );
                        } else {
                          return const Center(child: Text("No Results Found"));
                        }
                      }
                    }),
              ));
  }
}
