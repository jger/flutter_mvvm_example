import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:app/core/ui/ui_constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Outer padding inset for screen edges (todo_view layout).
const double kComposerGlowMargin = 12;

/// Height of the open expressive panel (excluding outer padding).
const double kComposerPanelHeight = 200;

/// Vertical space reserved for ListView bottom inset (open panel + gap).
const double kComposerBottomReserve = kComposerPanelHeight + 40;

const double _collapsedFab = 56;

/// M3 FAB 56dp: corner radius 16dp (rounded rect, not circle).
const double _kFabCornerRadius = 16;

/// M3 extra-large radius (same family as inner text field pill).
const double kComposerCornerRadius = 28;

const double _kKeyboardAccessoryBarHeight = 56;

class _TodoSubmitFab extends StatelessWidget {
  const _TodoSubmitFab({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: 'addTodoSubmit'.tr(),
      child: Material(
        color: scheme.tertiary,
        shape: const CircleBorder(),
        elevation: 2,
        shadowColor: scheme.shadow.withValues(alpha: 0.2),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 52,
            height: 52,
            child: Center(
              child: Icon(
                Symbols.send,
                size: 26,
                fill: 1,
                weight: 500,
                color: scheme.onTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// M3 Expressive: unified card with header, field, and actions.
class ExpressiveTaskPanel extends StatelessWidget {
  const ExpressiveTaskPanel({
    required this.width,
    required this.hintText,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.onClose,
    this.contentOpacity = 1,
    super.key,
  });

  final double width;
  final String hintText;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmitted;
  final VoidCallback onClose;

  /// Fades in header + field during open morph (0 = hidden).
  final double contentOpacity;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    final ThemeData fieldTheme = theme.copyWith(
      colorScheme: scheme.copyWith(
        surface: scheme.surfaceContainerHighest,
        onSurface: scheme.onSurface,
      ),
    );

    return SizedBox(
      width: width,
      height: kComposerPanelHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kComposerCornerRadius),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.22),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(kComposerCornerRadius),
          child: DecoratedBox(
            decoration: BoxDecoration(color: scheme.primary),
            child: IgnorePointer(
              ignoring: contentOpacity < 0.45,
              child: Opacity(
                opacity: contentOpacity.clamp(0, 1),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 12, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'expressiveTaskPanelTitle'.tr(),
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: scheme.onPrimary.withValues(
                                  alpha: 0.92,
                                ),
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          Material(
                            color: scheme.onPrimary.withValues(alpha: 0.18),
                            shape: const CircleBorder(),
                            child: IconButton(
                              key: const Key('todo_panel_close'),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                              tooltip: 'cancel'.tr(),
                              style: IconButton.styleFrom(
                                foregroundColor: scheme.onPrimary.withValues(
                                  alpha: 0.88,
                                ),
                              ),
                              onPressed: onClose,
                              icon: const Icon(
                                Symbols.close,
                                size: 22,
                                weight: 500,
                                opticalSize: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Theme(
                          data: fieldTheme,
                          child: Material(
                            color: fieldTheme.colorScheme.surface,
                            elevation: 1,
                            shadowColor: scheme.shadow.withValues(
                              alpha: 0.12,
                            ),
                            surfaceTintColor: scheme.surfaceTint.withValues(
                              alpha: 0,
                            ),
                            borderRadius: BorderRadius.circular(kComposerCornerRadius),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 4,
                                right: 4,
                              ),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: TextField(
                                      key: const Key('todo_input_field'),
                                      controller: controller,
                                      focusNode: focusNode,
                                      textInputAction: TextInputAction.send,
                                      onSubmitted: (_) => onSubmitted(),
                                      style: textTheme.bodyLarge?.copyWith(
                                        color: scheme.onSurface,
                                      ),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        hintText: hintText,
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                      ),
                                    ),
                                  ),
                                  _TodoSubmitFab(onPressed: onSubmitted),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact add button opens the unified expressive panel.
class FloatingTodoComposer extends StatefulWidget {
  const FloatingTodoComposer({
    required this.hintText,
    required this.onSubmitted,
    super.key,
  });

  final String hintText;
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

  void _syncImeChrome() {
    if (!mounted) {
      return;
    }
    // The system IME cannot be themed reliably in Flutter; navigation bar follows
    // the theme (ColorScheme.surfaceContainerLow).
    final ColorScheme scheme = Theme.of(context).colorScheme;
    if (_controller.isCompleted) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          systemNavigationBarColor: scheme.surfaceContainerLow,
          systemNavigationBarIconBrightness:
              scheme.brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          systemNavigationBarContrastEnforced: false,
        ),
      );
    } else {
      SystemChrome.restoreSystemUIOverlays();
    }
  }

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChanged);
    _controller.addListener(_syncImeChrome);
  }

  @override
  void dispose() {
    SystemChrome.restoreSystemUIOverlays();
    _detachFocusWhenPanelListener();
    _controller.removeListener(_syncImeChrome);
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
        final bool showKeyboardAccessory =
            _focus.hasFocus && keyboardInset > 0;

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
                final double fabOpacity = (1 - Curves.easeIn.transform(t)).clamp(
                  0.0,
                  1.0,
                );

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
                      child: _TodoSubmitFab(
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
