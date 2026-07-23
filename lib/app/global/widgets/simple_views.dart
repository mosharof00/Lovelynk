import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SimpleGridView — for non-paginated APIs
//
// Handles: full-page loader, empty state, refresh.
// No scroll controller, no load-more indicator, no pagination state.
//
// Usage:
/// ```dart
/// SimpleGridView(
///   isFetching: controller.isFetching,
///   isEmpty: controller.categoryList.isEmpty,
///   onRefresh: () => controller.fetchData(),
///   itemCount: controller.categoryList.length,
///   itemBuilder: (context, index) => CategoryCard(
///     category: controller.categoryList[index],
///   ),
/// )
/// ```
// ─────────────────────────────────────────────────────────────────────────────

enum SimpleGridType { masonry, uniform }

class SimpleGridView extends StatelessWidget {
  const SimpleGridView({
    super.key,

    /// Required
    required this.itemCount,
    required this.itemBuilder,
    required this.onRefresh,

    /// State flags
    this.isFetching = false,
    this.isEmpty = false,

    /// Grid config
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 16.0,
    this.mainAxisSpacing = 16.0,
    this.padding,
    this.gridType = SimpleGridType.masonry,
    this.childAspectRatio = 1.0,
    this.mainAxisExtent,

    /// Custom state widgets
    this.fetchingWidget,
    this.emptyWidget,

    /// RefreshIndicator
    this.refreshIndicatorColor,
    this.refreshIndicatorBackgroundColor,

    /// Scroll
    this.physics,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Future<void> Function() onRefresh;

  final bool isFetching;
  final bool isEmpty;

  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final SimpleGridType gridType;
  final double childAspectRatio;
  final double? mainAxisExtent;

  final Widget? fetchingWidget;
  final Widget? emptyWidget;

  final Color? refreshIndicatorColor;
  final Color? refreshIndicatorBackgroundColor;

  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    if (isFetching) {
      return fetchingWidget ?? const Center(child: CircularProgressIndicator());
    }

    if (isEmpty) {
      return emptyWidget ??
          const Center(
            child: Text(
              'No items found.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: refreshIndicatorColor ?? Theme.of(context).colorScheme.primary,
      backgroundColor: refreshIndicatorBackgroundColor,
      child: _buildGrid(),
    );
  }

  Widget _buildGrid() {
    return switch (gridType) {
      SimpleGridType.masonry => MasonryGridView.count(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        padding: padding,
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      ),
      SimpleGridType.uniform => GridView.builder(
        padding: padding,
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        itemCount: itemCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: mainAxisExtent == null ? childAspectRatio : 1.0,
          mainAxisExtent: mainAxisExtent,
        ),
        itemBuilder: itemBuilder,
      ),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SimpleListView — for non-paginated APIs
//
// Handles: full-page loader, empty state, refresh.
// No scroll controller, no load-more indicator, no pagination state.
//
// Usage:
/// ```dart
/// SimpleListView(
///   isFetching: controller.isFetching,
///   isEmpty: controller.categoryList.isEmpty,
///   onRefresh: () => controller.fetchData(),
///   itemCount: controller.categoryList.length,
///   itemBuilder: (context, index) => CategoryCard(
///     category: controller.categoryList[index],
///   ),
/// )
/// ```
// ─────────────────────────────────────────────────────────────────────────────

class SimpleListView extends StatelessWidget {
  const SimpleListView({
    super.key,

    /// Required
    required this.itemCount,
    required this.itemBuilder,
    required this.onRefresh,

    /// State flags
    this.isFetching = false,
    this.isEmpty = false,

    /// List config
    this.padding,
    this.shrinkWrap = false,
    this.separatorBuilder,
    this.itemExtent,
    this.scrollDirection = Axis.vertical,

    /// Custom state widgets
    this.fetchingWidget,
    this.emptyWidget,

    /// RefreshIndicator
    this.refreshIndicatorColor,
    this.refreshIndicatorBackgroundColor,

    /// Scroll
    this.physics,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Future<void> Function() onRefresh;

  final bool isFetching;
  final bool isEmpty;

  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final IndexedWidgetBuilder? separatorBuilder;
  final double? itemExtent;
  final Axis scrollDirection;

  final Widget? fetchingWidget;
  final Widget? emptyWidget;

  final Color? refreshIndicatorColor;
  final Color? refreshIndicatorBackgroundColor;

  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    if (isFetching) {
      return fetchingWidget ?? const Center(child: CircularProgressIndicator());
    }

    if (isEmpty) {
      return emptyWidget ??
          const Center(
            child: Text(
              'No items found.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: refreshIndicatorColor ?? Theme.of(context).colorScheme.primary,
      backgroundColor: refreshIndicatorBackgroundColor,
      child: _buildList(),
    );
  }

  Widget _buildList() {
    if (separatorBuilder != null) {
      return ListView.separated(
        padding: padding,
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        shrinkWrap: shrinkWrap,
        scrollDirection: scrollDirection,
        itemCount: itemCount,
        separatorBuilder: separatorBuilder!,
        itemBuilder: itemBuilder,
      );
    }

    return ListView.builder(
      padding: padding,
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      shrinkWrap: shrinkWrap,
      scrollDirection: scrollDirection,
      itemExtent: itemExtent,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}