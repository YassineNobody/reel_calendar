import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomSelect<T> extends StatefulWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T> onChanged;
  final Widget Function(T item) itemBuilder;

  const CustomSelect({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.itemBuilder,
  });

  @override
  State<CustomSelect<T>> createState() => _CustomSelectState<T>();
}

class _CustomSelectState<T> extends State<CustomSelect<T>> {
  OverlayEntry? _overlay;

  @override
  void dispose() {
    _closeMenu();
    super.dispose();
  }

  void _openMenu() {
    final overlay = Overlay.of(context);
    final box = context.findRenderObject() as RenderBox;
    final pos = box.localToGlobal(Offset.zero);
    final size = box.size;

    _overlay = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeMenu,
            ),
          ),
          Positioned(
            left: pos.dx,
            top: pos.dy + size.height + 4,
            width: size.width, // 👈 menu aligné au select
            child: _buildMenu(),
          ),
        ],
      ),
    );

    overlay.insert(_overlay!);
  }

  void _closeMenu() {
    _overlay?.remove();
    _overlay = null;
  }

  Widget _buildMenu() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: widget.items.map((item) {
          return InkWell(
            onTap: () {
              widget.onChanged(item);
              _closeMenu();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              child: widget.itemBuilder(item), // texte COMPLET ici
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _overlay == null ? _openMenu : _closeMenu,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 100,
          maxWidth: 200, // 👈 clé du responsive
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // 👈 CRITIQUE
          children: [
            Expanded(child: widget.itemBuilder(widget.value)),
            const SizedBox(width: 6),
            const Icon(
              CupertinoIcons.chevron_up_chevron_down,
              size: 12,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }
}
