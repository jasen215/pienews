import 'package:flutter/cupertino.dart';

class FilterButtons extends StatelessWidget {
  final int currentIndex;
  final Function(int) onFilterChanged;
  final bool isArticleFilter;

  const FilterButtons({
    super.key,
    required this.currentIndex,
    required this.onFilterChanged,
    this.isArticleFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedIndex = currentIndex == 3 ? 2 : currentIndex;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CupertinoButton(
          padding: const EdgeInsets.all(12),
          child: normalizedIndex == 0
              ? const Icon(
                  CupertinoIcons.star_fill,
                  color: CupertinoColors.systemBlue,
                  size: 24,
                )
              : Icon(
                  CupertinoIcons.star,
                  color: CupertinoTheme.of(context)
                      .textTheme
                      .textStyle
                      .color
                      ?.withOpacity(0.6),
                  size: 24,
                ),
          onPressed: () => onFilterChanged(0),
        ),
        CupertinoButton(
          padding: const EdgeInsets.all(12),
          child: normalizedIndex == 1
              ? const Icon(
                  CupertinoIcons.circle_fill,
                  color: CupertinoColors.systemBlue,
                  size: 24,
                )
              : Icon(
                  CupertinoIcons.circle,
                  color: CupertinoTheme.of(context)
                      .textTheme
                      .textStyle
                      .color
                      ?.withOpacity(0.6),
                  size: 24,
                ),
          onPressed: () => onFilterChanged(1),
        ),
        CupertinoButton(
          padding: const EdgeInsets.all(12),
          child: normalizedIndex == 2
              ? const Icon(
                  CupertinoIcons.square_list_fill,
                  color: CupertinoColors.systemBlue,
                  size: 24,
                )
              : Icon(
                  CupertinoIcons.square_list,
                  color: CupertinoTheme.of(context)
                      .textTheme
                      .textStyle
                      .color
                      ?.withOpacity(0.6),
                  size: 24,
                ),
          onPressed: () => onFilterChanged(isArticleFilter ? 3 : 2),
        ),
      ],
    );
  }
}
