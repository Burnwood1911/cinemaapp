import 'package:flutter/material.dart';
import 'package:cinemaapp/main.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
                onPressed: () async {
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

                  await Stripe.instance.initPaymentSheet(
                    paymentSheetParameters: SetupPaymentSheetParameters(
                        paymentIntentClientSecret: finalsecret,
                        applePay: true,
                        googlePay: true,
                        merchantCountryCode: 'US',
                        merchantDisplayName: "alex"),
                  );

                  setState(() {});

                  displayPaymentSheet();
                },
                child: const Text("Pay Now"))));
  }

  Future<void> displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
