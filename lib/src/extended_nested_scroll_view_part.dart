part of 'extended_nested_scroll_view.dart';

/// It may be include statusBarHeight ,pinned appbar height,pinned SliverPersistentHeader height
/// which are in NestedScrollViewHeaderSlivers
typedef NestedScrollViewPinnedHeaderSliverHeightBuilder = double Function();

// Custom Overscroll Handler
enum OverscrollHandler { inner, outer }

class _ExtendedNestedScrollCoordinator extends _NestedScrollCoordinator {
  _ExtendedNestedScrollCoordinator(
    ExtendedNestedScrollViewState state,
    ScrollController? parent,
    VoidCallback onHasScrolledBodyChanged,
    bool floatHeaderSlivers,
    this.pinnedHeaderSliverHeightBuilder,
    this.onlyOneScrollInBody,
    this.scrollDirection,
  ) : super(
          state,
          parent,
          onHasScrolledBodyChanged,
          floatHeaderSlivers,
        ) {
    final double initialScrollOffset = _parent?.initialScrollOffset ?? 0.0;
    _outerController = _ExtendedNestedScrollController(
      this,
      initialScrollOffset: initialScrollOffset,
      debugLabel: 'outer',
    );
    _innerController = _ExtendedNestedScrollController(
      this,
      initialScrollOffset: 0.0,
      debugLabel: 'inner',
    );
  }

  /// Get the total height of pinned header in NestedScrollView header.

  final NestedScrollViewPinnedHeaderSliverHeightBuilder?
      pinnedHeaderSliverHeightBuilder;

  /// When [ExtendedNestedScrollView]'s body has [TabBarView]/[PageView] and
  /// their children have AutomaticKeepAliveClientMixin or PageStorageKey,
  /// [_innerController.nestedPositions] will have more one,
  /// will scroll all of scroll positions together.
  /// set [onlyOneScrollInBody] true to avoid it.

  final bool onlyOneScrollInBody;

  /// The axis along which the scroll view scrolls.
  ///
  /// Defaults to [Axis.vertical].
  final Axis scrollDirection;

  @override
  _ExtendedNestedScrollController get _innerController =>
      super._innerController as _ExtendedNestedScrollController;

  /// The [TabBarView]/[PageView] in body should perpendicular with The Axis of
  /// [ExtendedNestedScrollView].
  Axis get bodyScrollDirection =>
      scrollDirection == Axis.vertical ? Axis.horizontal : Axis.vertical;

  @override
  Iterable<_ExtendedNestedScrollPosition> get _innerPositions {
    if (_innerController.nestedPositions.length > 1 && onlyOneScrollInBody) {
      final Iterable<_ExtendedNestedScrollPosition> actived = _innerController
          .nestedPositions
          .where((_ExtendedNestedScrollPosition element) => element.isActived);
      if (actived.isEmpty) {
        for (final _ExtendedNestedScrollPosition scrollPosition
            in _innerController.nestedPositions) {
          // TODO(zmtzawqlp): throw exception even mounted is true
          // In order for an element to have a valid renderObject, it must be '
          //  'active, which means it is part of the tree.\n'
          //  'Instead, this element is in the $_lifecycleState state.\n'
          //  'If you called this method from a State object, consider guarding '
          //  'it with State.mounted.
          try {
            if (!(scrollPosition.context as ScrollableState).mounted) {
              continue;
            }
            final RenderObject? renderObject =
                scrollPosition.context.storageContext.findRenderObject();
            if (renderObject == null || !renderObject.attached) {
              continue;
            }

            final VisibilityInfo? visibilityInfo =
                ExtendedVisibilityDetector.of(
                    scrollPosition.context.storageContext);
            if (visibilityInfo != null && visibilityInfo.visibleFraction == 1) {
              if (kDebugMode) {
                print('${visibilityInfo.key} is visible');
              }
              return <_ExtendedNestedScrollPosition>[scrollPosition];
            }

            if (renderObjectIsVisible(renderObject, bodyScrollDirection)) {
              return <_ExtendedNestedScrollPosition>[scrollPosition];
            }
          } catch (e) {
            continue;
          }
        }
        return _innerController.nestedPositions;
      }

      return actived;
    } else {
      return _innerController.nestedPositions;
    }
  }

