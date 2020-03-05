import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide NestedScrollView;
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/services.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';


@FFRoute(
    name: "fluttercandies://Tik Tok Comment",
    routeName: "tiktokcomment",
    description: "Demo for Tik Tok Comment")
class DouYinPingLunDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tik Tok Comment'),
      ),
      body: ListView.builder(
        itemBuilder: (_, index) => Text(
          '$index',
          textAlign: TextAlign.center,
        ),
        itemCount: 1000,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, 'fluttercandies://PingLunDemo');
        },
        child: Icon(Icons.add_comment),
      ),
    );
  }
}

@FFRoute(
  name: "fluttercandies://PingLunDemo",
  routeName: "pingLundemo",
  description: "Tik Tok Comment",
  pageRouteType: PageRouteType.transparent,
)
class PingLunDemo extends StatefulWidget {
  @override
  _PingLunDemoState createState() => _PingLunDemoState();
}

class _PingLunDemoState extends State<PingLunDemo>
    with TickerProviderStateMixin {
  TabController primaryTC;
  ScrollController sc = ScrollController();
  TextEditingController tc = TextEditingController();
  FocusNode _focusNode = FocusNode()..canRequestFocus = false;
  Timer _timer;
  bool _isAnimating = false;
  bool _isTapped = false;
  @override
  void initState() {
    primaryTC = new TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      _isAnimating = true;
      sc
          .animateTo(200.0,
              duration: Duration(
                milliseconds: 300,
              ),
              curve: Curves.easeIn)
          .whenComplete(() => _isAnimating = false);
    });
    sc.addListener(() {
      if (!_isAnimating && !_isTapped && sc.position.pixels < 200.0) {
        // remove inertia scroll
        sc.jumpTo(200.0);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    primaryTC.dispose();
    sc.dispose();
    super.dispose();
  }

  void onNotification() {
    _timer?.cancel();
    if (sc.position.pixels < 50) {
      Navigator.pop(context);
    } else if (sc.position.pixels != 200.0) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 50), (Timer timer) {
      timer.cancel();
      if (sc.position.pixels != 200.0) {
        sc
            .animateTo(200.0,
                duration: Duration(
                  milliseconds: 50,
                ),
                curve: Curves.easeIn)
            .whenComplete(() => _isAnimating = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Listener(
        onPointerDown: (_) => _isTapped = true,
        onPointerUp: (_) => _isTapped = false,
        child: NotificationListener<ScrollNotification>(
          onNotification: (value) {
            if (value.depth == 0) {
              if (value is ScrollEndNotification ||
                  value is OverscrollNotification) {
                onNotification();
              }
            }
            return false;
          },
          child: _buildScaffoldBody(),
        ),
      ),
      color: Colors.transparent,
    );
  }

  Widget _buildScaffoldBody() {
    return NestedScrollView(
      controller: sc,
      headerSliverBuilder: (c, f) {
        return [
          SliverToBoxAdapter(
            child: GestureDetector(
              child: Container(
                height: 400.0,
                color: Colors.grey.withOpacity(0.5),
              ),
              onTap: () => Navigator.pop(context),
            ),
          )
        ];
      },
      //1.[pinned sliver header issue](https://github.com/flutter/flutter/issues/22393)
      pinnedHeaderSliverHeightBuilder: () {
        return 200.0;
      },
      //2.[inner scrollables in tabview sync issue](https://github.com/flutter/flutter/issues/21868)
      innerScrollPositionKeyBuilder: () {
        var index = "Tab";

        index += primaryTC.index.toString();

        return Key(index);
      },
      body: Material(
        child: Column(
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
                    GlowNotificationWidget(
                      ListView.builder(
                        //store Page state
                        key: PageStorageKey("Tab0"),
                        itemBuilder: (c, i) {
                          return Container(
                            alignment: Alignment.center,
                            height: 60.0,
                            child:
                                Text(Key("Tab0").toString() + ": ListView$i"),
                          );
                        },
                        itemCount: 50,
                      ),
                      showGlowLeading: false,
                    ),
                  ),
                  NestedScrollViewInnerScrollPositionKeyWidget(
                    Key("Tab1"),
                    GlowNotificationWidget(
                      ListView.builder(
                        //store Page state
                        key: PageStorageKey("Tab1"),
                        itemBuilder: (c, i) {
                          return Container(
                            alignment: Alignment.center,
                            height: 60.0,
                            child:
                                Text(Key("Tab1").toString() + ": ListView$i"),
                          );
                        },
                        itemCount: 50,
                      ),
                      showGlowLeading: false,
                    ),
                  )
                ],
              ),
            ),
            TextField(
              maxLines: 1,
              readOnly: false,
              showCursor: false,
              controller: tc,
              autofocus: false,
              focusNode: _focusNode,
              onTap: () {
                Navigator.pushNamed(context, 'fluttercandies://TextFieldPage',
                    arguments: {'text': tc.text}).then((value) {
                  tc.text = value;

                  ///make sure TextInput is hide
                  Future.delayed(Duration(milliseconds: 200), () {
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                  });
                });
              },
              decoration: InputDecoration(
                hintText: 'say something',
                contentPadding: EdgeInsets.all(
                  10.0,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 1.0,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(0.0)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@FFRoute(
  name: "fluttercandies://TextFieldPage",
  routeName: "TextFieldPage",
  description: "Tik Tok Comment",
  argumentNames: ['text'],
  pageRouteType: PageRouteType.transparent,
)
class TextFieldPage extends StatefulWidget {
  final String text;
  TextFieldPage({this.text});
  @override
  _TextFieldPageState createState() => _TextFieldPageState();
}

class _TextFieldPageState extends State<TextFieldPage> {
  TextEditingController tc = TextEditingController();
  FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    tc.text = widget.text;
    tc.selection = TextSelection.collapsed(offset: widget.text.length);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Material(
      color: Colors.transparent,
      child: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () {
                _focusNode.unfocus();
                Navigator.pop(context, tc.text);
              },
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          Material(
            child: TextField(
              maxLines: 1,
              autofocus: true,
              controller: tc,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'say something',
                contentPadding: EdgeInsets.all(
                  10.0,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 1.0,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(0.0)),
                ),
              ),
            ),
          ),
          Container(
            height: keyboardHeight,
          )
        ],
      ),
    );
  }
}
