import 'package:dis_app/core/logger.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';

/// Startet Firebase — und zwar erst, wenn wirklich etwas gesendet wird.
///
/// ## Warum das nicht mehr im Startpfad steht
///
/// Bis zum 16.08.2026 rief `main.dart` `Firebase.initializeApp()` und
/// `FirebaseAppCheck.activate()` bedingungslos beim Start. Nicht nach der
/// Einwilligung, nicht beim ersten Feedback — bei jedem Kaltstart jeder
/// Installation, auch bei einem Menschen, der das Feedback-Formular nie
/// öffnet und die Telemetrie abgelehnt hat.
///
/// Was dabei das Gerät verließ, stand in keiner Nutzlast und deshalb in
/// keinem Schema-Test:
///
/// - **Firebase Installations** meldet die Installation bei Google an und holt
///   sich eine **Installations-ID** — eine dauerhafte Kennung je Installation,
///   zusammen mit Paketname, App-Version, Plattform und, unvermeidlich, der
///   IP-Adresse.
/// - **App Check** tauscht ein Play-Integrity-Urteil gegen ein Token. Das ist
///   eine von Google ausgestellte Gerätebescheinigung.
///
/// Damit standen drei Zusagen gleichzeitig falsch da — dieselben drei, die in
/// `AGENTS.md` unter „Datenschutz" als blockierend geführt werden:
///
/// 1. „Nichts verlässt das Gerät ohne ausdrückliche Zustimmung."
/// 2. „Alles Gesendete ist einsehbar" — das Übertragungsprotokoll kannte
///    diesen Weg nicht und zeigte „Es wurde noch nichts gesendet", während
///    die Verbindung längst stand.
/// 3. „Nichts erlaubt Wiedererkennung: … keine Installations-IDs." Für die
///    Nutzlast stimmte der Satz. Der Transport darunter trug die Kennung.
///
/// Der zweite Punkt wiegt am schwersten, und er erklärt die Bauform hier.
/// Man könnte den Handschlag ins Protokoll schreiben. Besser ist, ihn dann
/// stattfinden zu lassen, wenn ohnehin eine Übertragung protokolliert wird:
/// Startet Firebase erst beim Senden, ist der Handschlag Teil genau dieser
/// Übertragung, und der Schirm „Was Aurora sendet" stimmt wieder wörtlich —
/// ohne einen neuen Kanal, den fünf Sprachen erklären müssten.
///
/// Dieselbe Sorte Fehler wie die Cloud-Sicherung am 13.08.2026: eine
/// Plattform-Voreinstellung, die niemand angesehen hat.
/// Siehe `docs/befund-stiller-firebase-start.md`.
///
/// ## Warum ein Merker und keine Prüfung
///
/// `Firebase.initializeApp()` ein zweites Mal zu rufen ist erlaubt und gibt
/// dieselbe App zurück; `FirebaseAppCheck.activate()` ein zweites Mal zu rufen
/// stößt einen neuen Token-Tausch an. Ohne Merker zahlte jede Telemetrie-Runde
/// einen Netzabruf, den niemand braucht.
///
/// Der Merker hält das **laufende** Versprechen, nicht nur das erledigte:
/// Feedback und Telemetrie können sich überlappen (der Sender läuft aus einem
/// Formular, der Dispatcher aus `onRecorded`). Beide bekommen dasselbe
/// `Future` und damit einen Start, nicht zwei.
///
/// Nach einem Fehlschlag wird der Merker gelöscht. Wer beim ersten Versuch
/// kein Netz hatte, soll beim zweiten nicht an einem gespeicherten „nein"
/// hängen bleiben.
class FirebaseStart {
  FirebaseStart._();

  static Future<bool>? _laufenderStart;

  /// Nur für Tests: vergisst einen vorherigen Start.
  static void zuruecksetzenFuerTest() {
    _laufenderStart = null;
  }

  /// Stellt sicher, dass Firebase bereit ist. `false` heißt: Der Sendeweg über
  /// Firestore steht nicht zur Verfügung — die Aufrufer weichen dann auf ihren
  /// eigenen Weg aus (Feedback auf die Mail-App, Telemetrie zurück in die
  /// Warteschlange).
  ///
  /// Wirft nie. Ein Fehler hier darf keinen Bedienfluss abbrechen.
  static Future<bool> bereitmachen() {
    return _laufenderStart ??= _starten();
  }

  static Future<bool> _starten() async {
    final beginn = DateTime.now();
    try {
      await Firebase.initializeApp();

      // Anbieter ausgeschrieben, obwohl er dem Standard entspricht: Wovon die
      // Echtheitsprüfung abhängt, gehört sichtbar in den Code. Play Integrity
      // greift nur bei Installationen aus dem Play Store — seitlich geladene
      // Testbauten liefern deshalb kein gültiges Token, und die Console zählt
      // sie als „nicht bestätigt".
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
      );

      logger.info(
        LogCategory.service,
        'Firebase beim Senden gestartet',
        data: {
          'duration': '${DateTime.now().difference(beginn).inMilliseconds}ms',
        },
      );
      return true;
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.service,
        'Firebase-Start fehlgeschlagen — Feedback geht über die Mail-App',
        data: {'error': e.toString()},
        stackTrace: stackTrace,
      );
      // Den Merker löschen, damit der nächste Versuch wieder einer ist.
      _laufenderStart = null;
      return false;
    }
  }
}

/// Der Typ, den die Sendewege injiziert bekommen.
///
/// Als Funktion und nicht als Klasse, aus demselben Grund wie bei
/// `TransmissionRecorder`: Ein Widget- oder Einheitentest soll keinen
/// Firebase-Kanal aufsetzen müssen, um den Ablauf davor zu prüfen.
typedef FirebaseStarter = Future<bool> Function();

/// Der Weg für die App.
Future<bool> firebaseBeimSendenStarten() => FirebaseStart.bereitmachen();