  /// Return whether renderObject is visible in parent
  bool childIsVisible(
    RenderObject parent,
    RenderObject renderObject,
  ) {
    bool visible = false;

    // The implementation has to return the children in paint order skipping all
    // children that are not semantically relevant (e.g. because they are
    // invisible).
    parent.visitChildrenForSemantics((RenderObject child) {
      if (renderObject == child) {
        visible = true;
      } else {
        visible = childIsVisible(child, renderObject);
      }
    });
    return visible;
  }

  bool renderObjectIsVisible(RenderObject renderObject, Axis axis) {
    final RenderViewport? parent = findParentRenderViewport(renderObject);
    if (parent != null && parent.axis == axis) {
      for (final RenderSliver childrenInPaint
          in parent.childrenInHitTestOrder) {
        return childIsVisible(childrenInPaint, renderObject) &&
            renderObjectIsVisible(parent, axis);
      }
    }
    return true;
  }

  RenderViewport? findParentRenderViewport(RenderObject? object) {
    if (object == null) {
      return null;
    }
    object = object.parent as RenderObject?;
    while (object != null) {
      // only find in body
      if (object is _ExtendedRenderSliverFillRemainingWithScrollable) {
        return null;
      }
      if (object is RenderViewport) {
        return object;
      }
      object = object.parent as RenderObject?;
    }
    return null;
  }

  @override
  void updateCanDrag({_NestedScrollPosition? position}) {
    double maxInnerExtent = 0.0;

    if (onlyOneScrollInBody &&
        position != null &&
        position.debugLabel == 'inner') {
      if (position.haveDimensions) {
        maxInnerExtent = math.max(
          maxInnerExtent,
          position.maxScrollExtent - position.minScrollExtent,
        );
        position.updateCanDrag(maxInnerExtent);
      }
    }
    if (!_outerPosition!.haveDimensions) {
      return;
    }

    for (final _NestedScrollPosition position in _innerPositions) {
      if (!position.haveDimensions) {
        return;
      }
      maxInnerExtent = math.max(
        maxInnerExtent,
        position.maxScrollExtent - position.minScrollExtent,
      );
    }
    _outerPosition!.updateCanDrag(maxInnerExtent);
  }
}

