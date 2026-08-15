import 'package:dis_app/core/data_entry.dart';
import 'package:dis_app/core/di/injection.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/main.dart';
import 'package:dis_app/models/permission.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/modules/onboarding/post_login_welcome_screen.dart';
import 'package:dis_app/modules/profile/profile_creation_screen.dart';
import 'package:dis_app/modules/profile/widgets/app_info_overlay.dart';
import 'package:dis_app/modules/profile/widgets/profile_avatar.dart';
import 'package:dis_app/modules/settings/widgets/impressum_overlay.dart';
import 'package:dis_app/modules/settings/widgets/privacy_overlay.dart';
import 'package:dis_app/services/gps_manager.dart';
import 'package:dis_app/services/timeline_data_service.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:dis_app/utils/custom_snackbar.dart';
import 'package:dis_app/utils/position_age.dart';
import 'package:dis_app/utils/safe_area_extensions.dart';
import 'package:dis_app/widgets/gradient_text.dart';
import 'package:dis_app/widgets/profile_actions_dialog.dart';
import 'package:dis_app/widgets/time_map.dart';
import 'package:dis_app/widgets/today_overview_line.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Screen zur Auswahl eines Profils beim App-Start
/// Modernes Design mit Aurora-Logo und App-Beschreibung
///
/// WICHTIG: Loading Screen wird jetzt in main.dart gezeigt (SplashScreen)
/// Dieser Screen wird nur angezeigt wenn Essential Services bereits geladen sind
class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({
    this.onProfileSelected,
    super.key,
  });

  /// Wird nur bei einer laufenden App-Sitzung gesetzt. Der normale App-Start
  /// behält dadurch seine bisherige Navigation, während eine Sitzungssperre
  /// selbst entscheiden kann, ob sie zur alten Ansicht zurückkehrt.
  final Future<void> Function(Profile profile)? onProfileSelected;

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

