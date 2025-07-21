import 'package:flutter/material.dart';

class EmptyChatView extends StatelessWidget {
  const EmptyChatView({super.key});

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      // padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              'What can I help with?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              alignment: WrapAlignment.center,
              children: [
                SuggestionChip(
                  icon: Icons.image_outlined,
                  label: 'Create image',
                  onTap: () {},
                ),
                SuggestionChip(
                  icon: Icons.lightbulb_outline,
                  label: 'Surprise me',
                  onTap: () {},
                ),
                SuggestionChip(
                  icon: Icons.code,
                  label: 'Code',
                  onTap: () {},
                ),
                SuggestionChip(
                  icon: Icons.more_horiz,
                  label: 'More',
                  onTap: () {},
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class SuggestionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const SuggestionChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
