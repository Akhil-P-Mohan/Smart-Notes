import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enum to define the available sorting criteria.
enum SortBy {
  dateModified,
  dateCreated,
}

/// Enum to define the sorting order (ascending or descending).
enum SortOrder {
  descending, // Newest to oldest
  ascending, // Oldest to newest
}

/// Provider to hold the current sorting criterion.
/// Defaults to sorting by 'Date Modified'.
final sortByProvider = StateProvider<SortBy>((ref) => SortBy.dateModified);

/// Provider to hold the current sorting order.
/// Defaults to 'Descending' (newest notes first).
final sortOrderProvider =
    StateProvider<SortOrder>((ref) => SortOrder.descending);
