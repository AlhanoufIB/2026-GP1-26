import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Six (or [length]) digit boxes backed by ONE hidden text field.
/// This makes typing, deleting and pasting a code behave naturally.
class OtpInput extends StatefulWidget {
  final int length;
  final bool hasError;
  final ValueChanged<String> onChanged;

  const OtpInput({
    super.key,
    this.length = 6,
    this.hasError = false,
    required this.onChanged,
  });

  @override
  State<OtpInput> createState() => OtpInputState();
}

class OtpInputState extends State<OtpInput> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  /// Lets the parent clear the boxes (e.g. after a wrong code).
  void clear() {
    _controller.clear();
    widget.onChanged('');
    _focus.requestFocus();
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Widget _box(int i, String text) {
    final char = i < text.length ? text[i] : '';
    final isActive = _focus.hasFocus && i == text.length;
    final borderColor = widget.hasError
        ? AppColors.error
        : (isActive ? AppColors.brown : AppColors.border);

    return Container(
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: isActive || widget.hasError ? 1.8 : 1.2,
        ),
      ),
      child: Text(
        char,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.brownDark,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = _controller.text;

    // Digits are always shown left-to-right, even in an RTL app.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _focus.requestFocus(),
        child: Stack(
          children: [
            // The boxes share the full width equally (no LayoutBuilder here:
            // it breaks inside IntrinsicHeight, which the screen uses).
            Row(
              children: [
                for (var i = 0; i < widget.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: _box(i, text)),
                ],
              ],
            ),
            // The real (invisible) field that receives the keyboard input.
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(widget.length),
                  ],
                  showCursor: false,
                  enableInteractiveSelection: false,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  onChanged: widget.onChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}