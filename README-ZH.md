# extended_nested_scroll_view

[![pub package](https://img.shields.io/pub/v/extended_nested_scroll_view.svg)](https://pub.dartlang.org/packages/extended_nested_scroll_view) [![GitHub stars](https://img.shields.io/github/stars/fluttercandies/extended_nested_scroll_view)](https://github.com/fluttercandies/extended_nested_scroll_view/stargazers) [![GitHub forks](https://img.shields.io/github/forks/fluttercandies/extended_nested_scroll_view)](https://github.com/fluttercandies/extended_nested_scroll_view/network)  [![GitHub license](https://img.shields.io/github/license/fluttercandies/extended_nested_scroll_view)](https://github.com/fluttercandies/extended_nested_scroll_view/blob/master/LICENSE)  [![GitHub issues](https://img.shields.io/github/issues/fluttercandies/extended_nested_scroll_view)](https://github.com/fluttercandies/extended_nested_scroll_view/issues) <a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="flutter-candies" title="flutter-candies"></a>

文档语言: [English](README.md) | [中文简体](README-ZH.md)

扩展NestedScrollView来修复了下面的问题

1.[pinned的Header的问题](https://github.com/flutter/flutter/issues/22393)

2.[body里面TabView列表滚动同步，互相影响的问题](https://github.com/flutter/flutter/issues/21868)

3.下拉刷新不能工作

4.在NestedScrollView中不通过设置ScrollController来完成下拉刷新，增量加载，滚动到顶部

[掘金](https://juejin.im/post/5bea43ade51d45544844010a)

- [extended_nested_scroll_view](#extendednestedscrollview)
- [Example for issue 1](#example-for-issue-1)
- [Example for issue 2](#example-for-issue-2)
  - [步骤1](#%e6%ad%a5%e9%aa%a41)
  - [步骤2](#%e6%ad%a5%e9%aa%a42)
- [Example for NestedScrollView pull to refresh](#example-for-nestedscrollview-pull-to-refresh)
- [Do without ScrollController in NestedScrollView's body](#do-without-scrollcontroller-in-nestedscrollviews-body)
# Example for issue 1

 在pinnedHeaderSliverHeightBuilder回调中设置全部pinned的header的高度，
 demo里面高度为 状态栏高度+SliverAppbar的高度
``` dart
 var tabBarHeight = primaryTabBar.preferredSize.height;
      var pinnedHeaderHeight =
          //statusBar height
          statusBarHeight +
              //pinned SliverAppBar height in header
              kToolbarHeight;

 return NestedScrollView(
        pinnedHeaderSliverHeightBuilder: () {
          return pinnedHeaderHeight;
        },
       
```
# Example for issue 2

## 步骤1

TabbarView里面的列表，使用NestedScrollViewInnerScrollPositionKeyWidget包住，并且设置唯一key，
这个key跟列表是第几个tab有关系。
``` dart
 return extended.NestedScrollViewInnerScrollPositionKeyWidget(
        widget.tabKey,
        ListView.builder(
            itemBuilder: (c, i) {
              return Container(
                alignment: Alignment.center,
                height: 60.0,
                child: Text(widget.tabKey.toString() + ": List$i"),
              );
            },
            itemCount: 100)
        );
```
## 步骤2

innerScrollPositionKeyBuilder回调中给出当前tab的key. 这个key应该跟第一步中相同
``` dart
 extended.NestedScrollView(
        innerScrollPositionKeyBuilder: () {
          var index = "Tab";
          if (primaryTC.index == 0) {
            index +=
                (primaryTC.index.toString() + secondaryTC.index.toString());
          } else {
            index += primaryTC.index.toString();
          }
          return Key(index);
        },
```
# Example for NestedScrollView pull to refresh

NestedScrollViewRefreshIndicator is as the same as Flutter RefreshIndicator.
``` dart
 NestedScrollViewRefreshIndicator(
       onRefresh: onRefresh,
       child: extended.NestedScrollView(
         headerSliverBuilder: (c, f) {
           return _buildSliverHeader(primaryTabBar);
         },
```

[建议使用这个来做NestedScrollView的整体下拉刷新](https://github.com/fluttercandies/loading_more_list/blob/master/example/lib/demo/nested_scroll_view_demo.dart)

Please see the example app of this for a full example.

# Do without ScrollController in NestedScrollView's body

因为无法给NestedScrollView的body中的列表设置ScrollController(这样会破坏NestedScrollView内部的InnerScrollController的行为)，所以我这里给大家提供了Demos来展示怎么不通过ScrollController来完成

* [下拉刷新](https://github.com/fluttercandies/extended_nested_scroll_view/tree/master/example/lib/pages/pull_to_refresh.dart),
  
* [增量加载](https://github.com/fluttercandies/extended_nested_scroll_view/tree/master/example/lib/pages/load_more.dart) 
  
* [滚动到顶部](https://github.com/fluttercandies/extended_nested_scroll_view/tree/master/example/lib/pages/scroll_to_top.dart) 

