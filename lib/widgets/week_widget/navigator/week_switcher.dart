import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:reel_calendar/constants/icons_constants.dart';

/// ─────────────────────────────────────────
/// Widget final : ◀ Aujourd’hui ▶
/// ─────────────────────────────────────────
class WeekSwitcher extends StatelessWidget {
  final VoidCallback onPrevious;
  final VoidCallback onToday;
  final VoidCallback onNext;

  const WeekSwitcher({
    super.key,
    required this.onPrevious,
    required this.onToday,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SquareIconButton(icon: Icons.navigate_before, onTap: onPrevious),
        SizedBox(width: 0.15),
        SquareTextButton(label: "Aujourd’hui", onTap: onToday),
        SizedBox(width: 0.15),
        SquareIconButton(icon: Icons.navigate_next, onTap: onNext),
      ],
    );
  }
}

/// ─────────────────────────────────────────
/// 🔘 BOUTON ICÔNE
/// ─────────────────────────────────────────
class SquareIconButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final double size;

  const SquareIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 24,
  });

  @override
  State<SquareIconButton> createState() => _SquareIconButtonState();
}

class _SquareIconButtonState extends State<SquareIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return _BaseSquareButton(
      pressed: _pressed,
      onTap: widget.onTap,
      onTapDown: () => setState(() => _pressed = true),
      onTapEnd: () => setState(() => _pressed = false),
      width: widget.size,
      child: Transform.translate(
        offset: const Offset(-1, 0),
        child: SvgPicture.string(
          widget.icon == Icons.navigate_next
              ? kChevronRightSvg
              : kChevronLeftSvg,
          width: 14,
          height: 14,
          colorFilter: const ColorFilter.mode(
            Color.fromARGB(195, 0, 0, 0),
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────
/// 🔘 BOUTON TEXTE (IDENTIQUE AU STYLE ICÔNE)
/// ─────────────────────────────────────────
class SquareTextButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final double height;

  const SquareTextButton({
    super.key,
    required this.label,
    required this.onTap,
    this.height = 24,
  });

  @override
  State<SquareTextButton> createState() => _SquareTextButtonState();
}

class _SquareTextButtonState extends State<SquareTextButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return _BaseSquareButton(
      pressed: _pressed,
      onTap: widget.onTap,
      onTapDown: () => setState(() => _pressed = true),
      onTapEnd: () => setState(() => _pressed = false),
      width: null, // largeur auto selon le texte
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Transform.translate(
          offset: const Offset(0, -0.5), // 👈 correction optique verticale
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w300,
              color: Color(0xFF374151),
            ),
          ),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────
/// 🧱 BASE COMMUNE (DESIGN SYSTEM)
// ─────────────────────────────────────────
class _BaseSquareButton extends StatelessWidget {
  final bool pressed;
  final VoidCallback onTap;
  final VoidCallback onTapDown;
  final VoidCallback onTapEnd;
  final Widget child;
  final double? width;

  const _BaseSquareButton({
    required this.pressed,
    required this.onTap,
    required this.onTapDown,
    required this.onTapEnd,
    required this.child,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapEnd(),
      onTapCancel: onTapEnd,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: pressed ? const Color(0xFFF3F4F6) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFD1D5DB), width: 0.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 1,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: SizedBox(
          height: 24,
          width: width,
          child: Center(child: child),
        ),
      ),
    );
  }
}
