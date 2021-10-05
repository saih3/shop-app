import 'package:flutter/material.dart';

import 'package:shop_app/screens/products_overview_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.green),
        fontFamily: 'Lato',
      ),
      home: ProductsOverviewScreen(),
    );
  }
}
