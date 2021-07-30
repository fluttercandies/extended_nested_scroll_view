import 'package:example/common/common.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/material.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:loading_more_list/loading_more_list.dart';

@FFRoute(
  name: 'fluttercandies://nestedscrollview',
  routeName: 'NestedScrollview',
  description: 'fix pinned header and inner scrollables sync issues.',
  exts: <String, dynamic>{
    'group': 'Simple',
    'order': 0,
  },
)
class ExtendedNestedScrollViewDemo extends StatefulWidget {
  @override
  _ExtendedNestedScrollViewDemoState createState() =>
      _ExtendedNestedScrollViewDemoState();
}

class _ExtendedNestedScrollViewDemoState
    extends State<ExtendedNestedScrollViewDemo> with TickerProviderStateMixin {
  TabController primaryTC;
  TabController secondaryTC;

  @override
  void initState() {
    primaryTC = TabController(length: 2, vsync: this);
    secondaryTC = TabController(length: 5, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    primaryTC.dispose();
    secondaryTC.dispose();
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
        return buildSliverHeader();
      },
      //1.[pinned sliver header issue](https://github.com/flutter/flutter/issues/22393)
      pinnedHeaderSliverHeightBuilder: () {
        return pinnedHeaderHeight;
      },
      //2.[inner scrollables in tabview sync issue](https://github.com/flutter/flutter/issues/21868)
      onlyOneScrollInBody: true,
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 150,
            child: Swiper(
              itemBuilder: (BuildContext context, int index) {
                return Image.network(
                  'http://via.placeholder.com/350x150',
                  fit: BoxFit.fill,
                );
              },
              itemCount: 3,
              pagination: const SwiperPagination(),
              autoplay: true,
            ),
          ),
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
                SecondaryTabView('Tab0', secondaryTC),
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
              ],
            ),
          )
        ],
      ),
    );
  }
}