class _ExtendedNestedScrollCoordinatorOuter
    extends _ExtendedNestedScrollCoordinator {
  _ExtendedNestedScrollCoordinatorOuter(
    ExtendedNestedScrollViewState state,
    ScrollController? parent,
    VoidCallback onHasScrolledBodyChanged,
    bool floatHeaderSlivers,
    NestedScrollViewPinnedHeaderSliverHeightBuilder?
        pinnedHeaderSliverHeightBuilder,
    bool onlyOneScrollInBody,
    Axis scrollDirection,
  ) : super(
          state,
          parent,
          onHasScrolledBodyChanged,
          floatHeaderSlivers,
          pinnedHeaderSliverHeightBuilder,
          onlyOneScrollInBody,
          scrollDirection,
        ) {
    final double initialScrollOffset = _parent?.initialScrollOffset ?? 0.0;
    _outerController = _ExtendedNestedScrollControllerOuter(
      this,
      initialScrollOffset: initialScrollOffset,
      debugLabel: 'outer',
    );
    _innerController = _ExtendedNestedScrollControllerOuter(
      this,
      initialScrollOffset: 0.0,
      debugLabel: 'inner',
    );
  }

  @override
  _NestedScrollMetrics _getMetrics(
      _NestedScrollPosition innerPosition, double velocity) {
    return _NestedScrollMetrics(
      minScrollExtent: _outerPosition!.minScrollExtent,
      maxScrollExtent: _outerPosition!.maxScrollExtent +
          (innerPosition.maxScrollExtent - innerPosition.minScrollExtent),
      pixels: unnestOffset(innerPosition.pixels, innerPosition),
      viewportDimension: _outerPosition!.viewportDimension,
      axisDirection: _outerPosition!.axisDirection,
      minRange: 0,
      maxRange: 0,
      correctionOffset: 0,
      devicePixelRatio: _outerPosition!.devicePixelRatio,
    );
  }

  /// in/out -> coordinator
  @override
  double unnestOffset(double value, _NestedScrollPosition source) {
    if (source == _outerPosition) {
      return value;
    } else {
      if (_outerPosition!.maxScrollExtent - _outerPosition!.pixels >
          precisionErrorTolerance) {
        ///outer在滚动，以outer位置为基准
        return _outerPosition!.pixels;
      }
      return _outerPosition!.maxScrollExtent + (value - source.minScrollExtent);
    }
  }

  /// coordinator -> in/out
  @override
  double nestOffset(double value, _NestedScrollPosition target) {
    if (target == _outerPosition) {
      if (value > _outerPosition!.maxScrollExtent) {
        //不允许outer底部overscroll
        return _outerPosition!.maxScrollExtent;
      }
      return value;
    } else {
      if (value < _outerPosition!.maxScrollExtent) {
        //不允许inner顶部overscroll
        return target.minScrollExtent;
      }
      return target.minScrollExtent + (value - _outerPosition!.maxScrollExtent);
    }
  }

  @override
  void applyUserOffset(double delta) {
    updateUserScrollDirection(
        delta > 0.0 ? ScrollDirection.forward : ScrollDirection.reverse);
    if (_innerPositions.isEmpty) {
      _outerPosition!.applyFullDragUpdate(delta);
    } else if (delta < 0.0) {
      double outerDelta = delta;
      for (final _NestedScrollPosition position in _innerPositions) {
        if (position.pixels < position.minScrollExtent) {
          final double potentialOuterDelta =
              position.applyClampedDragUpdate(delta);
          if (potentialOuterDelta < 0) {
            outerDelta = math.max(outerDelta, potentialOuterDelta);
          }
        }
      }
      if (outerDelta != 0.0) {
        final double innerDelta = _outerPosition!.applyClampedDragUpdate(
          outerDelta,
        );
        if (innerDelta != 0.0) {
          for (final _NestedScrollPosition position in _innerPositions)
            position.applyFullDragUpdate(innerDelta);
        }
      }
    } else {
      double innerDelta = delta;
      if (_floatHeaderSlivers) {
        innerDelta = _outerPosition!.applyClampedDragUpdate(delta);
      }
      if (innerDelta != 0.0) {
        double outerDelta = 0.0;
        for (final _NestedScrollPosition position in _innerPositions) {
          final double overscroll = position.applyClampedDragUpdate(innerDelta);
          if (overscroll > 0) {
            outerDelta = math.max(outerDelta, overscroll);
          }
        }
        if (outerDelta != 0.0) {
          _outerPosition!.applyFullDragUpdate(outerDelta);
        }
      }
    }
  }
}

class _ExtendedNestedScrollController extends _NestedScrollController {
  _ExtendedNestedScrollController(
    _ExtendedNestedScrollCoordinator coordinator, {
    double initialScrollOffset = 0.0,
    String? debugLabel,
  }) : super(
          coordinator,
          initialScrollOffset: initialScrollOffset,
          debugLabel: debugLabel,
        );
  @override
  _ExtendedNestedScrollCoordinator get coordinator =>
      super.coordinator as _ExtendedNestedScrollCoordinator;

  @override
  Iterable<_ExtendedNestedScrollPosition> get nestedPositions =>
      kDebugMode ? _debugNestedPositions : _releaseNestedPositions;

  Iterable<_ExtendedNestedScrollPosition> get _debugNestedPositions {
    return Iterable.castFrom<ScrollPosition, _ExtendedNestedScrollPosition>(
        positions);
  }

  Iterable<_ExtendedNestedScrollPosition> get _releaseNestedPositions sync* {
    yield* Iterable.castFrom<ScrollPosition, _ExtendedNestedScrollPosition>(
        positions);
  }

