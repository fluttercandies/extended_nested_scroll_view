// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;

//import 'package:extended_nested_scroll_view/src/nested_scroll_view_inner_scroll_position_key_widget.dart';
//import 'package:extended_nested_scroll_view/src/util.dart';
//import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
//    as extend;
import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

// Examples can assume:
// List<String> _tabs;

/// Signature used by [ExtendedNestedScrollView] for building its header.
///
/// The `innerBoxIsScrolled` argument is typically used to control the
/// [SliverAppBar.forceElevated] property to ensure that the app bar shows a
/// shadow, since it would otherwise not necessarily be aware that it had
/// content ostensibly below it.

//it include statusBarHeight ,pinned appbar height ,pinned SliverPersistentHeader height
//which are in NestedScrollViewHeaderSlivers
typedef ExtendedNestedScrollViewPinnedHeaderSliverHeightBuilder = double
    Function();

/// A scrolling view inside of which can be nested other scrolling views, with
/// their scroll positions being intrinsically linked.
///
/// The most common use case for this widget is a scrollable view with a
/// flexible [SliverAppBar] containing a [TabBar] in the header (build by
/// [headerSliverBuilder], and with a [TabBarView] in the [body], such that the
/// scrollable view's contents vary based on which tab is visible.
///
/// ## Motivation
///
/// In a normal [ScrollView], there is one set of slivers (the components of the
/// scrolling view). If one of those slivers hosted a [TabBarView] which scrolls
/// in the opposite direction (e.g. allowing the user to swipe horizontally
/// between the pages represented by the tabs, while the list scrolls
/// vertically), then any list inside that [TabBarView] would not interact with
/// the outer [ScrollView]. For example, flinging the inner list to scroll to
/// the top would not cause a collapsed [SliverAppBar] in the outer [ScrollView]
/// to expand.
///
/// [ExtendedNestedScrollView] solves this problem by providing custom
/// [ScrollController]s for the outer [ScrollView] and the inner [ScrollView]s
/// (those inside the [TabBarView], hooking them together so that they appear,
/// to the user, as one coherent scroll view.
///
/// {@tool sample}
///
/// This example shows a [ExtendedNestedScrollView] whose header is the combination of a
/// [TabBar] in a [SliverAppBar] and whose body is a [TabBarView]. It uses a
/// [SliverOverlapAbsorber]/[SliverOverlapInjector] pair to make the inner lists
/// align correctly, and it uses [SafeArea] to avoid any horizontal disturbances
/// (e.g. the "notch" on iOS when the phone is horizontal). In addition,
/// [PageStorageKey]s are used to remember the scroll position of each tab's
/// list.
///
/// In the example below, `_tabs` is a list of strings, one for each tab, giving
/// the tab labels. In a real application, it would be replaced by the actual
/// data model being represented.
///
/// ```dart
/// DefaultTabController(
///   length: _tabs.length, // This is the number of tabs.
///   child: NestedScrollView(
///     headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
///       // These are the slivers that show up in the "outer" scroll view.
///       return <Widget>[
///         SliverOverlapAbsorber(
///           // This widget takes the overlapping behavior of the SliverAppBar,
///           // and redirects it to the SliverOverlapInjector below. If it is
///           // missing, then it is possible for the nested "inner" scroll view
///           // below to end up under the SliverAppBar even when the inner
///           // scroll view thinks it has not been scrolled.
///           // This is not necessary if the "headerSliverBuilder" only builds
///           // widgets that do not overlap the next sliver.
///           handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
///           child: SliverAppBar(
///             title: const Text('Books'), // This is the title in the app bar.
///             pinned: true,
///             expandedHeight: 150.0,
///             // The "forceElevated" property causes the SliverAppBar to show
///             // a shadow. The "innerBoxIsScrolled" parameter is true when the
///             // inner scroll view is scrolled beyond its "zero" point, i.e.
///             // when it appears to be scrolled below the SliverAppBar.
///             // Without this, there are cases where the shadow would appear
///             // or not appear inappropriately, because the SliverAppBar is
///             // not actually aware of the precise position of the inner
///             // scroll views.
///             forceElevated: innerBoxIsScrolled,
///             bottom: TabBar(
///               // These are the widgets to put in each tab in the tab bar.
///               tabs: _tabs.map((String name) => Tab(text: name)).toList(),
///             ),
///           ),
///         ),
///       ];
///     },
///     body: TabBarView(
///       // These are the contents of the tab views, below the tabs.
///       children: _tabs.map((String name) {
///         return SafeArea(
///           top: false,
///           bottom: false,
///           child: Builder(
///             // This Builder is needed to provide a BuildContext that is "inside"
///             // the NestedScrollView, so that sliverOverlapAbsorberHandleFor() can
///             // find the NestedScrollView.
///             builder: (BuildContext context) {
///               return CustomScrollView(
///                 // The "controller" and "primary" members should be left
///                 // unset, so that the NestedScrollView can control this
///                 // inner scroll view.
///                 // If the "controller" property is set, then this scroll
///                 // view will not be associated with the NestedScrollView.
///                 // The PageStorageKey should be unique to this ScrollView;
///                 // it allows the list to remember its scroll position when
///                 // the tab view is not on the screen.
///                 key: PageStorageKey<String>(name),
///                 slivers: <Widget>[
///                   SliverOverlapInjector(
///                     // This is the flip side of the SliverOverlapAbsorber above.
///                     handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
///                   ),
///                   SliverPadding(
///                     padding: const EdgeInsets.all(8.0),
///                     // In this example, the inner scroll view has
///                     // fixed-height list items, hence the use of
///                     // SliverFixedExtentList. However, one could use any
///                     // sliver widget here, e.g. SliverList or SliverGrid.
///                     sliver: SliverFixedExtentList(
///                       // The items in this example are fixed to 48 pixels
///                       // high. This matches the Material Design spec for
///                       // ListTile widgets.
///                       itemExtent: 48.0,
///                       delegate: SliverChildBuilderDelegate(
///                         (BuildContext context, int index) {
///                           // This builder is called for each child.
///                           // In this example, we just number each list item.
///                           return ListTile(
///                             title: Text('Item $index'),
///                           );
///                         },
///                         // The childCount of the SliverChildBuilderDelegate
///                         // specifies how many children this inner list
///                         // has. In this example, each tab has a list of
///                         // exactly 30 items, but this is arbitrary.
///                         childCount: 30,
///                       ),
///                     ),
///                   ),
///                 ],
///               );
///             },
///           ),
///         );
///       }).toList(),
///     ),
///   ),
/// )
/// ```
/// {@end-tool}
class ExtendedNestedScrollView extends StatefulWidget {
  /// Creates a nested scroll view.
  ///
  /// The [reverse], [headerSliverBuilder], and [body] arguments must not be
  /// null.
  const ExtendedNestedScrollView({
    Key key,
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.physics,
    this.pinnedHeaderSliverHeightBuilder,
    this.pinnedHeaderSliverHeight,
    this.keepOnlyOneInnerNestedScrollPositionActive: false,
    @required this.headerSliverBuilder,
    @required this.body,
  })  : assert(false,
            "new ExtendedNestedScrollView still has some issues in special layout, make it as obsolete for now till find a better solution"),
        assert(scrollDirection != null),
        assert(reverse != null),
        assert(headerSliverBuilder != null),
        assert(body != null),

