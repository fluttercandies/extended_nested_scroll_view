## 2.0.0-dev

* Fix Null check operator used on a null value
## 2.0.0

* Breaking change: add clipBehavior and restorationId
* Merge flutter/issues/29264(SliverAppBar's flexibleSpace glitch on iOS when NestedScrollView's body is a ScrollView)

## 1.0.1

* Merge flutter/flutter#59187(Support floating the header slivers of a NestedScrollView)

## 1.0.0

* Merge code from 1.17.0
* Fix analysis_options

## 0.4.1

* add demo to show how to change pinned header height dynamically.

## 0.4.0

* web support

## 0.3.8

* add NestedScrollViewState key to get currentInnerPosition/innerScrollPositions instead of ScrollController
* due to we can't set ScrollController for list in NestedScrollView's body(it will breaking behaviours of InnerScrollController in NestedScrollView), provide demos('PullToRefresh','LoadMore' and 'ScrollToTop') to show how to do it without ScrollController

## 0.3.6

* fix api error base on Flutter SDK v1.7.8+hotfix.2

## 0.3.5

* New ExtendedNestedScrollView still has some issues in special layout, make it as obsolete for now till find a better solution

## 0.3.3

* fix issue that Caught error: type 'Future<void>' is not a subtype of type 'Future<Null>'
 for old extended_nested_scroll_view

## 0.2.9

* fix issue 0.2.5 for old extended_nested_scroll_view

## 0.2.7

* fix issue for quick change page
* handle unavailable page change(no actived nested positions in it)

## 0.2.5

* fix issue that ut postion is not overscroll actually,it get minimal value
  and will scroll inner positions
  igore  minimal value here(value like following data)
  /// I/flutter (14963): 5.684341886080802e-14
  /// I/flutter (14963): -5.684341886080802e-14
  if (innerDelta != 0.0 && innerDelta.abs() > 0.0001) {
  for (_NestedScrollPosition position in _activedInnerPositions) {
        position.applyFullDragUpdate(innerDelta);
     }
   }

## 0.2.0

* update new extended_nested_scroll_view demo

## 0.1.9

* set keepOnlyOneInnerNestedScrollPositionActive default value: false

## 0.1.8

* update new ExtendedNestedScrollView readme

## 0.1.7

* add assert for keepOnlyOneInnerNestedScrollPositionActive
    ///when ExtendedNestedScrollView body has TabBarView/PageView and children have
    ///AutomaticKeepAliveClientMixin or PageStorageKey,
    ///_innerController.nestedPositions will have more one,
    ///when you scroll, it will scroll all of nestedPositions
    ///set keepOnlyOneInnerNestedScrollPositionActive true to avoid it.
    ///notice: only for Axis.horizontal TabBarView/PageView and
    ///scrollDirection must be Axis.vertical.
assert(!(widget.keepOnlyOneInnerNestedScrollPositionActive && widget.scrollDirection == Axis.horizontal));

## 0.1.6

* fix issue: Actived _NestedScrollPosition is not right for multiple

## 0.1.5

* add new ExtendedNestedScrollView to slove issue more smartly.

## 0.1.4

* Update readme.

## 0.1.3

* Update demo.

## 0.1.2

* Remove unused method.

## 0.1.1

* Update demo.

## 0.1.0

* Upgrade Some Commments.

## 0.0.1

* Initial Open Source release.
