import 'package:flutter/material.dart';

/// Wiederverwendbare Info-Card
///
/// Standardisiertes Card-Layout für Listen-Items mit:
/// - Leading: Icon, Avatar, Image, oder custom Widget
/// - Content: Title + optional Subtitle + optional Description
/// - Trailing: Icon, Badge, Count, oder custom Widget
/// - Footer: Buttons, Chips, Badges unterhalb des Contents
/// - onTap: Navigation oder Action
///
/// **Layout:**
/// ```
/// ┌─────────────────────────────────────┐
/// │ [Leading]  Title            [Trail] │
/// │            Subtitle                 │
/// │            Description              │
/// │                                     │
/// │ [Footer Widget]                     │
/// └─────────────────────────────────────┘
/// ```
///
/// Beispiele:
/// ```dart
/// InfoCard(
///   leading: IconContainer(icon: Icons.person),
///   title: "Max Mustermann",
///   subtitle: "Freund",
///   trailing: Icon(Icons.chevron_right),
///   onTap: () => ...,
/// )
///
/// InfoCard(
///   leading: CircleAvatar(...),
///   title: "Event Name",
///   subtitle: "12:00 Uhr",
///   description: "Weitere Details...",
///   footer: Row(children: [StatusBadge.success("Bestätigt")]),
/// )
/// ```
class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.title,
    super.key,
    this.leading,
    this.subtitle,
    this.description,
    this.trailing,
    this.footer,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.leadingSpacing = 12,
    this.contentSpacing = 4,
    this.elevation = 2,
  });

  /// Widget links (Icon, Avatar, Image, etc.)
  final Widget? leading;

  /// Haupt-Titel (fett, größer)
  final String title;

  /// Untertitel unter dem Title (normal, kleiner)
  final String? subtitle;

  /// Beschreibung unter Subtitle (noch kleiner, opacity)
  final String? description;

  /// Widget rechts (Icon, Badge, Count, etc.)
  final Widget? trailing;

  /// Widget unterhalb des Contents (Buttons, Chips, Badges)
  final Widget? footer;

  /// Tap-Callback für Navigation/Action
  final VoidCallback? onTap;

  /// Padding innerhalb der Card
  final EdgeInsets padding;

  /// Spacing zwischen Leading und Content
  final double leadingSpacing;

  /// Spacing zwischen Title/Subtitle/Description
  final double contentSpacing;

  /// Card Elevation
  final double elevation;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Row: Leading + Content + Trailing
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Leading Widget (optional)
                  if (leading != null) ...[
                    leading!,
                    SizedBox(width: leadingSpacing),
                  ],

                  // Content Column (Title + Subtitle + Description)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Subtitle
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          SizedBox(height: contentSpacing),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        // Description
                        if (description != null && description!.isNotEmpty) ...[
                          SizedBox(height: contentSpacing),
                          Text(
                            description!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Trailing Widget (optional)
                  if (trailing != null) ...[
                    const SizedBox(width: 12),
                    trailing!,
                  ],
                ],
              ),

              // Footer Widget (optional)
              if (footer != null) ...[
                const SizedBox(height: 12),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
