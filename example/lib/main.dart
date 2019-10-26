import 'dart:io';

import 'package:example/pages/no_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide NestedScrollView;

import 'example_route.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        builder: (c, w) {
          var data = MediaQuery.of(c);
          return MediaQuery(
            data: data.copyWith(textScaleFactor: 1.0),
            child: w,
          );
        },
        initialRoute: "fluttercandies://mainpage",
        onGenerateRoute: (RouteSettings settings) {
          var routeResult = getRouteResult(
              name: settings.name, arguments: settings.arguments);

          var page = routeResult.widget ?? NoRoute();

          return Platform.isIOS
              ? CupertinoPageRoute(settings: settings, builder: (c) => page)
              : MaterialPageRoute(settings: settings, builder: (c) => page);
        });
  }
}
