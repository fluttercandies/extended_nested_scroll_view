# extended_nested_scroll_view

[![pub package](https://img.shields.io/pub/v/extended_nested_scroll_view.svg)](https://pub.dartlang.org/packages/extended_nested_scroll_view) [![GitHub stars](https://img.shields.io/github/stars/fluttercandies/extended_nested_scroll_view)](https://github.com/fluttercandies/extended_nested_scroll_view/stargazers) [![GitHub forks](https://img.shields.io/github/forks/fluttercandies/extended_nested_scroll_view)](https://github.com/fluttercandies/extended_nested_scroll_view/network)  [![GitHub license](https://img.shields.io/github/license/fluttercandies/extended_nested_scroll_view)](https://github.com/fluttercandies/extended_nested_scroll_view/blob/master/LICENSE)  [![GitHub issues](https://img.shields.io/github/issues/fluttercandies/extended_nested_scroll_view)](https://github.com/fluttercandies/extended_nested_scroll_view/issues) <a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="flutter-candies" title="flutter-candies"></a>

Language: [English](README.md) | [中文简体](README-ZH.md)

NestedScrollView: extended nested scroll view to fix following issues.

1.[pinned sliver header issue](https://github.com/flutter/flutter/issues/22393)

2.[inner scrollables in tabview sync issue](https://github.com/flutter/flutter/issues/21868)

3.do without ScrollController in NestedScrollView's body

[Web demo for ExtendedNestedScrollView](https://fluttercandies.github.io/extended_nested_scroll_view/)

- [extended_nested_scroll_view](#extended_nested_scroll_view)
- [Example for issue 1](#example-for-issue-1)
- [Example for issue 2](#example-for-issue-2)
- [Do without ScrollController in NestedScrollView's body](#do-without-scrollcontroller-in-nestedscrollviews-body)
# Example for issue 1

give total height of pinned sliver headers in pinnedHeaderSliverHeightBuilder callback
``` dart
 var tabBarHeight = primaryTabBar.preferredSize.height;
      var pinnedHeaderHeight =
          //statusBar height
          statusBarHeight +
              //pinned SliverAppBar height in header
              kToolbarHeight;

    ExtendedNestedScrollView(
        pinnedHeaderSliverHeightBuilder: () {
          return pinnedHeaderHeight;
        }
       )   ,
       
```
# Example for issue 2

``` dart
    ExtendedNestedScrollView(
       onlyOneScrollInBody: true,
    )
``` 
# Do without ScrollController in NestedScrollView's body

* due to we can't set ScrollController for list in NestedScrollView's body(it will breaking behaviours of InnerScrollController in NestedScrollView),provide Demos
  
* [pull to refresh](https://github.com/fluttercandies/extended_nested_scroll_view/tree/master/example/lib/pages/pull_to_refresh.dart)
  
* [load more](https://github.com/fluttercandies/extended_nested_scroll_view/tree/master/example/lib/pages/load_more.dart) 
  
* [scroll to top](https://github.com/fluttercandies/extended_nested_scroll_view/tree/master/example/lib/pages/scroll_to_top.dart) 
  
  show how to do it without ScrollController


* [pinned header height](https://github.com/fluttercandies/extended_nested_scroll_view/tree/master/example/lib/pages/dynamic_pinned_header_height.dart) 

  show how to change pinned header height dynamically.

