import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PaginatedGridView — for paginated APIs
//
// Handles: full-page loader (isFetching), bottom load-more (isLoadingMore),
//          empty state, pull-to-refresh, end-of-page.
//
// Requires scrollController from PaginatedFetchMixin on the controller.
//
// Usage:
/// ```dart
/// PaginatedGridView(
///   scrollController: controller.scrollController,
///   itemCount: controller.productList.length,
///   isFetching: controller.isFetching,
///   isLoadingMore: controller.isLoadingMore.value,
///   isEmpty: controller.productList.isEmpty,
///   onRefresh: () => controller.fetchData(),
///   itemBuilder: (context, index) => ProductCard(
///     product: controller.productList[index],
///   ),
/// )
/// ```
// ─────────────────────────────────────────────────────────────────────────────

enum PaginatedGridType { masonry, uniform }

class PaginatedGridView extends StatelessWidget {
  const PaginatedGridView({
    super.key,

    /// Required
    required this.scrollController,
    required this.itemCount,
    required this.itemBuilder,
    required this.onRefresh,

    /// State flags
    this.isFetching = false,
    this.isLoadingMore = false,
    this.isEmpty = false,

    /// Grid config
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 16.0,
    this.mainAxisSpacing = 16.0,
    this.padding,
    this.gridType = PaginatedGridType.masonry,
    this.childAspectRatio = 1.0,
    this.mainAxisExtent,

    /// Custom state widgets
    this.fetchingWidget,
    this.emptyWidget,
    this.loadMoreWidget,

    /// RefreshIndicator
    this.refreshIndicatorColor,
    this.refreshIndicatorBackgroundColor,

    /// Scroll
    this.physics,
  });

  final ScrollController scrollController;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Future<void> Function() onRefresh;

  final bool isFetching;
  final bool isLoadingMore;
  final bool isEmpty;

  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final PaginatedGridType gridType;
  final double childAspectRatio;
  final double? mainAxisExtent;

  final Widget? fetchingWidget;
  final Widget? emptyWidget;
  final Widget? loadMoreWidget;

  final Color? refreshIndicatorColor;
  final Color? refreshIndicatorBackgroundColor;

  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    // Full-page loader — shown on first fetch or pull-to-refresh
    if (isFetching) {
      return fetchingWidget ?? const Center(child: CircularProgressIndicator());
    }

    // Empty state — only after fetch completes with no results
    if (isEmpty && !isLoadingMore) {
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
    // +1 slot at the bottom for load-more indicator
    final totalCount = itemCount + (isLoadingMore ? 1 : 0);

    return switch (gridType) {
      PaginatedGridType.masonry => MasonryGridView.count(
        controller: scrollController,
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        padding: padding,
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        itemCount: totalCount,
        itemBuilder: _itemBuilder,
      ),
      PaginatedGridType.uniform => GridView.builder(
        controller: scrollController,
        padding: padding,
        physics: physics ?? const AlwaysScrollableScrollPhysics(),
        itemCount: totalCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: mainAxisExtent == null ? childAspectRatio : 1.0,
          mainAxisExtent: mainAxisExtent,
        ),
        itemBuilder: _itemBuilder,
      ),
    };
  }

  Widget _itemBuilder(BuildContext context, int index) {
    if (index == itemCount && isLoadingMore) {
      return loadMoreWidget ?? const _DefaultLoadMoreWidget();
    }
    return itemBuilder(context, index);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PaginatedListView — for paginated APIs
//
// Handles: full-page loader (isFetching), bottom load-more (isLoadingMore),
//          empty state, pull-to-refresh, end-of-page.
//
// Requires scrollController from PaginatedFetchMixin on the controller.
//
// Usage:
/// ```dart
/// PaginatedListView(
///   scrollController: controller.scrollController,
///   itemCount: controller.orderList.length,
///   isFetching: controller.isFetching,
///   isLoadingMore: controller.isLoadingMore.value,
///   isEmpty: controller.orderList.isEmpty,
///   onRefresh: () => controller.fetchData(),
///   itemBuilder: (context, index) => OrderCard(
///     order: controller.orderList[index],
///   ),
/// )
/// ```
// ─────────────────────────────────────────────────────────────────────────────

class PaginatedListView extends StatelessWidget {
  const PaginatedListView({
    super.key,

    /// Required
    required this.scrollController,
    required this.itemCount,
    required this.itemBuilder,
    required this.onRefresh,

    /// State flags
    this.isFetching = false,
    this.isLoadingMore = false,
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
    this.loadMoreWidget,

    /// RefreshIndicator
    this.refreshIndicatorColor,
    this.refreshIndicatorBackgroundColor,

    /// Scroll
    this.physics,
  });

  final ScrollController scrollController;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Future<void> Function() onRefresh;

  final bool isFetching;
  final bool isLoadingMore;
  final bool isEmpty;

  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final IndexedWidgetBuilder? separatorBuilder;
  final double? itemExtent;
  final Axis scrollDirection;

  final Widget? fetchingWidget;
  final Widget? emptyWidget;
  final Widget? loadMoreWidget;

  final Color? refreshIndicatorColor;
  final Color? refreshIndicatorBackgroundColor;

  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    if (isFetching) {
      return fetchingWidget ?? const Center(child: CircularProgressIndicator());
    }

    if (isEmpty && !isLoadingMore) {
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
    final totalCount = itemCount + (isLoadingMore ? 1 : 0);

    return ListView.builder(
      controller: scrollController,
      padding: padding,
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      shrinkWrap: shrinkWrap,
      scrollDirection: scrollDirection,
      itemExtent: itemExtent,
      itemCount: totalCount,
      itemBuilder: (context, index) {
        final item = _itemBuilder(context, index);

        // If we have a separator and this is NOT the last item in the total list
        if (separatorBuilder != null && index < totalCount - 1) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [item, separatorBuilder!(context, index)],
          );
        }

        return item;
      },
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    if (index == itemCount && isLoadingMore) {
      return loadMoreWidget ?? const _DefaultLoadMoreWidget();
    }
    return itemBuilder(context, index);
  }
}

// ─────────────────────────────────────────────
// Internal: Default load-more indicator
// ─────────────────────────────────────────────

class _DefaultLoadMoreWidget extends StatelessWidget {
  const _DefaultLoadMoreWidget();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
