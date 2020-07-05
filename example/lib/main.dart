import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide NestedScrollView;

import 'example_route.dart';
import 'example_route_helper.dart';
import 'example_routes.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      builder: (BuildContext c, Widget w) {
        if (kIsWeb) {
          return w;
        }
        final MediaQueryData data = MediaQuery.of(c);
        return MediaQuery(
          data: data.copyWith(textScaleFactor: 1.0),
          child: w,
        );
      },
      initialRoute: Routes.fluttercandiesMainpage,
      onGenerateRoute: (RouteSettings settings) {
        //when refresh web, route will as following
        //   /
        //   /fluttercandies:
        //   /fluttercandies:/
        //   /fluttercandies://mainpage
        if (kIsWeb && settings.name.startsWith('/')) {
          return onGenerateRouteHelper(
            settings.copyWith(name: settings.name.replaceFirst('/', '')),
            notFoundFallback:
                getRouteResult(name: Routes.fluttercandiesMainpage).widget,
          );
        }
        return onGenerateRouteHelper(settings);
      },
    );
  }
}
