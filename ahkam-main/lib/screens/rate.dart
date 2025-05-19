import 'package:flutter/material.dart';

class Rate extends StatefulWidget {
  const Rate({super.key});

  @override
  State<Rate> createState() => _RateState();
}

class _RateState extends State<Rate> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [Text('data')],
      ),
    );
  }
}
