import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A profile section: a [SectionHead] (primary icon + title + optional trailing
/// action) above an elevated card holding hairline-divided rows.
class ProfileSection extends StatelessWidget {
  const ProfileSection({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    required this.rows,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHead(icon: icon, title: title, trailing: trailing),
        const SizedBox(height: 12),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                rows[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// 20px primary icon + titleMedium title, with an optional trailing action
/// (e.g. the "Chi tiết" text button on the business section).
class SectionHead extends StatelessWidget {
  const SectionHead({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: scheme.primary, fill: 1),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// One detail row inside a [ProfileSection] card.
///
/// Anatomy: 40px circular leading icon tile · label over value · optional
/// trailing widget (pill / chevron) and an `edit` glyph when [editable].
/// Editable / [onTap]-bearing rows are a full-row hit target with a hover tint.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.mono = false,
    this.muted = false,
    this.editable = false,
    this.trailing,
    this.onTap,
    this.semanticsLabel,
  });

  final IconData icon;
  final String label;
  final String value;

  /// Renders [value] in Roboto Mono (tax code, account number).
  final bool mono;

  /// Lighter weight value variant (`.muted` in the handoff).
  final bool muted;

  /// Appends the trailing `edit` glyph and marks the row tappable.
  final bool editable;

  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: (mono
                          ? theme.textTheme.bodyLarge?.copyWith(
                              fontFamily: 'monospace',
                              letterSpacing: 0.5,
                            )
                          : theme.textTheme.bodyLarge)
                      ?.copyWith(
                    fontWeight: muted ? FontWeight.w400 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
          if (editable) ...[
            const SizedBox(width: 8),
            Icon(Symbols.edit, size: 20, color: scheme.onSurfaceVariant),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return semanticsLabel == null
          ? row
          : Semantics(label: semanticsLabel, child: row);
    }
    return Semantics(
      label: semanticsLabel,
      button: true,
      child: InkWell(
        onTap: onTap,
        hoverColor: scheme.surfaceContainer,
        child: row,
      ),
    );
  }
}
