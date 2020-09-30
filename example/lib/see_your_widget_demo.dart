import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

const double itemHeight = 100.0;

class MyAppState extends State<MyApp> {
  GlobalKey<State> key = GlobalKey();

  bool widgetIn = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Check whether I\'m in'),
        ),
        body: NotificationListener<ScrollNotification>(
          child: ListView(
            itemExtent: itemHeight,
            children: <Widget>[
              YourWidget(),
              YourWidget(),
              YourWidget(),
              YourWidget(),
              YourWidget(),
              YourWidget(),
              YourWidget(),
              MyWidget(key: key),
              YourWidget(),
              YourWidget(),
              YourWidget(),
              YourWidget(),
              YourWidget(),
              YourWidget(),
              YourWidget(),
              YourWidget()
            ],
          ),
          onNotification: (ScrollNotification scroll) {
            final BuildContext currentContext = key.currentContext;
            if (currentContext == null) {
              return false;
            }
            //final double screenHeight = MediaQuery.of(currentContext).size.height;
            final RenderObject renderObject = currentContext.findRenderObject();
            final RenderAbstractViewport viewport =
                RenderAbstractViewport.of(renderObject);

            /// The `alignment` argument describes where the target should be positioned
            /// after applying the returned offset. If `alignment` is 0.0, the child must
            /// be positioned as close to the leading edge of the viewport as possible. If
            /// `alignment` is 1.0, the child must be positioned as close to the trailing
            /// edge of the viewport as possible. If `alignment` is 0.5, the child must be
            /// positioned as close to the center of the viewport as possible.

            /// Distance between top edge of screen and MyWidget bottom edge
            final RevealedOffset offsetToRevealLeading =
                viewport.getOffsetToReveal(renderObject, 0.0);

            /// Distance between bottom edge of screen and MyWidget top edge
            final RevealedOffset offsetToRevealTrailingEdge =
                viewport.getOffsetToReveal(renderObject, 1.0);

            print(
                ' ${scroll.metrics.pixels}  ${offsetToRevealLeading.offset} ${offsetToRevealTrailingEdge.offset}');

            final double offset = scroll.metrics.pixels;
            //in
            //
            if (offsetToRevealTrailingEdge.offset <= offset + itemHeight &&
                offset <= offsetToRevealLeading.offset + itemHeight) {
              if (!widgetIn) {
                setState(() {
                  widgetIn = true;
                });
              }
            }
            //out
            else {
              if (widgetIn) {
                setState(() {
                  //out
                  widgetIn = false;
                });
              }
            }

            return false;
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: Container(
            child: Text(widgetIn ? 'I see you ' : 'bye bye'),
            height: 200.0,
            width: 200.0,
            alignment: Alignment.center,
          ),
          onPressed: () {},
        ),
      ),
    );
  }
}

class MyWidget extends StatefulWidget {
  const MyWidget({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MyWidgetState();
}

class MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(height: itemHeight, color: Colors.red);
  }
}

class YourWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(), color: Colors.grey),
    );
  }
}
