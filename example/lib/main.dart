
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
          if (kIsWeb) return w;
          var data = MediaQuery.of(c);
          return MediaQuery(
            data: data.copyWith(textScaleFactor: 1.0),
            child: w,
          );
        },
        initialRoute: "fluttercandies://mainpage",
        onGenerateRoute: (RouteSettings settings) {
          var routeName = settings.name;
          //when refresh web, route will as following
          //   /
          //   /fluttercandies:
          //   /fluttercandies:/
          //   /fluttercandies://mainpage

          if (kIsWeb && routeName.startsWith('/')) {
            routeName = routeName.replaceFirst('/', '');
          }

          var routeResult =
              getRouteResult(name: routeName, arguments: settings.arguments);

          var page = routeResult.widget ??
              getRouteResult(
                      name: 'fluttercandies://mainpage',
                      arguments: settings.arguments)
                  .widget;

          final platform = Theme.of(context).platform;

          return platform == TargetPlatform.iOS
              ? CupertinoPageRoute(settings: settings, builder: (c) => page)
              : MaterialPageRoute(settings: settings, builder: (c) => page);
        });
  }
}
