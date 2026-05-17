import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'pre_game_scaffold.dart';

class CategoryItem {
  final String id;
  final String label;
  final IconData icon;
  final String? description;
  final int? badgeCount;

  const CategoryItem({
    required this.id,
    required this.label,
    required this.icon,
    this.description,
    this.badgeCount,
  });
}

class CategoryGridScreen extends StatefulWidget {
  final String modeName;
  final Color modeColor;
  final int step;
  final int totalSteps;
  final String title;
  final List<CategoryItem> categories;
  final bool multiSelect;
  final int minSelect;
  final List<String> initialSelected;
  final ValueChanged<List<String>> onConfirm;

  const CategoryGridScreen({
    super.key,
    required this.modeName,
    required this.modeColor,
    required this.step,
    required this.totalSteps,
    required this.title,
    required this.categories,
    this.multiSelect = true,
    this.minSelect = 1,
    this.initialSelected = const [],
    required this.onConfirm,
  });

  @override
  State<CategoryGridScreen> createState() => _CategoryGridScreenState();
}

class _CategoryGridScreenState extends State<CategoryGridScreen> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.initialSelected);
    if (_selected.isEmpty && widget.categories.isNotEmpty) {
      _selected = [widget.categories.first.id];
    }
  }

  void _toggle(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (widget.multiSelect) {
        if (_selected.contains(id)) {
          if (_selected.length > widget.minSelect) {
            _selected.remove(id);
          }
        } else {
          _selected.add(id);
        }
      } else {
        _selected = [id];
      }
    });
  }

  void _selectAll() {
    HapticFeedback.lightImpact();
    setState(() {
      _selected = widget.categories.map((c) => c.id).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PreGameScaffold(
      modeName: widget.modeName,
      modeColor: widget.modeColor,
      step: widget.step,
      totalSteps: widget.totalSteps,
      ctaLabel: 'Next →',
      ctaEnabled: _selected.length >= widget.minSelect,
      onCta: () => widget.onConfirm(_selected),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: GoogleFonts.sora(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (widget.multiSelect)
                  GestureDetector(
                    onTap: _selectAll,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: widget.modeColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: widget.modeColor.withAlpha(60)),
                      ),
                      child: Text(
                        'Select All',
                        style: GoogleFonts.sora(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: widget.modeColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.multiSelect
                  ? 'Select one or more categories'
                  : 'Choose a category',
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.3,
                ),
                itemCount: widget.categories.length,
                itemBuilder: (_, i) {
                  final cat = widget.categories[i];
                  final selected = _selected.contains(cat.id);
                  return GestureDetector(
                    onTap: () => _toggle(cat.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: selected
                            ? widget.modeColor.withAlpha(30)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? widget.modeColor
                              : AppColors.surfaceBright,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(cat.icon,
                                      color: selected
                                          ? widget.modeColor
                                          : Colors.white54,
                                      size: 28),
                                  const SizedBox(height: 8),
                                  Text(
                                    cat.label,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.sora(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: selected
                                          ? Colors.white
                                          : Colors.white70,
                                    ),
                                  ),
                                  if (cat.description != null) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      cat.description!,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        color: selected
                                            ? widget.modeColor
                                                .withAlpha(200)
                                            : Colors.white38,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          if (selected)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: widget.modeColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 12),
                              ),
                            ),
                          if (cat.badgeCount != null)
                            Positioned(
                              bottom: 6,
                              right: 8,
                              child: Text(
                                '${cat.badgeCount}',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: selected
                                      ? widget.modeColor
                                      : Colors.white38,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
