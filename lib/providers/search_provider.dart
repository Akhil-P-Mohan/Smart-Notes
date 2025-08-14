import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to hold the current search query string.
final searchQueryProvider = StateProvider<String>((ref) => '');
