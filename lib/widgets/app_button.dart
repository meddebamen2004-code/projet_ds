import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Composant "Button" de Figma : rayon 12, padding 24 x 12.
/// [outlined] = version blanche avec bordure (bouton Google).
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final bool loading;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.outlined = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
    const padding = EdgeInsets.symmetric(horizontal: 24, vertical: 14);
    final child = loading
        ? SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: outlined ? AppColors.primary : Colors.white,
            ),
          )
        : Text(label, style: const TextStyle(fontWeight: FontWeight.w600));

    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton(
              onPressed: loading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: padding,
                shape: shape,
              ),
              child: child,
            )
          : ElevatedButton(
              onPressed: loading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: padding,
                shape: shape,
              ),
              child: child,
            ),
    );
  }
}