import 'dart:convert';

import 'package:ahakam_v8/models/account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:ahakam_v8/keys.dart';
import 'package:http/http.dart' as http;

class PayPage extends StatefulWidget {
  const PayPage({super.key, required this.account, required this.rid});
  final Account account;
  final String rid;
  @override
  State<PayPage> createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> {
  double amount = 20;
  Map<String, dynamic>? intentPaymentData;

  Future<List<Map<String, dynamic>>> fetchACCRequests() async {
    var _firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await _firestore
        .collection('requests')
        .where('userId', isEqualTo: widget.account.uid)
        .where('status', isEqualTo: "Accepted")
        .get();

    return querySnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  void completePay() async {
    final _firestore = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot = await _firestore
        .collection('requests')
        .where('rid', isEqualTo: widget.rid)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      await _firestore.collection('requests').doc(doc.id).update({
        'paid': true,
      });
      print("Request ${doc.id} marked as paid.");
    } else {
      print("No request found with rid: ${widget.rid}");
    }
  }

  showPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((val) {
        intentPaymentData = null;
      }).onError((errorMsg, sTrace) {
        if (kDebugMode) {
          print(errorMsg.toString() + sTrace.toString());
        }
      });
    } on StripeException catch (error) {
      if (kDebugMode) {
        print(error);
      }
      showDialog(
          context: context,
          builder: (c) => const AlertDialog(
                content: Text("Cancelled"),
              ));
    } catch (errorMsg) {
      if (kDebugMode) {
        print(errorMsg);
      }
      print(errorMsg.toString());
    }
  }

  makeIntentForPayment(amountToBeCharge, currency) async {
    try {
      Map<String, dynamic>? paymentInfo = {
        "amount": (int.parse(amountToBeCharge) * 100).toString(),
        "currency": currency,
        "payment_method_types[]": "card",
      };

      var responseFromStripeAPI = await http.post(
          Uri.parse("https://api.stripe.com/v1/payment_intents"),
          body: paymentInfo,
          headers: {
            "Authorization": "Bearer $secretKey",
            "Content-Type": "application/x-www-form-urlencoded"
          });
      print("response from API" + responseFromStripeAPI.body);
      return jsonDecode(responseFromStripeAPI.body);
    } catch (errorMsg) {
      if (kDebugMode) {
        print(errorMsg);
      }
      print(errorMsg.toString());
    }
  }

  paymentSheetInitialization(amountToBeCharge, curremcy) async {
    try {
      intentPaymentData =
          await makeIntentForPayment(amountToBeCharge, curremcy);
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  allowsDelayedPaymentMethods: true,
                  paymentIntentClientSecret:
                      intentPaymentData!["client_secret"],
                  style: ThemeMode.dark,
                  merchantDisplayName: "Company Name Example"))
          .then((val) {
        print(val);
      });

      showPaymentSheet();
    } catch (errorMsg, s) {
      if (kDebugMode) {
        print(s);
      }
      print(errorMsg.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                completePay();

                paymentSheetInitialization(amount.round().toString(), "USD");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text(
                "Pay Now USD ${amount.toString()}",
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
