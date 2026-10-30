/// Konfiguration für Entwickler-Kontakt URLs und Branding
class ContactConfig {
  /// Support E-Mail-Adresse (aus Impressum)
  static const String supportEmail = 'info@3ofus.app';

  /// Discord Server Invite-URL (leer = wird nicht angezeigt)
  ///
  /// Eine eigene Weiterleitung, kein Einladungscode: `3ofus.net/discord`
  /// leitet per 302 auf die Einladung (`F:\3ofus-web\firebase.json`). Der
  /// Code stand bis 3.0.23 fest hier, lief ab und machte den Link in jeder
  /// ausgelieferten Fassung tot (`Unknown Invite`, gefunden 29.10.2026).
  /// Jetzt lässt sich die Einladung tauschen, ohne eine neue Fassung zu bauen.
  static const String discordInviteUrl = 'https://3ofus.net/discord';

  /// Website-URL (aus Impressum)
  ///
  /// Ohne `www`: Für `www.3ofus.app` gibt es keinen DNS-Eintrag. Der Link
  /// auf dem Dankeschön-Schirm nach dem Feedback lief bis 3.0.23 ins Leere
  /// (gefunden 29.10.2026).
  static const String websiteUrl = 'https://3ofus.app';

  /// GitHub Repository URL (leer = wird nicht angezeigt)
  static const String githubRepoUrl = 'https://github.com/Reffn/Aurora';

  /// Newsletter Signup URL (leer = wird nicht angezeigt)
  /// z.B. Mailchimp, Sendinblue, etc.
  static const String newsletterSignupUrl = ''; // TODO: Newsletter-Service URL

  /// Entwickler-Team Name
  static const String teamName = '3ofus Team';

  /// App Name
  static const String appName = 'Aurora';

  /// Aurora Brand Color (Lila)
  static const int auroraPurple = 0xFF9D84B7;
}
