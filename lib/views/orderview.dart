import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OrderTab extends StatefulWidget {
  const OrderTab({Key? key}) : super(key: key);

  @override
  _OrderTabState createState() => _OrderTabState();
}

class _OrderTabState extends State<OrderTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Container(
          color: Colors.white,
          child: ListView(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, left: 15),
                child: const Text(
                  "Order history",
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
                ),
              ),
              Container(
                  margin: const EdgeInsets.only(
                    top: 15,
                  ),
                  child: testWidget()),
            ],
          ),
        ));
  }

  Widget testWidget() {
    List<Widget> myWids = [];

    var blue = Container(
      height: 10,
      width: 10,
      color: Colors.blue,
    );

    var red = Container(
      height: 10,
      width: 10,
      color: Colors.red,
    );
    var orange = Container(
      height: 10,
      width: 10,
      color: Colors.orange,
    );

    String seats =
        "UUUAAARRRUUUAAARRRUUUAAARRRUUUAAARRRUUUAAARRRUUUAUUUAAARRRUU";

    for (int i = 0; i < seats.length;) {
      if (seats[i].contains("U")) {
        myWids.add(red);
        i++;
      } else if (seats[i].contains("A")) {
        myWids.add(blue);
        i++;
      } else if (seats[i].contains("R")) {
        myWids.add(orange);
        i++;
      }
    }
    debugPrint(myWids.length.toString());
    return Container();
  }
}
