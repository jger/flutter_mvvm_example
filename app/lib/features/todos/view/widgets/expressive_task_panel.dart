import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mvvm_example/features/todos/view/widgets/composer_constants.dart';
import 'package:flutter_mvvm_example/features/todos/view/widgets/todo_submit_fab.dart';
import 'package:material_symbols_icons/symbols.dart';

/// M3 Expressive: unified card with header, field, and actions.
class ExpressiveTaskPanel extends StatelessWidget {
  /// Creates the expanded task entry panel.
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

  /// Panel width (matches list max width).
  final double width;

  /// Hint shown in the text field.
  final String hintText;

  /// Bound text controller.
  final TextEditingController controller;

  /// Focus for the text field.
  final FocusNode focusNode;

  /// Called when the user submits (send or IME action).
  final VoidCallback onSubmitted;

  /// Called when the user closes the panel.
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
                                color: scheme.onPrimary.withValues(alpha: 0.92),
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
                            shadowColor: scheme.shadow.withValues(alpha: 0.12),
                            surfaceTintColor: scheme.surfaceTint.withValues(
                              alpha: 0,
                            ),
                            borderRadius: BorderRadius.circular(
                              kComposerCornerRadius,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4, right: 4),
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
                                  TodoSubmitFab(onPressed: onSubmitted),
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
