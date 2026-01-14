import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/app_scaffold.dart';

class about extends StatelessWidget {
  const about({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final onSurfaceMuted = colors.onSurface.withOpacity(0.7);
    return AppScaffold(
      title: 'About One App',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'One App',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'A compact toolkit for QR, OCR, and PDF utilities. Built to be fast, clean, and easy to use.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Features',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                const Text('• QR code generator and scanner'),
                const SizedBox(height: 6),
                const Text('• Image to text (OCR)'),
                const SizedBox(height: 6),
                const Text('• Image labeling'),
                const SizedBox(height: 6),
                const Text('• PDF to text conversion'),
                const SizedBox(height: 6),
                const Text('• Text to image export'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
