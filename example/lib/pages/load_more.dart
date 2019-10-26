import 'package:flutter/material.dart' hide NestedScrollView;
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'dart:async';

@FFRoute(
    name: "fluttercandies://loadmore",
    routeName: "load more demo",
    description:
        "show how to support load more list in NestedScrollView's body without ScrollController")
class LoadMoreDemo extends StatefulWidget {
  @override
  _LoadMoreDemoState createState() => _LoadMoreDemoState();
}

class _LoadMoreDemoState extends State<LoadMoreDemo>
    with TickerProviderStateMixin {
  TabController primaryTC;
  GlobalKey<NestedScrollViewState> _key = GlobalKey<NestedScrollViewState>();
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
      key: _key,
      headerSliverBuilder: (c, f) {
        return [
          SliverAppBar(
              pinned: true,
              expandedHeight: 200.0,
              title: Text("load more list"),
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
                TabViewItem(Key("Tab0")),
                TabViewItem(Key("Tab1")),
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
    return Future.delayed(Duration(seconds: 1), () {
      for (var i = 0; i < 10; i++) {
        this.add(0);
      }

      return true;
    });
  }
}

class TabViewItem extends StatefulWidget {
  final Key tabKey;
  TabViewItem(this.tabKey);
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
    var child = LoadingMoreList<int>(ListConfig<int>(
        itemBuilder: (c, item, index) {
          return Container(
            alignment: Alignment.center,
            height: 60.0,
            child: Text(widget.tabKey.toString() + ": ListView$index"),
          );
        },
        sourceList: source));

    return NestedScrollViewInnerScrollPositionKeyWidget(widget.tabKey, child);
  }

  @override
  bool get wantKeepAlive => true;
}