        ///don't use them at the same time
        assert(!(pinnedHeaderSliverHeight != null &&
            pinnedHeaderSliverHeightBuilder != null)),
        super(key: key);

  ///get the pinned header in NestedScrollView header.
  ///if your pinned header will changed, use this instead  of  [pinnedHeaderSliverHeight]
  final ExtendedNestedScrollViewPinnedHeaderSliverHeightBuilder
      pinnedHeaderSliverHeightBuilder;

  ///if your pinned header will not changed, use this instead  of  [pinnedHeaderSliverHeightBuilder]
  final double pinnedHeaderSliverHeight;

  ///when ExtendedNestedScrollView body has [TabBarView]/[PageView] and children have
  ///AutomaticKeepAliveClientMixin or PageStorageKey,
  ///[_innerController.nestedPositions] will have more one,
  ///when you scroll, it will scroll all of nestedPositions
  ///set [keepOnlyOneInnerNestedScrollPositionActive] true to avoid it.
  ///notice: only for Axis.horizontal PageView/TabBarView and
  ///[scrollDirection] must be Axis.vertical.
  final bool keepOnlyOneInnerNestedScrollPositionActive;

  /// An object that can be used to control the position to which the outer
  /// scroll view is scrolled.
  final ScrollController controller;

  /// The axis along which the scroll view scrolls.
  ///
  /// Defaults to [Axis.vertical].
  final Axis scrollDirection;

  /// Whether the scroll view scrolls in the reading direction.
  ///
  /// For example, if the reading direction is left-to-right and
  /// [scrollDirection] is [Axis.horizontal], then the scroll view scrolls from
  /// left to right when [reverse] is false and from right to left when
  /// [reverse] is true.
  ///
  /// Similarly, if [scrollDirection] is [Axis.vertical], then the scroll view
  /// scrolls from top to bottom when [reverse] is false and from bottom to top
  /// when [reverse] is true.
  ///
  /// Defaults to false.
  final bool reverse;

  /// How the scroll view should respond to user input.
  ///
  /// For example, determines how the scroll view continues to animate after the
  /// user stops dragging the scroll view (providing a custom implementation of
  /// [ScrollPhysics.createBallisticSimulation] allows this particular aspect of
  /// the physics to be overridden).
  ///
  /// Defaults to matching platform conventions.
  ///
  /// The [ScrollPhysics.applyBoundaryConditions] implementation of the provided
  /// object should not allow scrolling outside the scroll extent range
  /// described by the [ScrollMetrics.minScrollExtent] and
  /// [ScrollMetrics.maxScrollExtent] properties passed to that method. If that
  /// invariant is not maintained, the nested scroll view may respond to user
  /// scrolling erratically.
  final ScrollPhysics physics;

  /// A builder for any widgets that are to precede the inner scroll views (as
  /// given by [body]).
  ///
  /// Typically this is used to create a [SliverAppBar] with a [TabBar].
  final NestedScrollViewHeaderSliversBuilder headerSliverBuilder;

  /// The widget to show inside the [ExtendedNestedScrollView].
  ///
  /// Typically this will be [TabBarView].
  ///
  /// The [body] is built in a context that provides a [PrimaryScrollController]
  /// that interacts with the [ExtendedNestedScrollView]'s scroll controller. Any
  /// [ListView] or other [Scrollable]-based widget inside the [body] that is
  /// intended to scroll with the [ExtendedNestedScrollView] should therefore not be
  /// given an explicit [ScrollController], instead allowing it to default to
  /// the [PrimaryScrollController] provided by the [ExtendedNestedScrollView].
  final Widget body;

  /// Returns the [SliverOverlapAbsorberHandle] of the nearest ancestor
  /// [ExtendedNestedScrollView].
  ///
  /// This is necessary to configure the [SliverOverlapAbsorber] and
  /// [SliverOverlapInjector] widgets.
  ///
  /// For sample code showing how to use this method, see the [ExtendedNestedScrollView]
  /// documentation.
  static SliverOverlapAbsorberHandle sliverOverlapAbsorberHandleFor(
      BuildContext context) {
    final _InheritedNestedScrollView target =
        context.inheritFromWidgetOfExactType(_InheritedNestedScrollView);
    assert(target != null,
        'NestedScrollView.sliverOverlapAbsorberHandleFor must be called with a context that contains a NestedScrollView.');
    return target.state._absorberHandle;
  }

//  List<Widget> _buildSlivers(BuildContext context,
//      ScrollController innerController, bool bodyIsScrolled) {
//    final List<Widget> slivers = <Widget>[];
//    slivers.addAll(headerSliverBuilder(context, bodyIsScrolled));
//    slivers.add(
//        SliverFillRemaining(
//      child: PrimaryScrollController(
//        controller: innerController,
//        child: body,
//      ),
//    ));
//    return slivers;
//  }

  @override
  _ExtendedNestedScrollViewState createState() =>
      _ExtendedNestedScrollViewState();
}

class _ExtendedNestedScrollViewState extends State<ExtendedNestedScrollView> {
  final SliverOverlapAbsorberHandle _absorberHandle =
      SliverOverlapAbsorberHandle();

  _NestedScrollCoordinator _coordinator;

  @override
  void initState() {
    ///when ExtendedNestedScrollView body has [TabBarView]/[PageView] and children have
    ///AutomaticKeepAliveClientMixin or PageStorageKey,
    ///[_innerController.nestedPositions] will have more one,
    ///when you scroll, it will scroll all of nestedPositions
    ///set [keepOnlyOneInnerNestedScrollPositionActive] true to avoid it.
    ///notice: only for Axis.horizontal [TabBarView]/[PageView] and
    ///[scrollDirection] must be Axis.vertical.
    assert(!(widget.keepOnlyOneInnerNestedScrollPositionActive &&
        widget.scrollDirection == Axis.horizontal));

    super.initState();
    _coordinator = _NestedScrollCoordinator(
        this, widget.controller, _handleHasScrolledBodyChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _coordinator.setParent(widget.controller);
  }

  @override
  void didUpdateWidget(ExtendedNestedScrollView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller)
      _coordinator.setParent(widget.controller);
  }

