// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Aurora';

  @override
  String get appSubtitle => 'Deine sichere Begleiterin im Alltag mit DIS';

  @override
  String get appDescription =>
      'Aurora unterstützt dich beim Organisieren deines Alltags und der Kommunikation innerhalb deines Systems.';

  @override
  String get tabChat => 'Chat';

  @override
  String get tabFeedback => 'Feedback';

  @override
  String get tabCalendar => 'Kalender';

  @override
  String get tabMedication => 'Medikamente';

  @override
  String get tabDiary => 'Tagebuch';

  @override
  String get tabContacts => 'Kontakte';

  @override
  String get tabFinder => 'Finder';

  @override
  String get tabEmergency => 'Notfall';

  @override
  String get tabHelp => 'Hilfe';

  @override
  String get tabMantras => 'Mantras';

  @override
  String get tabGames => 'Spiele';

  @override
  String get tabTimeline => 'Zeitachse';

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionDelete => 'Löschen';

  @override
  String get actionEdit => 'Bearbeiten';

  @override
  String get actionClose => 'Schließen';

  @override
  String get actionContinue => 'Weiter';

  @override
  String get actionConfirm => 'Bestätigen';

  @override
  String get actionBack => 'Zurück';

  @override
  String get actionQuit => 'Beenden';

  @override
  String get actionSend => 'Senden';

  @override
  String get actionShare => 'Teilen';

  @override
  String get actionDone => 'Fertig';

  @override
  String get mainSettingLogout => 'Setting / Ausloggen';

  @override
  String get dialogExitTitle => 'App beenden?';

  @override
  String get dialogExitMessage => 'Möchtest du Aurora wirklich beenden?';

  @override
  String get menuProfileEdit => 'Profil bearbeiten';

  @override
  String get menuSettings => 'Einstellungen';

  @override
  String get menuLogout => 'Ausloggen';

  @override
  String get profileMenuTitle => 'Profil und Einstellungen';

  @override
  String get presenceRecentTitle => 'Wer war da?';

  @override
  String get eventLocationTitle => 'Wo findet der Termin statt?';

  @override
  String get eventLocationOther => 'Anderer Ort';

  @override
  String get eventLocationNone => 'Kein Ort';

  @override
  String get eventLocationLabel => 'Ort';

  @override
  String get eventLocationUnnamed => 'Ort auf der Karte';

  @override
  String get mapLocationNeeded =>
      'Aurora braucht den Standort für diese Karte. Er bleibt auf dem Gerät.';

  @override
  String get mapLocationAllow => 'Erlauben';

  @override
  String get profileSelectionTitle => 'Wer ist gerade da?';

  @override
  String get profileNewProfile => 'Neues Profil';

  @override
  String get profileCreationTitle => 'Neues Profil erstellen';

  @override
  String get profileCreationSubtitle => 'Wer möchte sich vorstellen?';

  @override
  String get profileCreationDescription =>
      'Erstelle dein persönliches Profil mit Namen, Farbe und Avatar. Jedes Profil kann individuell angepasst werden und erhält passende Berechtigungen basierend auf dem Alter.';

  @override
  String get profileEditTitle => 'Profil bearbeiten';

  @override
  String get profileEditSubtitle => 'Passe deine Einstellungen an';

  @override
  String get profileSectionIdentity => '👤 Identität';

  @override
  String get profileSectionAge => '🎂 Alter';

  @override
  String get profileSectionColor => '🎨 Farbe';

  @override
  String get profileSectionSecurity => '🔒 Sicherheitsfragen';

  @override
  String get profileWhoAreYou => 'Wer bist du?';

  @override
  String get profileWhoAreYouDescription =>
      'Gib deinen Namen ein und wähle einen Avatar. So können dich alle im System erkennen und unterscheiden. Du kannst auch ein Foto machen, aus der Galerie wählen oder eine der niedlichen Tier-Vorlagen verwenden.';

  @override
  String get profileColorTitle => 'Deine einzigartige Farbe';

  @override
  String get profileColorDescription =>
      'Deine Farbe macht dich unverwechselbar im System.';

  @override
  String get profileAgeTitle => 'Wie alt bist du?';

  @override
  String get profileAgeDescription =>
      'Das Alter bestimmt, welche Funktionen du nutzen kannst.';

  @override
  String get profileSecurityTitle => 'Schütze dein Profil';

  @override
  String get profileSecurityDescription =>
      'Optional kannst du ein Passwort setzen (mindestens 4 Zeichen).';

  @override
  String get profilePasswordOptionalInfo =>
      'Das Passwort ist optional. Lasse die Felder leer, wenn du keines setzen möchtest.';

  @override
  String get profileModeChild => 'Kind-Modus';

  @override
  String get profileModeFullAccess => 'Vollzugriff';

  @override
  String get profileModeChildDescription =>
      'Zugriff auf: Chat (Kritzeln), Tagebuch, Spiele, Timeline';

  @override
  String get profileModeFullDescription =>
      'Zugriff auf: Alle Funktionen (Chat, Kalender, Kontakte, Medikation, etc.)';

  @override
  String get profileActionSaveChanges => 'Änderungen speichern';

  @override
  String get profileActionCreateProfile => 'Profil erstellen ✓';

  @override
  String get profileDeactivateTitle => 'Profil deaktivieren?';

  @override
  String profileDeactivateMessage(String name) {
    return 'Möchtest du das Profil \"$name\" deaktivieren?\n\nEs wird ausgeblendet, kann aber später reaktiviert werden.';
  }

  @override
  String get profileDeactivated => 'Profil deaktiviert';

  @override
  String get profileDeactivate => 'Deaktivieren';

  @override
  String get profileEditComingSoon => 'Bearbeiten folgt bald';

  @override
  String get profileNameExists =>
      'Ein Profil mit diesem Namen existiert bereits';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldPassword => 'Passwort';

  @override
  String get fieldPasswordConfirm => 'Passwort bestätigen';

  @override
  String get fieldAge => 'Alter';

  @override
  String get fieldColor => 'Farbe';

  @override
  String get fieldAvatar => 'Avatar';

  @override
  String get validationRequired => 'Pflichtfeld';

  @override
  String get validationPasswordLength => 'Mindestens 4 Zeichen';

  @override
  String get validationPasswordMismatch => 'Passwörter stimmen nicht überein';

  @override
  String errorGeneric(String error) {
    return 'Fehler: $error';
  }

  @override
  String get errorNoProfile => 'Kein Profil ausgewählt';

  @override
  String get errorNoPermission =>
      'Du hast keine Berechtigung Chat-Nachrichten zu senden';

  @override
  String get chatTitle => 'Chat';

  @override
  String get chatEmptyTitle => 'Noch keine Nachrichten';

  @override
  String get chatEmptySubtitle => 'Teile deine Gedanken mit dem System';

  @override
  String get chatMessageDoodle => '[Doodle]';

  @override
  String get chatMessageVoice => '[Sprachnachricht]';

  @override
  String get chatMessageImage => '[Bild]';

  @override
  String get chatMessageVideo => '[Video]';

  @override
  String chatErrorSending(String error) {
    return 'Fehler beim Senden: $error';
  }

  @override
  String chatErrorSendingVoice(String error) {
    return 'Fehler beim Senden der Sprachnachricht: $error';
  }

  @override
  String chatErrorSendingImage(String error) {
    return 'Fehler beim Senden des Bildes: $error';
  }

  @override
  String chatErrorSendingVideo(String error) {
    return 'Fehler beim Senden des Videos: $error';
  }

  @override
  String chatErrorSendingDoodle(String error) {
    return 'Fehler beim Senden: $error';
  }

  @override
  String get chatRecordingInProgress => 'Aufnahme läuft...';

  @override
  String get chatRecordingHint =>
      'Tippe auf Stop um die Sprachnachricht zu senden';

  @override
  String get chatRecordingStop => 'Stop';

  @override
  String get chatErrorMicPermission => 'Mikrofon-Berechtigung erforderlich';

  @override
  String get chatErrorRecordingStart =>
      'Aufnahme konnte nicht gestartet werden';

  @override
  String get chatInputHint => 'Nachricht schreiben...';

  @override
  String get chatMessageFieldLabel => 'Nachricht';

  @override
  String get chatAddMedia => 'Weitere Medien hinzufügen';

  @override
  String get chatSendMessage => 'Nachricht senden';

  @override
  String get chatMediaSheetTitle => 'Medien hinzufügen';

  @override
  String get chatNoPermissionHint => 'Keine Berechtigung zum Senden';

  @override
  String get calendarTitle => 'Kalender';

  @override
  String get medicationTitle => 'Medikamente';

  @override
  String get medicationNewTitle => 'Neues Medikament';

  @override
  String get medicationEditTitle => 'Medikament bearbeiten';

  @override
  String get medicationDetailTitle => 'Medikament Details';

  @override
  String get medicationNotFound => 'Medikament nicht gefunden';

  @override
  String get medicationNotFoundMessage =>
      'Dieses Medikament existiert nicht mehr';

  @override
  String get medicationTabDaily => 'Tagesmedizin';

  @override
  String get medicationTabAsNeeded => 'Bedarfsmedizin';

  @override
  String get medicationEmptyTitle => 'Keine Medikamente 💊';

  @override
  String get medicationEmptySubtitle => 'Füge dein erstes Medikament hinzu';

  @override
  String get medicationEmptyAsNeededTitle => 'Keine Bedarfsmedizin 🩹';

  @override
  String get medicationEmptyAsNeededSubtitle =>
      'Füge dein erstes Bedarfsmedikament hinzu';

  @override
  String get medicationToday => 'Heute';

  @override
  String get medicationStatMedications => 'Medikamente';

  @override
  String get medicationStatDoses => 'Einnahmen';

  @override
  String medicationMarkedTaken(String name) {
    return '$name als genommen markiert';
  }

  @override
  String medicationMarkedRefused(String name) {
    return '$name als verweigert markiert';
  }

  @override
  String get medicationRefusalDialogTitle => 'Verweigerung dokumentieren';

  @override
  String medicationRefusalDialogMessage(String name) {
    return '$name wird als verweigert markiert.';
  }

  @override
  String get medicationRefusalReasonLabel => 'Grund (optional)';

  @override
  String get medicationRefusalReasonHint => 'z.B. Übelkeit, müde, etc.';

  @override
  String get medicationRefusalWithoutNote => 'Ohne Notiz';

  @override
  String get medicationFeedbackDialogTitle => 'Feedback hinzufügen';

  @override
  String medicationFeedbackQuestion(String name) {
    return 'Wie hast du dich nach der Einnahme von $name gefühlt?';
  }

  @override
  String get medicationFeedbackLabel => 'Deine Erfahrung';

  @override
  String get medicationFeedbackHint =>
      'z.B. \"Fühlte mich müde\", \"Hat gut geholfen\", etc.';

  @override
  String get medicationFeedbackSaved => 'Feedback gespeichert';

  @override
  String get medicationFeedbackViewTitle => 'Feedback';

  @override
  String get diaryTitle => 'Tagebuch';

  @override
  String get diaryEmptyTitle => 'Dein Tagebuch wartet auf dich! ✨';

  @override
  String get diaryEmptySubtitle =>
      'Halte deine Gedanken, Erlebnisse und Momente fest';

  @override
  String get contactsTitle => 'Kontakte';

  @override
  String get contactsFilterAll => 'Alle';

  @override
  String get contactsEmptyTitle => 'Noch keine Kontakte 👥';

  @override
  String get contactsEmptySubtitle =>
      'Tippe auf + um einen Kontakt hinzuzufügen';

  @override
  String get contactsEmptyFilteredTitle => 'Keine Kontakte gefunden 🔍';

  @override
  String get contactsEmptyFilteredSubtitle => 'Versuche einen anderen Filter';

  @override
  String get finderTitle => 'Finder';

  @override
  String get finderTabLocations => 'Orte';

  @override
  String get finderTabItems => 'Dinge';

  @override
  String get finderEmptyLocationsTitle => 'Noch keine Orte';

  @override
  String get finderEmptyItemsTitle => 'Noch keine Gegenstände';

  @override
  String get finderEmptyLocationsSubtitle =>
      'Tippe auf +, um einen Ort hinzuzufügen';

  @override
  String get finderEmptyItemsSubtitle =>
      'Tippe auf +, um einen Gegenstand hinzuzufügen';

  @override
  String get emergencyTitle => 'Notfall';

  @override
  String get emergencyEmptyTitle => 'Noch keine Notfallkontakte';

  @override
  String get emergencyEmptySubtitle =>
      'Füge Kontakte mit der Kategorie \"Notfall\" hinzu, um sie hier zu sehen.';

  @override
  String get emergencyEmptyDescription =>
      'Diese Kontakte können im Notfall schnell benachrichtigt werden.';

  @override
  String get emergencyEmptyAddContact => 'Notfallkontakt anlegen';

  @override
  String get emergencyEmptyOpenHelp => 'Hilfe und Notrufnummern';

  @override
  String get emergencySendSmsAll => 'NOTFALL-SMS an alle senden';

  @override
  String get emergencyShareAll => 'Via App an alle senden';

  @override
  String get emergencySmsDialogTitle => 'NOTFALL-SMS an alle senden?';

  @override
  String emergencySmsDialogMessage(int count) {
    return 'Die Notfall-Nachricht wird an $count Kontakte gesendet.';
  }

  @override
  String get emergencySendNow => 'Jetzt senden';

  @override
  String get emergencyMessagePreparing =>
      'Notfall-Nachricht wird vorbereitet...';

  @override
  String emergencyErrorSms(String error) {
    return 'Fehler beim SMS-Versand: $error';
  }

  @override
  String emergencyErrorShare(String error) {
    return 'Fehler beim Teilen: $error';
  }

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSectionDebug => '🔧 Debug-Optionen';

  @override
  String get settingsDebugInfo =>
      'Diese Optionen sind nur während der Entwicklung sichtbar';

  @override
  String get settingsDebugSkipCooldown => '⏩ Cooldown auf 20s setzen';

  @override
  String settingsDebugSkipCooldownInfo(String name, String time) {
    return 'Profil: $name\nVerbleibend: $time';
  }

  @override
  String get settingsDebugCooldownSet =>
      '⏩ Timer auf 20 Sekunden gesetzt!\nNach 20s kann das Passwort aktiviert werden.';

  @override
  String get settingsDebugCooldownError => '❌ Fehler beim Setzen des Timers';

  @override
  String get settingsDeleteAllData => 'Alle Daten löschen';

  @override
  String get settingsDeleteAllDataSubtitle =>
      'Löscht alle Profile, Nachrichten, Events und Anhänge';

  @override
  String get settingsDeleteConfirmTitle => '⚠️ Warnung';

  @override
  String get settingsDeleteConfirmMessage =>
      'Diese Aktion löscht ALLE Daten:\n\n• Alle Profile\n• Alle Chat-Nachrichten\n• Alle Kalender-Events\n• Alle Medikamente & Einnahme-Logs\n• Alle Kontakte\n• Alle Finder-Items\n• Alle Notfalltagebuch-Einträge\n• Alle Navigation-Daten\n• Alle Einstellungen\n• Alle Doodle-Anhänge\n\nDies kann NICHT rückgängig gemacht werden!';

  @override
  String get settingsDeleteSuccess => '✅ Alle Daten wurden gelöscht';

  @override
  String get settingsSectionManagement => 'Verwaltung';

  @override
  String get settingsPermissions => 'Rechte & Berechtigungen';

  @override
  String get settingsPermissionsSubtitle =>
      'Verwalte Zugriffsrechte der Profile';

  @override
  String get settingsSectionGlobal => 'Globale Einstellungen';

  @override
  String get settingsGlobalTrackingInfo => 'Was ist \"Tracking dauerhaft an\"?';

  @override
  String get settingsGlobalTrackingDescription =>
      'Als Admin kannst du das GPS-Tracking für ALLE Profile zentral steuern. Wenn aktiviert:';

  @override
  String get settingsGlobalTrackingBullet1 => 'Position wird permanent erfasst';

  @override
  String get settingsGlobalTrackingBullet2 =>
      'Funktioniert auch im Hintergrund';

  @override
  String get settingsGlobalTrackingBullet3 =>
      'Überschreibt individuelle Profil-Einstellungen';

  @override
  String get settingsGlobalTrackingBullet4 =>
      'Alle Profile werden automatisch getrackt';

  @override
  String get settingsGlobalTrackingRequirement =>
      'Voraussetzung: Die Android-Berechtigung \"Immer erlauben\" muss aktiviert sein, damit Tracking auch bei geschlossener App funktioniert.';

  @override
  String get settingsGpsPermissionTitle => 'GPS Berechtigung';

  @override
  String get settingsGpsStatusDisabled => 'GPS-Dienst deaktiviert';

  @override
  String get settingsGpsStatusDenied => 'Berechtigung verweigert';

  @override
  String get settingsGpsStatusDeniedForever => 'Dauerhaft verweigert';

  @override
  String get settingsGpsStatusWhileInUse => 'Nur während der Nutzung';

  @override
  String get settingsGpsStatusAlways => 'Immer erlaubt ✓';

  @override
  String get settingsGpsStatusUnknown => 'Unbekannt';

  @override
  String get settingsGpsReady => 'Perfekt! Background-Tracking ist bereit.';

  @override
  String get settingsGpsInstructions => 'So aktivierst du \"Immer erlauben\":';

  @override
  String get settingsGpsStep1 => 'Tippe auf \"Android-Einstellungen öffnen\" ↓';

  @override
  String get settingsGpsStep2 => 'Wähle \"Berechtigung\" → \"Standort\"';

  @override
  String get settingsGpsStep3 => 'Wähle \"Immer erlauben\"';

  @override
  String get settingsGpsOpenSettings => 'Android-Einstellungen öffnen';

  @override
  String get settingsGpsOpenLocationSettings => 'GPS-Einstellungen öffnen';

  @override
  String get settingsGpsPrivacyNote =>
      'Dein Standort bleibt auf diesem Gerät. Für Karten wird er an OpenStreetMap übergeben, nie an uns.';

  @override
  String get settingsTrackingPermanent => 'Tracking dauerhaft an';

  @override
  String get settingsTrackingPermanentOn =>
      'GPS läuft permanent für alle Profile';

  @override
  String get settingsTrackingPermanentOff => 'GPS nur bei Bedarf pro Profil';

  @override
  String get settingsTrackingPermissionRequired =>
      'Standort-Berechtigung nötig';

  @override
  String get settingsTrackingEnabled => '✅ Dauerhaftes Tracking aktiviert';

  @override
  String get settingsTrackingDisabled => '✅ Dauerhaftes Tracking deaktiviert';

  @override
  String get settingsSectionLegal => 'Rechtliches';

  @override
  String get settingsImpressum => 'Impressum';

  @override
  String get settingsImpressumSubtitle => 'Rechtliche Informationen';

  @override
  String get settingsPrivacy => 'Datenschutzerklärung';

  @override
  String get settingsPrivacySubtitle => 'Wie wir deine Daten schützen';

  @override
  String get settingsAppVersion => 'App-Version';

  @override
  String get settingsSectionDiagnostics => 'Diagnose & Support';

  @override
  String get settingsDebugLog => 'Debug-Log generieren';

  @override
  String get settingsDebugLogSubtitle =>
      'Erstellt technische Diagnose-Informationen zum Teilen';

  @override
  String settingsDebugLogError(String error) {
    return '❌ Fehler beim Generieren des Debug-Logs: $error';
  }

  @override
  String get settingsSectionNotifications => 'Benachrichtigungen';

  @override
  String get settingsNotificationsSubtitle =>
      'Erinnerungen für Medikamente und Termine';

  @override
  String get settingsNotificationsInfo =>
      'Wie funktionieren Benachrichtigungen?';

  @override
  String get settingsNotificationsBullet1 =>
      'Tagesmedikamente: -30min, -10min, 0min + +10min Wiederholungen';

  @override
  String get settingsNotificationsBullet2 =>
      'Bedarfsmedikamente: Verfügbarkeits-Erinnerungen (-30min, -10min, -5min, 0min)';

  @override
  String get settingsNotificationsBullet3 =>
      'Termine: Konfigurierbare Erinnerungen (15min bis 1 Tag vorher)';

  @override
  String get settingsNotificationsBullet4 =>
      'Funktioniert auch wenn die App geschlossen ist';

  @override
  String get settingsNotificationsTest => 'Test-Benachrichtigung senden';

  @override
  String get settingsNotificationsTestSubtitle =>
      'Prüfe ob Benachrichtigungen funktionieren';

  @override
  String get settingsNotificationsTestSent =>
      '✅ Test-Benachrichtigung gesendet';

  @override
  String get settingsNotificationsQueue => 'Warteschlange';

  @override
  String get settingsNotificationsQueuePending =>
      'Geplante Benachrichtigungen:';

  @override
  String settingsNotificationsQueueNext(String time) {
    return 'Nächste: $time';
  }

  @override
  String get settingsSectionMaps => 'Karten & Standort';

  @override
  String get settingsMapsSubtitle =>
      'Kartenkacheln werden automatisch beim Betrachten heruntergeladen und gespeichert';

  @override
  String get settingsCacheStorage => 'Cache-Speicher';

  @override
  String settingsCacheSize(int size, int limit, String count) {
    return '$size MB / $limit MB • $count Kacheln';
  }

  @override
  String get settingsCacheLimit => 'Cache-Limit';

  @override
  String settingsCacheLimitSubtitle(int limit) {
    return '$limit MB maximale Speichergröße';
  }

  @override
  String get settingsCacheLimitDialogTitle => 'Cache-Limit festlegen';

  @override
  String settingsCacheLimitDialogLabel(int size) {
    return 'Maximale Cache-Größe: $size MB';
  }

  @override
  String get settingsCacheLimitDialogInfo =>
      'Wenn der Cache dieses Limit überschreitet, werden automatisch die ältesten Kacheln gelöscht.';

  @override
  String settingsCacheLimitSet(int limit) {
    return '✅ Cache-Limit auf $limit MB gesetzt';
  }

  @override
  String get settingsCachePreDownload => 'Karten vorab herunterladen';

  @override
  String get settingsCachePreDownloadSubtitle =>
      'Lade Karten in einem Umkreis herunter';

  @override
  String get settingsCachePreDownloadPlaceholder =>
      '🚧 Voraus-Download wird in Phase 4 implementiert';

  @override
  String get settingsCacheClear => 'Cache leeren';

  @override
  String get settingsCacheClearSubtitle =>
      'Alle gespeicherten Kartenkacheln löschen';

  @override
  String get settingsCacheClearDialogTitle => 'Karten-Cache leeren';

  @override
  String get settingsCacheClearDialogMessage =>
      'Möchtest du alle gespeicherten Kartenkacheln löschen?\n\nDie Karten werden beim nächsten Aufruf neu geladen. Dies kann helfen, Speicherplatz freizugeben.';

  @override
  String get settingsCacheClearConfirm => 'Cache leeren';

  @override
  String get settingsCacheCleared => '✅ Karten-Cache geleert';

  @override
  String get settingsSectionApp => 'App-Einstellungen';

  @override
  String get settingsTimeFormat => 'Zeitformat';

  @override
  String get settingsTimeFormatSystem => 'System-Standard';

  @override
  String get settingsTimeFormat12h => '12-Stunden Format';

  @override
  String get settingsTimeFormat24h => '24-Stunden Format';

  @override
  String get settingsTimeFormatSystemSubtitle =>
      'Folgt den Android-Systemeinstellungen';

  @override
  String get settingsTimeFormat12hExample => 'z.B. 2:30 PM';

  @override
  String get settingsTimeFormat24hExample => 'z.B. 14:30';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLanguageChanged => 'Sprache geändert';

  @override
  String get onboardingSelectLanguage => 'Wähle deine Sprache';

  @override
  String get onboardingWelcomeTitle => 'Willkommen bei';

  @override
  String get onboardingWelcomeSubtitle =>
      'Deine sichere Begleiterin im Alltag mit DIS';

  @override
  String get onboardingWelcomeDescription =>
      'Aurora ist euer geschützter Raum. Hier kannst du dich frei ausdrücken und mit den anderen Anteilen im System in Verbindung bleiben.';

  @override
  String get onboardingPrivacyTitle => 'Deine Daten gehören DIR';

  @override
  String get onboardingPrivacyBullet1 =>
      'Alle Daten bleiben lokal auf deinem Gerät';

  @override
  String get onboardingPrivacyBullet2 =>
      'Keine Cloud-Sicherung, kein Tracking, keine Werbung';

  @override
  String get onboardingPrivacyBullet3 => 'Du hast die volle Kontrolle';

  @override
  String get onboardingPrivacyBullet4 => 'Transparent und sicher';

  @override
  String get onboardingMultiProfileTitle => 'Viele Stimmen, eine App';

  @override
  String get onboardingMultiProfileDescription =>
      'Jeder Anteil bekommt ein eigenes Profil – mit eigener Farbe, eigenem Bild und eigenen Rechten.';

  @override
  String get onboardingLetsGoTitle => 'Bereit anzufangen?';

  @override
  String get onboardingLetsGoDescription =>
      'Erstelle jetzt dein erstes Profil. Das erste Profil wird automatisch zum Admin-Profil mit vollen Zugriffsrechten.';

  @override
  String get onboardingButtonNext => 'Weiter →';

  @override
  String get onboardingButtonCreateProfile => 'Profil erstellen →';

  @override
  String get splashLoading => 'Aurora lädt';

  @override
  String get splashDidYouKnow => 'Wusstest du?';

  @override
  String get splashEmergencyWipeTitle => 'Notfall-Reset';

  @override
  String get splashEmergencyWipeMessage =>
      'WARNUNG: Alle Daten werden unwiderruflich gelöscht!\n\n• Alle Profile\n• Alle Nachrichten\n• Alle Tagebuch-Einträge\n• Alle Kontakte\n• Alle Medikamente\n\nFortfahren?';

  @override
  String get splashEmergencyWipeConfirm => 'ALLES LÖSCHEN';

  @override
  String get passwordResetBannerReady => 'Passwort bereit zum Aktivieren';

  @override
  String get passwordResetBannerRunning => 'Passwort-Reset läuft';

  @override
  String passwordResetBannerProfile(String name) {
    return 'Profil: $name';
  }

  @override
  String passwordResetBannerRemaining(String name, String time) {
    return 'Profil: $name • Verbleibend: $time';
  }

  @override
  String get dialogWarning => 'Warnung';

  @override
  String get dialogConfirm => 'Bestätigen';

  @override
  String get dialogUnderstood => 'Verstanden';

  @override
  String get dialogYes => 'Ja';

  @override
  String get dialogNo => 'Nein';

  @override
  String get permissionGpsRequired =>
      '⚠️ GPS-Berechtigung \"Immer erlaubt\" erforderlich';

  @override
  String get permissionTrackingDialogTitle =>
      'Dauerhaftes Tracking aktivieren?';

  @override
  String get permissionTrackingDialogHeading => 'Das bewirkt dieser Modus:';

  @override
  String get permissionTrackingBullet1 => 'GPS läuft permanent im Hintergrund';

  @override
  String get permissionTrackingBullet2 =>
      'Überschreibt Tracking-Einstellung ALLER Profile';

  @override
  String get permissionTrackingBullet3 =>
      'Timeline erfasst alle Bewegungen automatisch';

  @override
  String get permissionTrackingPrivacyTitle =>
      'Deine Daten bleiben auf diesem Gerät';

  @override
  String get permissionTrackingPrivacyMessage =>
      'Aurora speichert alle Daten nur auf diesem Gerät. Kein Tracking, keine Werbung, keine Weitergabe.';

  @override
  String get permissionTrackingBatteryWarning =>
      'Background-GPS kann den Akku stärker belasten.';

  @override
  String get permissionTrackingAndroidStatus => 'Android-Status:';

  @override
  String get permissionTrackingActivate => 'Aktivieren';

  @override
  String get permissionTrackingDeactivate => 'Deaktivieren';

  @override
  String get permissionTrackingDeactivateTitle =>
      'Dauerhaftes Tracking deaktivieren?';

  @override
  String get permissionTrackingDeactivateMessage =>
      'Das GPS-Tracking wird wieder pro Profil gesteuert.\n\nJedes Profil kann dann individuell das Tracking aktivieren/deaktivieren.';

  @override
  String get permissionGuidanceTitle => 'Android-Einstellung erforderlich';

  @override
  String get permissionGuidanceMessage =>
      'Um dauerhaftes Tracking zu nutzen, benötigst du die Berechtigung \"Immer erlauben\".';

  @override
  String get permissionGuidanceStepsTitle =>
      'Ich helfe dir Schritt für Schritt:';

  @override
  String get permissionGuidanceStep1Title => 'Android-Einstellungen öffnen';

  @override
  String get permissionGuidanceStep1Button => 'Jetzt öffnen';

  @override
  String get permissionGuidanceStep2Title => 'In den Einstellungen';

  @override
  String get permissionGuidanceStep2Bullet1 => 'Tippe auf \"Berechtigung\"';

  @override
  String get permissionGuidanceStep2Bullet2 => 'Tippe auf \"Standort\"';

  @override
  String get permissionGuidanceStep2Bullet3 => 'Wähle \"Immer erlauben\"';

  @override
  String get permissionGuidanceStep3Message =>
      'Zurück zu Aurora\nDie App erkennt die Änderung automatisch.';

  @override
  String get messageError => 'Fehler';

  @override
  String get messageSuccess => 'Erfolgreich';

  @override
  String get messageWarning => 'Warnung';

  @override
  String get messageInfo => 'Information';

  @override
  String get messageLoading => 'Lädt...';

  @override
  String get misc24HourFormat => '24-Stunden Format';

  @override
  String get misc12HourFormat => '12-Stunden Format';

  @override
  String get miscSystemDefault => 'System-Standard';

  @override
  String get miscUnknown => 'Unbekannt';

  @override
  String get chatDayYesterday => 'Gestern';

  @override
  String get miscToday => 'Heute';

  @override
  String get miscAll => 'Alle';

  @override
  String get notificationChannelName => 'Aurora Benachrichtigungen';

  @override
  String get notificationChannelDescription =>
      'Erinnerungen für Medikamente und Termine';

  @override
  String get notificationMedicationReminder => 'Medikamenten-Erinnerung';

  @override
  String notificationMedicationBodyWithTime(
    String name,
    String dosage,
    String time,
  ) {
    return '$name - $dosage $time';
  }

  @override
  String notificationMedicationBodyNow(String name, String dosage) {
    return '$name - $dosage jetzt einnehmen';
  }

  @override
  String get notificationMedicationAvailableSoon =>
      'Bedarfsmedikament bald verfügbar';

  @override
  String get notificationMedicationAvailableNow =>
      'Bedarfsmedikament jetzt verfügbar';

  @override
  String notificationMedicationAvailableBody(String name) {
    return '$name kann eingenommen werden';
  }

  @override
  String get notificationEventReminder => 'Termin-Erinnerung';

  @override
  String notificationEventBody(String title, String time) {
    return '$title $time';
  }

  @override
  String get notificationTestTitle => 'Test-Benachrichtigung';

  @override
  String get notificationTestBody => 'Benachrichtigungen funktionieren!';

  @override
  String notificationTimeInMinutes(int minutes) {
    return 'in $minutes Minuten';
  }

  @override
  String get notificationTimeIn1Hour => 'in 1 Stunde';

  @override
  String notificationTimeInHours(int hours) {
    return 'in $hours Stunden';
  }

  @override
  String get notificationTimeNow => 'jetzt';

  @override
  String get notificationMedicationTakeNowTitle =>
      'Medikament jetzt einnehmen!';

  @override
  String get notificationMedicationNotTakenYet => 'Noch nicht eingenommen!';

  @override
  String get actionCreate => 'Erstellen';

  @override
  String get commonDescription => 'Beschreibung';

  @override
  String get commonNotes => 'Notizen';

  @override
  String get commonOptional => 'Optional';

  @override
  String get commonCategory => 'Kategorie';

  @override
  String get commonStartTime => 'Startzeit';

  @override
  String get commonEndTime => 'Endzeit';

  @override
  String get commonVisibleFor => 'Sichtbar für';

  @override
  String get commonUnnamed => 'Unbenannt';

  @override
  String get commentsTitle => 'Kommentare';

  @override
  String get eventCreate => 'Termin erstellen';

  @override
  String get eventNewTitle => 'Neuer Termin';

  @override
  String get eventEditTitle => 'Termin bearbeiten';

  @override
  String get eventDetailTitle => 'Termin';

  @override
  String get eventNotFound => 'Termin nicht gefunden';

  @override
  String get eventNotFoundMessage => 'Diesen Termin gibt es nicht mehr';

  @override
  String get eventDeleteTitle => 'Termin löschen?';

  @override
  String get eventDeleteMessage =>
      'Möchtest du diesen Termin wirklich löschen?';

  @override
  String get eventDeleteConfirmMessage =>
      'Dieser Termin wird dauerhaft gelöscht.';

  @override
  String get eventDeleted => 'Termin gelöscht';

  @override
  String get eventUpdated => 'Termin gespeichert';

  @override
  String get eventCreated => 'Termin erstellt';

  @override
  String get eventSelectProfileRequired =>
      'Bitte mindestens ein Profil auswählen';

  @override
  String get eventEndTimeError => 'End-Zeit muss nach Start-Zeit liegen';

  @override
  String get eventTitleLabel => 'Titel';

  @override
  String get eventTitleLabelRequired => 'Titel *';

  @override
  String get eventTitleRequired => 'Bitte gib einen Titel ein';

  @override
  String get eventTitleHint => 'z.B. Arzttermin';

  @override
  String get eventCategoryLabel => 'Kategorie (optional)';

  @override
  String get eventCategoryHint => 'z.B. Arzttermin, privat, etc.';

  @override
  String get eventDescriptionLabel => 'Beschreibung (optional)';

  @override
  String contactDistanceAway(String distance) {
    return '$distance entfernt';
  }

  @override
  String eventReminderMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes Minuten',
      one: '1 Minute',
    );
    return '$_temp0';
  }

  @override
  String eventReminderHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours Stunden',
      one: '1 Stunde',
    );
    return '$_temp0';
  }

  @override
  String get eventReminderDay => '1 Tag';

  @override
  String eventReminderNotice(String when) {
    return 'Aurora meldet sich $when vor dem Termin.';
  }

  @override
  String eventReminderBefore(int minutes) {
    return 'Erinnerung $minutes Min. vorher';
  }

  @override
  String eventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Termine',
      one: '1 Termin',
      zero: 'Keine Termine',
    );
    return '$_temp0';
  }

  @override
  String get noEventsToday => 'Keine Termine an diesem Tag';

  @override
  String get calendarNothingPlannedToday => 'Heute ist nichts geplant.';

  @override
  String get calendarNothingPlannedOnDay => 'An diesem Tag ist nichts geplant.';

  @override
  String get calendarUpcomingTitle => 'Als Nächstes';

  @override
  String get calendarChooseDay => 'Anderen Tag ansehen';

  @override
  String get eventForWhom => 'Für wen ist der Termin?';

  @override
  String get eventMoreDetails => 'Weitere Angaben';

  @override
  String get contactTitle => 'Kontakt';

  @override
  String get contactNewTitle => 'Neuer Kontakt';

  @override
  String get contactEditTitle => 'Kontakt bearbeiten';

  @override
  String get contactNotFound => 'Kontakt nicht gefunden';

  @override
  String get contactDeleteTitle => 'Kontakt löschen?';

  @override
  String get contactDeleteMessage =>
      'Dieser Kontakt wird dauerhaft gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get contactImagePickerTitle => 'Kontaktbild wählen';

  @override
  String get contactNameLabel => 'Name *';

  @override
  String get contactNameRequired => 'Bitte einen Namen eingeben';

  @override
  String get contactRelationLabel => 'Beziehung';

  @override
  String get contactRelationHint => 'z.B. Mutter, Therapeutin, Freund...';

  @override
  String get contactMarkAsEmergency => 'Als Notfallkontakt markieren';

  @override
  String get contactEmergencyDescription =>
      'Dieser Kontakt erscheint in der Notfall-Ansicht und kann schnell benachrichtigt werden';

  @override
  String get contactPhoneLabel => 'Telefon';

  @override
  String get contactEmailLabel => 'E-Mail';

  @override
  String get contactDefaultRating => 'Standard-Bewertung';

  @override
  String get contactDefaultRatingDescription =>
      'Diese Bewertung sehen alle Profile standardmäßig. Jedes Profil kann später eine eigene Bewertung vergeben.';

  @override
  String get contactPersonalRating => 'Persönliche Bewertung';

  @override
  String get contactLocationSection => '📍 Standort (optional)';

  @override
  String get contactLocationTitle => '📍 Standort';

  @override
  String get contactLocationDescription =>
      'Füge einen Standort hinzu (z.B. Wohnort, Praxis-Adresse)';

  @override
  String get contactLocationSet => 'Position festlegen';

  @override
  String get contactLocationChange => 'Position ändern';

  @override
  String get contactAddressLabel => 'Adresse';

  @override
  String get contactAddressHint =>
      'Wird automatisch ermittelt, wenn Position festgelegt';

  @override
  String get contactVisibleToAll => 'Alle Profile können diesen Kontakt sehen';

  @override
  String get contactInfoSection => 'Informationen';

  @override
  String get gpsPermissionRequired => 'GPS-Berechtigung erforderlich';

  @override
  String get gpsTrackingDisabled => 'GPS-Tracking deaktiviert';

  @override
  String get emergencyContactLabel => 'Notfallkontakt';

  @override
  String get diaryEntryNewTitle => 'Neuer Eintrag';

  @override
  String get diaryEntryEditTitle => 'Eintrag bearbeiten';

  @override
  String get diaryEntryDetailTitle => 'Eintrag Details';

  @override
  String get diaryEntryNotFound => 'Eintrag nicht gefunden';

  @override
  String get diaryEntryNotFoundMessage => 'Dieser Eintrag existiert nicht mehr';

  @override
  String get diaryEntryDeleteTitle => 'Eintrag löschen';

  @override
  String get diaryEntryDeleteMessage =>
      'Möchtest du diesen Eintrag wirklich löschen? Alle Kommentare werden ebenfalls gelöscht.';

  @override
  String get diaryEntryDeleted => 'Eintrag gelöscht';

  @override
  String get diaryEntryUpdated => 'Eintrag aktualisiert';

  @override
  String get diaryEntryCreated => 'Eintrag erstellt';

  @override
  String get diaryTitleHint => 'Was ist passiert?';

  @override
  String get diaryTitleRequired => 'Bitte Titel eingeben';

  @override
  String get diaryDescriptionHint => 'Beschreibe das Ereignis...';

  @override
  String get diaryDescriptionRequired => 'Bitte Beschreibung eingeben';

  @override
  String get diaryPriorityLabel => 'Priorität';

  @override
  String get diaryImagesLabel => 'Bilder';

  @override
  String get diaryNoImagesYet => 'Noch keine Bilder hinzugefügt';

  @override
  String get diaryImagePickerComingSoon =>
      'Bild-Auswahl wird in Kürze implementiert';

  @override
  String get diaryCannotEditEntry =>
      'Du darfst diesen Eintrag nicht bearbeiten';

  @override
  String get diaryCannotCreateEntry => 'Du darfst keine Einträge erstellen';

  @override
  String get commonError => 'Fehler';

  @override
  String get commonNoPermission => 'Keine Berechtigung';

  @override
  String get commonEdited => 'Bearbeitet';

  @override
  String get commonTitle => 'Titel';

  @override
  String get profileNotSelected => 'Kein Profil ausgewählt';

  @override
  String get actionAdd => 'Hinzufügen';

  @override
  String commonSaveError(String error) {
    return 'Fehler beim Speichern: $error';
  }

  @override
  String get timeJustNow => 'gerade eben';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Minuten',
      one: 'vor einer Minute',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Stunden',
      one: 'vor einer Stunde',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Tagen',
      one: 'vor einem Tag',
    );
    return '$_temp0';
  }

  @override
  String get emergencyCall => 'Anrufen';

  @override
  String get emergencyCallTooltip => 'Kontakt anrufen';

  @override
  String get emergencyNoPhone => 'Keine Telefonnummer vorhanden';

  @override
  String get emergencySms => 'SMS';

  @override
  String get emergencySmsTooltip => 'Notfall-SMS senden';

  @override
  String get emergencyApp => 'App';

  @override
  String get emergencyShareTooltip => 'Via App teilen';

  @override
  String emergencyErrorCall(String error) {
    return 'Fehler beim Anrufen: $error';
  }

  @override
  String emergencyErrorOpen(String error) {
    return 'Fehler beim Öffnen: $error';
  }

  @override
  String get actionOpen => 'Öffnen';

  @override
  String get finderLocationEditTitle => 'Ort bearbeiten';

  @override
  String get finderItemEditTitle => 'Gegenstand bearbeiten';

  @override
  String get finderLocationNewTitle => 'Neuer Ort';

  @override
  String get finderItemNewTitle => 'Neuer Gegenstand';

  @override
  String get finderSetPosition => 'Position festlegen';

  @override
  String get finderChangePosition => 'Position ändern';

  @override
  String get finderAddressLabel => 'Adresse';

  @override
  String get finderStorageLocationLabel => 'Aufbewahrungsort';

  @override
  String get finderStorageLocationHint => 'z.B. Küche, 2. Schublade';

  @override
  String get finderChoosePhoto => 'Foto wählen';

  @override
  String get finderAddPhoto => 'Foto hinzufügen';

  @override
  String get finderAddTag => 'Tag hinzufügen';

  @override
  String get finderNotFound => 'Nicht gefunden';

  @override
  String get finderNotFoundMessage => 'Item nicht gefunden';

  @override
  String get finderDeleteTitle => 'Löschen?';

  @override
  String finderDeleteMessage(String title) {
    return '$title wirklich löschen?';
  }

  @override
  String get commonRequired => 'Pflichtfeld';

  @override
  String get feedbackTitle => 'Feedback senden';

  @override
  String get feedbackPrivacyInfo =>
      'Dein Feedback wird vertraulich behandelt und nur intern verarbeitet. Deine Rückmeldungen helfen uns, Aurora zu verbessern!';

  @override
  String get feedbackSelectCategory => 'Kategorie wählen:';

  @override
  String get fieldPasswordShow => 'Passwort anzeigen';

  @override
  String get fieldPasswordHide => 'Passwort verbergen';

  @override
  String get feedbackCategoryBug => 'Fehler melden';

  @override
  String get feedbackCategoryWish => 'Wunsch äußern';

  @override
  String get feedbackCategoryGeneral => 'Allgemeine Rückmeldung';

  @override
  String get feedbackCategoryLabel => 'Kategorie';

  @override
  String get feedbackTitleLabel => 'Titel:';

  @override
  String get feedbackTitleHint => 'Kurze Zusammenfassung deines Feedbacks';

  @override
  String get feedbackTitleRequired => 'Bitte gib einen Titel ein';

  @override
  String get feedbackTitleTooShort => 'Titel zu kurz (mindestens 5 Zeichen)';

  @override
  String get feedbackMessageLabel => 'Deine Nachricht:';

  @override
  String get feedbackMessageHint => 'Beschreibe dein Feedback ausführlich...';

  @override
  String get feedbackMessageRequired => 'Bitte gib eine Nachricht ein';

  @override
  String get feedbackMessageTooShort =>
      'Nachricht zu kurz (mindestens 20 Zeichen)';

  @override
  String get feedbackEmailLabel => 'Deine E-Mail (optional):';

  @override
  String get feedbackEmailHint =>
      'Nur wenn du möchtest, dass wir dich bei Rückfragen kontaktieren';

  @override
  String get feedbackEmailPlaceholder => 'deine@email.de';

  @override
  String get feedbackEmailInvalid => 'Bitte gültige E-Mail-Adresse eingeben';

  @override
  String get feedbackAttachImageLabel => 'Bild anfügen (optional):';

  @override
  String get feedbackAttachImage => 'Bild anfügen';

  @override
  String get feedbackSelectImage => 'Bild auswählen';

  @override
  String get feedbackSend => 'Feedback senden';

  @override
  String get feedbackCopyToClipboard => 'In Zwischenablage kopieren';

  @override
  String get feedbackCopiedToClipboard => 'Feedback in Zwischenablage kopiert!';

  @override
  String get feedbackContactLabel => 'Kontakt';

  @override
  String get feedbackErrorOccurred =>
      'Ein Fehler ist aufgetreten. Report wurde in Zwischenablage kopiert.';

  @override
  String get feedbackCouldNotSend => 'Feedback konnte nicht gesendet werden';

  @override
  String feedbackErrorClipboardHint(String email) {
    return 'Dein Feedback wurde in die Zwischenablage kopiert. Du kannst es uns auch per E-Mail an $email senden.';
  }

  @override
  String get feedbackTechnicalDetails => 'Technische Details';

  @override
  String get actionChange => 'Ändern';

  @override
  String get actionRemove => 'Entfernen';

  @override
  String get onboardingNext => 'Weiter →';

  @override
  String get onboardingCreateProfile => 'Profil erstellen →';

  @override
  String get onboardingLetsGo => 'Los geht\'s! →';

  @override
  String get onboardingWelcomeTo => 'Willkommen bei';

  @override
  String get onboardingSubline => 'Deine sichere Begleiterin im Alltag mit DIS';

  @override
  String get onboardingDescription =>
      'Aurora unterstützt dich beim Organisieren deines Alltags und der Kommunikation innerhalb deines Systems.';

  @override
  String get onboardingPrivacyHeadline => 'Deine Daten gehören DIR';

  @override
  String get onboardingPrivacyPoint1 =>
      'Alle Daten bleiben lokal auf deinem Gerät';

  @override
  String get onboardingPrivacyPoint2 =>
      'Keine Cloud-Sicherung, kein Tracking, keine Werbung';

  @override
  String get onboardingPrivacyPoint3 => 'Du hast die volle Kontrolle';

  @override
  String get onboardingPrivacyPoint4 => 'Transparent und sicher';

  @override
  String get onboardingMultiProfileHeadline => 'Viele Stimmen, eine App';

  @override
  String get onboardingLetsGoHeadline => 'Bereit anzufangen?';

  @override
  String onboardingHelloName(String name) {
    return 'Hallo $name!';
  }

  @override
  String get onboardingGladYoureHere => 'Schön, dass du da bist.';

  @override
  String get onboardingNotAlone => 'Du bist nicht allein';

  @override
  String get onboardingNotAloneDescription =>
      'Ihr könnt miteinander chatten, Termine teilen und euch gegenseitig unterstützen.';

  @override
  String get onboardingWhatYouCanDo => 'Was du tun kannst';

  @override
  String get onboardingChildAccessDescription =>
      'Als Kind-Profil hast du Zugriff auf:';

  @override
  String get onboardingAdultAccessDescription =>
      'Diese Funktionen stehen dir zur Verfügung:';

  @override
  String get onboardingSafeSpace => 'Dein sicherer Raum';

  @override
  String get onboardingSafeSpaceDescription =>
      'Alle deine Einträge bleiben auf diesem Gerät. Gesendet wird nur, was du selbst absendest — und du kannst es jederzeit nachlesen.';

  @override
  String get onboardingHaveFun => 'Viel Spaß mit Aurora!';

  @override
  String get onboardingFeatureChatChild =>
      'Chat - Kritzeln und mit anderen sprechen';

  @override
  String get onboardingFeatureDiaryChild =>
      'Tagebuch - Deine Gedanken aufschreiben';

  @override
  String get onboardingFeatureGamesChild =>
      'Spiele - Spaß haben und entspannen';

  @override
  String get onboardingFeatureTimelineChild =>
      'Timeline - Wichtige Momente festhalten';

  @override
  String get onboardingFeatureChat =>
      'Chat - Nachrichten, Kritzeleien, Sprachnachrichten';

  @override
  String get onboardingFeatureCalendar =>
      'Kalender - Termine planen und verwalten';

  @override
  String get onboardingFeatureContacts =>
      'Kontakte - Wichtige Personen speichern';

  @override
  String get onboardingFeatureMedication =>
      'Medikation - Medikamente und Einnahmen tracken';

  @override
  String get onboardingFeatureDiary =>
      'Tagebuch - Gedanken und Erlebnisse festhalten';

  @override
  String get onboardingFeatureFinder => 'Finder - Orte und Dinge wiederfinden';

  @override
  String get onboardingFeatureEmergency =>
      'Notfall - Schnelle Hilfe in Krisensituationen';

  @override
  String get onboardingFeatureMantras =>
      'Mantras - Beruhigende Sätze und Affirmationen';

  @override
  String get onboardingFeatureChatBasic => 'Chat - Grundfunktionen verfügbar';

  @override
  String get featureCarouselHeadline => 'Was Aurora alles kann';

  @override
  String get featureCarouselSwipeHint => 'Wisch durch die Features →';

  @override
  String get featureCarouselChatTitle => 'Chat';

  @override
  String get featureCarouselChatSubtitle => 'Interne Kommunikation';

  @override
  String get featureCarouselChatDescription =>
      'Nachrichten, Kritzeleien & Sprachnachrichten.\nTeilt Gedanken, malt zusammen oder sprecht miteinander.';

  @override
  String get featureCarouselCalendarTitle => 'Kalender';

  @override
  String get featureCarouselCalendarSubtitle => 'Events & Termine';

  @override
  String get featureCarouselCalendarDescription =>
      'Termine mit Bildern & Standorten.\nBehaltet wichtige Termine im Blick, mit Bildern und GPS-Positionen.';

  @override
  String get featureCarouselDiaryTitle => 'Tagebuch';

  @override
  String get featureCarouselDiarySubtitle => 'Private Gedanken';

  @override
  String get featureCarouselDiaryDescription =>
      'Für alle sichtbar oder nur für dich.\nHaltet Gedanken fest - öffentlich für alle Profile oder privat nur für euch.';

  @override
  String get featureCarouselFinderTitle => 'Finder';

  @override
  String get featureCarouselFinderSubtitle => 'Orte & Dinge';

  @override
  String get featureCarouselFinderDescription =>
      'Findet Orte und Dinge wieder.\nSpeichert wichtige Orte (mit Karte) und Gegenstände, damit ihr sie wiederfindet.';

  @override
  String get featureCarouselMedicationTitle => 'Medikation';

  @override
  String get featureCarouselMedicationSubtitle => 'Medikamenten-Tracker';

  @override
  String get featureCarouselMedicationDescription =>
      'Medikamente & Einnahmezeiten.\nTrackt Medikamente, Einnahmezeiten und Bedarfsmedikation.';

  @override
  String get featureCarouselGamesTitle => 'Spiele & Grounding';

  @override
  String get featureCarouselGamesSubtitle => 'Entspannung';

  @override
  String get featureCarouselGamesDescription =>
      'Spiele, Atemübungen & Grounding.\nBeruhigt euch mit Puzzles, Atemübungen und Grounding-Techniken.';

  @override
  String get featureCarouselEmergencyTitle => 'Hilfsangebote';

  @override
  String get featureCarouselEmergencySubtitle => 'Notfallkontakte';

  @override
  String get featureCarouselEmergencyDescription =>
      'Notfallkontakte & schnelle Hilfe.\nHinterlegt wichtige Kontakte für Krisensituationen.';

  @override
  String get featureCarouselInfoTitle => 'DIS-Informationen';

  @override
  String get featureCarouselInfoSubtitle => 'Wissen & Ressourcen';

  @override
  String get featureCarouselInfoDescription =>
      'Erklärt: Was ist DIS?\nInformationen über Dissoziative Identitätsstörung und Ressourcen.';

  @override
  String get commonUnknown => 'Unbekannt';

  @override
  String get timelineTitle => 'Zeitachse';

  @override
  String get timelineHistory => 'Verlauf';

  @override
  String timelineEntries(int count) {
    return '$count Einträge';
  }

  @override
  String get timelinePositionUpdated => 'Position aktualisiert';

  @override
  String timelineProfileActive(String name) {
    return '$name aktiv';
  }

  @override
  String get timelineAppStarted => 'App gestartet';

  @override
  String get timelineProfileSwitched => 'Profil gewechselt';

  @override
  String timelineToday(String time) {
    return 'Heute, $time Uhr';
  }

  @override
  String timelineYesterday(String time) {
    return 'Gestern, $time Uhr';
  }

  @override
  String get timelineTrackingDisabledTitle => 'GPS-Tracking deaktiviert';

  @override
  String get timelineTrackingDisabledSubtitle =>
      'Die Zeitachse zeigt deine Profil-Wechsel und GPS-Positionen über die Zeit.\n\nAktiviere das GPS-Tracking über das Satelliten-Symbol oben rechts, um Daten zu sammeln.';

  @override
  String get timelineEmptyTitle => 'Noch keine Daten';

  @override
  String get timelineEmptySubtitle =>
      'Das GPS-Tracking ist aktiv. Deine Position wird alle 2-3 Minuten aufgezeichnet.\n\nProfil-Wechsel und GPS-Positionen erscheinen hier automatisch.';

  @override
  String get gamesTitle => 'Spiele & Entspannung';

  @override
  String get gamesSubtitle =>
      'Einfache Spiele zur Ablenkung und Entspannung.\nKeine Timer, keine Punkte - nur Ruhe.';

  @override
  String get gamesComingSoon => 'Bald';

  @override
  String get gamesPuzzleTitle => 'Puzzle';

  @override
  String get gamesPuzzleSubtitle => 'Jigsaw oder Schiebepuzzle';

  @override
  String get gamesPuzzleDescription =>
      'Entspanne dich mit beruhigenden Bildern';

  @override
  String get gamesBreathingTitle => 'Atemübungen';

  @override
  String get gamesBreathingSubtitle => 'Geführte Atemtechniken';

  @override
  String get gamesBreathingDescription =>
      'Beruhige dich mit einfachen Atemübungen';

  @override
  String get memoryCardHidden => 'Verdeckt';

  @override
  String get memoryCardOpen => 'Aufgedeckt';

  @override
  String get memoryCardFound => 'Paar gefunden';

  @override
  String get memoryAllFound => 'Alle Paare liegen.';

  @override
  String get memoryNewGame => 'Neues Spiel';

  @override
  String get gamesDrawingSend => 'In den Chat schicken';

  @override
  String get gamesDrawingEmpty => 'Zeichne etwas, dann kannst du es schicken';

  @override
  String get gamesDrawingSent => 'Dein Bild steht jetzt im Chat.';

  @override
  String memoryCardPosition(int position, int total) {
    return 'Karte $position von $total';
  }

  @override
  String get gamesMemoryTitle => 'Memory';

  @override
  String get gamesMemorySubtitle => 'Finde passende Paare';

  @override
  String get gamesMemoryDescription =>
      'Entspanntes Memory-Spiel ohne Zeitdruck';

  @override
  String get gamesDrawingTitle => 'Zeichnen';

  @override
  String get gamesDrawingSubtitle => 'Freies Malen & Doodles';

  @override
  String get gamesDrawingDescription => 'Drücke dich kreativ aus';

  @override
  String get puzzleCreateTitle => 'Puzzle erstellen';

  @override
  String get puzzleRelaxationTitle => 'Puzzle zur Entspannung';

  @override
  String get puzzleRelaxationSubtitle =>
      'Wähle deinen Puzzle-Typ und die Schwierigkeit. Nimm dir Zeit - es gibt keine Wertung.';

  @override
  String get puzzleTypeLabel => 'Puzzle-Typ';

  @override
  String get puzzleTypeJigsaw => 'Jigsaw';

  @override
  String get puzzleTypeJigsawDescription =>
      'Ziehe Teile an die richtige Stelle';

  @override
  String get puzzleTypeSliding => 'Schiebepuzzle';

  @override
  String get puzzleTypeSlidingDescription => 'Verschiebe Teile durch Antippen';

  @override
  String get puzzleDifficultyLabel => 'Schwierigkeit';

  @override
  String get puzzleDifficultyEasy => 'Einfach';

  @override
  String get puzzleDifficultyEasyDescription =>
      '3×3 Raster - perfekt zum Entspannen';

  @override
  String get puzzleDifficultyMedium => 'Mittel';

  @override
  String get puzzleDifficultyMediumDescription =>
      '4×4 Raster - eine kleine Herausforderung';

  @override
  String get puzzleDifficultyHard => 'Schwer';

  @override
  String get puzzleDifficultyHardDescription =>
      '5×5 Raster - für Puzzle-Profis';

  @override
  String get puzzleSelectImageAndStart => 'Bild auswählen & starten';

  @override
  String get puzzleJigsawTitle => 'Jigsaw Puzzle';

  @override
  String get puzzleSlidingTitle => 'Schiebepuzzle';

  @override
  String puzzleMoves(int count) {
    return 'Züge: $count';
  }

  @override
  String get puzzlePreparing => 'Puzzle wird vorbereitet...';

  @override
  String get puzzleAvailablePieces => 'Verfügbare Teile';

  @override
  String get puzzleTapToMove => 'Tippe auf ein Teil, um es zu verschieben';

  @override
  String get puzzleShowHint => 'Hilfe anzeigen';

  @override
  String puzzleHintMovablePieces(int count) {
    return 'Tipp: Du kannst $count Teile bewegen';
  }

  @override
  String get puzzleSolved => 'Puzzle gelöst!';

  @override
  String puzzleSolvedInMoves(int count) {
    return 'Du hast das Puzzle in $count Zügen gelöst.';
  }

  @override
  String puzzleErrorLoadingImage(String error) {
    return 'Fehler beim Laden des Bildes: $error';
  }

  @override
  String puzzleErrorSharing(String error) {
    return 'Fehler beim Teilen: $error';
  }

  @override
  String get puzzleImagePickerTitle => 'Bild auswählen';

  @override
  String get puzzleImagePickerSubtitle =>
      'Wähle ein beruhigendes Bild für dein Puzzle';

  @override
  String get puzzleImageLoading => 'Bild wird geladen...';

  @override
  String get puzzleImageLoadFailed => 'Bild konnte nicht geladen werden';

  @override
  String get puzzleImageSourceGallery => 'Galerie';

  @override
  String get puzzleImageSourceGallerySubtitle =>
      'Bild aus deiner Galerie wählen';

  @override
  String get puzzleImageSourceCamera => 'Kamera';

  @override
  String get puzzleImageSourceCameraSubtitle => 'Neues Foto aufnehmen';

  @override
  String get puzzleImageSourceOnline => 'Online';

  @override
  String get puzzleImageSourceOnlineSubtitle =>
      'Beruhigendes Bild vom Internet';

  @override
  String get puzzleSelectCategory => 'Kategorie wählen';

  @override
  String get errorNoProfileSelected => 'Kein Profil ausgewählt';

  @override
  String get mantrasTitle => 'Mantras';

  @override
  String get mantrasComingSoonTitle => 'Mantras - Coming Soon ✨';

  @override
  String get mantrasComingSoonSubtitle =>
      'Beruhigende Affirmationen und positive Mantras für schwierige Momente';

  @override
  String get helpResourcesTitle => 'Hilfsangebote';

  @override
  String get helpHotlinesTitle => '24/7 Notfall-Hotlines';

  @override
  String get helpHotlinesSubtitle =>
      'Professionelle Unterstützung - jederzeit erreichbar';

  @override
  String get helpMoreResourcesTitle => 'Weitere Ressourcen folgen';

  @override
  String get helpMoreResourcesDescription =>
      'In zukünftigen Updates:\n• Therapie-Ressourcen\n• Selbsthilfegruppen\n• Informationsmaterial über DIS\n• Krisenpläne & Strategien';

  @override
  String get moreTitle => 'Weitere Funktionen';

  @override
  String get moreHelpResources => 'Hilfsangebote';

  @override
  String get moreHelpResourcesDescription =>
      'Informationen und Links zu professioneller Unterstützung';

  @override
  String get moreGames => 'Spiele & Entspannung';

  @override
  String get moreGamesDescription =>
      'Atemübungen, Memory und mehr zur Ablenkung';

  @override
  String get moreSettings => 'Einstellungen';

  @override
  String get moreSettingsDescription => 'App-Konfiguration und Datenschutz';

  @override
  String get permissionsTitle => 'Rechte & Berechtigungen';

  @override
  String get permissionsNoProfiles => 'Keine Profile vorhanden';

  @override
  String get permissionsInfoText =>
      'Hier kannst du Berechtigungen für jedes Profil verwalten. Tippe auf ein Profil um Details zu sehen.';

  @override
  String get permissionsAllRightsAdmin => 'Alle Rechte (Administrator)';

  @override
  String permissionsCount(int count) {
    return '$count Berechtigungen';
  }

  @override
  String get permissionsAdminBadge => 'Admin';

  @override
  String get permissionsAdministrator => 'Administrator';

  @override
  String permissionsDetailTitle(String name) {
    return 'Berechtigungen: $name';
  }

  @override
  String get permissionsChangeError =>
      'Berechtigung konnte nicht geändert werden';

  @override
  String get permissionsMakeAdminTitle => 'Administrator ernennen';

  @override
  String permissionsMakeAdminMessage(String name) {
    return '$name wird zum Administrator mit allen Rechten. Fortfahren?';
  }

  @override
  String get permissionsMakeAdminButton => 'Zum Administrator machen';

  @override
  String get permissionsMakeAdminSubtitle => 'Gibt alle Rechte';

  @override
  String get permissionsRevokeAdminTitle => 'Administrator-Status entfernen';

  @override
  String permissionsRevokeAdminMessage(String name) {
    return '$name verliert alle Admin-Rechte und bekommt Standard-Berechtigungen. Fortfahren?';
  }

  @override
  String get permissionsRevokeAdminSubtitle =>
      'Setzt auf Standard-Rechte zurück';

  @override
  String get permissionsRevokeAdminError =>
      'Admin-Status konnte nicht entfernt werden. Das erste Profil muss Administrator bleiben.';

  @override
  String permissionsActiveCount(int active, int total) {
    return '$active / $total aktiv';
  }

  @override
  String get permissionsCategorySystem => 'System-Berechtigungen';

  @override
  String get permissionsCategoryChat => 'Chat';

  @override
  String get permissionsCategoryCalendar => 'Kalender';

  @override
  String get permissionsCategoryMedication => 'Medikamente';

  @override
  String get permissionsCategoryContacts => 'Kontakte';

  @override
  String get permissionsCategoryFinder => 'Finder (Orte & Gegenstände)';

  @override
  String get permissionsCategoryDiary => 'Tagebuch';

  @override
  String get permissionsCategoryEmergency => 'Notfallkontakte';

  @override
  String get permissionsCategorySecurity => 'Sicherheit';

  @override
  String profileAgeYears(int age) {
    return '$age Jahre';
  }

  @override
  String get groundingTitle => 'Halt';

  @override
  String get groundingChooseLabel => 'Oder such dir etwas aus';

  @override
  String get groundingDoneAgain => 'Nochmal';

  @override
  String get groundingDoneOther => 'Was anderes';

  @override
  String get groundingDoneCall => 'Jemanden anrufen';

  @override
  String get groundingOrientationTitle => 'Hier und Jetzt';

  @override
  String get groundingOrientationStep1 => 'Heute ist';

  @override
  String get groundingOrientationStep2 => 'Schau dich um. Wo bist du gerade?';

  @override
  String get groundingOrientationStep3 => 'Sag laut oder leise, wer du bist.';

  @override
  String get groundingOrientationStep4 =>
      'Der Körper von heute ist nicht der von damals.';

  @override
  String get groundingOrientationStep5 => 'Was du erinnerst, ist vorbei.';

  @override
  String get groundingOrientationStep6 => 'Du bist hier.';

  @override
  String get groundingSensesTitle => 'Sehen, hören, spüren';

  @override
  String get groundingSensesStep1 => 'Fünf Dinge, die du siehst.';

  @override
  String get groundingSensesStep2 => 'Vier Dinge, die du hörst.';

  @override
  String get groundingSensesStep3 => 'Drei Dinge, die du anfassen kannst.';

  @override
  String get groundingSensesStep4 => 'Zwei Dinge, die du riechst.';

  @override
  String get groundingSensesStep5 => 'Eine Sache, die du schmeckst.';

  @override
  String get groundingSensesStep6 => 'Du bist hier.';

  @override
  String get groundingBodyTitle => 'Körper spüren';

  @override
  String get groundingBodyStep1 => 'Stell beide Füße flach auf den Boden.';

  @override
  String get groundingBodyStep2 => 'Drück die Fersen nach unten.';

  @override
  String get groundingBodyStep3 => 'Nimm etwas Kaltes in die Hand.';

  @override
  String get groundingBodyStep4 => 'Halt es fest, solange du magst.';

  @override
  String get groundingBodyStep5 => 'Spür deinen Rücken an der Lehne.';

  @override
  String get groundingBodyStep6 => 'Der Boden trägt dich.';

  @override
  String get groundingContainerTitle => 'Wegschließen';

  @override
  String get groundingContainerStep1 =>
      'Stell dir einen Behälter vor. So groß, wie du willst.';

  @override
  String get groundingContainerStep2 =>
      'Er hat einen Deckel, der fest schließt.';

  @override
  String get groundingContainerStep3 => 'Leg hinein, was gerade zu viel ist.';

  @override
  String get groundingContainerStep4 => 'Mach den Deckel zu.';

  @override
  String get groundingContainerStep5 =>
      'Stell ihn an einen Ort, den du bestimmst.';

  @override
  String get groundingContainerStep6 =>
      'Du kannst ihn wieder öffnen. Nicht jetzt.';

  @override
  String get groundingBreathTitle => 'Atem';

  @override
  String get groundingBreathStep1 => 'Atme ein und zähl bis vier.';

  @override
  String get groundingBreathStep2 => 'Halt kurz.';

  @override
  String get groundingBreathStep3 => 'Atme aus und zähl bis sechs.';

  @override
  String get groundingBreathStep4 => 'Nochmal. Ohne Eile.';

  @override
  String get groundingBreathStep5 => 'Langsamer raus als rein. Das reicht.';

  @override
  String get medicationNameLabel => 'Medikamenten-Name';

  @override
  String get medicationDosageLabel => 'Dosierung';

  @override
  String get medicationDosageHint => 'z.B. 1 Tablette, 10mg, 5ml';

  @override
  String get medicationNameRequired => 'Bitte Namen eingeben';

  @override
  String get medicationDosageRequired => 'Bitte Dosierung eingeben';

  @override
  String get medicationTypeQuestion => 'Was für ein Medikament?';

  @override
  String get medicationTypeDailyTitle => 'Tagesmedizin';

  @override
  String get medicationTypeDailyExplanation => 'Zu festen Zeiten, jeden Tag';

  @override
  String get medicationTypeAsNeededTitle => 'Bedarfsmedizin';

  @override
  String get medicationTypeAsNeededExplanation => 'Nur wenn du sie brauchst';

  @override
  String get medicationWhenToTake => 'Wann nehmen?';

  @override
  String get medicationSectionMorning => 'Morgens';

  @override
  String get medicationSectionMidday => 'Mittags';

  @override
  String get medicationSectionEvening => 'Abends';

  @override
  String get medicationSectionNight => 'Nachts';

  @override
  String get medicationOtherTime => 'Andere Zeit';

  @override
  String get medicationSectionNotChosen => 'nicht ausgewählt';

  @override
  String get medicationTimeRequired =>
      'Bitte mindestens eine Einnahmezeit hinzufügen';

  @override
  String get medicationAsNeededSettings => 'Bedarfsmedizin-Einstellungen';

  @override
  String get medicationMaxDosesLabel => 'Maximale Anzahl pro Tag *';

  @override
  String get medicationMaxDosesHint => 'z.B. 3';

  @override
  String get medicationMaxDosesHelper =>
      'Wie oft darf das Medikament pro Tag genommen werden?';

  @override
  String get medicationMaxDosesRequired => 'Pflichtfeld für Bedarfsmedizin';

  @override
  String get medicationMaxDosesInvalid => 'Bitte gültige Zahl > 0 eingeben';

  @override
  String get medicationMaxDosesMissing =>
      'Bitte maximale Anzahl pro Tag angeben';

  @override
  String get medicationMinIntervalLabel =>
      'Mindestabstand in Stunden (optional)';

  @override
  String get medicationMinIntervalHint => 'z.B. 4';

  @override
  String get medicationMinIntervalHelper =>
      'Mindestzeit zwischen zwei Einnahmen';

  @override
  String get medicationMinIntervalInvalid => 'Bitte gültige Zahl >= 0 eingeben';

  @override
  String get medicationRemindersTitle => 'Aurora erinnert dich';

  @override
  String get medicationRemindersOff =>
      'Aurora sagt nichts. Das Medikament steht weiter in deiner Liste, du entscheidest selbst, wann du nachsiehst.';

  @override
  String get medicationRemindersDaily =>
      'Zu jeder Einnahmezeit meldet sich Aurora dreimal: 30 Minuten vorher, 10 Minuten vorher und zur Zeit selbst. Wenn du nicht reagierst, noch einmal 10 Minuten später.';

  @override
  String get medicationRemindersNoInterval =>
      'Ohne Mindestabstand gibt es keinen Zeitpunkt, auf den Aurora warten könnte. Trag unten einen Abstand ein, wenn du erinnert werden willst, sobald die nächste Dosis erlaubt ist.';

  @override
  String get medicationRemindersAsNeeded =>
      'Nach einer Einnahme sagt Aurora Bescheid, sobald die nächste Dosis erlaubt ist — und kündigt sie 30, 10 und 5 Minuten vorher an.';

  @override
  String get medicationPeriodTitle => 'Zeitraum (optional)';

  @override
  String get medicationStartDate => 'Startdatum';

  @override
  String get medicationEndDate => 'Enddatum';

  @override
  String get medicationNotesLabel => 'Notizen (optional)';

  @override
  String get medicationNotesHint => 'z.B. Mit Essen einnehmen';

  @override
  String get medicationDescriptionLabel =>
      'Detaillierte Beschreibung (optional)';

  @override
  String get medicationDescriptionHint =>
      'Hilft bei der Unterscheidung ähnlicher Medikamente';

  @override
  String get medicationPhotoTitle => 'Tabletten-Foto (optional)';

  @override
  String get medicationPhotoHint =>
      'Foto hilft bei der Identifikation und vermeidet Verwechslungen';

  @override
  String get medicationPhotoTake => 'Foto aufnehmen';

  @override
  String get medicationPhotoRetake => 'Neu aufnehmen';

  @override
  String medicationPhotoError(String error) {
    return 'Foto konnte nicht geladen werden: $error';
  }

  @override
  String get medicationActiveTitle => 'Aktiv';

  @override
  String get medicationActiveOn => 'Medikament wird in Tagesliste angezeigt';

  @override
  String get medicationActiveOff => 'Medikament ist archiviert';

  @override
  String get medicationDeleteTitle => 'Medikament löschen?';

  @override
  String get medicationDeleteMessage =>
      'Möchtest du dieses Medikament wirklich löschen?';

  @override
  String get medicationDeleteConfirmMessage =>
      'Dieses Medikament wird dauerhaft gelöscht.';

  @override
  String get medicationDeleted => 'Medikament gelöscht';

  @override
  String get medicationIntakeTimesLabel => 'Einnahmezeiten';

  @override
  String get medicationMaxDailyLabel => 'Max. Tagesdosis';

  @override
  String get medicationMinGapLabel => 'Min. Abstand';

  @override
  String get medicationStatusLabel => 'Status';

  @override
  String get medicationStatusTaken => 'Genommen';

  @override
  String get medicationStatusRefused => 'Verweigert';

  @override
  String get medicationStatusSnoozed => 'Später';

  @override
  String get medicationTake => 'Nehmen';

  @override
  String get medicationTakeAnyway => 'Trotzdem nehmen';

  @override
  String get medicationDailyLimitReached => 'Tageslimit erreicht';

  @override
  String get medicationAddFeedback => 'Feedback hinzufügen';

  @override
  String get medicationFeedbackYourExperience => 'Deine Erfahrung';

  @override
  String get medicationRefusalTitle => 'Verweigerung dokumentieren';

  @override
  String get medicationIntakesLabel => 'Einnahmen';

  @override
  String get medicationNoProfileSelected => 'Kein Profil ausgewählt';

  @override
  String get medicationNoLogPermission =>
      'Keine Berechtigung zur Einnahmeprotokollierung';

  @override
  String get commonGallery => 'Galerie';

  @override
  String get commonCamera => 'Kamera';

  @override
  String get medicationStatusSkipped => 'Übersprungen';

  @override
  String medicationWillBeRefused(String name) {
    return '$name wird als verweigert markiert.';
  }

  @override
  String clockTime(String time) {
    return '$time Uhr';
  }

  @override
  String medicationReminderAtTime(String time) {
    return 'Erinnerung um $time';
  }

  @override
  String medicationSnoozedUntil(String name, String time) {
    return '$name — Erinnerung um $time Uhr';
  }

  @override
  String medicationAtTime(String time) {
    return '$time Uhr';
  }

  @override
  String medicationDoseCountToday(int available, int max) {
    return 'Verfügbar: $available von $max heute';
  }

  @override
  String medicationLastTaken(String time) {
    return 'Letzte Einnahme: $time';
  }

  @override
  String medicationNextPossible(String time) {
    return 'Nächste Einnahme möglich um $time Uhr';
  }

  @override
  String medicationNoteLabel(String note) {
    return 'Notiz: $note';
  }

  @override
  String medicationLimitWarning(int count, String name) {
    return 'Du hast heute bereits $count Dosen von $name genommen. Das ist das Tageslimit.';
  }

  @override
  String medicationTakenConfirmation(String name) {
    return '$name eingenommen';
  }

  @override
  String get anchorTitle => 'Anker';

  @override
  String get anchorSectionWhenHard => 'Wenn es schwer ist';

  @override
  String get anchorSectionEveryday => 'Alltag';

  @override
  String get anchorSectionWhenCalm => 'Wenn Ruhe ist';

  @override
  String get fabMedication => 'Medikament';

  @override
  String get fabDiaryEntry => 'Eintrag';

  @override
  String get fabContact => 'Kontakt';

  @override
  String get appQuitTitle => 'App beenden?';

  @override
  String get appQuitMessage => 'Möchtest du Aurora wirklich beenden?';

  @override
  String get emergencyResetTitle => 'Notfall-Reset';

  @override
  String get emergencyResetWarning =>
      'WARNUNG: Alle Daten werden unwiderruflich gelöscht!\n\nProfile, Nachrichten, Termine, Medikamente, Kontakte — alles.\n\nDieser Schritt kann nicht rückgängig gemacht werden.';

  @override
  String get emergencyResetConfirm => 'ALLES LÖSCHEN';

  @override
  String get pwResetCancelledTitle => 'Zurücksetzen abgebrochen';

  @override
  String get pwResetCancelledMessage =>
      'Der laufende Passwort-Reset wurde mit dem alten Passwort abgebrochen. Dein Profil ist jetzt aktiv.';

  @override
  String get pwResetUnderstood => 'Verstanden';

  @override
  String get pwResetNowActiveTitle => 'Neues Passwort aktiv';

  @override
  String get pwResetNowActiveMessage =>
      'Das neue Passwort wurde nach Ablauf der Wartezeit automatisch aktiviert. Dein Profil ist jetzt aktiv.';

  @override
  String get pwResetTitle => 'Passwort zurücksetzen';

  @override
  String get pwResetAnswerQuestions =>
      'Beantworte die Sicherheitsfragen für sofortigen Reset';

  @override
  String pwResetAnswerN(int number) {
    return 'Antwort $number';
  }

  @override
  String get pwResetForgotAnswers =>
      'Antworten vergessen?\n24-Stunden Timer starten';

  @override
  String get pwResetAnswerAll => 'Bitte alle Fragen beantworten';

  @override
  String get pwResetAnswersWrong =>
      'Antworten sind nicht korrekt.\n\nDu kannst es nochmal versuchen oder den 24h-Timer starten.';

  @override
  String get pwResetCheckAnswers => 'Antworten prüfen';

  @override
  String get pwResetSetNewTitle => 'Neues Passwort setzen';

  @override
  String get pwResetAnswersCorrect => 'Sicherheitsfragen korrekt beantwortet!';

  @override
  String get pwResetImmediateHint =>
      'Gib dein neues Passwort ein. Es wird sofort aktiviert.';

  @override
  String get pwResetNewPassword => 'Neues Passwort';

  @override
  String get pwResetConfirmPassword => 'Passwort bestätigen';

  @override
  String get pwResetTooShort => 'Passwort muss mindestens 4 Zeichen lang sein';

  @override
  String get pwResetMismatch => 'Passwörter stimmen nicht überein';

  @override
  String get pwResetChanged =>
      'Passwort erfolgreich geändert!\n\nDu kannst dich jetzt mit dem neuen Passwort anmelden.';

  @override
  String get pwResetSetPassword => 'Passwort setzen';

  @override
  String get pwResetTimerHint =>
      'Gib dein neues Passwort ein.\n\nNach dem Start läuft ein 24-Stunden Timer, danach kannst du das neue Passwort aktivieren.';

  @override
  String pwResetStarted(String waitTime) {
    return 'Passwort-Reset gestartet!\n\nDein altes Passwort bleibt aktiv. In $waitTime kannst du das neue Passwort aktivieren.';
  }

  @override
  String get pwResetStartError => 'Fehler beim Starten des Passwort-Resets';

  @override
  String get pwResetStart => 'Reset starten';

  @override
  String get pwResetRunningTitle => 'Passwort-Reset läuft';

  @override
  String get pwResetWhatsHappening => 'Was passiert gerade?';

  @override
  String get pwResetRunningExplanation =>
      'Du hast vor Kurzem ein neues Passwort festgelegt. Aus Sicherheitsgründen läuft jetzt ein 24-Stunden Timer.\n\n';

  @override
  String pwResetRemaining(String time) {
    return 'Verbleibende Zeit: $time';
  }

  @override
  String get pwResetReadyTitle => 'Bereit zum Aktivieren';

  @override
  String get pwResetWaitOver => 'Die Wartezeit ist vorbei!';

  @override
  String pwResetReadyExplanation(String startTime) {
    return 'Du hast $startTime ein neues Passwort festgelegt. Die 24-Stunden Sicherheitsfrist ist nun abgelaufen.';
  }

  @override
  String get pwResetIrreversible =>
      'Wenn du aktivierst, wird dein ALTES Passwort unwiderruflich durch das NEUE Passwort ersetzt.';

  @override
  String get pwResetActivated =>
      'Neues Passwort aktiviert!\n\nDu kannst dich jetzt mit dem neuen Passwort anmelden.';

  @override
  String get pwResetActivateError => 'Fehler beim Aktivieren des Passworts';

  @override
  String get pwResetActivate => 'Neues Passwort aktivieren';

  @override
  String get profileCurrentlyActive => 'Aktuell aktives Profil';

  @override
  String get profilePasswordProtected => 'Dieses Profil ist passwortgeschützt';

  @override
  String get profilePasswordLabel => 'Passwort';

  @override
  String get settingsMapCacheClearQuestion =>
      'Möchtest du alle gespeicherten Kartenkacheln löschen?';

  @override
  String get settingsMapCacheCleared => 'Karten-Cache geleert';

  @override
  String get settingsMapPredownloadComingSoon =>
      'Das Vorab-Herunterladen kommt in einer späteren Version';

  @override
  String get settingsCacheLimitTitle => 'Cache-Limit festlegen';

  @override
  String settingsCacheLimitValue(int size) {
    return 'Maximale Cache-Größe: $size MB';
  }

  @override
  String settingsCacheLimitMegabytes(int size) {
    return '$size MB';
  }

  @override
  String get settingsCacheLimitExplanation =>
      'Wenn der Cache dieses Limit überschreitet, werden automatisch die ältesten Kacheln gelöscht.';

  @override
  String get settingsAllDataDeleted => 'Alle Daten wurden gelöscht';

  @override
  String get settingsDeleteIncomplete =>
      'Es konnte nicht alles gelöscht werden. Bitte noch einmal versuchen.';

  @override
  String get settingsTrackingEnableTitle => 'Dauerhaftes Tracking aktivieren?';

  @override
  String get settingsTrackingWhatItDoes => 'Das bewirkt dieser Modus:';

  @override
  String get settingsDataStaysHere => 'Deine Daten bleiben auf diesem Gerät';

  @override
  String get settingsDataStaysHereExplanation =>
      'Aurora speichert alle Daten nur lokal.';

  @override
  String get settingsBackgroundGpsBattery =>
      'Background-GPS kann den Akku stärker belasten.';

  @override
  String get settingsAndroidStatus => 'Android-Status:';

  @override
  String get settingsActivate => 'Aktivieren';

  @override
  String get settingsDeactivate => 'Deaktivieren';

  @override
  String get settingsTrackingDisableTitle =>
      'Dauerhaftes Tracking deaktivieren?';

  @override
  String get settingsTrackingDisableExplanation =>
      'Das GPS-Tracking wird wieder pro Profil gesteuert.';

  @override
  String get settingsTestNotificationSent => 'Test-Benachrichtigung gesendet';

  @override
  String get settingsAndroidSettingNeeded => 'Android-Einstellung erforderlich';

  @override
  String settingsPermissionNeededFor(String permission) {
    return 'Um dauerhaftes Tracking zu nutzen, brauchst du die Berechtigung „$permission\".';
  }

  @override
  String get settingsStepByStep => 'Ich helfe dir Schritt für Schritt:';

  @override
  String get settingsOpenAndroidSettings => 'Android-Einstellungen öffnen';

  @override
  String get settingsOpenNow => 'Jetzt öffnen';

  @override
  String get settingsInTheSettings => 'In den Einstellungen';

  @override
  String get settingsBackToAurora =>
      'Zurück zu Aurora\nDie App erkennt die Änderung automatisch.';

  @override
  String get settingsUnderstood => 'Verstanden';

  @override
  String settingsResetPendingFor(String name, String time) {
    return 'Profil: $name\nVerbleibend: $time';
  }

  @override
  String settingsWhatIs(String name) {
    return 'Was ist „$name\"?';
  }

  @override
  String get settingsAdminTrackingExplanation =>
      'Als Admin kannst du das GPS-Tracking für ALLE Profile zentral steuern. Wenn aktiviert:';

  @override
  String settingsPrerequisite(String permission) {
    return 'Voraussetzung: die Android-Berechtigung „$permission\".';
  }

  @override
  String get settingsGpsPermission => 'GPS-Berechtigung';

  @override
  String get settingsBackgroundReady =>
      'Alles bereit für dauerhaftes Tracking.';

  @override
  String settingsHowToEnable(String permission) {
    return 'So aktivierst du „$permission\"';
  }

  @override
  String get settingsLocationStaysHere =>
      'Deine Standortdaten bleiben auf diesem Gerät.';

  @override
  String get settingsTrackingAlwaysOn => 'Tracking dauerhaft an';

  @override
  String get settingsHowNotificationsWork =>
      'Wie funktionieren Benachrichtigungen?';

  @override
  String get settingsSendTestNotification => 'Test-Benachrichtigung senden';

  @override
  String get settingsCheckNotificationsWork =>
      'Prüfe, ob Benachrichtigungen ankommen';

  @override
  String get settingsQueue => 'Warteschlange';

  @override
  String get settingsScheduledNotifications => 'Geplante Benachrichtigungen:';

  @override
  String settingsNextAt(String time) {
    return 'Nächste: $time';
  }

  @override
  String settingsCacheUsage(String used, String limit, String count) {
    return '$used MB von $limit MB • $count Kacheln';
  }

  @override
  String settingsPercent(int value) {
    return '$value%';
  }

  @override
  String get settingsCacheLimitLabel => 'Cache-Limit';

  @override
  String get settingsPredownloadMaps => 'Karten vorab herunterladen';

  @override
  String get settingsPredownloadSubtitle =>
      'Lädt Karten für einen Umkreis herunter';

  @override
  String get settingsClearCache => 'Cache leeren';

  @override
  String get settingsClearCacheSubtitle =>
      'Alle gespeicherten Kartenkacheln löschen';

  @override
  String get settingsDiscreetRemindersTitle => 'Erinnerungen ohne Inhalt';

  @override
  String get settingsDiscreetRemindersOn =>
      'Auf dem Sperrbildschirm steht nur „Aurora — Erinnerung\". Was gemeint ist, siehst du nach dem Entsperren.';

  @override
  String get settingsDiscreetRemindersOff =>
      'Auf dem Sperrbildschirm stehen Name und Dosis beziehungsweise der Termin im Klartext.';

  @override
  String get settingsWhatAuroraSends => 'Was Aurora sendet';

  @override
  String get settingsWhatAuroraSendsSubtitle =>
      'Jede Übertragung im Wortlaut einsehen';

  @override
  String get settingsAlwaysAllow => 'Immer erlauben';

  @override
  String get settingsAlwaysAllowRequired =>
      'GPS-Berechtigung „Immer erlauben\" erforderlich';

  @override
  String get settingsLocalOnly =>
      'Aurora speichert alle Daten nur lokal. Keine Cloud, keine Server, keine Übertragung.';

  @override
  String get settingsTrackingDisableFull =>
      'Das GPS-Tracking wird wieder pro Profil gesteuert.\n\nJedes Profil kann es dann selbst ein- und ausschalten.';

  @override
  String get settingsAlwaysAllowNeeded =>
      'Um dauerhaftes Tracking zu nutzen, brauchst du die Berechtigung „Immer erlauben\".';

  @override
  String get settingsWhatIsAlwaysOn => 'Was ist „Tracking dauerhaft an\"?';

  @override
  String get settingsAlwaysAllowPrerequisite =>
      'Voraussetzung: Die Android-Berechtigung „Immer erlauben\" muss aktiv sein, damit das Tracking auch bei geschlossener App läuft.';

  @override
  String get settingsHowToEnableAlwaysAllow =>
      'So aktivierst du „Immer erlauben\":';

  @override
  String get settingsLocationStaysOffline =>
      'Deine Standortdaten bleiben auf diesem Gerät. Aurora arbeitet offline, ohne Server-Verbindung.';

  @override
  String settingsCountValue(int count) {
    return '$count';
  }

  @override
  String settingsTilesCount(String used, String limit, String count) {
    return '$used MB von $limit MB • $count Kacheln';
  }

  @override
  String settingsMaxStorage(int size) {
    return '$size MB maximale Speichergröße';
  }

  @override
  String errorWithDetail(String error) {
    return 'Fehler: $error';
  }

  @override
  String get securityQuestionsFillAll =>
      'Bitte alle 3 Fragen und Antworten ausfüllen';

  @override
  String get securityQuestionsSaved =>
      'Sicherheitsfragen gespeichert!\n\nDu kannst sie jetzt zum Zurücksetzen des Passworts nutzen.';

  @override
  String get securityQuestionsRemoveTitle => 'Sicherheitsfragen entfernen?';

  @override
  String get securityQuestionsRemoveWarning =>
      'Wenn du die Sicherheitsfragen entfernst, kannst du dein Passwort nur noch über den 24-Stunden-Timer zurücksetzen.';

  @override
  String get securityQuestionsRemoved => 'Sicherheitsfragen entfernt';

  @override
  String get securityQuestionsSetupTitle => 'Sicherheitsfragen einrichten';

  @override
  String get securityQuestionsSetupExplanation =>
      'Richte 3 Sicherheitsfragen ein, um dein Passwort schnell zurücksetzen zu können.';

  @override
  String get securityQuestionsChooseWisely =>
      'Wähle Fragen, deren Antworten du nie vergisst';

  @override
  String securityQuestionN(int number) {
    return 'Frage $number';
  }

  @override
  String securityAnswerToQuestionN(int number) {
    return 'Antwort auf Frage $number';
  }

  @override
  String get securityQuestionHint1 => 'z.B. Name meines ersten Haustieres?';

  @override
  String get securityQuestionHint2 => 'z.B. Geburtsort meiner Mutter?';

  @override
  String get securityQuestionHint3 => 'z.B. Mein Lieblingsfilm als Kind?';

  @override
  String get errorReportPreviewTitle => 'Vorschau des Fehlerberichts';

  @override
  String get errorReportWhatIsSent => 'Diese Angaben werden gesendet:';

  @override
  String get errorReportContactSection => 'Kontakt (optional)';

  @override
  String get errorReportContactExplanation =>
      'Nur wenn du möchtest, dass wir dich bei Rückfragen erreichen können:';

  @override
  String get errorReportEmailLabel => 'E-Mail-Adresse (optional)';

  @override
  String get errorReportNewsletter => 'Für Neuigkeiten anmelden';

  @override
  String get errorReportNewsletterSubtitle =>
      'Erhalte Neuigkeiten zu Aurora, höchstens einmal im Monat';

  @override
  String get errorReportEmailUseOnly =>
      'Deine E-Mail-Adresse nutzen wir nur für Rückfragen zu diesem Bericht.';

  @override
  String get errorReportCopy => 'Kopieren';

  @override
  String get errorReportCopied => 'Bericht in die Zwischenablage kopiert';

  @override
  String errorReportAutoGenerated(String type) {
    return 'Automatisch erzeugter Bericht ($type).';
  }

  @override
  String get errorReportQueued =>
      'Bericht angenommen. Er geht raus, sobald du wieder online bist.';

  @override
  String get errorReportFailed => 'Der Bericht konnte nicht gesendet werden';

  @override
  String get errorReportCopyToClipboard => 'In die Zwischenablage kopieren';

  @override
  String permissionsLevel(int level) {
    return 'Stufe $level';
  }

  @override
  String get permissionsSectionExplanation =>
      'Lege fest, welche Bereiche dieses Profil nutzen kann. Jeder Bereich lässt sich einzeln einstellen:';

  @override
  String get permissionsChildPreset => 'Kind-Voreinstellung';

  @override
  String get permissionsAdultPreset => 'Erwachsenen-Voreinstellung';

  @override
  String get permissionsCategoryEmergencyDiary => 'Notfall-Tagebuch';

  @override
  String get permissionsCategoryHelp => 'Hilfe';

  @override
  String get permissionsCategoryMantras => 'Mantras';

  @override
  String get permissionsCategoryGames => 'Spiele';

  @override
  String get permissionsChangeableLater =>
      'Du kannst die Berechtigungen jederzeit in den Einstellungen ändern';

  @override
  String get errorReportRoute =>
      'Der Bericht geht direkt an die Entwickler; klappt das nicht, öffnet Aurora deine E-Mail-App. Was gesendet wurde, steht in den Einstellungen unter „Was Aurora sendet\".';

  @override
  String get errorReportEmailPrivacy =>
      'Deine E-Mail-Adresse nutzen wir nur für Rückfragen zu diesem Bericht und geben sie nicht weiter.';

  @override
  String errorReportAutoBody(String type) {
    return 'Automatisch erzeugter Bericht ($type). Die Einzelheiten stehen in der Gerätediagnose.';
  }

  @override
  String errorReportClipboardFallback(String email) {
    return 'Der Bericht liegt in der Zwischenablage. Du kannst ihn uns auch per E-Mail an $email schicken.';
  }

  @override
  String get mapAddressNotFound => 'Adresse nicht gefunden';

  @override
  String get mapNeedsInternet => 'Für die Adress-Suche braucht Aurora Internet';

  @override
  String get mapDataEnabled => 'Kartendaten aktiviert — die Karte wird geladen';

  @override
  String get mapTapOrSearch => 'Tippe auf die Karte oder such eine Adresse';

  @override
  String get mapAddressLoading => 'Adresse wird geladen…';

  @override
  String get mapPickTitle => 'Ort eintragen';

  @override
  String get mapTapSearchOrLocate =>
      'Tippe auf die Karte, such eine Adresse oder nimm deinen Standort';

  @override
  String get mapSearchHint => 'Adresse suchen (z.B. Kirchstraße 3, Coswig)';

  @override
  String get mapDataNotLoaded => 'Kartendaten nicht geladen';

  @override
  String get mapEnableToMark =>
      'Aktiviere die Kartendaten, um Orte auf der Karte zu markieren.';

  @override
  String get mapDataFromOsm =>
      'Die Kartendaten kommen von OpenStreetMap.\nDafür braucht Aurora einmalig eine Internetverbindung.';

  @override
  String get mapZoomIn => 'Vergrößern';

  @override
  String get mapZoomOut => 'Verkleinern';

  @override
  String get mapToMyLocation => 'Zu meiner Position';

  @override
  String get feedbackSheetTitle => 'Kontakt zum Entwickler';

  @override
  String get feedbackSheetIntro =>
      'Aurora ist in der offenen Beta und lebt von deinen Rückmeldungen.';

  @override
  String get feedbackReplyOnlyIfWanted => 'Nur wenn du eine Antwort möchtest';

  @override
  String errorOpening(String error) {
    return 'Fehler beim Öffnen: $error';
  }

  @override
  String errorLinkNotOpened(String url) {
    return 'Der Link ließ sich nicht öffnen: $url';
  }

  @override
  String get thankYouTitle => 'Vielen Dank!';

  @override
  String get thankYouReportSent =>
      'Dein Bericht ist angekommen und hilft uns, Aurora besser zu machen.';

  @override
  String get thankYouReportRecorded => 'Dein Fehlerbericht wurde erfasst';

  @override
  String get thankYouJoinCommunity => 'Komm in die Community';

  @override
  String get thankYouDiscord => 'Discord-Server';

  @override
  String get thankYouDiscordSubtitle =>
      'Tausch dich mit anderen Nutzenden und dem Team aus';

  @override
  String get thankYouMoreContact => 'Weitere Wege zu uns';

  @override
  String get thankYouEmailSupport => 'E-Mail-Unterstützung';

  @override
  String get thankYouWhatsNext => 'Wie geht es weiter?';

  @override
  String get thankYouBackToApp => 'Zurück zu Aurora';

  @override
  String get transparencyDeleteTitle => 'Eintrag löschen?';

  @override
  String get transparencyDeleteMessage =>
      'Der Eintrag verschwindet aus dieser Liste. Was bereits gesendet wurde, kommt dadurch nicht zurück.';

  @override
  String get transparencyIntro =>
      'Hier siehst du jede Übertragung, die dein Gerät verlassen hat — im Wortlaut.';

  @override
  String get transparencyNothingSent => 'Es wurde noch nichts gesendet.';

  @override
  String get transparencySendUsageData => 'Anonyme Nutzungsdaten senden';

  @override
  String get transparencyIrreversible =>
      'Was bereits gesendet wurde, kann nicht zurückgeholt werden. Es ist unterwegs.';

  @override
  String imagePickerAnimalError(String error) {
    return 'Der Tier-Avatar ließ sich nicht auswählen: $error';
  }

  @override
  String get imagePickerCameraNeeded =>
      'Zum Fotografieren braucht Aurora die Kamera-Berechtigung';

  @override
  String get imagePickerGalleryNeeded =>
      'Zum Auswählen von Bildern braucht Aurora die Galerie-Berechtigung';

  @override
  String get imagePickerAllowInSettings => 'In den Einstellungen erlauben';

  @override
  String get imagePickerOpenSettings => 'Einstellungen öffnen';

  @override
  String imagePickerPickError(String error) {
    return 'Das Bild ließ sich nicht auswählen: $error';
  }

  @override
  String imagePickerSaveError(String error) {
    return 'Das Bild ließ sich nicht speichern: $error';
  }

  @override
  String get feedbackThankYouTitle => 'Dein Feedback wurde erfasst';

  @override
  String get feedbackThankYouMessage =>
      'Vielen Dank! Dein Feedback hilft uns, Aurora zu verbessern.';

  @override
  String get feedbackStayInTouch => 'Bleib in Kontakt';

  @override
  String get feedbackAuroraDiscord => 'Aurora auf Discord';

  @override
  String get feedbackWebsite => 'Website';

  @override
  String get feedbackEmail => 'E-Mail';

  @override
  String get crashTitle => 'Etwas ist schiefgelaufen';

  @override
  String get crashMessage =>
      'Aurora ist auf einen unerwarteten Fehler gestoßen. Deine Daten sind davon nicht betroffen.';

  @override
  String get crashTechnicalDetails => 'Technische Einzelheiten';

  @override
  String get crashReport => 'Fehler melden';

  @override
  String get crashRestart => 'App neu starten';

  @override
  String get crashContinue => 'Trotzdem weitermachen';

  @override
  String get doodleSendDrawing => 'Zeichnung senden';

  @override
  String get doodleSticker => 'Sticker';

  @override
  String get doodleStrokeWidth => 'Strichstärke';

  @override
  String get doodleStrokeThin => 'Dünner Strich';

  @override
  String get doodleStrokeMedium => 'Mittlerer Strich';

  @override
  String get doodleStrokeThick => 'Dicker Strich';

  @override
  String get imagePickerDrawYourself => 'Selbst malen';

  @override
  String get doodleAvatarTitle => 'Dein Bild malen';

  @override
  String get doodleAvatarDone => 'Fertig';

  @override
  String get doodleAvatarEmptyHint => 'Erst malen, dann übernehmen';

  @override
  String get permCreateProfilesLabel => 'Anteil anlegen';

  @override
  String get permCreateProfilesDesc => 'Einen neuen Anteil in Aurora aufnehmen';

  @override
  String get permDeactivateProfilesLabel => 'Anteil ausblenden';

  @override
  String get permDeactivateProfilesDesc =>
      'Einen Anteil vorübergehend verbergen – später wieder sichtbar';

  @override
  String get permManagePermissionsLabel => 'Rechte verwalten';

  @override
  String get permManagePermissionsDesc =>
      'Bestimmen, was andere Anteile dürfen';

  @override
  String get permAccessSettingsLabel => 'App-Einstellungen';

  @override
  String get permAccessSettingsDesc => 'Aurora einrichten und anpassen';

  @override
  String get permViewChatLabel => 'Chat lesen';

  @override
  String get permViewChatDesc => 'Nachrichten im internen Chat ansehen';

  @override
  String get permSendChatMessageLabel => 'Alles senden dürfen';

  @override
  String get permSendChatMessageDesc =>
      'Sammelrecht für jede Art von Nachricht – ersetzt die Einzelrechte darunter';

  @override
  String get permSendTextMessageLabel => 'Text schreiben';

  @override
  String get permSendTextMessageDesc =>
      'Geschriebene Nachrichten in den Chat stellen';

  @override
  String get permSendDoodleLabel => 'Malen';

  @override
  String get permSendDoodleDesc => 'Zeichnungen und Gekritzeltes teilen';

  @override
  String get permSendVoiceMessageLabel => 'Sprechen';

  @override
  String get permSendVoiceMessageDesc =>
      'Etwas aufnehmen und die eigene Stimme schicken';

  @override
  String get permSendImageLabel => 'Bilder schicken';

  @override
  String get permSendImageDesc => 'Fotos aufnehmen oder aus der Galerie teilen';

  @override
  String get permSendVideoLabel => 'Videos schicken';

  @override
  String get permSendVideoDesc =>
      'Videos aufnehmen oder aus der Galerie teilen';

  @override
  String get permDeleteOwnMessagesLabel => 'Eigene Nachrichten löschen';

  @override
  String get permDeleteOwnMessagesDesc =>
      'Nur zurücknehmen, was man selbst geschrieben hat';

  @override
  String get permDeleteAllMessagesLabel => 'Nachrichten anderer löschen';

  @override
  String get permDeleteAllMessagesDesc =>
      'Auch Nachrichten anderer Anteile entfernen – das lässt sich nicht rückgängig machen';

  @override
  String get permViewCalendarLabel => 'Kalender ansehen';

  @override
  String get permViewCalendarDesc => 'Sehen, was ansteht';

  @override
  String get permCreateEventsLabel => 'Termin eintragen';

  @override
  String get permCreateEventsDesc => 'Neue Termine in den Kalender setzen';

  @override
  String get permEditOwnEventsLabel => 'Eigene Termine ändern';

  @override
  String get permEditOwnEventsDesc =>
      'Nur selbst eingetragene Termine bearbeiten';

  @override
  String get permEditAllEventsLabel => 'Alle Termine ändern';

  @override
  String get permEditAllEventsDesc => 'Auch Termine anderer Anteile bearbeiten';

  @override
  String get permDeleteOwnEventsLabel => 'Eigene Termine löschen';

  @override
  String get permDeleteOwnEventsDesc =>
      'Nur selbst eingetragene Termine entfernen';

  @override
  String get permDeleteAllEventsLabel => 'Alle Termine löschen';

  @override
  String get permDeleteAllEventsDesc =>
      'Auch Termine anderer Anteile entfernen – das lässt sich nicht rückgängig machen';

  @override
  String get permAttachEventMediaLabel => 'Termin-Anhänge';

  @override
  String get permAttachEventMediaDesc =>
      'Bilder und Notizen an einen Termin hängen';

  @override
  String get permCommentOnCalendarEventsLabel => 'Kommentieren';

  @override
  String get permCommentOnCalendarEventsDesc =>
      'Zu einem Termin etwas dazuschreiben';

  @override
  String get permViewMedicationLabel => 'Medikamente ansehen';

  @override
  String get permViewMedicationDesc => 'Sehen, was der Körper wann bekommt';

  @override
  String get permManageMedicationLabel => 'Medikamente verwalten';

  @override
  String get permManageMedicationDesc =>
      'Medikamente hinzufügen, ändern und entfernen';

  @override
  String get permLogMedicationLabel => 'Einnahme bestätigen';

  @override
  String get permLogMedicationDesc => 'Abhaken, was schon genommen wurde';

  @override
  String get permOverrideMedicationLogLabel => 'Einnahmen zurücksetzen';

  @override
  String get permOverrideMedicationLogDesc =>
      'Eine Bestätigung ändern, die ein anderer Anteil gesetzt hat';

  @override
  String get permCommentOnMedicationLabel => 'Kommentieren';

  @override
  String get permCommentOnMedicationDesc =>
      'Zu einem Medikament etwas dazuschreiben';

  @override
  String get permViewOwnDiaryLabel => 'Eigenes Tagebuch';

  @override
  String get permViewOwnDiaryDesc => 'Nur die eigenen Einträge lesen';

  @override
  String get permViewAllDiariesLabel => 'Alle Tagebücher';

  @override
  String get permViewAllDiariesDesc =>
      'Auch die Einträge anderer Anteile lesen';

  @override
  String get permWriteDiaryLabel => 'Tagebuch schreiben';

  @override
  String get permWriteDiaryDesc => 'Etwas ins Tagebuch schreiben';

  @override
  String get permViewContactsLabel => 'Kontakte ansehen';

  @override
  String get permViewContactsDesc => 'Sehen, wer zum Umfeld gehört';

  @override
  String get permManageContactsLabel => 'Kontakte verwalten';

  @override
  String get permManageContactsDesc =>
      'Menschen hinzufügen, ändern und entfernen';

  @override
  String get permCommentOnContactsLabel => 'Kommentieren';

  @override
  String get permCommentOnContactsDesc => 'Zu einer Person etwas dazuschreiben';

  @override
  String get permViewFinderLabel => 'Finder ansehen';

  @override
  String get permViewFinderDesc => 'Nachsehen, wo etwas liegt oder wo man war';

  @override
  String get permManageFinderLabel => 'Finder verwalten';

  @override
  String get permManageFinderDesc =>
      'Orte und Gegenstände eintragen, ändern und entfernen';

  @override
  String get permCommentOnFinderEntriesLabel => 'Kommentieren';

  @override
  String get permCommentOnFinderEntriesDesc =>
      'Zu einem Ort oder Gegenstand etwas dazuschreiben';

  @override
  String get permCreateDiaryEntryLabel => 'Eintrag schreiben';

  @override
  String get permCreateDiaryEntryDesc => 'Einen neuen Tagebuch-Eintrag anlegen';

  @override
  String get permEditOwnDiaryEntriesLabel => 'Eigene Einträge ändern';

  @override
  String get permEditOwnDiaryEntriesDesc =>
      'Nur selbst geschriebene Einträge bearbeiten';

  @override
  String get permEditAllDiaryEntriesLabel => 'Alle Einträge ändern';

  @override
  String get permEditAllDiaryEntriesDesc =>
      'Auch Einträge anderer Anteile bearbeiten';

  @override
  String get permDeleteOwnDiaryEntriesLabel => 'Eigene Einträge löschen';

  @override
  String get permDeleteOwnDiaryEntriesDesc =>
      'Nur selbst geschriebene Einträge entfernen';

  @override
  String get permDeleteAllDiaryEntriesLabel => 'Alle Einträge löschen';

  @override
  String get permDeleteAllDiaryEntriesDesc =>
      'Auch Einträge anderer Anteile entfernen – das lässt sich nicht rückgängig machen';

  @override
  String get permCommentOnDiaryEntriesLabel => 'Kommentieren';

  @override
  String get permCommentOnDiaryEntriesDesc =>
      'Zu einem Eintrag etwas dazuschreiben';

  @override
  String get permViewSharedEntriesLabel => 'Geteilte Einträge';

  @override
  String get permViewSharedEntriesDesc =>
      'Einträge lesen, die für mehrere Anteile freigegeben sind';

  @override
  String get permViewEmergencyContactsLabel => 'Notfallkontakte ansehen';

  @override
  String get permViewEmergencyContactsDesc =>
      'Sehen, wer im Notfall erreichbar ist';

  @override
  String get permCallEmergencyContactsLabel => 'Anrufen';

  @override
  String get permCallEmergencyContactsDesc =>
      'Im Notfall direkt jemanden anrufen';

  @override
  String get permEditEmergencyContactsLabel => 'Notfallkontakte bearbeiten';

  @override
  String get permEditEmergencyContactsDesc =>
      'Notfallkontakte hinzufügen, ändern und entfernen';

  @override
  String get permResetPasswordsLabel => 'Passwörter zurücksetzen';

  @override
  String get permResetPasswordsDesc =>
      'Das Passwort eines anderen Anteils neu setzen';

  @override
  String get permChangeOwnPasswordLabel => 'Eigenes Passwort ändern';

  @override
  String get permChangeOwnPasswordDesc => 'Nur das eigene Passwort neu setzen';

  @override
  String get permEnableBiometricsLabel => 'Biometrie aktivieren';

  @override
  String get permEnableBiometricsDesc =>
      'Mit Fingerabdruck oder Gesicht anmelden';

  @override
  String get permViewChatTabLabel => 'Chat-Bereich';

  @override
  String get permViewChatTabDesc => 'Den Chat überhaupt sehen';

  @override
  String get permViewFeedbackTabLabel => 'Feedback-Bereich';

  @override
  String get permViewFeedbackTabDesc => 'Der Entwicklung schreiben';

  @override
  String get permViewCalendarTabLabel => 'Kalender-Bereich';

  @override
  String get permViewCalendarTabDesc => 'Den Kalender überhaupt sehen';

  @override
  String get permViewMedicationTabLabel => 'Medikamente-Bereich';

  @override
  String get permViewMedicationTabDesc =>
      'Den Medikamentenplan überhaupt sehen';

  @override
  String get permViewDiaryTabLabel => 'Tagebuch-Bereich';

  @override
  String get permViewDiaryTabDesc => 'Das Tagebuch überhaupt sehen';

  @override
  String get permViewContactsTabLabel => 'Kontakte-Bereich';

  @override
  String get permViewContactsTabDesc => 'Die Kontakte überhaupt sehen';

  @override
  String get permViewFinderTabLabel => 'Finder-Bereich';

  @override
  String get permViewFinderTabDesc => 'Den Finder überhaupt sehen';

  @override
  String get permViewEmergencyTabLabel => 'Notfall-Bereich';

  @override
  String get permViewEmergencyTabDesc => 'Die Notfallhilfe überhaupt sehen';

  @override
  String get permViewHelpTabLabel => 'Hilfe-Bereich';

  @override
  String get permViewHelpTabDesc => 'Hilfe und Anlaufstellen überhaupt sehen';

  @override
  String get permViewMantrasTabLabel => 'Mantras-Bereich';

  @override
  String get permViewMantrasTabDesc => 'Die Mantras überhaupt sehen';

  @override
  String get permViewGamesTabLabel => 'Spiele-Bereich';

  @override
  String get permViewGamesTabDesc => 'Die Spiele überhaupt sehen';

  @override
  String get permViewTimelineTabLabel => 'Zeitachse-Bereich';

  @override
  String get permViewTimelineTabDesc =>
      'Sehen, wann welcher Anteil da war – und an welchem Ort';

  @override
  String permissionYouNeed(String permission) {
    return 'Du brauchst: $permission';
  }

  @override
  String get fact01 =>
      'DIS (Dissoziative Identitätsstörung) betrifft etwa 1-2% der Bevölkerung.';

  @override
  String get fact02 =>
      'Jede Person in einem System kann eigene Vorlieben, Fähigkeiten und Erinnerungen haben.';

  @override
  String get fact03 =>
      'Innere Kommunikation ist ein wichtiger Schritt zur Stabilität und Heilung.';

  @override
  String get fact04 =>
      'Dissoziation ist eine natürliche Schutzreaktion der Psyche.';

  @override
  String get fact05 =>
      'Viele Menschen mit DIS sind hochfunktional und führen erfolgreiche Leben.';

  @override
  String get fact06 =>
      'Aurora wurde speziell für die Kommunikation zwischen Innenpersonen entwickelt.';

  @override
  String get fact07 =>
      'Der Chat-Bereich ermöglicht sichere interne Kommunikation ohne externe Apps.';

  @override
  String get fact08 =>
      'Jedes Profil kann individuelle Berechtigungen haben - vom Vollzugriff bis zu eingeschränkten Rechten.';

  @override
  String get fact09 =>
      'Das erste Profil wird automatisch zum Admin mit allen Berechtigungen.';

  @override
  String get fact10 =>
      'Der Kalender hilft dabei, wichtige Termine für alle Innenpersonen sichtbar zu machen.';

  @override
  String get fact11 =>
      'Im Medikamenten-Bereich kannst du regelmäßige und Bedarfsmedikamente verwalten.';

  @override
  String get fact12 =>
      'Der Finder hilft dabei, verlorene Gegenstände zu dokumentieren und wiederzufinden.';

  @override
  String get fact13 =>
      'Das Notfall-Tagebuch dokumentiert kritische Situationen für Therapeuten.';

  @override
  String get fact14 =>
      'Mantras können bei Dissoziation oder Stress helfen zu erden.';

  @override
  String get fact15 =>
      'Im Kontakte-Bereich kannst du wichtige Personen bewerten und kommentieren.';

  @override
  String get fact16 => 'Du kannst für jedes Profil eine eigene Farbe wählen.';

  @override
  String get fact17 =>
      'Sprachnachrichten ermöglichen Kommunikation auch wenn Schreiben schwerfällt.';

  @override
  String get fact18 => 'Doodles im Chat helfen, Gefühle visuell auszudrücken.';

  @override
  String get fact19 =>
      'Deine Einträge bleiben auf deinem Gerät. Gesendet wird nur, was du selbst ins Feedback schreibst.';

  @override
  String get fact20 =>
      'Regelmäßige Check-ins mit allen Innenpersonen fördern die Zusammenarbeit.';

  @override
  String get fact21 =>
      'Ein gemeinsamer Kalender verhindert Doppelbuchungen und Stress.';

  @override
  String get fact22 =>
      'Notizen im Notfall-Tagebuch können bei der Therapie sehr hilfreich sein.';

  @override
  String get fact23 =>
      'Jede Innenperson darf eigene Bedürfnisse haben - das ist völlig normal.';

  @override
  String get fact24 =>
      'Erdungsübungen können helfen, im Hier und Jetzt zu bleiben.';

  @override
  String get fact25 =>
      'Routinen geben Sicherheit und Struktur für alle im System.';

  @override
  String get fact26 => 'Pausen sind wichtig - auch für Innenpersonen.';

  @override
  String get fact27 =>
      'Du kannst Profile jederzeit deaktivieren und später reaktivieren.';

  @override
  String get fact28 => 'Der Admin kann Berechtigungen jederzeit anpassen.';

  @override
  String get fact29 =>
      'Bedarfsmedikamente können spontan protokolliert werden.';

  @override
  String get fact30 =>
      'Im Chat kannst du gezielt bestimmte Personen ansprechen.';

  @override
  String get fact31 =>
      'Aurora verwendet starke Verschlüsselung für sensible Daten.';

  @override
  String get fact32 => 'Passwörter werden niemals im Klartext gespeichert.';

  @override
  String get fact33 =>
      'Der Passwort-Reset braucht 24 Stunden als Sicherheitsmaßnahme.';

  @override
  String get fact34 =>
      'Alle Chat-Nachrichten bleiben privat und lokal gespeichert.';

  @override
  String get fact35 =>
      'Jeder Schritt zur besseren Kommunikation ist ein Erfolg.';

  @override
  String get fact36 =>
      'Es ist okay, unterschiedliche Meinungen im System zu haben.';

  @override
  String get fact37 => 'Zusammenarbeit macht stark - auch intern.';

  @override
  String get fact38 =>
      'Du bist nicht allein - viele Menschen leben erfolgreich mit DIS.';

  @override
  String get sliderChat0 => '👁️ Chat lesen und malen';

  @override
  String get sliderChat1 =>
      '✅ Alles im Chat: Text, Zeichnungen, Sprache, Bilder, Videos';

  @override
  String get sliderCalendar0 => '❌ Kein Zugriff auf den Kalender';

  @override
  String get sliderCalendar1 => '👁️ Termine ansehen';

  @override
  String get sliderCalendar2 => '📅 Eigene Termine anlegen und ändern';

  @override
  String get sliderCalendar3 =>
      '✅ Alle Termine verwalten und Anhänge hinzufügen';

  @override
  String get sliderMedication0 => '❌ Kein Zugriff auf Medikamente';

  @override
  String get sliderMedication1 => '👁️ Medikamentenliste ansehen';

  @override
  String get sliderMedication2 => '✅ Einnahmen bestätigen';

  @override
  String get sliderDiary0 => '❌ Kein Zugriff auf das Tagebuch';

  @override
  String get sliderDiary1 => '👁️ Nur das eigene Tagebuch lesen';

  @override
  String get sliderDiary2 => '📝 Ins eigene Tagebuch schreiben';

  @override
  String get sliderDiary3 => '✅ Alle Tagebücher lesen und schreiben';

  @override
  String get sliderContacts0 => '❌ Kein Zugriff auf Kontakte';

  @override
  String get sliderContacts1 => '👁️ Kontakte ansehen';

  @override
  String get sliderContacts2 => '💬 Kontakte ansehen und kommentieren';

  @override
  String get sliderContacts3 =>
      '✅ Kontakte verwalten: anlegen, ändern, löschen';

  @override
  String get sliderFinder0 => '❌ Kein Zugriff auf den Finder';

  @override
  String get sliderFinder1 => '👁️ Einträge ansehen';

  @override
  String get sliderFinder2 => '✅ Einträge verwalten';

  @override
  String get sliderEmergencyDiary0 => '❌ Kein Zugriff auf das Notfall-Tagebuch';

  @override
  String get sliderEmergencyDiary1 => '👁️ Einträge ansehen';

  @override
  String get sliderEmergencyDiary2 =>
      '💬 Einträge anlegen und kommentieren, eigene ändern';

  @override
  String get sliderEmergencyDiary3 => '✅ Alle Einträge verwalten';

  @override
  String get sliderEmergency0 => '❌ Kein Zugriff auf Notfallkontakte';

  @override
  String get sliderEmergency1 => '👁️ Notfallkontakte ansehen';

  @override
  String get sliderEmergency2 => '📞 Notfallkontakte ansehen und anrufen';

  @override
  String get sliderEmergency3 => '✅ Notfallkontakte verwalten';

  @override
  String get sliderHelp0 => '❌ Kein Zugriff auf Hilfe';

  @override
  String get sliderHelp1 => '✅ Hilfe und Anlaufstellen ansehen';

  @override
  String get sliderMantras0 => '❌ Kein Zugriff auf Mantras';

  @override
  String get sliderMantras1 => '✅ Mantras nutzen';

  @override
  String get sliderGames0 => '❌ Kein Zugriff auf Spiele';

  @override
  String get sliderGames1 => '✅ Spiele spielen';

  @override
  String get settingsDeleteAll => 'Alles löschen';

  @override
  String get settingsCacheClearHint =>
      'Die Karten werden beim nächsten Aufruf neu geladen. Das kann Speicherplatz freigeben.';

  @override
  String get settingsGpsWhileInUse => 'Bei Nutzung erlaubt ✓';

  @override
  String get settingsGpsNotAllowed => 'Nicht erlaubt';

  @override
  String settingsGpsStatusLine(String status) {
    return '⚠️ $status';
  }

  @override
  String get settingsGpsBackgroundRuns => 'GPS läuft dauerhaft im Hintergrund';

  @override
  String get settingsGpsOverridesAll =>
      'Überschreibt die Tracking-Einstellung ALLER Profile';

  @override
  String get settingsStepTapPermission => 'Tippe auf „Berechtigungen\"';

  @override
  String get settingsStepTapLocation => 'Tippe auf „Standort\"';

  @override
  String get settingsStepChooseAlways => 'Wähle „Immer erlauben\"';

  @override
  String get settingsStepOpenSettings =>
      'Tippe unten auf „Android-Einstellungen öffnen\"';

  @override
  String get settingsStepPermissionLocation =>
      'Wähle „Berechtigungen\" → „Standort\"';

  @override
  String get settingsPositionAlways => 'Die Position wird dauerhaft erfasst';

  @override
  String get settingsOverridesProfiles =>
      'Überschreibt die Einstellung jedes einzelnen Profils';

  @override
  String get settingsAllProfilesTracked =>
      'Alle Profile werden automatisch aufgezeichnet';

  @override
  String get settingsOpenGpsSettings => 'GPS-Einstellungen öffnen';

  @override
  String get settingsGpsRunsForAll => 'GPS läuft dauerhaft für alle Profile';

  @override
  String get settingsNotifAsNeeded =>
      'Bedarfsmedizin: Aurora meldet sich, sobald die nächste Dosis erlaubt ist — 30, 10 und 5 Minuten vorher';

  @override
  String get settingsNotifWorksClosed =>
      'Funktioniert auch, wenn die App geschlossen ist';

  @override
  String get aboutTitle => 'Über Aurora';

  @override
  String get aboutChat =>
      'Miteinander sprechen – mit Text, Bildern, Videos und Sprachnachrichten';

  @override
  String get aboutCalendar =>
      'Gemeinsame Termine mit Erinnerungen und Anhängen';

  @override
  String get aboutMedication => 'Medikamentenpläne mit Einnahmeprotokoll';

  @override
  String get aboutEmergencyDiary =>
      'Geteiltes Logbuch für Krisen und wichtige Ereignisse';

  @override
  String get aboutContacts =>
      'Eigene Bewertungen und Notizen zu Menschen im Umfeld';

  @override
  String get aboutFinder => 'Orte und Gegenstände wiederfinden';

  @override
  String get aboutLocalOnly =>
      'Alle Daten bleiben auf deinem Gerät – keine Cloud';

  @override
  String get telemetryQuestion => 'Hilfst du mit, Aurora zu verbessern?';

  @override
  String get telemetryExplanation =>
      'Aurora kann zählen, welche Bereiche geöffnet werden und wo Abläufe abbrechen. Gesendet wird nur der Name des Ereignisses, der Tag und die App-Version — kein Text, kein Standort und nichts, was zu dir zurückführt. Die Meldung geht sofort raus; wann sie ankommt, ist also auch der Zeitpunkt, an dem du Aurora benutzt hast.';

  @override
  String get telemetryChangeLater =>
      'Du kannst das jederzeit in den Einstellungen unter „Was Aurora sendet\" ändern. Dort steht auch jede einzelne Meldung, die dein Gerät verlassen hat.';

  @override
  String get transparencyIntroFull =>
      'Hier siehst du jede Übertragung, die dein Gerät verlassen hat — vollständig und im Wortlaut.';

  @override
  String get transparencyIrreversibleFull =>
      'Was bereits gesendet wurde, kann nicht zurückgeholt werden. Es ist dir nicht zugeordnet — deshalb lässt es sich auch nicht finden und löschen.';

  @override
  String get transparencyWaitingForConnection => 'Wartet auf Verbindung';

  @override
  String get privacyTitle => 'Datenschutzerklärung';

  @override
  String get privacyAtAGlance => 'Datenschutz auf einen Blick';

  @override
  String get privacyWhatIsStored => 'Welche Daten werden gespeichert?';

  @override
  String get privacyTransmission => 'Datenübertragung';

  @override
  String get privacyDeletion => 'Daten löschen';

  @override
  String get privacyMinors => 'Schutz Minderjähriger';

  @override
  String get privacyChanges => 'Änderungen dieser Erklärung';

  @override
  String get privacyClosing => 'Aurora – deine Daten bleiben bei dir.';

  @override
  String get mediaImageNotOpened => 'Das Bild ließ sich nicht öffnen';

  @override
  String get mediaVideoNotOpened => 'Das Video ließ sich nicht öffnen';

  @override
  String get mediaFromGallery => 'Aus der Galerie';

  @override
  String get mediaPickImage => 'Bild auswählen';

  @override
  String get mediaPickVideo => 'Video auswählen';

  @override
  String get transportDirectToDevelopers => 'Direkt an die Entwickler';

  @override
  String get transportSendFailed =>
      'Senden fehlgeschlagen. Versuch es später noch einmal oder schick es per E-Mail.';

  @override
  String get transportRejected => 'Der Server hat die Nachricht abgelehnt.';

  @override
  String get transportUnreachable => 'Der Server ist gerade nicht erreichbar.';

  @override
  String get transparencyArrived => 'Angekommen';

  @override
  String transparencyNotSent(String reason) {
    return 'Nicht gesendet: $reason';
  }

  @override
  String get transparencyReasonUnknown => 'Grund unbekannt';

  @override
  String get transportTryLaterOrEmail =>
      'Versuch es später noch einmal oder schick es per E-Mail.';

  @override
  String get transportEmailInstead =>
      'Du kannst deine Rückmeldung stattdessen per E-Mail schicken.';

  @override
  String get crashDialogTitle => 'Aurora ist abgestürzt';

  @override
  String get errorDialogTitle => 'Aurora hat ein Problem bemerkt';

  @override
  String get errorHelpUsFix => 'Möchtest du uns helfen, das zu beheben?';

  @override
  String get errorSendingFailed => 'Beim Senden ist ein Fehler aufgetreten.';

  @override
  String get feedbackContactOptions => 'Wege zu uns';

  @override
  String get feedbackInvalidEmail => 'Ungültige E-Mail-Adresse';

  @override
  String get feedbackArrived =>
      'Danke für deine Rückmeldung! Sie ist angekommen.';

  @override
  String get feedbackQueued =>
      'Angenommen. Es geht raus, sobald du wieder online bist.';

  @override
  String get feedbackSendFailed =>
      'Senden fehlgeschlagen. Versuch es später noch einmal.';

  @override
  String get profilePickImage => 'Profilbild wählen';

  @override
  String get profilePasswordOptional =>
      'Schütze dein Profil mit einem Passwort (optional)';

  @override
  String get profilePasswordOptionalMin =>
      'Schütze dein Profil mit einem Passwort (optional, mindestens 4 Zeichen)';

  @override
  String get thankYouWeReceived =>
      'Wir haben deinen Bericht erhalten und melden uns bei Rückfragen per E-Mail.';

  @override
  String get thankYouWeCheck => 'Wir sehen uns deinen Bericht an';

  @override
  String get thankYouWeFix => 'Wir arbeiten an einer Lösung';

  @override
  String get thankYouYouGetMail =>
      'Du bekommst eine E-Mail, sobald die Lösung da ist';

  @override
  String get thankYouNextUpdate => 'Die Lösung kommt mit dem nächsten Update';

  @override
  String get mapGpsLoading => 'GPS lädt…';

  @override
  String get mapGpsPositionLoading => 'Position wird geladen…';

  @override
  String get mapAllowLocation =>
      'Erlaube den Zugriff auf den Standort, um deine Position auf der Karte zu sehen';

  @override
  String mapLastKnownPosition(String age) {
    return 'Auf der Karte steht deine letzte bekannte Position: $age.';
  }

  @override
  String get pwResetThenReplaced =>
      '✓ Erst dann wird das alte Passwort ersetzt';

  @override
  String get pwResetCanActivateNow =>
      'Dein neues Passwort kann jetzt aktiviert werden';

  @override
  String get pwResetRunningShort => 'Reset läuft…';

  @override
  String get moodVeryHappy => 'Sehr glücklich';

  @override
  String get moodHappy => 'Glücklich';

  @override
  String get moodAnxious => 'Ängstlich';

  @override
  String get moodAngry => 'Wütend';

  @override
  String get emergencyPositionUnavailable => 'Position nicht verfügbar';

  @override
  String get emergencyPositionNoPermission =>
      'Position nicht verfügbar (keine Berechtigung)';

  @override
  String get emergencyMessageSubject => 'Notfall-Nachricht von Aurora';

  @override
  String autoLogoutAfter(int minutes) {
    return 'Automatisch abmelden nach $minutes Minuten ohne Nutzung';
  }

  @override
  String get pwResetBannerReady => 'Passwort bereit zum Aktivieren';

  @override
  String get doodleHistory => 'Verlauf blättern';

  @override
  String get doodleDraw => 'Malen';

  @override
  String get doodleSendEmptyHint => 'Male zuerst — dann kannst du senden';

  @override
  String get anchorTelemetryNotice =>
      'Anonyme Zählung ist an — was Aurora sendet';

  @override
  String get timePhaseMorning => 'morgens';

  @override
  String get timePhaseMidday => 'mittags';

  @override
  String get timePhaseAfternoon => 'nachmittags';

  @override
  String get timePhaseEvening => 'abends';

  @override
  String get timePhaseNight => 'nachts';

  @override
  String get greetingMorning => 'Guten Morgen';

  @override
  String get greetingDay => 'Guten Tag';

  @override
  String get greetingEvening => 'Guten Abend';

  @override
  String get anchorSwitchProfile => 'Das bin ich nicht';

  @override
  String get greetingNight => 'Hallo';

  @override
  String get quickTimelineYou => '(Du)';

  @override
  String todayEvents(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Termine heute',
      one: '1 Termin heute',
    );
    return '$_temp0';
  }

  @override
  String todayMedications(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Medikamente heute',
      one: '1 Medikament heute',
    );
    return '$_temp0';
  }

  @override
  String workSurfaceActiveProfile(String name) {
    return '$name ist gerade hier';
  }

  @override
  String get doodleUndo => 'Zurücknehmen';

  @override
  String get doodleClear => 'Alles löschen';

  @override
  String get finderPersonName => 'Name der Person';

  @override
  String get finderPlaceTitle => 'Titel für diesen Ort';

  @override
  String get commonLoading => 'Lädt…';

  @override
  String get puzzleCategoryAnimals => 'Niedliche und beruhigende Tiere';

  @override
  String get puzzleCategoryWater => 'Meer und Wasser';

  @override
  String get puzzleCategoryFlowers => 'Bunte Blumen und Pflanzen';

  @override
  String get gpsTrackingOffTap => 'Aufzeichnung aus – tippen zum Einschalten';

  @override
  String get gpsTrackingOnTap => 'Aufzeichnung an – tippen zum Ausschalten';

  @override
  String get gpsNoPermissionHint =>
      'Ohne die Standort-Berechtigung kann Aurora die Aufzeichnung nicht starten. Du kannst sie in den Android-Einstellungen unter Apps → Aurora → Berechtigungen erteilen.';

  @override
  String get settingsCouldNotOpen =>
      'Die Einstellungen ließen sich nicht öffnen.';

  @override
  String get settingsOpenAppSettings => 'App-Einstellungen öffnen';

  @override
  String get gpsWaitingFirstUpdate => 'Warte auf die erste Position…';

  @override
  String get imagePickerOpenCamera => 'Kamera öffnen';

  @override
  String get imagePickerFromGallery => 'Aus der Galerie wählen';

  @override
  String get imagePickerAnimalAvatar => 'Tier-Avatar wählen';

  @override
  String get animalAvatarDog => 'Hund';

  @override
  String get animalAvatarCat => 'Katze';

  @override
  String get animalAvatarGiraffe => 'Giraffe';

  @override
  String get puzzleDragPieces => 'Zieh die Teile an die richtige Stelle';

  @override
  String get puzzleTapPieces => 'Verschieb die Teile durch Antippen';

  @override
  String get feedbackTabSend => 'Feedback senden';

  @override
  String get pwResetRunningFull =>
      'Du hast vor Kurzem ein neues Passwort festgelegt. Aus Sicherheitsgründen läuft jetzt ein 24-Stunden-Timer.\n\n✓ Dein ALTES Passwort bleibt weiterhin aktiv\n✓ Nach Ablauf kannst du das neue aktivieren\n✓ Erst dann wird das alte ersetzt';

  @override
  String get transportRejectedFull =>
      'Der Server hat die Nachricht abgelehnt. Schick sie stattdessen per E-Mail.';

  @override
  String get transportUnreachableFull =>
      'Der Server ist gerade nicht erreichbar. Versuch es später noch einmal oder schick es per E-Mail.';

  @override
  String transportFailedWithCode(String code) {
    return 'Senden fehlgeschlagen ($code). Du kannst deine Rückmeldung stattdessen per E-Mail schicken.';
  }

  @override
  String get transportNoMailApp =>
      'Es ließ sich keine E-Mail-App öffnen. Du kannst den Text kopieren und selbst senden.';

  @override
  String get emergencySmsSubject => 'Notfall-Nachricht von Aurora';

  @override
  String get pwResetBannerRunning => 'Passwort-Reset läuft';

  @override
  String get puzzleDragHint => 'Zieh die Teile an die richtige Stelle';

  @override
  String get puzzleTapHint => 'Verschieb die Teile durch Antippen';

  @override
  String get medicationConfirm => 'Bestätigen';

  @override
  String get medicationAddFirstAsNeeded =>
      'Füge dein erstes Bedarfsmedikament hinzu';

  @override
  String medicationTakenBy(String name) {
    return '✓ Genommen von $name';
  }

  @override
  String medicationRefusedBy(String name) {
    return '✗ Verweigert von $name';
  }

  @override
  String get imprintPerLaw => 'Angaben gemäß § 5 TMG';

  @override
  String get imprintResponsible => 'Verantwortlich für den Inhalt';

  @override
  String get timelineSkipped => 'übersprungen';

  @override
  String get timelineDueSoon => 'Bald fällig';

  @override
  String get medicationLater => 'später';

  @override
  String get debugLogHint =>
      'Dieser Bericht enthält technische Angaben über die App. Kopiere ihn mit dem Knopf oben rechts, um ihn bei Problemen mitzuschicken.';

  @override
  String get unsavedChangesTitle => 'Ungespeicherte Änderungen';

  @override
  String get hotlineForYoung => 'Für Kinder und Jugendliche';

  @override
  String get hotlineAnonymousFree => 'Kostenlos und anonym';

  @override
  String get hotlineHoursNumberAgainstSorrow => 'Mo–Sa 14–20 Uhr';

  @override
  String get hotlineInfoNotAcute => 'Informationen, keine Akuthilfe';

  @override
  String get hotlineHoursDepressionInfo =>
      'Mo, Di, Do 13–17 Uhr · Mi, Fr 8:30–12:30 Uhr';

  @override
  String get hotlineChatUnder25 => 'Beratung per Chat, für alle unter 25';

  @override
  String get helpEmergencyDangerTitle =>
      'Wenn unmittelbar jemand in Gefahr ist';

  @override
  String get helpEmergencyDangerBody =>
      'Der Notruf ist Tag und Nacht erreichbar, auch ohne Guthaben.';

  @override
  String get helpEmergencyCallEmergencyNumber => 'Notruf 112';

  @override
  String get helpTalkTitle => 'Wenn du reden oder Beratung brauchst';

  @override
  String get helpGroupRoundTheClock => 'Rund um die Uhr erreichbar';

  @override
  String get helpGroupLimitedHours => 'Zu bestimmten Zeiten erreichbar';

  @override
  String helpSourcesCheckedOn(String datum) {
    return 'Angaben geprüft am $datum';
  }

  @override
  String get cameraCouldNotOpen => 'Die Kamera ließ sich nicht öffnen';

  @override
  String get feedbackDeviceDiagnostics => '--- Gerätediagnose ---';

  @override
  String get eventNoReminder =>
      'Der Termin steht nur im Kalender. Aurora meldet sich nicht von selbst.';

  @override
  String get unsavedChangesMessage =>
      'Du hast Änderungen gemacht.\n\nMöchtest du sie speichern?';

  @override
  String get confirmSave => 'Speichern';

  @override
  String get videoCouldNotLoad => 'Das Video ließ sich nicht laden';

  @override
  String get finderDaily => 'täglich';

  @override
  String get mapNotAvailable => 'Karte nicht verfügbar';

  @override
  String get medicationAnotherDose =>
      'Möchtest du trotzdem eine weitere Dosis nehmen?';

  @override
  String get feedbackThankYouReceived =>
      'Wir haben deine Rückmeldung erhalten und melden uns bei Rückfragen per E-Mail.';

  @override
  String get positionAgeYesterday => 'von gestern';

  @override
  String get timePickerTitle => 'Zeit wählen';

  @override
  String get reminderPermissionMissingTitle =>
      'Aurora darf gerade nicht erinnern';

  @override
  String reminderPermissionMissingBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Für $count Einnahmezeiten sind Erinnerungen eingeschaltet. Ohne die Erlaubnis des Geräts kommt keine davon an.',
      one:
          'Für eine Einnahmezeit sind Erinnerungen eingeschaltet. Ohne die Erlaubnis des Geräts kommt sie nicht an.',
    );
    return '$_temp0';
  }

  @override
  String get reminderPermissionMissingAction => 'Erlaubnis geben';

  @override
  String get timePickerHours => 'Stunden';

  @override
  String get timePickerMinutes => 'Minuten';

  @override
  String get commentsNoneYet => 'Noch keine Kommentare';

  @override
  String get notificationDiscreetBody => 'Erinnerung — tippen zum Ansehen';

  @override
  String get reminderNoPermission =>
      'Ohne die Erlaubnis für Benachrichtigungen kann Aurora nicht erinnern. Du kannst sie in den Android-Einstellungen unter Apps → Aurora → Benachrichtigungen erteilen.';

  @override
  String get telemetryConsentAccept => 'Ja, gerne';

  @override
  String get telemetryConsentDecline => 'Weiter ohne';

  @override
  String get transparencyGroupTelemetry => 'Telemetrie';

  @override
  String get telemetryExampleIntro => 'So sieht eine Meldung aus:';

  @override
  String get telemetryExampleEvent => 'Ereignis';

  @override
  String get telemetryExampleDay => 'Tag';

  @override
  String get telemetryExampleVersion => 'App-Version';

  @override
  String get onboardingDismiss => 'Nicht mehr anzeigen';

  @override
  String get eventStart => 'Beginn';

  @override
  String get eventEnd => 'Ende';

  @override
  String get chatCapturePhoto => 'Bild aufnehmen';

  @override
  String get chatCaptureImageShort => 'Bild';

  @override
  String get doodleErase => 'Radieren';

  @override
  String get chatRecordVideo => 'Video aufnehmen';

  @override
  String get chatRecordVideoSubtitle => 'Neues Video erstellen';

  @override
  String get actionDiscard => 'Verwerfen';

  @override
  String get actionKeep => 'Behalten';

  @override
  String get actionDetails => 'Details';

  @override
  String get resetWaitingPeriodTitle => 'Wartefrist beim Zurücksetzen';

  @override
  String get fieldNameHint => 'z.B. Max, Anna, Leo';

  @override
  String get fieldPasswordHint => 'Mind. 4 Zeichen';

  @override
  String get fieldPasswordConfirmHint => 'Passwort wiederholen';

  @override
  String get fieldPasswordEnterHint => 'Passwort eingeben';

  @override
  String get feedbackCommunityJoin => 'Tritt unserer Community bei';

  @override
  String get feedbackDiscord => 'Discord Server';

  @override
  String get feedbackGithub => 'GitHub';

  @override
  String get feedbackGithubSubtitle => 'Bug Reports & Issues';

  @override
  String get timelineProfileSwitch => 'Profil-Wechsel';

  @override
  String get debugLogReportTitle => 'Debug-Log Report';

  @override
  String get formPickImage => 'Bild wählen';

  @override
  String get permissionGrant => 'Berechtigung erteilen';

  @override
  String get pwResetRestart => 'Erneut starten';

  @override
  String get navBackToAnchor => 'Zum Anker';

  @override
  String get mapGpsPositionLoadingHint => 'Einen Moment bitte';

  @override
  String get voiceRecordingStartFailed => 'Sprachaufnahme konnte nicht starten';

  @override
  String get voiceRecordingStopFailed =>
      'Sprachaufnahme konnte nicht beendet werden';

  @override
  String get voiceRecordingDiscardFailed =>
      'Sprachaufnahme konnte nicht verworfen werden';

  @override
  String get trackingPermissionDeniedHint =>
      'GPS-Berechtigung verweigert. Aktiviere sie in den Einstellungen.';

  @override
  String get pwResetVisibleToAll => 'Die Frist läuft sichtbar für alle';

  @override
  String get pwResetRestartResetsTimer =>
      'Tipp: Erneuter Start setzt die Frist zurück';

  @override
  String get pwResetActivatedAtNextLogin =>
      'Das neue Passwort wird beim nächsten Login aktiviert';

  @override
  String get imagePickerCameraDeniedForever =>
      'Die Kamera-Berechtigung wurde dauerhaft verweigert. Aktiviere sie in den Einstellungen.';

  @override
  String get imagePickerGalleryDeniedForever =>
      'Die Galerie-Berechtigung wurde dauerhaft verweigert. Aktiviere sie in den Einstellungen.';

  @override
  String get permissionCameraTitle => 'Kamera-Berechtigung';

  @override
  String get permissionGalleryTitle => 'Galerie-Berechtigung';

  @override
  String get profileResetFristExplanation =>
      'So lange wartet ein Zurücksetzen deines Passworts, bevor es greift. Melde dich in dieser Zeit an, bricht es ab.';

  @override
  String get cameraNotFound => 'Keine Kamera gefunden';

  @override
  String get validationNameRequired => 'Bitte Name eingeben';

  @override
  String get validationPasswordRequired => 'Bitte Passwort eingeben';

  @override
  String get transportCopyManually =>
      'Du kannst den Text kopieren und manuell senden.';

  @override
  String get statusSending => 'Wird gesendet...';

  @override
  String get errorReportSendButton => 'Report senden';

  @override
  String get settingsGpsStatusAlwaysReady => '✅ Immer erlaubt (Bereit!)';

  @override
  String get gpsActive => 'GPS aktiv';

  @override
  String get gpsOff => 'GPS aus';

  @override
  String get gpsStatusUnknown => 'GPS Status unbekannt';

  @override
  String get gpsPermissionMissing => 'GPS-Berechtigung fehlt';

  @override
  String get gpsServiceDisabled => 'GPS-Service deaktiviert';

  @override
  String get permissionMissingShort => 'Berechtigung fehlt';

  @override
  String get pwResetWrongPassword => 'Falsches Passwort';

  @override
  String get pwResetStartTitle => 'Passwort-Reset starten?';

  @override
  String get pwResetExpired => 'Frist ist abgelaufen';

  @override
  String get pwResetForgotPassword => 'Passwort vergessen?';

  @override
  String get commentWritePlaceholder => 'Kommentar schreiben...';

  @override
  String get profileVisibilityTitle => 'Zuordnung zu Profilen';

  @override
  String get addressUnknown => 'Unbekannte Adresse';

  @override
  String get activateNow => 'Jetzt aktivieren';

  @override
  String get eventRemindMe => 'Erinnerung';

  @override
  String get noProfileAvailable => 'Kein Profil vorhanden';

  @override
  String get ratingVeryNegative => 'Sehr negativ';

  @override
  String get ratingVeryPositive => 'Sehr positiv';

  @override
  String get errorReportHelpUs => 'Hilf uns, den Fehler zu beheben!';

  @override
  String get errorReportDetailsSection => 'Report Details';

  @override
  String get trackingLabel => 'GPS-Tracking: ';

  @override
  String trackingLastUpdate(Object time) {
    return 'Letztes Update: $time';
  }

  @override
  String profileSwitchError(Object error) {
    return 'Fehler beim Profilwechsel: $error';
  }

  @override
  String get gpsError => 'GPS-Fehler';

  @override
  String get statusActive => 'Aktiv';

  @override
  String get statusPaused => 'Pausiert';

  @override
  String timeSecondsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Sekunden',
      one: 'vor einer Sekunde',
    );
    return '$_temp0';
  }

  @override
  String timeInMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count Minuten',
      one: 'in einer Minute',
    );
    return '$_temp0';
  }

  @override
  String timeInHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count Stunden',
      one: 'in einer Stunde',
    );
    return '$_temp0';
  }

  @override
  String timeInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count Tagen',
      one: 'in einem Tag',
    );
    return '$_temp0';
  }

  @override
  String get languageFollowApp => 'Sprache der App';

  @override
  String get profileLanguageSubtitle =>
      'Die Sprache, in der Aurora mit diesem Anteil spricht';

  @override
  String get contactCategoryFamily => 'Familie';

  @override
  String get contactCategoryFriends => 'Freunde';

  @override
  String get contactCategoryTherapists => 'Therapeuten';

  @override
  String get contactCategoryDoctors => 'Ärzte';

  @override
  String get contactCategoryEmergency => 'Notfall';

  @override
  String get contactCategoryOther => 'Sonstiges';

  @override
  String get finderTypeLocation => 'Ort';

  @override
  String get finderTypeItem => 'Gegenstand';

  @override
  String get diaryPriorityLow => 'Niedrig';

  @override
  String get diaryPriorityMedium => 'Mittel';

  @override
  String get diaryPriorityHigh => 'Hoch';

  @override
  String get diaryPriorityCritical => 'Kritisch';

  @override
  String get moodNeutral => 'Neutral';

  @override
  String get moodSad => 'Traurig';

  @override
  String get moodVerySad => 'Sehr traurig';

  @override
  String get moodExcited => 'Aufgeregt';

  @override
  String timeHoursMinutesAgo(Object hours, Object minutes) {
    return 'vor $hours Std $minutes Min';
  }

  @override
  String presenceLastFront(Object when) {
    return 'zuletzt $when';
  }

  @override
  String get privacyGlanceBody =>
      'Aurora speichert alles auf deinem Gerät. Drei Dinge verlassen es — und nur, wenn du sie auslöst oder erlaubst: abgesendetes Feedback, Telemetrie nach deiner Zustimmung, und die Kartenanfragen an OpenStreetMap.\n\nWas wann gesendet wurde, steht wörtlich in den Einstellungen unter „Was Aurora sendet\". Nichts davon lässt sich auf dich zurückführen.';

  @override
  String get privacyStoredBody =>
      'Diese Daten liegen in der lokalen Datenbank auf deinem Gerät:\n\n• Anteile und Einstellungen\n• Nachrichten zwischen Anteilen\n• Termine im Kalender\n• Medikamentenpläne und Einnahmen\n• Tagebuch- und Notfalleinträge\n• Kontakte mit Bewertungen und Notizen\n• Orte und Gegenstände aus dem Finder\n• Standortverlauf und Anteilswechsel\n• Bilder, Videos und Sprachnachrichten\n\nNichts davon wird übertragen.';

  @override
  String get privacyTransmissionBody =>
      'Feedback — nur wenn du das Formular absendest. Es enthält deinen Text, die App-Version und das Gerätemodell. Keinen Namen, keine Kennung, keinen Ort.\n\nTelemetrie — nur nach deiner ausdrücklichen Zustimmung, die du jederzeit zurücknehmen kannst. Ein Ereignis trägt drei Felder: was geschehen ist, an welchem Tag, mit welcher App-Version. Keine Uhrzeit, keine Kennung.\n\nKarten — beim Anzeigen einer Karte und beim Auflösen einer Adresse gehen der gezeigte Ausschnitt und deine IP-Adresse an OpenStreetMap. Das ist die Bedingung dafür, dass es überhaupt eine Karte gibt.\n\nNie übertragen werden: Standortverlauf, Anteile, Nachrichten, Termine, Medikamente, Tagebuch und Kontakte.';

  @override
  String get privacyPermissions => 'Berechtigungen';

  @override
  String get privacyPermissionsBody =>
      '• Standort — für die Karte, den Standortverlauf und den Notfall-Schirm. Er bleibt auf dem Gerät.\n• Standort im Hintergrund — nur wenn du die durchgehende Aufzeichnung einschaltest. Ohne diesen Schalter wird sie nicht gebraucht.\n• Kamera und Mikrofon — für Fotos und Sprachnachrichten.\n• Speicher — zum Laden von Bildern und Videos aus der Galerie.\n• Benachrichtigungen und Wecker — für Erinnerungen an Medikamente und Termine.\n\nJede Berechtigung lässt sich in den Systemeinstellungen entziehen. Die App sagt dann, was ohne sie nicht geht.';

  @override
  String get privacySecurity => 'Datensicherheit';

  @override
  String get privacySecurityBody =>
      '• Alle Daten liegen lokal, es gibt keine Cloud-Synchronisation.\n• Anteile lassen sich mit einem Passwort schützen.\n• Es gibt keine Nutzerkonten und keine Anmeldung.\n\nFür Sicherungen bist du selbst zuständig. Geht das Gerät verloren oder kaputt, sind die Daten weg — das ist der Preis dafür, dass sie nirgendwo sonst liegen.';

  @override
  String get privacyDeletionBody =>
      '• Einzelne Einträge und Nachrichten kannst du löschen.\n• Anteile lassen sich deaktivieren oder löschen.\n• In den Einstellungen gibt es „Alle Daten löschen\".\n• Beim Deinstallieren der App verschwindet alles mit.\n\nGelöschtes lässt sich nicht wiederherstellen.';

  @override
  String get privacyRights => 'Deine Rechte';

  @override
  String get privacyRightsBody =>
      'Nach der DSGVO hast du Recht auf Auskunft, Berichtigung, Löschung, Einschränkung, Datenübertragbarkeit und Widerspruch. Weil alle Daten auf deinem Gerät liegen, übst du die meisten davon unmittelbar in der App aus.\n\nFür abgesendetes Feedback und für Telemetrie wende dich an die Adresse unten. Du hast außerdem das Recht, dich bei einer Datenschutz-Aufsichtsbehörde zu beschweren.';

  @override
  String get privacyMinorsBody =>
      'Aurora darf von Minderjährigen genutzt werden. Über sie werden keine anderen Daten erhoben als über alle anderen — also keine, außer den oben genannten drei Wegen.\n\nBei jüngeren Nutzerinnen und Nutzern ist es sinnvoll, wenn Erziehungsberechtigte die Einrichtung begleiten.';

  @override
  String get privacyChangesBody =>
      'Diese Erklärung kann sich mit Aktualisierungen der App ändern. Die jeweils geltende Fassung steht hier und trägt unten ihr Datum.';

  @override
  String get privacyContact => 'Verantwortlicher und Kontakt';

  @override
  String privacyAsOf(Object date) {
    return 'Stand: $date';
  }

  @override
  String get startupFailedTitle => 'Aurora konnte nicht starten';

  @override
  String get startupFailedBody =>
      'Etwas beim Hochfahren ist schiefgegangen. Du kannst es noch einmal versuchen. Hilft das nicht, lässt sich alles Gespeicherte löschen — danach startet Aurora leer.';

  @override
  String get startupRetry => 'Noch einmal versuchen';

  @override
  String get startupDeleteAll => 'Alle Daten löschen';

  @override
  String get startupDeleteIncomplete =>
      'Nicht alles konnte gelöscht werden. Ein Teil ist noch da.';

  @override
  String get reminderPermissionBlocked =>
      'Aurora darf noch nicht erinnern. Die Erlaubnis lässt sich in den Systemeinstellungen erteilen.';

  @override
  String get reminderOpenSettings => 'Einstellungen öffnen';

  @override
  String get settingsTrackingPermissionNeeded =>
      'Für die Wegaufzeichnung braucht Aurora Zugriff auf den Standort.';

  @override
  String get settingsHowToEnableLocation => 'So gibst du den Standort frei:';

  @override
  String get settingsStepChooseWhileUsing =>
      'Wähle „Bei Nutzung der App erlauben\"';

  @override
  String get settingsTrackingNotice =>
      'Solange Aurora aufzeichnet, steht eine Benachrichtigung in deiner Leiste. Verschwindet sie, wird nicht aufgezeichnet.';

  @override
  String get locationTrackingNotificationTitle =>
      'Aurora merkt sich deinen Weg';

  @override
  String get locationTrackingNotificationBody =>
      'Damit du später wiederfindest, wo du warst. Bleibt auf dem Gerät.';

  @override
  String profileContinueAs(String name) {
    return 'Weiter als $name';
  }

  @override
  String get profileContinueInProgress => 'Einen Moment …';

  @override
  String get trackingPausedTitle => 'Aufzeichnung pausiert';

  @override
  String get trackingPausedBody =>
      'Nach dem Neustart zeichnet Aurora deinen Weg erst wieder auf, wenn du sie einmal öffnest. Tippe hier.';

  @override
  String get aboutAuroraSemantics => 'Über Aurora';

  @override
  String get openTimelineSemantics => 'Zeitachse öffnen';

  @override
  String get timeMapSemantics => 'Zeitachse öffnen: Karte mit Zeit und Ort';
}
