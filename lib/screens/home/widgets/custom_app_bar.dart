import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_notes/providers/search_provider.dart';
import 'package:smart_notes/providers/sort_provider.dart';

// 1. Convert to a ConsumerStatefulWidget
class CustomAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  final VoidCallback onMenuPressed;
  const CustomAppBar({super.key, required this.onMenuPressed});

  @override
  ConsumerState<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// 2. Create the State class
class _CustomAppBarState extends ConsumerState<CustomAppBar> {
  // 3. Create a single, long-lived controller
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    // Initialize the controller and set its initial text from the provider
    _searchController =
        TextEditingController(text: ref.read(searchQueryProvider));
  }

  @override
  void dispose() {
    // 4. Always dispose of your controllers to prevent memory leaks
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 5. Listen for external changes to the search query provider
    // This ensures that if the query is cleared elsewhere, our text field updates.
    ref.listen(searchQueryProvider, (_, next) {
      if (_searchController.text != next) {
        _searchController.text = next;
      }
    });

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: widget.onMenuPressed,
      ),
      title: TextField(
        // 6. Use the controller that lives in the State
        controller: _searchController,
        autofocus: false,
        decoration: const InputDecoration(
          hintText: 'Search your notes..',
          border: InputBorder.none,
        ),
        onChanged: (value) {
          // When the user types, update the provider. The listener above
          // will prevent this from causing a feedback loop.
          ref.read(searchQueryProvider.notifier).state = value;
        },
      ),
      actions: [
        // This logic remains the same
        if (ref.watch(searchQueryProvider).isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              // Clear the search query provider
              ref.read(searchQueryProvider.notifier).state = '';
            },
          ),
        IconButton(
          icon: const Icon(Icons.sort),
          onPressed: () {
            _showSortOptions(context, ref);
          },
        ),
      ],
    );
  }

  /// Shows a modal bottom sheet with sorting options.
  void _showSortOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final sortBy = ref.watch(sortByProvider);
            final sortOrder = ref.watch(sortOrderProvider);

            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sort by',
                      style: Theme.of(context).textTheme.titleLarge),
                  RadioListTile<SortBy>(
                    title: const Text('Date Modified'),
                    value: SortBy.dateModified,
                    groupValue: sortBy,
                    onChanged: (value) {
                      ref.read(sortByProvider.notifier).state = value!;
                    },
                  ),
                  RadioListTile<SortBy>(
                    title: const Text('Date Created'),
                    value: SortBy.dateCreated,
                    groupValue: sortBy,
                    onChanged: (value) {
                      ref.read(sortByProvider.notifier).state = value!;
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Order'),
                    trailing: TextButton.icon(
                      onPressed: () {
                        final newOrder = sortOrder == SortOrder.ascending
                            ? SortOrder.descending
                            : SortOrder.ascending;
                        ref.read(sortOrderProvider.notifier).state = newOrder;
                      },
                      icon: Icon(sortOrder == SortOrder.descending
                          ? Icons.arrow_downward
                          : Icons.arrow_upward),
                      label: Text(sortOrder == SortOrder.descending
                          ? 'Newest first'
                          : 'Oldest first'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