  @override
  void dispose() {
    _coordinator.dispose();
    _coordinator = null;
    super.dispose();
  }

  bool _lastHasScrolledBody;

  void _handleHasScrolledBodyChanged() {
    if (!mounted) return;
    final bool newHasScrolledBody = _coordinator.hasScrolledBody;
    if (_lastHasScrolledBody != newHasScrolledBody) {
      setState(() {
        // _coordinator.hasScrolledBody changed (we use it in the build method)
        // (We record _lastHasScrolledBody in the build() method, rather than in
        // this setState call, because the build() method may be called more
        // often than just from here, and we want to only call setState when the
        // new value is different than the last built value.)
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var child = _InheritedNestedScrollView(
      state: this,
      child: Builder(
        builder: (BuildContext context) {
          _lastHasScrolledBody = _coordinator.hasScrolledBody;
          return _NestedScrollViewCustomScrollView(
            scrollDirection: widget.scrollDirection,
            reverse: widget.reverse,
            physics: widget.physics != null
                ? widget.physics.applyTo(const ClampingScrollPhysics())
                : const ClampingScrollPhysics(),
            controller: _coordinator._outerController,
            slivers: _buildSlivers(
              context,
              _coordinator._innerController,
              _lastHasScrolledBody,
            ),
            handle: _absorberHandle,
          );
        },
      ),
    );
    return child;
  }

  ///zmt
  List<Widget> _buildSlivers(BuildContext context,
      ScrollController innerController, bool bodyIsScrolled) {
    final List<Widget> slivers = <Widget>[];
    slivers.addAll(widget.headerSliverBuilder(context, bodyIsScrolled));

    Widget body = widget.body;

    if (widget.keepOnlyOneInnerNestedScrollPositionActive) {
      ///get notifications and compute active one in _innerController.nestedPositions
      body = NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (((notification is ScrollEndNotification) ||
                    (notification is UserScrollNotification &&
                        notification.direction == ScrollDirection.idle)) &&
                notification.metrics is PageMetrics &&
                notification.metrics.axis == Axis.horizontal) {
              _coordinator._innerController
                  ._computeActivatedNestedPosition(notification);
            }
            return false;
          },
          child: body);
    }

    slivers.add(SliverFillRemaining(
      child: PrimaryScrollController(
        controller: innerController,
        child: body,
      ),
    ));
    return slivers;
  }
}

class _NestedScrollViewCustomScrollView extends CustomScrollView {
  const _NestedScrollViewCustomScrollView({
    @required Axis scrollDirection,
    @required bool reverse,
    @required ScrollPhysics physics,
    @required ScrollController controller,
    @required List<Widget> slivers,
    @required this.handle,
  }) : super(
          scrollDirection: scrollDirection,
          reverse: reverse,
          physics: physics,
          controller: controller,
          slivers: slivers,
        );

  final SliverOverlapAbsorberHandle handle;

  @override
  Widget buildViewport(
    BuildContext context,
    ViewportOffset offset,
    AxisDirection axisDirection,
    List<Widget> slivers,
  ) {
    assert(!shrinkWrap);
    return NestedScrollViewViewport(
      axisDirection: axisDirection,
      offset: offset,
      slivers: slivers,
      handle: handle,
    );
  }
}

class _InheritedNestedScrollView extends InheritedWidget {
  const _InheritedNestedScrollView({
    Key key,
    @required this.state,
    @required Widget child,
  })  : assert(state != null),
        assert(child != null),
        super(key: key, child: child);

  final _ExtendedNestedScrollViewState state;

  @override
  bool updateShouldNotify(_InheritedNestedScrollView old) => state != old.state;
}

class _NestedScrollMetrics extends FixedScrollMetrics {
  _NestedScrollMetrics({
    @required double minScrollExtent,
    @required double maxScrollExtent,
    @required double pixels,
    @required double viewportDimension,
    @required AxisDirection axisDirection,
    @required this.minRange,
    @required this.maxRange,
    @required this.correctionOffset,
  }) : super(
          minScrollExtent: minScrollExtent,
          maxScrollExtent: maxScrollExtent,
          pixels: pixels,
          viewportDimension: viewportDimension,
          axisDirection: axisDirection,
        );

  @override
  _NestedScrollMetrics copyWith({
    double minScrollExtent,
    double maxScrollExtent,
    double pixels,
    double viewportDimension,
    AxisDirection axisDirection,
    double minRange,
    double maxRange,
    double correctionOffset,
  }) {
    return _NestedScrollMetrics(
      minScrollExtent: minScrollExtent ?? this.minScrollExtent,
      maxScrollExtent: maxScrollExtent ?? this.maxScrollExtent,
      pixels: pixels ?? this.pixels,
      viewportDimension: viewportDimension ?? this.viewportDimension,
      axisDirection: axisDirection ?? this.axisDirection,
      minRange: minRange ?? this.minRange,
      maxRange: maxRange ?? this.maxRange,
      correctionOffset: correctionOffset ?? this.correctionOffset,
    );
  }

  final double minRange;

  final double maxRange;

