import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cryptoarth/shared/theme/app_colors.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final String? prefixText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int maxLines;
  final bool readOnly;
  final IconData? icon;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.prefixText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.readOnly = false,
    this.icon,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Row(
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: _isFocused ? AppColors.primary : Colors.white38, size: 12),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label.toUpperCase(),
                style: TextStyle(
                  color: _isFocused ? AppColors.primary : Colors.white24,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Focus(
          onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(_isFocused ? 0.05 : 0.03),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isFocused ? AppColors.primary.withOpacity(0.4) : Colors.white.withOpacity(0.05),
                width: 1,
              ),
              boxShadow: _isFocused ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.05), 
                  blurRadius: 20, 
                  offset: const Offset(0, 4)
                )
              ] : [],
            ),
            child: Row(
              children: [
                if (widget.prefixText != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      widget.prefixText!,
                      style: TextStyle(
                        color: _isFocused ? AppColors.primary : Colors.white38,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    keyboardType: widget.keyboardType,
                    obscureText: widget.obscureText,
                    readOnly: widget.readOnly,
                    inputFormatters: widget.inputFormatters,
                    maxLength: widget.maxLength,
                    maxLines: widget.maxLines,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      hintText: widget.hint.toUpperCase(),
                      counterText: "",
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.1),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
