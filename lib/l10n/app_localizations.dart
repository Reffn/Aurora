import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
  ];

  /// Application title
  ///
  /// In de, this message translates to:
  /// **'Aurora'**
  String get appTitle;

  /// Application subtitle/tagline
  ///
  /// In de, this message translates to:
  /// **'Deine sichere Begleiterin im Alltag mit DIS'**
  String get appSubtitle;

  /// Application description
  ///
  /// In de, this message translates to:
  /// **'Aurora unterstützt dich beim Organisieren deines Alltags und der Kommunikation innerhalb deines Systems.'**
  String get appDescription;

  /// Chat tab label
  ///
  /// In de, this message translates to:
  /// **'Chat'**
  String get tabChat;

  /// Feedback tab label
  ///
  /// In de, this message translates to:
  /// **'Feedback'**
  String get tabFeedback;

  /// Calendar tab label
  ///
  /// In de, this message translates to:
  /// **'Kalender'**
  String get tabCalendar;

  /// Medication tab label
  ///
  /// In de, this message translates to:
  /// **'Medikamente'**
  String get tabMedication;

  /// Diary tab label
  ///
  /// In de, this message translates to:
  /// **'Tagebuch'**
  String get tabDiary;

  /// Contacts tab label
  ///
  /// In de, this message translates to:
  /// **'Kontakte'**
  String get tabContacts;

  /// Finder tab label
  ///
  /// In de, this message translates to:
  /// **'Finder'**
  String get tabFinder;

  /// Emergency tab label
  ///
  /// In de, this message translates to:
  /// **'Notfall'**
  String get tabEmergency;

  /// Help tab label
  ///
  /// In de, this message translates to:
  /// **'Hilfe'**
  String get tabHelp;

  /// Mantras tab label
  ///
  /// In de, this message translates to:
  /// **'Mantras'**
  String get tabMantras;

  /// Games tab label
  ///
  /// In de, this message translates to:
  /// **'Spiele'**
  String get tabGames;

  /// Timeline tab label
  ///
  /// In de, this message translates to:
  /// **'Zeitachse'**
  String get tabTimeline;

  /// Save button label
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get actionSave;

  /// Cancel button label
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get actionCancel;

  /// Delete button label
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get actionDelete;

  /// Edit button label
  ///
  /// In de, this message translates to:
  /// **'Bearbeiten'**
  String get actionEdit;

  /// Close action button
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get actionClose;

  /// Continue/Next button label
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get actionContinue;

  /// Confirm action button
  ///
  /// In de, this message translates to:
  /// **'Bestätigen'**
  String get actionConfirm;

  /// Back button label
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get actionBack;

  /// Quit/Exit button label
  ///
  /// In de, this message translates to:
  /// **'Beenden'**
  String get actionQuit;

  /// Send button label
  ///
  /// In de, this message translates to:
  /// **'Senden'**
  String get actionSend;

  /// Share button label
  ///
  /// In de, this message translates to:
  /// **'Teilen'**
  String get actionShare;

  /// Done button label
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get actionDone;

  /// Settings/Logout text in AppBar profile button
  ///
  /// In de, this message translates to:
  /// **'Setting / Ausloggen'**
  String get mainSettingLogout;

  /// Exit app dialog title
  ///
  /// In de, this message translates to:
  /// **'App beenden?'**
  String get dialogExitTitle;

  /// Exit app dialog message
  ///
  /// In de, this message translates to:
  /// **'Möchtest du Aurora wirklich beenden?'**
  String get dialogExitMessage;

  /// Edit profile menu item
  ///
  /// In de, this message translates to:
  /// **'Profil bearbeiten'**
  String get menuProfileEdit;

  /// Settings menu item
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get menuSettings;

  /// Logout menu item
  ///
  /// In de, this message translates to:
  /// **'Ausloggen'**
  String get menuLogout;

  /// Header of the profile bottom sheet and label of the tap target that opens it
  ///
  /// In de, this message translates to:
  /// **'Profil und Einstellungen'**
  String get profileMenuTitle;

  /// Heading of the recent presence lines above the profile selection
  ///
  /// In de, this message translates to:
  /// **'Wer war da?'**
  String get presenceRecentTitle;

  /// Title of the sheet that picks where an event takes place
  ///
  /// In de, this message translates to:
  /// **'Wo findet der Termin statt?'**
  String get eventLocationTitle;

  /// Entry that opens the map to pick a free location
  ///
  /// In de, this message translates to:
  /// **'Anderer Ort'**
  String get eventLocationOther;

  /// Entry that clears the location of an event
  ///
  /// In de, this message translates to:
  /// **'Kein Ort'**
  String get eventLocationNone;

  /// Label of the location row in the event form
  ///
  /// In de, this message translates to:
  /// **'Ort'**
  String get eventLocationLabel;

  /// Fallback name for a location picked on the map
  ///
  /// In de, this message translates to:
  /// **'Ort auf der Karte'**
  String get eventLocationUnnamed;

  /// Notice at the bottom of the time map when location permission is missing
  ///
  /// In de, this message translates to:
  /// **'Aurora braucht den Standort für diese Karte. Er bleibt auf dem Gerät.'**
  String get mapLocationNeeded;

  /// Button in the location notice that asks for permission
  ///
  /// In de, this message translates to:
  /// **'Erlauben'**
  String get mapLocationAllow;

  /// Profile selection screen title
  ///
  /// In de, this message translates to:
  /// **'Wer ist gerade da?'**
  String get profileSelectionTitle;

  /// New profile button label
  ///
  /// In de, this message translates to:
  /// **'Neues Profil'**
  String get profileNewProfile;

  /// Profile creation screen title
  ///
  /// In de, this message translates to:
  /// **'Neues Profil erstellen'**
  String get profileCreationTitle;

  /// Profile creation screen subtitle
  ///
  /// In de, this message translates to:
  /// **'Wer möchte sich vorstellen?'**
  String get profileCreationSubtitle;

  /// Profile creation description text
  ///
  /// In de, this message translates to:
  /// **'Erstelle dein persönliches Profil mit Namen, Farbe und Avatar. Jedes Profil kann individuell angepasst werden und erhält passende Berechtigungen basierend auf dem Alter.'**
  String get profileCreationDescription;

  /// Profile edit screen title
  ///
  /// In de, this message translates to:
  /// **'Profil bearbeiten'**
  String get profileEditTitle;

  /// Profile edit screen subtitle
  ///
  /// In de, this message translates to:
  /// **'Passe deine Einstellungen an'**
  String get profileEditSubtitle;

  /// Identity section title in profile creation/edit
  ///
  /// In de, this message translates to:
  /// **'👤 Identität'**
  String get profileSectionIdentity;

  /// Age section title in profile creation/edit
  ///
  /// In de, this message translates to:
  /// **'🎂 Alter'**
  String get profileSectionAge;

  /// Color section title in profile creation/edit
  ///
  /// In de, this message translates to:
  /// **'🎨 Farbe'**
  String get profileSectionColor;

  /// Security questions section title
  ///
  /// In de, this message translates to:
  /// **'🔒 Sicherheitsfragen'**
  String get profileSectionSecurity;

  /// Who are you page title in profile creation
  ///
  /// In de, this message translates to:
  /// **'Wer bist du?'**
  String get profileWhoAreYou;

  /// Who are you page description
  ///
  /// In de, this message translates to:
  /// **'Gib deinen Namen ein und wähle einen Avatar. So können dich alle im System erkennen und unterscheiden. Du kannst auch ein Foto machen, aus der Galerie wählen oder eine der niedlichen Tier-Vorlagen verwenden.'**
  String get profileWhoAreYouDescription;

  /// Color selection page title
  ///
  /// In de, this message translates to:
  /// **'Deine einzigartige Farbe'**
  String get profileColorTitle;

  /// Color selection description
  ///
  /// In de, this message translates to:
  /// **'Deine Farbe macht dich unverwechselbar im System.'**
  String get profileColorDescription;

  /// Age selection page title
  ///
  /// In de, this message translates to:
  /// **'Wie alt bist du?'**
  String get profileAgeTitle;

  /// Age selection description
  ///
  /// In de, this message translates to:
  /// **'Das Alter bestimmt, welche Funktionen du nutzen kannst.'**
  String get profileAgeDescription;

  /// Security/password page title
  ///
  /// In de, this message translates to:
  /// **'Schütze dein Profil'**
  String get profileSecurityTitle;

  /// Security/password description
  ///
  /// In de, this message translates to:
  /// **'Optional kannst du ein Passwort setzen (mindestens 4 Zeichen).'**
  String get profileSecurityDescription;

  /// Password optional info text
  ///
  /// In de, this message translates to:
  /// **'Das Passwort ist optional. Lasse die Felder leer, wenn du keines setzen möchtest.'**
  String get profilePasswordOptionalInfo;

  /// Child mode label for young profiles
  ///
  /// In de, this message translates to:
  /// **'Kind-Modus'**
  String get profileModeChild;

  /// Full access mode label for older profiles
  ///
  /// In de, this message translates to:
  /// **'Vollzugriff'**
  String get profileModeFullAccess;

  /// Child mode features description
  ///
  /// In de, this message translates to:
  /// **'Zugriff auf: Chat (Kritzeln), Tagebuch, Spiele, Timeline'**
  String get profileModeChildDescription;

  /// Full access mode features description
  ///
  /// In de, this message translates to:
  /// **'Zugriff auf: Alle Funktionen (Chat, Kalender, Kontakte, Medikation, etc.)'**
  String get profileModeFullDescription;

  /// Save changes button in profile edit
  ///
  /// In de, this message translates to:
  /// **'Änderungen speichern'**
  String get profileActionSaveChanges;

  /// Create profile button label
  ///
  /// In de, this message translates to:
  /// **'Profil erstellen ✓'**
  String get profileActionCreateProfile;

  /// Deactivate profile dialog title
  ///
  /// In de, this message translates to:
  /// **'Profil deaktivieren?'**
  String get profileDeactivateTitle;

  /// Deactivate profile dialog message
  ///
  /// In de, this message translates to:
  /// **'Möchtest du das Profil \"{name}\" deaktivieren?\n\nEs wird ausgeblendet, kann aber später reaktiviert werden.'**
  String profileDeactivateMessage(String name);

  /// Profile deactivated success message
  ///
  /// In de, this message translates to:
  /// **'Profil deaktiviert'**
  String get profileDeactivated;

  /// Deactivate profile button label
  ///
  /// In de, this message translates to:
  /// **'Deaktivieren'**
  String get profileDeactivate;

  /// Profile edit coming soon message
  ///
  /// In de, this message translates to:
  /// **'Bearbeiten folgt bald'**
  String get profileEditComingSoon;

  /// Profile name already exists error message
  ///
  /// In de, this message translates to:
  /// **'Ein Profil mit diesem Namen existiert bereits'**
  String get profileNameExists;

  /// Name input field label
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// Password input field label
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get fieldPassword;

  /// Password confirmation input field label
  ///
  /// In de, this message translates to:
  /// **'Passwort bestätigen'**
  String get fieldPasswordConfirm;

  /// Age input field label
  ///
  /// In de, this message translates to:
  /// **'Alter'**
  String get fieldAge;

  /// Color input field label
  ///
  /// In de, this message translates to:
  /// **'Farbe'**
  String get fieldColor;

  /// Avatar input field label
  ///
  /// In de, this message translates to:
  /// **'Avatar'**
  String get fieldAvatar;

  /// Required field validation error
  ///
  /// In de, this message translates to:
  /// **'Pflichtfeld'**
  String get validationRequired;

  /// Password minimum length validation
  ///
  /// In de, this message translates to:
  /// **'Mindestens 4 Zeichen'**
  String get validationPasswordLength;

  /// Password mismatch validation error
  ///
  /// In de, this message translates to:
  /// **'Passwörter stimmen nicht überein'**
  String get validationPasswordMismatch;

  /// Generic error message
  ///
  /// In de, this message translates to:
  /// **'Fehler: {error}'**
  String errorGeneric(String error);

  /// No profile selected error
  ///
  /// In de, this message translates to:
  /// **'Kein Profil ausgewählt'**
  String get errorNoProfile;

  /// No permission to send chat messages
  ///
  /// In de, this message translates to:
  /// **'Du hast keine Berechtigung Chat-Nachrichten zu senden'**
  String get errorNoPermission;

  /// Chat screen title
  ///
  /// In de, this message translates to:
  /// **'Chat'**
  String get chatTitle;

  /// Empty chat state title
  ///
  /// In de, this message translates to:
  /// **'Noch keine Nachrichten'**
  String get chatEmptyTitle;

  /// Empty chat state subtitle
  ///
  /// In de, this message translates to:
  /// **'Teile deine Gedanken mit dem System'**
  String get chatEmptySubtitle;

  /// Placeholder text for doodle message
  ///
  /// In de, this message translates to:
  /// **'[Doodle]'**
  String get chatMessageDoodle;

  /// Placeholder text for voice message
  ///
  /// In de, this message translates to:
  /// **'[Sprachnachricht]'**
  String get chatMessageVoice;

  /// Placeholder text for image message
  ///
  /// In de, this message translates to:
  /// **'[Bild]'**
  String get chatMessageImage;

  /// Placeholder text for video message
  ///
  /// In de, this message translates to:
  /// **'[Video]'**
  String get chatMessageVideo;

  /// Error sending message
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Senden: {error}'**
  String chatErrorSending(String error);

  /// Error sending voice message
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Senden der Sprachnachricht: {error}'**
  String chatErrorSendingVoice(String error);

  /// Error sending image
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Senden des Bildes: {error}'**
  String chatErrorSendingImage(String error);

  /// Error sending video
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Senden des Videos: {error}'**
  String chatErrorSendingVideo(String error);

  /// Error sending doodle
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Senden: {error}'**
  String chatErrorSendingDoodle(String error);

  /// Recording in progress dialog title
  ///
  /// In de, this message translates to:
  /// **'Aufnahme läuft...'**
  String get chatRecordingInProgress;

  /// Recording hint text
  ///
  /// In de, this message translates to:
  /// **'Tippe auf Stop um die Sprachnachricht zu senden'**
  String get chatRecordingHint;

  /// Stop recording button
  ///
  /// In de, this message translates to:
  /// **'Stop'**
  String get chatRecordingStop;

  /// Microphone permission required error
  ///
  /// In de, this message translates to:
  /// **'Mikrofon-Berechtigung erforderlich'**
  String get chatErrorMicPermission;

  /// Could not start recording error
  ///
  /// In de, this message translates to:
  /// **'Aufnahme konnte nicht gestartet werden'**
  String get chatErrorRecordingStart;

  /// Chat input placeholder
  ///
  /// In de, this message translates to:
  /// **'Nachricht schreiben...'**
  String get chatInputHint;

  /// Bleibender Name des Chat-Eingabefelds für TalkBack. Der Platzhalter verschwindet beim Tippen, dieser Name nicht.
  ///
  /// In de, this message translates to:
  /// **'Nachricht'**
  String get chatMessageFieldLabel;

  /// Name des Plus-Knopfes neben dem Chat-Eingabefeld
  ///
  /// In de, this message translates to:
  /// **'Weitere Medien hinzufügen'**
  String get chatAddMedia;

  /// Name des Sende-Knopfes im Chat
  ///
  /// In de, this message translates to:
  /// **'Nachricht senden'**
  String get chatSendMessage;

  /// Überschrift des Medienblatts. Neutral, weil darunter auch die Kamera steht, nicht nur die Galerie.
  ///
  /// In de, this message translates to:
  /// **'Medien hinzufügen'**
  String get chatMediaSheetTitle;

  /// No permission to send hint
  ///
  /// In de, this message translates to:
  /// **'Keine Berechtigung zum Senden'**
  String get chatNoPermissionHint;

  /// Calendar screen title
  ///
  /// In de, this message translates to:
  /// **'Kalender'**
  String get calendarTitle;

  /// Medication screen title
  ///
  /// In de, this message translates to:
  /// **'Medikamente'**
  String get medicationTitle;

  /// New medication form title
  ///
  /// In de, this message translates to:
  /// **'Neues Medikament'**
  String get medicationNewTitle;

  /// Edit medication form title
  ///
  /// In de, this message translates to:
  /// **'Medikament bearbeiten'**
  String get medicationEditTitle;

  /// Medication detail screen title
  ///
  /// In de, this message translates to:
  /// **'Medikament Details'**
  String get medicationDetailTitle;

  /// Medication not found error title
  ///
  /// In de, this message translates to:
  /// **'Medikament nicht gefunden'**
  String get medicationNotFound;

  /// Medication not found error message
  ///
  /// In de, this message translates to:
  /// **'Dieses Medikament existiert nicht mehr'**
  String get medicationNotFoundMessage;

  /// Daily medication tab label
  ///
  /// In de, this message translates to:
  /// **'Tagesmedizin'**
  String get medicationTabDaily;

  /// As-needed medication tab label
  ///
  /// In de, this message translates to:
  /// **'Bedarfsmedizin'**
  String get medicationTabAsNeeded;

  /// Empty medication list title
  ///
  /// In de, this message translates to:
  /// **'Keine Medikamente 💊'**
  String get medicationEmptyTitle;

  /// Empty medication list subtitle
  ///
  /// In de, this message translates to:
  /// **'Füge dein erstes Medikament hinzu'**
  String get medicationEmptySubtitle;

  /// Empty as-needed medication title
  ///
  /// In de, this message translates to:
  /// **'Keine Bedarfsmedizin 🩹'**
  String get medicationEmptyAsNeededTitle;

  /// Empty as-needed medication subtitle
  ///
  /// In de, this message translates to:
  /// **'Füge dein erstes Bedarfsmedikament hinzu'**
  String get medicationEmptyAsNeededSubtitle;

  /// Today header in medication list
  ///
  /// In de, this message translates to:
  /// **'Heute'**
  String get medicationToday;

  /// Medications stat label
  ///
  /// In de, this message translates to:
  /// **'Medikamente'**
  String get medicationStatMedications;

  /// Doses stat label
  ///
  /// In de, this message translates to:
  /// **'Einnahmen'**
  String get medicationStatDoses;

  /// Medication marked as taken success message
  ///
  /// In de, this message translates to:
  /// **'{name} als genommen markiert'**
  String medicationMarkedTaken(String name);

  /// Medication marked as refused message
  ///
  /// In de, this message translates to:
  /// **'{name} als verweigert markiert'**
  String medicationMarkedRefused(String name);

  /// Refusal documentation dialog title
  ///
  /// In de, this message translates to:
  /// **'Verweigerung dokumentieren'**
  String get medicationRefusalDialogTitle;

  /// Refusal dialog message
  ///
  /// In de, this message translates to:
  /// **'{name} wird als verweigert markiert.'**
  String medicationRefusalDialogMessage(String name);

  /// Refusal reason input label
  ///
  /// In de, this message translates to:
  /// **'Grund (optional)'**
  String get medicationRefusalReasonLabel;

  /// Refusal reason input hint
  ///
  /// In de, this message translates to:
  /// **'z.B. Übelkeit, müde, etc.'**
  String get medicationRefusalReasonHint;

  /// Refusal without note button
  ///
  /// In de, this message translates to:
  /// **'Ohne Notiz'**
  String get medicationRefusalWithoutNote;

  /// Medication feedback dialog title
  ///
  /// In de, this message translates to:
  /// **'Feedback hinzufügen'**
  String get medicationFeedbackDialogTitle;

  /// Medication feedback question
  ///
  /// In de, this message translates to:
  /// **'Wie hast du dich nach der Einnahme von {name} gefühlt?'**
  String medicationFeedbackQuestion(String name);

  /// Feedback input label
  ///
  /// In de, this message translates to:
  /// **'Deine Erfahrung'**
  String get medicationFeedbackLabel;

  /// Feedback input hint
  ///
  /// In de, this message translates to:
  /// **'z.B. \"Fühlte mich müde\", \"Hat gut geholfen\", etc.'**
  String get medicationFeedbackHint;

  /// Feedback saved success message
  ///
  /// In de, this message translates to:
  /// **'Feedback gespeichert'**
  String get medicationFeedbackSaved;

  /// View feedback dialog title
  ///
  /// In de, this message translates to:
  /// **'Feedback'**
  String get medicationFeedbackViewTitle;

  /// Diary screen title
  ///
  /// In de, this message translates to:
  /// **'Tagebuch'**
  String get diaryTitle;

  /// Empty diary title
  ///
  /// In de, this message translates to:
  /// **'Dein Tagebuch wartet auf dich! ✨'**
  String get diaryEmptyTitle;

  /// Empty diary subtitle
  ///
  /// In de, this message translates to:
  /// **'Halte deine Gedanken, Erlebnisse und Momente fest'**
  String get diaryEmptySubtitle;

  /// Contacts screen title
  ///
  /// In de, this message translates to:
  /// **'Kontakte'**
  String get contactsTitle;

  /// All contacts filter label
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get contactsFilterAll;

  /// Empty contacts title
  ///
  /// In de, this message translates to:
  /// **'Noch keine Kontakte 👥'**
  String get contactsEmptyTitle;

  /// Empty contacts subtitle
  ///
  /// In de, this message translates to:
  /// **'Tippe auf + um einen Kontakt hinzuzufügen'**
  String get contactsEmptySubtitle;

  /// Empty filtered contacts title
  ///
  /// In de, this message translates to:
  /// **'Keine Kontakte gefunden 🔍'**
  String get contactsEmptyFilteredTitle;

  /// Empty filtered contacts subtitle
  ///
  /// In de, this message translates to:
  /// **'Versuche einen anderen Filter'**
  String get contactsEmptyFilteredSubtitle;

  /// Finder screen title
  ///
  /// In de, this message translates to:
  /// **'Finder'**
  String get finderTitle;

  /// Locations tab label in finder
  ///
  /// In de, this message translates to:
  /// **'Orte'**
  String get finderTabLocations;

  /// Items tab label in finder
  ///
  /// In de, this message translates to:
  /// **'Dinge'**
  String get finderTabItems;

  /// Empty locations title
  ///
  /// In de, this message translates to:
  /// **'Noch keine Orte'**
  String get finderEmptyLocationsTitle;

  /// Empty items title
  ///
  /// In de, this message translates to:
  /// **'Noch keine Gegenstände'**
  String get finderEmptyItemsTitle;

  /// Empty locations subtitle
  ///
  /// In de, this message translates to:
  /// **'Tippe auf +, um einen Ort hinzuzufügen'**
  String get finderEmptyLocationsSubtitle;

  /// Empty items subtitle
  ///
  /// In de, this message translates to:
  /// **'Tippe auf +, um einen Gegenstand hinzuzufügen'**
  String get finderEmptyItemsSubtitle;

  /// Emergency screen title
  ///
  /// In de, this message translates to:
  /// **'Notfall'**
  String get emergencyTitle;

  /// Empty emergency contacts title
  ///
  /// In de, this message translates to:
  /// **'Noch keine Notfallkontakte'**
  String get emergencyEmptyTitle;

  /// Empty emergency contacts subtitle
  ///
  /// In de, this message translates to:
  /// **'Füge Kontakte mit der Kategorie \"Notfall\" hinzu, um sie hier zu sehen.'**
  String get emergencyEmptySubtitle;

  /// Emergency contacts description
  ///
  /// In de, this message translates to:
  /// **'Diese Kontakte können im Notfall schnell benachrichtigt werden.'**
  String get emergencyEmptyDescription;

  /// Knopf im Notfall-Leerzustand, legt einen Kontakt an
  ///
  /// In de, this message translates to:
  /// **'Notfallkontakt anlegen'**
  String get emergencyEmptyAddContact;

  /// Knopf im Notfall-Leerzustand, oeffnet die 24/7-Anlaufstellen
  ///
  /// In de, this message translates to:
  /// **'Hilfe und Notrufnummern'**
  String get emergencyEmptyOpenHelp;

  /// Send emergency SMS to all button
  ///
  /// In de, this message translates to:
  /// **'NOTFALL-SMS an alle senden'**
  String get emergencySendSmsAll;

  /// Share emergency message to all button
  ///
  /// In de, this message translates to:
  /// **'Via App an alle senden'**
  String get emergencyShareAll;

  /// Emergency SMS confirmation dialog title
  ///
  /// In de, this message translates to:
  /// **'NOTFALL-SMS an alle senden?'**
  String get emergencySmsDialogTitle;

  /// Emergency SMS confirmation dialog message
  ///
  /// In de, this message translates to:
  /// **'Die Notfall-Nachricht wird an {count} Kontakte gesendet.'**
  String emergencySmsDialogMessage(int count);

  /// Send now button in emergency
  ///
  /// In de, this message translates to:
  /// **'Jetzt senden'**
  String get emergencySendNow;

  /// Emergency message preparing status
  ///
  /// In de, this message translates to:
  /// **'Notfall-Nachricht wird vorbereitet...'**
  String get emergencyMessagePreparing;

  /// SMS send error message
  ///
  /// In de, this message translates to:
  /// **'Fehler beim SMS-Versand: {error}'**
  String emergencyErrorSms(String error);

  /// Share error message
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Teilen: {error}'**
  String emergencyErrorShare(String error);

  /// Settings screen title
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settingsTitle;

  /// Debug options section title
  ///
  /// In de, this message translates to:
  /// **'🔧 Debug-Optionen'**
  String get settingsSectionDebug;

  /// Debug options info text
  ///
  /// In de, this message translates to:
  /// **'Diese Optionen sind nur während der Entwicklung sichtbar'**
  String get settingsDebugInfo;

  /// Skip password reset cooldown button
  ///
  /// In de, this message translates to:
  /// **'⏩ Cooldown auf 20s setzen'**
  String get settingsDebugSkipCooldown;

  /// Cooldown skip info text
  ///
  /// In de, this message translates to:
  /// **'Profil: {name}\nVerbleibend: {time}'**
  String settingsDebugSkipCooldownInfo(String name, String time);

  /// Cooldown set success message
  ///
  /// In de, this message translates to:
  /// **'⏩ Timer auf 20 Sekunden gesetzt!\nNach 20s kann das Passwort aktiviert werden.'**
  String get settingsDebugCooldownSet;

  /// Cooldown set error message
  ///
  /// In de, this message translates to:
  /// **'❌ Fehler beim Setzen des Timers'**
  String get settingsDebugCooldownError;

  /// Delete all data button
  ///
  /// In de, this message translates to:
  /// **'Alle Daten löschen'**
  String get settingsDeleteAllData;

  /// Delete all data subtitle
  ///
  /// In de, this message translates to:
  /// **'Löscht alle Profile, Nachrichten, Events und Anhänge'**
  String get settingsDeleteAllDataSubtitle;

  /// Delete confirmation dialog title
  ///
  /// In de, this message translates to:
  /// **'⚠️ Warnung'**
  String get settingsDeleteConfirmTitle;

  /// Delete all data confirmation message
  ///
  /// In de, this message translates to:
  /// **'Diese Aktion löscht ALLE Daten:\n\n• Alle Profile\n• Alle Chat-Nachrichten\n• Alle Kalender-Events\n• Alle Medikamente & Einnahme-Logs\n• Alle Kontakte\n• Alle Finder-Items\n• Alle Notfalltagebuch-Einträge\n• Alle Navigation-Daten\n• Alle Einstellungen\n• Alle Doodle-Anhänge\n\nDies kann NICHT rückgängig gemacht werden!'**
  String get settingsDeleteConfirmMessage;

  /// Delete all data success message
  ///
  /// In de, this message translates to:
  /// **'✅ Alle Daten wurden gelöscht'**
  String get settingsDeleteSuccess;

  /// Management section title
  ///
  /// In de, this message translates to:
  /// **'Verwaltung'**
  String get settingsSectionManagement;

  /// Permissions manager menu item
  ///
  /// In de, this message translates to:
  /// **'Rechte & Berechtigungen'**
  String get settingsPermissions;

  /// Permissions manager subtitle
  ///
  /// In de, this message translates to:
  /// **'Verwalte Zugriffsrechte der Profile'**
  String get settingsPermissionsSubtitle;

  /// Global settings section title
  ///
  /// In de, this message translates to:
  /// **'Globale Einstellungen'**
  String get settingsSectionGlobal;

  /// Global tracking info title
  ///
  /// In de, this message translates to:
  /// **'Was ist \"Tracking dauerhaft an\"?'**
  String get settingsGlobalTrackingInfo;

  /// Global tracking description
  ///
  /// In de, this message translates to:
  /// **'Als Admin kannst du das GPS-Tracking für ALLE Profile zentral steuern. Wenn aktiviert:'**
  String get settingsGlobalTrackingDescription;

  /// Global tracking feature 1
  ///
  /// In de, this message translates to:
  /// **'Position wird permanent erfasst'**
  String get settingsGlobalTrackingBullet1;

  /// Global tracking feature 2
  ///
  /// In de, this message translates to:
  /// **'Funktioniert auch im Hintergrund'**
  String get settingsGlobalTrackingBullet2;

  /// Global tracking feature 3
  ///
  /// In de, this message translates to:
  /// **'Überschreibt individuelle Profil-Einstellungen'**
  String get settingsGlobalTrackingBullet3;

  /// Global tracking feature 4
  ///
  /// In de, this message translates to:
  /// **'Alle Profile werden automatisch getrackt'**
  String get settingsGlobalTrackingBullet4;

  /// Global tracking permission requirement
  ///
  /// In de, this message translates to:
  /// **'Voraussetzung: Die Android-Berechtigung \"Immer erlauben\" muss aktiviert sein, damit Tracking auch bei geschlossener App funktioniert.'**
  String get settingsGlobalTrackingRequirement;

  /// GPS permission section title
  ///
  /// In de, this message translates to:
  /// **'GPS Berechtigung'**
  String get settingsGpsPermissionTitle;

  /// GPS service disabled status
  ///
  /// In de, this message translates to:
  /// **'GPS-Dienst deaktiviert'**
  String get settingsGpsStatusDisabled;

  /// GPS permission denied status
  ///
  /// In de, this message translates to:
  /// **'Berechtigung verweigert'**
  String get settingsGpsStatusDenied;

  /// GPS permission denied forever status
  ///
  /// In de, this message translates to:
  /// **'Dauerhaft verweigert'**
  String get settingsGpsStatusDeniedForever;

  /// GPS permission while in use status
  ///
  /// In de, this message translates to:
  /// **'Nur während der Nutzung'**
  String get settingsGpsStatusWhileInUse;

  /// GPS permission always allowed status
  ///
  /// In de, this message translates to:
  /// **'Immer erlaubt ✓'**
  String get settingsGpsStatusAlways;

  /// GPS permission unknown status
  ///
  /// In de, this message translates to:
  /// **'Unbekannt'**
  String get settingsGpsStatusUnknown;

  /// GPS ready for background tracking message
  ///
  /// In de, this message translates to:
  /// **'Perfekt! Background-Tracking ist bereit.'**
  String get settingsGpsReady;

  /// GPS permission activation instructions title
  ///
  /// In de, this message translates to:
  /// **'So aktivierst du \"Immer erlauben\":'**
  String get settingsGpsInstructions;

  /// GPS permission step 1
  ///
  /// In de, this message translates to:
  /// **'Tippe auf \"Android-Einstellungen öffnen\" ↓'**
  String get settingsGpsStep1;

  /// GPS permission step 2
  ///
  /// In de, this message translates to:
  /// **'Wähle \"Berechtigung\" → \"Standort\"'**
  String get settingsGpsStep2;

  /// GPS permission step 3
  ///
  /// In de, this message translates to:
  /// **'Wähle \"Immer erlauben\"'**
  String get settingsGpsStep3;

  /// Open Android settings button
  ///
  /// In de, this message translates to:
  /// **'Android-Einstellungen öffnen'**
  String get settingsGpsOpenSettings;

  /// Open location settings button
  ///
  /// In de, this message translates to:
  /// **'GPS-Einstellungen öffnen'**
  String get settingsGpsOpenLocationSettings;

  /// GPS privacy note
  ///
  /// In de, this message translates to:
  /// **'Dein Standort bleibt auf diesem Gerät. Für Karten wird er an OpenStreetMap übergeben, nie an uns.'**
  String get settingsGpsPrivacyNote;

  /// Permanent tracking toggle label
  ///
  /// In de, this message translates to:
  /// **'Tracking dauerhaft an'**
  String get settingsTrackingPermanent;

  /// Permanent tracking enabled subtitle
  ///
  /// In de, this message translates to:
  /// **'GPS läuft permanent für alle Profile'**
  String get settingsTrackingPermanentOn;

  /// Permanent tracking disabled subtitle
  ///
  /// In de, this message translates to:
  /// **'GPS nur bei Bedarf pro Profil'**
  String get settingsTrackingPermanentOff;

  /// Tracking permission required message
  ///
  /// In de, this message translates to:
  /// **'Standort-Berechtigung nötig'**
  String get settingsTrackingPermissionRequired;

  /// Permanent tracking enabled message
  ///
  /// In de, this message translates to:
  /// **'✅ Dauerhaftes Tracking aktiviert'**
  String get settingsTrackingEnabled;

  /// Permanent tracking disabled message
  ///
  /// In de, this message translates to:
  /// **'✅ Dauerhaftes Tracking deaktiviert'**
  String get settingsTrackingDisabled;

  /// Legal section title
  ///
  /// In de, this message translates to:
  /// **'Rechtliches'**
  String get settingsSectionLegal;

  /// Imprint menu item
  ///
  /// In de, this message translates to:
  /// **'Impressum'**
  String get settingsImpressum;

  /// Imprint subtitle
  ///
  /// In de, this message translates to:
  /// **'Rechtliche Informationen'**
  String get settingsImpressumSubtitle;

  /// Privacy policy menu item
  ///
  /// In de, this message translates to:
  /// **'Datenschutzerklärung'**
  String get settingsPrivacy;

  /// Privacy policy subtitle
  ///
  /// In de, this message translates to:
  /// **'Wie wir deine Daten schützen'**
  String get settingsPrivacySubtitle;

  /// App version menu item
  ///
  /// In de, this message translates to:
  /// **'App-Version'**
  String get settingsAppVersion;

  /// Diagnostics & Support section title
  ///
  /// In de, this message translates to:
  /// **'Diagnose & Support'**
  String get settingsSectionDiagnostics;

  /// Generate debug log button
  ///
  /// In de, this message translates to:
  /// **'Debug-Log generieren'**
  String get settingsDebugLog;

  /// Debug log subtitle
  ///
  /// In de, this message translates to:
  /// **'Erstellt technische Diagnose-Informationen zum Teilen'**
  String get settingsDebugLogSubtitle;

  /// Debug log generation error
  ///
  /// In de, this message translates to:
  /// **'❌ Fehler beim Generieren des Debug-Logs: {error}'**
  String settingsDebugLogError(String error);

  /// Notifications section title
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen'**
  String get settingsSectionNotifications;

  /// Notifications subtitle
  ///
  /// In de, this message translates to:
  /// **'Erinnerungen für Medikamente und Termine'**
  String get settingsNotificationsSubtitle;

  /// Notifications info title
  ///
  /// In de, this message translates to:
  /// **'Wie funktionieren Benachrichtigungen?'**
  String get settingsNotificationsInfo;

  /// Notifications feature 1
  ///
  /// In de, this message translates to:
  /// **'Tagesmedikamente: -30min, -10min, 0min + +10min Wiederholungen'**
  String get settingsNotificationsBullet1;

  /// Notifications feature 2
  ///
  /// In de, this message translates to:
  /// **'Bedarfsmedikamente: Verfügbarkeits-Erinnerungen (-30min, -10min, -5min, 0min)'**
  String get settingsNotificationsBullet2;

  /// Notifications feature 3
  ///
  /// In de, this message translates to:
  /// **'Termine: Konfigurierbare Erinnerungen (15min bis 1 Tag vorher)'**
  String get settingsNotificationsBullet3;

  /// Notifications feature 4
  ///
  /// In de, this message translates to:
  /// **'Funktioniert auch wenn die App geschlossen ist'**
  String get settingsNotificationsBullet4;

  /// Send test notification button
  ///
  /// In de, this message translates to:
  /// **'Test-Benachrichtigung senden'**
  String get settingsNotificationsTest;

  /// Test notification subtitle
  ///
  /// In de, this message translates to:
  /// **'Prüfe ob Benachrichtigungen funktionieren'**
  String get settingsNotificationsTestSubtitle;

  /// Test notification sent message
  ///
  /// In de, this message translates to:
  /// **'✅ Test-Benachrichtigung gesendet'**
  String get settingsNotificationsTestSent;

  /// Notification queue title
  ///
  /// In de, this message translates to:
  /// **'Warteschlange'**
  String get settingsNotificationsQueue;

  /// Pending notifications label
  ///
  /// In de, this message translates to:
  /// **'Geplante Benachrichtigungen:'**
  String get settingsNotificationsQueuePending;

  /// Next notification time
  ///
  /// In de, this message translates to:
  /// **'Nächste: {time}'**
  String settingsNotificationsQueueNext(String time);

  /// Maps & Location section title
  ///
  /// In de, this message translates to:
  /// **'Karten & Standort'**
  String get settingsSectionMaps;

  /// Maps subtitle
  ///
  /// In de, this message translates to:
  /// **'Kartenkacheln werden automatisch beim Betrachten heruntergeladen und gespeichert'**
  String get settingsMapsSubtitle;

  /// Cache storage title
  ///
  /// In de, this message translates to:
  /// **'Cache-Speicher'**
  String get settingsCacheStorage;

  /// Cache size display
  ///
  /// In de, this message translates to:
  /// **'{size} MB / {limit} MB • {count} Kacheln'**
  String settingsCacheSize(int size, int limit, String count);

  /// Cache limit menu item
  ///
  /// In de, this message translates to:
  /// **'Cache-Limit'**
  String get settingsCacheLimit;

  /// Cache limit subtitle
  ///
  /// In de, this message translates to:
  /// **'{limit} MB maximale Speichergröße'**
  String settingsCacheLimitSubtitle(int limit);

  /// Cache limit dialog title
  ///
  /// In de, this message translates to:
  /// **'Cache-Limit festlegen'**
  String get settingsCacheLimitDialogTitle;

  /// Cache limit dialog label
  ///
  /// In de, this message translates to:
  /// **'Maximale Cache-Größe: {size} MB'**
  String settingsCacheLimitDialogLabel(int size);

  /// Cache limit dialog info
  ///
  /// In de, this message translates to:
  /// **'Wenn der Cache dieses Limit überschreitet, werden automatisch die ältesten Kacheln gelöscht.'**
  String get settingsCacheLimitDialogInfo;

  /// Cache limit set success message
  ///
  /// In de, this message translates to:
  /// **'✅ Cache-Limit auf {limit} MB gesetzt'**
  String settingsCacheLimitSet(int limit);

  /// Pre-download maps menu item
  ///
  /// In de, this message translates to:
  /// **'Karten vorab herunterladen'**
  String get settingsCachePreDownload;

  /// Pre-download maps subtitle
  ///
  /// In de, this message translates to:
  /// **'Lade Karten in einem Umkreis herunter'**
  String get settingsCachePreDownloadSubtitle;

  /// Pre-download placeholder message
  ///
  /// In de, this message translates to:
  /// **'🚧 Voraus-Download wird in Phase 4 implementiert'**
  String get settingsCachePreDownloadPlaceholder;

  /// Clear cache menu item
  ///
  /// In de, this message translates to:
  /// **'Cache leeren'**
  String get settingsCacheClear;

  /// Clear cache subtitle
  ///
  /// In de, this message translates to:
  /// **'Alle gespeicherten Kartenkacheln löschen'**
  String get settingsCacheClearSubtitle;

  /// Clear cache dialog title
  ///
  /// In de, this message translates to:
  /// **'Karten-Cache leeren'**
  String get settingsCacheClearDialogTitle;

  /// Clear cache dialog message
  ///
  /// In de, this message translates to:
  /// **'Möchtest du alle gespeicherten Kartenkacheln löschen?\n\nDie Karten werden beim nächsten Aufruf neu geladen. Dies kann helfen, Speicherplatz freizugeben.'**
  String get settingsCacheClearDialogMessage;

  /// Clear cache confirm button
  ///
  /// In de, this message translates to:
  /// **'Cache leeren'**
  String get settingsCacheClearConfirm;

  /// Cache cleared success message
  ///
  /// In de, this message translates to:
  /// **'✅ Karten-Cache geleert'**
  String get settingsCacheCleared;

  /// App settings section title
  ///
  /// In de, this message translates to:
  /// **'App-Einstellungen'**
  String get settingsSectionApp;

  /// Time format menu item
  ///
  /// In de, this message translates to:
  /// **'Zeitformat'**
  String get settingsTimeFormat;

  /// System default time format
  ///
  /// In de, this message translates to:
  /// **'System-Standard'**
  String get settingsTimeFormatSystem;

  /// 12-hour time format
  ///
  /// In de, this message translates to:
  /// **'12-Stunden Format'**
  String get settingsTimeFormat12h;

  /// 24-hour time format
  ///
  /// In de, this message translates to:
  /// **'24-Stunden Format'**
  String get settingsTimeFormat24h;

  /// System time format subtitle
  ///
  /// In de, this message translates to:
  /// **'Folgt den Android-Systemeinstellungen'**
  String get settingsTimeFormatSystemSubtitle;

  /// 12-hour format example
  ///
  /// In de, this message translates to:
  /// **'z.B. 2:30 PM'**
  String get settingsTimeFormat12hExample;

  /// 24-hour format example
  ///
  /// In de, this message translates to:
  /// **'z.B. 14:30'**
  String get settingsTimeFormat24hExample;

  /// Language setting menu item
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get settingsLanguage;

  /// Language changed confirmation message
  ///
  /// In de, this message translates to:
  /// **'Sprache geändert'**
  String get settingsLanguageChanged;

  /// Select language prompt in onboarding
  ///
  /// In de, this message translates to:
  /// **'Wähle deine Sprache'**
  String get onboardingSelectLanguage;

  /// Welcome onboarding page title
  ///
  /// In de, this message translates to:
  /// **'Willkommen bei'**
  String get onboardingWelcomeTitle;

  /// Welcome onboarding page subtitle
  ///
  /// In de, this message translates to:
  /// **'Deine sichere Begleiterin im Alltag mit DIS'**
  String get onboardingWelcomeSubtitle;

  /// Post-login welcome description
  ///
  /// In de, this message translates to:
  /// **'Aurora ist euer geschützter Raum. Hier kannst du dich frei ausdrücken und mit den anderen Anteilen im System in Verbindung bleiben.'**
  String get onboardingWelcomeDescription;

  /// Privacy onboarding page title
  ///
  /// In de, this message translates to:
  /// **'Deine Daten gehören DIR'**
  String get onboardingPrivacyTitle;

  /// Privacy feature 1
  ///
  /// In de, this message translates to:
  /// **'Alle Daten bleiben lokal auf deinem Gerät'**
  String get onboardingPrivacyBullet1;

  /// Privacy feature 2
  ///
  /// In de, this message translates to:
  /// **'Keine Cloud-Sicherung, kein Tracking, keine Werbung'**
  String get onboardingPrivacyBullet2;

  /// Privacy feature 3
  ///
  /// In de, this message translates to:
  /// **'Du hast die volle Kontrolle'**
  String get onboardingPrivacyBullet3;

  /// Privacy feature 4
  ///
  /// In de, this message translates to:
  /// **'Transparent und sicher'**
  String get onboardingPrivacyBullet4;

  /// Multi-profile onboarding page title
  ///
  /// In de, this message translates to:
  /// **'Viele Stimmen, eine App'**
  String get onboardingMultiProfileTitle;

  /// Multi-profile description
  ///
  /// In de, this message translates to:
  /// **'Jeder Anteil bekommt ein eigenes Profil – mit eigener Farbe, eigenem Bild und eigenen Rechten.'**
  String get onboardingMultiProfileDescription;

  /// Let's go onboarding page title
  ///
  /// In de, this message translates to:
  /// **'Bereit anzufangen?'**
  String get onboardingLetsGoTitle;

  /// Let's go description
  ///
  /// In de, this message translates to:
  /// **'Erstelle jetzt dein erstes Profil. Das erste Profil wird automatisch zum Admin-Profil mit vollen Zugriffsrechten.'**
  String get onboardingLetsGoDescription;

  /// Next button in onboarding
  ///
  /// In de, this message translates to:
  /// **'Weiter →'**
  String get onboardingButtonNext;

  /// Create profile button in onboarding
  ///
  /// In de, this message translates to:
  /// **'Profil erstellen →'**
  String get onboardingButtonCreateProfile;

  /// Aurora loading text on splash screen
  ///
  /// In de, this message translates to:
  /// **'Aurora lädt'**
  String get splashLoading;

  /// Did you know label on splash screen
  ///
  /// In de, this message translates to:
  /// **'Wusstest du?'**
  String get splashDidYouKnow;

  /// Emergency wipe dialog title
  ///
  /// In de, this message translates to:
  /// **'Notfall-Reset'**
  String get splashEmergencyWipeTitle;

  /// Emergency wipe dialog message
  ///
  /// In de, this message translates to:
  /// **'WARNUNG: Alle Daten werden unwiderruflich gelöscht!\n\n• Alle Profile\n• Alle Nachrichten\n• Alle Tagebuch-Einträge\n• Alle Kontakte\n• Alle Medikamente\n\nFortfahren?'**
  String get splashEmergencyWipeMessage;

  /// Emergency wipe confirm button
  ///
  /// In de, this message translates to:
  /// **'ALLES LÖSCHEN'**
  String get splashEmergencyWipeConfirm;

  /// Password ready to activate banner
  ///
  /// In de, this message translates to:
  /// **'Passwort bereit zum Aktivieren'**
  String get passwordResetBannerReady;

  /// Password reset running banner
  ///
  /// In de, this message translates to:
  /// **'Passwort-Reset läuft'**
  String get passwordResetBannerRunning;

  /// Password reset profile label
  ///
  /// In de, this message translates to:
  /// **'Profil: {name}'**
  String passwordResetBannerProfile(String name);

  /// Password reset remaining time
  ///
  /// In de, this message translates to:
  /// **'Profil: {name} • Verbleibend: {time}'**
  String passwordResetBannerRemaining(String name, String time);

  /// Warning dialog title
  ///
  /// In de, this message translates to:
  /// **'Warnung'**
  String get dialogWarning;

  /// Confirm dialog button
  ///
  /// In de, this message translates to:
  /// **'Bestätigen'**
  String get dialogConfirm;

  /// Understood dialog button
  ///
  /// In de, this message translates to:
  /// **'Verstanden'**
  String get dialogUnderstood;

  /// Yes dialog button
  ///
  /// In de, this message translates to:
  /// **'Ja'**
  String get dialogYes;

  /// No dialog button
  ///
  /// In de, this message translates to:
  /// **'Nein'**
  String get dialogNo;

  /// GPS permission required warning
  ///
  /// In de, this message translates to:
  /// **'⚠️ GPS-Berechtigung \"Immer erlaubt\" erforderlich'**
  String get permissionGpsRequired;

  /// Permanent tracking activation dialog title
  ///
  /// In de, this message translates to:
  /// **'Dauerhaftes Tracking aktivieren?'**
  String get permissionTrackingDialogTitle;

  /// Tracking dialog what it does heading
  ///
  /// In de, this message translates to:
  /// **'Das bewirkt dieser Modus:'**
  String get permissionTrackingDialogHeading;

  /// Tracking dialog feature 1
  ///
  /// In de, this message translates to:
  /// **'GPS läuft permanent im Hintergrund'**
  String get permissionTrackingBullet1;

  /// Tracking dialog feature 2
  ///
  /// In de, this message translates to:
  /// **'Überschreibt Tracking-Einstellung ALLER Profile'**
  String get permissionTrackingBullet2;

  /// Tracking dialog feature 3
  ///
  /// In de, this message translates to:
  /// **'Timeline erfasst alle Bewegungen automatisch'**
  String get permissionTrackingBullet3;

  /// Tracking privacy title
  ///
  /// In de, this message translates to:
  /// **'Deine Daten bleiben auf diesem Gerät'**
  String get permissionTrackingPrivacyTitle;

  /// Tracking privacy message
  ///
  /// In de, this message translates to:
  /// **'Aurora speichert alle Daten nur auf diesem Gerät. Kein Tracking, keine Werbung, keine Weitergabe.'**
  String get permissionTrackingPrivacyMessage;

  /// Battery warning for background GPS
  ///
  /// In de, this message translates to:
  /// **'Background-GPS kann den Akku stärker belasten.'**
  String get permissionTrackingBatteryWarning;

  /// Android status label in tracking dialog
  ///
  /// In de, this message translates to:
  /// **'Android-Status:'**
  String get permissionTrackingAndroidStatus;

  /// Activate tracking button
  ///
  /// In de, this message translates to:
  /// **'Aktivieren'**
  String get permissionTrackingActivate;

  /// Deactivate tracking button
  ///
  /// In de, this message translates to:
  /// **'Deaktivieren'**
  String get permissionTrackingDeactivate;

  /// Deactivate permanent tracking dialog title
  ///
  /// In de, this message translates to:
  /// **'Dauerhaftes Tracking deaktivieren?'**
  String get permissionTrackingDeactivateTitle;

  /// Deactivate permanent tracking dialog message
  ///
  /// In de, this message translates to:
  /// **'Das GPS-Tracking wird wieder pro Profil gesteuert.\n\nJedes Profil kann dann individuell das Tracking aktivieren/deaktivieren.'**
  String get permissionTrackingDeactivateMessage;

  /// Permission guidance dialog title
  ///
  /// In de, this message translates to:
  /// **'Android-Einstellung erforderlich'**
  String get permissionGuidanceTitle;

  /// Permission guidance message
  ///
  /// In de, this message translates to:
  /// **'Um dauerhaftes Tracking zu nutzen, benötigst du die Berechtigung \"Immer erlauben\".'**
  String get permissionGuidanceMessage;

  /// Permission guidance steps title
  ///
  /// In de, this message translates to:
  /// **'Ich helfe dir Schritt für Schritt:'**
  String get permissionGuidanceStepsTitle;

  /// Permission guidance step 1 title
  ///
  /// In de, this message translates to:
  /// **'Android-Einstellungen öffnen'**
  String get permissionGuidanceStep1Title;

  /// Permission guidance step 1 button
  ///
  /// In de, this message translates to:
  /// **'Jetzt öffnen'**
  String get permissionGuidanceStep1Button;

  /// Permission guidance step 2 title
  ///
  /// In de, this message translates to:
  /// **'In den Einstellungen'**
  String get permissionGuidanceStep2Title;

  /// Permission guidance step 2 bullet 1
  ///
  /// In de, this message translates to:
  /// **'Tippe auf \"Berechtigung\"'**
  String get permissionGuidanceStep2Bullet1;

  /// Permission guidance step 2 bullet 2
  ///
  /// In de, this message translates to:
  /// **'Tippe auf \"Standort\"'**
  String get permissionGuidanceStep2Bullet2;

  /// Permission guidance step 2 bullet 3
  ///
  /// In de, this message translates to:
  /// **'Wähle \"Immer erlauben\"'**
  String get permissionGuidanceStep2Bullet3;

  /// Permission guidance step 3 message
  ///
  /// In de, this message translates to:
  /// **'Zurück zu Aurora\nDie App erkennt die Änderung automatisch.'**
  String get permissionGuidanceStep3Message;

  /// Error message prefix
  ///
  /// In de, this message translates to:
  /// **'Fehler'**
  String get messageError;

  /// Success message prefix
  ///
  /// In de, this message translates to:
  /// **'Erfolgreich'**
  String get messageSuccess;

  /// Warning message prefix
  ///
  /// In de, this message translates to:
  /// **'Warnung'**
  String get messageWarning;

  /// Info message prefix
  ///
  /// In de, this message translates to:
  /// **'Information'**
  String get messageInfo;

  /// Loading message
  ///
  /// In de, this message translates to:
  /// **'Lädt...'**
  String get messageLoading;

  /// 24-hour time format label
  ///
  /// In de, this message translates to:
  /// **'24-Stunden Format'**
  String get misc24HourFormat;

  /// 12-hour time format label
  ///
  /// In de, this message translates to:
  /// **'12-Stunden Format'**
  String get misc12HourFormat;

  /// System default label
  ///
  /// In de, this message translates to:
  /// **'System-Standard'**
  String get miscSystemDefault;

  /// Unknown label
  ///
  /// In de, this message translates to:
  /// **'Unbekannt'**
  String get miscUnknown;

  /// Day separator in the chat history for the previous day
  ///
  /// In de, this message translates to:
  /// **'Gestern'**
  String get chatDayYesterday;

  /// Today label
  ///
  /// In de, this message translates to:
  /// **'Heute'**
  String get miscToday;

  /// All label
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get miscAll;

  /// Android notification channel name
  ///
  /// In de, this message translates to:
  /// **'Aurora Benachrichtigungen'**
  String get notificationChannelName;

  /// Android notification channel description
  ///
  /// In de, this message translates to:
  /// **'Erinnerungen für Medikamente und Termine'**
  String get notificationChannelDescription;

  /// Medication reminder notification title
  ///
  /// In de, this message translates to:
  /// **'Medikamenten-Erinnerung'**
  String get notificationMedicationReminder;

  /// Medication reminder notification body with time
  ///
  /// In de, this message translates to:
  /// **'{name} - {dosage} {time}'**
  String notificationMedicationBodyWithTime(
    String name,
    String dosage,
    String time,
  );

  /// Medication reminder - take now
  ///
  /// In de, this message translates to:
  /// **'{name} - {dosage} jetzt einnehmen'**
  String notificationMedicationBodyNow(String name, String dosage);

  /// As-needed medication available soon title
  ///
  /// In de, this message translates to:
  /// **'Bedarfsmedikament bald verfügbar'**
  String get notificationMedicationAvailableSoon;

  /// As-needed medication available now title
  ///
  /// In de, this message translates to:
  /// **'Bedarfsmedikament jetzt verfügbar'**
  String get notificationMedicationAvailableNow;

  /// As-needed medication available body
  ///
  /// In de, this message translates to:
  /// **'{name} kann eingenommen werden'**
  String notificationMedicationAvailableBody(String name);

  /// Event reminder notification title
  ///
  /// In de, this message translates to:
  /// **'Termin-Erinnerung'**
  String get notificationEventReminder;

  /// Event reminder notification body
  ///
  /// In de, this message translates to:
  /// **'{title} {time}'**
  String notificationEventBody(String title, String time);

  /// Test notification title
  ///
  /// In de, this message translates to:
  /// **'Test-Benachrichtigung'**
  String get notificationTestTitle;

  /// Test notification body
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen funktionieren!'**
  String get notificationTestBody;

  /// Time format - in X minutes
  ///
  /// In de, this message translates to:
  /// **'in {minutes} Minuten'**
  String notificationTimeInMinutes(int minutes);

  /// Time format - in 1 hour
  ///
  /// In de, this message translates to:
  /// **'in 1 Stunde'**
  String get notificationTimeIn1Hour;

  /// Time format - in X hours
  ///
  /// In de, this message translates to:
  /// **'in {hours} Stunden'**
  String notificationTimeInHours(int hours);

  /// Time format - now
  ///
  /// In de, this message translates to:
  /// **'jetzt'**
  String get notificationTimeNow;

  /// Medication take now notification title
  ///
  /// In de, this message translates to:
  /// **'Medikament jetzt einnehmen!'**
  String get notificationMedicationTakeNowTitle;

  /// Medication not taken yet suffix
  ///
  /// In de, this message translates to:
  /// **'Noch nicht eingenommen!'**
  String get notificationMedicationNotTakenYet;

  /// Create button label
  ///
  /// In de, this message translates to:
  /// **'Erstellen'**
  String get actionCreate;

  /// Description label
  ///
  /// In de, this message translates to:
  /// **'Beschreibung'**
  String get commonDescription;

  /// Notes label
  ///
  /// In de, this message translates to:
  /// **'Notizen'**
  String get commonNotes;

  /// Optional label
  ///
  /// In de, this message translates to:
  /// **'Optional'**
  String get commonOptional;

  /// Category label
  ///
  /// In de, this message translates to:
  /// **'Kategorie'**
  String get commonCategory;

  /// Start time label
  ///
  /// In de, this message translates to:
  /// **'Startzeit'**
  String get commonStartTime;

  /// End time label
  ///
  /// In de, this message translates to:
  /// **'Endzeit'**
  String get commonEndTime;

  /// Visible for label
  ///
  /// In de, this message translates to:
  /// **'Sichtbar für'**
  String get commonVisibleFor;

  /// Unnamed placeholder
  ///
  /// In de, this message translates to:
  /// **'Unbenannt'**
  String get commonUnnamed;

  /// Comments section title
  ///
  /// In de, this message translates to:
  /// **'Kommentare'**
  String get commentsTitle;

  /// Create event button
  ///
  /// In de, this message translates to:
  /// **'Termin erstellen'**
  String get eventCreate;

  /// New event form title
  ///
  /// In de, this message translates to:
  /// **'Neuer Termin'**
  String get eventNewTitle;

  /// Edit event form title
  ///
  /// In de, this message translates to:
  /// **'Termin bearbeiten'**
  String get eventEditTitle;

  /// Event detail screen title
  ///
  /// In de, this message translates to:
  /// **'Termin'**
  String get eventDetailTitle;

  /// Event not found title
  ///
  /// In de, this message translates to:
  /// **'Termin nicht gefunden'**
  String get eventNotFound;

  /// Event not found message
  ///
  /// In de, this message translates to:
  /// **'Diesen Termin gibt es nicht mehr'**
  String get eventNotFoundMessage;

  /// Delete event dialog title
  ///
  /// In de, this message translates to:
  /// **'Termin löschen?'**
  String get eventDeleteTitle;

  /// Delete event dialog message
  ///
  /// In de, this message translates to:
  /// **'Möchtest du diesen Termin wirklich löschen?'**
  String get eventDeleteMessage;

  /// Delete event confirmation message
  ///
  /// In de, this message translates to:
  /// **'Dieser Termin wird dauerhaft gelöscht.'**
  String get eventDeleteConfirmMessage;

  /// Event deleted success message
  ///
  /// In de, this message translates to:
  /// **'Termin gelöscht'**
  String get eventDeleted;

  /// Event updated success message
  ///
  /// In de, this message translates to:
  /// **'Termin gespeichert'**
  String get eventUpdated;

  /// Event created success message
  ///
  /// In de, this message translates to:
  /// **'Termin erstellt'**
  String get eventCreated;

  /// Profile selection required error
  ///
  /// In de, this message translates to:
  /// **'Bitte mindestens ein Profil auswählen'**
  String get eventSelectProfileRequired;

  /// End time must be after start time error
  ///
  /// In de, this message translates to:
  /// **'End-Zeit muss nach Start-Zeit liegen'**
  String get eventEndTimeError;

  /// Event title field label
  ///
  /// In de, this message translates to:
  /// **'Titel'**
  String get eventTitleLabel;

  /// Event title field label with required marker
  ///
  /// In de, this message translates to:
  /// **'Titel *'**
  String get eventTitleLabelRequired;

  /// Event title required validation message
  ///
  /// In de, this message translates to:
  /// **'Bitte gib einen Titel ein'**
  String get eventTitleRequired;

  /// Event title hint text
  ///
  /// In de, this message translates to:
  /// **'z.B. Arzttermin'**
  String get eventTitleHint;

  /// Event category field label
  ///
  /// In de, this message translates to:
  /// **'Kategorie (optional)'**
  String get eventCategoryLabel;

  /// Event category hint text
  ///
  /// In de, this message translates to:
  /// **'z.B. Arzttermin, privat, etc.'**
  String get eventCategoryHint;

  /// Event description field label
  ///
  /// In de, this message translates to:
  /// **'Beschreibung (optional)'**
  String get eventDescriptionLabel;

  /// Air-line distance from the user to a contact
  ///
  /// In de, this message translates to:
  /// **'{distance} entfernt'**
  String contactDistanceAway(String distance);

  /// Duration chip in the reminder picker
  ///
  /// In de, this message translates to:
  /// **'{minutes, plural, =1{1 Minute} other{{minutes} Minuten}}'**
  String eventReminderMinutes(int minutes);

  /// Duration chip in the reminder picker
  ///
  /// In de, this message translates to:
  /// **'{hours, plural, =1{1 Stunde} other{{hours} Stunden}}'**
  String eventReminderHours(int hours);

  /// Duration chip in the reminder picker
  ///
  /// In de, this message translates to:
  /// **'1 Tag'**
  String get eventReminderDay;

  /// Explains when the reminder will arrive
  ///
  /// In de, this message translates to:
  /// **'Aurora meldet sich {when} vor dem Termin.'**
  String eventReminderNotice(String when);

  /// Event reminder before text
  ///
  /// In de, this message translates to:
  /// **'Erinnerung {minutes} Min. vorher'**
  String eventReminderBefore(int minutes);

  /// Event count with plural forms
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =0{Keine Termine} =1{1 Termin} other{{count} Termine}}'**
  String eventCount(int count);

  /// No events for the day message
  ///
  /// In de, this message translates to:
  /// **'Keine Termine an diesem Tag'**
  String get noEventsToday;

  /// Calm empty state for today in the calendar agenda
  ///
  /// In de, this message translates to:
  /// **'Heute ist nichts geplant.'**
  String get calendarNothingPlannedToday;

  /// Calm empty state for a selected calendar day
  ///
  /// In de, this message translates to:
  /// **'An diesem Tag ist nichts geplant.'**
  String get calendarNothingPlannedOnDay;

  /// Heading above upcoming calendar events
  ///
  /// In de, this message translates to:
  /// **'Als Nächstes'**
  String get calendarUpcomingTitle;

  /// Button that opens the calendar date picker
  ///
  /// In de, this message translates to:
  /// **'Anderen Tag ansehen'**
  String get calendarChooseDay;

  /// Heading above profile choices in the event form
  ///
  /// In de, this message translates to:
  /// **'Für wen ist der Termin?'**
  String get eventForWhom;

  /// Heading above optional event form fields
  ///
  /// In de, this message translates to:
  /// **'Weitere Angaben'**
  String get eventMoreDetails;

  /// Contact screen title
  ///
  /// In de, this message translates to:
  /// **'Kontakt'**
  String get contactTitle;

  /// New contact form title
  ///
  /// In de, this message translates to:
  /// **'Neuer Kontakt'**
  String get contactNewTitle;

  /// Edit contact form title
  ///
  /// In de, this message translates to:
  /// **'Kontakt bearbeiten'**
  String get contactEditTitle;

  /// Contact not found message
  ///
  /// In de, this message translates to:
  /// **'Kontakt nicht gefunden'**
  String get contactNotFound;

  /// Delete contact dialog title
  ///
  /// In de, this message translates to:
  /// **'Kontakt löschen?'**
  String get contactDeleteTitle;

  /// Delete contact dialog message
  ///
  /// In de, this message translates to:
  /// **'Dieser Kontakt wird dauerhaft gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.'**
  String get contactDeleteMessage;

  /// Contact image picker title
  ///
  /// In de, this message translates to:
  /// **'Kontaktbild wählen'**
  String get contactImagePickerTitle;

  /// Contact name field label
  ///
  /// In de, this message translates to:
  /// **'Name *'**
  String get contactNameLabel;

  /// Contact name required validation
  ///
  /// In de, this message translates to:
  /// **'Bitte einen Namen eingeben'**
  String get contactNameRequired;

  /// Contact relation field label
  ///
  /// In de, this message translates to:
  /// **'Beziehung'**
  String get contactRelationLabel;

  /// Contact relation hint
  ///
  /// In de, this message translates to:
  /// **'z.B. Mutter, Therapeutin, Freund...'**
  String get contactRelationHint;

  /// Mark as emergency contact checkbox
  ///
  /// In de, this message translates to:
  /// **'Als Notfallkontakt markieren'**
  String get contactMarkAsEmergency;

  /// Emergency contact description
  ///
  /// In de, this message translates to:
  /// **'Dieser Kontakt erscheint in der Notfall-Ansicht und kann schnell benachrichtigt werden'**
  String get contactEmergencyDescription;

  /// Phone field label
  ///
  /// In de, this message translates to:
  /// **'Telefon'**
  String get contactPhoneLabel;

  /// Email field label
  ///
  /// In de, this message translates to:
  /// **'E-Mail'**
  String get contactEmailLabel;

  /// Default rating label
  ///
  /// In de, this message translates to:
  /// **'Standard-Bewertung'**
  String get contactDefaultRating;

  /// Default rating description
  ///
  /// In de, this message translates to:
  /// **'Diese Bewertung sehen alle Profile standardmäßig. Jedes Profil kann später eine eigene Bewertung vergeben.'**
  String get contactDefaultRatingDescription;

  /// Personal rating label
  ///
  /// In de, this message translates to:
  /// **'Persönliche Bewertung'**
  String get contactPersonalRating;

  /// Location section title
  ///
  /// In de, this message translates to:
  /// **'📍 Standort (optional)'**
  String get contactLocationSection;

  /// Location title
  ///
  /// In de, this message translates to:
  /// **'📍 Standort'**
  String get contactLocationTitle;

  /// Location description
  ///
  /// In de, this message translates to:
  /// **'Füge einen Standort hinzu (z.B. Wohnort, Praxis-Adresse)'**
  String get contactLocationDescription;

  /// Set location button
  ///
  /// In de, this message translates to:
  /// **'Position festlegen'**
  String get contactLocationSet;

  /// Change location button
  ///
  /// In de, this message translates to:
  /// **'Position ändern'**
  String get contactLocationChange;

  /// Address field label
  ///
  /// In de, this message translates to:
  /// **'Adresse'**
  String get contactAddressLabel;

  /// Address hint
  ///
  /// In de, this message translates to:
  /// **'Wird automatisch ermittelt, wenn Position festgelegt'**
  String get contactAddressHint;

  /// Contact visibility info
  ///
  /// In de, this message translates to:
  /// **'Alle Profile können diesen Kontakt sehen'**
  String get contactVisibleToAll;

  /// Contact info section title
  ///
  /// In de, this message translates to:
  /// **'Informationen'**
  String get contactInfoSection;

  /// GPS permission required warning
  ///
  /// In de, this message translates to:
  /// **'GPS-Berechtigung erforderlich'**
  String get gpsPermissionRequired;

  /// GPS tracking disabled warning
  ///
  /// In de, this message translates to:
  /// **'GPS-Tracking deaktiviert'**
  String get gpsTrackingDisabled;

  /// Emergency contact badge label
  ///
  /// In de, this message translates to:
  /// **'Notfallkontakt'**
  String get emergencyContactLabel;

  /// New diary entry form title
  ///
  /// In de, this message translates to:
  /// **'Neuer Eintrag'**
  String get diaryEntryNewTitle;

  /// Edit diary entry form title
  ///
  /// In de, this message translates to:
  /// **'Eintrag bearbeiten'**
  String get diaryEntryEditTitle;

  /// Diary entry detail screen title
  ///
  /// In de, this message translates to:
  /// **'Eintrag Details'**
  String get diaryEntryDetailTitle;

  /// Diary entry not found title
  ///
  /// In de, this message translates to:
  /// **'Eintrag nicht gefunden'**
  String get diaryEntryNotFound;

  /// Diary entry not found message
  ///
  /// In de, this message translates to:
  /// **'Dieser Eintrag existiert nicht mehr'**
  String get diaryEntryNotFoundMessage;

  /// Delete diary entry dialog title
  ///
  /// In de, this message translates to:
  /// **'Eintrag löschen'**
  String get diaryEntryDeleteTitle;

  /// Delete diary entry dialog message
  ///
  /// In de, this message translates to:
  /// **'Möchtest du diesen Eintrag wirklich löschen? Alle Kommentare werden ebenfalls gelöscht.'**
  String get diaryEntryDeleteMessage;

  /// Diary entry deleted success message
  ///
  /// In de, this message translates to:
  /// **'Eintrag gelöscht'**
  String get diaryEntryDeleted;

  /// Diary entry updated success message
  ///
  /// In de, this message translates to:
  /// **'Eintrag aktualisiert'**
  String get diaryEntryUpdated;

  /// Diary entry created success message
  ///
  /// In de, this message translates to:
  /// **'Eintrag erstellt'**
  String get diaryEntryCreated;

  /// Diary entry title hint
  ///
  /// In de, this message translates to:
  /// **'Was ist passiert?'**
  String get diaryTitleHint;

  /// Diary entry title required validation
  ///
  /// In de, this message translates to:
  /// **'Bitte Titel eingeben'**
  String get diaryTitleRequired;

  /// Diary entry description hint
  ///
  /// In de, this message translates to:
  /// **'Beschreibe das Ereignis...'**
  String get diaryDescriptionHint;

  /// Diary entry description required validation
  ///
  /// In de, this message translates to:
  /// **'Bitte Beschreibung eingeben'**
  String get diaryDescriptionRequired;

  /// Priority label
  ///
  /// In de, this message translates to:
  /// **'Priorität'**
  String get diaryPriorityLabel;

  /// Images section label
  ///
  /// In de, this message translates to:
  /// **'Bilder'**
  String get diaryImagesLabel;

  /// No images added yet message
  ///
  /// In de, this message translates to:
  /// **'Noch keine Bilder hinzugefügt'**
  String get diaryNoImagesYet;

  /// Image picker coming soon message
  ///
  /// In de, this message translates to:
  /// **'Bild-Auswahl wird in Kürze implementiert'**
  String get diaryImagePickerComingSoon;

  /// Cannot edit entry permission message
  ///
  /// In de, this message translates to:
  /// **'Du darfst diesen Eintrag nicht bearbeiten'**
  String get diaryCannotEditEntry;

  /// Cannot create entry permission message
  ///
  /// In de, this message translates to:
  /// **'Du darfst keine Einträge erstellen'**
  String get diaryCannotCreateEntry;

  /// Error label
  ///
  /// In de, this message translates to:
  /// **'Fehler'**
  String get commonError;

  /// No permission label
  ///
  /// In de, this message translates to:
  /// **'Keine Berechtigung'**
  String get commonNoPermission;

  /// Edited label
  ///
  /// In de, this message translates to:
  /// **'Bearbeitet'**
  String get commonEdited;

  /// Title label
  ///
  /// In de, this message translates to:
  /// **'Titel'**
  String get commonTitle;

  /// No profile selected message
  ///
  /// In de, this message translates to:
  /// **'Kein Profil ausgewählt'**
  String get profileNotSelected;

  /// Add button label
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen'**
  String get actionAdd;

  /// Save error message
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Speichern: {error}'**
  String commonSaveError(String error);

  /// Just now relative time
  ///
  /// In de, this message translates to:
  /// **'gerade eben'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{vor einer Minute} other{vor {count} Minuten}}'**
  String timeMinutesAgo(int count);

  /// No description provided for @timeHoursAgo.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{vor einer Stunde} other{vor {count} Stunden}}'**
  String timeHoursAgo(int count);

  /// No description provided for @timeDaysAgo.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{vor einem Tag} other{vor {count} Tagen}}'**
  String timeDaysAgo(int count);

  /// Call button label
  ///
  /// In de, this message translates to:
  /// **'Anrufen'**
  String get emergencyCall;

  /// Call contact tooltip
  ///
  /// In de, this message translates to:
  /// **'Kontakt anrufen'**
  String get emergencyCallTooltip;

  /// No phone number available
  ///
  /// In de, this message translates to:
  /// **'Keine Telefonnummer vorhanden'**
  String get emergencyNoPhone;

  /// SMS button label
  ///
  /// In de, this message translates to:
  /// **'SMS'**
  String get emergencySms;

  /// Send emergency SMS tooltip
  ///
  /// In de, this message translates to:
  /// **'Notfall-SMS senden'**
  String get emergencySmsTooltip;

  /// App share button label
  ///
  /// In de, this message translates to:
  /// **'App'**
  String get emergencyApp;

  /// Share via app tooltip
  ///
  /// In de, this message translates to:
  /// **'Via App teilen'**
  String get emergencyShareTooltip;

  /// Call error message
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Anrufen: {error}'**
  String emergencyErrorCall(String error);

  /// Open error message
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Öffnen: {error}'**
  String emergencyErrorOpen(String error);

  /// Open button label
  ///
  /// In de, this message translates to:
  /// **'Öffnen'**
  String get actionOpen;

  /// Edit location form title
  ///
  /// In de, this message translates to:
  /// **'Ort bearbeiten'**
  String get finderLocationEditTitle;

  /// Edit item form title
  ///
  /// In de, this message translates to:
  /// **'Gegenstand bearbeiten'**
  String get finderItemEditTitle;

  /// New location form title
  ///
  /// In de, this message translates to:
  /// **'Neuer Ort'**
  String get finderLocationNewTitle;

  /// New item form title
  ///
  /// In de, this message translates to:
  /// **'Neuer Gegenstand'**
  String get finderItemNewTitle;

  /// Set position button
  ///
  /// In de, this message translates to:
  /// **'Position festlegen'**
  String get finderSetPosition;

  /// Change position button
  ///
  /// In de, this message translates to:
  /// **'Position ändern'**
  String get finderChangePosition;

  /// Address field label
  ///
  /// In de, this message translates to:
  /// **'Adresse'**
  String get finderAddressLabel;

  /// Storage location field label
  ///
  /// In de, this message translates to:
  /// **'Aufbewahrungsort'**
  String get finderStorageLocationLabel;

  /// Storage location hint
  ///
  /// In de, this message translates to:
  /// **'z.B. Küche, 2. Schublade'**
  String get finderStorageLocationHint;

  /// Choose photo button
  ///
  /// In de, this message translates to:
  /// **'Foto wählen'**
  String get finderChoosePhoto;

  /// Add photo button
  ///
  /// In de, this message translates to:
  /// **'Foto hinzufügen'**
  String get finderAddPhoto;

  /// Add tag field label
  ///
  /// In de, this message translates to:
  /// **'Tag hinzufügen'**
  String get finderAddTag;

  /// Not found title
  ///
  /// In de, this message translates to:
  /// **'Nicht gefunden'**
  String get finderNotFound;

  /// Item not found message
  ///
  /// In de, this message translates to:
  /// **'Item nicht gefunden'**
  String get finderNotFoundMessage;

  /// Delete confirmation title
  ///
  /// In de, this message translates to:
  /// **'Löschen?'**
  String get finderDeleteTitle;

  /// Delete confirmation message
  ///
  /// In de, this message translates to:
  /// **'{title} wirklich löschen?'**
  String finderDeleteMessage(String title);

  /// Required field validation message
  ///
  /// In de, this message translates to:
  /// **'Pflichtfeld'**
  String get commonRequired;

  /// Feedback screen title
  ///
  /// In de, this message translates to:
  /// **'Feedback senden'**
  String get feedbackTitle;

  /// Privacy info text
  ///
  /// In de, this message translates to:
  /// **'Dein Feedback wird vertraulich behandelt und nur intern verarbeitet. Deine Rückmeldungen helfen uns, Aurora zu verbessern!'**
  String get feedbackPrivacyInfo;

  /// Category selection label
  ///
  /// In de, this message translates to:
  /// **'Kategorie wählen:'**
  String get feedbackSelectCategory;

  /// Tooltip for the eye button that reveals the password
  ///
  /// In de, this message translates to:
  /// **'Passwort anzeigen'**
  String get fieldPasswordShow;

  /// Tooltip for the eye button that hides the password again
  ///
  /// In de, this message translates to:
  /// **'Passwort verbergen'**
  String get fieldPasswordHide;

  /// Category: report a problem
  ///
  /// In de, this message translates to:
  /// **'Fehler melden'**
  String get feedbackCategoryBug;

  /// Category: suggest an idea
  ///
  /// In de, this message translates to:
  /// **'Wunsch äußern'**
  String get feedbackCategoryWish;

  /// Category: general feedback
  ///
  /// In de, this message translates to:
  /// **'Allgemeine Rückmeldung'**
  String get feedbackCategoryGeneral;

  /// Category label
  ///
  /// In de, this message translates to:
  /// **'Kategorie'**
  String get feedbackCategoryLabel;

  /// Title field label
  ///
  /// In de, this message translates to:
  /// **'Titel:'**
  String get feedbackTitleLabel;

  /// Title field hint
  ///
  /// In de, this message translates to:
  /// **'Kurze Zusammenfassung deines Feedbacks'**
  String get feedbackTitleHint;

  /// Title required validation
  ///
  /// In de, this message translates to:
  /// **'Bitte gib einen Titel ein'**
  String get feedbackTitleRequired;

  /// Title too short validation
  ///
  /// In de, this message translates to:
  /// **'Titel zu kurz (mindestens 5 Zeichen)'**
  String get feedbackTitleTooShort;

  /// Message field label
  ///
  /// In de, this message translates to:
  /// **'Deine Nachricht:'**
  String get feedbackMessageLabel;

  /// Message field hint
  ///
  /// In de, this message translates to:
  /// **'Beschreibe dein Feedback ausführlich...'**
  String get feedbackMessageHint;

  /// Message required validation
  ///
  /// In de, this message translates to:
  /// **'Bitte gib eine Nachricht ein'**
  String get feedbackMessageRequired;

  /// Message too short validation
  ///
  /// In de, this message translates to:
  /// **'Nachricht zu kurz (mindestens 20 Zeichen)'**
  String get feedbackMessageTooShort;

  /// Email field label
  ///
  /// In de, this message translates to:
  /// **'Deine E-Mail (optional):'**
  String get feedbackEmailLabel;

  /// Email field hint
  ///
  /// In de, this message translates to:
  /// **'Nur wenn du möchtest, dass wir dich bei Rückfragen kontaktieren'**
  String get feedbackEmailHint;

  /// Email field placeholder
  ///
  /// In de, this message translates to:
  /// **'deine@email.de'**
  String get feedbackEmailPlaceholder;

  /// Invalid email validation
  ///
  /// In de, this message translates to:
  /// **'Bitte gültige E-Mail-Adresse eingeben'**
  String get feedbackEmailInvalid;

  /// Attach image label
  ///
  /// In de, this message translates to:
  /// **'Bild anfügen (optional):'**
  String get feedbackAttachImageLabel;

  /// Attach image button
  ///
  /// In de, this message translates to:
  /// **'Bild anfügen'**
  String get feedbackAttachImage;

  /// Select image dialog title
  ///
  /// In de, this message translates to:
  /// **'Bild auswählen'**
  String get feedbackSelectImage;

  /// Send feedback button
  ///
  /// In de, this message translates to:
  /// **'Feedback senden'**
  String get feedbackSend;

  /// Copy to clipboard button
  ///
  /// In de, this message translates to:
  /// **'In Zwischenablage kopieren'**
  String get feedbackCopyToClipboard;

  /// Copied to clipboard success message
  ///
  /// In de, this message translates to:
  /// **'Feedback in Zwischenablage kopiert!'**
  String get feedbackCopiedToClipboard;

  /// Contact label
  ///
  /// In de, this message translates to:
  /// **'Kontakt'**
  String get feedbackContactLabel;

  /// Error occurred message
  ///
  /// In de, this message translates to:
  /// **'Ein Fehler ist aufgetreten. Report wurde in Zwischenablage kopiert.'**
  String get feedbackErrorOccurred;

  /// Could not send feedback error title
  ///
  /// In de, this message translates to:
  /// **'Feedback konnte nicht gesendet werden'**
  String get feedbackCouldNotSend;

  /// Error clipboard hint with email
  ///
  /// In de, this message translates to:
  /// **'Dein Feedback wurde in die Zwischenablage kopiert. Du kannst es uns auch per E-Mail an {email} senden.'**
  String feedbackErrorClipboardHint(String email);

  /// Technical details expansion title
  ///
  /// In de, this message translates to:
  /// **'Technische Details'**
  String get feedbackTechnicalDetails;

  /// Change action button
  ///
  /// In de, this message translates to:
  /// **'Ändern'**
  String get actionChange;

  /// Remove action button
  ///
  /// In de, this message translates to:
  /// **'Entfernen'**
  String get actionRemove;

  /// Next button text
  ///
  /// In de, this message translates to:
  /// **'Weiter →'**
  String get onboardingNext;

  /// Create profile button
  ///
  /// In de, this message translates to:
  /// **'Profil erstellen →'**
  String get onboardingCreateProfile;

  /// Let's go button
  ///
  /// In de, this message translates to:
  /// **'Los geht\'s! →'**
  String get onboardingLetsGo;

  /// Welcome to text
  ///
  /// In de, this message translates to:
  /// **'Willkommen bei'**
  String get onboardingWelcomeTo;

  /// Main subline
  ///
  /// In de, this message translates to:
  /// **'Deine sichere Begleiterin im Alltag mit DIS'**
  String get onboardingSubline;

  /// Main description
  ///
  /// In de, this message translates to:
  /// **'Aurora unterstützt dich beim Organisieren deines Alltags und der Kommunikation innerhalb deines Systems.'**
  String get onboardingDescription;

  /// Privacy page headline
  ///
  /// In de, this message translates to:
  /// **'Deine Daten gehören DIR'**
  String get onboardingPrivacyHeadline;

  /// Privacy bullet point 1
  ///
  /// In de, this message translates to:
  /// **'Alle Daten bleiben lokal auf deinem Gerät'**
  String get onboardingPrivacyPoint1;

  /// Privacy bullet point 2
  ///
  /// In de, this message translates to:
  /// **'Keine Cloud-Sicherung, kein Tracking, keine Werbung'**
  String get onboardingPrivacyPoint2;

  /// Privacy bullet point 3
  ///
  /// In de, this message translates to:
  /// **'Du hast die volle Kontrolle'**
  String get onboardingPrivacyPoint3;

  /// Privacy bullet point 4
  ///
  /// In de, this message translates to:
  /// **'Transparent und sicher'**
  String get onboardingPrivacyPoint4;

  /// Multi-profile page headline
  ///
  /// In de, this message translates to:
  /// **'Viele Stimmen, eine App'**
  String get onboardingMultiProfileHeadline;

  /// Let's go page headline
  ///
  /// In de, this message translates to:
  /// **'Bereit anzufangen?'**
  String get onboardingLetsGoHeadline;

  /// Hello greeting with name
  ///
  /// In de, this message translates to:
  /// **'Hallo {name}!'**
  String onboardingHelloName(String name);

  /// Glad you're here subline
  ///
  /// In de, this message translates to:
  /// **'Schön, dass du da bist.'**
  String get onboardingGladYoureHere;

  /// Not alone headline
  ///
  /// In de, this message translates to:
  /// **'Du bist nicht allein'**
  String get onboardingNotAlone;

  /// Not alone description
  ///
  /// In de, this message translates to:
  /// **'Ihr könnt miteinander chatten, Termine teilen und euch gegenseitig unterstützen.'**
  String get onboardingNotAloneDescription;

  /// What you can do headline
  ///
  /// In de, this message translates to:
  /// **'Was du tun kannst'**
  String get onboardingWhatYouCanDo;

  /// Child access description
  ///
  /// In de, this message translates to:
  /// **'Als Kind-Profil hast du Zugriff auf:'**
  String get onboardingChildAccessDescription;

  /// Adult access description
  ///
  /// In de, this message translates to:
  /// **'Diese Funktionen stehen dir zur Verfügung:'**
  String get onboardingAdultAccessDescription;

  /// Safe space headline
  ///
  /// In de, this message translates to:
  /// **'Dein sicherer Raum'**
  String get onboardingSafeSpace;

  /// Safe space description
  ///
  /// In de, this message translates to:
  /// **'Alle deine Einträge bleiben auf diesem Gerät. Gesendet wird nur, was du selbst absendest — und du kannst es jederzeit nachlesen.'**
  String get onboardingSafeSpaceDescription;

  /// Have fun subline
  ///
  /// In de, this message translates to:
  /// **'Viel Spaß mit Aurora!'**
  String get onboardingHaveFun;

  /// Chat feature for children
  ///
  /// In de, this message translates to:
  /// **'Chat - Kritzeln und mit anderen sprechen'**
  String get onboardingFeatureChatChild;

  /// Diary feature for children
  ///
  /// In de, this message translates to:
  /// **'Tagebuch - Deine Gedanken aufschreiben'**
  String get onboardingFeatureDiaryChild;

  /// Games feature for children
  ///
  /// In de, this message translates to:
  /// **'Spiele - Spaß haben und entspannen'**
  String get onboardingFeatureGamesChild;

  /// Timeline feature for children
  ///
  /// In de, this message translates to:
  /// **'Timeline - Wichtige Momente festhalten'**
  String get onboardingFeatureTimelineChild;

  /// Chat feature for adults
  ///
  /// In de, this message translates to:
  /// **'Chat - Nachrichten, Kritzeleien, Sprachnachrichten'**
  String get onboardingFeatureChat;

  /// Calendar feature
  ///
  /// In de, this message translates to:
  /// **'Kalender - Termine planen und verwalten'**
  String get onboardingFeatureCalendar;

  /// Contacts feature
  ///
  /// In de, this message translates to:
  /// **'Kontakte - Wichtige Personen speichern'**
  String get onboardingFeatureContacts;

  /// Medication feature
  ///
  /// In de, this message translates to:
  /// **'Medikation - Medikamente und Einnahmen tracken'**
  String get onboardingFeatureMedication;

  /// Diary feature for adults
  ///
  /// In de, this message translates to:
  /// **'Tagebuch - Gedanken und Erlebnisse festhalten'**
  String get onboardingFeatureDiary;

  /// Finder feature
  ///
  /// In de, this message translates to:
  /// **'Finder - Orte und Dinge wiederfinden'**
  String get onboardingFeatureFinder;

  /// Emergency feature
  ///
  /// In de, this message translates to:
  /// **'Notfall - Schnelle Hilfe in Krisensituationen'**
  String get onboardingFeatureEmergency;

  /// Mantras feature
  ///
  /// In de, this message translates to:
  /// **'Mantras - Beruhigende Sätze und Affirmationen'**
  String get onboardingFeatureMantras;

  /// Basic chat feature fallback
  ///
  /// In de, this message translates to:
  /// **'Chat - Grundfunktionen verfügbar'**
  String get onboardingFeatureChatBasic;

  /// Feature carousel headline
  ///
  /// In de, this message translates to:
  /// **'Was Aurora alles kann'**
  String get featureCarouselHeadline;

  /// Swipe hint
  ///
  /// In de, this message translates to:
  /// **'Wisch durch die Features →'**
  String get featureCarouselSwipeHint;

  /// Chat title
  ///
  /// In de, this message translates to:
  /// **'Chat'**
  String get featureCarouselChatTitle;

  /// Chat subtitle
  ///
  /// In de, this message translates to:
  /// **'Interne Kommunikation'**
  String get featureCarouselChatSubtitle;

  /// Chat description
  ///
  /// In de, this message translates to:
  /// **'Nachrichten, Kritzeleien & Sprachnachrichten.\nTeilt Gedanken, malt zusammen oder sprecht miteinander.'**
  String get featureCarouselChatDescription;

  /// Calendar title
  ///
  /// In de, this message translates to:
  /// **'Kalender'**
  String get featureCarouselCalendarTitle;

  /// Calendar subtitle
  ///
  /// In de, this message translates to:
  /// **'Events & Termine'**
  String get featureCarouselCalendarSubtitle;

  /// Calendar description
  ///
  /// In de, this message translates to:
  /// **'Termine mit Bildern & Standorten.\nBehaltet wichtige Termine im Blick, mit Bildern und GPS-Positionen.'**
  String get featureCarouselCalendarDescription;

  /// Diary title
  ///
  /// In de, this message translates to:
  /// **'Tagebuch'**
  String get featureCarouselDiaryTitle;

  /// Diary subtitle
  ///
  /// In de, this message translates to:
  /// **'Private Gedanken'**
  String get featureCarouselDiarySubtitle;

  /// Diary description
  ///
  /// In de, this message translates to:
  /// **'Für alle sichtbar oder nur für dich.\nHaltet Gedanken fest - öffentlich für alle Profile oder privat nur für euch.'**
  String get featureCarouselDiaryDescription;

  /// Finder title
  ///
  /// In de, this message translates to:
  /// **'Finder'**
  String get featureCarouselFinderTitle;

  /// Finder subtitle
  ///
  /// In de, this message translates to:
  /// **'Orte & Dinge'**
  String get featureCarouselFinderSubtitle;

  /// Finder description
  ///
  /// In de, this message translates to:
  /// **'Findet Orte und Dinge wieder.\nSpeichert wichtige Orte (mit Karte) und Gegenstände, damit ihr sie wiederfindet.'**
  String get featureCarouselFinderDescription;

  /// Medication title
  ///
  /// In de, this message translates to:
  /// **'Medikation'**
  String get featureCarouselMedicationTitle;

  /// Medication subtitle
  ///
  /// In de, this message translates to:
  /// **'Medikamenten-Tracker'**
  String get featureCarouselMedicationSubtitle;

  /// Medication description
  ///
  /// In de, this message translates to:
  /// **'Medikamente & Einnahmezeiten.\nTrackt Medikamente, Einnahmezeiten und Bedarfsmedikation.'**
  String get featureCarouselMedicationDescription;

  /// Games title
  ///
  /// In de, this message translates to:
  /// **'Spiele & Grounding'**
  String get featureCarouselGamesTitle;

  /// Games subtitle
  ///
  /// In de, this message translates to:
  /// **'Entspannung'**
  String get featureCarouselGamesSubtitle;

  /// Games description
  ///
  /// In de, this message translates to:
  /// **'Spiele, Atemübungen & Grounding.\nBeruhigt euch mit Puzzles, Atemübungen und Grounding-Techniken.'**
  String get featureCarouselGamesDescription;

  /// Emergency title
  ///
  /// In de, this message translates to:
  /// **'Hilfsangebote'**
  String get featureCarouselEmergencyTitle;

  /// Emergency subtitle
  ///
  /// In de, this message translates to:
  /// **'Notfallkontakte'**
  String get featureCarouselEmergencySubtitle;

  /// Emergency description
  ///
  /// In de, this message translates to:
  /// **'Notfallkontakte & schnelle Hilfe.\nHinterlegt wichtige Kontakte für Krisensituationen.'**
  String get featureCarouselEmergencyDescription;

  /// Info title
  ///
  /// In de, this message translates to:
  /// **'DIS-Informationen'**
  String get featureCarouselInfoTitle;

  /// Info subtitle
  ///
  /// In de, this message translates to:
  /// **'Wissen & Ressourcen'**
  String get featureCarouselInfoSubtitle;

  /// Info description
  ///
  /// In de, this message translates to:
  /// **'Erklärt: Was ist DIS?\nInformationen über Dissoziative Identitätsstörung und Ressourcen.'**
  String get featureCarouselInfoDescription;

  /// Unknown label
  ///
  /// In de, this message translates to:
  /// **'Unbekannt'**
  String get commonUnknown;

  /// Timeline screen title
  ///
  /// In de, this message translates to:
  /// **'Zeitachse'**
  String get timelineTitle;

  /// Timeline history section header
  ///
  /// In de, this message translates to:
  /// **'Verlauf'**
  String get timelineHistory;

  /// Timeline entries count
  ///
  /// In de, this message translates to:
  /// **'{count} Einträge'**
  String timelineEntries(int count);

  /// Location entry when address is not available
  ///
  /// In de, this message translates to:
  /// **'Position aktualisiert'**
  String get timelinePositionUpdated;

  /// Profile is active message
  ///
  /// In de, this message translates to:
  /// **'{name} aktiv'**
  String timelineProfileActive(String name);

  /// App started event label
  ///
  /// In de, this message translates to:
  /// **'App gestartet'**
  String get timelineAppStarted;

  /// Profile switched event label
  ///
  /// In de, this message translates to:
  /// **'Profil gewechselt'**
  String get timelineProfileSwitched;

  /// Today date format
  ///
  /// In de, this message translates to:
  /// **'Heute, {time} Uhr'**
  String timelineToday(String time);

  /// Yesterday date format
  ///
  /// In de, this message translates to:
  /// **'Gestern, {time} Uhr'**
  String timelineYesterday(String time);

  /// Tracking disabled empty state title
  ///
  /// In de, this message translates to:
  /// **'GPS-Tracking deaktiviert'**
  String get timelineTrackingDisabledTitle;

  /// Tracking disabled empty state subtitle
  ///
  /// In de, this message translates to:
  /// **'Die Zeitachse zeigt deine Profil-Wechsel und GPS-Positionen über die Zeit.\n\nAktiviere das GPS-Tracking über das Satelliten-Symbol oben rechts, um Daten zu sammeln.'**
  String get timelineTrackingDisabledSubtitle;

  /// Empty timeline state title
  ///
  /// In de, this message translates to:
  /// **'Noch keine Daten'**
  String get timelineEmptyTitle;

  /// Empty timeline state subtitle
  ///
  /// In de, this message translates to:
  /// **'Das GPS-Tracking ist aktiv. Deine Position wird alle 2-3 Minuten aufgezeichnet.\n\nProfil-Wechsel und GPS-Positionen erscheinen hier automatisch.'**
  String get timelineEmptySubtitle;

  /// Games screen title
  ///
  /// In de, this message translates to:
  /// **'Spiele & Entspannung'**
  String get gamesTitle;

  /// Games screen subtitle
  ///
  /// In de, this message translates to:
  /// **'Einfache Spiele zur Ablenkung und Entspannung.\nKeine Timer, keine Punkte - nur Ruhe.'**
  String get gamesSubtitle;

  /// Coming soon badge
  ///
  /// In de, this message translates to:
  /// **'Bald'**
  String get gamesComingSoon;

  /// Puzzle game title
  ///
  /// In de, this message translates to:
  /// **'Puzzle'**
  String get gamesPuzzleTitle;

  /// Puzzle game subtitle
  ///
  /// In de, this message translates to:
  /// **'Jigsaw oder Schiebepuzzle'**
  String get gamesPuzzleSubtitle;

  /// Puzzle game description
  ///
  /// In de, this message translates to:
  /// **'Entspanne dich mit beruhigenden Bildern'**
  String get gamesPuzzleDescription;

  /// Breathing exercises title
  ///
  /// In de, this message translates to:
  /// **'Atemübungen'**
  String get gamesBreathingTitle;

  /// Breathing exercises subtitle
  ///
  /// In de, this message translates to:
  /// **'Geführte Atemtechniken'**
  String get gamesBreathingSubtitle;

  /// Breathing exercises description
  ///
  /// In de, this message translates to:
  /// **'Beruhige dich mit einfachen Atemübungen'**
  String get gamesBreathingDescription;

  /// Memory card state: face down
  ///
  /// In de, this message translates to:
  /// **'Verdeckt'**
  String get memoryCardHidden;

  /// Memory card state: face up
  ///
  /// In de, this message translates to:
  /// **'Aufgedeckt'**
  String get memoryCardOpen;

  /// Memory card state: matched
  ///
  /// In de, this message translates to:
  /// **'Paar gefunden'**
  String get memoryCardFound;

  /// Shown when the memory game is complete
  ///
  /// In de, this message translates to:
  /// **'Alle Paare liegen.'**
  String get memoryAllFound;

  /// Starts a new memory round
  ///
  /// In de, this message translates to:
  /// **'Neues Spiel'**
  String get memoryNewGame;

  /// Confirm button on the standalone drawing screen
  ///
  /// In de, this message translates to:
  /// **'In den Chat schicken'**
  String get gamesDrawingSend;

  /// Tooltip when the drawing is still empty
  ///
  /// In de, this message translates to:
  /// **'Zeichne etwas, dann kannst du es schicken'**
  String get gamesDrawingEmpty;

  /// Confirmation after the drawing was sent
  ///
  /// In de, this message translates to:
  /// **'Dein Bild steht jetzt im Chat.'**
  String get gamesDrawingSent;

  /// Accessibility label naming a memory card by its place
  ///
  /// In de, this message translates to:
  /// **'Karte {position} von {total}'**
  String memoryCardPosition(int position, int total);

  /// Memory game title
  ///
  /// In de, this message translates to:
  /// **'Memory'**
  String get gamesMemoryTitle;

  /// Memory game subtitle
  ///
  /// In de, this message translates to:
  /// **'Finde passende Paare'**
  String get gamesMemorySubtitle;

  /// Memory game description
  ///
  /// In de, this message translates to:
  /// **'Entspanntes Memory-Spiel ohne Zeitdruck'**
  String get gamesMemoryDescription;

  /// Drawing title
  ///
  /// In de, this message translates to:
  /// **'Zeichnen'**
  String get gamesDrawingTitle;

  /// Drawing subtitle
  ///
  /// In de, this message translates to:
  /// **'Freies Malen & Doodles'**
  String get gamesDrawingSubtitle;

  /// Drawing description
  ///
  /// In de, this message translates to:
  /// **'Drücke dich kreativ aus'**
  String get gamesDrawingDescription;

  /// Puzzle creation screen title
  ///
  /// In de, this message translates to:
  /// **'Puzzle erstellen'**
  String get puzzleCreateTitle;

  /// Puzzle relaxation header
  ///
  /// In de, this message translates to:
  /// **'Puzzle zur Entspannung'**
  String get puzzleRelaxationTitle;

  /// Puzzle relaxation subtitle
  ///
  /// In de, this message translates to:
  /// **'Wähle deinen Puzzle-Typ und die Schwierigkeit. Nimm dir Zeit - es gibt keine Wertung.'**
  String get puzzleRelaxationSubtitle;

  /// Puzzle type section label
  ///
  /// In de, this message translates to:
  /// **'Puzzle-Typ'**
  String get puzzleTypeLabel;

  /// Jigsaw puzzle type
  ///
  /// In de, this message translates to:
  /// **'Jigsaw'**
  String get puzzleTypeJigsaw;

  /// Jigsaw puzzle description
  ///
  /// In de, this message translates to:
  /// **'Ziehe Teile an die richtige Stelle'**
  String get puzzleTypeJigsawDescription;

  /// Sliding puzzle type
  ///
  /// In de, this message translates to:
  /// **'Schiebepuzzle'**
  String get puzzleTypeSliding;

  /// Sliding puzzle description
  ///
  /// In de, this message translates to:
  /// **'Verschiebe Teile durch Antippen'**
  String get puzzleTypeSlidingDescription;

  /// Difficulty section label
  ///
  /// In de, this message translates to:
  /// **'Schwierigkeit'**
  String get puzzleDifficultyLabel;

  /// Easy difficulty
  ///
  /// In de, this message translates to:
  /// **'Einfach'**
  String get puzzleDifficultyEasy;

  /// Easy difficulty description
  ///
  /// In de, this message translates to:
  /// **'3×3 Raster - perfekt zum Entspannen'**
  String get puzzleDifficultyEasyDescription;

  /// Medium difficulty
  ///
  /// In de, this message translates to:
  /// **'Mittel'**
  String get puzzleDifficultyMedium;

  /// Medium difficulty description
  ///
  /// In de, this message translates to:
  /// **'4×4 Raster - eine kleine Herausforderung'**
  String get puzzleDifficultyMediumDescription;

  /// Hard difficulty
  ///
  /// In de, this message translates to:
  /// **'Schwer'**
  String get puzzleDifficultyHard;

  /// Hard difficulty description
  ///
  /// In de, this message translates to:
  /// **'5×5 Raster - für Puzzle-Profis'**
  String get puzzleDifficultyHardDescription;

  /// Select image and start button
  ///
  /// In de, this message translates to:
  /// **'Bild auswählen & starten'**
  String get puzzleSelectImageAndStart;

  /// Jigsaw puzzle screen title
  ///
  /// In de, this message translates to:
  /// **'Jigsaw Puzzle'**
  String get puzzleJigsawTitle;

  /// Sliding puzzle screen title
  ///
  /// In de, this message translates to:
  /// **'Schiebepuzzle'**
  String get puzzleSlidingTitle;

  /// Move counter
  ///
  /// In de, this message translates to:
  /// **'Züge: {count}'**
  String puzzleMoves(int count);

  /// Puzzle loading message
  ///
  /// In de, this message translates to:
  /// **'Puzzle wird vorbereitet...'**
  String get puzzlePreparing;

  /// Available pieces section header
  ///
  /// In de, this message translates to:
  /// **'Verfügbare Teile'**
  String get puzzleAvailablePieces;

  /// Sliding puzzle instruction
  ///
  /// In de, this message translates to:
  /// **'Tippe auf ein Teil, um es zu verschieben'**
  String get puzzleTapToMove;

  /// Show hint button
  ///
  /// In de, this message translates to:
  /// **'Hilfe anzeigen'**
  String get puzzleShowHint;

  /// Hint showing movable pieces count
  ///
  /// In de, this message translates to:
  /// **'Tipp: Du kannst {count} Teile bewegen'**
  String puzzleHintMovablePieces(int count);

  /// Puzzle solved celebration title
  ///
  /// In de, this message translates to:
  /// **'Puzzle gelöst!'**
  String get puzzleSolved;

  /// Puzzle solved message with move count
  ///
  /// In de, this message translates to:
  /// **'Du hast das Puzzle in {count} Zügen gelöst.'**
  String puzzleSolvedInMoves(int count);

  /// Image loading error
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden des Bildes: {error}'**
  String puzzleErrorLoadingImage(String error);

  /// Sharing error
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Teilen: {error}'**
  String puzzleErrorSharing(String error);

  /// Image picker dialog title
  ///
  /// In de, this message translates to:
  /// **'Bild auswählen'**
  String get puzzleImagePickerTitle;

  /// Image picker dialog subtitle
  ///
  /// In de, this message translates to:
  /// **'Wähle ein beruhigendes Bild für dein Puzzle'**
  String get puzzleImagePickerSubtitle;

  /// Image loading message
  ///
  /// In de, this message translates to:
  /// **'Bild wird geladen...'**
  String get puzzleImageLoading;

  /// Image load failed message
  ///
  /// In de, this message translates to:
  /// **'Bild konnte nicht geladen werden'**
  String get puzzleImageLoadFailed;

  /// Gallery image source
  ///
  /// In de, this message translates to:
  /// **'Galerie'**
  String get puzzleImageSourceGallery;

  /// Gallery image source subtitle
  ///
  /// In de, this message translates to:
  /// **'Bild aus deiner Galerie wählen'**
  String get puzzleImageSourceGallerySubtitle;

  /// Camera image source
  ///
  /// In de, this message translates to:
  /// **'Kamera'**
  String get puzzleImageSourceCamera;

  /// Camera image source subtitle
  ///
  /// In de, this message translates to:
  /// **'Neues Foto aufnehmen'**
  String get puzzleImageSourceCameraSubtitle;

  /// Online image source
  ///
  /// In de, this message translates to:
  /// **'Online'**
  String get puzzleImageSourceOnline;

  /// Online image source subtitle
  ///
  /// In de, this message translates to:
  /// **'Beruhigendes Bild vom Internet'**
  String get puzzleImageSourceOnlineSubtitle;

  /// Select category dialog title
  ///
  /// In de, this message translates to:
  /// **'Kategorie wählen'**
  String get puzzleSelectCategory;

  /// No profile selected error
  ///
  /// In de, this message translates to:
  /// **'Kein Profil ausgewählt'**
  String get errorNoProfileSelected;

  /// Mantras screen title
  ///
  /// In de, this message translates to:
  /// **'Mantras'**
  String get mantrasTitle;

  /// Mantras coming soon title
  ///
  /// In de, this message translates to:
  /// **'Mantras - Coming Soon ✨'**
  String get mantrasComingSoonTitle;

  /// Mantras coming soon subtitle
  ///
  /// In de, this message translates to:
  /// **'Beruhigende Affirmationen und positive Mantras für schwierige Momente'**
  String get mantrasComingSoonSubtitle;

  /// Help resources screen title
  ///
  /// In de, this message translates to:
  /// **'Hilfsangebote'**
  String get helpResourcesTitle;

  /// Emergency hotlines section title
  ///
  /// In de, this message translates to:
  /// **'24/7 Notfall-Hotlines'**
  String get helpHotlinesTitle;

  /// Emergency hotlines section subtitle
  ///
  /// In de, this message translates to:
  /// **'Professionelle Unterstützung - jederzeit erreichbar'**
  String get helpHotlinesSubtitle;

  /// More resources coming soon title
  ///
  /// In de, this message translates to:
  /// **'Weitere Ressourcen folgen'**
  String get helpMoreResourcesTitle;

  /// More resources coming soon description
  ///
  /// In de, this message translates to:
  /// **'In zukünftigen Updates:\n• Therapie-Ressourcen\n• Selbsthilfegruppen\n• Informationsmaterial über DIS\n• Krisenpläne & Strategien'**
  String get helpMoreResourcesDescription;

  /// More screen title
  ///
  /// In de, this message translates to:
  /// **'Weitere Funktionen'**
  String get moreTitle;

  /// Help resources menu item
  ///
  /// In de, this message translates to:
  /// **'Hilfsangebote'**
  String get moreHelpResources;

  /// Help resources menu item description
  ///
  /// In de, this message translates to:
  /// **'Informationen und Links zu professioneller Unterstützung'**
  String get moreHelpResourcesDescription;

  /// Games menu item
  ///
  /// In de, this message translates to:
  /// **'Spiele & Entspannung'**
  String get moreGames;

  /// Games menu item description
  ///
  /// In de, this message translates to:
  /// **'Atemübungen, Memory und mehr zur Ablenkung'**
  String get moreGamesDescription;

  /// Settings menu item
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get moreSettings;

  /// Settings menu item description
  ///
  /// In de, this message translates to:
  /// **'App-Konfiguration und Datenschutz'**
  String get moreSettingsDescription;

  /// Permissions manager screen title
  ///
  /// In de, this message translates to:
  /// **'Rechte & Berechtigungen'**
  String get permissionsTitle;

  /// No profiles available message
  ///
  /// In de, this message translates to:
  /// **'Keine Profile vorhanden'**
  String get permissionsNoProfiles;

  /// Permissions info text
  ///
  /// In de, this message translates to:
  /// **'Hier kannst du Berechtigungen für jedes Profil verwalten. Tippe auf ein Profil um Details zu sehen.'**
  String get permissionsInfoText;

  /// All rights admin label
  ///
  /// In de, this message translates to:
  /// **'Alle Rechte (Administrator)'**
  String get permissionsAllRightsAdmin;

  /// Permission count label
  ///
  /// In de, this message translates to:
  /// **'{count} Berechtigungen'**
  String permissionsCount(int count);

  /// Admin badge label
  ///
  /// In de, this message translates to:
  /// **'Admin'**
  String get permissionsAdminBadge;

  /// Administrator label
  ///
  /// In de, this message translates to:
  /// **'Administrator'**
  String get permissionsAdministrator;

  /// Permission detail screen title
  ///
  /// In de, this message translates to:
  /// **'Berechtigungen: {name}'**
  String permissionsDetailTitle(String name);

  /// Permission change error message
  ///
  /// In de, this message translates to:
  /// **'Berechtigung konnte nicht geändert werden'**
  String get permissionsChangeError;

  /// Make admin dialog title
  ///
  /// In de, this message translates to:
  /// **'Administrator ernennen'**
  String get permissionsMakeAdminTitle;

  /// Make admin confirmation message
  ///
  /// In de, this message translates to:
  /// **'{name} wird zum Administrator mit allen Rechten. Fortfahren?'**
  String permissionsMakeAdminMessage(String name);

  /// Make admin button label
  ///
  /// In de, this message translates to:
  /// **'Zum Administrator machen'**
  String get permissionsMakeAdminButton;

  /// Make admin subtitle
  ///
  /// In de, this message translates to:
  /// **'Gibt alle Rechte'**
  String get permissionsMakeAdminSubtitle;

  /// Revoke admin dialog title
  ///
  /// In de, this message translates to:
  /// **'Administrator-Status entfernen'**
  String get permissionsRevokeAdminTitle;

  /// Revoke admin confirmation message
  ///
  /// In de, this message translates to:
  /// **'{name} verliert alle Admin-Rechte und bekommt Standard-Berechtigungen. Fortfahren?'**
  String permissionsRevokeAdminMessage(String name);

  /// Revoke admin subtitle
  ///
  /// In de, this message translates to:
  /// **'Setzt auf Standard-Rechte zurück'**
  String get permissionsRevokeAdminSubtitle;

  /// Revoke admin error message
  ///
  /// In de, this message translates to:
  /// **'Admin-Status konnte nicht entfernt werden. Das erste Profil muss Administrator bleiben.'**
  String get permissionsRevokeAdminError;

  /// Active permissions count
  ///
  /// In de, this message translates to:
  /// **'{active} / {total} aktiv'**
  String permissionsActiveCount(int active, int total);

  /// System permissions category
  ///
  /// In de, this message translates to:
  /// **'System-Berechtigungen'**
  String get permissionsCategorySystem;

  /// Chat permissions category
  ///
  /// In de, this message translates to:
  /// **'Chat'**
  String get permissionsCategoryChat;

  /// Calendar permissions category
  ///
  /// In de, this message translates to:
  /// **'Kalender'**
  String get permissionsCategoryCalendar;

  /// Medication permissions category
  ///
  /// In de, this message translates to:
  /// **'Medikamente'**
  String get permissionsCategoryMedication;

  /// Contacts permissions category
  ///
  /// In de, this message translates to:
  /// **'Kontakte'**
  String get permissionsCategoryContacts;

  /// Finder permissions category
  ///
  /// In de, this message translates to:
  /// **'Finder (Orte & Gegenstände)'**
  String get permissionsCategoryFinder;

  /// Diary permissions category
  ///
  /// In de, this message translates to:
  /// **'Tagebuch'**
  String get permissionsCategoryDiary;

  /// Emergency permissions category
  ///
  /// In de, this message translates to:
  /// **'Notfallkontakte'**
  String get permissionsCategoryEmergency;

  /// Security permissions category
  ///
  /// In de, this message translates to:
  /// **'Sicherheit'**
  String get permissionsCategorySecurity;

  /// Profile age in years
  ///
  /// In de, this message translates to:
  /// **'{age} Jahre'**
  String profileAgeYears(int age);

  /// Title of the grounding area
  ///
  /// In de, this message translates to:
  /// **'Halt'**
  String get groundingTitle;

  /// Header above the exercise tiles
  ///
  /// In de, this message translates to:
  /// **'Oder such dir etwas aus'**
  String get groundingChooseLabel;

  /// Repeat the same exercise
  ///
  /// In de, this message translates to:
  /// **'Nochmal'**
  String get groundingDoneAgain;

  /// Go back and pick a different exercise
  ///
  /// In de, this message translates to:
  /// **'Was anderes'**
  String get groundingDoneOther;

  /// Escalate to emergency contacts or hotlines
  ///
  /// In de, this message translates to:
  /// **'Jemanden anrufen'**
  String get groundingDoneCall;

  /// No description provided for @groundingOrientationTitle.
  ///
  /// In de, this message translates to:
  /// **'Hier und Jetzt'**
  String get groundingOrientationTitle;

  /// No description provided for @groundingOrientationStep1.
  ///
  /// In de, this message translates to:
  /// **'Heute ist'**
  String get groundingOrientationStep1;

  /// No description provided for @groundingOrientationStep2.
  ///
  /// In de, this message translates to:
  /// **'Schau dich um. Wo bist du gerade?'**
  String get groundingOrientationStep2;

  /// No description provided for @groundingOrientationStep3.
  ///
  /// In de, this message translates to:
  /// **'Sag laut oder leise, wer du bist.'**
  String get groundingOrientationStep3;

  /// No description provided for @groundingOrientationStep4.
  ///
  /// In de, this message translates to:
  /// **'Der Körper von heute ist nicht der von damals.'**
  String get groundingOrientationStep4;

  /// No description provided for @groundingOrientationStep5.
  ///
  /// In de, this message translates to:
  /// **'Was du erinnerst, ist vorbei.'**
  String get groundingOrientationStep5;

  /// No description provided for @groundingOrientationStep6.
  ///
  /// In de, this message translates to:
  /// **'Du bist hier.'**
  String get groundingOrientationStep6;

  /// No description provided for @groundingSensesTitle.
  ///
  /// In de, this message translates to:
  /// **'Sehen, hören, spüren'**
  String get groundingSensesTitle;

  /// No description provided for @groundingSensesStep1.
  ///
  /// In de, this message translates to:
  /// **'Fünf Dinge, die du siehst.'**
  String get groundingSensesStep1;

  /// No description provided for @groundingSensesStep2.
  ///
  /// In de, this message translates to:
  /// **'Vier Dinge, die du hörst.'**
  String get groundingSensesStep2;

  /// No description provided for @groundingSensesStep3.
  ///
  /// In de, this message translates to:
  /// **'Drei Dinge, die du anfassen kannst.'**
  String get groundingSensesStep3;

  /// No description provided for @groundingSensesStep4.
  ///
  /// In de, this message translates to:
  /// **'Zwei Dinge, die du riechst.'**
  String get groundingSensesStep4;

  /// No description provided for @groundingSensesStep5.
  ///
  /// In de, this message translates to:
  /// **'Eine Sache, die du schmeckst.'**
  String get groundingSensesStep5;

  /// No description provided for @groundingSensesStep6.
  ///
  /// In de, this message translates to:
  /// **'Du bist hier.'**
  String get groundingSensesStep6;

  /// No description provided for @groundingBodyTitle.
  ///
  /// In de, this message translates to:
  /// **'Körper spüren'**
  String get groundingBodyTitle;

  /// No description provided for @groundingBodyStep1.
  ///
  /// In de, this message translates to:
  /// **'Stell beide Füße flach auf den Boden.'**
  String get groundingBodyStep1;

  /// No description provided for @groundingBodyStep2.
  ///
  /// In de, this message translates to:
  /// **'Drück die Fersen nach unten.'**
  String get groundingBodyStep2;

  /// No description provided for @groundingBodyStep3.
  ///
  /// In de, this message translates to:
  /// **'Nimm etwas Kaltes in die Hand.'**
  String get groundingBodyStep3;

  /// No description provided for @groundingBodyStep4.
  ///
  /// In de, this message translates to:
  /// **'Halt es fest, solange du magst.'**
  String get groundingBodyStep4;

  /// No description provided for @groundingBodyStep5.
  ///
  /// In de, this message translates to:
  /// **'Spür deinen Rücken an der Lehne.'**
  String get groundingBodyStep5;

  /// No description provided for @groundingBodyStep6.
  ///
  /// In de, this message translates to:
  /// **'Der Boden trägt dich.'**
  String get groundingBodyStep6;

  /// No description provided for @groundingContainerTitle.
  ///
  /// In de, this message translates to:
  /// **'Wegschließen'**
  String get groundingContainerTitle;

  /// No description provided for @groundingContainerStep1.
  ///
  /// In de, this message translates to:
  /// **'Stell dir einen Behälter vor. So groß, wie du willst.'**
  String get groundingContainerStep1;

  /// No description provided for @groundingContainerStep2.
  ///
  /// In de, this message translates to:
  /// **'Er hat einen Deckel, der fest schließt.'**
  String get groundingContainerStep2;

  /// No description provided for @groundingContainerStep3.
  ///
  /// In de, this message translates to:
  /// **'Leg hinein, was gerade zu viel ist.'**
  String get groundingContainerStep3;

  /// No description provided for @groundingContainerStep4.
  ///
  /// In de, this message translates to:
  /// **'Mach den Deckel zu.'**
  String get groundingContainerStep4;

  /// No description provided for @groundingContainerStep5.
  ///
  /// In de, this message translates to:
  /// **'Stell ihn an einen Ort, den du bestimmst.'**
  String get groundingContainerStep5;

  /// No description provided for @groundingContainerStep6.
  ///
  /// In de, this message translates to:
  /// **'Du kannst ihn wieder öffnen. Nicht jetzt.'**
  String get groundingContainerStep6;

  /// No description provided for @groundingBreathTitle.
  ///
  /// In de, this message translates to:
  /// **'Atem'**
  String get groundingBreathTitle;

  /// No description provided for @groundingBreathStep1.
  ///
  /// In de, this message translates to:
  /// **'Atme ein und zähl bis vier.'**
  String get groundingBreathStep1;

  /// No description provided for @groundingBreathStep2.
  ///
  /// In de, this message translates to:
  /// **'Halt kurz.'**
  String get groundingBreathStep2;

  /// No description provided for @groundingBreathStep3.
  ///
  /// In de, this message translates to:
  /// **'Atme aus und zähl bis sechs.'**
  String get groundingBreathStep3;

  /// No description provided for @groundingBreathStep4.
  ///
  /// In de, this message translates to:
  /// **'Nochmal. Ohne Eile.'**
  String get groundingBreathStep4;

  /// No description provided for @groundingBreathStep5.
  ///
  /// In de, this message translates to:
  /// **'Langsamer raus als rein. Das reicht.'**
  String get groundingBreathStep5;

  /// No description provided for @medicationNameLabel.
  ///
  /// In de, this message translates to:
  /// **'Medikamenten-Name'**
  String get medicationNameLabel;

  /// No description provided for @medicationDosageLabel.
  ///
  /// In de, this message translates to:
  /// **'Dosierung'**
  String get medicationDosageLabel;

  /// No description provided for @medicationDosageHint.
  ///
  /// In de, this message translates to:
  /// **'z.B. 1 Tablette, 10mg, 5ml'**
  String get medicationDosageHint;

  /// No description provided for @medicationNameRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte Namen eingeben'**
  String get medicationNameRequired;

  /// No description provided for @medicationDosageRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte Dosierung eingeben'**
  String get medicationDosageRequired;

  /// No description provided for @medicationTypeQuestion.
  ///
  /// In de, this message translates to:
  /// **'Was für ein Medikament?'**
  String get medicationTypeQuestion;

  /// No description provided for @medicationTypeDailyTitle.
  ///
  /// In de, this message translates to:
  /// **'Tagesmedizin'**
  String get medicationTypeDailyTitle;

  /// No description provided for @medicationTypeDailyExplanation.
  ///
  /// In de, this message translates to:
  /// **'Zu festen Zeiten, jeden Tag'**
  String get medicationTypeDailyExplanation;

  /// No description provided for @medicationTypeAsNeededTitle.
  ///
  /// In de, this message translates to:
  /// **'Bedarfsmedizin'**
  String get medicationTypeAsNeededTitle;

  /// No description provided for @medicationTypeAsNeededExplanation.
  ///
  /// In de, this message translates to:
  /// **'Nur wenn du sie brauchst'**
  String get medicationTypeAsNeededExplanation;

  /// No description provided for @medicationWhenToTake.
  ///
  /// In de, this message translates to:
  /// **'Wann nehmen?'**
  String get medicationWhenToTake;

  /// No description provided for @medicationSectionMorning.
  ///
  /// In de, this message translates to:
  /// **'Morgens'**
  String get medicationSectionMorning;

  /// No description provided for @medicationSectionMidday.
  ///
  /// In de, this message translates to:
  /// **'Mittags'**
  String get medicationSectionMidday;

  /// No description provided for @medicationSectionEvening.
  ///
  /// In de, this message translates to:
  /// **'Abends'**
  String get medicationSectionEvening;

  /// No description provided for @medicationSectionNight.
  ///
  /// In de, this message translates to:
  /// **'Nachts'**
  String get medicationSectionNight;

  /// No description provided for @medicationOtherTime.
  ///
  /// In de, this message translates to:
  /// **'Andere Zeit'**
  String get medicationOtherTime;

  /// No description provided for @medicationSectionNotChosen.
  ///
  /// In de, this message translates to:
  /// **'nicht ausgewählt'**
  String get medicationSectionNotChosen;

  /// No description provided for @medicationTimeRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte mindestens eine Einnahmezeit hinzufügen'**
  String get medicationTimeRequired;

  /// No description provided for @medicationAsNeededSettings.
  ///
  /// In de, this message translates to:
  /// **'Bedarfsmedizin-Einstellungen'**
  String get medicationAsNeededSettings;

  /// No description provided for @medicationMaxDosesLabel.
  ///
  /// In de, this message translates to:
  /// **'Maximale Anzahl pro Tag *'**
  String get medicationMaxDosesLabel;

  /// No description provided for @medicationMaxDosesHint.
  ///
  /// In de, this message translates to:
  /// **'z.B. 3'**
  String get medicationMaxDosesHint;

  /// No description provided for @medicationMaxDosesHelper.
  ///
  /// In de, this message translates to:
  /// **'Wie oft darf das Medikament pro Tag genommen werden?'**
  String get medicationMaxDosesHelper;

  /// No description provided for @medicationMaxDosesRequired.
  ///
  /// In de, this message translates to:
  /// **'Pflichtfeld für Bedarfsmedizin'**
  String get medicationMaxDosesRequired;

  /// No description provided for @medicationMaxDosesInvalid.
  ///
  /// In de, this message translates to:
  /// **'Bitte gültige Zahl > 0 eingeben'**
  String get medicationMaxDosesInvalid;

  /// No description provided for @medicationMaxDosesMissing.
  ///
  /// In de, this message translates to:
  /// **'Bitte maximale Anzahl pro Tag angeben'**
  String get medicationMaxDosesMissing;

  /// No description provided for @medicationMinIntervalLabel.
  ///
  /// In de, this message translates to:
  /// **'Mindestabstand in Stunden (optional)'**
  String get medicationMinIntervalLabel;

  /// No description provided for @medicationMinIntervalHint.
  ///
  /// In de, this message translates to:
  /// **'z.B. 4'**
  String get medicationMinIntervalHint;

  /// No description provided for @medicationMinIntervalHelper.
  ///
  /// In de, this message translates to:
  /// **'Mindestzeit zwischen zwei Einnahmen'**
  String get medicationMinIntervalHelper;

  /// No description provided for @medicationMinIntervalInvalid.
  ///
  /// In de, this message translates to:
  /// **'Bitte gültige Zahl >= 0 eingeben'**
  String get medicationMinIntervalInvalid;

  /// No description provided for @medicationRemindersTitle.
  ///
  /// In de, this message translates to:
  /// **'Aurora erinnert dich'**
  String get medicationRemindersTitle;

  /// No description provided for @medicationRemindersOff.
  ///
  /// In de, this message translates to:
  /// **'Aurora sagt nichts. Das Medikament steht weiter in deiner Liste, du entscheidest selbst, wann du nachsiehst.'**
  String get medicationRemindersOff;

  /// No description provided for @medicationRemindersDaily.
  ///
  /// In de, this message translates to:
  /// **'Zu jeder Einnahmezeit meldet sich Aurora dreimal: 30 Minuten vorher, 10 Minuten vorher und zur Zeit selbst. Wenn du nicht reagierst, noch einmal 10 Minuten später.'**
  String get medicationRemindersDaily;

  /// No description provided for @medicationRemindersNoInterval.
  ///
  /// In de, this message translates to:
  /// **'Ohne Mindestabstand gibt es keinen Zeitpunkt, auf den Aurora warten könnte. Trag unten einen Abstand ein, wenn du erinnert werden willst, sobald die nächste Dosis erlaubt ist.'**
  String get medicationRemindersNoInterval;

  /// No description provided for @medicationRemindersAsNeeded.
  ///
  /// In de, this message translates to:
  /// **'Nach einer Einnahme sagt Aurora Bescheid, sobald die nächste Dosis erlaubt ist — und kündigt sie 30, 10 und 5 Minuten vorher an.'**
  String get medicationRemindersAsNeeded;

  /// No description provided for @medicationPeriodTitle.
  ///
  /// In de, this message translates to:
  /// **'Zeitraum (optional)'**
  String get medicationPeriodTitle;

  /// No description provided for @medicationStartDate.
  ///
  /// In de, this message translates to:
  /// **'Startdatum'**
  String get medicationStartDate;

  /// No description provided for @medicationEndDate.
  ///
  /// In de, this message translates to:
  /// **'Enddatum'**
  String get medicationEndDate;

  /// No description provided for @medicationNotesLabel.
  ///
  /// In de, this message translates to:
  /// **'Notizen (optional)'**
  String get medicationNotesLabel;

  /// No description provided for @medicationNotesHint.
  ///
  /// In de, this message translates to:
  /// **'z.B. Mit Essen einnehmen'**
  String get medicationNotesHint;

  /// No description provided for @medicationDescriptionLabel.
  ///
  /// In de, this message translates to:
  /// **'Detaillierte Beschreibung (optional)'**
  String get medicationDescriptionLabel;

  /// No description provided for @medicationDescriptionHint.
  ///
  /// In de, this message translates to:
  /// **'Hilft bei der Unterscheidung ähnlicher Medikamente'**
  String get medicationDescriptionHint;

  /// No description provided for @medicationPhotoTitle.
  ///
  /// In de, this message translates to:
  /// **'Tabletten-Foto (optional)'**
  String get medicationPhotoTitle;

  /// No description provided for @medicationPhotoHint.
  ///
  /// In de, this message translates to:
  /// **'Foto hilft bei der Identifikation und vermeidet Verwechslungen'**
  String get medicationPhotoHint;

  /// No description provided for @medicationPhotoTake.
  ///
  /// In de, this message translates to:
  /// **'Foto aufnehmen'**
  String get medicationPhotoTake;

  /// No description provided for @medicationPhotoRetake.
  ///
  /// In de, this message translates to:
  /// **'Neu aufnehmen'**
  String get medicationPhotoRetake;

  /// No description provided for @medicationPhotoError.
  ///
  /// In de, this message translates to:
  /// **'Foto konnte nicht geladen werden: {error}'**
  String medicationPhotoError(String error);

  /// No description provided for @medicationActiveTitle.
  ///
  /// In de, this message translates to:
  /// **'Aktiv'**
  String get medicationActiveTitle;

  /// No description provided for @medicationActiveOn.
  ///
  /// In de, this message translates to:
  /// **'Medikament wird in Tagesliste angezeigt'**
  String get medicationActiveOn;

  /// No description provided for @medicationActiveOff.
  ///
  /// In de, this message translates to:
  /// **'Medikament ist archiviert'**
  String get medicationActiveOff;

  /// No description provided for @medicationDeleteTitle.
  ///
  /// In de, this message translates to:
  /// **'Medikament löschen?'**
  String get medicationDeleteTitle;

  /// No description provided for @medicationDeleteMessage.
  ///
  /// In de, this message translates to:
  /// **'Möchtest du dieses Medikament wirklich löschen?'**
  String get medicationDeleteMessage;

  /// No description provided for @medicationDeleteConfirmMessage.
  ///
  /// In de, this message translates to:
  /// **'Dieses Medikament wird dauerhaft gelöscht.'**
  String get medicationDeleteConfirmMessage;

  /// No description provided for @medicationDeleted.
  ///
  /// In de, this message translates to:
  /// **'Medikament gelöscht'**
  String get medicationDeleted;

  /// No description provided for @medicationIntakeTimesLabel.
  ///
  /// In de, this message translates to:
  /// **'Einnahmezeiten'**
  String get medicationIntakeTimesLabel;

  /// No description provided for @medicationMaxDailyLabel.
  ///
  /// In de, this message translates to:
  /// **'Max. Tagesdosis'**
  String get medicationMaxDailyLabel;

  /// No description provided for @medicationMinGapLabel.
  ///
  /// In de, this message translates to:
  /// **'Min. Abstand'**
  String get medicationMinGapLabel;

  /// No description provided for @medicationStatusLabel.
  ///
  /// In de, this message translates to:
  /// **'Status'**
  String get medicationStatusLabel;

  /// No description provided for @medicationStatusTaken.
  ///
  /// In de, this message translates to:
  /// **'Genommen'**
  String get medicationStatusTaken;

  /// No description provided for @medicationStatusRefused.
  ///
  /// In de, this message translates to:
  /// **'Verweigert'**
  String get medicationStatusRefused;

  /// No description provided for @medicationStatusSnoozed.
  ///
  /// In de, this message translates to:
  /// **'Später'**
  String get medicationStatusSnoozed;

  /// No description provided for @medicationTake.
  ///
  /// In de, this message translates to:
  /// **'Nehmen'**
  String get medicationTake;

  /// No description provided for @medicationTakeAnyway.
  ///
  /// In de, this message translates to:
  /// **'Trotzdem nehmen'**
  String get medicationTakeAnyway;

  /// No description provided for @medicationDailyLimitReached.
  ///
  /// In de, this message translates to:
  /// **'Tageslimit erreicht'**
  String get medicationDailyLimitReached;

  /// No description provided for @medicationAddFeedback.
  ///
  /// In de, this message translates to:
  /// **'Feedback hinzufügen'**
  String get medicationAddFeedback;

  /// No description provided for @medicationFeedbackYourExperience.
  ///
  /// In de, this message translates to:
  /// **'Deine Erfahrung'**
  String get medicationFeedbackYourExperience;

  /// No description provided for @medicationRefusalTitle.
  ///
  /// In de, this message translates to:
  /// **'Verweigerung dokumentieren'**
  String get medicationRefusalTitle;

  /// No description provided for @medicationIntakesLabel.
  ///
  /// In de, this message translates to:
  /// **'Einnahmen'**
  String get medicationIntakesLabel;

  /// No description provided for @medicationNoProfileSelected.
  ///
  /// In de, this message translates to:
  /// **'Kein Profil ausgewählt'**
  String get medicationNoProfileSelected;

  /// No description provided for @medicationNoLogPermission.
  ///
  /// In de, this message translates to:
  /// **'Keine Berechtigung zur Einnahmeprotokollierung'**
  String get medicationNoLogPermission;

  /// No description provided for @commonGallery.
  ///
  /// In de, this message translates to:
  /// **'Galerie'**
  String get commonGallery;

  /// No description provided for @commonCamera.
  ///
  /// In de, this message translates to:
  /// **'Kamera'**
  String get commonCamera;

  /// No description provided for @medicationStatusSkipped.
  ///
  /// In de, this message translates to:
  /// **'Übersprungen'**
  String get medicationStatusSkipped;

  /// No description provided for @medicationWillBeRefused.
  ///
  /// In de, this message translates to:
  /// **'{name} wird als verweigert markiert.'**
  String medicationWillBeRefused(String name);

  /// No description provided for @clockTime.
  ///
  /// In de, this message translates to:
  /// **'{time} Uhr'**
  String clockTime(String time);

  /// No description provided for @medicationReminderAtTime.
  ///
  /// In de, this message translates to:
  /// **'Erinnerung um {time}'**
  String medicationReminderAtTime(String time);

  /// No description provided for @medicationSnoozedUntil.
  ///
  /// In de, this message translates to:
  /// **'{name} — Erinnerung um {time} Uhr'**
  String medicationSnoozedUntil(String name, String time);

  /// No description provided for @medicationAtTime.
  ///
  /// In de, this message translates to:
  /// **'{time} Uhr'**
  String medicationAtTime(String time);

  /// No description provided for @medicationDoseCountToday.
  ///
  /// In de, this message translates to:
  /// **'Verfügbar: {available} von {max} heute'**
  String medicationDoseCountToday(int available, int max);

  /// No description provided for @medicationLastTaken.
  ///
  /// In de, this message translates to:
  /// **'Letzte Einnahme: {time}'**
  String medicationLastTaken(String time);

  /// No description provided for @medicationNextPossible.
  ///
  /// In de, this message translates to:
  /// **'Nächste Einnahme möglich um {time} Uhr'**
  String medicationNextPossible(String time);

  /// No description provided for @medicationNoteLabel.
  ///
  /// In de, this message translates to:
  /// **'Notiz: {note}'**
  String medicationNoteLabel(String note);

  /// No description provided for @medicationLimitWarning.
  ///
  /// In de, this message translates to:
  /// **'Du hast heute bereits {count} Dosen von {name} genommen. Das ist das Tageslimit.'**
  String medicationLimitWarning(int count, String name);

  /// No description provided for @medicationTakenConfirmation.
  ///
  /// In de, this message translates to:
  /// **'{name} eingenommen'**
  String medicationTakenConfirmation(String name);

  /// No description provided for @anchorTitle.
  ///
  /// In de, this message translates to:
  /// **'Anker'**
  String get anchorTitle;

  /// No description provided for @anchorSectionWhenHard.
  ///
  /// In de, this message translates to:
  /// **'Wenn es schwer ist'**
  String get anchorSectionWhenHard;

  /// No description provided for @anchorSectionEveryday.
  ///
  /// In de, this message translates to:
  /// **'Alltag'**
  String get anchorSectionEveryday;

  /// No description provided for @anchorSectionWhenCalm.
  ///
  /// In de, this message translates to:
  /// **'Wenn Ruhe ist'**
  String get anchorSectionWhenCalm;

  /// No description provided for @fabMedication.
  ///
  /// In de, this message translates to:
  /// **'Medikament'**
  String get fabMedication;

  /// No description provided for @fabDiaryEntry.
  ///
  /// In de, this message translates to:
  /// **'Eintrag'**
  String get fabDiaryEntry;

  /// No description provided for @fabContact.
  ///
  /// In de, this message translates to:
  /// **'Kontakt'**
  String get fabContact;

  /// No description provided for @appQuitTitle.
  ///
  /// In de, this message translates to:
  /// **'App beenden?'**
  String get appQuitTitle;

  /// No description provided for @appQuitMessage.
  ///
  /// In de, this message translates to:
  /// **'Möchtest du Aurora wirklich beenden?'**
  String get appQuitMessage;

  /// No description provided for @emergencyResetTitle.
  ///
  /// In de, this message translates to:
  /// **'Notfall-Reset'**
  String get emergencyResetTitle;

  /// No description provided for @emergencyResetWarning.
  ///
  /// In de, this message translates to:
  /// **'WARNUNG: Alle Daten werden unwiderruflich gelöscht!\n\nProfile, Nachrichten, Termine, Medikamente, Kontakte — alles.\n\nDieser Schritt kann nicht rückgängig gemacht werden.'**
  String get emergencyResetWarning;

  /// No description provided for @emergencyResetConfirm.
  ///
  /// In de, this message translates to:
  /// **'ALLES LÖSCHEN'**
  String get emergencyResetConfirm;

  /// No description provided for @pwResetCancelledTitle.
  ///
  /// In de, this message translates to:
  /// **'Zurücksetzen abgebrochen'**
  String get pwResetCancelledTitle;

  /// No description provided for @pwResetCancelledMessage.
  ///
  /// In de, this message translates to:
  /// **'Der laufende Passwort-Reset wurde mit dem alten Passwort abgebrochen. Dein Profil ist jetzt aktiv.'**
  String get pwResetCancelledMessage;

  /// No description provided for @pwResetUnderstood.
  ///
  /// In de, this message translates to:
  /// **'Verstanden'**
  String get pwResetUnderstood;

  /// No description provided for @pwResetNowActiveTitle.
  ///
  /// In de, this message translates to:
  /// **'Neues Passwort aktiv'**
  String get pwResetNowActiveTitle;

  /// No description provided for @pwResetNowActiveMessage.
  ///
  /// In de, this message translates to:
  /// **'Das neue Passwort wurde nach Ablauf der Wartezeit automatisch aktiviert. Dein Profil ist jetzt aktiv.'**
  String get pwResetNowActiveMessage;

  /// No description provided for @pwResetTitle.
  ///
  /// In de, this message translates to:
  /// **'Passwort zurücksetzen'**
  String get pwResetTitle;

  /// No description provided for @pwResetAnswerQuestions.
  ///
  /// In de, this message translates to:
  /// **'Beantworte die Sicherheitsfragen für sofortigen Reset'**
  String get pwResetAnswerQuestions;

  /// No description provided for @pwResetAnswerN.
  ///
  /// In de, this message translates to:
  /// **'Antwort {number}'**
  String pwResetAnswerN(int number);

  /// No description provided for @pwResetForgotAnswers.
  ///
  /// In de, this message translates to:
  /// **'Antworten vergessen?\n24-Stunden Timer starten'**
  String get pwResetForgotAnswers;

  /// No description provided for @pwResetAnswerAll.
  ///
  /// In de, this message translates to:
  /// **'Bitte alle Fragen beantworten'**
  String get pwResetAnswerAll;

  /// No description provided for @pwResetAnswersWrong.
  ///
  /// In de, this message translates to:
  /// **'Antworten sind nicht korrekt.\n\nDu kannst es nochmal versuchen oder den 24h-Timer starten.'**
  String get pwResetAnswersWrong;

  /// No description provided for @pwResetCheckAnswers.
  ///
  /// In de, this message translates to:
  /// **'Antworten prüfen'**
  String get pwResetCheckAnswers;

  /// No description provided for @pwResetSetNewTitle.
  ///
  /// In de, this message translates to:
  /// **'Neues Passwort setzen'**
  String get pwResetSetNewTitle;

  /// No description provided for @pwResetAnswersCorrect.
  ///
  /// In de, this message translates to:
  /// **'Sicherheitsfragen korrekt beantwortet!'**
  String get pwResetAnswersCorrect;

  /// No description provided for @pwResetImmediateHint.
  ///
  /// In de, this message translates to:
  /// **'Gib dein neues Passwort ein. Es wird sofort aktiviert.'**
  String get pwResetImmediateHint;

  /// No description provided for @pwResetNewPassword.
  ///
  /// In de, this message translates to:
  /// **'Neues Passwort'**
  String get pwResetNewPassword;

  /// No description provided for @pwResetConfirmPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort bestätigen'**
  String get pwResetConfirmPassword;

  /// No description provided for @pwResetTooShort.
  ///
  /// In de, this message translates to:
  /// **'Passwort muss mindestens 4 Zeichen lang sein'**
  String get pwResetTooShort;

  /// No description provided for @pwResetMismatch.
  ///
  /// In de, this message translates to:
  /// **'Passwörter stimmen nicht überein'**
  String get pwResetMismatch;

  /// No description provided for @pwResetChanged.
  ///
  /// In de, this message translates to:
  /// **'Passwort erfolgreich geändert!\n\nDu kannst dich jetzt mit dem neuen Passwort anmelden.'**
  String get pwResetChanged;

  /// No description provided for @pwResetSetPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort setzen'**
  String get pwResetSetPassword;

  /// No description provided for @pwResetTimerHint.
  ///
  /// In de, this message translates to:
  /// **'Gib dein neues Passwort ein.\n\nNach dem Start läuft ein 24-Stunden Timer, danach kannst du das neue Passwort aktivieren.'**
  String get pwResetTimerHint;

  /// No description provided for @pwResetStarted.
  ///
  /// In de, this message translates to:
  /// **'Passwort-Reset gestartet!\n\nDein altes Passwort bleibt aktiv. In {waitTime} kannst du das neue Passwort aktivieren.'**
  String pwResetStarted(String waitTime);

  /// No description provided for @pwResetStartError.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Starten des Passwort-Resets'**
  String get pwResetStartError;

  /// No description provided for @pwResetStart.
  ///
  /// In de, this message translates to:
  /// **'Reset starten'**
  String get pwResetStart;

  /// No description provided for @pwResetRunningTitle.
  ///
  /// In de, this message translates to:
  /// **'Passwort-Reset läuft'**
  String get pwResetRunningTitle;

  /// No description provided for @pwResetWhatsHappening.
  ///
  /// In de, this message translates to:
  /// **'Was passiert gerade?'**
  String get pwResetWhatsHappening;

  /// No description provided for @pwResetRunningExplanation.
  ///
  /// In de, this message translates to:
  /// **'Du hast vor Kurzem ein neues Passwort festgelegt. Aus Sicherheitsgründen läuft jetzt ein 24-Stunden Timer.\n\n'**
  String get pwResetRunningExplanation;

  /// No description provided for @pwResetRemaining.
  ///
  /// In de, this message translates to:
  /// **'Verbleibende Zeit: {time}'**
  String pwResetRemaining(String time);

  /// No description provided for @pwResetReadyTitle.
  ///
  /// In de, this message translates to:
  /// **'Bereit zum Aktivieren'**
  String get pwResetReadyTitle;

  /// No description provided for @pwResetWaitOver.
  ///
  /// In de, this message translates to:
  /// **'Die Wartezeit ist vorbei!'**
  String get pwResetWaitOver;

  /// No description provided for @pwResetReadyExplanation.
  ///
  /// In de, this message translates to:
  /// **'Du hast {startTime} ein neues Passwort festgelegt. Die 24-Stunden Sicherheitsfrist ist nun abgelaufen.'**
  String pwResetReadyExplanation(String startTime);

  /// No description provided for @pwResetIrreversible.
  ///
  /// In de, this message translates to:
  /// **'Wenn du aktivierst, wird dein ALTES Passwort unwiderruflich durch das NEUE Passwort ersetzt.'**
  String get pwResetIrreversible;

  /// No description provided for @pwResetActivated.
  ///
  /// In de, this message translates to:
  /// **'Neues Passwort aktiviert!\n\nDu kannst dich jetzt mit dem neuen Passwort anmelden.'**
  String get pwResetActivated;

  /// No description provided for @pwResetActivateError.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Aktivieren des Passworts'**
  String get pwResetActivateError;

  /// No description provided for @pwResetActivate.
  ///
  /// In de, this message translates to:
  /// **'Neues Passwort aktivieren'**
  String get pwResetActivate;

  /// No description provided for @profileCurrentlyActive.
  ///
  /// In de, this message translates to:
  /// **'Aktuell aktives Profil'**
  String get profileCurrentlyActive;

  /// No description provided for @profilePasswordProtected.
  ///
  /// In de, this message translates to:
  /// **'Dieses Profil ist passwortgeschützt'**
  String get profilePasswordProtected;

  /// No description provided for @profilePasswordLabel.
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get profilePasswordLabel;

  /// No description provided for @settingsMapCacheClearQuestion.
  ///
  /// In de, this message translates to:
  /// **'Möchtest du alle gespeicherten Kartenkacheln löschen?'**
  String get settingsMapCacheClearQuestion;

  /// No description provided for @settingsMapCacheCleared.
  ///
  /// In de, this message translates to:
  /// **'Karten-Cache geleert'**
  String get settingsMapCacheCleared;

  /// No description provided for @settingsMapPredownloadComingSoon.
  ///
  /// In de, this message translates to:
  /// **'Das Vorab-Herunterladen kommt in einer späteren Version'**
  String get settingsMapPredownloadComingSoon;

  /// No description provided for @settingsCacheLimitTitle.
  ///
  /// In de, this message translates to:
  /// **'Cache-Limit festlegen'**
  String get settingsCacheLimitTitle;

  /// No description provided for @settingsCacheLimitValue.
  ///
  /// In de, this message translates to:
  /// **'Maximale Cache-Größe: {size} MB'**
  String settingsCacheLimitValue(int size);

  /// No description provided for @settingsCacheLimitMegabytes.
  ///
  /// In de, this message translates to:
  /// **'{size} MB'**
  String settingsCacheLimitMegabytes(int size);

  /// No description provided for @settingsCacheLimitExplanation.
  ///
  /// In de, this message translates to:
  /// **'Wenn der Cache dieses Limit überschreitet, werden automatisch die ältesten Kacheln gelöscht.'**
  String get settingsCacheLimitExplanation;

  /// No description provided for @settingsAllDataDeleted.
  ///
  /// In de, this message translates to:
  /// **'Alle Daten wurden gelöscht'**
  String get settingsAllDataDeleted;

  /// No description provided for @settingsDeleteIncomplete.
  ///
  /// In de, this message translates to:
  /// **'Es konnte nicht alles gelöscht werden. Bitte noch einmal versuchen.'**
  String get settingsDeleteIncomplete;

  /// No description provided for @settingsTrackingEnableTitle.
  ///
  /// In de, this message translates to:
  /// **'Dauerhaftes Tracking aktivieren?'**
  String get settingsTrackingEnableTitle;

  /// No description provided for @settingsTrackingWhatItDoes.
  ///
  /// In de, this message translates to:
  /// **'Das bewirkt dieser Modus:'**
  String get settingsTrackingWhatItDoes;

  /// No description provided for @settingsDataStaysHere.
  ///
  /// In de, this message translates to:
  /// **'Deine Daten bleiben auf diesem Gerät'**
  String get settingsDataStaysHere;

  /// No description provided for @settingsDataStaysHereExplanation.
  ///
  /// In de, this message translates to:
  /// **'Aurora speichert alle Daten nur lokal.'**
  String get settingsDataStaysHereExplanation;

  /// No description provided for @settingsBackgroundGpsBattery.
  ///
  /// In de, this message translates to:
  /// **'Background-GPS kann den Akku stärker belasten.'**
  String get settingsBackgroundGpsBattery;

  /// No description provided for @settingsAndroidStatus.
  ///
  /// In de, this message translates to:
  /// **'Android-Status:'**
  String get settingsAndroidStatus;

  /// No description provided for @settingsActivate.
  ///
  /// In de, this message translates to:
  /// **'Aktivieren'**
  String get settingsActivate;

  /// No description provided for @settingsDeactivate.
  ///
  /// In de, this message translates to:
  /// **'Deaktivieren'**
  String get settingsDeactivate;

  /// No description provided for @settingsTrackingDisableTitle.
  ///
  /// In de, this message translates to:
  /// **'Dauerhaftes Tracking deaktivieren?'**
  String get settingsTrackingDisableTitle;

  /// No description provided for @settingsTrackingDisableExplanation.
  ///
  /// In de, this message translates to:
  /// **'Das GPS-Tracking wird wieder pro Profil gesteuert.'**
  String get settingsTrackingDisableExplanation;

  /// No description provided for @settingsTestNotificationSent.
  ///
  /// In de, this message translates to:
  /// **'Test-Benachrichtigung gesendet'**
  String get settingsTestNotificationSent;

  /// No description provided for @settingsAndroidSettingNeeded.
  ///
  /// In de, this message translates to:
  /// **'Android-Einstellung erforderlich'**
  String get settingsAndroidSettingNeeded;

  /// No description provided for @settingsPermissionNeededFor.
  ///
  /// In de, this message translates to:
  /// **'Um dauerhaftes Tracking zu nutzen, brauchst du die Berechtigung „{permission}\".'**
  String settingsPermissionNeededFor(String permission);

  /// No description provided for @settingsStepByStep.
  ///
  /// In de, this message translates to:
  /// **'Ich helfe dir Schritt für Schritt:'**
  String get settingsStepByStep;

  /// No description provided for @settingsOpenAndroidSettings.
  ///
  /// In de, this message translates to:
  /// **'Android-Einstellungen öffnen'**
  String get settingsOpenAndroidSettings;

  /// No description provided for @settingsOpenNow.
  ///
  /// In de, this message translates to:
  /// **'Jetzt öffnen'**
  String get settingsOpenNow;

  /// No description provided for @settingsInTheSettings.
  ///
  /// In de, this message translates to:
  /// **'In den Einstellungen'**
  String get settingsInTheSettings;

  /// No description provided for @settingsBackToAurora.
  ///
  /// In de, this message translates to:
  /// **'Zurück zu Aurora\nDie App erkennt die Änderung automatisch.'**
  String get settingsBackToAurora;

  /// No description provided for @settingsUnderstood.
  ///
  /// In de, this message translates to:
  /// **'Verstanden'**
  String get settingsUnderstood;

  /// No description provided for @settingsResetPendingFor.
  ///
  /// In de, this message translates to:
  /// **'Profil: {name}\nVerbleibend: {time}'**
  String settingsResetPendingFor(String name, String time);

  /// No description provided for @settingsWhatIs.
  ///
  /// In de, this message translates to:
  /// **'Was ist „{name}\"?'**
  String settingsWhatIs(String name);

  /// No description provided for @settingsAdminTrackingExplanation.
  ///
  /// In de, this message translates to:
  /// **'Als Admin kannst du das GPS-Tracking für ALLE Profile zentral steuern. Wenn aktiviert:'**
  String get settingsAdminTrackingExplanation;

  /// No description provided for @settingsPrerequisite.
  ///
  /// In de, this message translates to:
  /// **'Voraussetzung: die Android-Berechtigung „{permission}\".'**
  String settingsPrerequisite(String permission);

  /// No description provided for @settingsGpsPermission.
  ///
  /// In de, this message translates to:
  /// **'GPS-Berechtigung'**
  String get settingsGpsPermission;

  /// No description provided for @settingsBackgroundReady.
  ///
  /// In de, this message translates to:
  /// **'Alles bereit für dauerhaftes Tracking.'**
  String get settingsBackgroundReady;

  /// No description provided for @settingsHowToEnable.
  ///
  /// In de, this message translates to:
  /// **'So aktivierst du „{permission}\"'**
  String settingsHowToEnable(String permission);

  /// No description provided for @settingsLocationStaysHere.
  ///
  /// In de, this message translates to:
  /// **'Deine Standortdaten bleiben auf diesem Gerät.'**
  String get settingsLocationStaysHere;

  /// No description provided for @settingsTrackingAlwaysOn.
  ///
  /// In de, this message translates to:
  /// **'Tracking dauerhaft an'**
  String get settingsTrackingAlwaysOn;

  /// No description provided for @settingsHowNotificationsWork.
  ///
  /// In de, this message translates to:
  /// **'Wie funktionieren Benachrichtigungen?'**
  String get settingsHowNotificationsWork;

  /// No description provided for @settingsSendTestNotification.
  ///
  /// In de, this message translates to:
  /// **'Test-Benachrichtigung senden'**
  String get settingsSendTestNotification;

  /// No description provided for @settingsCheckNotificationsWork.
  ///
  /// In de, this message translates to:
  /// **'Prüfe, ob Benachrichtigungen ankommen'**
  String get settingsCheckNotificationsWork;

  /// No description provided for @settingsQueue.
  ///
  /// In de, this message translates to:
  /// **'Warteschlange'**
  String get settingsQueue;

  /// No description provided for @settingsScheduledNotifications.
  ///
  /// In de, this message translates to:
  /// **'Geplante Benachrichtigungen:'**
  String get settingsScheduledNotifications;

  /// No description provided for @settingsNextAt.
  ///
  /// In de, this message translates to:
  /// **'Nächste: {time}'**
  String settingsNextAt(String time);

  /// No description provided for @settingsCacheUsage.
  ///
  /// In de, this message translates to:
  /// **'{used} MB von {limit} MB • {count} Kacheln'**
  String settingsCacheUsage(String used, String limit, String count);

  /// No description provided for @settingsPercent.
  ///
  /// In de, this message translates to:
  /// **'{value}%'**
  String settingsPercent(int value);

  /// No description provided for @settingsCacheLimitLabel.
  ///
  /// In de, this message translates to:
  /// **'Cache-Limit'**
  String get settingsCacheLimitLabel;

  /// No description provided for @settingsPredownloadMaps.
  ///
  /// In de, this message translates to:
  /// **'Karten vorab herunterladen'**
  String get settingsPredownloadMaps;

  /// No description provided for @settingsPredownloadSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Lädt Karten für einen Umkreis herunter'**
  String get settingsPredownloadSubtitle;

  /// No description provided for @settingsClearCache.
  ///
  /// In de, this message translates to:
  /// **'Cache leeren'**
  String get settingsClearCache;

  /// No description provided for @settingsClearCacheSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Alle gespeicherten Kartenkacheln löschen'**
  String get settingsClearCacheSubtitle;

  /// No description provided for @settingsDiscreetRemindersTitle.
  ///
  /// In de, this message translates to:
  /// **'Erinnerungen ohne Inhalt'**
  String get settingsDiscreetRemindersTitle;

  /// No description provided for @settingsDiscreetRemindersOn.
  ///
  /// In de, this message translates to:
  /// **'Auf dem Sperrbildschirm steht nur „Aurora — Erinnerung\". Was gemeint ist, siehst du nach dem Entsperren.'**
  String get settingsDiscreetRemindersOn;

  /// No description provided for @settingsDiscreetRemindersOff.
  ///
  /// In de, this message translates to:
  /// **'Auf dem Sperrbildschirm stehen Name und Dosis beziehungsweise der Termin im Klartext.'**
  String get settingsDiscreetRemindersOff;

  /// No description provided for @settingsWhatAuroraSends.
  ///
  /// In de, this message translates to:
  /// **'Was Aurora sendet'**
  String get settingsWhatAuroraSends;

  /// No description provided for @settingsWhatAuroraSendsSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Jede Übertragung im Wortlaut einsehen'**
  String get settingsWhatAuroraSendsSubtitle;

  /// No description provided for @settingsAlwaysAllow.
  ///
  /// In de, this message translates to:
  /// **'Immer erlauben'**
  String get settingsAlwaysAllow;

  /// No description provided for @settingsAlwaysAllowRequired.
  ///
  /// In de, this message translates to:
  /// **'GPS-Berechtigung „Immer erlauben\" erforderlich'**
  String get settingsAlwaysAllowRequired;

  /// No description provided for @settingsLocalOnly.
  ///
  /// In de, this message translates to:
  /// **'Aurora speichert alle Daten nur lokal. Keine Cloud, keine Server, keine Übertragung.'**
  String get settingsLocalOnly;

  /// No description provided for @settingsTrackingDisableFull.
  ///
  /// In de, this message translates to:
  /// **'Das GPS-Tracking wird wieder pro Profil gesteuert.\n\nJedes Profil kann es dann selbst ein- und ausschalten.'**
  String get settingsTrackingDisableFull;

  /// No description provided for @settingsAlwaysAllowNeeded.
  ///
  /// In de, this message translates to:
  /// **'Um dauerhaftes Tracking zu nutzen, brauchst du die Berechtigung „Immer erlauben\".'**
  String get settingsAlwaysAllowNeeded;

  /// No description provided for @settingsWhatIsAlwaysOn.
  ///
  /// In de, this message translates to:
  /// **'Was ist „Tracking dauerhaft an\"?'**
  String get settingsWhatIsAlwaysOn;

  /// No description provided for @settingsAlwaysAllowPrerequisite.
  ///
  /// In de, this message translates to:
  /// **'Voraussetzung: Die Android-Berechtigung „Immer erlauben\" muss aktiv sein, damit das Tracking auch bei geschlossener App läuft.'**
  String get settingsAlwaysAllowPrerequisite;

  /// No description provided for @settingsHowToEnableAlwaysAllow.
  ///
  /// In de, this message translates to:
  /// **'So aktivierst du „Immer erlauben\":'**
  String get settingsHowToEnableAlwaysAllow;

  /// No description provided for @settingsLocationStaysOffline.
  ///
  /// In de, this message translates to:
  /// **'Deine Standortdaten bleiben auf diesem Gerät. Aurora arbeitet offline, ohne Server-Verbindung.'**
  String get settingsLocationStaysOffline;

  /// No description provided for @settingsCountValue.
  ///
  /// In de, this message translates to:
  /// **'{count}'**
  String settingsCountValue(int count);

  /// No description provided for @settingsTilesCount.
  ///
  /// In de, this message translates to:
  /// **'{used} MB von {limit} MB • {count} Kacheln'**
  String settingsTilesCount(String used, String limit, String count);

  /// No description provided for @settingsMaxStorage.
  ///
  /// In de, this message translates to:
  /// **'{size} MB maximale Speichergröße'**
  String settingsMaxStorage(int size);

  /// No description provided for @errorWithDetail.
  ///
  /// In de, this message translates to:
  /// **'Fehler: {error}'**
  String errorWithDetail(String error);

  /// No description provided for @securityQuestionsFillAll.
  ///
  /// In de, this message translates to:
  /// **'Bitte alle 3 Fragen und Antworten ausfüllen'**
  String get securityQuestionsFillAll;

  /// No description provided for @securityQuestionsSaved.
  ///
  /// In de, this message translates to:
  /// **'Sicherheitsfragen gespeichert!\n\nDu kannst sie jetzt zum Zurücksetzen des Passworts nutzen.'**
  String get securityQuestionsSaved;

  /// No description provided for @securityQuestionsRemoveTitle.
  ///
  /// In de, this message translates to:
  /// **'Sicherheitsfragen entfernen?'**
  String get securityQuestionsRemoveTitle;

  /// No description provided for @securityQuestionsRemoveWarning.
  ///
  /// In de, this message translates to:
  /// **'Wenn du die Sicherheitsfragen entfernst, kannst du dein Passwort nur noch über den 24-Stunden-Timer zurücksetzen.'**
  String get securityQuestionsRemoveWarning;

  /// No description provided for @securityQuestionsRemoved.
  ///
  /// In de, this message translates to:
  /// **'Sicherheitsfragen entfernt'**
  String get securityQuestionsRemoved;

  /// No description provided for @securityQuestionsSetupTitle.
  ///
  /// In de, this message translates to:
  /// **'Sicherheitsfragen einrichten'**
  String get securityQuestionsSetupTitle;

  /// No description provided for @securityQuestionsSetupExplanation.
  ///
  /// In de, this message translates to:
  /// **'Richte 3 Sicherheitsfragen ein, um dein Passwort schnell zurücksetzen zu können.'**
  String get securityQuestionsSetupExplanation;

  /// No description provided for @securityQuestionsChooseWisely.
  ///
  /// In de, this message translates to:
  /// **'Wähle Fragen, deren Antworten du nie vergisst'**
  String get securityQuestionsChooseWisely;

  /// No description provided for @securityQuestionN.
  ///
  /// In de, this message translates to:
  /// **'Frage {number}'**
  String securityQuestionN(int number);

  /// No description provided for @securityAnswerToQuestionN.
  ///
  /// In de, this message translates to:
  /// **'Antwort auf Frage {number}'**
  String securityAnswerToQuestionN(int number);

  /// No description provided for @securityQuestionHint1.
  ///
  /// In de, this message translates to:
  /// **'z.B. Name meines ersten Haustieres?'**
  String get securityQuestionHint1;

  /// No description provided for @securityQuestionHint2.
  ///
  /// In de, this message translates to:
  /// **'z.B. Geburtsort meiner Mutter?'**
  String get securityQuestionHint2;

  /// No description provided for @securityQuestionHint3.
  ///
  /// In de, this message translates to:
  /// **'z.B. Mein Lieblingsfilm als Kind?'**
  String get securityQuestionHint3;

  /// No description provided for @errorReportPreviewTitle.
  ///
  /// In de, this message translates to:
  /// **'Vorschau des Fehlerberichts'**
  String get errorReportPreviewTitle;

  /// No description provided for @errorReportWhatIsSent.
  ///
  /// In de, this message translates to:
  /// **'Diese Angaben werden gesendet:'**
  String get errorReportWhatIsSent;

  /// No description provided for @errorReportContactSection.
  ///
  /// In de, this message translates to:
  /// **'Kontakt (optional)'**
  String get errorReportContactSection;

  /// No description provided for @errorReportContactExplanation.
  ///
  /// In de, this message translates to:
  /// **'Nur wenn du möchtest, dass wir dich bei Rückfragen erreichen können:'**
  String get errorReportContactExplanation;

  /// No description provided for @errorReportEmailLabel.
  ///
  /// In de, this message translates to:
  /// **'E-Mail-Adresse (optional)'**
  String get errorReportEmailLabel;

  /// No description provided for @errorReportNewsletter.
  ///
  /// In de, this message translates to:
  /// **'Für Neuigkeiten anmelden'**
  String get errorReportNewsletter;

  /// No description provided for @errorReportNewsletterSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Erhalte Neuigkeiten zu Aurora, höchstens einmal im Monat'**
  String get errorReportNewsletterSubtitle;

  /// No description provided for @errorReportEmailUseOnly.
  ///
  /// In de, this message translates to:
  /// **'Deine E-Mail-Adresse nutzen wir nur für Rückfragen zu diesem Bericht.'**
  String get errorReportEmailUseOnly;

  /// No description provided for @errorReportCopy.
  ///
  /// In de, this message translates to:
  /// **'Kopieren'**
  String get errorReportCopy;

  /// No description provided for @errorReportCopied.
  ///
  /// In de, this message translates to:
  /// **'Bericht in die Zwischenablage kopiert'**
  String get errorReportCopied;

  /// No description provided for @errorReportAutoGenerated.
  ///
  /// In de, this message translates to:
  /// **'Automatisch erzeugter Bericht ({type}).'**
  String errorReportAutoGenerated(String type);

  /// No description provided for @errorReportQueued.
  ///
  /// In de, this message translates to:
  /// **'Bericht angenommen. Er geht raus, sobald du wieder online bist.'**
  String get errorReportQueued;

  /// No description provided for @errorReportFailed.
  ///
  /// In de, this message translates to:
  /// **'Der Bericht konnte nicht gesendet werden'**
  String get errorReportFailed;

  /// No description provided for @errorReportCopyToClipboard.
  ///
  /// In de, this message translates to:
  /// **'In die Zwischenablage kopieren'**
  String get errorReportCopyToClipboard;

  /// No description provided for @permissionsLevel.
  ///
  /// In de, this message translates to:
  /// **'Stufe {level}'**
  String permissionsLevel(int level);

  /// No description provided for @permissionsSectionExplanation.
  ///
  /// In de, this message translates to:
  /// **'Lege fest, welche Bereiche dieses Profil nutzen kann. Jeder Bereich lässt sich einzeln einstellen:'**
  String get permissionsSectionExplanation;

  /// No description provided for @permissionsChildPreset.
  ///
  /// In de, this message translates to:
  /// **'Kind-Voreinstellung'**
  String get permissionsChildPreset;

  /// No description provided for @permissionsAdultPreset.
  ///
  /// In de, this message translates to:
  /// **'Erwachsenen-Voreinstellung'**
  String get permissionsAdultPreset;

  /// No description provided for @permissionsCategoryEmergencyDiary.
  ///
  /// In de, this message translates to:
  /// **'Notfall-Tagebuch'**
  String get permissionsCategoryEmergencyDiary;

  /// No description provided for @permissionsCategoryHelp.
  ///
  /// In de, this message translates to:
  /// **'Hilfe'**
  String get permissionsCategoryHelp;

  /// No description provided for @permissionsCategoryMantras.
  ///
  /// In de, this message translates to:
  /// **'Mantras'**
  String get permissionsCategoryMantras;

  /// No description provided for @permissionsCategoryGames.
  ///
  /// In de, this message translates to:
  /// **'Spiele'**
  String get permissionsCategoryGames;

  /// No description provided for @permissionsChangeableLater.
  ///
  /// In de, this message translates to:
  /// **'Du kannst die Berechtigungen jederzeit in den Einstellungen ändern'**
  String get permissionsChangeableLater;

  /// No description provided for @errorReportRoute.
  ///
  /// In de, this message translates to:
  /// **'Der Bericht geht direkt an die Entwickler; klappt das nicht, öffnet Aurora deine E-Mail-App. Was gesendet wurde, steht in den Einstellungen unter „Was Aurora sendet\".'**
  String get errorReportRoute;

  /// No description provided for @errorReportEmailPrivacy.
  ///
  /// In de, this message translates to:
  /// **'Deine E-Mail-Adresse nutzen wir nur für Rückfragen zu diesem Bericht und geben sie nicht weiter.'**
  String get errorReportEmailPrivacy;

  /// No description provided for @errorReportAutoBody.
  ///
  /// In de, this message translates to:
  /// **'Automatisch erzeugter Bericht ({type}). Die Einzelheiten stehen in der Gerätediagnose.'**
  String errorReportAutoBody(String type);

  /// No description provided for @errorReportClipboardFallback.
  ///
  /// In de, this message translates to:
  /// **'Der Bericht liegt in der Zwischenablage. Du kannst ihn uns auch per E-Mail an {email} schicken.'**
  String errorReportClipboardFallback(String email);

  /// No description provided for @mapAddressNotFound.
  ///
  /// In de, this message translates to:
  /// **'Adresse nicht gefunden'**
  String get mapAddressNotFound;

  /// No description provided for @mapNeedsInternet.
  ///
  /// In de, this message translates to:
  /// **'Für die Adress-Suche braucht Aurora Internet'**
  String get mapNeedsInternet;

  /// No description provided for @mapDataEnabled.
  ///
  /// In de, this message translates to:
  /// **'Kartendaten aktiviert — die Karte wird geladen'**
  String get mapDataEnabled;

  /// No description provided for @mapTapOrSearch.
  ///
  /// In de, this message translates to:
  /// **'Tippe auf die Karte oder such eine Adresse'**
  String get mapTapOrSearch;

  /// No description provided for @mapAddressLoading.
  ///
  /// In de, this message translates to:
  /// **'Adresse wird geladen…'**
  String get mapAddressLoading;

  /// No description provided for @mapPickTitle.
  ///
  /// In de, this message translates to:
  /// **'Ort eintragen'**
  String get mapPickTitle;

  /// No description provided for @mapTapSearchOrLocate.
  ///
  /// In de, this message translates to:
  /// **'Tippe auf die Karte, such eine Adresse oder nimm deinen Standort'**
  String get mapTapSearchOrLocate;

  /// No description provided for @mapSearchHint.
  ///
  /// In de, this message translates to:
  /// **'Adresse suchen (z.B. Kirchstraße 3, Coswig)'**
  String get mapSearchHint;

  /// No description provided for @mapDataNotLoaded.
  ///
  /// In de, this message translates to:
  /// **'Kartendaten nicht geladen'**
  String get mapDataNotLoaded;

  /// No description provided for @mapEnableToMark.
  ///
  /// In de, this message translates to:
  /// **'Aktiviere die Kartendaten, um Orte auf der Karte zu markieren.'**
  String get mapEnableToMark;

  /// No description provided for @mapDataFromOsm.
  ///
  /// In de, this message translates to:
  /// **'Die Kartendaten kommen von OpenStreetMap.\nDafür braucht Aurora einmalig eine Internetverbindung.'**
  String get mapDataFromOsm;

  /// Name der Vergrößern-Schaltfläche auf der Karte. Wird als Tooltip und von TalkBack angesagt.
  ///
  /// In de, this message translates to:
  /// **'Vergrößern'**
  String get mapZoomIn;

  /// Name der Verkleinern-Schaltfläche auf der Karte.
  ///
  /// In de, this message translates to:
  /// **'Verkleinern'**
  String get mapZoomOut;

  /// Name der Schaltfläche, die die Karte zurück auf den eigenen Standort führt.
  ///
  /// In de, this message translates to:
  /// **'Zu meiner Position'**
  String get mapToMyLocation;

  /// No description provided for @feedbackSheetTitle.
  ///
  /// In de, this message translates to:
  /// **'Kontakt zum Entwickler'**
  String get feedbackSheetTitle;

  /// No description provided for @feedbackSheetIntro.
  ///
  /// In de, this message translates to:
  /// **'Aurora ist in der offenen Beta und lebt von deinen Rückmeldungen.'**
  String get feedbackSheetIntro;

  /// No description provided for @feedbackReplyOnlyIfWanted.
  ///
  /// In de, this message translates to:
  /// **'Nur wenn du eine Antwort möchtest'**
  String get feedbackReplyOnlyIfWanted;

  /// No description provided for @errorOpening.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Öffnen: {error}'**
  String errorOpening(String error);

  /// No description provided for @errorLinkNotOpened.
  ///
  /// In de, this message translates to:
  /// **'Der Link ließ sich nicht öffnen: {url}'**
  String errorLinkNotOpened(String url);

  /// No description provided for @thankYouTitle.
  ///
  /// In de, this message translates to:
  /// **'Vielen Dank!'**
  String get thankYouTitle;

  /// No description provided for @thankYouReportSent.
  ///
  /// In de, this message translates to:
  /// **'Dein Bericht ist angekommen und hilft uns, Aurora besser zu machen.'**
  String get thankYouReportSent;

  /// No description provided for @thankYouReportRecorded.
  ///
  /// In de, this message translates to:
  /// **'Dein Fehlerbericht wurde erfasst'**
  String get thankYouReportRecorded;

  /// No description provided for @thankYouJoinCommunity.
  ///
  /// In de, this message translates to:
  /// **'Komm in die Community'**
  String get thankYouJoinCommunity;

  /// No description provided for @thankYouDiscord.
  ///
  /// In de, this message translates to:
  /// **'Discord-Server'**
  String get thankYouDiscord;

  /// No description provided for @thankYouDiscordSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Tausch dich mit anderen Nutzenden und dem Team aus'**
  String get thankYouDiscordSubtitle;

  /// No description provided for @thankYouMoreContact.
  ///
  /// In de, this message translates to:
  /// **'Weitere Wege zu uns'**
  String get thankYouMoreContact;

  /// No description provided for @thankYouEmailSupport.
  ///
  /// In de, this message translates to:
  /// **'E-Mail-Unterstützung'**
  String get thankYouEmailSupport;

  /// No description provided for @thankYouWhatsNext.
  ///
  /// In de, this message translates to:
  /// **'Wie geht es weiter?'**
  String get thankYouWhatsNext;

  /// No description provided for @thankYouBackToApp.
  ///
  /// In de, this message translates to:
  /// **'Zurück zu Aurora'**
  String get thankYouBackToApp;

  /// No description provided for @transparencyDeleteTitle.
  ///
  /// In de, this message translates to:
  /// **'Eintrag löschen?'**
  String get transparencyDeleteTitle;

  /// No description provided for @transparencyDeleteMessage.
  ///
  /// In de, this message translates to:
  /// **'Der Eintrag verschwindet aus dieser Liste. Was bereits gesendet wurde, kommt dadurch nicht zurück.'**
  String get transparencyDeleteMessage;

  /// No description provided for @transparencyIntro.
  ///
  /// In de, this message translates to:
  /// **'Hier siehst du jede Übertragung, die dein Gerät verlassen hat — im Wortlaut.'**
  String get transparencyIntro;

  /// No description provided for @transparencyNothingSent.
  ///
  /// In de, this message translates to:
  /// **'Es wurde noch nichts gesendet.'**
  String get transparencyNothingSent;

  /// No description provided for @transparencySendUsageData.
  ///
  /// In de, this message translates to:
  /// **'Anonyme Nutzungsdaten senden'**
  String get transparencySendUsageData;

  /// No description provided for @transparencyIrreversible.
  ///
  /// In de, this message translates to:
  /// **'Was bereits gesendet wurde, kann nicht zurückgeholt werden. Es ist unterwegs.'**
  String get transparencyIrreversible;

  /// No description provided for @imagePickerAnimalError.
  ///
  /// In de, this message translates to:
  /// **'Der Tier-Avatar ließ sich nicht auswählen: {error}'**
  String imagePickerAnimalError(String error);

  /// No description provided for @imagePickerCameraNeeded.
  ///
  /// In de, this message translates to:
  /// **'Zum Fotografieren braucht Aurora die Kamera-Berechtigung'**
  String get imagePickerCameraNeeded;

  /// No description provided for @imagePickerGalleryNeeded.
  ///
  /// In de, this message translates to:
  /// **'Zum Auswählen von Bildern braucht Aurora die Galerie-Berechtigung'**
  String get imagePickerGalleryNeeded;

  /// No description provided for @imagePickerAllowInSettings.
  ///
  /// In de, this message translates to:
  /// **'In den Einstellungen erlauben'**
  String get imagePickerAllowInSettings;

  /// No description provided for @imagePickerOpenSettings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen öffnen'**
  String get imagePickerOpenSettings;

  /// No description provided for @imagePickerPickError.
  ///
  /// In de, this message translates to:
  /// **'Das Bild ließ sich nicht auswählen: {error}'**
  String imagePickerPickError(String error);

  /// No description provided for @imagePickerSaveError.
  ///
  /// In de, this message translates to:
  /// **'Das Bild ließ sich nicht speichern: {error}'**
  String imagePickerSaveError(String error);

  /// No description provided for @feedbackThankYouTitle.
  ///
  /// In de, this message translates to:
  /// **'Dein Feedback wurde erfasst'**
  String get feedbackThankYouTitle;

  /// No description provided for @feedbackThankYouMessage.
  ///
  /// In de, this message translates to:
  /// **'Vielen Dank! Dein Feedback hilft uns, Aurora zu verbessern.'**
  String get feedbackThankYouMessage;

  /// No description provided for @feedbackStayInTouch.
  ///
  /// In de, this message translates to:
  /// **'Bleib in Kontakt'**
  String get feedbackStayInTouch;

  /// No description provided for @feedbackAuroraDiscord.
  ///
  /// In de, this message translates to:
  /// **'Aurora auf Discord'**
  String get feedbackAuroraDiscord;

  /// No description provided for @feedbackWebsite.
  ///
  /// In de, this message translates to:
  /// **'Website'**
  String get feedbackWebsite;

  /// No description provided for @feedbackEmail.
  ///
  /// In de, this message translates to:
  /// **'E-Mail'**
  String get feedbackEmail;

  /// No description provided for @crashTitle.
  ///
  /// In de, this message translates to:
  /// **'Etwas ist schiefgelaufen'**
  String get crashTitle;

  /// No description provided for @crashMessage.
  ///
  /// In de, this message translates to:
  /// **'Aurora ist auf einen unerwarteten Fehler gestoßen. Deine Daten sind davon nicht betroffen.'**
  String get crashMessage;

  /// No description provided for @crashTechnicalDetails.
  ///
  /// In de, this message translates to:
  /// **'Technische Einzelheiten'**
  String get crashTechnicalDetails;

  /// No description provided for @crashReport.
  ///
  /// In de, this message translates to:
  /// **'Fehler melden'**
  String get crashReport;

  /// No description provided for @crashRestart.
  ///
  /// In de, this message translates to:
  /// **'App neu starten'**
  String get crashRestart;

  /// No description provided for @crashContinue.
  ///
  /// In de, this message translates to:
  /// **'Trotzdem weitermachen'**
  String get crashContinue;

  /// No description provided for @doodleSendDrawing.
  ///
  /// In de, this message translates to:
  /// **'Zeichnung senden'**
  String get doodleSendDrawing;

  /// No description provided for @doodleSticker.
  ///
  /// In de, this message translates to:
  /// **'Sticker'**
  String get doodleSticker;

  /// No description provided for @doodleStrokeWidth.
  ///
  /// In de, this message translates to:
  /// **'Strichstärke'**
  String get doodleStrokeWidth;

  /// No description provided for @doodleStrokeThin.
  ///
  /// In de, this message translates to:
  /// **'Dünner Strich'**
  String get doodleStrokeThin;

  /// No description provided for @doodleStrokeMedium.
  ///
  /// In de, this message translates to:
  /// **'Mittlerer Strich'**
  String get doodleStrokeMedium;

  /// No description provided for @doodleStrokeThick.
  ///
  /// In de, this message translates to:
  /// **'Dicker Strich'**
  String get doodleStrokeThick;

  /// No description provided for @imagePickerDrawYourself.
  ///
  /// In de, this message translates to:
  /// **'Selbst malen'**
  String get imagePickerDrawYourself;

  /// No description provided for @doodleAvatarTitle.
  ///
  /// In de, this message translates to:
  /// **'Dein Bild malen'**
  String get doodleAvatarTitle;

  /// No description provided for @doodleAvatarDone.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get doodleAvatarDone;

  /// No description provided for @doodleAvatarEmptyHint.
  ///
  /// In de, this message translates to:
  /// **'Erst malen, dann übernehmen'**
  String get doodleAvatarEmptyHint;

  /// No description provided for @permCreateProfilesLabel.
  ///
  /// In de, this message translates to:
  /// **'Anteil anlegen'**
  String get permCreateProfilesLabel;

  /// No description provided for @permCreateProfilesDesc.
  ///
  /// In de, this message translates to:
  /// **'Einen neuen Anteil in Aurora aufnehmen'**
  String get permCreateProfilesDesc;

  /// No description provided for @permDeactivateProfilesLabel.
  ///
  /// In de, this message translates to:
  /// **'Anteil ausblenden'**
  String get permDeactivateProfilesLabel;

  /// No description provided for @permDeactivateProfilesDesc.
  ///
  /// In de, this message translates to:
  /// **'Einen Anteil vorübergehend verbergen – später wieder sichtbar'**
  String get permDeactivateProfilesDesc;

  /// No description provided for @permManagePermissionsLabel.
  ///
  /// In de, this message translates to:
  /// **'Rechte verwalten'**
  String get permManagePermissionsLabel;

  /// No description provided for @permManagePermissionsDesc.
  ///
  /// In de, this message translates to:
  /// **'Bestimmen, was andere Anteile dürfen'**
  String get permManagePermissionsDesc;

  /// No description provided for @permAccessSettingsLabel.
  ///
  /// In de, this message translates to:
  /// **'App-Einstellungen'**
  String get permAccessSettingsLabel;

  /// No description provided for @permAccessSettingsDesc.
  ///
  /// In de, this message translates to:
  /// **'Aurora einrichten und anpassen'**
  String get permAccessSettingsDesc;

  /// No description provided for @permViewChatLabel.
  ///
  /// In de, this message translates to:
  /// **'Chat lesen'**
  String get permViewChatLabel;

  /// No description provided for @permViewChatDesc.
  ///
  /// In de, this message translates to:
  /// **'Nachrichten im internen Chat ansehen'**
  String get permViewChatDesc;

  /// No description provided for @permSendChatMessageLabel.
  ///
  /// In de, this message translates to:
  /// **'Alles senden dürfen'**
  String get permSendChatMessageLabel;

  /// No description provided for @permSendChatMessageDesc.
  ///
  /// In de, this message translates to:
  /// **'Sammelrecht für jede Art von Nachricht – ersetzt die Einzelrechte darunter'**
  String get permSendChatMessageDesc;

  /// No description provided for @permSendTextMessageLabel.
  ///
  /// In de, this message translates to:
  /// **'Text schreiben'**
  String get permSendTextMessageLabel;

  /// No description provided for @permSendTextMessageDesc.
  ///
  /// In de, this message translates to:
  /// **'Geschriebene Nachrichten in den Chat stellen'**
  String get permSendTextMessageDesc;

  /// No description provided for @permSendDoodleLabel.
  ///
  /// In de, this message translates to:
  /// **'Malen'**
  String get permSendDoodleLabel;

  /// No description provided for @permSendDoodleDesc.
  ///
  /// In de, this message translates to:
  /// **'Zeichnungen und Gekritzeltes teilen'**
  String get permSendDoodleDesc;

  /// No description provided for @permSendVoiceMessageLabel.
  ///
  /// In de, this message translates to:
  /// **'Sprechen'**
  String get permSendVoiceMessageLabel;

  /// No description provided for @permSendVoiceMessageDesc.
  ///
  /// In de, this message translates to:
  /// **'Etwas aufnehmen und die eigene Stimme schicken'**
  String get permSendVoiceMessageDesc;

  /// No description provided for @permSendImageLabel.
  ///
  /// In de, this message translates to:
  /// **'Bilder schicken'**
  String get permSendImageLabel;

  /// No description provided for @permSendImageDesc.
  ///
  /// In de, this message translates to:
  /// **'Fotos aufnehmen oder aus der Galerie teilen'**
  String get permSendImageDesc;

  /// No description provided for @permSendVideoLabel.
  ///
  /// In de, this message translates to:
  /// **'Videos schicken'**
  String get permSendVideoLabel;

  /// No description provided for @permSendVideoDesc.
  ///
  /// In de, this message translates to:
  /// **'Videos aufnehmen oder aus der Galerie teilen'**
  String get permSendVideoDesc;

  /// No description provided for @permDeleteOwnMessagesLabel.
  ///
  /// In de, this message translates to:
  /// **'Eigene Nachrichten löschen'**
  String get permDeleteOwnMessagesLabel;

  /// No description provided for @permDeleteOwnMessagesDesc.
  ///
  /// In de, this message translates to:
  /// **'Nur zurücknehmen, was man selbst geschrieben hat'**
  String get permDeleteOwnMessagesDesc;

  /// No description provided for @permDeleteAllMessagesLabel.
  ///
  /// In de, this message translates to:
  /// **'Nachrichten anderer löschen'**
  String get permDeleteAllMessagesLabel;

  /// No description provided for @permDeleteAllMessagesDesc.
  ///
  /// In de, this message translates to:
  /// **'Auch Nachrichten anderer Anteile entfernen – das lässt sich nicht rückgängig machen'**
  String get permDeleteAllMessagesDesc;

  /// No description provided for @permViewCalendarLabel.
  ///
  /// In de, this message translates to:
  /// **'Kalender ansehen'**
  String get permViewCalendarLabel;

  /// No description provided for @permViewCalendarDesc.
  ///
  /// In de, this message translates to:
  /// **'Sehen, was ansteht'**
  String get permViewCalendarDesc;

  /// No description provided for @permCreateEventsLabel.
  ///
  /// In de, this message translates to:
  /// **'Termin eintragen'**
  String get permCreateEventsLabel;

  /// No description provided for @permCreateEventsDesc.
  ///
  /// In de, this message translates to:
  /// **'Neue Termine in den Kalender setzen'**
  String get permCreateEventsDesc;

  /// No description provided for @permEditOwnEventsLabel.
  ///
  /// In de, this message translates to:
  /// **'Eigene Termine ändern'**
  String get permEditOwnEventsLabel;

  /// No description provided for @permEditOwnEventsDesc.
  ///
  /// In de, this message translates to:
  /// **'Nur selbst eingetragene Termine bearbeiten'**
  String get permEditOwnEventsDesc;

  /// No description provided for @permEditAllEventsLabel.
  ///
  /// In de, this message translates to:
  /// **'Alle Termine ändern'**
  String get permEditAllEventsLabel;

  /// No description provided for @permEditAllEventsDesc.
  ///
  /// In de, this message translates to:
  /// **'Auch Termine anderer Anteile bearbeiten'**
  String get permEditAllEventsDesc;

  /// No description provided for @permDeleteOwnEventsLabel.
  ///
  /// In de, this message translates to:
  /// **'Eigene Termine löschen'**
  String get permDeleteOwnEventsLabel;

  /// No description provided for @permDeleteOwnEventsDesc.
  ///
  /// In de, this message translates to:
  /// **'Nur selbst eingetragene Termine entfernen'**
  String get permDeleteOwnEventsDesc;

  /// No description provided for @permDeleteAllEventsLabel.
  ///
  /// In de, this message translates to:
  /// **'Alle Termine löschen'**
  String get permDeleteAllEventsLabel;

  /// No description provided for @permDeleteAllEventsDesc.
  ///
  /// In de, this message translates to:
  /// **'Auch Termine anderer Anteile entfernen – das lässt sich nicht rückgängig machen'**
  String get permDeleteAllEventsDesc;

  /// No description provided for @permAttachEventMediaLabel.
  ///
  /// In de, this message translates to:
  /// **'Termin-Anhänge'**
  String get permAttachEventMediaLabel;

  /// No description provided for @permAttachEventMediaDesc.
  ///
  /// In de, this message translates to:
  /// **'Bilder und Notizen an einen Termin hängen'**
  String get permAttachEventMediaDesc;

  /// No description provided for @permCommentOnCalendarEventsLabel.
  ///
  /// In de, this message translates to:
  /// **'Kommentieren'**
  String get permCommentOnCalendarEventsLabel;

  /// No description provided for @permCommentOnCalendarEventsDesc.
  ///
  /// In de, this message translates to:
  /// **'Zu einem Termin etwas dazuschreiben'**
  String get permCommentOnCalendarEventsDesc;

  /// No description provided for @permViewMedicationLabel.
  ///
  /// In de, this message translates to:
  /// **'Medikamente ansehen'**
  String get permViewMedicationLabel;

  /// No description provided for @permViewMedicationDesc.
  ///
  /// In de, this message translates to:
  /// **'Sehen, was der Körper wann bekommt'**
  String get permViewMedicationDesc;

  /// No description provided for @permManageMedicationLabel.
  ///
  /// In de, this message translates to:
  /// **'Medikamente verwalten'**
  String get permManageMedicationLabel;

  /// No description provided for @permManageMedicationDesc.
  ///
  /// In de, this message translates to:
  /// **'Medikamente hinzufügen, ändern und entfernen'**
  String get permManageMedicationDesc;

  /// No description provided for @permLogMedicationLabel.
  ///
  /// In de, this message translates to:
  /// **'Einnahme bestätigen'**
  String get permLogMedicationLabel;

  /// No description provided for @permLogMedicationDesc.
  ///
  /// In de, this message translates to:
  /// **'Abhaken, was schon genommen wurde'**
  String get permLogMedicationDesc;

  /// No description provided for @permOverrideMedicationLogLabel.
  ///
  /// In de, this message translates to:
  /// **'Einnahmen zurücksetzen'**
  String get permOverrideMedicationLogLabel;

  /// No description provided for @permOverrideMedicationLogDesc.
  ///
  /// In de, this message translates to:
  /// **'Eine Bestätigung ändern, die ein anderer Anteil gesetzt hat'**
  String get permOverrideMedicationLogDesc;

  /// No description provided for @permCommentOnMedicationLabel.
  ///
  /// In de, this message translates to:
  /// **'Kommentieren'**
  String get permCommentOnMedicationLabel;

  /// No description provided for @permCommentOnMedicationDesc.
  ///
  /// In de, this message translates to:
  /// **'Zu einem Medikament etwas dazuschreiben'**
  String get permCommentOnMedicationDesc;

  /// No description provided for @permViewOwnDiaryLabel.
  ///
  /// In de, this message translates to:
  /// **'Eigenes Tagebuch'**
  String get permViewOwnDiaryLabel;

  /// No description provided for @permViewOwnDiaryDesc.
  ///
  /// In de, this message translates to:
  /// **'Nur die eigenen Einträge lesen'**
  String get permViewOwnDiaryDesc;

  /// No description provided for @permViewAllDiariesLabel.
  ///
  /// In de, this message translates to:
  /// **'Alle Tagebücher'**
  String get permViewAllDiariesLabel;

  /// No description provided for @permViewAllDiariesDesc.
  ///
  /// In de, this message translates to:
  /// **'Auch die Einträge anderer Anteile lesen'**
  String get permViewAllDiariesDesc;

  /// No description provided for @permWriteDiaryLabel.
  ///
  /// In de, this message translates to:
  /// **'Tagebuch schreiben'**
  String get permWriteDiaryLabel;

  /// No description provided for @permWriteDiaryDesc.
  ///
  /// In de, this message translates to:
  /// **'Etwas ins Tagebuch schreiben'**
  String get permWriteDiaryDesc;

  /// No description provided for @permViewContactsLabel.
  ///
  /// In de, this message translates to:
  /// **'Kontakte ansehen'**
  String get permViewContactsLabel;

  /// No description provided for @permViewContactsDesc.
  ///
  /// In de, this message translates to:
  /// **'Sehen, wer zum Umfeld gehört'**
  String get permViewContactsDesc;

  /// No description provided for @permManageContactsLabel.
  ///
  /// In de, this message translates to:
  /// **'Kontakte verwalten'**
  String get permManageContactsLabel;

  /// No description provided for @permManageContactsDesc.
  ///
  /// In de, this message translates to:
  /// **'Menschen hinzufügen, ändern und entfernen'**
  String get permManageContactsDesc;

  /// No description provided for @permCommentOnContactsLabel.
  ///
  /// In de, this message translates to:
  /// **'Kommentieren'**
  String get permCommentOnContactsLabel;

  /// No description provided for @permCommentOnContactsDesc.
  ///
  /// In de, this message translates to:
  /// **'Zu einer Person etwas dazuschreiben'**
  String get permCommentOnContactsDesc;

  /// No description provided for @permViewFinderLabel.
  ///
  /// In de, this message translates to:
  /// **'Finder ansehen'**
  String get permViewFinderLabel;

  /// No description provided for @permViewFinderDesc.
  ///
  /// In de, this message translates to:
  /// **'Nachsehen, wo etwas liegt oder wo man war'**
  String get permViewFinderDesc;

  /// No description provided for @permManageFinderLabel.
  ///
  /// In de, this message translates to:
  /// **'Finder verwalten'**
  String get permManageFinderLabel;

  /// No description provided for @permManageFinderDesc.
  ///
  /// In de, this message translates to:
  /// **'Orte und Gegenstände eintragen, ändern und entfernen'**
  String get permManageFinderDesc;

  /// No description provided for @permCommentOnFinderEntriesLabel.
  ///
  /// In de, this message translates to:
  /// **'Kommentieren'**
  String get permCommentOnFinderEntriesLabel;

  /// No description provided for @permCommentOnFinderEntriesDesc.
  ///
  /// In de, this message translates to:
  /// **'Zu einem Ort oder Gegenstand etwas dazuschreiben'**
  String get permCommentOnFinderEntriesDesc;

  /// No description provided for @permCreateDiaryEntryLabel.
  ///
  /// In de, this message translates to:
  /// **'Eintrag schreiben'**
  String get permCreateDiaryEntryLabel;

  /// No description provided for @permCreateDiaryEntryDesc.
  ///
  /// In de, this message translates to:
  /// **'Einen neuen Tagebuch-Eintrag anlegen'**
  String get permCreateDiaryEntryDesc;

  /// No description provided for @permEditOwnDiaryEntriesLabel.
  ///
  /// In de, this message translates to:
  /// **'Eigene Einträge ändern'**
  String get permEditOwnDiaryEntriesLabel;

  /// No description provided for @permEditOwnDiaryEntriesDesc.
  ///
  /// In de, this message translates to:
  /// **'Nur selbst geschriebene Einträge bearbeiten'**
  String get permEditOwnDiaryEntriesDesc;

  /// No description provided for @permEditAllDiaryEntriesLabel.
  ///
  /// In de, this message translates to:
  /// **'Alle Einträge ändern'**
  String get permEditAllDiaryEntriesLabel;

  /// No description provided for @permEditAllDiaryEntriesDesc.
  ///
  /// In de, this message translates to:
  /// **'Auch Einträge anderer Anteile bearbeiten'**
  String get permEditAllDiaryEntriesDesc;

  /// No description provided for @permDeleteOwnDiaryEntriesLabel.
  ///
  /// In de, this message translates to:
  /// **'Eigene Einträge löschen'**
  String get permDeleteOwnDiaryEntriesLabel;

  /// No description provided for @permDeleteOwnDiaryEntriesDesc.
  ///
  /// In de, this message translates to:
  /// **'Nur selbst geschriebene Einträge entfernen'**
  String get permDeleteOwnDiaryEntriesDesc;

  /// No description provided for @permDeleteAllDiaryEntriesLabel.
  ///
  /// In de, this message translates to:
  /// **'Alle Einträge löschen'**
  String get permDeleteAllDiaryEntriesLabel;

  /// No description provided for @permDeleteAllDiaryEntriesDesc.
  ///
  /// In de, this message translates to:
  /// **'Auch Einträge anderer Anteile entfernen – das lässt sich nicht rückgängig machen'**
  String get permDeleteAllDiaryEntriesDesc;

  /// No description provided for @permCommentOnDiaryEntriesLabel.
  ///
  /// In de, this message translates to:
  /// **'Kommentieren'**
  String get permCommentOnDiaryEntriesLabel;

  /// No description provided for @permCommentOnDiaryEntriesDesc.
  ///
  /// In de, this message translates to:
  /// **'Zu einem Eintrag etwas dazuschreiben'**
  String get permCommentOnDiaryEntriesDesc;

  /// No description provided for @permViewSharedEntriesLabel.
  ///
  /// In de, this message translates to:
  /// **'Geteilte Einträge'**
  String get permViewSharedEntriesLabel;

  /// No description provided for @permViewSharedEntriesDesc.
  ///
  /// In de, this message translates to:
  /// **'Einträge lesen, die für mehrere Anteile freigegeben sind'**
  String get permViewSharedEntriesDesc;

  /// No description provided for @permViewEmergencyContactsLabel.
  ///
  /// In de, this message translates to:
  /// **'Notfallkontakte ansehen'**
  String get permViewEmergencyContactsLabel;

  /// No description provided for @permViewEmergencyContactsDesc.
  ///
  /// In de, this message translates to:
  /// **'Sehen, wer im Notfall erreichbar ist'**
  String get permViewEmergencyContactsDesc;

  /// No description provided for @permCallEmergencyContactsLabel.
  ///
  /// In de, this message translates to:
  /// **'Anrufen'**
  String get permCallEmergencyContactsLabel;

  /// No description provided for @permCallEmergencyContactsDesc.
  ///
  /// In de, this message translates to:
  /// **'Im Notfall direkt jemanden anrufen'**
  String get permCallEmergencyContactsDesc;

  /// No description provided for @permEditEmergencyContactsLabel.
  ///
  /// In de, this message translates to:
  /// **'Notfallkontakte bearbeiten'**
  String get permEditEmergencyContactsLabel;

  /// No description provided for @permEditEmergencyContactsDesc.
  ///
  /// In de, this message translates to:
  /// **'Notfallkontakte hinzufügen, ändern und entfernen'**
  String get permEditEmergencyContactsDesc;

  /// No description provided for @permResetPasswordsLabel.
  ///
  /// In de, this message translates to:
  /// **'Passwörter zurücksetzen'**
  String get permResetPasswordsLabel;

  /// No description provided for @permResetPasswordsDesc.
  ///
  /// In de, this message translates to:
  /// **'Das Passwort eines anderen Anteils neu setzen'**
  String get permResetPasswordsDesc;

  /// No description provided for @permChangeOwnPasswordLabel.
  ///
  /// In de, this message translates to:
  /// **'Eigenes Passwort ändern'**
  String get permChangeOwnPasswordLabel;

  /// No description provided for @permChangeOwnPasswordDesc.
  ///
  /// In de, this message translates to:
  /// **'Nur das eigene Passwort neu setzen'**
  String get permChangeOwnPasswordDesc;

  /// No description provided for @permEnableBiometricsLabel.
  ///
  /// In de, this message translates to:
  /// **'Biometrie aktivieren'**
  String get permEnableBiometricsLabel;

  /// No description provided for @permEnableBiometricsDesc.
  ///
  /// In de, this message translates to:
  /// **'Mit Fingerabdruck oder Gesicht anmelden'**
  String get permEnableBiometricsDesc;

  /// No description provided for @permViewChatTabLabel.
  ///
  /// In de, this message translates to:
  /// **'Chat-Bereich'**
  String get permViewChatTabLabel;

  /// No description provided for @permViewChatTabDesc.
  ///
  /// In de, this message translates to:
  /// **'Den Chat überhaupt sehen'**
  String get permViewChatTabDesc;

  /// No description provided for @permViewFeedbackTabLabel.
  ///
  /// In de, this message translates to:
  /// **'Feedback-Bereich'**
  String get permViewFeedbackTabLabel;

  /// No description provided for @permViewFeedbackTabDesc.
  ///
  /// In de, this message translates to:
  /// **'Der Entwicklung schreiben'**
  String get permViewFeedbackTabDesc;

  /// No description provided for @permViewCalendarTabLabel.
  ///
  /// In de, this message translates to:
  /// **'Kalender-Bereich'**
  String get permViewCalendarTabLabel;

  /// No description provided for @permViewCalendarTabDesc.
  ///
  /// In de, this message translates to:
  /// **'Den Kalender überhaupt sehen'**
  String get permViewCalendarTabDesc;

  /// No description provided for @permViewMedicationTabLabel.
  ///
  /// In de, this message translates to:
  /// **'Medikamente-Bereich'**
  String get permViewMedicationTabLabel;

  /// No description provided for @permViewMedicationTabDesc.
  ///
  /// In de, this message translates to:
  /// **'Den Medikamentenplan überhaupt sehen'**
  String get permViewMedicationTabDesc;

  /// No description provided for @permViewDiaryTabLabel.
  ///
  /// In de, this message translates to:
  /// **'Tagebuch-Bereich'**
  String get permViewDiaryTabLabel;

  /// No description provided for @permViewDiaryTabDesc.
  ///
  /// In de, this message translates to:
  /// **'Das Tagebuch überhaupt sehen'**
  String get permViewDiaryTabDesc;

  /// No description provided for @permViewContactsTabLabel.
  ///
  /// In de, this message translates to:
  /// **'Kontakte-Bereich'**
  String get permViewContactsTabLabel;

  /// No description provided for @permViewContactsTabDesc.
  ///
  /// In de, this message translates to:
  /// **'Die Kontakte überhaupt sehen'**
  String get permViewContactsTabDesc;

  /// No description provided for @permViewFinderTabLabel.
  ///
  /// In de, this message translates to:
  /// **'Finder-Bereich'**
  String get permViewFinderTabLabel;

  /// No description provided for @permViewFinderTabDesc.
  ///
  /// In de, this message translates to:
  /// **'Den Finder überhaupt sehen'**
  String get permViewFinderTabDesc;

  /// No description provided for @permViewEmergencyTabLabel.
  ///
  /// In de, this message translates to:
  /// **'Notfall-Bereich'**
  String get permViewEmergencyTabLabel;

  /// No description provided for @permViewEmergencyTabDesc.
  ///
  /// In de, this message translates to:
  /// **'Die Notfallhilfe überhaupt sehen'**
  String get permViewEmergencyTabDesc;

  /// No description provided for @permViewHelpTabLabel.
  ///
  /// In de, this message translates to:
  /// **'Hilfe-Bereich'**
  String get permViewHelpTabLabel;

  /// No description provided for @permViewHelpTabDesc.
  ///
  /// In de, this message translates to:
  /// **'Hilfe und Anlaufstellen überhaupt sehen'**
  String get permViewHelpTabDesc;

  /// No description provided for @permViewMantrasTabLabel.
  ///
  /// In de, this message translates to:
  /// **'Mantras-Bereich'**
  String get permViewMantrasTabLabel;

  /// No description provided for @permViewMantrasTabDesc.
  ///
  /// In de, this message translates to:
  /// **'Die Mantras überhaupt sehen'**
  String get permViewMantrasTabDesc;

  /// No description provided for @permViewGamesTabLabel.
  ///
  /// In de, this message translates to:
  /// **'Spiele-Bereich'**
  String get permViewGamesTabLabel;

  /// No description provided for @permViewGamesTabDesc.
  ///
  /// In de, this message translates to:
  /// **'Die Spiele überhaupt sehen'**
  String get permViewGamesTabDesc;

  /// No description provided for @permViewTimelineTabLabel.
  ///
  /// In de, this message translates to:
  /// **'Zeitachse-Bereich'**
  String get permViewTimelineTabLabel;

  /// No description provided for @permViewTimelineTabDesc.
  ///
  /// In de, this message translates to:
  /// **'Sehen, wann welcher Anteil da war – und an welchem Ort'**
  String get permViewTimelineTabDesc;

  /// No description provided for @permissionYouNeed.
  ///
  /// In de, this message translates to:
  /// **'Du brauchst: {permission}'**
  String permissionYouNeed(String permission);

  /// No description provided for @fact01.
  ///
  /// In de, this message translates to:
  /// **'DIS (Dissoziative Identitätsstörung) betrifft etwa 1-2% der Bevölkerung.'**
  String get fact01;

  /// No description provided for @fact02.
  ///
  /// In de, this message translates to:
  /// **'Jede Person in einem System kann eigene Vorlieben, Fähigkeiten und Erinnerungen haben.'**
  String get fact02;

  /// No description provided for @fact03.
  ///
  /// In de, this message translates to:
  /// **'Innere Kommunikation ist ein wichtiger Schritt zur Stabilität und Heilung.'**
  String get fact03;

  /// No description provided for @fact04.
  ///
  /// In de, this message translates to:
  /// **'Dissoziation ist eine natürliche Schutzreaktion der Psyche.'**
  String get fact04;

  /// No description provided for @fact05.
  ///
  /// In de, this message translates to:
  /// **'Viele Menschen mit DIS sind hochfunktional und führen erfolgreiche Leben.'**
  String get fact05;

  /// No description provided for @fact06.
  ///
  /// In de, this message translates to:
  /// **'Aurora wurde speziell für die Kommunikation zwischen Innenpersonen entwickelt.'**
  String get fact06;

  /// No description provided for @fact07.
  ///
  /// In de, this message translates to:
  /// **'Der Chat-Bereich ermöglicht sichere interne Kommunikation ohne externe Apps.'**
  String get fact07;

  /// No description provided for @fact08.
  ///
  /// In de, this message translates to:
  /// **'Jedes Profil kann individuelle Berechtigungen haben - vom Vollzugriff bis zu eingeschränkten Rechten.'**
  String get fact08;

  /// No description provided for @fact09.
  ///
  /// In de, this message translates to:
  /// **'Das erste Profil wird automatisch zum Admin mit allen Berechtigungen.'**
  String get fact09;

  /// No description provided for @fact10.
  ///
  /// In de, this message translates to:
  /// **'Der Kalender hilft dabei, wichtige Termine für alle Innenpersonen sichtbar zu machen.'**
  String get fact10;

  /// No description provided for @fact11.
  ///
  /// In de, this message translates to:
  /// **'Im Medikamenten-Bereich kannst du regelmäßige und Bedarfsmedikamente verwalten.'**
  String get fact11;

  /// No description provided for @fact12.
  ///
  /// In de, this message translates to:
  /// **'Der Finder hilft dabei, verlorene Gegenstände zu dokumentieren und wiederzufinden.'**
  String get fact12;

  /// No description provided for @fact13.
  ///
  /// In de, this message translates to:
  /// **'Das Notfall-Tagebuch dokumentiert kritische Situationen für Therapeuten.'**
  String get fact13;

  /// No description provided for @fact14.
  ///
  /// In de, this message translates to:
  /// **'Mantras können bei Dissoziation oder Stress helfen zu erden.'**
  String get fact14;

  /// No description provided for @fact15.
  ///
  /// In de, this message translates to:
  /// **'Im Kontakte-Bereich kannst du wichtige Personen bewerten und kommentieren.'**
  String get fact15;

  /// No description provided for @fact16.
  ///
  /// In de, this message translates to:
  /// **'Du kannst für jedes Profil eine eigene Farbe wählen.'**
  String get fact16;

  /// No description provided for @fact17.
  ///
  /// In de, this message translates to:
  /// **'Sprachnachrichten ermöglichen Kommunikation auch wenn Schreiben schwerfällt.'**
  String get fact17;

  /// No description provided for @fact18.
  ///
  /// In de, this message translates to:
  /// **'Doodles im Chat helfen, Gefühle visuell auszudrücken.'**
  String get fact18;

  /// No description provided for @fact19.
  ///
  /// In de, this message translates to:
  /// **'Deine Einträge bleiben auf deinem Gerät. Gesendet wird nur, was du selbst ins Feedback schreibst.'**
  String get fact19;

  /// No description provided for @fact20.
  ///
  /// In de, this message translates to:
  /// **'Regelmäßige Check-ins mit allen Innenpersonen fördern die Zusammenarbeit.'**
  String get fact20;

  /// No description provided for @fact21.
  ///
  /// In de, this message translates to:
  /// **'Ein gemeinsamer Kalender verhindert Doppelbuchungen und Stress.'**
  String get fact21;

  /// No description provided for @fact22.
  ///
  /// In de, this message translates to:
  /// **'Notizen im Notfall-Tagebuch können bei der Therapie sehr hilfreich sein.'**
  String get fact22;

  /// No description provided for @fact23.
  ///
  /// In de, this message translates to:
  /// **'Jede Innenperson darf eigene Bedürfnisse haben - das ist völlig normal.'**
  String get fact23;

  /// No description provided for @fact24.
  ///
  /// In de, this message translates to:
  /// **'Erdungsübungen können helfen, im Hier und Jetzt zu bleiben.'**
  String get fact24;

  /// No description provided for @fact25.
  ///
  /// In de, this message translates to:
  /// **'Routinen geben Sicherheit und Struktur für alle im System.'**
  String get fact25;

  /// No description provided for @fact26.
  ///
  /// In de, this message translates to:
  /// **'Pausen sind wichtig - auch für Innenpersonen.'**
  String get fact26;

  /// No description provided for @fact27.
  ///
  /// In de, this message translates to:
  /// **'Du kannst Profile jederzeit deaktivieren und später reaktivieren.'**
  String get fact27;

  /// No description provided for @fact28.
  ///
  /// In de, this message translates to:
  /// **'Der Admin kann Berechtigungen jederzeit anpassen.'**
  String get fact28;

  /// No description provided for @fact29.
  ///
  /// In de, this message translates to:
  /// **'Bedarfsmedikamente können spontan protokolliert werden.'**
  String get fact29;

  /// No description provided for @fact30.
  ///
  /// In de, this message translates to:
  /// **'Im Chat kannst du gezielt bestimmte Personen ansprechen.'**
  String get fact30;

  /// No description provided for @fact31.
  ///
  /// In de, this message translates to:
  /// **'Aurora verwendet starke Verschlüsselung für sensible Daten.'**
  String get fact31;

  /// No description provided for @fact32.
  ///
  /// In de, this message translates to:
  /// **'Passwörter werden niemals im Klartext gespeichert.'**
  String get fact32;

  /// No description provided for @fact33.
  ///
  /// In de, this message translates to:
  /// **'Der Passwort-Reset braucht 24 Stunden als Sicherheitsmaßnahme.'**
  String get fact33;

  /// No description provided for @fact34.
  ///
  /// In de, this message translates to:
  /// **'Alle Chat-Nachrichten bleiben privat und lokal gespeichert.'**
  String get fact34;

  /// No description provided for @fact35.
  ///
  /// In de, this message translates to:
  /// **'Jeder Schritt zur besseren Kommunikation ist ein Erfolg.'**
  String get fact35;

  /// No description provided for @fact36.
  ///
  /// In de, this message translates to:
  /// **'Es ist okay, unterschiedliche Meinungen im System zu haben.'**
  String get fact36;

  /// No description provided for @fact37.
  ///
  /// In de, this message translates to:
  /// **'Zusammenarbeit macht stark - auch intern.'**
  String get fact37;

  /// No description provided for @fact38.
  ///
  /// In de, this message translates to:
  /// **'Du bist nicht allein - viele Menschen leben erfolgreich mit DIS.'**
  String get fact38;

  /// No description provided for @sliderChat0.
  ///
  /// In de, this message translates to:
  /// **'👁️ Chat lesen und malen'**
  String get sliderChat0;

  /// No description provided for @sliderChat1.
  ///
  /// In de, this message translates to:
  /// **'✅ Alles im Chat: Text, Zeichnungen, Sprache, Bilder, Videos'**
  String get sliderChat1;

  /// No description provided for @sliderCalendar0.
  ///
  /// In de, this message translates to:
  /// **'❌ Kein Zugriff auf den Kalender'**
  String get sliderCalendar0;

  /// No description provided for @sliderCalendar1.
  ///
  /// In de, this message translates to:
  /// **'👁️ Termine ansehen'**
  String get sliderCalendar1;

  /// No description provided for @sliderCalendar2.
  ///
  /// In de, this message translates to:
  /// **'📅 Eigene Termine anlegen und ändern'**
  String get sliderCalendar2;

  /// No description provided for @sliderCalendar3.
  ///
  /// In de, this message translates to:
  /// **'✅ Alle Termine verwalten und Anhänge hinzufügen'**
  String get sliderCalendar3;

  /// No description provided for @sliderMedication0.
  ///
  /// In de, this message translates to:
  /// **'❌ Kein Zugriff auf Medikamente'**
  String get sliderMedication0;

  /// No description provided for @sliderMedication1.
  ///
  /// In de, this message translates to:
  /// **'👁️ Medikamentenliste ansehen'**
  String get sliderMedication1;

  /// No description provided for @sliderMedication2.
  ///
  /// In de, this message translates to:
  /// **'✅ Einnahmen bestätigen'**
  String get sliderMedication2;

  /// No description provided for @sliderDiary0.
  ///
  /// In de, this message translates to:
  /// **'❌ Kein Zugriff auf das Tagebuch'**
  String get sliderDiary0;

  /// No description provided for @sliderDiary1.
  ///
  /// In de, this message translates to:
  /// **'👁️ Nur das eigene Tagebuch lesen'**
  String get sliderDiary1;

  /// No description provided for @sliderDiary2.
  ///
  /// In de, this message translates to:
  /// **'📝 Ins eigene Tagebuch schreiben'**
  String get sliderDiary2;

  /// No description provided for @sliderDiary3.
  ///
  /// In de, this message translates to:
  /// **'✅ Alle Tagebücher lesen und schreiben'**
  String get sliderDiary3;

  /// No description provided for @sliderContacts0.
  ///
  /// In de, this message translates to:
  /// **'❌ Kein Zugriff auf Kontakte'**
  String get sliderContacts0;

  /// No description provided for @sliderContacts1.
  ///
  /// In de, this message translates to:
  /// **'👁️ Kontakte ansehen'**
  String get sliderContacts1;

  /// No description provided for @sliderContacts2.
  ///
  /// In de, this message translates to:
  /// **'💬 Kontakte ansehen und kommentieren'**
  String get sliderContacts2;

  /// No description provided for @sliderContacts3.
  ///
  /// In de, this message translates to:
  /// **'✅ Kontakte verwalten: anlegen, ändern, löschen'**
  String get sliderContacts3;

  /// No description provided for @sliderFinder0.
  ///
  /// In de, this message translates to:
  /// **'❌ Kein Zugriff auf den Finder'**
  String get sliderFinder0;

  /// No description provided for @sliderFinder1.
  ///
  /// In de, this message translates to:
  /// **'👁️ Einträge ansehen'**
  String get sliderFinder1;

  /// No description provided for @sliderFinder2.
  ///
  /// In de, this message translates to:
  /// **'✅ Einträge verwalten'**
  String get sliderFinder2;

  /// No description provided for @sliderEmergencyDiary0.
  ///
  /// In de, this message translates to:
  /// **'❌ Kein Zugriff auf das Notfall-Tagebuch'**
  String get sliderEmergencyDiary0;

  /// No description provided for @sliderEmergencyDiary1.
  ///
  /// In de, this message translates to:
  /// **'👁️ Einträge ansehen'**
  String get sliderEmergencyDiary1;

  /// No description provided for @sliderEmergencyDiary2.
  ///
  /// In de, this message translates to:
  /// **'💬 Einträge anlegen und kommentieren, eigene ändern'**
  String get sliderEmergencyDiary2;

  /// No description provided for @sliderEmergencyDiary3.
  ///
  /// In de, this message translates to:
  /// **'✅ Alle Einträge verwalten'**
  String get sliderEmergencyDiary3;

  /// No description provided for @sliderEmergency0.
  ///
  /// In de, this message translates to:
  /// **'❌ Kein Zugriff auf Notfallkontakte'**
  String get sliderEmergency0;

  /// No description provided for @sliderEmergency1.
  ///
  /// In de, this message translates to:
  /// **'👁️ Notfallkontakte ansehen'**
  String get sliderEmergency1;

  /// No description provided for @sliderEmergency2.
  ///
  /// In de, this message translates to:
  /// **'📞 Notfallkontakte ansehen und anrufen'**
  String get sliderEmergency2;

  /// No description provided for @sliderEmergency3.
  ///
  /// In de, this message translates to:
  /// **'✅ Notfallkontakte verwalten'**
  String get sliderEmergency3;

  /// No description provided for @sliderHelp0.
  ///
  /// In de, this message translates to:
  /// **'❌ Kein Zugriff auf Hilfe'**
  String get sliderHelp0;

  /// No description provided for @sliderHelp1.
  ///
  /// In de, this message translates to:
  /// **'✅ Hilfe und Anlaufstellen ansehen'**
  String get sliderHelp1;

  /// No description provided for @sliderMantras0.
  ///
  /// In de, this message translates to:
  /// **'❌ Kein Zugriff auf Mantras'**
  String get sliderMantras0;

  /// No description provided for @sliderMantras1.
  ///
  /// In de, this message translates to:
  /// **'✅ Mantras nutzen'**
  String get sliderMantras1;

  /// No description provided for @sliderGames0.
  ///
  /// In de, this message translates to:
  /// **'❌ Kein Zugriff auf Spiele'**
  String get sliderGames0;

  /// No description provided for @sliderGames1.
  ///
  /// In de, this message translates to:
  /// **'✅ Spiele spielen'**
  String get sliderGames1;

  /// No description provided for @settingsDeleteAll.
  ///
  /// In de, this message translates to:
  /// **'Alles löschen'**
  String get settingsDeleteAll;

  /// No description provided for @settingsCacheClearHint.
  ///
  /// In de, this message translates to:
  /// **'Die Karten werden beim nächsten Aufruf neu geladen. Das kann Speicherplatz freigeben.'**
  String get settingsCacheClearHint;

  /// No description provided for @settingsGpsWhileInUse.
  ///
  /// In de, this message translates to:
  /// **'Bei Nutzung erlaubt ✓'**
  String get settingsGpsWhileInUse;

  /// No description provided for @settingsGpsNotAllowed.
  ///
  /// In de, this message translates to:
  /// **'Nicht erlaubt'**
  String get settingsGpsNotAllowed;

  /// No description provided for @settingsGpsStatusLine.
  ///
  /// In de, this message translates to:
  /// **'⚠️ {status}'**
  String settingsGpsStatusLine(String status);

  /// No description provided for @settingsGpsBackgroundRuns.
  ///
  /// In de, this message translates to:
  /// **'GPS läuft dauerhaft im Hintergrund'**
  String get settingsGpsBackgroundRuns;

  /// No description provided for @settingsGpsOverridesAll.
  ///
  /// In de, this message translates to:
  /// **'Überschreibt die Tracking-Einstellung ALLER Profile'**
  String get settingsGpsOverridesAll;

  /// No description provided for @settingsStepTapPermission.
  ///
  /// In de, this message translates to:
  /// **'Tippe auf „Berechtigungen\"'**
  String get settingsStepTapPermission;

  /// No description provided for @settingsStepTapLocation.
  ///
  /// In de, this message translates to:
  /// **'Tippe auf „Standort\"'**
  String get settingsStepTapLocation;

  /// No description provided for @settingsStepChooseAlways.
  ///
  /// In de, this message translates to:
  /// **'Wähle „Immer erlauben\"'**
  String get settingsStepChooseAlways;

  /// No description provided for @settingsStepOpenSettings.
  ///
  /// In de, this message translates to:
  /// **'Tippe unten auf „Android-Einstellungen öffnen\"'**
  String get settingsStepOpenSettings;

  /// No description provided for @settingsStepPermissionLocation.
  ///
  /// In de, this message translates to:
  /// **'Wähle „Berechtigungen\" → „Standort\"'**
  String get settingsStepPermissionLocation;

  /// No description provided for @settingsPositionAlways.
  ///
  /// In de, this message translates to:
  /// **'Die Position wird dauerhaft erfasst'**
  String get settingsPositionAlways;

  /// No description provided for @settingsOverridesProfiles.
  ///
  /// In de, this message translates to:
  /// **'Überschreibt die Einstellung jedes einzelnen Profils'**
  String get settingsOverridesProfiles;

  /// No description provided for @settingsAllProfilesTracked.
  ///
  /// In de, this message translates to:
  /// **'Alle Profile werden automatisch aufgezeichnet'**
  String get settingsAllProfilesTracked;

  /// No description provided for @settingsOpenGpsSettings.
  ///
  /// In de, this message translates to:
  /// **'GPS-Einstellungen öffnen'**
  String get settingsOpenGpsSettings;

  /// No description provided for @settingsGpsRunsForAll.
  ///
  /// In de, this message translates to:
  /// **'GPS läuft dauerhaft für alle Profile'**
  String get settingsGpsRunsForAll;

  /// No description provided for @settingsNotifAsNeeded.
  ///
  /// In de, this message translates to:
  /// **'Bedarfsmedizin: Aurora meldet sich, sobald die nächste Dosis erlaubt ist — 30, 10 und 5 Minuten vorher'**
  String get settingsNotifAsNeeded;

  /// No description provided for @settingsNotifWorksClosed.
  ///
  /// In de, this message translates to:
  /// **'Funktioniert auch, wenn die App geschlossen ist'**
  String get settingsNotifWorksClosed;

  /// No description provided for @aboutTitle.
  ///
  /// In de, this message translates to:
  /// **'Über Aurora'**
  String get aboutTitle;

  /// No description provided for @aboutChat.
  ///
  /// In de, this message translates to:
  /// **'Miteinander sprechen – mit Text, Bildern, Videos und Sprachnachrichten'**
  String get aboutChat;

  /// No description provided for @aboutCalendar.
  ///
  /// In de, this message translates to:
  /// **'Gemeinsame Termine mit Erinnerungen und Anhängen'**
  String get aboutCalendar;

  /// No description provided for @aboutMedication.
  ///
  /// In de, this message translates to:
  /// **'Medikamentenpläne mit Einnahmeprotokoll'**
  String get aboutMedication;

  /// No description provided for @aboutEmergencyDiary.
  ///
  /// In de, this message translates to:
  /// **'Geteiltes Logbuch für Krisen und wichtige Ereignisse'**
  String get aboutEmergencyDiary;

  /// No description provided for @aboutContacts.
  ///
  /// In de, this message translates to:
  /// **'Eigene Bewertungen und Notizen zu Menschen im Umfeld'**
  String get aboutContacts;

  /// No description provided for @aboutFinder.
  ///
  /// In de, this message translates to:
  /// **'Orte und Gegenstände wiederfinden'**
  String get aboutFinder;

  /// No description provided for @aboutLocalOnly.
  ///
  /// In de, this message translates to:
  /// **'Alle Daten bleiben auf deinem Gerät – keine Cloud'**
  String get aboutLocalOnly;

  /// No description provided for @telemetryQuestion.
  ///
  /// In de, this message translates to:
  /// **'Hilfst du mit, Aurora zu verbessern?'**
  String get telemetryQuestion;

  /// No description provided for @telemetryExplanation.
  ///
  /// In de, this message translates to:
  /// **'Aurora kann zählen, welche Bereiche geöffnet werden und wo Abläufe abbrechen. Gesendet wird nur der Name des Ereignisses, der Tag und die App-Version — kein Text, kein Standort und nichts, was zu dir zurückführt. Die Meldung geht sofort raus; wann sie ankommt, ist also auch der Zeitpunkt, an dem du Aurora benutzt hast.'**
  String get telemetryExplanation;

  /// No description provided for @telemetryChangeLater.
  ///
  /// In de, this message translates to:
  /// **'Du kannst das jederzeit in den Einstellungen unter „Was Aurora sendet\" ändern. Dort steht auch jede einzelne Meldung, die dein Gerät verlassen hat.'**
  String get telemetryChangeLater;

  /// No description provided for @transparencyIntroFull.
  ///
  /// In de, this message translates to:
  /// **'Hier siehst du jede Übertragung, die dein Gerät verlassen hat — vollständig und im Wortlaut.'**
  String get transparencyIntroFull;

  /// No description provided for @transparencyIrreversibleFull.
  ///
  /// In de, this message translates to:
  /// **'Was bereits gesendet wurde, kann nicht zurückgeholt werden. Es ist dir nicht zugeordnet — deshalb lässt es sich auch nicht finden und löschen.'**
  String get transparencyIrreversibleFull;

  /// No description provided for @transparencyWaitingForConnection.
  ///
  /// In de, this message translates to:
  /// **'Wartet auf Verbindung'**
  String get transparencyWaitingForConnection;

  /// No description provided for @privacyTitle.
  ///
  /// In de, this message translates to:
  /// **'Datenschutzerklärung'**
  String get privacyTitle;

  /// No description provided for @privacyAtAGlance.
  ///
  /// In de, this message translates to:
  /// **'Datenschutz auf einen Blick'**
  String get privacyAtAGlance;

  /// No description provided for @privacyWhatIsStored.
  ///
  /// In de, this message translates to:
  /// **'Welche Daten werden gespeichert?'**
  String get privacyWhatIsStored;

  /// No description provided for @privacyTransmission.
  ///
  /// In de, this message translates to:
  /// **'Datenübertragung'**
  String get privacyTransmission;

  /// No description provided for @privacyDeletion.
  ///
  /// In de, this message translates to:
  /// **'Daten löschen'**
  String get privacyDeletion;

  /// No description provided for @privacyMinors.
  ///
  /// In de, this message translates to:
  /// **'Schutz Minderjähriger'**
  String get privacyMinors;

  /// No description provided for @privacyChanges.
  ///
  /// In de, this message translates to:
  /// **'Änderungen dieser Erklärung'**
  String get privacyChanges;

  /// No description provided for @privacyClosing.
  ///
  /// In de, this message translates to:
  /// **'Aurora – deine Daten bleiben bei dir.'**
  String get privacyClosing;

  /// No description provided for @mediaImageNotOpened.
  ///
  /// In de, this message translates to:
  /// **'Das Bild ließ sich nicht öffnen'**
  String get mediaImageNotOpened;

  /// No description provided for @mediaVideoNotOpened.
  ///
  /// In de, this message translates to:
  /// **'Das Video ließ sich nicht öffnen'**
  String get mediaVideoNotOpened;

  /// No description provided for @mediaFromGallery.
  ///
  /// In de, this message translates to:
  /// **'Aus der Galerie'**
  String get mediaFromGallery;

  /// No description provided for @mediaPickImage.
  ///
  /// In de, this message translates to:
  /// **'Bild auswählen'**
  String get mediaPickImage;

  /// No description provided for @mediaPickVideo.
  ///
  /// In de, this message translates to:
  /// **'Video auswählen'**
  String get mediaPickVideo;

  /// No description provided for @transportDirectToDevelopers.
  ///
  /// In de, this message translates to:
  /// **'Direkt an die Entwickler'**
  String get transportDirectToDevelopers;

  /// No description provided for @transportSendFailed.
  ///
  /// In de, this message translates to:
  /// **'Senden fehlgeschlagen. Versuch es später noch einmal oder schick es per E-Mail.'**
  String get transportSendFailed;

  /// No description provided for @transportRejected.
  ///
  /// In de, this message translates to:
  /// **'Der Server hat die Nachricht abgelehnt.'**
  String get transportRejected;

  /// No description provided for @transportUnreachable.
  ///
  /// In de, this message translates to:
  /// **'Der Server ist gerade nicht erreichbar.'**
  String get transportUnreachable;

  /// No description provided for @transparencyArrived.
  ///
  /// In de, this message translates to:
  /// **'Angekommen'**
  String get transparencyArrived;

  /// No description provided for @transparencyNotSent.
  ///
  /// In de, this message translates to:
  /// **'Nicht gesendet: {reason}'**
  String transparencyNotSent(String reason);

  /// No description provided for @transparencyReasonUnknown.
  ///
  /// In de, this message translates to:
  /// **'Grund unbekannt'**
  String get transparencyReasonUnknown;

  /// No description provided for @transportTryLaterOrEmail.
  ///
  /// In de, this message translates to:
  /// **'Versuch es später noch einmal oder schick es per E-Mail.'**
  String get transportTryLaterOrEmail;

  /// No description provided for @transportEmailInstead.
  ///
  /// In de, this message translates to:
  /// **'Du kannst deine Rückmeldung stattdessen per E-Mail schicken.'**
  String get transportEmailInstead;

  /// No description provided for @crashDialogTitle.
  ///
  /// In de, this message translates to:
  /// **'Aurora ist abgestürzt'**
  String get crashDialogTitle;

  /// No description provided for @errorDialogTitle.
  ///
  /// In de, this message translates to:
  /// **'Aurora hat ein Problem bemerkt'**
  String get errorDialogTitle;

  /// No description provided for @errorHelpUsFix.
  ///
  /// In de, this message translates to:
  /// **'Möchtest du uns helfen, das zu beheben?'**
  String get errorHelpUsFix;

  /// No description provided for @errorSendingFailed.
  ///
  /// In de, this message translates to:
  /// **'Beim Senden ist ein Fehler aufgetreten.'**
  String get errorSendingFailed;

  /// No description provided for @feedbackContactOptions.
  ///
  /// In de, this message translates to:
  /// **'Wege zu uns'**
  String get feedbackContactOptions;

  /// No description provided for @feedbackInvalidEmail.
  ///
  /// In de, this message translates to:
  /// **'Ungültige E-Mail-Adresse'**
  String get feedbackInvalidEmail;

  /// No description provided for @feedbackArrived.
  ///
  /// In de, this message translates to:
  /// **'Danke für deine Rückmeldung! Sie ist angekommen.'**
  String get feedbackArrived;

  /// No description provided for @feedbackQueued.
  ///
  /// In de, this message translates to:
  /// **'Angenommen. Es geht raus, sobald du wieder online bist.'**
  String get feedbackQueued;

  /// No description provided for @feedbackSendFailed.
  ///
  /// In de, this message translates to:
  /// **'Senden fehlgeschlagen. Versuch es später noch einmal.'**
  String get feedbackSendFailed;

  /// No description provided for @profilePickImage.
  ///
  /// In de, this message translates to:
  /// **'Profilbild wählen'**
  String get profilePickImage;

  /// No description provided for @profilePasswordOptional.
  ///
  /// In de, this message translates to:
  /// **'Schütze dein Profil mit einem Passwort (optional)'**
  String get profilePasswordOptional;

  /// No description provided for @profilePasswordOptionalMin.
  ///
  /// In de, this message translates to:
  /// **'Schütze dein Profil mit einem Passwort (optional, mindestens 4 Zeichen)'**
  String get profilePasswordOptionalMin;

  /// No description provided for @thankYouWeReceived.
  ///
  /// In de, this message translates to:
  /// **'Wir haben deinen Bericht erhalten und melden uns bei Rückfragen per E-Mail.'**
  String get thankYouWeReceived;

  /// No description provided for @thankYouWeCheck.
  ///
  /// In de, this message translates to:
  /// **'Wir sehen uns deinen Bericht an'**
  String get thankYouWeCheck;

  /// No description provided for @thankYouWeFix.
  ///
  /// In de, this message translates to:
  /// **'Wir arbeiten an einer Lösung'**
  String get thankYouWeFix;

  /// No description provided for @thankYouYouGetMail.
  ///
  /// In de, this message translates to:
  /// **'Du bekommst eine E-Mail, sobald die Lösung da ist'**
  String get thankYouYouGetMail;

  /// No description provided for @thankYouNextUpdate.
  ///
  /// In de, this message translates to:
  /// **'Die Lösung kommt mit dem nächsten Update'**
  String get thankYouNextUpdate;

  /// No description provided for @mapGpsLoading.
  ///
  /// In de, this message translates to:
  /// **'GPS lädt…'**
  String get mapGpsLoading;

  /// No description provided for @mapGpsPositionLoading.
  ///
  /// In de, this message translates to:
  /// **'Position wird geladen…'**
  String get mapGpsPositionLoading;

  /// No description provided for @mapAllowLocation.
  ///
  /// In de, this message translates to:
  /// **'Erlaube den Zugriff auf den Standort, um deine Position auf der Karte zu sehen'**
  String get mapAllowLocation;

  /// No description provided for @mapLastKnownPosition.
  ///
  /// In de, this message translates to:
  /// **'Auf der Karte steht deine letzte bekannte Position: {age}.'**
  String mapLastKnownPosition(String age);

  /// No description provided for @pwResetThenReplaced.
  ///
  /// In de, this message translates to:
  /// **'✓ Erst dann wird das alte Passwort ersetzt'**
  String get pwResetThenReplaced;

  /// No description provided for @pwResetCanActivateNow.
  ///
  /// In de, this message translates to:
  /// **'Dein neues Passwort kann jetzt aktiviert werden'**
  String get pwResetCanActivateNow;

  /// No description provided for @pwResetRunningShort.
  ///
  /// In de, this message translates to:
  /// **'Reset läuft…'**
  String get pwResetRunningShort;

  /// No description provided for @moodVeryHappy.
  ///
  /// In de, this message translates to:
  /// **'Sehr glücklich'**
  String get moodVeryHappy;

  /// No description provided for @moodHappy.
  ///
  /// In de, this message translates to:
  /// **'Glücklich'**
  String get moodHappy;

  /// No description provided for @moodAnxious.
  ///
  /// In de, this message translates to:
  /// **'Ängstlich'**
  String get moodAnxious;

  /// No description provided for @moodAngry.
  ///
  /// In de, this message translates to:
  /// **'Wütend'**
  String get moodAngry;

  /// No description provided for @emergencyPositionUnavailable.
  ///
  /// In de, this message translates to:
  /// **'Position nicht verfügbar'**
  String get emergencyPositionUnavailable;

  /// No description provided for @emergencyPositionNoPermission.
  ///
  /// In de, this message translates to:
  /// **'Position nicht verfügbar (keine Berechtigung)'**
  String get emergencyPositionNoPermission;

  /// No description provided for @emergencyMessageSubject.
  ///
  /// In de, this message translates to:
  /// **'Notfall-Nachricht von Aurora'**
  String get emergencyMessageSubject;

  /// No description provided for @autoLogoutAfter.
  ///
  /// In de, this message translates to:
  /// **'Automatisch abmelden nach {minutes} Minuten ohne Nutzung'**
  String autoLogoutAfter(int minutes);

  /// No description provided for @pwResetBannerReady.
  ///
  /// In de, this message translates to:
  /// **'Passwort bereit zum Aktivieren'**
  String get pwResetBannerReady;

  /// No description provided for @doodleHistory.
  ///
  /// In de, this message translates to:
  /// **'Verlauf blättern'**
  String get doodleHistory;

  /// No description provided for @doodleDraw.
  ///
  /// In de, this message translates to:
  /// **'Malen'**
  String get doodleDraw;

  /// No description provided for @doodleSendEmptyHint.
  ///
  /// In de, this message translates to:
  /// **'Male zuerst — dann kannst du senden'**
  String get doodleSendEmptyHint;

  /// No description provided for @anchorTelemetryNotice.
  ///
  /// In de, this message translates to:
  /// **'Anonyme Zählung ist an — was Aurora sendet'**
  String get anchorTelemetryNotice;

  /// No description provided for @timePhaseMorning.
  ///
  /// In de, this message translates to:
  /// **'morgens'**
  String get timePhaseMorning;

  /// No description provided for @timePhaseMidday.
  ///
  /// In de, this message translates to:
  /// **'mittags'**
  String get timePhaseMidday;

  /// No description provided for @timePhaseAfternoon.
  ///
  /// In de, this message translates to:
  /// **'nachmittags'**
  String get timePhaseAfternoon;

  /// No description provided for @timePhaseEvening.
  ///
  /// In de, this message translates to:
  /// **'abends'**
  String get timePhaseEvening;

  /// No description provided for @timePhaseNight.
  ///
  /// In de, this message translates to:
  /// **'nachts'**
  String get timePhaseNight;

  /// Greeting above the profile name on the anchor, 5:00-11:00
  ///
  /// In de, this message translates to:
  /// **'Guten Morgen'**
  String get greetingMorning;

  /// Greeting above the profile name on the anchor, 11:00-18:00
  ///
  /// In de, this message translates to:
  /// **'Guten Tag'**
  String get greetingDay;

  /// Greeting above the profile name on the anchor, 18:00-23:00
  ///
  /// In de, this message translates to:
  /// **'Guten Abend'**
  String get greetingEvening;

  /// Link under the name on the anchor. Leads back to the profile selection - the same route as logout, but named after the purpose instead of the technique. Phrased from the inside: whoever reads it is not the part shown above, and the sentence says that before it asks anyone to do anything. Do not translate it as an instruction ('switch part'); keep it a statement about oneself.
  ///
  /// In de, this message translates to:
  /// **'Das bin ich nicht'**
  String get anchorSwitchProfile;

  /// Greeting above the profile name on the anchor, 23:00-5:00. Must NOT be a parting phrase - German 'Gute Nacht' means goodbye, and someone coming to the front at night is arriving, not leaving. Same for 'Buonanotte' (it) and 'Bonne nuit' (fr).
  ///
  /// In de, this message translates to:
  /// **'Hallo'**
  String get greetingNight;

  /// No description provided for @quickTimelineYou.
  ///
  /// In de, this message translates to:
  /// **'(Du)'**
  String get quickTimelineYou;

  /// No description provided for @todayEvents.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, one{1 Termin heute} other{{count} Termine heute}}'**
  String todayEvents(num count);

  /// No description provided for @todayMedications.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, one{1 Medikament heute} other{{count} Medikamente heute}}'**
  String todayMedications(num count);

  /// No description provided for @workSurfaceActiveProfile.
  ///
  /// In de, this message translates to:
  /// **'{name} ist gerade hier'**
  String workSurfaceActiveProfile(String name);

  /// No description provided for @doodleUndo.
  ///
  /// In de, this message translates to:
  /// **'Zurücknehmen'**
  String get doodleUndo;

  /// No description provided for @doodleClear.
  ///
  /// In de, this message translates to:
  /// **'Alles löschen'**
  String get doodleClear;

  /// No description provided for @finderPersonName.
  ///
  /// In de, this message translates to:
  /// **'Name der Person'**
  String get finderPersonName;

  /// No description provided for @finderPlaceTitle.
  ///
  /// In de, this message translates to:
  /// **'Titel für diesen Ort'**
  String get finderPlaceTitle;

  /// No description provided for @commonLoading.
  ///
  /// In de, this message translates to:
  /// **'Lädt…'**
  String get commonLoading;

  /// No description provided for @puzzleCategoryAnimals.
  ///
  /// In de, this message translates to:
  /// **'Niedliche und beruhigende Tiere'**
  String get puzzleCategoryAnimals;

  /// No description provided for @puzzleCategoryWater.
  ///
  /// In de, this message translates to:
  /// **'Meer und Wasser'**
  String get puzzleCategoryWater;

  /// No description provided for @puzzleCategoryFlowers.
  ///
  /// In de, this message translates to:
  /// **'Bunte Blumen und Pflanzen'**
  String get puzzleCategoryFlowers;

  /// No description provided for @gpsTrackingOffTap.
  ///
  /// In de, this message translates to:
  /// **'Aufzeichnung aus – tippen zum Einschalten'**
  String get gpsTrackingOffTap;

  /// No description provided for @gpsTrackingOnTap.
  ///
  /// In de, this message translates to:
  /// **'Aufzeichnung an – tippen zum Ausschalten'**
  String get gpsTrackingOnTap;

  /// No description provided for @gpsNoPermissionHint.
  ///
  /// In de, this message translates to:
  /// **'Ohne die Standort-Berechtigung kann Aurora die Aufzeichnung nicht starten. Du kannst sie in den Android-Einstellungen unter Apps → Aurora → Berechtigungen erteilen.'**
  String get gpsNoPermissionHint;

  /// No description provided for @settingsCouldNotOpen.
  ///
  /// In de, this message translates to:
  /// **'Die Einstellungen ließen sich nicht öffnen.'**
  String get settingsCouldNotOpen;

  /// No description provided for @settingsOpenAppSettings.
  ///
  /// In de, this message translates to:
  /// **'App-Einstellungen öffnen'**
  String get settingsOpenAppSettings;

  /// No description provided for @gpsWaitingFirstUpdate.
  ///
  /// In de, this message translates to:
  /// **'Warte auf die erste Position…'**
  String get gpsWaitingFirstUpdate;

  /// No description provided for @imagePickerOpenCamera.
  ///
  /// In de, this message translates to:
  /// **'Kamera öffnen'**
  String get imagePickerOpenCamera;

  /// No description provided for @imagePickerFromGallery.
  ///
  /// In de, this message translates to:
  /// **'Aus der Galerie wählen'**
  String get imagePickerFromGallery;

  /// No description provided for @imagePickerAnimalAvatar.
  ///
  /// In de, this message translates to:
  /// **'Tier-Avatar wählen'**
  String get imagePickerAnimalAvatar;

  /// No description provided for @animalAvatarDog.
  ///
  /// In de, this message translates to:
  /// **'Hund'**
  String get animalAvatarDog;

  /// No description provided for @animalAvatarCat.
  ///
  /// In de, this message translates to:
  /// **'Katze'**
  String get animalAvatarCat;

  /// No description provided for @animalAvatarGiraffe.
  ///
  /// In de, this message translates to:
  /// **'Giraffe'**
  String get animalAvatarGiraffe;

  /// No description provided for @puzzleDragPieces.
  ///
  /// In de, this message translates to:
  /// **'Zieh die Teile an die richtige Stelle'**
  String get puzzleDragPieces;

  /// No description provided for @puzzleTapPieces.
  ///
  /// In de, this message translates to:
  /// **'Verschieb die Teile durch Antippen'**
  String get puzzleTapPieces;

  /// No description provided for @feedbackTabSend.
  ///
  /// In de, this message translates to:
  /// **'Feedback senden'**
  String get feedbackTabSend;

  /// No description provided for @pwResetRunningFull.
  ///
  /// In de, this message translates to:
  /// **'Du hast vor Kurzem ein neues Passwort festgelegt. Aus Sicherheitsgründen läuft jetzt ein 24-Stunden-Timer.\n\n✓ Dein ALTES Passwort bleibt weiterhin aktiv\n✓ Nach Ablauf kannst du das neue aktivieren\n✓ Erst dann wird das alte ersetzt'**
  String get pwResetRunningFull;

  /// No description provided for @transportRejectedFull.
  ///
  /// In de, this message translates to:
  /// **'Der Server hat die Nachricht abgelehnt. Schick sie stattdessen per E-Mail.'**
  String get transportRejectedFull;

  /// No description provided for @transportUnreachableFull.
  ///
  /// In de, this message translates to:
  /// **'Der Server ist gerade nicht erreichbar. Versuch es später noch einmal oder schick es per E-Mail.'**
  String get transportUnreachableFull;

  /// No description provided for @transportFailedWithCode.
  ///
  /// In de, this message translates to:
  /// **'Senden fehlgeschlagen ({code}). Du kannst deine Rückmeldung stattdessen per E-Mail schicken.'**
  String transportFailedWithCode(String code);

  /// No description provided for @transportNoMailApp.
  ///
  /// In de, this message translates to:
  /// **'Es ließ sich keine E-Mail-App öffnen. Du kannst den Text kopieren und selbst senden.'**
  String get transportNoMailApp;

  /// No description provided for @emergencySmsSubject.
  ///
  /// In de, this message translates to:
  /// **'Notfall-Nachricht von Aurora'**
  String get emergencySmsSubject;

  /// No description provided for @pwResetBannerRunning.
  ///
  /// In de, this message translates to:
  /// **'Passwort-Reset läuft'**
  String get pwResetBannerRunning;

  /// No description provided for @puzzleDragHint.
  ///
  /// In de, this message translates to:
  /// **'Zieh die Teile an die richtige Stelle'**
  String get puzzleDragHint;

  /// No description provided for @puzzleTapHint.
  ///
  /// In de, this message translates to:
  /// **'Verschieb die Teile durch Antippen'**
  String get puzzleTapHint;

  /// No description provided for @medicationConfirm.
  ///
  /// In de, this message translates to:
  /// **'Bestätigen'**
  String get medicationConfirm;

  /// No description provided for @medicationAddFirstAsNeeded.
  ///
  /// In de, this message translates to:
  /// **'Füge dein erstes Bedarfsmedikament hinzu'**
  String get medicationAddFirstAsNeeded;

  /// No description provided for @medicationTakenBy.
  ///
  /// In de, this message translates to:
  /// **'✓ Genommen von {name}'**
  String medicationTakenBy(String name);

  /// No description provided for @medicationRefusedBy.
  ///
  /// In de, this message translates to:
  /// **'✗ Verweigert von {name}'**
  String medicationRefusedBy(String name);

  /// No description provided for @imprintPerLaw.
  ///
  /// In de, this message translates to:
  /// **'Angaben gemäß § 5 TMG'**
  String get imprintPerLaw;

  /// No description provided for @imprintResponsible.
  ///
  /// In de, this message translates to:
  /// **'Verantwortlich für den Inhalt'**
  String get imprintResponsible;

  /// No description provided for @timelineSkipped.
  ///
  /// In de, this message translates to:
  /// **'übersprungen'**
  String get timelineSkipped;

  /// No description provided for @timelineDueSoon.
  ///
  /// In de, this message translates to:
  /// **'Bald fällig'**
  String get timelineDueSoon;

  /// No description provided for @medicationLater.
  ///
  /// In de, this message translates to:
  /// **'später'**
  String get medicationLater;

  /// No description provided for @debugLogHint.
  ///
  /// In de, this message translates to:
  /// **'Dieser Bericht enthält technische Angaben über die App. Kopiere ihn mit dem Knopf oben rechts, um ihn bei Problemen mitzuschicken.'**
  String get debugLogHint;

  /// No description provided for @unsavedChangesTitle.
  ///
  /// In de, this message translates to:
  /// **'Ungespeicherte Änderungen'**
  String get unsavedChangesTitle;

  /// No description provided for @hotlineForYoung.
  ///
  /// In de, this message translates to:
  /// **'Für Kinder und Jugendliche'**
  String get hotlineForYoung;

  /// Beschreibung der Telefonseelsorge. Ohne '24/7' im Text — das sagt jetzt die Gruppenüberschrift.
  ///
  /// In de, this message translates to:
  /// **'Kostenlos und anonym'**
  String get hotlineAnonymousFree;

  /// Erreichbarkeit der Nummer gegen Kummer. Geprüft am 10.08.2026 an der Anbieterseite.
  ///
  /// In de, this message translates to:
  /// **'Mo–Sa 14–20 Uhr'**
  String get hotlineHoursNumberAgainstSorrow;

  /// Beschreibung des Info-Telefons Depression. Der Anbieter sagt selbst, dass es eine ärztliche Beratung nicht ersetzt.
  ///
  /// In de, this message translates to:
  /// **'Informationen, keine Akuthilfe'**
  String get hotlineInfoNotAcute;

  /// Erreichbarkeit des Info-Telefons Depression. Geprüft am 10.08.2026 an der Anbieterseite.
  ///
  /// In de, this message translates to:
  /// **'Mo, Di, Do 13–17 Uhr · Mi, Fr 8:30–12:30 Uhr'**
  String get hotlineHoursDepressionInfo;

  /// Beschreibung des Krisenchats samt seiner Altersgrenze.
  ///
  /// In de, this message translates to:
  /// **'Beratung per Chat, für alle unter 25'**
  String get hotlineChatUnder25;

  /// Überschrift der Notruf-Stufe auf der Hilfefläche.
  ///
  /// In de, this message translates to:
  /// **'Wenn unmittelbar jemand in Gefahr ist'**
  String get helpEmergencyDangerTitle;

  /// Erklärung unter der Notruf-Überschrift.
  ///
  /// In de, this message translates to:
  /// **'Der Notruf ist Tag und Nacht erreichbar, auch ohne Guthaben.'**
  String get helpEmergencyDangerBody;

  /// Beschriftung der Notruf-Schaltfläche. Sie öffnet die Telefon-App mit vorgewählter Nummer und ruft nicht von selbst an.
  ///
  /// In de, this message translates to:
  /// **'Notruf 112'**
  String get helpEmergencyCallEmergencyNumber;

  /// Überschrift über den Beratungsangeboten.
  ///
  /// In de, this message translates to:
  /// **'Wenn du reden oder Beratung brauchst'**
  String get helpTalkTitle;

  /// Gruppenüberschrift für Angebote ohne Zeitgrenze.
  ///
  /// In de, this message translates to:
  /// **'Rund um die Uhr erreichbar'**
  String get helpGroupRoundTheClock;

  /// Gruppenüberschrift für Angebote mit begrenzten Zeiten oder Zielgruppen.
  ///
  /// In de, this message translates to:
  /// **'Zu bestimmten Zeiten erreichbar'**
  String get helpGroupLimitedHours;

  /// Fußzeile der Hilfefläche mit dem Prüfdatum der Erreichbarkeiten.
  ///
  /// In de, this message translates to:
  /// **'Angaben geprüft am {datum}'**
  String helpSourcesCheckedOn(String datum);

  /// No description provided for @cameraCouldNotOpen.
  ///
  /// In de, this message translates to:
  /// **'Die Kamera ließ sich nicht öffnen'**
  String get cameraCouldNotOpen;

  /// No description provided for @feedbackDeviceDiagnostics.
  ///
  /// In de, this message translates to:
  /// **'--- Gerätediagnose ---'**
  String get feedbackDeviceDiagnostics;

  /// No description provided for @eventNoReminder.
  ///
  /// In de, this message translates to:
  /// **'Der Termin steht nur im Kalender. Aurora meldet sich nicht von selbst.'**
  String get eventNoReminder;

  /// No description provided for @unsavedChangesMessage.
  ///
  /// In de, this message translates to:
  /// **'Du hast Änderungen gemacht.\n\nMöchtest du sie speichern?'**
  String get unsavedChangesMessage;

  /// No description provided for @confirmSave.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get confirmSave;

  /// No description provided for @videoCouldNotLoad.
  ///
  /// In de, this message translates to:
  /// **'Das Video ließ sich nicht laden'**
  String get videoCouldNotLoad;

  /// No description provided for @finderDaily.
  ///
  /// In de, this message translates to:
  /// **'täglich'**
  String get finderDaily;

  /// No description provided for @mapNotAvailable.
  ///
  /// In de, this message translates to:
  /// **'Karte nicht verfügbar'**
  String get mapNotAvailable;

  /// No description provided for @medicationAnotherDose.
  ///
  /// In de, this message translates to:
  /// **'Möchtest du trotzdem eine weitere Dosis nehmen?'**
  String get medicationAnotherDose;

  /// No description provided for @feedbackThankYouReceived.
  ///
  /// In de, this message translates to:
  /// **'Wir haben deine Rückmeldung erhalten und melden uns bei Rückfragen per E-Mail.'**
  String get feedbackThankYouReceived;

  /// No description provided for @positionAgeYesterday.
  ///
  /// In de, this message translates to:
  /// **'von gestern'**
  String get positionAgeYesterday;

  /// No description provided for @timePickerTitle.
  ///
  /// In de, this message translates to:
  /// **'Zeit wählen'**
  String get timePickerTitle;

  /// No description provided for @reminderPermissionMissingTitle.
  ///
  /// In de, this message translates to:
  /// **'Aurora darf gerade nicht erinnern'**
  String get reminderPermissionMissingTitle;

  /// No description provided for @reminderPermissionMissingBody.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{Für eine Einnahmezeit sind Erinnerungen eingeschaltet. Ohne die Erlaubnis des Geräts kommt sie nicht an.} other{Für {count} Einnahmezeiten sind Erinnerungen eingeschaltet. Ohne die Erlaubnis des Geräts kommt keine davon an.}}'**
  String reminderPermissionMissingBody(int count);

  /// No description provided for @reminderPermissionMissingAction.
  ///
  /// In de, this message translates to:
  /// **'Erlaubnis geben'**
  String get reminderPermissionMissingAction;

  /// No description provided for @timePickerHours.
  ///
  /// In de, this message translates to:
  /// **'Stunden'**
  String get timePickerHours;

  /// No description provided for @timePickerMinutes.
  ///
  /// In de, this message translates to:
  /// **'Minuten'**
  String get timePickerMinutes;

  /// No description provided for @commentsNoneYet.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Kommentare'**
  String get commentsNoneYet;

  /// No description provided for @notificationDiscreetBody.
  ///
  /// In de, this message translates to:
  /// **'Erinnerung — tippen zum Ansehen'**
  String get notificationDiscreetBody;

  /// No description provided for @reminderNoPermission.
  ///
  /// In de, this message translates to:
  /// **'Ohne die Erlaubnis für Benachrichtigungen kann Aurora nicht erinnern. Du kannst sie in den Android-Einstellungen unter Apps → Aurora → Benachrichtigungen erteilen.'**
  String get reminderNoPermission;

  /// No description provided for @telemetryConsentAccept.
  ///
  /// In de, this message translates to:
  /// **'Ja, gerne'**
  String get telemetryConsentAccept;

  /// No description provided for @telemetryConsentDecline.
  ///
  /// In de, this message translates to:
  /// **'Weiter ohne'**
  String get telemetryConsentDecline;

  /// No description provided for @transparencyGroupTelemetry.
  ///
  /// In de, this message translates to:
  /// **'Telemetrie'**
  String get transparencyGroupTelemetry;

  /// No description provided for @telemetryExampleIntro.
  ///
  /// In de, this message translates to:
  /// **'So sieht eine Meldung aus:'**
  String get telemetryExampleIntro;

  /// No description provided for @telemetryExampleEvent.
  ///
  /// In de, this message translates to:
  /// **'Ereignis'**
  String get telemetryExampleEvent;

  /// No description provided for @telemetryExampleDay.
  ///
  /// In de, this message translates to:
  /// **'Tag'**
  String get telemetryExampleDay;

  /// No description provided for @telemetryExampleVersion.
  ///
  /// In de, this message translates to:
  /// **'App-Version'**
  String get telemetryExampleVersion;

  /// No description provided for @onboardingDismiss.
  ///
  /// In de, this message translates to:
  /// **'Nicht mehr anzeigen'**
  String get onboardingDismiss;

  /// No description provided for @eventStart.
  ///
  /// In de, this message translates to:
  /// **'Beginn'**
  String get eventStart;

  /// No description provided for @eventEnd.
  ///
  /// In de, this message translates to:
  /// **'Ende'**
  String get eventEnd;

  /// No description provided for @chatCapturePhoto.
  ///
  /// In de, this message translates to:
  /// **'Bild aufnehmen'**
  String get chatCapturePhoto;

  /// No description provided for @chatCaptureImageShort.
  ///
  /// In de, this message translates to:
  /// **'Bild'**
  String get chatCaptureImageShort;

  /// No description provided for @doodleErase.
  ///
  /// In de, this message translates to:
  /// **'Radieren'**
  String get doodleErase;

  /// No description provided for @chatRecordVideo.
  ///
  /// In de, this message translates to:
  /// **'Video aufnehmen'**
  String get chatRecordVideo;

  /// No description provided for @chatRecordVideoSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Neues Video erstellen'**
  String get chatRecordVideoSubtitle;

  /// No description provided for @actionDiscard.
  ///
  /// In de, this message translates to:
  /// **'Verwerfen'**
  String get actionDiscard;

  /// No description provided for @actionKeep.
  ///
  /// In de, this message translates to:
  /// **'Behalten'**
  String get actionKeep;

  /// No description provided for @actionDetails.
  ///
  /// In de, this message translates to:
  /// **'Details'**
  String get actionDetails;

  /// No description provided for @resetWaitingPeriodTitle.
  ///
  /// In de, this message translates to:
  /// **'Wartefrist beim Zurücksetzen'**
  String get resetWaitingPeriodTitle;

  /// No description provided for @fieldNameHint.
  ///
  /// In de, this message translates to:
  /// **'z.B. Max, Anna, Leo'**
  String get fieldNameHint;

  /// No description provided for @fieldPasswordHint.
  ///
  /// In de, this message translates to:
  /// **'Mind. 4 Zeichen'**
  String get fieldPasswordHint;

  /// No description provided for @fieldPasswordConfirmHint.
  ///
  /// In de, this message translates to:
  /// **'Passwort wiederholen'**
  String get fieldPasswordConfirmHint;

  /// No description provided for @fieldPasswordEnterHint.
  ///
  /// In de, this message translates to:
  /// **'Passwort eingeben'**
  String get fieldPasswordEnterHint;

  /// No description provided for @feedbackCommunityJoin.
  ///
  /// In de, this message translates to:
  /// **'Tritt unserer Community bei'**
  String get feedbackCommunityJoin;

  /// No description provided for @feedbackDiscord.
  ///
  /// In de, this message translates to:
  /// **'Discord Server'**
  String get feedbackDiscord;

  /// No description provided for @feedbackGithub.
  ///
  /// In de, this message translates to:
  /// **'GitHub'**
  String get feedbackGithub;

  /// No description provided for @feedbackGithubSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Bug Reports & Issues'**
  String get feedbackGithubSubtitle;

  /// No description provided for @timelineProfileSwitch.
  ///
  /// In de, this message translates to:
  /// **'Profil-Wechsel'**
  String get timelineProfileSwitch;

  /// No description provided for @debugLogReportTitle.
  ///
  /// In de, this message translates to:
  /// **'Debug-Log Report'**
  String get debugLogReportTitle;

  /// No description provided for @formPickImage.
  ///
  /// In de, this message translates to:
  /// **'Bild wählen'**
  String get formPickImage;

  /// No description provided for @permissionGrant.
  ///
  /// In de, this message translates to:
  /// **'Berechtigung erteilen'**
  String get permissionGrant;

  /// No description provided for @pwResetRestart.
  ///
  /// In de, this message translates to:
  /// **'Erneut starten'**
  String get pwResetRestart;

  /// No description provided for @navBackToAnchor.
  ///
  /// In de, this message translates to:
  /// **'Zum Anker'**
  String get navBackToAnchor;

  /// No description provided for @mapGpsPositionLoadingHint.
  ///
  /// In de, this message translates to:
  /// **'Einen Moment bitte'**
  String get mapGpsPositionLoadingHint;

  /// No description provided for @voiceRecordingStartFailed.
  ///
  /// In de, this message translates to:
  /// **'Sprachaufnahme konnte nicht starten'**
  String get voiceRecordingStartFailed;

  /// No description provided for @voiceRecordingStopFailed.
  ///
  /// In de, this message translates to:
  /// **'Sprachaufnahme konnte nicht beendet werden'**
  String get voiceRecordingStopFailed;

  /// No description provided for @voiceRecordingDiscardFailed.
  ///
  /// In de, this message translates to:
  /// **'Sprachaufnahme konnte nicht verworfen werden'**
  String get voiceRecordingDiscardFailed;

  /// No description provided for @trackingPermissionDeniedHint.
  ///
  /// In de, this message translates to:
  /// **'GPS-Berechtigung verweigert. Aktiviere sie in den Einstellungen.'**
  String get trackingPermissionDeniedHint;

  /// No description provided for @pwResetVisibleToAll.
  ///
  /// In de, this message translates to:
  /// **'Die Frist läuft sichtbar für alle'**
  String get pwResetVisibleToAll;

  /// No description provided for @pwResetRestartResetsTimer.
  ///
  /// In de, this message translates to:
  /// **'Tipp: Erneuter Start setzt die Frist zurück'**
  String get pwResetRestartResetsTimer;

  /// No description provided for @pwResetActivatedAtNextLogin.
  ///
  /// In de, this message translates to:
  /// **'Das neue Passwort wird beim nächsten Login aktiviert'**
  String get pwResetActivatedAtNextLogin;

  /// No description provided for @imagePickerCameraDeniedForever.
  ///
  /// In de, this message translates to:
  /// **'Die Kamera-Berechtigung wurde dauerhaft verweigert. Aktiviere sie in den Einstellungen.'**
  String get imagePickerCameraDeniedForever;

  /// No description provided for @imagePickerGalleryDeniedForever.
  ///
  /// In de, this message translates to:
  /// **'Die Galerie-Berechtigung wurde dauerhaft verweigert. Aktiviere sie in den Einstellungen.'**
  String get imagePickerGalleryDeniedForever;

  /// No description provided for @permissionCameraTitle.
  ///
  /// In de, this message translates to:
  /// **'Kamera-Berechtigung'**
  String get permissionCameraTitle;

  /// No description provided for @permissionGalleryTitle.
  ///
  /// In de, this message translates to:
  /// **'Galerie-Berechtigung'**
  String get permissionGalleryTitle;

  /// No description provided for @profileResetFristExplanation.
  ///
  /// In de, this message translates to:
  /// **'So lange wartet ein Zurücksetzen deines Passworts, bevor es greift. Melde dich in dieser Zeit an, bricht es ab.'**
  String get profileResetFristExplanation;

  /// No description provided for @cameraNotFound.
  ///
  /// In de, this message translates to:
  /// **'Keine Kamera gefunden'**
  String get cameraNotFound;

  /// No description provided for @validationNameRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte Name eingeben'**
  String get validationNameRequired;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte Passwort eingeben'**
  String get validationPasswordRequired;

  /// No description provided for @transportCopyManually.
  ///
  /// In de, this message translates to:
  /// **'Du kannst den Text kopieren und manuell senden.'**
  String get transportCopyManually;

  /// No description provided for @statusSending.
  ///
  /// In de, this message translates to:
  /// **'Wird gesendet...'**
  String get statusSending;

  /// No description provided for @errorReportSendButton.
  ///
  /// In de, this message translates to:
  /// **'Report senden'**
  String get errorReportSendButton;

  /// No description provided for @settingsGpsStatusAlwaysReady.
  ///
  /// In de, this message translates to:
  /// **'✅ Immer erlaubt (Bereit!)'**
  String get settingsGpsStatusAlwaysReady;

  /// No description provided for @gpsActive.
  ///
  /// In de, this message translates to:
  /// **'GPS aktiv'**
  String get gpsActive;

  /// No description provided for @gpsOff.
  ///
  /// In de, this message translates to:
  /// **'GPS aus'**
  String get gpsOff;

  /// No description provided for @gpsStatusUnknown.
  ///
  /// In de, this message translates to:
  /// **'GPS Status unbekannt'**
  String get gpsStatusUnknown;

  /// No description provided for @gpsPermissionMissing.
  ///
  /// In de, this message translates to:
  /// **'GPS-Berechtigung fehlt'**
  String get gpsPermissionMissing;

  /// No description provided for @gpsServiceDisabled.
  ///
  /// In de, this message translates to:
  /// **'GPS-Service deaktiviert'**
  String get gpsServiceDisabled;

  /// No description provided for @permissionMissingShort.
  ///
  /// In de, this message translates to:
  /// **'Berechtigung fehlt'**
  String get permissionMissingShort;

  /// No description provided for @pwResetWrongPassword.
  ///
  /// In de, this message translates to:
  /// **'Falsches Passwort'**
  String get pwResetWrongPassword;

  /// No description provided for @pwResetStartTitle.
  ///
  /// In de, this message translates to:
  /// **'Passwort-Reset starten?'**
  String get pwResetStartTitle;

  /// No description provided for @pwResetExpired.
  ///
  /// In de, this message translates to:
  /// **'Frist ist abgelaufen'**
  String get pwResetExpired;

  /// No description provided for @pwResetForgotPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort vergessen?'**
  String get pwResetForgotPassword;

  /// No description provided for @commentWritePlaceholder.
  ///
  /// In de, this message translates to:
  /// **'Kommentar schreiben...'**
  String get commentWritePlaceholder;

  /// No description provided for @profileVisibilityTitle.
  ///
  /// In de, this message translates to:
  /// **'Zuordnung zu Profilen'**
  String get profileVisibilityTitle;

  /// No description provided for @addressUnknown.
  ///
  /// In de, this message translates to:
  /// **'Unbekannte Adresse'**
  String get addressUnknown;

  /// No description provided for @activateNow.
  ///
  /// In de, this message translates to:
  /// **'Jetzt aktivieren'**
  String get activateNow;

  /// No description provided for @eventRemindMe.
  ///
  /// In de, this message translates to:
  /// **'Erinnerung'**
  String get eventRemindMe;

  /// No description provided for @noProfileAvailable.
  ///
  /// In de, this message translates to:
  /// **'Kein Profil vorhanden'**
  String get noProfileAvailable;

  /// No description provided for @ratingVeryNegative.
  ///
  /// In de, this message translates to:
  /// **'Sehr negativ'**
  String get ratingVeryNegative;

  /// No description provided for @ratingVeryPositive.
  ///
  /// In de, this message translates to:
  /// **'Sehr positiv'**
  String get ratingVeryPositive;

  /// No description provided for @errorReportHelpUs.
  ///
  /// In de, this message translates to:
  /// **'Hilf uns, den Fehler zu beheben!'**
  String get errorReportHelpUs;

  /// No description provided for @errorReportDetailsSection.
  ///
  /// In de, this message translates to:
  /// **'Report Details'**
  String get errorReportDetailsSection;

  /// No description provided for @trackingLabel.
  ///
  /// In de, this message translates to:
  /// **'GPS-Tracking: '**
  String get trackingLabel;

  /// No description provided for @trackingLastUpdate.
  ///
  /// In de, this message translates to:
  /// **'Letztes Update: {time}'**
  String trackingLastUpdate(Object time);

  /// No description provided for @profileSwitchError.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Profilwechsel: {error}'**
  String profileSwitchError(Object error);

  /// No description provided for @gpsError.
  ///
  /// In de, this message translates to:
  /// **'GPS-Fehler'**
  String get gpsError;

  /// No description provided for @statusActive.
  ///
  /// In de, this message translates to:
  /// **'Aktiv'**
  String get statusActive;

  /// No description provided for @statusPaused.
  ///
  /// In de, this message translates to:
  /// **'Pausiert'**
  String get statusPaused;

  /// No description provided for @timeSecondsAgo.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{vor einer Sekunde} other{vor {count} Sekunden}}'**
  String timeSecondsAgo(int count);

  /// No description provided for @timeInMinutes.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{in einer Minute} other{in {count} Minuten}}'**
  String timeInMinutes(int count);

  /// No description provided for @timeInHours.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{in einer Stunde} other{in {count} Stunden}}'**
  String timeInHours(int count);

  /// No description provided for @timeInDays.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{in einem Tag} other{in {count} Tagen}}'**
  String timeInDays(int count);

  /// No description provided for @languageFollowApp.
  ///
  /// In de, this message translates to:
  /// **'Sprache der App'**
  String get languageFollowApp;

  /// No description provided for @profileLanguageSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Die Sprache, in der Aurora mit diesem Anteil spricht'**
  String get profileLanguageSubtitle;

  /// No description provided for @contactCategoryFamily.
  ///
  /// In de, this message translates to:
  /// **'Familie'**
  String get contactCategoryFamily;

  /// No description provided for @contactCategoryFriends.
  ///
  /// In de, this message translates to:
  /// **'Freunde'**
  String get contactCategoryFriends;

  /// No description provided for @contactCategoryTherapists.
  ///
  /// In de, this message translates to:
  /// **'Therapeuten'**
  String get contactCategoryTherapists;

  /// No description provided for @contactCategoryDoctors.
  ///
  /// In de, this message translates to:
  /// **'Ärzte'**
  String get contactCategoryDoctors;

  /// No description provided for @contactCategoryEmergency.
  ///
  /// In de, this message translates to:
  /// **'Notfall'**
  String get contactCategoryEmergency;

  /// No description provided for @contactCategoryOther.
  ///
  /// In de, this message translates to:
  /// **'Sonstiges'**
  String get contactCategoryOther;

  /// No description provided for @finderTypeLocation.
  ///
  /// In de, this message translates to:
  /// **'Ort'**
  String get finderTypeLocation;

  /// No description provided for @finderTypeItem.
  ///
  /// In de, this message translates to:
  /// **'Gegenstand'**
  String get finderTypeItem;

  /// No description provided for @diaryPriorityLow.
  ///
  /// In de, this message translates to:
  /// **'Niedrig'**
  String get diaryPriorityLow;

  /// No description provided for @diaryPriorityMedium.
  ///
  /// In de, this message translates to:
  /// **'Mittel'**
  String get diaryPriorityMedium;

  /// No description provided for @diaryPriorityHigh.
  ///
  /// In de, this message translates to:
  /// **'Hoch'**
  String get diaryPriorityHigh;

  /// No description provided for @diaryPriorityCritical.
  ///
  /// In de, this message translates to:
  /// **'Kritisch'**
  String get diaryPriorityCritical;

  /// No description provided for @moodNeutral.
  ///
  /// In de, this message translates to:
  /// **'Neutral'**
  String get moodNeutral;

  /// No description provided for @moodSad.
  ///
  /// In de, this message translates to:
  /// **'Traurig'**
  String get moodSad;

  /// No description provided for @moodVerySad.
  ///
  /// In de, this message translates to:
  /// **'Sehr traurig'**
  String get moodVerySad;

  /// No description provided for @moodExcited.
  ///
  /// In de, this message translates to:
  /// **'Aufgeregt'**
  String get moodExcited;

  /// No description provided for @timeHoursMinutesAgo.
  ///
  /// In de, this message translates to:
  /// **'vor {hours} Std {minutes} Min'**
  String timeHoursMinutesAgo(Object hours, Object minutes);

  /// No description provided for @presenceLastFront.
  ///
  /// In de, this message translates to:
  /// **'zuletzt {when}'**
  String presenceLastFront(Object when);

  /// No description provided for @privacyGlanceBody.
  ///
  /// In de, this message translates to:
  /// **'Aurora speichert alles auf deinem Gerät. Drei Dinge verlassen es — und nur, wenn du sie auslöst oder erlaubst: abgesendetes Feedback, Telemetrie nach deiner Zustimmung, und die Kartenanfragen an OpenStreetMap.\n\nWas wann gesendet wurde, steht wörtlich in den Einstellungen unter „Was Aurora sendet\". Nichts davon lässt sich auf dich zurückführen.'**
  String get privacyGlanceBody;

  /// No description provided for @privacyStoredBody.
  ///
  /// In de, this message translates to:
  /// **'Diese Daten liegen in der lokalen Datenbank auf deinem Gerät:\n\n• Anteile und Einstellungen\n• Nachrichten zwischen Anteilen\n• Termine im Kalender\n• Medikamentenpläne und Einnahmen\n• Tagebuch- und Notfalleinträge\n• Kontakte mit Bewertungen und Notizen\n• Orte und Gegenstände aus dem Finder\n• Standortverlauf und Anteilswechsel\n• Bilder, Videos und Sprachnachrichten\n\nNichts davon wird übertragen.'**
  String get privacyStoredBody;

  /// No description provided for @privacyTransmissionBody.
  ///
  /// In de, this message translates to:
  /// **'Feedback — nur wenn du das Formular absendest. Es enthält deinen Text, die App-Version und das Gerätemodell. Keinen Namen, keine Kennung, keinen Ort.\n\nTelemetrie — nur nach deiner ausdrücklichen Zustimmung, die du jederzeit zurücknehmen kannst. Ein Ereignis trägt drei Felder: was geschehen ist, an welchem Tag, mit welcher App-Version. Keine Uhrzeit, keine Kennung.\n\nKarten — beim Anzeigen einer Karte und beim Auflösen einer Adresse gehen der gezeigte Ausschnitt und deine IP-Adresse an OpenStreetMap. Das ist die Bedingung dafür, dass es überhaupt eine Karte gibt.\n\nNie übertragen werden: Standortverlauf, Anteile, Nachrichten, Termine, Medikamente, Tagebuch und Kontakte.'**
  String get privacyTransmissionBody;

  /// No description provided for @privacyPermissions.
  ///
  /// In de, this message translates to:
  /// **'Berechtigungen'**
  String get privacyPermissions;

  /// No description provided for @privacyPermissionsBody.
  ///
  /// In de, this message translates to:
  /// **'• Standort — für die Karte, den Standortverlauf und den Notfall-Schirm. Er bleibt auf dem Gerät.\n• Standort im Hintergrund — nur wenn du die durchgehende Aufzeichnung einschaltest. Ohne diesen Schalter wird sie nicht gebraucht.\n• Kamera und Mikrofon — für Fotos und Sprachnachrichten.\n• Speicher — zum Laden von Bildern und Videos aus der Galerie.\n• Benachrichtigungen und Wecker — für Erinnerungen an Medikamente und Termine.\n\nJede Berechtigung lässt sich in den Systemeinstellungen entziehen. Die App sagt dann, was ohne sie nicht geht.'**
  String get privacyPermissionsBody;

  /// No description provided for @privacySecurity.
  ///
  /// In de, this message translates to:
  /// **'Datensicherheit'**
  String get privacySecurity;

  /// No description provided for @privacySecurityBody.
  ///
  /// In de, this message translates to:
  /// **'• Alle Daten liegen lokal, es gibt keine Cloud-Synchronisation.\n• Anteile lassen sich mit einem Passwort schützen.\n• Es gibt keine Nutzerkonten und keine Anmeldung.\n\nFür Sicherungen bist du selbst zuständig. Geht das Gerät verloren oder kaputt, sind die Daten weg — das ist der Preis dafür, dass sie nirgendwo sonst liegen.'**
  String get privacySecurityBody;

  /// No description provided for @privacyDeletionBody.
  ///
  /// In de, this message translates to:
  /// **'• Einzelne Einträge und Nachrichten kannst du löschen.\n• Anteile lassen sich deaktivieren oder löschen.\n• In den Einstellungen gibt es „Alle Daten löschen\".\n• Beim Deinstallieren der App verschwindet alles mit.\n\nGelöschtes lässt sich nicht wiederherstellen.'**
  String get privacyDeletionBody;

  /// No description provided for @privacyRights.
  ///
  /// In de, this message translates to:
  /// **'Deine Rechte'**
  String get privacyRights;

  /// No description provided for @privacyRightsBody.
  ///
  /// In de, this message translates to:
  /// **'Nach der DSGVO hast du Recht auf Auskunft, Berichtigung, Löschung, Einschränkung, Datenübertragbarkeit und Widerspruch. Weil alle Daten auf deinem Gerät liegen, übst du die meisten davon unmittelbar in der App aus.\n\nFür abgesendetes Feedback und für Telemetrie wende dich an die Adresse unten. Du hast außerdem das Recht, dich bei einer Datenschutz-Aufsichtsbehörde zu beschweren.'**
  String get privacyRightsBody;

  /// No description provided for @privacyMinorsBody.
  ///
  /// In de, this message translates to:
  /// **'Aurora darf von Minderjährigen genutzt werden. Über sie werden keine anderen Daten erhoben als über alle anderen — also keine, außer den oben genannten drei Wegen.\n\nBei jüngeren Nutzerinnen und Nutzern ist es sinnvoll, wenn Erziehungsberechtigte die Einrichtung begleiten.'**
  String get privacyMinorsBody;

  /// No description provided for @privacyChangesBody.
  ///
  /// In de, this message translates to:
  /// **'Diese Erklärung kann sich mit Aktualisierungen der App ändern. Die jeweils geltende Fassung steht hier und trägt unten ihr Datum.'**
  String get privacyChangesBody;

  /// No description provided for @privacyContact.
  ///
  /// In de, this message translates to:
  /// **'Verantwortlicher und Kontakt'**
  String get privacyContact;

  /// No description provided for @privacyAsOf.
  ///
  /// In de, this message translates to:
  /// **'Stand: {date}'**
  String privacyAsOf(Object date);

  /// No description provided for @startupFailedTitle.
  ///
  /// In de, this message translates to:
  /// **'Aurora konnte nicht starten'**
  String get startupFailedTitle;

  /// No description provided for @startupFailedBody.
  ///
  /// In de, this message translates to:
  /// **'Etwas beim Hochfahren ist schiefgegangen. Du kannst es noch einmal versuchen. Hilft das nicht, lässt sich alles Gespeicherte löschen — danach startet Aurora leer.'**
  String get startupFailedBody;

  /// No description provided for @startupRetry.
  ///
  /// In de, this message translates to:
  /// **'Noch einmal versuchen'**
  String get startupRetry;

  /// No description provided for @startupDeleteAll.
  ///
  /// In de, this message translates to:
  /// **'Alle Daten löschen'**
  String get startupDeleteAll;

  /// No description provided for @startupDeleteIncomplete.
  ///
  /// In de, this message translates to:
  /// **'Nicht alles konnte gelöscht werden. Ein Teil ist noch da.'**
  String get startupDeleteIncomplete;

  /// No description provided for @reminderPermissionBlocked.
  ///
  /// In de, this message translates to:
  /// **'Aurora darf noch nicht erinnern. Die Erlaubnis lässt sich in den Systemeinstellungen erteilen.'**
  String get reminderPermissionBlocked;

  /// No description provided for @reminderOpenSettings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen öffnen'**
  String get reminderOpenSettings;

  /// No description provided for @settingsTrackingPermissionNeeded.
  ///
  /// In de, this message translates to:
  /// **'Für die Wegaufzeichnung braucht Aurora Zugriff auf den Standort.'**
  String get settingsTrackingPermissionNeeded;

  /// No description provided for @settingsHowToEnableLocation.
  ///
  /// In de, this message translates to:
  /// **'So gibst du den Standort frei:'**
  String get settingsHowToEnableLocation;

  /// Bewusst NICHT „Immer erlauben". Die Aufzeichnung läuft über einen Vordergrunddienst, der aus der sichtbaren App startet — dafür genügt „Bei Nutzung", und Aurora bleibt der unheimlichsten Berechtigung fern, die Android kennt.
  ///
  /// In de, this message translates to:
  /// **'Wähle „Bei Nutzung der App erlauben\"'**
  String get settingsStepChooseWhileUsing;

  /// No description provided for @settingsTrackingNotice.
  ///
  /// In de, this message translates to:
  /// **'Solange Aurora aufzeichnet, steht eine Benachrichtigung in deiner Leiste. Verschwindet sie, wird nicht aufgezeichnet.'**
  String get settingsTrackingNotice;

  /// Titel der dauerhaften Benachrichtigung des Vordergrunddienstes, solange der Weg aufgezeichnet wird. Sie ist die sichtbare Zusage: aufgezeichnet wird nur, solange sie steht.
  ///
  /// In de, this message translates to:
  /// **'Aurora merkt sich deinen Weg'**
  String get locationTrackingNotificationTitle;

  /// Text der dauerhaften Benachrichtigung. Nennt den Grund und dass die Daten das Gerät nicht verlassen. Genusfrei formulieren.
  ///
  /// In de, this message translates to:
  /// **'Damit du später wiederfindest, wo du warst. Bleibt auf dem Gerät.'**
  String get locationTrackingNotificationBody;

  /// Knopf im Profil-Dialog. Nennt den Anteil, weil "Profil wechseln" falsch ist, solange man in keinem war.
  ///
  /// In de, this message translates to:
  /// **'Weiter als {name}'**
  String profileContinueAs(String name);

  /// Derselbe Knopf, waehrend der Wechsel laeuft.
  ///
  /// In de, this message translates to:
  /// **'Einen Moment …'**
  String get profileContinueInProgress;

  /// Meldung nach einem Geraeteneustart. Der Vordergrunddienst darf aus dem Hintergrund nicht starten, also erfaehrt die Nutzerin es statt es stillschweigend zu verlieren.
  ///
  /// In de, this message translates to:
  /// **'Aufzeichnung pausiert'**
  String get trackingPausedTitle;

  /// Text derselben Meldung. Sagt, was zu tun ist — ein Griff.
  ///
  /// In de, this message translates to:
  /// **'Nach dem Neustart zeichnet Aurora deinen Weg erst wieder auf, wenn du sie einmal öffnest. Tippe hier.'**
  String get trackingPausedBody;

  /// Beschriftung des Info-Knopfes auf der Profilauswahl
  ///
  /// In de, this message translates to:
  /// **'Über Aurora'**
  String get aboutAuroraSemantics;

  /// Vorlese-Beschriftung des schnellen Zeitbands
  ///
  /// In de, this message translates to:
  /// **'Zeitachse öffnen'**
  String get openTimelineSemantics;

  /// Vorlese-Beschriftung der klickbaren Zeitkarte
  ///
  /// In de, this message translates to:
  /// **'Zeitachse öffnen: Karte mit Zeit und Ort'**
  String get timeMapSemantics;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