  final double correctionOffset;
}

typedef _NestedScrollActivityGetter = ScrollActivity Function(
    _NestedScrollPosition position);

class _NestedScrollCoordinator
    implements ScrollActivityDelegate, ScrollHoldController {
  _NestedScrollCoordinator(
      this._state, this._parent, this._onHasScrolledBodyChanged) {
    final double initialScrollOffset = _parent?.initialScrollOffset ?? 0.0;
    _outerController = _NestedScrollController(this,
        initialScrollOffset: initialScrollOffset, debugLabel: 'outer');
    _innerController = _NestedScrollController(this,
        initialScrollOffset: 0.0, debugLabel: 'inner');
  }

  final _ExtendedNestedScrollViewState _state;
  ScrollController _parent;
  final VoidCallback _onHasScrolledBodyChanged;

  _NestedScrollController _outerController;
  _NestedScrollController _innerController;

  _NestedScrollPosition get _outerPosition {
    if (!_outerController.hasClients) return null;
    return _outerController.nestedPositions.single;
  }

  ///zmt
  ///scroll only for actived one
  Iterable<_NestedScrollPosition> get _activedInnerPositions {
    var list = _innerController.nestedPositions;
    if (_state.widget.keepOnlyOneInnerNestedScrollPositionActive &&
        list.length > 1) {
      var temp = list.where((item) {
        return item._isActived;
      });
//
//      if (temp.length == 0 &&
//          _innerController.prePageChangedRenderBox != null) {
//        _innerController._computeActivatedNestedPosition(null);
//        temp = list.where((item) {
//          return item._isActived;
//        });
//      }

      if (temp.length != 1) {
        return list;
      }
      return temp;
    }
    return list;
  }

  Iterable<_NestedScrollPosition> get _innerPositions {
    return _innerController.nestedPositions;
  }

  bool get canScrollBody {
    final _NestedScrollPosition outer = _outerPosition;
    if (outer == null) return true;
    return outer.haveDimensions && outer.extentAfter == 0.0;
  }

  bool get hasScrolledBody {
    for (_NestedScrollPosition position in _activedInnerPositions) {
      if (position.pixels > position.minScrollExtent) return true;
    }
    return false;
  }

  void updateShadow() {
    if (_onHasScrolledBodyChanged != null) _onHasScrolledBodyChanged();
  }

  ScrollDirection get userScrollDirection => _userScrollDirection;
  ScrollDirection _userScrollDirection = ScrollDirection.idle;

  void updateUserScrollDirection(ScrollDirection value) {
    assert(value != null);
    if (userScrollDirection == value) return;
    _userScrollDirection = value;
    _outerPosition.didUpdateScrollDirection(value);
    for (_NestedScrollPosition position in _innerPositions)
      position.didUpdateScrollDirection(value);
  }

  ScrollDragController _currentDrag;

  void beginActivity(ScrollActivity newOuterActivity,
      _NestedScrollActivityGetter innerActivityGetter) {
    _outerPosition.beginActivity(newOuterActivity);
    bool scrolling = newOuterActivity.isScrolling;
    for (_NestedScrollPosition position in _activedInnerPositions) {
      final ScrollActivity newInnerActivity = innerActivityGetter(position);
      position.beginActivity(newInnerActivity);
      scrolling = scrolling && newInnerActivity.isScrolling;
    }
    _currentDrag?.dispose();
    _currentDrag = null;
    if (!scrolling) updateUserScrollDirection(ScrollDirection.idle);
  }

  @override
  AxisDirection get axisDirection => _outerPosition.axisDirection;

  static IdleScrollActivity _createIdleScrollActivity(
      _NestedScrollPosition position) {
    return IdleScrollActivity(position);
  }

  @override
  void goIdle() {
    beginActivity(
        _createIdleScrollActivity(_outerPosition), _createIdleScrollActivity);
  }

  @override
  void goBallistic(double velocity) {
    beginActivity(
      createOuterBallisticScrollActivity(velocity),
      (_NestedScrollPosition position) =>
          createInnerBallisticScrollActivity(position, velocity),
    );
  }

  ScrollActivity createOuterBallisticScrollActivity(double velocity) {
    // This function creates a ballistic scroll for the outer scrollable.
    //
    // It assumes that the outer scrollable can't be overscrolled, and sets up a
    // ballistic scroll over the combined space of the innerPositions and the
    // outerPosition.

    // First we must pick a representative inner position that we will care
    // about. This is somewhat arbitrary. Ideally we'd pick the one that is "in
    // the center" but there isn't currently a good way to do that so we
    // arbitrarily pick the one that is the furthest away from the infinity we
    // are heading towards.
    _NestedScrollPosition innerPosition;
    if (velocity != 0.0) {
      for (_NestedScrollPosition position in _activedInnerPositions) {
        if (innerPosition != null) {
          if (velocity > 0.0) {
            if (innerPosition.pixels < position.pixels) continue;
          } else {
            assert(velocity < 0.0);
            if (innerPosition.pixels > position.pixels) continue;
          }
        }
        innerPosition = position;
      }
    }

    if (innerPosition == null) {
      // It's either just us or a velocity=0 situation.
      return _outerPosition.createBallisticScrollActivity(
        _outerPosition.physics
            .createBallisticSimulation(_outerPosition, velocity),
        mode: _NestedBallisticScrollActivityMode.independent,
      );
    }

    final _NestedScrollMetrics metrics = _getMetrics(innerPosition, velocity);

    return _outerPosition.createBallisticScrollActivity(
      _outerPosition.physics.createBallisticSimulation(metrics, velocity),
      mode: _NestedBallisticScrollActivityMode.outer,
      metrics: metrics,
    );
  }

  @protected
  ScrollActivity createInnerBallisticScrollActivity(
      _NestedScrollPosition position, double velocity) {
    return position.createBallisticScrollActivity(
      position.physics.createBallisticSimulation(
        velocity == 0 ? position : _getMetrics(position, velocity),
        velocity,
      ),
      mode: _NestedBallisticScrollActivityMode.inner,
    );
  }

  _NestedScrollMetrics _getMetrics(
      _NestedScrollPosition innerPosition, double velocity) {
    assert(innerPosition != null);
    double pixels, minRange, maxRange, correctionOffset, extra;
    if (innerPosition.pixels == innerPosition.minScrollExtent) {
      pixels = _outerPosition.pixels.clamp(
          _outerPosition.minScrollExtent,
          _outerPosition
              .maxScrollExtent); // TODO(ianh): gracefully handle out-of-range outer positions
      minRange = _outerPosition.minScrollExtent;
      maxRange = _outerPosition.maxScrollExtent;
      assert(minRange <= maxRange);
      correctionOffset = 0.0;
      extra = 0.0;
    } else {
      assert(innerPosition.pixels != innerPosition.minScrollExtent);
      if (innerPosition.pixels < innerPosition.minScrollExtent) {
        pixels = innerPosition.pixels -
            innerPosition.minScrollExtent +
            _outerPosition.minScrollExtent;
      } else {
        assert(innerPosition.pixels > innerPosition.minScrollExtent);
        pixels = innerPosition.pixels -
            innerPosition.minScrollExtent +
            _outerPosition.maxScrollExtent;
      }
      if ((velocity > 0.0) &&
          (innerPosition.pixels > innerPosition.minScrollExtent)) {
        // This handles going forward (fling up) and inner list is scrolled past
        // zero. We want to grab the extra pixels immediately to shrink.
        extra = _outerPosition.maxScrollExtent - _outerPosition.pixels;
        assert(extra >= 0.0);
        minRange = pixels;
        maxRange = pixels + extra;
        assert(minRange <= maxRange);
        correctionOffset = _outerPosition.pixels - pixels;
      } else if ((velocity < 0.0) &&
          (innerPosition.pixels < innerPosition.minScrollExtent)) {
        // This handles going backward (fling down) and inner list is
        // underscrolled. We want to grab the extra pixels immediately to grow.
        extra = _outerPosition.pixels - _outerPosition.minScrollExtent;
        assert(extra >= 0.0);
        minRange = pixels - extra;
        maxRange = pixels;
        assert(minRange <= maxRange);
        correctionOffset = _outerPosition.pixels - pixels;
      } else {
        // This handles going forward (fling up) and inner list is
        // underscrolled, OR, going backward (fling down) and inner list is
        // scrolled past zero. We want to skip the pixels we don't need to grow
        // or shrink over.
        if (velocity > 0.0) {
          // shrinking
          extra = _outerPosition.minScrollExtent - _outerPosition.pixels;
        } else {
          assert(velocity < 0.0);
          // growing
          extra = _outerPosition.pixels -
              (_outerPosition.maxScrollExtent - _outerPosition.minScrollExtent);
        }
        assert(extra <= 0.0);
        minRange = _outerPosition.minScrollExtent;
        maxRange = _outerPosition.maxScrollExtent + extra;
        assert(minRange <= maxRange);
        correctionOffset = 0.0;
      }
    }
    return _NestedScrollMetrics(
      minScrollExtent: _outerPosition.minScrollExtent,
      maxScrollExtent: _outerPosition.maxScrollExtent +
          innerPosition.maxScrollExtent -
          innerPosition.minScrollExtent +
          extra,
      pixels: pixels,
      viewportDimension: _outerPosition.viewportDimension,
      axisDirection: _outerPosition.axisDirection,
      minRange: minRange,
      maxRange: maxRange,
      correctionOffset: correctionOffset,
    );
  }

  double unnestOffset(double value, _NestedScrollPosition source) {
    if (source == _outerPosition)
      return value.clamp(
          _outerPosition.minScrollExtent, _outerPosition.maxScrollExtent);
    if (value < source.minScrollExtent)
      return value - source.minScrollExtent + _outerPosition.minScrollExtent;
    return value - source.minScrollExtent + _outerPosition.maxScrollExtent;
  }

  double nestOffset(double value, _NestedScrollPosition target) {
    if (target == _outerPosition)
      return value.clamp(
          _outerPosition.minScrollExtent, _outerPosition.maxScrollExtent);
    if (value < _outerPosition.minScrollExtent)
      return value - _outerPosition.minScrollExtent + target.minScrollExtent;
    if (value > _outerPosition.maxScrollExtent)
      return value - _outerPosition.maxScrollExtent + target.minScrollExtent;
    return target.minScrollExtent;
  }

  void updateCanDrag() {
    if (!_outerPosition.haveDimensions) return;
    double maxInnerExtent = 0.0;
    for (_NestedScrollPosition position in _activedInnerPositions) {
      if (!position.haveDimensions) return;
      maxInnerExtent = math.max(
          maxInnerExtent, position.maxScrollExtent - position.minScrollExtent);
    }
    _outerPosition.updateCanDrag(maxInnerExtent);
  }

  Future<void> animateTo(
    double to, {
    @required Duration duration,
    @required Curve curve,
  }) async {
    final DrivenScrollActivity outerActivity =
        _outerPosition.createDrivenScrollActivity(
      nestOffset(to, _outerPosition),
      duration,
      curve,
    );
    final List<Future<void>> resultFutures = <Future<void>>[outerActivity.done];
    beginActivity(
      outerActivity,
      (_NestedScrollPosition position) {
        final DrivenScrollActivity innerActivity =
            position.createDrivenScrollActivity(
          nestOffset(to, position),
          duration,
          curve,
        );
        resultFutures.add(innerActivity.done);
        return innerActivity;
      },
    );
    await Future.wait<void>(resultFutures);
  }

  void jumpTo(double to) {
    goIdle();
    _outerPosition.localJumpTo(nestOffset(to, _outerPosition));
    for (_NestedScrollPosition position in _activedInnerPositions)
      position.localJumpTo(nestOffset(to, position));
    goBallistic(0.0);
  }

  @override
  double setPixels(double newPixels) {
    assert(false);
    return 0.0;
  }

  ScrollHoldController hold(VoidCallback holdCancelCallback) {
    beginActivity(
      HoldScrollActivity(
          delegate: _outerPosition, onHoldCanceled: holdCancelCallback),
      (_NestedScrollPosition position) =>
          HoldScrollActivity(delegate: position),
    );
    return this;
  }

  @override
  void cancel() {
    goBallistic(0.0);
  }

  Drag drag(DragStartDetails details, VoidCallback dragCancelCallback) {
    final ScrollDragController drag = ScrollDragController(
      delegate: this,
      details: details,
      onDragCanceled: dragCancelCallback,
    );
    beginActivity(
      DragScrollActivity(_outerPosition, drag),
      (_NestedScrollPosition position) => DragScrollActivity(position, drag),
    );
    assert(_currentDrag == null);
    _currentDrag = drag;
    return drag;
  }

  @override

  ///zmt
  void applyUserOffset(double delta) {
    updateUserScrollDirection(
        delta > 0.0 ? ScrollDirection.forward : ScrollDirection.reverse);
    assert(delta != 0.0);
    if (_innerPositions.isEmpty) {
      _outerPosition.applyFullDragUpdate(delta);
    } else if (delta < 0.0) {
      // dragging "up"
      // TODO(ianh): prioritize first getting rid of overscroll, and then the
      // outer view, so that the app bar will scroll out of the way asap.
      // Right now we ignore overscroll. This works fine on Android but looks
      // weird on iOS if you fling down then up. The problem is it's not at all
      // clear what this should do when you have multiple inner positions at
      // different levels of overscroll.
      final double innerDelta = _outerPosition.applyClampedDragUpdate(delta);

      ///this is a bug that the out postion is not overscroll actually and it get minimal value
      ///do under code will scroll inner positions
      ///so i igore  minimal value here(value like following data)
      ///  I/flutter (14963): 5.684341886080802e-14
      /// I/flutter (14963): -5.684341886080802e-14
      /// I/flutter (14963): -5.684341886080802e-14
      /// I/flutter (14963): 5.684341886080802e-14
      /// I/flutter (14963): -5.684341886080802e-14
      /// I/flutter (14963): -5.684341886080802e-14
      /// I/flutter (14963): -5.684341886080802e-14
      if (innerDelta != 0.0 && innerDelta.abs() > 0.0001) {
        for (_NestedScrollPosition position in _activedInnerPositions) {
          position.applyFullDragUpdate(innerDelta);
        }
      }
    } else {
      // dragging "down" - delta is positive
      // prioritize the inner views, so that the inner content will move before the app bar grows
      double outerDelta = 0.0; // it will go positive if it changes
      final List<double> overscrolls = <double>[];
      final List<_NestedScrollPosition> innerPositions =
          _activedInnerPositions.toList();
      for (_NestedScrollPosition position in innerPositions) {
        final double overscroll = position.applyClampedDragUpdate(delta);
        outerDelta = math.max(outerDelta, overscroll);
        overscrolls.add(overscroll);
      }
      if (outerDelta != 0.0)
        outerDelta -= _outerPosition.applyClampedDragUpdate(outerDelta);
      // now deal with any overscroll
      for (int i = 0; i < innerPositions.length; ++i) {
        final double remainingDelta = overscrolls[i] - outerDelta;
        if (remainingDelta > 0.0)
          innerPositions[i].applyFullDragUpdate(remainingDelta);
      }
    }
  }

  void setParent(ScrollController value) {
    _parent = value;
    updateParent();
  }

  void updateParent() {
    _outerPosition
        ?.setParent(_parent ?? PrimaryScrollController.of(_state.context));
  }

  @mustCallSuper
  void dispose() {
    _currentDrag?.dispose();
    _currentDrag = null;
    _outerController.dispose();
    _innerController.dispose();
  }

  @override
  String toString() =>
      '$runtimeType(outer=$_outerController; inner=$_innerController)';
}

class _NestedScrollController extends ScrollController {
  _NestedScrollController(
    this.coordinator, {
    double initialScrollOffset = 0.0,
    String debugLabel,
  }) : super(initialScrollOffset: initialScrollOffset, debugLabel: debugLabel);

