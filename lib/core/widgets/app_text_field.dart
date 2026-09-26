import 'package:flutter/material.dart';

import '../constants/app_radius.dart';
import '../extensions/context_extensions.dart';

/// The single text input used by the whole app.
///
/// Supports an optional password visibility toggle, an error slot, helper text
/// and live validation, so screens never build raw `TextField`s.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.helperText,
    this.enabled = true,
    this.autofocus = false,
    this.showCounter = false,
    this.fillEmpty = true,
    this.textStyle,
    this.contentPadding,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue;
  final bool isPassword;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final int? minLines;
  final int? maxLength;

  /// Returns a message when the value is invalid, otherwise `null`.
  final String? Function(String? value)? validator;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final String? helperText;
  final bool enabled;
  final bool autofocus;
  final bool showCounter;
  final bool fillEmpty;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? contentPadding;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final TextEditingController _controller;
  late final bool _ownsController;
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    if (_ownsController && widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final colors = context.colors;

    final suffix = widget.isPassword
        ? IconButton(
            onPressed: () => setState(() => _obscured = !_obscured),
            icon: Icon(
              _obscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              size: 20,
            ),
            color: colors.onSurfaceMuted,
            tooltip: _obscured ? 'Show password' : 'Hide password',
          )
        : widget.suffixIcon == null
            ? null
            : Icon(widget.suffixIcon, size: 20);

    return TextFormField(
      controller: _controller,
      obscureText: widget.isPassword && _obscured,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      style: widget.textStyle ??
          context.text.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: scheme.onSurface,
          ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.errorText,
        helperText: widget.helperText,
        prefixIcon: widget.prefixIcon == null
            ? null
            : Icon(widget.prefixIcon, size: 20),
        suffixIcon: suffix,
        counterText: widget.showCounter ? null : '',
        filled: true,
        fillColor: widget.fillEmpty
            ? (context.isDark ? colors.surfaceAlt : Colors.white)
            : Colors.transparent,
        contentPadding: widget.contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: AppRadius.md,
              vertical: AppRadius.md + 2,
            ),
      ),
    );
  }
}
