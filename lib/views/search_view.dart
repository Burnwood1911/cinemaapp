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

  int selectedindex = 0;

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
                    hintText: 'Enter Search..',
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.all(0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10))),
              )),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width / 2,
                    decoration: BoxDecoration(
                        border: selectedindex == 0
                            ? const Border(
                                bottom:
                                    BorderSide(color: Colors.black, width: 3))
                            : null),
                    child: TextButton(
                        onPressed: () {
                          setState(() {
                            selectedindex = 0;
                          });
                        },
                        child: const Text(
                          "MOVIES",
                          style: TextStyle(color: Colors.black45),
                        ))),
                Container(
                    width: MediaQuery.of(context).size.width / 2,
                    decoration: BoxDecoration(
                        border: selectedindex == 1
                            ? const Border(
                                bottom:
                                    BorderSide(color: Colors.black, width: 3))
                            : null),
                    child: TextButton(
                        onPressed: () {
                          setState(() {
                            selectedindex = 1;
                          });
                        },
                        child: const Text("TV-SHOWS",
                            style: TextStyle(color: Colors.black45))))
              ],
            ),
            query!.isEmpty
                ? const Expanded(
                    child: Center(
                      child: Text(
                        "No Results Found",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                    ),
                  )
                : Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(
                        top: 15,
                        left: 10,
                        right: 10,
                      ),
                      child: FutureBuilder<List<SearchResults>>(
                          future: apiService.getSearchResults(
                              query!, selectedindex),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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
                                        selectedindex == 0
                                            ? Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        MovieDetalView(
                                                          movieId:
                                                              mySearches[index]
                                                                  .id!,
                                                        )))
                                            : null;
                                      },
                                      child: SizedBox(
                                        height: 20,
                                        width: 200,
                                        child: Text(selectedindex == 0
                                            ? "${mySearches[index].title!} (${mySearches[index].releaseDate!.split("-")[0]})"
                                            : mySearches[index].name!),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return const Center(
                                    child: Text("No Results Found"));
                              }
                            }
                          }),
                    ),
                  ),
            const SizedBox(height: 20)
          ],
        ));
  }
}
