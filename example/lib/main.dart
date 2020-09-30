import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'example_route.dart';
import 'example_route_helper.dart';
import 'example_routes.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'extended_nested_scroll_view demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
        return onGenerateRouteHelper(settings,
            builder: (Widget child, RouteResult result) {
          return child;

          // if (settings.name == Routes.fluttercandiesMainpage ||
          //     settings.name == Routes.fluttercandiesDemogrouppage ||
          //     settings.name == Routes.fluttercandiesNestedscrollview ||
          //     settings.name == Routes.fluttercandiesPinnedHeaderHeight ||
          //     settings.name == Routes.fluttercandiesDemogrouppage) {
          //   return child;
          // }
          // return CommonWidget(
          //   child: child,
          //   result: result,
          // );
        });
      },
    );
  }
}

class CommonWidget extends StatelessWidget {
  const CommonWidget({
    this.child,
    this.result,
  });
  final Widget child;
  final RouteResult result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          result.routeName,
        ),
      ),
      body: child,
    );
  }
}
