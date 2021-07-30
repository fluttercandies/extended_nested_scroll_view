import 'dart:async';
import 'package:example/common/push_to_refresh_header.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:loading_more_list/loading_more_list.dart';

import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';

@FFRoute(
  name: 'fluttercandies://pulltorefresh',
  routeName: 'pull to refresh',
  description:
      'how to pull to refresh for list in NestedScrollView\'s body without ScrollController',
  exts: <String, dynamic>{
    'group': 'Complex',
    'order': 0,
  },
)
class PullToRefreshDemo extends StatefulWidget {
  @override
  _PullToRefreshDemoState createState() => _PullToRefreshDemoState();
}

class _PullToRefreshDemoState extends State<PullToRefreshDemo>
    with TickerProviderStateMixin {
  TabController primaryTC;
  int _length1 = 50;
  final int _length2 = 50;
  DateTime lastRefreshTime = DateTime.now();
  @override
  void initState() {
    primaryTC = TabController(length: 2, vsync: this);
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
    final double pinnedHeaderHeight =
        //statusBar height
        statusBarHeight +
            //pinned SliverAppBar height in header
            kToolbarHeight;
    return ExtendedNestedScrollView(
      headerSliverBuilder: (BuildContext c, bool f) {
        return <Widget>[
          SliverAppBar(
              pinned: true,
              expandedHeight: 200.0,
              title: const Text('pull to refresh in body'),
              flexibleSpace: FlexibleSpaceBar(
                  //centerTitle: true,
                  collapseMode: CollapseMode.pin,
                  background: Image.asset(
                    'assets/467141054.jpg',
                    fit: BoxFit.fill,
                  )))
        ];
      },
      //1.[pinned sliver header issue](https://github.com/flutter/flutter/issues/22393)
      pinnedHeaderSliverHeightBuilder: () {
        return pinnedHeaderHeight;
      },
      //2.[inner scrollables in tabview sync issue](https://github.com/flutter/flutter/issues/21868)
      onlyOneScrollInBody: true,
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
            tabs: const <Tab>[
              Tab(text: 'Tab0'),
              Tab(text: 'Tab1'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: primaryTC,
              children: <Widget>[
                PullToRefreshNotification(
                  color: Colors.blue,
                  onRefresh: () {
                    return Future<bool>.delayed(
                        const Duration(
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
                        PullToRefreshContainer(
                            (PullToRefreshScrollNotificationInfo info) {
                          return PullToRefreshHeader(info, lastRefreshTime);
                        }),
                        Expanded(
                          child: ListView.builder(
                            //store Page state
                            key: const PageStorageKey<String>('Tab0'),
                            physics: const ClampingScrollPhysics(),
                            itemBuilder: (BuildContext c, int i) {
                              return Container(
                                alignment: Alignment.center,
                                height: 60.0,
                                child: Text(const Key('Tab0').toString() +
                                    ': ListView$i of $_length1'),
                              );
                            },
                            itemCount: _length1,
                            padding: const EdgeInsets.all(0.0),
                          ),
                        )
                      ],
                    ),
                    showGlowLeading: false,
                  ),
                ),
                PullToRefreshNotification(
                  color: Colors.blue,
                  onRefresh: () {
                    return Future<bool>.delayed(
                        const Duration(
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
                        PullToRefreshContainer(
                            (PullToRefreshScrollNotificationInfo info) {
                          return PullToRefreshHeader(info, lastRefreshTime);
                        }),
                        Expanded(
                          child: ListView.builder(
                            //store Page state
                            key: const PageStorageKey<String>('Tab1'),
                            physics: const ClampingScrollPhysics(),
                            itemBuilder: (BuildContext c, int i) {
                              return Container(
                                alignment: Alignment.center,
                                height: 60.0,
                                child: Text(const Key('Tab1').toString() +
                                    ': ListView$i of $_length2'),
                              );
                            },
                            itemCount: _length2,
                            padding: const EdgeInsets.all(0.0),
                          ),
                        )
                      ],
                    ),
                    showGlowLeading: false,
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
