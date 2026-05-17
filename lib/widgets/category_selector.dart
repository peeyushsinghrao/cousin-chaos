import 'package:cousin_chaos/core/icons.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class CategorySelector extends StatefulWidget {
  final List<String> categories;
  final List<String> initialSelected;
  final ValueChanged<List<String>> onChanged;

  const CategorySelector({
    required this.categories,
    required this.initialSelected,
    required this.onChanged,
    super.key,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(
      widget.initialSelected.isNotEmpty
          ? widget.initialSelected
          : [widget.categories.first],
    );
  }

  void _toggle(String cat) {
    setState(() {
      if (_selected.contains(cat)) {
        if (_selected.length > 1) {
          _selected.remove(cat);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Select at least 1 category'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } else {
        _selected.add(cat);
      }
    });
    widget.onChanged(_selected);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_selected.length} selected',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(
                        () => _selected = List.from(widget.categories));
                    widget.onChanged(_selected);
                  },
                  child: const Text('All'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _selected = [widget.categories.first]);
                    widget.onChanged(_selected);
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.5,
          ),
          itemCount: widget.categories.length,
          itemBuilder: (context, index) {
            final cat = widget.categories[index];
            final isSelected = _selected.contains(cat);
            return GestureDetector(
              onTap: () => _toggle(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withAlpha(50)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.white24,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? LucideIcons.checkCircle
                          : LucideIcons.circle,
                      color:
                          isSelected ? AppColors.primary : Colors.white30,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cat,
                        style: TextStyle(
                          color:
                              isSelected ? Colors.white : Colors.white70,
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
