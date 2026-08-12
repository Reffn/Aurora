import 'package:dis_app/l10n/app_texts.dart';
import 'package:dis_app/models/feedback_payload.dart';
import 'package:dis_app/services/transport/feedback_transport.dart';
import 'package:dis_app/utils/contact_config.dart';
import 'package:url_launcher/url_launcher.dart';

/// Injizierbar, damit der Versand ohne Plattformkanal testbar bleibt.
typedef UrlLauncher = Future<bool> Function(Uri uri);

/// Öffnet den Mail-Client mit vorausgefülltem Text.
///
/// Gleichwertige Alternative zum Firestore-Weg, nicht bloß ein Notfall-Fallback:
/// Wer selbst per Mail schickt, sieht den vollen Inhalt und behält eine Kopie.
class MailtoTransport implements FeedbackTransport {
  MailtoTransport({UrlLauncher? launcher})
    : _launcher = launcher ?? _defaultLauncher;

  final UrlLauncher _launcher;

  static Future<bool> _defaultLauncher(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);

  /// Marker für das CI-Tor: Diese Zeichenkette muss im gebauten Artefakt
  /// auftauchen, sonst hat der Compiler den Transport entfernt und der
  /// Rückkanal wäre still tot. Bewusst reines ASCII — Dart legt Strings
  /// unter 256 als Latin-1 ab, ein Umlaut würde anders kodiert als das
  /// Suchmuster in .github/workflows/test.yml. Nicht loeschen, nicht
  /// uebersetzen: der Nutzertext dafuer steht in transportNoMailApp.
  static const String ciMarker =
      'Du kannst den Text kopieren und manuell senden.';

  /// Immer verfügbar — es gibt nichts zu konfigurieren.
  @override
  bool get isConfigured => true;

  @override
  String get displayName => 'E-Mail';

  Uri buildUri(FeedbackPayload payload) {
    return Uri(
      scheme: 'mailto',
      path: ContactConfig.supportEmail,
      queryParameters: {
        'subject': '${ContactConfig.appName} Feedback: ${payload.category}',
        'body': payload.toPlainText(),
      },
    );
  }

  @override
  Future<TransportResult> send(FeedbackPayload payload) async {
    final opened = await _launcher(buildUri(payload));

    if (opened) {
      return const TransportResult.success();
    }
    // Fällt die Lokalisierung aus, trägt der Marker den Satz.
    final text = AppTexts.current.transportNoMailApp;
    return TransportResult.failure(text.isEmpty ? ciMarker : text);
  }
}
