import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/hotline.dart';
import 'package:dis_app/modules/emergency/widgets/hotline_card.dart';
import 'package:dis_app/services/emergency_message_service.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:dis_app/widgets/section_header.dart';
import 'package:dis_app/widgets/standard_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Hilfsangebote-Screen
///
/// Die Fläche trägt drei Ebenen, und zwar in dieser Reihenfolge:
///
/// 1. **Der Notruf** für unmittelbare Gefahr. Er stand vorher nirgends,
///    obwohl die Fläche „Notfall-Hotlines" hieß.
/// 2. **Rund um die Uhr erreichbar** — nur Angebote, für die das wirklich
///    gilt.
/// 3. **Zu bestimmten Zeiten erreichbar** — mit den Zeiten auf der Karte.
///
/// Vorher stand alles in einer flachen Liste unter „24/7 Notfall-Hotlines /
/// jederzeit erreichbar". Das stimmte für zwei von fünf Einträgen. In einer
/// Krise ist ein erfolgloser Anruf keine neutrale Sackgasse: Die Person kann
/// daraus schließen, Hilfe sei gerade grundsätzlich nicht erreichbar.
///
/// **Nichts wird nach Uhrzeit ein- oder ausgeblendet.** Die Richtlinien
/// verlangen, dass Zustände angeboten und nicht erraten werden (Regel 9), und
/// dass die Reihenfolge eine Zusage ist (Regel 7). Wer die Liste kennt, findet
/// sie morgen genauso vor — die Zeiten stehen dabei, statt dass Aurora
/// entscheidet, was gerade sinnvoll ist.
class HelpResourcesScreen extends StatelessWidget {
  const HelpResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final emergencyService = getIt<EmergencyMessageService>();

    final hotlines = germanEmergencyHotlines();
    final rundUmDieUhr = hotlines.where((h) => h.isRoundTheClock).toList();
    final zuZeiten = hotlines.where((h) => !h.isRoundTheClock).toList();

    return Scaffold(
      appBar: const StandardAppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _NotrufStufe(emergencyService: emergencyService),

            const SizedBox(height: 28),

            SectionHeader(
              icon: Icons.phone_in_talk,
              title: l10n.helpTalkTitle,
              description: l10n.helpHotlinesSubtitle,
            ),
            const SizedBox(height: 20),

            _GruppenTitel(text: l10n.helpGroupRoundTheClock),
            ...rundUmDieUhr.map(
              (hotline) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: HotlineCard(
                  hotline: hotline,
                  emergencyService: emergencyService,
                ),
              ),
            ),

            const SizedBox(height: 16),

            _GruppenTitel(text: l10n.helpGroupLimitedHours),
            ...zuZeiten.map(
              (hotline) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: HotlineCard(
                  hotline: hotline,
                  emergencyService: emergencyService,
                ),
              ),
            ),

            const SizedBox(height: 8),
            Text(
              l10n.helpSourcesCheckedOn(
                DateFormat.yMd(l10n.localeName).format(
                  hotlineAngabenGeprueftAm,
                ),
              ),
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // Platzhalter für zukünftige Ressourcen
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.construction,
                    size: 48,
                    color: Colors.blue.shade300,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.helpMoreResourcesTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.helpMoreResourcesDescription,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Die Überschrift einer Erreichbarkeitsgruppe.
///
/// Ruhig gehalten: Die Gruppen ordnen, sie rufen nicht. Gesättigte Fläche
/// bleibt dem Notruf vorbehalten (Richtlinie 4).
class _GruppenTitel extends StatelessWidget {
  const _GruppenTitel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}

/// Der Weg für unmittelbare Gefahr.
///
/// Steht oben und trägt als einziges Element dieser Fläche eine gesättigte
/// Farbe — [AppColors.signal] ist im Farbmodell ausdrücklich für „Notruf"
/// vorgesehen. Richtlinie 4 erlaubt Sättigung für das, was im schlechtesten
/// Zustand gefunden werden muss; alles andere hier bleibt ruhig, damit dieser
/// eine Block nicht in einer lauten Fläche untergeht.
///
/// Der Knopf öffnet die Telefon-App mit vorgewählter Nummer. Aurora ruft
/// **nicht** von selbst an: `callHotline` baut eine `tel:`-Adresse, und die
/// öffnet unter Android den Wähler, statt eine Verbindung aufzubauen.
class _NotrufStufe extends StatelessWidget {
  const _NotrufStufe({required this.emergencyService});

  final EmergencyMessageService emergencyService;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.signal.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.signal, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emergency,
                color: AppColors.signal,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.helpEmergencyDangerTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.helpEmergencyDangerBody,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _oeffneWaehler(context),
              icon: const Icon(Icons.phone),
              label: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  l10n.helpEmergencyCallEmergencyNumber,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.signal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _oeffneWaehler(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    try {
      await emergencyService.callHotline('112');
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.emergencyErrorCall(e.toString()))),
        );
      }
    }
  }
}
