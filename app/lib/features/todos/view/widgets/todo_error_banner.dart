import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mvvm_example/core/ui/ui_constants.dart';

/// Inline error banner below filter/sort when the view model reports an error.
class TodoErrorBanner extends StatelessWidget {
  /// Creates the error banner.
  const TodoErrorBanner({required this.message, super.key});

  /// Error text to show.
  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'errorBannerLabel'.tr(),
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(UiConstants.spacingSm),
        margin: const EdgeInsets.only(bottom: UiConstants.spacingMd),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(UiConstants.radiusSm),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.error,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            const SizedBox(width: UiConstants.spacingXs),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