  final _NestedScrollCoordinator coordinator;

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition oldPosition,
  ) {
    return _NestedScrollPosition(
      coordinator: coordinator,
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }

  @override
  void attach(ScrollPosition position) {
    assert(position is _NestedScrollPosition);
    super.attach(position);
    coordinator.updateParent();
    coordinator.updateCanDrag();
    position.addListener(_scheduleUpdateShadow);
    _scheduleUpdateShadow();
  }

  @override
  void detach(ScrollPosition position) {
    assert(position is _NestedScrollPosition);
    position.removeListener(_scheduleUpdateShadow);
    if (position is _NestedScrollPosition) {
      position._isActived = false;
    }
    super.detach(position);
    _scheduleUpdateShadow();
  }

  void _scheduleUpdateShadow() {
    // We do this asynchronously for attach() so that the new position has had
    // time to be initialized, and we do it asynchronously for detach() and from
    // the position change notifications because those happen synchronously
    // during a frame, at a time where it's too late to call setState. Since the
    // result is usually animated, the lag incurred is no big deal.
    SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
      coordinator.updateShadow();
    });
  }

  ///store page index
  Map<Key, int> _pageMetricsList = Map<Key, int>();

  ///zmt
  ///compute activated one when page changed
  void _computeActivatedNestedPosition(ScrollNotification notification) {
    final key = notification.context.widget.key;
    var page = _pageMetricsList[key];

    ///it's not an available
    if (page == -1) {
//      print(
//          "${this.runtimeType}: it's not available pageMetrics(no actived nested positions in it)");
      return;
    }

    final PageMetrics metrics = notification.metrics;
    final int currentPage = metrics.page.round();
    _pageMetricsList[key] = currentPage;

    //ComputeActivatedNestedPosition only when page changed
    if (page != currentPage) {
      ///if layout is not completed, the data will has some gap.
      ///need more accurate time to compute
      ///delay it in case.
      ///to do
      Future.delayed(const Duration(milliseconds: 150), () {
        var list = nestedPositions.toList();
        if (list.length > 1) {
          int activeCount = 0;
          int exceptionCount = 0;

          /// this is the page changed of PageView's renderBox,
          /// it maybe not the renderBox of [nestedPositions]
          /// because it maybe has more one tabbarview or pageview in NestedScrollView body
          final RenderBox pageChangedRenderBox =
              notification.context.findRenderObject();

          var activedItem = list.firstWhere((x) {
            return x._isActived;
          }, orElse: () => null);

          list.forEach((item) {
            if (item._computeActived(pageChangedRenderBox)) {
              exceptionCount++;
            }
            if (item._isActived) {
              activeCount++;
            }
          });

          if (activeCount != 1) {
            //use prePageChangedRenderBox try one more time.
            //no actived nested positions in it, it will throw expection for all of nested positions
            if (activeCount == 0 && exceptionCount == list.length) {
              ///it's not available pageMetrics(no actived nested positions in it)
              _pageMetricsList[key] = -1;

              ///reset actived
              if (activedItem != null) {
                activedItem._isActived = true;
              }
            } else {
              print(
                  "${this.runtimeType}: activeCount is $activeCount, please report to zmtzawqlp@live.com and show your case.");
            }
          } else {
            coordinator.updateCanDrag();
          }
        }
      });
    }
  }

  Iterable<_NestedScrollPosition> get nestedPositions sync* {
    // TODO(vegorov): use instance method version of castFrom when it is available.
    yield* Iterable.castFrom<ScrollPosition, _NestedScrollPosition>(positions);
  }
}

