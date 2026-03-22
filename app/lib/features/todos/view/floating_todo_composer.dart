import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mvvm_example/core/ui/ui_constants.dart';
import 'package:flutter_mvvm_example/features/todos/view/widgets/composer_constants.dart';
import 'package:flutter_mvvm_example/features/todos/view/widgets/expressive_task_panel.dart';
import 'package:flutter_mvvm_example/features/todos/view/widgets/todo_submit_fab.dart';
import 'package:material_symbols_icons/symbols.dart';

const double _collapsedFab = 56;

/// M3 FAB 56dp: corner radius 16dp (rounded rect, not circle).
const double _kFabCornerRadius = 16;

const double _kKeyboardAccessoryBarHeight = 56;

/// Compact add button opens the unified expressive panel.
class FloatingTodoComposer extends StatefulWidget {
  /// Creates the morphing FAB + panel composer.
  const FloatingTodoComposer({
    required this.hintText,
    required this.onSubmitted,
    super.key,
  });

  /// Hint for the text field.
  final String hintText;

  /// Called with trimmed non-empty text on submit.
  final void Function(String) onSubmitted;

  @override
  State<FloatingTodoComposer> createState() => _FloatingTodoComposerState();
}

class _FloatingTodoComposerState extends State<FloatingTodoComposer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 420),
    vsync: this,
  );
  late final Animation<double> _expand = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutCubic,
  );
  final FocusNode _focus = FocusNode();
  final TextEditingController _text = TextEditingController();

  VoidCallback? _focusWhenPanelVisible;

  void _detachFocusWhenPanelListener() {
    if (_focusWhenPanelVisible != null) {
      _controller.removeListener(_focusWhenPanelVisible!);
      _focusWhenPanelVisible = null;
    }
  }

  void _onFocusChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _detachFocusWhenPanelListener();
    _focus.removeListener(_onFocusChanged);
    _controller.dispose();
    _focus.dispose();
    _text.dispose();
    super.dispose();
  }

  void _open() {
    _detachFocusWhenPanelListener();
    void listener() {
      if (!mounted) {
        _detachFocusWhenPanelListener();
        return;
      }
      if (_expand.value > 0) {
        _detachFocusWhenPanelListener();
        _focus.requestFocus();
      }
    }

    _focusWhenPanelVisible = listener;
    _controller
      ..addListener(listener)
      ..forward();
    listener();
  }

  void _close() {
    _detachFocusWhenPanelListener();
    _controller.reverse();
    _focus.unfocus();
  }

  void _submit() {
    final String t = _text.text.trim();
    if (t.isEmpty) {
      return;
    }
    widget.onSubmitted(t);
    _text.clear();
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxW = math.min(
          constraints.maxWidth,
          UiConstants.maxContentWidth,
        );
        final double keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
        final bool showKeyboardAccessory = _focus.hasFocus && keyboardInset > 0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget? child) {
                final double t = _expand.value;
                final double sx = lerpDouble(_collapsedFab / maxW, 1, t)!;
                final double sy = lerpDouble(
                  _collapsedFab / kComposerPanelHeight,
                  1,
                  t,
                )!;
                final double contentReveal = Curves.easeOut.transform(
                  ((t - 0.12) / 0.88).clamp(0.0, 1.0),
                );
                final double fabOpacity = (1 - Curves.easeIn.transform(t))
                    .clamp(0.0, 1.0);

                return SizedBox(
                  width: maxW,
                  height: kComposerPanelHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomRight,
                    children: <Widget>[
                      if (t > 0)
                        Transform(
                          alignment: Alignment.bottomRight,
                          transform: Matrix4.diagonal3Values(sx, sy, 1),
                          child: SizedBox(
                            width: maxW,
                            height: kComposerPanelHeight,
                            child: ExpressiveTaskPanel(
                              width: maxW,
                              hintText: widget.hintText,
                              controller: _text,
                              focusNode: _focus,
                              onSubmitted: _submit,
                              onClose: _close,
                              contentOpacity: contentReveal,
                            ),
                          ),
                        ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: IgnorePointer(
                          ignoring: fabOpacity < 0.01,
                          child: Opacity(
                            opacity: fabOpacity,
                            child: Tooltip(
                              message: 'addTodoHint'.tr(),
                              child: Material(
                                key: const Key('todo_fab_expand'),
                                elevation: 6,
                                shadowColor: scheme.shadow,
                                surfaceTintColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    _kFabCornerRadius,
                                  ),
                                ),
                                color: scheme.primary,
                                child: InkWell(
                                  customBorder: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      _kFabCornerRadius,
                                    ),
                                  ),
                                  onTap: _open,
                                  child: SizedBox(
                                    width: _collapsedFab,
                                    height: _collapsedFab,
                                    child: Icon(
                                      Symbols.add,
                                      color: scheme.onPrimary,
                                      size: 24,
                                      fill: 0,
                                      weight: 500,
                                      opticalSize: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            if (showKeyboardAccessory)
              Material(
                color: scheme.surfaceContainerHigh,
                elevation: 2,
                child: SizedBox(
                  height: _kKeyboardAccessoryBarHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TodoSubmitFab(
                        key: const Key('todo_keyboard_submit'),
                        onPressed: _submit,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
