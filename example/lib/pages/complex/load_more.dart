import 'dart:async';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:loading_more_list/loading_more_list.dart';

@FFRoute(
  name: 'fluttercandies://loadmore',
  routeName: 'load more demo',
  description:
      'show how to support load more list in NestedScrollView\'s body without ScrollController',
  exts: <String, dynamic>{
    'group': 'Complex',
    'order': 2,
  },
)
class LoadMoreDemo extends StatefulWidget {
  @override
  _LoadMoreDemoState createState() => _LoadMoreDemoState();
}

class _LoadMoreDemoState extends State<LoadMoreDemo>
    with TickerProviderStateMixin {
  TabController primaryTC;
  final GlobalKey<ExtendedNestedScrollViewState> _key =
      GlobalKey<ExtendedNestedScrollViewState>();
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
      key: _key,
      headerSliverBuilder: (BuildContext c, bool f) {
        return <Widget>[
          SliverAppBar(
              pinned: true,
              expandedHeight: 200.0,
              title: const Text('load more list'),
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
              children: const <Widget>[
                TabViewItem(),
                TabViewItem(),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class LoadMoreListSource extends LoadingMoreBase<int> {
  @override
  Future<bool> loadData([bool isloadMoreAction = false]) {
    return Future<bool>.delayed(const Duration(seconds: 1), () {
      for (int i = 0; i < 10; i++) {
        add(0);
      }

      return true;
    });
  }
}

class TabViewItem extends StatefulWidget {
  const TabViewItem();
  @override
  _TabViewItemState createState() => _TabViewItemState();
}

class _TabViewItemState extends State<TabViewItem>
    with AutomaticKeepAliveClientMixin {
  LoadMoreListSource source;
  @override
  void initState() {
    source = LoadMoreListSource();
    super.initState();
  }

  @override
  void dispose() {
    source.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final LoadingMoreList<int> child = LoadingMoreList<int>(ListConfig<int>(
        itemBuilder: (BuildContext c, int item, int index) {
          return Container(
            alignment: Alignment.center,
            height: 60.0,
            child: Text(': ListView$index'),
          );
        },
        sourceList: source));

    return child;
  }

  @override
  bool get wantKeepAlive => true;
}