// The _NestedScrollPosition is used by both the inner and outer viewports of a
// NestedScrollView. It tracks the offset to use for those viewports, and knows
// about the _NestedScrollCoordinator, so that when activities are triggered on
// this class, they can defer, or be influenced by, the coordinator.
class _NestedScrollPosition extends ScrollPosition
    implements ScrollActivityDelegate {
  _NestedScrollPosition({
    @required ScrollPhysics physics,
    @required ScrollContext context,
    double initialPixels = 0.0,
    ScrollPosition oldPosition,
    String debugLabel,
    @required this.coordinator,
  }) : super(
          physics: physics,
          context: context,
          oldPosition: oldPosition,
          debugLabel: debugLabel,
        ) {
    if (pixels == null && initialPixels != null) correctPixels(initialPixels);
    if (activity == null) goIdle();
    assert(activity != null);
    saveScrollOffset(); // in case we didn't restore but could, so that we don't restore it later
  }

  final _NestedScrollCoordinator coordinator;

  TickerProvider get vsync => context.vsync;

  ScrollController _parent;

  void setParent(ScrollController value) {
    _parent?.detach(this);
    _parent = value;
    _parent?.attach(this);
  }

  ///whether it is actived
  bool _isActived = false;
  //RenderBox _renderBox;

  ///zmt
  ///whether it's actived in its' owner viewport
  bool _computeActived(RenderBox pageChangedRenderBox) {
    var context = (this.context as ScrollableState)?.context;
    try {
      if (context == null) {
        _isActived = false;
        //print("$scrollPositionKey $_isActived");
        return false;
      }
      final RenderBox renderBox = context.findRenderObject();

      if (renderBox == null) {
        _isActived = false;
        //print("$scrollPositionKey $_isActived");
        return false;
      }

      ///the nearest pageview/tabview
      final RenderBox parentRenderBox = _getParentPageViewRenderBox(context);

//      RenderAbstractViewport viewport = RenderAbstractViewport.of(renderBox);
//      RenderAbstractViewport viewport1 =
//          RenderAbstractViewport.of(pageChangedRenderBox);
//      RenderAbstractViewport viewport2 =
//          RenderAbstractViewport.of(parentRenderBox);

//      var test = viewport.getOffsetToReveal(renderBox, 0.0);
//      var test1 = viewport1.getOffsetToReveal(pageChangedRenderBox, 0.0);
//      var test2 = viewport2.getOffsetToReveal(parentRenderBox, 0.0);
//      print("$test $test1 $test2");
//
//      var test = viewport.getOffsetToReveal(renderBox, 0.0,
//          rect: viewport2.semanticBounds);

      _isActived = _childIsActivedInViewport(renderBox, pageChangedRenderBox) &&
          _childIsActivedInViewport(renderBox, parentRenderBox);

//      // just for test
//      var key = context.ancestorWidgetOfExactType(extend
//              .typeOf<extend.NestedScrollViewInnerScrollPositionKeyWidget>())
//          as extend.NestedScrollViewInnerScrollPositionKeyWidget;
//      scrollPositionKey = key?.scrollPositionKey;
//
//      print("$scrollPositionKey $_isActived");
      return false;
    } catch (e) {
      //print("${this.runtimeType}: $e");
      _isActived = false;
      //print("$scrollPositionKey $_isActived");
      return true;
    }
  }

  //Key scrollPositionKey;

  ///whether child is zero to parent
  bool _childIsActivedInViewport(RenderBox child, RenderBox parent) {
    Size parentSize = parent?.size ?? Size(0.0, 0.0);
    final Offset position = child.localToGlobal(Offset.zero, ancestor: parent);

    ///remove the margin/padding
    final Offset size = Offset(parentSize.width - child.size.width,
        parentSize.height - child.size.height);

    ///if layout is not completed, the data will has some gap.
    ///need more accurate time to compute
    ///to do
    bool childIsActivedInViewport = ((position.dx - size.dx).abs() < 1 &&
        (position.dy - size.dy).abs() < 1);
    return childIsActivedInViewport;
  }

  ///the nearest pageview/tabbarview
  RenderBox _getParentPageViewRenderBox(BuildContext context) {
    ScrollableState parent =
        context.ancestorStateOfType(TypeMatcher<ScrollableState>());
    if (parent == null) {
      return null;
    }

    ///find horizontal pageview/tabbarview
    if (parent.widget.controller is! PageController ||
        parent.widget.axis != Axis.horizontal) {
      return _getParentPageViewRenderBox(parent.context);
    }
    return parent.context.findRenderObject();
  }

  @override
  bool applyContentDimensions(double minScrollExtent, double maxScrollExtent) {
    if (debugLabel == 'outer') {
      if (coordinator._state.widget.pinnedHeaderSliverHeight != null) {
        maxScrollExtent = maxScrollExtent -
            coordinator._state.widget.pinnedHeaderSliverHeight;
        maxScrollExtent = math.max(0.0, maxScrollExtent);
      } else if (coordinator._state.widget.pinnedHeaderSliverHeightBuilder !=
          null) {
        maxScrollExtent = maxScrollExtent -
            coordinator._state.widget.pinnedHeaderSliverHeightBuilder();

        maxScrollExtent = math.max(0.0, maxScrollExtent);
      }
    }
    return super.applyContentDimensions(minScrollExtent, maxScrollExtent);
  }

  @override
  AxisDirection get axisDirection => context.axisDirection;

  @override
  void absorb(ScrollPosition other) {
    super.absorb(other);
    activity.updateDelegate(this);
  }

  @override
  void restoreScrollOffset() {
    if (coordinator.canScrollBody) super.restoreScrollOffset();
  }

  // Returns the amount of delta that was not used.
  //
  // Positive delta means going down (exposing stuff above), negative delta
  // going up (exposing stuff below).
  double applyClampedDragUpdate(double delta) {
    assert(delta != 0.0);
    // If we are going towards the maxScrollExtent (negative scroll offset),
    // then the furthest we can be in the minScrollExtent direction is negative
    // infinity. For example, if we are already overscrolled, then scrolling to
    // reduce the overscroll should not disallow the overscroll.
    //
    // If we are going towards the minScrollExtent (positive scroll offset),
    // then the furthest we can be in the minScrollExtent direction is wherever
    // we are now, if we are already overscrolled (in which case pixels is less
    // than the minScrollExtent), or the minScrollExtent if we are not.
    //
    // In other words, we cannot, via applyClampedDragUpdate, _enter_ an
    // overscroll situation.
    //
    // An overscroll situation might be nonetheless entered via several means.
    // One is if the physics allow it, via applyFullDragUpdate (see below). An
    // overscroll situation can also be forced, e.g. if the scroll position is
    // artificially set using the scroll controller.
    final double min =
        delta < 0.0 ? -double.infinity : math.min(minScrollExtent, pixels);
    // The logic for max is equivalent but on the other side.
    final double max =
        delta > 0.0 ? double.infinity : math.max(maxScrollExtent, pixels);
    final double oldPixels = pixels;
    final double newPixels = (pixels - delta).clamp(min, max);
    final double clampedDelta = newPixels - pixels;
    if (clampedDelta == 0.0) return delta;
    final double overscroll = physics.applyBoundaryConditions(this, newPixels);
    final double actualNewPixels = newPixels - overscroll;
    final double offset = actualNewPixels - oldPixels;
    if (offset != 0.0) {
      forcePixels(actualNewPixels);
      didUpdateScrollPositionBy(offset);
    }
    return delta + offset;
  }

  // Returns the overscroll.
  double applyFullDragUpdate(double delta) {
    assert(delta != 0.0);
    final double oldPixels = pixels;
    // Apply friction:
    final double newPixels =
        pixels - physics.applyPhysicsToUserOffset(this, delta);
    if (oldPixels == newPixels)
      return 0.0; // delta must have been so small we dropped it during floating point addition
    // Check for overscroll:
    final double overscroll = physics.applyBoundaryConditions(this, newPixels);
    final double actualNewPixels = newPixels - overscroll;
    if (actualNewPixels != oldPixels) {
      forcePixels(actualNewPixels);
      didUpdateScrollPositionBy(actualNewPixels - oldPixels);
    }
    if (overscroll != 0.0) {
      didOverscrollBy(overscroll);
      return overscroll;
    }
    return 0.0;
  }

  @override
  ScrollDirection get userScrollDirection => coordinator.userScrollDirection;

  DrivenScrollActivity createDrivenScrollActivity(
      double to, Duration duration, Curve curve) {
    return DrivenScrollActivity(
      this,
      from: pixels,
      to: to,
      duration: duration,
      curve: curve,
      vsync: vsync,
    );
  }

  @override
  double applyUserOffset(double delta) {
    assert(false);
    return 0.0;
  }

  // This is called by activities when they finish their work.
  @override
  void goIdle() {
    beginActivity(IdleScrollActivity(this));
  }

  // This is called by activities when they finish their work and want to go ballistic.
  @override
  void goBallistic(double velocity) {
    Simulation simulation;
    if (velocity != 0.0 || outOfRange)
      simulation = physics.createBallisticSimulation(this, velocity);
    beginActivity(createBallisticScrollActivity(
      simulation,
      mode: _NestedBallisticScrollActivityMode.independent,
    ));
  }

  ScrollActivity createBallisticScrollActivity(
    Simulation simulation, {
    @required _NestedBallisticScrollActivityMode mode,
    _NestedScrollMetrics metrics,
  }) {
    if (simulation == null) return IdleScrollActivity(this);
    assert(mode != null);
    switch (mode) {
      case _NestedBallisticScrollActivityMode.outer:
        assert(metrics != null);
        if (metrics.minRange == metrics.maxRange)
          return IdleScrollActivity(this);
        return _NestedOuterBallisticScrollActivity(
            coordinator, this, metrics, simulation, context.vsync);
      case _NestedBallisticScrollActivityMode.inner:
        return _NestedInnerBallisticScrollActivity(
            coordinator, this, simulation, context.vsync);
      case _NestedBallisticScrollActivityMode.independent:
        return BallisticScrollActivity(this, simulation, context.vsync);
    }
    return null;
  }

  @override
  Future<void> animateTo(
    double to, {
    @required Duration duration,
    @required Curve curve,
  }) {
    return coordinator.animateTo(coordinator.unnestOffset(to, this),
        duration: duration, curve: curve);
  }

  @override
  void jumpTo(double value) {
    return coordinator.jumpTo(coordinator.unnestOffset(value, this));
  }

  @override
  void jumpToWithoutSettling(double value) {
    assert(false);
  }

  void localJumpTo(double value) {
    if (pixels != value) {
      final double oldPixels = pixels;
      forcePixels(value);
      didStartScroll();
      didUpdateScrollPositionBy(pixels - oldPixels);
      didEndScroll();
    }
  }

  @override
  void applyNewDimensions() {
    super.applyNewDimensions();
    coordinator.updateCanDrag();
  }

  void updateCanDrag(double totalExtent) {
    context.setCanDrag(totalExtent > (viewportDimension - maxScrollExtent) ||
        minScrollExtent != maxScrollExtent);
  }

  @override
  ScrollHoldController hold(VoidCallback holdCancelCallback) {
    return coordinator.hold(holdCancelCallback);
  }

  @override
  Drag drag(DragStartDetails details, VoidCallback dragCancelCallback) {
    return coordinator.drag(details, dragCancelCallback);
  }

  @override
  void dispose() {
    _parent?.detach(this);
    super.dispose();
  }
}

