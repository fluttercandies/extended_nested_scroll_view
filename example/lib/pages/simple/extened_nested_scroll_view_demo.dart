import 'package:example/common/common.dart';
import 'package:flutter/material.dart' hide NestedScrollView;
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';

@FFRoute(
  name: 'fluttercandies://nestedscrollview',
  routeName: 'NestedScrollview',
  description: 'fix pinned header and inner scrollables sync issues.',
  exts: <String, dynamic>{
    'group': 'Simple',
    'order': 0,
  },
)
class OldExtendedNestedScrollViewDemo extends StatefulWidget {
  @override
  _OldExtendedNestedScrollViewDemoState createState() =>
      _OldExtendedNestedScrollViewDemoState();
}

class _OldExtendedNestedScrollViewDemoState
    extends State<OldExtendedNestedScrollViewDemo>
    with TickerProviderStateMixin {
  TabController primaryTC;
  TabController secondaryTC;

  @override
  void initState() {
    primaryTC = TabController(length: 2, vsync: this);
    primaryTC.addListener(tabControlerListener);
    secondaryTC = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    primaryTC.removeListener(tabControlerListener);
    primaryTC.dispose();
    secondaryTC.dispose();
    super.dispose();
  }

  //when primary tabcontroller tab,rebuild headerSliverBuilder
  //click fire twice (due to animation),gesture fire onetime
  int index;
  void tabControlerListener() {
    if (index != primaryTC.index) {
      //your code
      index = primaryTC.index;
    }
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
    return NestedScrollViewRefreshIndicator(
      onRefresh: onRefresh,
      child: NestedScrollView(
          headerSliverBuilder: (BuildContext c, bool f) {
            return buildSliverHeader();
          },
          //1.[pinned sliver header issue](https://github.com/flutter/flutter/issues/22393)
          pinnedHeaderSliverHeightBuilder: () {
            return pinnedHeaderHeight;
          },
          //2.[inner scrollables in tabview sync issue](https://github.com/flutter/flutter/issues/21868)
          innerScrollPositionKeyBuilder: () {
            String index = 'Tab';
            if (primaryTC.index == 0) {
              index +=
                  primaryTC.index.toString() + secondaryTC.index.toString();
            } else {
              index += primaryTC.index.toString();
            }
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
                    SecondaryTabView('Tab0', secondaryTC, true),
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
                              child: Text(const Key('Tab1').toString() +
                                  ': ListView$i'),
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
