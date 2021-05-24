import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart'
    hide NestedScrollView, NestedScrollViewState;
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:loading_more_list/loading_more_list.dart';

@FFRoute(
  name: 'fluttercandies://scroll to top',
  routeName: 'scroll to top',
  description:
      'how to scroll list to top in NestedScrollView\'s body without ScrollController',
  exts: <String, dynamic>{
    'group': 'Complex',
    'order': 2,
  },
)
class ScrollToTopDemo extends StatefulWidget {
  @override
  _ScrollToTopDemoState createState() => _ScrollToTopDemoState();
}

class _ScrollToTopDemoState extends State<ScrollToTopDemo>
    with TickerProviderStateMixin {
  TabController primaryTC;
  final GlobalKey<NestedScrollViewState> _key =
      GlobalKey<NestedScrollViewState>();
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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.file_upload),
        onPressed: () {
          ///scroll current tab list
          _key.currentState.currentInnerPosition.animateTo(0.0,
              duration: const Duration(seconds: 1), curve: Curves.easeIn);

          ///scroll all tab list
          // _key.currentState.innerScrollPositions.forEach((position) {
          //   position.animateTo(0.0,
          //       duration: Duration(seconds: 1), curve: Curves.easeIn);
          // });
        },
      ),
    );
  }

  Widget _buildScaffoldBody() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double pinnedHeaderHeight =
        //statusBar height
        statusBarHeight +
            //pinned SliverAppBar height in header
            kToolbarHeight;
    return NestedScrollView(
      key: _key,
      // [SliverAppBar.stretch not supported issue](https://github.com/flutter/flutter/issues/54059)
      stretchHeaderSlivers: true,
      physics: const BouncingScrollPhysics(parent: const AlwaysScrollableScrollPhysics()),
      headerSliverBuilder: (BuildContext c, bool f) {
        return <Widget>[
          SliverAppBar(
              pinned: true,
              expandedHeight: 200.0,
              stretch: true,
              stretchTriggerOffset: 1.0,
              title: const Text('scroll to top'),
              flexibleSpace: FlexibleSpaceBar(
                  //centerTitle: true,
                  collapseMode: CollapseMode.pin,
                  stretchModes: [StretchMode.blurBackground, StretchMode.zoomBackground],
                  background: Image.asset(
                    'assets/467141054.jpg',
                    fit: BoxFit.cover,
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
                      physics: const BouncingScrollPhysics(parent: const AlwaysScrollableScrollPhysics()),
                      //store Page state
                      key: const PageStorageKey<String>('Tab0'),
                      itemBuilder: (BuildContext c, int i) {
                        return Container(
                          alignment: Alignment.center,
                          height: 60.0,
                          child: Text(
                              const Key('Tab0').toString() + ': ListView$i'),
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
                      physics: const BouncingScrollPhysics(parent: const AlwaysScrollableScrollPhysics()),
                      itemBuilder: (BuildContext c, int i) {
                        return Container(
                          alignment: Alignment.center,
                          height: 60.0,
                          child: Text(
                              const Key('Tab1').toString() + ': ListView$i'),
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
      ),
    );
  }
}
