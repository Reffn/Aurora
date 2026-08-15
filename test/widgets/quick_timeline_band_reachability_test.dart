import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/services/timeline_data_service.dart';
import 'package:dis_app/widgets/quick_timeline_band.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Eine Fläche sieht nur dann nach Handlung aus, wenn sie eine ist.
///
/// Ohne das Recht auf die Zeitachse führte der Griff ins Band eine Welle aus
/// und dann nichts. Wer das erlebt, sucht den Fehler bei sich.
void main() {
  final profil = Profile(
    id: 'lina',
    nameRaw: 'Lina',
    preferredColorValue: 0xFFAA66CC,
    createdAt: DateTime(2026, 8),
  );

  final marke = TimelineEvent(
    id: 'e1',
    type: TimelineEventType.profileSwitch,
    timestamp: DateTime(2026, 8, 7, 10),
    title: 'Wechsel',
    data: const {'toProfileId': 'mina'},
  );

  Widget bandMit(VoidCallback? onTap) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('de'),
        home: Scaffold(
          body: QuickTimelineBand(
            profile: profil,
            pastEvents: [marke],
            upcomingEvents: const [],
            profileNameOf: (_) => 'Mina',
            onTap: onTap,
          ),
        ),
      );

  testWidgets('mit erreichbarem Ziel ist das Band anklickbar', (tester) async {
    var getippt = 0;
    await tester.pumpWidget(bandMit(() => getippt++));
    await tester.pumpAndSettle();

    expect(find.byType(InkWell), findsOneWidget);
    await tester.tap(find.byType(InkWell));
    expect(getippt, 1);
  });

  testWidgets('ohne Ziel bleibt das Band reine Orientierung', (tester) async {
    await tester.pumpWidget(bandMit(null));
    await tester.pumpAndSettle();

    expect(
      find.byType(InkWell),
      findsNothing,
      reason: 'kein Ripple, kein Knopf-Eindruck ohne Wirkung',
    );
  });
}
