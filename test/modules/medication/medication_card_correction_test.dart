import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/medication.dart';
import 'package:dis_app/modules/medication/widgets/medication_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Befund 5 des Gerätetests: nach „Später" und nach „Genommen" verschwand
/// die Knopfreihe. Ein Fehlgriff war damit fest — und im Test lag „Später"
/// einen Daumen von „Genommen" entfernt.
///
/// Korrigieren muss billiger sein als Festlegen.
Widget _rahmen(Widget child) => MaterialApp(
      locale: const Locale('de'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  final medikament = Medication(
    id: 'm1',
    name: 'Testmed',
    dosage: '1 Tablette',
    timesOfDay: const ['12:50'],
    profileIds: const ['lina'],
    createdAt: DateTime(2026, 8),
  );

  Widget karte(MedicationStatus? status, {VoidCallback? onTaken}) =>
      MedicationCard(
        medication: medikament,
        timeOfDay: '12:50',
        status: status,
        onTap: () {},
        onMarkTaken: onTaken ?? () {},
        onMarkRefused: () {},
        onSnooze: () {},
      );

  for (final status in <MedicationStatus?>[
    null,
    MedicationStatus.taken,
    MedicationStatus.refused,
    MedicationStatus.snoozed,
  ]) {
    testWidgets(
      'Status ${status?.name ?? 'offen'}: alle drei Knoepfe bleiben da',
      (tester) async {
        await tester.pumpWidget(_rahmen(karte(status)));
        final l10n = await AppLocalizations.delegate.load(const Locale('de'));

        expect(find.text(l10n.medicationStatusTaken), findsOneWidget);
        expect(find.text(l10n.medicationStatusRefused), findsOneWidget);
        expect(find.text(l10n.medicationStatusSnoozed), findsOneWidget);
      },
    );
  }

  testWidgets('Nach „Spaeter" laesst sich noch „Genommen" tippen',
      (tester) async {
    var genommen = false;
    await tester.pumpWidget(
      _rahmen(karte(MedicationStatus.snoozed, onTaken: () => genommen = true)),
    );
    final l10n = await AppLocalizations.delegate.load(const Locale('de'));

    await tester.tap(find.text(l10n.medicationStatusTaken));
    await tester.pump();

    expect(genommen, isTrue);
  });
}
