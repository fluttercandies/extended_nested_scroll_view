import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';

import '../example_route.dart';

@FFRoute(
  name: "fluttercandies://mainpage",
  routeName: "MainPage",
)
class MainPage extends StatelessWidget {
  final List<RouteResult> routes = List<RouteResult>();
  MainPage() {
    routeNames.remove("fluttercandies://mainpage");
    routes.addAll(
        routeNames.map<RouteResult>((name) => getRouteResult(name: name)));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("extended nestedscrollview"),
      ),
      body: ListView.builder(
        itemBuilder: (c, index) {
          var page = routes[index];
          return Container(
              margin: EdgeInsets.all(20.0),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      (index + 1).toString() + "." + page.routeName,
                      //style: TextStyle(inherit: false),
                    ),
                    Text(
                      page.description,
                      style: TextStyle(color: Colors.grey),
                    )
                  ],
                ),
                onTap: () {
                  Navigator.pushNamed(context, routeNames[index]);
                },
              ));
        },
        itemCount: routeNames.length,
      ),
    );
  }
}
