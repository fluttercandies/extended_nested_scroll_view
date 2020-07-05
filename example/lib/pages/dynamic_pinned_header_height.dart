import 'package:example/common/common.dart';
import 'package:flutter/material.dart' hide NestedScrollView;
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';

@FFRoute(
    name: 'fluttercandies://pinned header height',
    routeName: 'pinned header height',
    description: 'how to change pinned header height dynamically')
class DynamicPinnedHeaderHeightDemo extends StatefulWidget {
  @override
  _DynamicPinnedHeaderHeightDemoState createState() =>
      _DynamicPinnedHeaderHeightDemoState();
}

class _DynamicPinnedHeaderHeightDemoState
    extends State<DynamicPinnedHeaderHeightDemo> with TickerProviderStateMixin {
  TabController primaryTC;
  ScrollController sc = ScrollController();
  @override
  void initState() {
    primaryTC = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    primaryTC.dispose();
    sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildScaffoldBody(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.update),
        onPressed: () {
          //change pinnedHeaderHeight here
          final double before = pinnedHeaderHeight;
          pinnedHeaderHeight += 10.0;
          sc.position.applyContentDimensions(sc.position.minScrollExtent,
              sc.position.maxScrollExtent + before);
        },
      ),
    );
  }

  double pinnedHeaderHeight;
  Widget _buildScaffoldBody() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    pinnedHeaderHeight =
        //statusBar height
        statusBarHeight +
            //pinned SliverAppBar height in header
            kToolbarHeight;
    return NestedScrollViewRefreshIndicator(
      onRefresh: onRefresh,
      child: NestedScrollView(
          controller: sc,
          headerSliverBuilder: (BuildContext c, bool f) {
            return <Widget>[
              SliverAppBar(
                  pinned: true,
                  expandedHeight: 200.0,
                  title: const Text('pinned header height'),
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
          innerScrollPositionKeyBuilder: () {
            String index = 'Tab';

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
                tabs: const <Tab>[
                  Tab(text: 'Tab0'),
                  Tab(text: 'Tab1'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: primaryTC,
                  children: <Widget>[
                    NestedScrollViewInnerScrollPositionKeyWidget(
                      const Key('Tab0'),
                      GlowNotificationWidget(
                        ListView.builder(
                          //store Page state
                          key: const PageStorageKey<String>('Tab0'),
                          physics: const ClampingScrollPhysics(),
                          itemBuilder: (BuildContext c, int i) {
                            return Container(
                              alignment: Alignment.center,
                              height: 60.0,
                              child:
                                  Text(const Key('Tab0').toString() + ': ListView$i'),
                            );
                          },
                          itemCount: 50,
                        ),
                        showGlowLeading: false,
                      ),
                    ),
                    NestedScrollViewInnerScrollPositionKeyWidget(
                      const Key('Tab1'),
                      GlowNotificationWidget(
                        ListView.builder(
                          //store Page state
                          key: const PageStorageKey<String>('Tab1'),
                          physics: const ClampingScrollPhysics(),
                          itemBuilder: (BuildContext c, int i) {
                            return Container(
                              alignment: Alignment.center,
                              height: 60.0,
                              child:
                                  Text(const Key('Tab1').toString() + ': ListView$i'),
                            );
                          },
                          itemCount: 50,
                        ),
                        showGlowLeading: false,
                      ),
                    )
                  ],
                ),
              )
            ],
          )),
    );
  }
}
