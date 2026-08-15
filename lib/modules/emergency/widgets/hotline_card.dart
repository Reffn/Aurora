import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/hotline.dart';
import 'package:dis_app/services/emergency_message_service.dart';
import 'package:flutter/material.dart';

/// Card-Widget für vordefinierte Notfall-Hotlines
class HotlineCard extends StatelessWidget {
  const HotlineCard({
    required this.hotline,
    required this.emergencyService,
    super.key,
  });

  final Hotline hotline;
  final EmergencyMessageService emergencyService;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Knopf unter dem Text statt daneben: Neben Icon und festem Knopf blieb
    // dem Namen so wenig Breite, dass „Telefonseelsorge" mitten im Wort
    // brach. Und ein Anruf-Knopf über die volle Breite ist auf dieser
    // Fläche ohnehin richtiger — wer hier tippt, tippt womöglich zitternd.
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hotline.icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        hotline.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hotline.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      // Die Zeiten stehen auf der Karte, nicht in einer
                      // Überschrift weiter oben: Wer in einer Krise wählt,
                      // soll vorher sehen, ob jetzt jemand rangeht. Ein
                      // erfolgloser Anruf kann sonst als „Hilfe ist gerade
                      // grundsätzlich nicht erreichbar" gelesen werden.
                      if (hotline.hours != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                hotline.hours!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (hotline.phone != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          hotline.phone!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.6),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (hotline.isPhoneHotline || hotline.isWebsiteHotline) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: hotline.isPhoneHotline
                    ? ElevatedButton.icon(
                        onPressed: () => _callHotline(context),
                        icon: const Icon(Icons.phone, size: 18),
                        label: Text(l10n.emergencyCall),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: () => _openWebsite(context),
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: Text(l10n.actionOpen),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _callHotline(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    try {
      await emergencyService.callHotline(hotline.phone!);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.emergencyErrorCall(e.toString()))),
      );
    }
  }

  Future<void> _openWebsite(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    try {
      await emergencyService.openWebsite(hotline.website!);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.emergencyErrorOpen(e.toString()))),
      );
    }
  }
}