  @override
  void attach(ScrollPosition position) {
    assert(position is _NestedScrollPosition);
    super.attach(position);
    coordinator.updateParent();
    coordinator.updateCanDrag(position: position as _NestedScrollPosition);
    position.addListener(_scheduleUpdateShadow);
    _scheduleUpdateShadow();
  }

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return _ExtendedNestedScrollPosition(
      coordinator: coordinator,
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }
}

class _ExtendedNestedScrollControllerOuter
    extends _ExtendedNestedScrollController {
  _ExtendedNestedScrollControllerOuter(
    _ExtendedNestedScrollCoordinator coordinator, {
    double initialScrollOffset = 0.0,
    String? debugLabel,
  }) : super(
          coordinator,
          initialScrollOffset: initialScrollOffset,
          debugLabel: debugLabel,
        );

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return _ExtendedNestedScrollPositionOuter(
      coordinator: coordinator,
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }
}

class _ExtendedNestedScrollPositionOuter extends _ExtendedNestedScrollPosition {
  _ExtendedNestedScrollPositionOuter({
    required ScrollPhysics physics,
    required ScrollContext context,
    double initialPixels = 0.0,
    ScrollPosition? oldPosition,
    String? debugLabel,
    required _ExtendedNestedScrollCoordinator coordinator,
  }) : super(
            physics: physics,
            context: context,
            initialPixels: initialPixels,
            oldPosition: oldPosition,
            debugLabel: debugLabel,
            coordinator: coordinator);

  @override
  ScrollActivity createBallisticScrollActivity(
    Simulation? simulation, {
    required _NestedBallisticScrollActivityMode mode,
    _NestedScrollMetrics? metrics,
  }) {
    if (simulation == null) {
      return IdleScrollActivity(this);
    }
    switch (mode) {
      case _NestedBallisticScrollActivityMode.outer:
        return _NestedOuterBallisticScrollActivityX(
          coordinator,
          this,
          simulation,
          context.vsync,
          activity?.shouldIgnorePointer ?? true,
        );
      case _NestedBallisticScrollActivityMode.inner:
        return _NestedInnerBallisticScrollActivityX(
          coordinator,
          this,
          simulation,
          context.vsync,
          activity?.shouldIgnorePointer ?? true,
        );
      case _NestedBallisticScrollActivityMode.independent:
        return BallisticScrollActivity(this, simulation, context.vsync,
            activity?.shouldIgnorePointer ?? true);
    }
  }
}

class _NestedBallisticScrollActivityX extends BallisticScrollActivity {
  _NestedBallisticScrollActivityX(
    this.coordinator,
    _NestedScrollPosition position,
    Simulation simulation,
    TickerProvider vsync,
    bool shouldIgnorePointer,
  ) : super(position, simulation, vsync, shouldIgnorePointer);

  final _NestedScrollCoordinator coordinator;

  @override
  _NestedScrollPosition get delegate => super.delegate as _NestedScrollPosition;

  @override
  void resetActivity() {
    assert(false);
  }

  @override
  void applyNewDimensions() {
    assert(false);
  }

  @override
  bool applyMoveTo(double value) {
    return super.applyMoveTo(coordinator.nestOffset(value, delegate));
  }
}

class _NestedOuterBallisticScrollActivityX
    extends _NestedBallisticScrollActivityX {
  _NestedOuterBallisticScrollActivityX(
    _NestedScrollCoordinator coordinator,
    _NestedScrollPosition position,
    Simulation simulation,
    TickerProvider vsync,
    bool shouldIgnorePointer,
  ) : super(coordinator, position, simulation, vsync, shouldIgnorePointer);

  @override
  void resetActivity() {
    delegate.beginActivity(coordinator.createOuterBallisticScrollActivity(
      velocity,
    ));
  }

  @override
  void applyNewDimensions() {
    delegate.beginActivity(coordinator.createOuterBallisticScrollActivity(
      velocity,
    ));
  }
}

