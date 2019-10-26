import 'package:example/common/push_to_refresh_header.dart';
import 'package:flutter/material.dart' hide NestedScrollView;
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'dart:async';

@FFRoute(
    name: "fluttercandies://pulltorefresh",
    routeName: "pull to refresh",
    description: "how to pull to refresh for list in NestedScrollView's body without ScrollController")
class PullToRefreshDemo extends StatefulWidget {
  @override
  _PullToRefreshDemoState createState() => _PullToRefreshDemoState();
}

class _PullToRefreshDemoState extends State<PullToRefreshDemo>
    with TickerProviderStateMixin {
  TabController primaryTC;
  int _length1 = 50;
  int _length2 = 50;
  DateTime lastRefreshTime = DateTime.now();
  @override
  void initState() {
    primaryTC = new TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    primaryTC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildScaffoldBody(),
    );
  }

  Widget _buildScaffoldBody() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    var pinnedHeaderHeight =
        //statusBar height
        statusBarHeight +
            //pinned SliverAppBar height in header
            kToolbarHeight;
    return NestedScrollView(
      headerSliverBuilder: (c, f) {
        return [
          SliverAppBar(
              pinned: true,
              expandedHeight: 200.0,
              title: Text("pull to refresh in body"),
              flexibleSpace: FlexibleSpaceBar(
                  //centerTitle: true,
                  collapseMode: CollapseMode.pin,
                  background: Image.asset(
                    "assets/467141054.jpg",
                    fit: BoxFit.fill,
                  )))
        ];
      },
      //1.[pinned sliver header issue](https://github.com/flutter/flutter/issues/22393)
      pinnedHeaderSliverHeightBuilder: () {
        return pinnedHeaderHeight;
      },
      //2.[inner scrollables in tabview sync issue](https://github.com/flutter/flutter/issues/21868)
      innerScrollPositionKeyBuilder: () {
        var index = "Tab";

        index += primaryTC.index.toString();

        return Key(index);
      },
      body: Column(
        children: <Widget>[
          TabBar(
            controller: primaryTC,
            labelColor: Colors.blue,
            indicatorColor: Colors.blue,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 2.0,
            isScrollable: false,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Tab0"),
              Tab(text: "Tab1"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: primaryTC,
              children: <Widget>[
                NestedScrollViewInnerScrollPositionKeyWidget(
                  Key("Tab0"),
                  PullToRefreshNotification(
                    color: Colors.blue,
                    onRefresh: () {
                      return Future.delayed(
                          Duration(
                            seconds: 1,
                          ), () {
                        setState(() {
                          _length1 += 10;
                          lastRefreshTime = DateTime.now();
                        });
                        return true;
                      });
                    },
                    maxDragOffset: maxDragOffset,
                    child: GlowNotificationWidget(
                      Column(
                        children: <Widget>[
                          PullToRefreshContainer((info) {
                            return PullToRefreshHeader(info, lastRefreshTime);
                          }),
                          Expanded(
                            child: ListView.builder(
                              //store Page state
                              key: PageStorageKey("Tab0"),
                              physics: ClampingScrollPhysics(),
                              itemBuilder: (c, i) {
                                return Container(
                                  alignment: Alignment.center,
                                  height: 60.0,
                                  child: Text(Key("Tab0").toString() +
                                      ": ListView$i of $_length1"),
                                );
                              },
                              itemCount: _length1,
                              padding: EdgeInsets.all(0.0),
                            ),
                          )
                        ],
                      ),
                      showGlowLeading: false,
                    ),
                  ),
                ),
                NestedScrollViewInnerScrollPositionKeyWidget(
                  Key("Tab1"),
                  PullToRefreshNotification(
                    color: Colors.blue,
                    onRefresh: () {
                      return Future.delayed(
                          Duration(
                            seconds: 1,
                          ), () {
                        setState(() {
                          _length1 += 10;
                          lastRefreshTime = DateTime.now();
                        });
                        return true;
                      });
                    },
                    maxDragOffset: maxDragOffset,
                    child: GlowNotificationWidget(
                      Column(
                        children: <Widget>[
                          PullToRefreshContainer((info) {
                            return PullToRefreshHeader(info, lastRefreshTime);
                          }),
                          Expanded(
                            child: ListView.builder(
                              //store Page state
                              key: PageStorageKey("Tab1"),
                              physics: ClampingScrollPhysics(),
                              itemBuilder: (c, i) {
                                return Container(
                                  alignment: Alignment.center,
                                  height: 60.0,
                                  child: Text(Key("Tab1").toString() +
                                      ": ListView$i of $_length2"),
                                );
                              },
                              itemCount: _length2,
                              padding: EdgeInsets.all(0.0),
                            ),
                          )
                        ],
                      ),
                      showGlowLeading: false,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}


