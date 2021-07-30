import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';

class SecondaryTabView extends StatefulWidget {
  const SecondaryTabView(this.tabKey, this.tc);
  final String tabKey;
  final TabController tc;
  @override
  _SecondaryTabViewState createState() => _SecondaryTabViewState();
}

class _SecondaryTabViewState extends State<SecondaryTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final TabBar secondaryTabBar = TabBar(
      controller: widget.tc,
      labelColor: Colors.blue,
      indicatorColor: Colors.blue,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorWeight: 2.0,
      isScrollable: false,
      unselectedLabelColor: Colors.grey,
      tabs: <Tab>[
        Tab(text: widget.tabKey + '0'),
        Tab(text: widget.tabKey + '1'),
        Tab(text: widget.tabKey + '2'),
        Tab(text: widget.tabKey + '3'),
        Tab(text: widget.tabKey + '4'),
      ],
    );
    return Column(
      children: <Widget>[
        secondaryTabBar,
        Expanded(
          child: TabBarView(
            controller: widget.tc,
            children: <Widget>[
              TabViewItem(Key(widget.tabKey + '0')),
              TabViewItem(Key(widget.tabKey + '1')),
              TabViewItem(Key(widget.tabKey + '2')),
              TabViewItem(Key(widget.tabKey + '3')),
              CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  SliverFillRemaining(
                    child: Container(
                      color: Colors.blue,
                      child: const Text('tab4'),
                      alignment: Alignment.center,
                    ),
                  )
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class TabViewItem extends StatefulWidget {
  const TabViewItem(this.tabKey);
  final Key tabKey;
  @override
  _TabViewItemState createState() => _TabViewItemState();
}

class _TabViewItemState extends State<TabViewItem>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final GlowNotificationWidget child = GlowNotificationWidget(
      //margin: EdgeInsets.only(left: 190.0),
      ListView.builder(
          physics: const ClampingScrollPhysics(),
          itemBuilder: (BuildContext c, int i) {
            return Container(
              //decoration: BoxDecoration(border: Border.all(color: Colors.orange,width: 1.0)),
              alignment: Alignment.center,
              height: 60.0,
              width: double.infinity,
              //color: Colors.blue,
              child: Text(widget.tabKey.toString() + ': List$i'),
            );
          },
          itemCount: 100,
          padding: const EdgeInsets.all(0.0)),
      showGlowLeading: false,
    );

    return child;
  }

  @override
  bool get wantKeepAlive => true;
}

class CommonSliverPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  CommonSliverPersistentHeaderDelegate(this.child, this.height);
  final Widget child;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(CommonSliverPersistentHeaderDelegate oldDelegate) {
    //print('shouldRebuild---------------');
    return oldDelegate != this;
  }
}

Future<bool> onRefresh() {
  return Future<bool>.delayed(const Duration(seconds: 1), () {
    return true;
  });
}

List<Widget> buildSliverHeader() {
  final List<Widget> widgets = <Widget>[];

  widgets.add(SliverAppBar(
      pinned: true,
      expandedHeight: 200.0,
      //title: Text(old ? 'old demo' : 'new demo'),
      flexibleSpace: FlexibleSpaceBar(
          //centerTitle: true,
          collapseMode: CollapseMode.pin,
          background: Image.asset(
            'assets/467141054.jpg',
            fit: BoxFit.fill,
          ))));

  widgets.add(SliverGrid(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 4,
      crossAxisSpacing: 0.0,
      mainAxisSpacing: 0.0,
    ),
    delegate: SliverChildBuilderDelegate(
      (BuildContext context, int index) {
        return Container(
          alignment: Alignment.center,
          height: 60.0,
          child: Text('Gird$index'),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.orange, width: 1.0)),
        );
      },
      childCount: 7,
    ),
  ));

  widgets.add(SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext c, int i) {
    return Container(
      alignment: Alignment.center,
      height: 60.0,
      child: Text('SliverList$i'),
    );
  }, childCount: 3)));

//  widgets.add(SliverPersistentHeader(
//      pinned: true,
//      floating: false,
//      delegate: CommonSliverPersistentHeaderDelegate(
//          Container(
//            child: primaryTabBar,
//            //color: Colors.white,
//          ),
//          primaryTabBar.preferredSize.height)));
  return widgets;
}