/// Wann dieser Anteil zuletzt vorn war.
///
/// „Zuletzt vor drei Tagen" ist für viele die eigentliche Frage beim Öffnen
/// der App: Wie lange war ich weg. Sie steht klein und farblos unter dem
/// Namen — angeboten, nicht aufgedrängt. Die Antwort kann erschrecken, und wer
/// sie nicht sucht, soll nicht über sie stolpern.
///
/// Für Anteile mit Passwort steht dort nichts. Diese Fläche sieht auch ein
/// Dritter mit dem Gerät in der Hand, und wann jemand vorn war, ist eine
/// Auskunft über ihn — dieselbe Schwelle wie beim Weg und bei den Marken.
///
/// Ohne Wechsel in der Aufzeichnung steht dort ebenfalls nichts. „Noch nie"
/// wäre bei einem frisch angelegten Anteil richtig und bei einem alten, dessen
/// Wechsel aus dem Fenster gelaufen sind, falsch.
/// [texts] kommt aus dem Context des Schirms und muss mitgereicht werden.
///
/// Ohne sie griffe `formatPositionAge` auf die globale Sprache zurück, und
/// die trägt, was zuletzt vorn war. Auf einem italienisch eingestellten
/// Anteil stand dann „zuletzt 6 minuti fa" — der Rahmen in einer Sprache,
/// die Zeitangabe darin in einer anderen.
String? _lastFront(Profile profile, AppLocalizations texts) {
  if (profile.passwordHash != null) return null;
  if (!getIt.isRegistered<TimelineDataService>()) return null;

  DateTime? newest;
  for (final event in getIt<TimelineDataService>().profileSwitchBox.values) {
    if (event.toProfileId != profile.id) continue;
    if (newest == null || event.timestamp.isAfter(newest)) {
      newest = event.timestamp;
    }
  }
  if (newest == null) return null;
  return formatPositionAge(
    DateTime.now().difference(newest),
    texts: texts,
  );
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen>
    with SingleTickerProviderStateMixin {
  final _dataEntry = getIt<DataEntry>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  /// Ab diesem Schriftfaktor rollt der ganze Schirm.
  ///
  /// Die gemessenen Chrome-Zahlen unten gelten für Schriftfaktor 1,0. Wer
  /// größer stellt, bekommt kein gerechnetes Layout mehr, sondern eine
  /// Fläche, die einfach wächst. Schrift zu begrenzen wäre für diese
  /// Zielgruppe keine gleichwertige Lösung: Große Systemschrift ist bei
  /// Stress, Sehschwäche und Erschöpfung die naheliegende Selbsthilfe.
  static const double rollschwelle = 1.3;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    // Starte Fade-in Animation sofort
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Behandelt Profil-Auswahl: Zeigt Dialog mit Passwort-Check,
  /// navigiert dann zu PostLoginWelcome oder MainScreen
  Future<void> _handleProfileSelection(
    BuildContext context,
    Profile profile,
  ) async {
    // Breadcrumb: Profile selected
    logger.breadcrumb(
      BreadcrumbType.navigation,
      'Profile selected on ProfileSelectionScreen',
      data: {'profileId': profile.id.substring(0, 8)},
    );

    // Zeige ProfileActionsDialog (inkl. Passwort-Check)
    await ProfileActionsDialog.show(
      context,
      profile,
      // Ein Rückruf kennzeichnet die Auswahl innerhalb einer laufenden,
      // gesperrten Sitzung. Dann bestätigt sich auch der bisherige Anteil neu.
      requireCurrentProfileLogin: widget.onProfileSelected != null,
    );

    // Nach Dialog-Close: Prüfe ob Profil gewechselt wurde.
    // Beide Prüfungen, weil beide gebraucht werden: `mounted` gehört zum
    // State, `context` ist hier ein Parameter und kann zu einem Element
    // gehören, das schon weg ist, während der State noch lebt.
    if (!mounted || !context.mounted) return;

    final activeProfile = _dataEntry.getActiveProfile();

    // Wenn zu diesem Profil gewechselt wurde
    if (activeProfile?.id == profile.id) {
      try {
        final onProfileSelected = widget.onProfileSelected;
        if (onProfileSelected != null) {
          await onProfileSelected(activeProfile!);
          return;
        }

        // Prüfe ob Post-Login Welcome bereits gesehen wurde
        if (!activeProfile!.hasSeenPostLoginWelcome) {
          logger.info(
            LogCategory.ui,
            'Navigating to PostLoginWelcomeScreen',
            data: {'profileId': activeProfile.id.substring(0, 8)},
          );

          // Breadcrumb: Welcome screen
          logger.breadcrumb(
            BreadcrumbType.navigation,
            'Navigate to PostLoginWelcomeScreen',
          );

          // Zeige Post-Login Welcome Screen
          final nav = Navigator.of(context);
          await nav.pushReplacement(
            MaterialPageRoute<void>(
              builder: (context) => PostLoginWelcomeScreen(
                profile: activeProfile,
                onComplete: () async {
                  // Markiere Welcome als gesehen
                  final dataEntry = getIt<DataEntry>();
                  final updatedProfile = activeProfile.copyWith(
                    hasSeenPostLoginWelcome: true,
                  );
                  await dataEntry.updateProfile(updatedProfile);

                  // Navigiere zu MainScreen
                  if (context.mounted) {
                    logger.breadcrumb(
                      BreadcrumbType.navigation,
                      'Navigate to MainScreen from Welcome',
                    );

                    await Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (context) => const MainScreen(),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        } else {
          logger.info(
            LogCategory.ui,
            'Navigating directly to MainScreen',
            data: {'profileId': activeProfile.id.substring(0, 8)},
          );

          // Breadcrumb: MainScreen
          logger.breadcrumb(
            BreadcrumbType.navigation,
            'Navigate to MainScreen',
          );

          // Welcome bereits gesehen - direkt zu MainScreen
          final nav = Navigator.of(context);
          await nav.pushReplacement(
            MaterialPageRoute<void>(builder: (context) => const MainScreen()),
          );
        }
      } catch (e, stackTrace) {
        logger.error(
          LogCategory.ui,
          'Error during post-login navigation',
          data: {
            'profileId': profile.id.substring(0, 8),
            'error': e.toString(),
            'errorType': e.runtimeType.toString(),
          },
          stackTrace: stackTrace,
        );

        if (mounted && context.mounted) {
          final errorMsg = AppLocalizations.of(
            context,
          ).errorGeneric(e.toString());
          showCustomSnackBar(
            context,
            message: errorMsg,
            type: SnackBarType.error,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildFullScreen(context);
  }

  // Hier standen _recentPresence, _recentSwitches, _isPrivate und
  // _placeNear: die Daten fuer das Anwesenheitsband ueber der Wahl.
  // Die Zeitkarte hat das Band am 7. August 2026 abgeloest und gibt
  // dieselbe Auskunft besser — sie zeigt den Weg, nicht nur den
  // Endpunkt. Die Datenschutzregel dahinter ist nicht verlorengegangen:
  // Anteile mit Passwort bleiben draussen, das erledigt jetzt
  // TimeMap.fromServices(hidePasswordProtected: true) weiter unten.

  /// Baut vollständigen ProfileSelectionScreen mit allen Features
  ///
  /// Diese Fläche ist eine Wahlfläche (Richtlinie 2): feste, überschaubare
  /// Menge gleichrangiger Ziele. Sie hat genau eine Aufgabe — sich selbst
  /// finden — und gehört deshalb den Profilen. Logo und Wortmarke stehen
  /// als Kopfzeile daneben, nicht als Bühne darüber: Store-Material richtet
  /// sich an jemanden, der die App noch nicht kennt, diesen Schirm sieht man
  /// beim fünfhundertsten Start.
  Widget _buildFullScreen(BuildContext context) {
    return Scaffold(
      // Der Verlauf endet mit dem Inhalt, sobald der Schirm nicht voll ist.
      // Die Grundfarbe ist deshalb der Endton des Verlaufs — sonst steht
      // unter der Auswahl eine sichtbare Kante.
      backgroundColor: AppColors.inkDeep,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.ink, AppColors.inkDeep],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Kachelbreite kommt aus der verfügbaren Breite, nicht aus
                // einer festen Zahl: zwei Spalten am Telefon, mehr am Tablet.
                const outerPadding = 16.0;
                const columnGap = 16.0;
                final available = constraints.maxWidth - outerPadding * 2;

                // Berechne columns und avatarDiameter EINMAL hier — beide branches
                // und der Budget-Rechner müssen die gleichen Zahlen benutzen.
                // Die Deviation wurde am 10.08.2026 mit S24-Clipping erkannt: zwei
                // Rechnungen → zwei Grid-Layouts → Budget passt nicht zum Rendering.
                var columns = (available / (96 + columnGap)).floor();
                if (columns < 1) columns = 1;
                if (columns > 4) columns = 4;

                final tileWidth =
                    (available - columnGap * (columns - 1)) / columns;
                // Der Kreis bleibt in der Kachel, deckelt aber bei 148 dp.
                // Die Zahl ist gemessen, nicht gewählt: Kopf, Zeitzeile und
                // Frage brauchen 216 dp, ein Telefon lässt rund 600 dp für
                // das Raster. Eine Reihe kostet Durchmesser + 60 dp, drei
                // Reihen passen bis 149 dp. Darüber fällt die dritte Reihe
                // unter die Falz — und mit ihr zwei Anteile.
                final avatarDiameter = tileWidth > 148.0
                    ? 148.0
                    : (tileWidth < 96.0 ? 96.0 : tileWidth);

                // Diese Fläche steht vor jeder Anmeldung. Anteile mit
                // Passwort bleiben deshalb ganz draußen — Lauflinie,
                // Wechselpunkte und Marken.
                // Die Karte nimmt, was übrig bleibt — nicht umgekehrt.
                //
                // Bei festen 260 dp stand am S24 mit zwei Anteilen „Lina" und
                // „Mina" halb unter der Kante: Kopf, Tageszeile, Karte, Frage
                // und eine Rasterreihe kamen zusammen auf etwas mehr, als der
                // Schirm hergibt. Erreichbar war der Name durch Rollen, aber
                // die eine Angabe, die man auf dieser Fläche lesen muss, war
                // die erste, die verschwand. Die Reihenfolge ist damit
                // festgelegt: erst die Wahl vollständig, dann so viel Karte,
                // wie danach noch hineinpasst.
                //
                // Die Zahlen sind gemessen, nicht gewählt: Kopf 60, Tageszeile
                // 40, die beiden Überschriften mit ihren Abständen 148,
                // Fußzeile 44. Eine Rasterreihe kostet den Durchmesser plus 62
                // (Name plus Zeilenabstand).
                final profileCount = _dataEntry.getProfiles().length + 1;
                final rows = (profileCount / columns).ceil();
                const chrome = 60.0 + 40.0 + 148.0 + 44.0;
                final rasterHeight = rows * (avatarDiameter + 62);

                // Bei großer Schrift rollt der ganze Schirm, nicht nur die
                // Wahl in der Mitte. Das ermöglicht es, alle Inhalte zu
                // erreichen, auch wenn das Layout zusammenpresst.
                // Die abgeleitete Skala wird nur für die Layout-Verzweigung begrenzt —
                // wie Text wirklich gerendert wird, entscheidet ausschließlich die
                // Systemschrift. Aurora begrenzt nie die Schriftgröße der Nutzerin.
                final skala = (MediaQuery.textScalerOf(context).scale(14) / 14)
                    .clamp(0.5, 3.0);

                // Seit Aufgabe 2 trägt die Zeitkarte den Standorthinweis
                // unter sich, statt ihn in den Stapel zu legen. Ohne
                // Standortrecht wächst sie also — und zwar auch bei
                // Normalschrift. Wird das nicht vom Kartenbudget abgezogen,
                // fallen die Namen bei 100 % unter die Kante: derselbe
                // Fehler wie vorher, nur eine Ebene tiefer.
                final hinweisHoehe = getIt<GpsManager>().hasGpsPermission.value
                    ? 0.0
                    : 56.0 * skala;

                // Berechne das verfügbare Budget für die Karte BEVOR sie begrenzt wird.
                // Am S24 und 10.08.2026 reichte das Budget bei 1.0x nicht aus:
                // chrome (292) + rasterHeight (420) + hinweisHoehe (56) = 768,
                // übrig = 780 - 768 = 12 dp. Die alte clamp(150, 260) hob das
                // auf 150 und drückte das Raster unter die Falz (Y > 780).
                // Neue Regel: Wenn Budget < 150, nutze den Rollzweig (sicherer).
                final rest =
                    constraints.maxHeight -
                    chrome -
                    rasterHeight -
                    hinweisHoehe;
                final rollt = skala >= rollschwelle || rest < 150.0;

                final mapHeight = rollt
                    // In der Rollfläche konkurriert die Karte nicht mehr mit
                    // der Wahl um dieselbe Höhe. Sie bekommt ein bescheidenes
                    // festes Maß und darf den Rest der Fläche wachsen lassen.
                    ? 180.0
                    : rest.clamp(150.0, 260.0);

                final timeMap = TimeMap.fromServices(
                  height: mapHeight,
                  hidePasswordProtected: true,
                );

                // Oben die Lage, unten das Rechtliche, beide fest. Die Wahl
                // bekommt den Rest und sitzt darin mittig.
                //
                // Nicht mit `spaceBetween` über drei Blöcke: Das schiebt den
                // Kopf hoch und die Wahl in die Schirmmitte, und zwischen
                // beiden steht dann die Leere, die vorher unten stand. Sie
                // wandert, sie verschwindet nicht.

                if (rollt) {
                  // Kopf, Karte, Wahl und Rechtslinks in einer Rollfläche:
                  // Bei 200 % passt keine Aufteilung mehr, die etwas fest
                  // hält. Wer rollt, findet alles; wer nichts rollen kann,
                  // sieht wenigstens nichts Abgeschnittenes.
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: context.safeBottomPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: outerPadding,
                            vertical: 12,
                          ),
                          child: _buildHeader(context),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: outerPadding,
                          ),
                          child: timeMap,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: outerPadding,
                          ),
                          child: Text(
                            AppLocalizations.of(
                              context,
                            ).profileSelectionTitle,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.75),
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: outerPadding,
                          ),
                          child: _buildProfileGrid(
                            context,
                            columns: columns,
                            avatarDiameter: avatarDiameter,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: outerPadding,
                          ),
                          child: _buildLegalLinks(context),
                        ),
                      ],
                    ),
                  );
                }

                // Standard-Layout: Kopf und Fuß fest, Wahl rollt in der Mitte.
                // Die Wahl rollt für sich, falls viele Anteile da sind. Kopf
                // und Fußzeile bleiben dabei stehen — die Zeitangabe soll
                // nicht weggescrollt werden können.
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: outerPadding,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(context),

                          // „Wann bin ich" vor „wer bin ich": Diese Fläche ist
                          // das Erste nach dem Aufwachen, und Zeitverlust
                          // gehört zum Krankheitsbild.
                          //
                          // Trägt die Zeitkarte, steht das vollständige Datum
                          // an ihrem Jetzt-Ende und diese beiden Zeilen
                          // entfallen. Zweimal dasselbe Datum kostet nur den
                          // Platz, den die Karte braucht — und die Karte sagt
                          // dazu, wo man war.

                          // „Was dieser Tag trägt", hier als bloße ZAHLEN.
                          //
                          // Termine und Medikamente gelten dem Körper, nicht
                          // dem Anteil — sie stehen deshalb schon vor der
                          // Wahl da, für jeden. Ohne Rechteprüfung, weil es
                          // vor der Anmeldung kein Profil gibt, dessen Rechte
                          // gälten.
                          //
                          // Es bleiben Zahlen: Titel, Uhrzeiten und Präparate
                          // erscheinen erst nach der Wahl. Diese Fläche sieht
                          // auch ein Dritter mit dem Gerät in der Hand, und
                          // ein Präparatname verrät eine Diagnose.
                          TodayOverviewLine(
                            profile: null,
                            gateByPermissions: false,
                            centered: true,
                            // Über DataEntry, nicht über die Dienste: Der
                            // Weg durch die UI geht durch die eine Tür
                            // (`no_direct_service_access`).
                            countEventsForDay: (day) =>
                                _dataEntry.getCalendarEventsForDay(day).length,
                            countMedicationsToday: () =>
                                _dataEntry.getTodaysMedications().length,
                          ),
                        ],
                      ),

                      Expanded(
                        // `Center` gibt der Rollfläche lose Vorgaben, damit
                        // sie sich auf ihren Inhalt zusammenzieht statt die
                        // volle Höhe zu nehmen. Nur so sitzt die Wahl mittig,
                        // solange sie passt, und rollt erst, wenn nicht.
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Erst „Wer war da?", dann „Wer bist du?".
                                // Die Reihenfolge ist die Aussage: Wer die
                                // App öffnet, hat oft Stunden verloren. Die
                                // Antwort darauf steht vor der Frage nach
                                // dem eigenen Namen, nicht dahinter.
                                // Entweder die Zeitkarte oder die Zeilen,
                                // nie beides: Die obere Randleiste der Karte
                                // sagt bereits, wer wann da war. Daneben
                                // dieselbe Auskunft als Text wäre nicht mehr
                                // Information, nur mehr Fläche.
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  ).presenceRecentTitle,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.55),
                                    letterSpacing: 0.3,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                                timeMap,
                                const SizedBox(height: 40),

                                // Leiser als die Namen darunter. Die Frage wird
                                // einmal gelernt, die Namen liest man bei jedem
                                // Start — der Inhalt gehört nach vorn, nicht die
                                // Überschrift.
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  ).profileSelectionTitle,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.75),
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                const SizedBox(height: 28),

                                // Profil-Raster. Die Reihenfolge ist die der
                                // Profile selbst (Richtlinie 7) — „Neues Profil"
                                // steht hinten, damit ein neuer Anteil keinen
                                // bestehenden verschiebt.
                                _buildProfileGrid(
                                  context,
                                  columns: columns,
                                  avatarDiameter: avatarDiameter,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      _buildLegalLinks(context),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Profil-Raster mit optionalen Scrolling-Einstellungen.
  ///
  /// Das Raster zeigt alle existierenden Profile plus einen "Neues Profil"-Button.
  /// Die Reihenfolge entspricht der Profilreihenfolge (Richtlinie 7).
  ///
  /// `columns` und `avatarDiameter` werden vom LayoutBuilder übergeben, damit
  /// die Höhenrechnung und das Rendering synchron bleiben. Doppeltes Rechnen
  /// führt zu Mismatches: am 10.08.2026 reichte das Budget am S24 nicht aus.
  Widget _buildProfileGrid(
    BuildContext context, {
    required int columns,
    required double avatarDiameter,
  }) {
    const outerPadding = 16.0;
    const columnGap = 16.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - (outerPadding * 2);
    final tileWidth = (availableWidth - (columnGap * (columns - 1))) / columns;

    return ValueListenableBuilder(
      valueListenable: _dataEntry.profilesBox.listenable(),
      builder: (context, box, _) {
        final profiles = _dataEntry.getProfiles();

        return Wrap(
          spacing: columnGap,
          runSpacing: 28,
          alignment: WrapAlignment.center,
          children: [
            ...profiles.map((profile) {
              final lastFront = _lastFront(
                profile,
                AppLocalizations.of(context),
              );
              return SizedBox(
                width: tileWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ProfileAvatar(
                      profile: profile,
                      size: avatarDiameter,
                      nameFontSize: 20,
                      onTap: () async {
                        await _handleProfileSelection(
                          context,
                          profile,
                        );
                      },
                      onLongPress: () {
                        _showProfileOptions(
                          context,
                          profile,
                        );
                      },
                    ),
                    if (lastFront != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          AppLocalizations.of(context).presenceLastFront(
                            lastFront,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
            SizedBox(
              width: tileWidth,
              child: _buildAddProfileButton(
                context,
                avatarDiameter,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Kopfzeile: Marke links, Info rechts. Das Chamäleon bleibt konstant und
  /// signalisiert nie — es trägt hier nur die Wiedererkennung.
  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Image.asset('assets/images/logo_rainbow.png', height: 44),
        const SizedBox(width: 10),
        const GradientText(
          'Aurora',
          gradient: kAuroraRainbowGradient,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: l10n.aboutAuroraSemantics,
          icon: Semantics(
            enabled: false,
            child: const Icon(
              Icons.info_outline,
              color: AppColors.paper,
              size: 28,
            ),
          ),
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (context) => const AppInfoOverlay(),
            );
          },
        ),
      ],
    );
  }

  /// Rechtliche Links. Wrap statt Row für Umbruch auf kleinen Bildschirmen.
  Widget _buildLegalLinks(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        InkWell(
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (context) => const ImpressumOverlay(),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              AppLocalizations.of(context).settingsImpressum,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.paper.withValues(alpha: 0.6),
                decoration: TextDecoration.underline,
                decorationColor: AppColors.paper.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
        Text(
          '  •  ',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.paper.withValues(alpha: 0.4),
          ),
        ),
        InkWell(
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (context) => const PrivacyOverlay(),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              AppLocalizations.of(context).settingsPrivacy,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.paper.withValues(alpha: 0.6),
                decoration: TextDecoration.underline,
                decorationColor: AppColors.paper.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// „Neues Profil" trägt dieselbe Kachelgröße wie ein Anteil, aber keine
  /// Farbfläche: gesättigte Fläche ist den Anteilen vorbehalten (Richtlinie 4).
  Widget _buildAddProfileButton(BuildContext context, double diameter) {
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.profileNewProfile,
      child: GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const ProfileCreationScreen(),
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Kleiner als ein Anteil und in derselben Zeile mittig: Hier steht
            // kein Mensch, sondern eine Verwaltungshandlung. Gleich groß hat er
            // mit den Anteilen um den Blick konkurriert (Richtlinie 2). Die
            // Kachelhöhe bleibt, damit die Namen darunter auf einer Linie
            // liegen.
            SizedBox(
              height: diameter,
              child: Center(
                child: Container(
                  width: diameter * 0.58,
                  height: diameter * 0.58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withAlpha(60),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    size: diameter * 0.28,
                    color: Colors.white54,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Text
            Text(
              AppLocalizations.of(context).profileNewProfile,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileOptions(BuildContext context, Profile profile) {
    final activeProfile = _dataEntry.getActiveProfile();
    final canDeactivate =
        activeProfile?.hasPermission(Permission.deactivateProfiles) ?? false;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1F1F1F),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: Text(
                AppLocalizations.of(context).actionEdit,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                showCustomSnackBar(
                  context,
                  message: AppLocalizations.of(context).profileEditComingSoon,
                );
              },
            ),
            if (canDeactivate)
              ListTile(
                leading: const Icon(Icons.block, color: Colors.orange),
                title: Text(
                  AppLocalizations.of(context).profileDeactivate,
                  style: const TextStyle(color: Colors.orange),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeactivate(context, profile);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDeactivate(BuildContext context, Profile profile) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        title: Text(
          AppLocalizations.of(context).profileDeactivateTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          AppLocalizations.of(context).profileDeactivateMessage(profile.name),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).actionCancel),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _dataEntry.deactivateProfile(profile.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  showCustomSnackBar(
                    context,
                    message: AppLocalizations.of(context).profileDeactivated,
                    type: SnackBarType.success,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  showCustomSnackBar(
                    context,
                    message: AppLocalizations.of(
                      context,
                    ).errorGeneric(e.toString()),
                    type: SnackBarType.error,
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context).actionDelete),
          ),
        ],
      ),
    );
  }
}
