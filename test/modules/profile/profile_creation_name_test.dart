import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/modules/profile/profile_creation_screen.dart';
import 'package:dis_app/services/permission_preset_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ein pausierter Anteil hält seinen Namen.
///
/// Seit das Pausieren wirkt, fehlt ein pausierter Anteil in `getProfiles()`.
/// Prüfte die Anlage nur dort, bekam ein neuer Anteil seinen Namen, und nach
/// dem Wiederaufnehmen stünden zwei gleichnamige in der Auswahl.
class _FakeDataEntry implements DataEntry {
  _FakeDataEntry(this._active, this._paused);

  final List<Profile> _active;
  final List<Profile> _paused;
  final List<Profile> created = [];

  @override
  List<Profile> getProfiles() => _active;

  @override
  List<Profile> getAllProfiles() => [..._active, ..._paused];

  @override
  Future<void> createProfile(Profile profile, {String source = 'UI'}) async {
    created.add(profile);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Profile _profil(String id, String name, {bool isActive = true}) => Profile(
  id: id,
  nameRaw: name,
  preferredColorValue: 0xFF3366CC,
  createdAt: DateTime(2026, 10, 29),
  isActive: isActive,
);

void main() {
  late _FakeDataEntry dataEntry;

  setUp(() async {
    await getIt.reset();
    dataEntry = _FakeDataEntry(
      [_profil('lou', 'Lou')],
      [_profil('mira', 'Mira', isActive: false)],
    );
    // Ohne `initialize()` liefert der Vorlagendienst leere Vorlagen. Das
    // genügt: Ohne Namensprüfung käme die Anlage damit bis zum Speichern.
    getIt
      ..registerSingleton<DataEntry>(dataEntry)
      ..registerSingleton<PermissionPresetService>(PermissionPresetService());
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('der Name eines pausierten Anteils ist vergeben', (
    tester,
  ) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('de'));

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // Das Logo pulsiert sonst endlos.
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(900, 1400),
          ).copyWith(disableAnimations: true),
          child: const ProfileCreationScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Seite 2: Name, anders geschrieben als beim pausierten Anteil.
    await tester.tap(find.textContaining(l10n.actionContinue));
    // Der erste Frame startet das Blättern, der zweite beendet es.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(find.byType(TextField).first, 'mira');
    await tester.pump();

    // Direkt zur letzten Seite; Farbe, Alter und Passwort spielen keine Rolle.
    tester.widget<PageView>(find.byType(PageView)).controller!.jumpToPage(4);
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text(l10n.profileActionCreateProfile));
    await tester.pump(const Duration(milliseconds: 100));

    expect(dataEntry.created.map((p) => p.name), isEmpty);
    expect(find.text(l10n.profileNameExists), findsOneWidget);

    // Die Meldung verschwindet nach ihrer Zeit; der Timer muss ablaufen.
    await tester.pump(const Duration(seconds: 4));
  });
}
