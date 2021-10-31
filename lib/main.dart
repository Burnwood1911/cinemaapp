// ignore_for_file: prefer_const_constructors, unrelated_type_equality_checks

import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'package:cinemaapp/views/orderview.dart';
import 'package:http/http.dart' as http;
import 'package:cinemaapp/views/search_view.dart';
import 'package:cinemaapp/widgets/genrecategory.dart';
import 'package:cinemaapp/widgets/genreshowcase.dart';
import 'package:cinemaapp/widgets/kappa.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cinemaapp/apiservice.dart';

import 'package:flutter/painting.dart';
import 'package:cinemaapp/utils/painter.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;

import 'models/actor.dart';

void main() {
  stripe.Stripe.publishableKey =
      'pk_test_51JqiiDB8WVxp7KfwjFD3fzSinEGH8AnbkvFjRg5jMkCiuuXrTahohDiiGq54c04ltwJVWj44bryuDnGI51zn9ZX700e34XDcAD';
  runApp(const MyApp());
}

ApiService apiService = ApiService();

StreamController<int> genreController = StreamController<int>.broadcast();

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
              leading: Builder(builder: (context) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => OrderTab()));
                  },
                  child: Icon(
                    Icons.menu,
                    color: Colors.black54,
                  ),
                );
              }),
              centerTitle: true,
              title: const Text(
                "COMING SOON",
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              actions: [
                Builder(builder: (context) {
                  return IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchTab()));
                      },
                      icon: Icon(Icons.search, color: Colors.black45));
                })
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
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                alignment: Alignment.bottomLeft,
                                padding: EdgeInsets.only(left: 15),
                                child: Text("Top Actors".toUpperCase(),
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black45,
                                        fontWeight: FontWeight.bold)),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              ActorsWidget()
                            ],
                          ),
                        ],
                      )));
            })));
  }
}

class ActorsWidget extends StatefulWidget {
  const ActorsWidget({Key? key}) : super(key: key);

  @override
  _ActorsWidgetState createState() => _ActorsWidgetState();
}

class _ActorsWidgetState extends State<ActorsWidget> {
  Future<List<Results>>? myFuture;

  @override
  void initState() {
    super.initState();

    myFuture = apiService.getTopActors();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Results>>(
        future: myFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
                height: 100,
                child: const Center(child: CupertinoActivityIndicator()));
          } else {
            List<Results> actorList = snapshot.data!;

            return Container(
              padding: EdgeInsets.only(left: 10),
              height: 100,
              child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (context, index) => VerticalDivider(
                        width: 3,
                        color: Colors.transparent,
                      ),
                  itemCount: actorList.length,
                  itemBuilder: (context, index) {
                    Results actor = actorList[index];
                    return Column(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100)),
                          elevation: 3,
                          child: ClipRRect(
                            child: CachedNetworkImage(
                              imageUrl:
                                  'https://image.tmdb.org/t/p/w200${actor.profilePath}',
                              imageBuilder: (context, provider) {
                                return Container(
                                  height: 75,
                                  width: 75,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      image: DecorationImage(
                                          image: provider, fit: BoxFit.cover)),
                                );
                              },
                              placeholder: (context, url) => SizedBox(
                                  height: 75,
                                  width: 75,
                                  child: Center(
                                      child: CupertinoActivityIndicator())),
                            ),
                          ),
                        ),
                        Center(
                            child: Text(
                          actor.name!.toUpperCase(),
                          style: TextStyle(fontSize: 8, color: Colors.black45),
                        ))
                      ],
                    );
                  }),
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
                SizedBox(
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
                    SizedBox(
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
                SizedBox(
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
                  onTap: () async {
                    var ultra = await http.post(
                        Uri.parse(
                          'https://api.stripe.com/v1/payment_intents',
                        ),
                        headers: {
                          'Authorization':
                              'Bearer sk_test_51JqiiDB8WVxp7KfwHhllcfBamgahUjZizuPqnUFvxozbAkpIPMLg08CVbdBMsKLKqj7APPUX72Xhndu3pxmv4w2b00Rr1iCPaS',
                          'Content-Type': 'application/x-www-form-urlencoded'
                        },
                        body: {
                          'amount': '10000',
                          'currency': 'usd'
                        });

                    var finalsecret = jsonDecode(ultra.body)['client_secret'];

                    await stripe.Stripe.instance.initPaymentSheet(
                      paymentSheetParameters:
                          stripe.SetupPaymentSheetParameters(
                              paymentIntentClientSecret: finalsecret,
                              applePay: true,
                              googlePay: true,
                              merchantCountryCode: 'US',
                              merchantDisplayName: "alex"),
                    );

                    setState(() {});

                    displayPaymentSheet();
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

  Future<void> displayPaymentSheet() async {
    try {
      await stripe.Stripe.instance.presentPaymentSheet();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

class BookDetainScreen extends StatefulWidget {
  const BookDetainScreen({Key? key}) : super(key: key);

  @override
  _BookDetainScreenState createState() => _BookDetainScreenState();
}

class _BookDetainScreenState extends State<BookDetainScreen> {
  int? selectedTimeIndex;
  int? selectedQualityIndex;
  int? selectedCinemaIndex;

  List<String> times = ['19:30', '20:30', '21:30', '22:00'];
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 30),
      height: 400,
      width: 100,
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Text("Watch Time".toUpperCase(),
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black45)),
          Container(
            height: 80,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                childAspectRatio: 300 / 180,
                crossAxisSpacing: 10,
                mainAxisSpacing: 5,
                shrinkWrap: true,
                children: List.generate(
                    4,
                    (index) => GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTimeIndex = index;
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: index == selectedTimeIndex
                                    ? Colors.black45
                                    : Colors.white,
                                border: Border.all(color: Colors.black45),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Text(
                              times[index],
                              style: TextStyle(
                                  color: index == selectedTimeIndex
                                      ? Colors.white
                                      : Colors.black45),
                            ),
                          ),
                        ))),
          ),
          Text("Quality".toUpperCase(),
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black45)),
          Container(
            height: 80,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 100 / 30,
                crossAxisSpacing: 10,
                mainAxisSpacing: 5,
                shrinkWrap: true,
                children: List.generate(
                    2,
                    (index) => GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedQualityIndex = index;
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black45),
                                color: index == selectedQualityIndex
                                    ? Colors.black45
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Text(
                              index == 0 ? '2D' : '3D',
                              style: TextStyle(
                                color: index == selectedQualityIndex
                                    ? Colors.white
                                    : Colors.black45,
                              ),
                            ),
                          ),
                        ))),
          ),
          Text("Cinema".toUpperCase(),
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black45)),
          Container(
            height: 80,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                childAspectRatio: 100 / 40,
                crossAxisSpacing: 10,
                mainAxisSpacing: 5,
                shrinkWrap: true,
                children: List.generate(
                    3,
                    (index) => GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCinemaIndex = index;
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black45),
                                color: index == selectedCinemaIndex
                                    ? Colors.black45
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Text(
                              index == 0
                                  ? 'MCITY'
                                  : index == 1
                                      ? 'DFM'
                                      : 'AURA',
                              style: TextStyle(
                                  color: index == selectedCinemaIndex
                                      ? Colors.white
                                      : Colors.black45),
                            ),
                          ),
                        ))),
          ),
          Expanded(child: Container()),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SeatSelectorView()));
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black45),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)),
              height: 40,
              width: 100,
              child: Text(
                "BOOK",
                style: TextStyle(color: Colors.black45),
              ),
            ),
          )
        ],
      ),
    );
  }
}
