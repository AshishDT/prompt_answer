import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A widget that displays an icon or placeholder.
class IconWidget extends StatelessWidget {
  /// Icon Widget constructor.
  const IconWidget({
    required this.icon,
    this.name,
    this.shape,
    this.radius,
    this.onTap,
    this.border,
    this.color,
    this.padding,
    this.iconSize,
    this.textStyle,
    super.key,
  });

  /// Icon to be displayed in the widget.
  final IconData icon;

  /// Name
  final String? name;

  /// Shape of the icon container.
  final BoxShape? shape;

  /// Radius of the icon container.
  final double? radius;

  /// On tap
  final void Function()? onTap;

  /// Border of the icon container.
  final Border? border;

  /// Color of the icon container.
  final Color? color;

  /// Padding for the icon container.
  final EdgeInsets? padding;

  /// Size of the icon.
  final double? iconSize;

  /// Text style for the name.
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          onTap?.call();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding:
              padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: color ?? Colors.white,
            border: border ??
                Border.all(
                  color: Colors.grey.shade500,
                ),
            borderRadius:
                shape != null ? null : BorderRadius.circular(radius ?? 14),
            shape: shape ?? BoxShape.rectangle,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                color: Colors.black,
                size: iconSize ?? 20,
              ),
              if (name != null && name!.isNotEmpty) ...<Widget>[
                const SizedBox(
                  width: 4,
                ),
                Text(
                  name!,
                  style: textStyle ?? GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
}
