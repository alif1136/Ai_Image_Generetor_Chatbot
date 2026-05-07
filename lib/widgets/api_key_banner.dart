import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ApiKeyBanner extends StatelessWidget {
  final VoidCallback onGoToSettings;
  const ApiKeyBanner({super.key, required this.onGoToSettings});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppTheme.error.withOpacity(0.12),
      child: Row(children: [
        const Icon(Icons.warning_amber_rounded, color: AppTheme.error, size: 18),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'No API key set. Add your OpenAI key in Settings.',
            style: TextStyle(color: AppTheme.error, fontSize: 13),
          ),
        ),
        TextButton(
          onPressed: onGoToSettings,
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.error,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Go →',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ),
      ]),
    );
  }
}