class _NestedInnerBallisticScrollActivityX
    extends _NestedBallisticScrollActivityX {
  _NestedInnerBallisticScrollActivityX(
    _NestedScrollCoordinator coordinator,
    _NestedScrollPosition position,
    Simulation simulation,
    TickerProvider vsync,
    bool shouldIgnorePointer,
  ) : super(coordinator, position, simulation, vsync, shouldIgnorePointer);

  @override
  void resetActivity() {
    delegate.beginActivity(coordinator.createInnerBallisticScrollActivity(
      delegate,
      velocity,
    ));
  }

  @override
  void applyNewDimensions() {
    delegate.beginActivity(coordinator.createInnerBallisticScrollActivity(
      delegate,
      velocity,
    ));
  }
}

class _ExtendedNestedScrollPosition extends _NestedScrollPosition {
  _ExtendedNestedScrollPosition({
    required ScrollPhysics physics,
    required ScrollContext context,
    double initialPixels = 0.0,
    ScrollPosition? oldPosition,
    String? debugLabel,
    required _ExtendedNestedScrollCoordinator coordinator,
  }) : super(
          physics: physics,
          context: context,
          oldPosition: oldPosition,
          debugLabel: debugLabel,
          coordinator: coordinator,
          initialPixels: initialPixels,
        );
  @override
  _ExtendedNestedScrollCoordinator get coordinator =>
      super.coordinator as _ExtendedNestedScrollCoordinator;

  @override
  void applyNewDimensions() {
    super.applyNewDimensions();
    coordinator.updateCanDrag(position: this);
  }

  @override
  bool applyContentDimensions(double minScrollExtent, double maxScrollExtent) {
    if (debugLabel == 'outer' &&
        coordinator.pinnedHeaderSliverHeightBuilder != null) {
      maxScrollExtent =
          maxScrollExtent - coordinator.pinnedHeaderSliverHeightBuilder!();
      maxScrollExtent = math.max(0.0, maxScrollExtent);
    }
    return super.applyContentDimensions(minScrollExtent, maxScrollExtent);
  }

  bool _isActived = false;
  @override
  Drag drag(DragStartDetails details, VoidCallback dragCancelCallback) {
    //print('drag--$debugLabel');
    _isActived = true;
    return coordinator.drag(details, () {
      dragCancelCallback();
      _isActived = false;
      //print('dragCancel--$debugLabel');
    });
  }

  /// Whether is actived now
  bool get isActived {
    return _isActived;
  }
}

class _ExtendedSliverFillRemainingWithScrollable
    extends SingleChildRenderObjectWidget {
  const _ExtendedSliverFillRemainingWithScrollable({
    Key? key,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  _ExtendedRenderSliverFillRemainingWithScrollable createRenderObject(
          BuildContext context) =>
      _ExtendedRenderSliverFillRemainingWithScrollable();
}

class _ExtendedRenderSliverFillRemainingWithScrollable
    extends RenderSliverFillRemainingWithScrollable {}

// this is a bug that the out postion is not overscroll actually and it get minimal value
// do under code will scroll inner positions
// igore minimal value here(value like following data)
// I/flutter (14963): 5.684341886080802e-14
// I/flutter (14963): -5.684341886080802e-14
// I/flutter (14963): -5.684341886080802e-14
// I/flutter (14963): 5.684341886080802e-14
// I/flutter (14963): -5.684341886080802e-14
// I/flutter (14963): -5.684341886080802e-14
// I/flutter (14963): -5.684341886080802e-14
extension DoubleEx on double {
  bool get notZero => abs() > precisionErrorTolerance;
  bool get isZero => abs() < precisionErrorTolerance;
}

class _ExtendedNestedInnerBallisticScrollActivity
    extends _NestedInnerBallisticScrollActivity {
  _ExtendedNestedInnerBallisticScrollActivity(
    super.coordinator,
    super.position,
    super.simulation,
    super.vsync,
    super.shouldIgnorePointer,
  );
  @override
  bool applyMoveTo(double value) {
    // https://github.com/flutter/flutter/pull/87801
    return delegate.setPixels(coordinator.nestOffset(value, delegate)).isZero;
  }
}
