import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Circular send FAB used in the expressive panel and keyboard accessory bar.
class TodoSubmitFab extends StatelessWidget {
  /// Creates the submit FAB.
  const TodoSubmitFab({required this.onPressed, super.key});

  /// Called when the user taps send.
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