enum _NestedBallisticScrollActivityMode { outer, inner, independent }

class _NestedInnerBallisticScrollActivity extends BallisticScrollActivity {
  _NestedInnerBallisticScrollActivity(
    this.coordinator,
    _NestedScrollPosition position,
    Simulation simulation,
    TickerProvider vsync,
  ) : super(position, simulation, vsync);

  final _NestedScrollCoordinator coordinator;

  @override
  _NestedScrollPosition get delegate => super.delegate;

  @override
  void resetActivity() {
    delegate.beginActivity(
        coordinator.createInnerBallisticScrollActivity(delegate, velocity));
  }

  @override
  void applyNewDimensions() {
    delegate.beginActivity(
        coordinator.createInnerBallisticScrollActivity(delegate, velocity));
  }

  @override
  bool applyMoveTo(double value) {
    return super.applyMoveTo(coordinator.nestOffset(value, delegate));
  }
}

class _NestedOuterBallisticScrollActivity extends BallisticScrollActivity {
  _NestedOuterBallisticScrollActivity(
    this.coordinator,
    _NestedScrollPosition position,
    this.metrics,
    Simulation simulation,
    TickerProvider vsync,
  )   : assert(metrics.minRange != metrics.maxRange),
        assert(metrics.maxRange > metrics.minRange),
        super(position, simulation, vsync);

  final _NestedScrollCoordinator coordinator;
  final _NestedScrollMetrics metrics;

  @override
  _NestedScrollPosition get delegate => super.delegate;

  @override
  void resetActivity() {
    delegate.beginActivity(
        coordinator.createOuterBallisticScrollActivity(velocity));
  }

  @override
  void applyNewDimensions() {
    delegate.beginActivity(
        coordinator.createOuterBallisticScrollActivity(velocity));
  }

  @override
  bool applyMoveTo(double value) {
    bool done = false;
    if (velocity > 0.0) {
      if (value < metrics.minRange) return true;
      if (value > metrics.maxRange) {
        value = metrics.maxRange;
        done = true;
      }
    } else if (velocity < 0.0) {
      if (value > metrics.maxRange) return true;
      if (value < metrics.minRange) {
        value = metrics.minRange;
        done = true;
      }
    } else {
      value = value.clamp(metrics.minRange, metrics.maxRange);
      done = true;
    }
    final bool result = super.applyMoveTo(value + metrics.correctionOffset);
    assert(
        result); // since we tried to pass an in-range value, it shouldn't ever overflow
    return !done;
  }

  @override
  String toString() {
    return '$runtimeType(${metrics.minRange} .. ${metrics.maxRange}; correcting by ${metrics.correctionOffset})';
  }
}
