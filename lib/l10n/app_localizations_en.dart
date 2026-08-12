// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Aurora';

  @override
  String get appSubtitle => 'Your safe companion in everyday life with DIS';

  @override
  String get appDescription =>
      'Aurora helps you organize your daily life and communicate within your system.';

  @override
  String get tabChat => 'Chat';

  @override
  String get tabFeedback => 'Feedback';

  @override
  String get tabCalendar => 'Calendar';

  @override
  String get tabMedication => 'Medication';

  @override
  String get tabDiary => 'Diary';

  @override
  String get tabContacts => 'Contacts';

  @override
  String get tabFinder => 'Finder';

  @override
  String get tabEmergency => 'Emergency';

  @override
  String get tabHelp => 'Help';

  @override
  String get tabMantras => 'Mantras';

  @override
  String get tabGames => 'Games';

  @override
  String get tabTimeline => 'Timeline';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionClose => 'Close';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get actionBack => 'Back';

  @override
  String get actionQuit => 'Quit';

  @override
  String get actionSend => 'Send';

  @override
  String get actionShare => 'Share';

  @override
  String get actionDone => 'Done';

  @override
  String get mainSettingLogout => 'Settings / Logout';

  @override
  String get dialogExitTitle => 'Exit app?';

  @override
  String get dialogExitMessage => 'Do you really want to exit Aurora?';

  @override
  String get menuProfileEdit => 'Edit profile';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuLogout => 'Logout';

  @override
  String get profileMenuTitle => 'Profile and settings';

  @override
  String get presenceRecentTitle => 'Who was here?';

  @override
  String get eventLocationTitle => 'Where does this take place?';

  @override
  String get eventLocationOther => 'Somewhere else';

  @override
  String get eventLocationNone => 'No place';

  @override
  String get eventLocationLabel => 'Place';

  @override
  String get eventLocationUnnamed => 'Place on the map';

  @override
  String get mapLocationNeeded =>
      'Aurora needs your location for this map. It stays on the device.';

  @override
  String get mapLocationAllow => 'Allow';

  @override
  String get profileSelectionTitle => 'Who is here right now?';

  @override
  String get profileNewProfile => 'New Profile';

  @override
  String get profileCreationTitle => 'Create new profile';

  @override
  String get profileCreationSubtitle =>
      'Who would like to introduce themselves?';

  @override
  String get profileCreationDescription =>
      'Create your personal profile with name, color, and avatar. Each profile can be customized individually and receives appropriate permissions based on age.';

  @override
  String get profileEditTitle => 'Edit profile';

  @override
  String get profileEditSubtitle => 'Customize your settings';

  @override
  String get profileSectionIdentity => '👤 Identity';

  @override
  String get profileSectionAge => '🎂 Age';

  @override
  String get profileSectionColor => '🎨 Color';

  @override
  String get profileSectionSecurity => '🔒 Security Questions';

  @override
  String get profileWhoAreYou => 'Who are you?';

  @override
  String get profileWhoAreYouDescription =>
      'Enter your name and choose an avatar. This way everyone in the system can recognize and distinguish you. You can also take a photo, choose from the gallery, or use one of the cute animal templates.';

  @override
  String get profileColorTitle => 'Your unique color';

  @override
  String get profileColorDescription =>
      'Your color makes you unmistakable in the system.';

  @override
  String get profileAgeTitle => 'How old are you?';

  @override
  String get profileAgeDescription =>
      'Your age determines which features you can use.';

  @override
  String get profileSecurityTitle => 'Protect your profile';

  @override
  String get profileSecurityDescription =>
      'Optionally, you can set a password (minimum 4 characters).';

  @override
  String get profilePasswordOptionalInfo =>
      'The password is optional. Leave the fields empty if you don\'t want to set one.';

  @override
  String get profileModeChild => 'Child Mode';

  @override
  String get profileModeFullAccess => 'Full Access';

  @override
  String get profileModeChildDescription =>
      'Access to: Chat (Doodles), Diary, Games, Timeline';

  @override
  String get profileModeFullDescription =>
      'Access to: All features (Chat, Calendar, Contacts, Medication, etc.)';

  @override
  String get profileActionSaveChanges => 'Save changes';

  @override
  String get profileActionCreateProfile => 'Create profile ✓';

  @override
  String get profileDeactivateTitle => 'Deactivate profile?';

  @override
  String profileDeactivateMessage(String name) {
    return 'Do you want to deactivate the profile \"$name\"?\n\nIt will be hidden but can be reactivated later.';
  }

  @override
  String get profileDeactivated => 'Profile deactivated';

  @override
  String get profileDeactivate => 'Deactivate';

  @override
  String get profileEditComingSoon => 'Edit coming soon';

  @override
  String get profileNameExists => 'A profile with this name already exists';

  @override
  String get fieldName => 'Name';

  @override
  String get fieldPassword => 'Password';

  @override
  String get fieldPasswordConfirm => 'Confirm password';

  @override
  String get fieldAge => 'Age';

  @override
  String get fieldColor => 'Color';

  @override
  String get fieldAvatar => 'Avatar';

  @override
  String get validationRequired => 'Required field';

  @override
  String get validationPasswordLength => 'Minimum 4 characters';

  @override
  String get validationPasswordMismatch => 'Passwords do not match';

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get errorNoProfile => 'No profile selected';

  @override
  String get errorNoPermission =>
      'You do not have permission to send chat messages';

  @override
  String get chatTitle => 'Chat';

  @override
  String get chatEmptyTitle => 'No messages yet';

  @override
  String get chatEmptySubtitle => 'Share your thoughts with the system';

  @override
  String get chatMessageDoodle => '[Doodle]';

  @override
  String get chatMessageVoice => '[Voice message]';

  @override
  String get chatMessageImage => '[Image]';

  @override
  String get chatMessageVideo => '[Video]';

  @override
  String chatErrorSending(String error) {
    return 'Error sending: $error';
  }

  @override
  String chatErrorSendingVoice(String error) {
    return 'Error sending voice message: $error';
  }

  @override
  String chatErrorSendingImage(String error) {
    return 'Error sending image: $error';
  }

  @override
  String chatErrorSendingVideo(String error) {
    return 'Error sending video: $error';
  }

  @override
  String chatErrorSendingDoodle(String error) {
    return 'Error sending: $error';
  }

  @override
  String get chatRecordingInProgress => 'Recording...';

  @override
  String get chatRecordingHint => 'Tap Stop to send the voice message';

  @override
  String get chatRecordingStop => 'Stop';

  @override
  String get chatErrorMicPermission => 'Microphone permission required';

  @override
  String get chatErrorRecordingStart => 'Could not start recording';

  @override
  String get chatInputHint => 'Write a message...';

  @override
  String get chatMessageFieldLabel => 'Message';

  @override
  String get chatAddMedia => 'Add more media';

  @override
  String get chatSendMessage => 'Send message';

  @override
  String get chatMediaSheetTitle => 'Add media';

  @override
  String get chatNoPermissionHint => 'No permission to send';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get medicationTitle => 'Medication';

  @override
  String get medicationNewTitle => 'New Medication';

  @override
  String get medicationEditTitle => 'Edit Medication';

  @override
  String get medicationDetailTitle => 'Medication Details';

  @override
  String get medicationNotFound => 'Medication Not Found';

  @override
  String get medicationNotFoundMessage => 'This medication no longer exists';

  @override
  String get medicationTabDaily => 'Daily Medication';

  @override
  String get medicationTabAsNeeded => 'As-Needed Medication';

  @override
  String get medicationEmptyTitle => 'No medications 💊';

  @override
  String get medicationEmptySubtitle => 'Add your first medication';

  @override
  String get medicationEmptyAsNeededTitle => 'No as-needed medications 🩹';

  @override
  String get medicationEmptyAsNeededSubtitle =>
      'Add your first as-needed medication';

  @override
  String get medicationToday => 'Today';

  @override
  String get medicationStatMedications => 'Medications';

  @override
  String get medicationStatDoses => 'Doses';

  @override
  String medicationMarkedTaken(String name) {
    return '$name marked as taken';
  }

  @override
  String medicationMarkedRefused(String name) {
    return '$name marked as refused';
  }

  @override
  String get medicationRefusalDialogTitle => 'Document refusal';

  @override
  String medicationRefusalDialogMessage(String name) {
    return '$name will be marked as refused.';
  }

  @override
  String get medicationRefusalReasonLabel => 'Reason (optional)';

  @override
  String get medicationRefusalReasonHint => 'e.g. nausea, tired, etc.';

  @override
  String get medicationRefusalWithoutNote => 'Without note';

  @override
  String get medicationFeedbackDialogTitle => 'Add feedback';

  @override
  String medicationFeedbackQuestion(String name) {
    return 'How did you feel after taking $name?';
  }

  @override
  String get medicationFeedbackLabel => 'Your experience';

  @override
  String get medicationFeedbackHint =>
      'e.g. \"Felt tired\", \"Helped well\", etc.';

  @override
  String get medicationFeedbackSaved => 'Feedback saved';

  @override
  String get medicationFeedbackViewTitle => 'Feedback';

  @override
  String get diaryTitle => 'Diary';

  @override
  String get diaryEmptyTitle => 'Your diary is waiting for you! ✨';

  @override
  String get diaryEmptySubtitle =>
      'Capture your thoughts, experiences, and moments';

  @override
  String get contactsTitle => 'Contacts';

  @override
  String get contactsFilterAll => 'All';

  @override
  String get contactsEmptyTitle => 'No contacts yet 👥';

  @override
  String get contactsEmptySubtitle => 'Tap + to add a contact';

  @override
  String get contactsEmptyFilteredTitle => 'No contacts found 🔍';

  @override
  String get contactsEmptyFilteredSubtitle => 'Try a different filter';

  @override
  String get finderTitle => 'Finder';

  @override
  String get finderTabLocations => 'Places';

  @override
  String get finderTabItems => 'Items';

  @override
  String get finderEmptyLocationsTitle => 'No locations yet';

  @override
  String get finderEmptyItemsTitle => 'No items yet';

  @override
  String get finderEmptyLocationsSubtitle => 'Tap + to add a location';

  @override
  String get finderEmptyItemsSubtitle => 'Tap + to add an item';

  @override
  String get emergencyTitle => 'Emergency';

  @override
  String get emergencyEmptyTitle => 'No emergency contacts yet';

  @override
  String get emergencyEmptySubtitle =>
      'Add contacts with the \"Emergency\" category to see them here.';

  @override
  String get emergencyEmptyDescription =>
      'These contacts can be quickly notified in an emergency.';

  @override
  String get emergencyEmptyAddContact => 'Add emergency contact';

  @override
  String get emergencyEmptyOpenHelp => 'Help and crisis lines';

  @override
  String get emergencySendSmsAll => 'Send EMERGENCY SMS to all';

  @override
  String get emergencyShareAll => 'Send to all via app';

  @override
  String get emergencySmsDialogTitle => 'Send EMERGENCY SMS to all?';

  @override
  String emergencySmsDialogMessage(int count) {
    return 'The emergency message will be sent to $count contacts.';
  }

  @override
  String get emergencySendNow => 'Send now';

  @override
  String get emergencyMessagePreparing => 'Preparing emergency message...';

  @override
  String emergencyErrorSms(String error) {
    return 'Error sending SMS: $error';
  }

  @override
  String emergencyErrorShare(String error) {
    return 'Error sharing: $error';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionDebug => '🔧 Debug Options';

  @override
  String get settingsDebugInfo =>
      'These options are only visible during development';

  @override
  String get settingsDebugSkipCooldown => '⏩ Set cooldown to 20s';

  @override
  String settingsDebugSkipCooldownInfo(String name, String time) {
    return 'Profile: $name\nRemaining: $time';
  }

  @override
  String get settingsDebugCooldownSet =>
      '⏩ Timer set to 20 seconds!\nAfter 20s the password can be activated.';

  @override
  String get settingsDebugCooldownError => '❌ Error setting timer';

  @override
  String get settingsDeleteAllData => 'Delete all data';

  @override
  String get settingsDeleteAllDataSubtitle =>
      'Deletes all profiles, messages, events, and attachments';

  @override
  String get settingsDeleteConfirmTitle => '⚠️ Warning';

  @override
  String get settingsDeleteConfirmMessage =>
      'This action will delete ALL data:\n\n• All profiles\n• All chat messages\n• All calendar events\n• All medications & intake logs\n• All contacts\n• All finder items\n• All crisis diary entries\n• All navigation data\n• All settings\n• All doodle attachments\n\nThis CANNOT be undone!';

  @override
  String get settingsDeleteSuccess => '✅ All data has been deleted';

  @override
  String get settingsSectionManagement => 'Management';

  @override
  String get settingsPermissions => 'Rights & Permissions';

  @override
  String get settingsPermissionsSubtitle => 'Manage profile access rights';

  @override
  String get settingsSectionGlobal => 'Global Settings';

  @override
  String get settingsGlobalTrackingInfo => 'What is \"Permanent tracking\"?';

  @override
  String get settingsGlobalTrackingDescription =>
      'As an admin, you can centrally control GPS tracking for ALL profiles. When enabled:';

  @override
  String get settingsGlobalTrackingBullet1 =>
      'Location is continuously recorded';

  @override
  String get settingsGlobalTrackingBullet2 => 'Works in the background';

  @override
  String get settingsGlobalTrackingBullet3 =>
      'Overrides individual profile settings';

  @override
  String get settingsGlobalTrackingBullet4 =>
      'All profiles are automatically tracked';

  @override
  String get settingsGlobalTrackingRequirement =>
      'Requirement: The Android permission \"Allow all the time\" must be enabled for tracking to work when the app is closed.';

  @override
  String get settingsGpsPermissionTitle => 'GPS Permission';

  @override
  String get settingsGpsStatusDisabled => 'GPS service disabled';

  @override
  String get settingsGpsStatusDenied => 'Permission denied';

  @override
  String get settingsGpsStatusDeniedForever => 'Permanently denied';

  @override
  String get settingsGpsStatusWhileInUse => 'Only while using the app';

  @override
  String get settingsGpsStatusAlways => 'Always allowed ✓';

  @override
  String get settingsGpsStatusUnknown => 'Unknown';

  @override
  String get settingsGpsReady => 'Perfect! Background tracking is ready.';

  @override
  String get settingsGpsInstructions => 'How to enable \"Allow all the time\":';

  @override
  String get settingsGpsStep1 => 'Tap \"Open Android settings\" ↓';

  @override
  String get settingsGpsStep2 => 'Select \"Permission\" → \"Location\"';

  @override
  String get settingsGpsStep3 => 'Select \"Allow all the time\"';

  @override
  String get settingsGpsOpenSettings => 'Open Android settings';

  @override
  String get settingsGpsOpenLocationSettings => 'Open location settings';

  @override
  String get settingsGpsPrivacyNote =>
      'Your location stays on this device. Maps pass it to OpenStreetMap, never to us.';

  @override
  String get settingsTrackingPermanent => 'Permanent tracking';

  @override
  String get settingsTrackingPermanentOn =>
      'GPS runs permanently for all profiles';

  @override
  String get settingsTrackingPermanentOff => 'GPS only as needed per profile';

  @override
  String get settingsTrackingPermissionRequired => 'Location permission needed';

  @override
  String get settingsTrackingEnabled => '✅ Permanent tracking enabled';

  @override
  String get settingsTrackingDisabled => '✅ Permanent tracking disabled';

  @override
  String get settingsSectionLegal => 'Legal';

  @override
  String get settingsImpressum => 'Imprint';

  @override
  String get settingsImpressumSubtitle => 'Legal information';

  @override
  String get settingsPrivacy => 'Privacy Policy';

  @override
  String get settingsPrivacySubtitle => 'How we protect your data';

  @override
  String get settingsAppVersion => 'App Version';

  @override
  String get settingsSectionDiagnostics => 'Diagnostics & Support';

  @override
  String get settingsDebugLog => 'Generate debug log';

  @override
  String get settingsDebugLogSubtitle =>
      'Creates technical diagnostic information for sharing';

  @override
  String settingsDebugLogError(String error) {
    return '❌ Error generating debug log: $error';
  }

  @override
  String get settingsSectionNotifications => 'Notifications';

  @override
  String get settingsNotificationsSubtitle =>
      'Reminders for medications and appointments';

  @override
  String get settingsNotificationsInfo => 'How do notifications work?';

  @override
  String get settingsNotificationsBullet1 =>
      'Daily medications: -30min, -10min, 0min + +10min repeats';

  @override
  String get settingsNotificationsBullet2 =>
      'As-needed medications: Availability reminders (-30min, -10min, -5min, 0min)';

  @override
  String get settingsNotificationsBullet3 =>
      'Appointments: Configurable reminders (15min to 1 day in advance)';

  @override
  String get settingsNotificationsBullet4 =>
      'Works even when the app is closed';

  @override
  String get settingsNotificationsTest => 'Send test notification';

  @override
  String get settingsNotificationsTestSubtitle =>
      'Check if notifications are working';

  @override
  String get settingsNotificationsTestSent => '✅ Test notification sent';

  @override
  String get settingsNotificationsQueue => 'Queue';

  @override
  String get settingsNotificationsQueuePending => 'Scheduled notifications:';

  @override
  String settingsNotificationsQueueNext(String time) {
    return 'Next: $time';
  }

  @override
  String get settingsSectionMaps => 'Maps & Location';

  @override
  String get settingsMapsSubtitle =>
      'Map tiles are automatically downloaded and saved when viewed';

  @override
  String get settingsCacheStorage => 'Cache Storage';

  @override
  String settingsCacheSize(int size, int limit, String count) {
    return '$size MB / $limit MB • $count tiles';
  }

  @override
  String get settingsCacheLimit => 'Cache limit';

  @override
  String settingsCacheLimitSubtitle(int limit) {
    return '$limit MB maximum storage size';
  }

  @override
  String get settingsCacheLimitDialogTitle => 'Set cache limit';

  @override
  String settingsCacheLimitDialogLabel(int size) {
    return 'Maximum cache size: $size MB';
  }

  @override
  String get settingsCacheLimitDialogInfo =>
      'When the cache exceeds this limit, the oldest tiles will be automatically deleted.';

  @override
  String settingsCacheLimitSet(int limit) {
    return '✅ Cache limit set to $limit MB';
  }

  @override
  String get settingsCachePreDownload => 'Pre-download maps';

  @override
  String get settingsCachePreDownloadSubtitle => 'Download maps in a radius';

  @override
  String get settingsCachePreDownloadPlaceholder =>
      '🚧 Pre-download will be implemented in Phase 4';

  @override
  String get settingsCacheClear => 'Clear cache';

  @override
  String get settingsCacheClearSubtitle => 'Delete all saved map tiles';

  @override
  String get settingsCacheClearDialogTitle => 'Clear map cache';

  @override
  String get settingsCacheClearDialogMessage =>
      'Do you want to delete all saved map tiles?\n\nMaps will be reloaded the next time you view them. This can help free up storage space.';

  @override
  String get settingsCacheClearConfirm => 'Clear cache';

  @override
  String get settingsCacheCleared => '✅ Map cache cleared';

  @override
  String get settingsSectionApp => 'App Settings';

  @override
  String get settingsTimeFormat => 'Time format';

  @override
  String get settingsTimeFormatSystem => 'System default';

  @override
  String get settingsTimeFormat12h => '12-hour format';

  @override
  String get settingsTimeFormat24h => '24-hour format';

  @override
  String get settingsTimeFormatSystemSubtitle =>
      'Follows Android system settings';

  @override
  String get settingsTimeFormat12hExample => 'e.g. 2:30 PM';

  @override
  String get settingsTimeFormat24hExample => 'e.g. 14:30';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageChanged => 'Language changed';

  @override
  String get onboardingSelectLanguage => 'Choose your language';

  @override
  String get onboardingWelcomeTitle => 'Welcome to';

  @override
  String get onboardingWelcomeSubtitle =>
      'Your safe companion in everyday life with DIS';

  @override
  String get onboardingWelcomeDescription =>
      'Aurora is your shared safe space. Here you can express yourself freely and stay in touch with the other parts in the system.';

  @override
  String get onboardingPrivacyTitle => 'Your data belongs to YOU';

  @override
  String get onboardingPrivacyBullet1 => 'All data stays local on your device';

  @override
  String get onboardingPrivacyBullet2 => 'No cloud backup, no tracking, no ads';

  @override
  String get onboardingPrivacyBullet3 => 'You have full control';

  @override
  String get onboardingPrivacyBullet4 => 'Transparent and secure';

  @override
  String get onboardingMultiProfileTitle => 'Many voices, one app';

  @override
  String get onboardingMultiProfileDescription =>
      'Every part gets its own profile – with its own colour, its own picture and its own permissions.';

  @override
  String get onboardingLetsGoTitle => 'Ready to start?';

  @override
  String get onboardingLetsGoDescription =>
      'Create your first profile now. The first profile automatically becomes the admin profile with full access rights.';

  @override
  String get onboardingButtonNext => 'Next →';

  @override
  String get onboardingButtonCreateProfile => 'Create profile →';

  @override
  String get splashLoading => 'Aurora is loading';

  @override
  String get splashDidYouKnow => 'Did you know?';

  @override
  String get splashEmergencyWipeTitle => 'Emergency Reset';

  @override
  String get splashEmergencyWipeMessage =>
      'WARNING: All data will be permanently deleted!\n\n• All profiles\n• All messages\n• All diary entries\n• All contacts\n• All medications\n\nContinue?';

  @override
  String get splashEmergencyWipeConfirm => 'DELETE EVERYTHING';

  @override
  String get passwordResetBannerReady => 'Password ready to activate';

  @override
  String get passwordResetBannerRunning => 'Password reset in progress';

  @override
  String passwordResetBannerProfile(String name) {
    return 'Profile: $name';
  }

  @override
  String passwordResetBannerRemaining(String name, String time) {
    return 'Profile: $name • Remaining: $time';
  }

  @override
  String get dialogWarning => 'Warning';

  @override
  String get dialogConfirm => 'Confirm';

  @override
  String get dialogUnderstood => 'Understood';

  @override
  String get dialogYes => 'Yes';

  @override
  String get dialogNo => 'No';

  @override
  String get permissionGpsRequired =>
      '⚠️ GPS permission \"Allow all the time\" required';

  @override
  String get permissionTrackingDialogTitle => 'Enable permanent tracking?';

  @override
  String get permissionTrackingDialogHeading => 'What this mode does:';

  @override
  String get permissionTrackingBullet1 =>
      'GPS runs permanently in the background';

  @override
  String get permissionTrackingBullet2 =>
      'Overrides tracking settings for ALL profiles';

  @override
  String get permissionTrackingBullet3 =>
      'Timeline automatically captures all movements';

  @override
  String get permissionTrackingPrivacyTitle => 'Your data stays on this device';

  @override
  String get permissionTrackingPrivacyMessage =>
      'Aurora stores all data on this device only. No tracking, no ads, nothing shared.';

  @override
  String get permissionTrackingBatteryWarning =>
      'Background GPS may drain the battery more.';

  @override
  String get permissionTrackingAndroidStatus => 'Android status:';

  @override
  String get permissionTrackingActivate => 'Activate';

  @override
  String get permissionTrackingDeactivate => 'Deactivate';

  @override
  String get permissionTrackingDeactivateTitle =>
      'Deactivate permanent tracking?';

  @override
  String get permissionTrackingDeactivateMessage =>
      'GPS tracking will be controlled per profile again.\n\nEach profile can then individually enable/disable tracking.';

  @override
  String get permissionGuidanceTitle => 'Android setting required';

  @override
  String get permissionGuidanceMessage =>
      'To use permanent tracking, you need the \"Allow all the time\" permission.';

  @override
  String get permissionGuidanceStepsTitle => 'I\'ll guide you step by step:';

  @override
  String get permissionGuidanceStep1Title => 'Open Android settings';

  @override
  String get permissionGuidanceStep1Button => 'Open now';

  @override
  String get permissionGuidanceStep2Title => 'In the settings';

  @override
  String get permissionGuidanceStep2Bullet1 => 'Tap \"Permission\"';

  @override
  String get permissionGuidanceStep2Bullet2 => 'Tap \"Location\"';

  @override
  String get permissionGuidanceStep2Bullet3 => 'Select \"Allow all the time\"';

  @override
  String get permissionGuidanceStep3Message =>
      'Back to Aurora\nThe app will detect the change automatically.';

  @override
  String get messageError => 'Error';

  @override
  String get messageSuccess => 'Success';

  @override
  String get messageWarning => 'Warning';

  @override
  String get messageInfo => 'Information';

  @override
  String get messageLoading => 'Loading...';

  @override
  String get misc24HourFormat => '24-hour format';

  @override
  String get misc12HourFormat => '12-hour format';

  @override
  String get miscSystemDefault => 'System default';

  @override
  String get miscUnknown => 'Unknown';

  @override
  String get chatDayYesterday => 'Yesterday';

  @override
  String get miscToday => 'Today';

  @override
  String get miscAll => 'All';

  @override
  String get notificationChannelName => 'Aurora Notifications';

  @override
  String get notificationChannelDescription =>
      'Reminders for medications and appointments';

  @override
  String get notificationMedicationReminder => 'Medication Reminder';

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
    return '$name - $dosage take now';
  }

  @override
  String get notificationMedicationAvailableSoon =>
      'As-needed medication available soon';

  @override
  String get notificationMedicationAvailableNow =>
      'As-needed medication now available';

  @override
  String notificationMedicationAvailableBody(String name) {
    return '$name can be taken';
  }

  @override
  String get notificationEventReminder => 'Appointment Reminder';

  @override
  String notificationEventBody(String title, String time) {
    return '$title $time';
  }

  @override
  String get notificationTestTitle => 'Test Notification';

  @override
  String get notificationTestBody => 'Notifications are working!';

  @override
  String notificationTimeInMinutes(int minutes) {
    return 'in $minutes minutes';
  }

  @override
  String get notificationTimeIn1Hour => 'in 1 hour';

  @override
  String notificationTimeInHours(int hours) {
    return 'in $hours hours';
  }

  @override
  String get notificationTimeNow => 'now';

  @override
  String get notificationMedicationTakeNowTitle => 'Take medication now!';

  @override
  String get notificationMedicationNotTakenYet => 'Not taken yet!';

  @override
  String get actionCreate => 'Create';

  @override
  String get commonDescription => 'Description';

  @override
  String get commonNotes => 'Notes';

  @override
  String get commonOptional => 'Optional';

  @override
  String get commonCategory => 'Category';

  @override
  String get commonStartTime => 'Start time';

  @override
  String get commonEndTime => 'End time';

  @override
  String get commonVisibleFor => 'Visible for';

  @override
  String get commonUnnamed => 'Unnamed';

  @override
  String get commentsTitle => 'Comments';

  @override
  String get eventCreate => 'Create event';

  @override
  String get eventNewTitle => 'New Event';

  @override
  String get eventEditTitle => 'Edit Event';

  @override
  String get eventDetailTitle => 'Event Details';

  @override
  String get eventNotFound => 'Event not found';

  @override
  String get eventNotFoundMessage => 'This event no longer exists';

  @override
  String get eventDeleteTitle => 'Delete event?';

  @override
  String get eventDeleteMessage => 'Do you really want to delete this event?';

  @override
  String get eventDeleteConfirmMessage =>
      'This event will be permanently deleted.';

  @override
  String get eventDeleted => 'Event deleted';

  @override
  String get eventUpdated => 'Event updated';

  @override
  String get eventCreated => 'Event created';

  @override
  String get eventSelectProfileRequired => 'Please select at least one profile';

  @override
  String get eventEndTimeError => 'End time must be after start time';

  @override
  String get eventTitleLabel => 'Title';

  @override
  String get eventTitleLabelRequired => 'Title *';

  @override
  String get eventTitleRequired => 'Please enter a title';

  @override
  String get eventTitleHint => 'e.g. Doctor appointment';

  @override
  String get eventCategoryLabel => 'Category (optional)';

  @override
  String get eventCategoryHint => 'e.g. appointment, private, etc.';

  @override
  String get eventDescriptionLabel => 'Description (optional)';

  @override
  String contactDistanceAway(String distance) {
    return '$distance away';
  }

  @override
  String eventReminderMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String eventReminderHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String get eventReminderDay => '1 day';

  @override
  String eventReminderNotice(String when) {
    return 'Aurora will let you know $when before the appointment.';
  }

  @override
  String eventReminderBefore(int minutes) {
    return 'Reminder $minutes min. before';
  }

  @override
  String eventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Events',
      one: '1 Event',
      zero: '0 Events',
    );
    return '$_temp0';
  }

  @override
  String get noEventsToday => 'No events on this day';

  @override
  String get calendarNothingPlannedToday => 'Nothing is planned for today.';

  @override
  String get calendarNothingPlannedOnDay => 'Nothing is planned for this day.';

  @override
  String get calendarUpcomingTitle => 'Up next';

  @override
  String get calendarChooseDay => 'View another day';

  @override
  String get eventForWhom => 'Who is this appointment for?';

  @override
  String get eventMoreDetails => 'More details';

  @override
  String get contactTitle => 'Contact';

  @override
  String get contactNewTitle => 'New Contact';

  @override
  String get contactEditTitle => 'Edit Contact';

  @override
  String get contactNotFound => 'Contact not found';

  @override
  String get contactDeleteTitle => 'Delete contact?';

  @override
  String get contactDeleteMessage =>
      'This contact will be permanently deleted. This action cannot be undone.';

  @override
  String get contactImagePickerTitle => 'Choose contact image';

  @override
  String get contactNameLabel => 'Name *';

  @override
  String get contactNameRequired => 'Please enter a name';

  @override
  String get contactRelationLabel => 'Relationship';

  @override
  String get contactRelationHint => 'e.g. Mother, Therapist, Friend...';

  @override
  String get contactMarkAsEmergency => 'Mark as emergency contact';

  @override
  String get contactEmergencyDescription =>
      'This contact will appear in the emergency view and can be quickly notified';

  @override
  String get contactPhoneLabel => 'Phone';

  @override
  String get contactEmailLabel => 'Email';

  @override
  String get contactDefaultRating => 'Default Rating';

  @override
  String get contactDefaultRatingDescription =>
      'All profiles will see this rating by default. Each profile can set their own rating later.';

  @override
  String get contactPersonalRating => 'Personal Rating';

  @override
  String get contactLocationSection => '📍 Location (optional)';

  @override
  String get contactLocationTitle => '📍 Location';

  @override
  String get contactLocationDescription =>
      'Add a location (e.g. home address, office address)';

  @override
  String get contactLocationSet => 'Set location';

  @override
  String get contactLocationChange => 'Change location';

  @override
  String get contactAddressLabel => 'Address';

  @override
  String get contactAddressHint =>
      'Will be determined automatically when location is set';

  @override
  String get contactVisibleToAll => 'All profiles can see this contact';

  @override
  String get contactInfoSection => 'Information';

  @override
  String get gpsPermissionRequired => 'GPS permission required';

  @override
  String get gpsTrackingDisabled => 'GPS tracking disabled';

  @override
  String get emergencyContactLabel => 'Emergency contact';

  @override
  String get diaryEntryNewTitle => 'New Entry';

  @override
  String get diaryEntryEditTitle => 'Edit Entry';

  @override
  String get diaryEntryDetailTitle => 'Entry Details';

  @override
  String get diaryEntryNotFound => 'Entry not found';

  @override
  String get diaryEntryNotFoundMessage => 'This entry no longer exists';

  @override
  String get diaryEntryDeleteTitle => 'Delete entry';

  @override
  String get diaryEntryDeleteMessage =>
      'Do you really want to delete this entry? All comments will also be deleted.';

  @override
  String get diaryEntryDeleted => 'Entry deleted';

  @override
  String get diaryEntryUpdated => 'Entry updated';

  @override
  String get diaryEntryCreated => 'Entry created';

  @override
  String get diaryTitleHint => 'What happened?';

  @override
  String get diaryTitleRequired => 'Please enter a title';

  @override
  String get diaryDescriptionHint => 'Describe the event...';

  @override
  String get diaryDescriptionRequired => 'Please enter a description';

  @override
  String get diaryPriorityLabel => 'Priority';

  @override
  String get diaryImagesLabel => 'Images';

  @override
  String get diaryNoImagesYet => 'No images added yet';

  @override
  String get diaryImagePickerComingSoon =>
      'Image picker will be available soon';

  @override
  String get diaryCannotEditEntry => 'You cannot edit this entry';

  @override
  String get diaryCannotCreateEntry => 'You cannot create entries';

  @override
  String get commonError => 'Error';

  @override
  String get commonNoPermission => 'No Permission';

  @override
  String get commonEdited => 'Edited';

  @override
  String get commonTitle => 'Title';

  @override
  String get profileNotSelected => 'No profile selected';

  @override
  String get actionAdd => 'Add';

  @override
  String commonSaveError(String error) {
    return 'Error saving: $error';
  }

  @override
  String get timeJustNow => 'just now';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: 'a minute ago',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: 'an hour ago',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: 'a day ago',
    );
    return '$_temp0';
  }

  @override
  String get emergencyCall => 'Call';

  @override
  String get emergencyCallTooltip => 'Call contact';

  @override
  String get emergencyNoPhone => 'No phone number available';

  @override
  String get emergencySms => 'SMS';

  @override
  String get emergencySmsTooltip => 'Send emergency SMS';

  @override
  String get emergencyApp => 'App';

  @override
  String get emergencyShareTooltip => 'Share via app';

  @override
  String emergencyErrorCall(String error) {
    return 'Error calling: $error';
  }

  @override
  String emergencyErrorOpen(String error) {
    return 'Error opening: $error';
  }

  @override
  String get actionOpen => 'Open';

  @override
  String get finderLocationEditTitle => 'Edit Location';

  @override
  String get finderItemEditTitle => 'Edit Item';

  @override
  String get finderLocationNewTitle => 'New Location';

  @override
  String get finderItemNewTitle => 'New Item';

  @override
  String get finderSetPosition => 'Set position';

  @override
  String get finderChangePosition => 'Change position';

  @override
  String get finderAddressLabel => 'Address';

  @override
  String get finderStorageLocationLabel => 'Storage location';

  @override
  String get finderStorageLocationHint => 'e.g. Kitchen, 2nd drawer';

  @override
  String get finderChoosePhoto => 'Choose photo';

  @override
  String get finderAddPhoto => 'Add photo';

  @override
  String get finderAddTag => 'Add tag';

  @override
  String get finderNotFound => 'Not found';

  @override
  String get finderNotFoundMessage => 'Item not found';

  @override
  String get finderDeleteTitle => 'Delete?';

  @override
  String finderDeleteMessage(String title) {
    return 'Really delete $title?';
  }

  @override
  String get commonRequired => 'Required field';

  @override
  String get feedbackTitle => 'Send Feedback';

  @override
  String get feedbackPrivacyInfo =>
      'Your feedback is treated confidentially and processed internally only. Your feedback helps us improve Aurora!';

  @override
  String get feedbackSelectCategory => 'Select category:';

  @override
  String get fieldPasswordShow => 'Show password';

  @override
  String get fieldPasswordHide => 'Hide password';

  @override
  String get feedbackCategoryBug => 'Report a problem';

  @override
  String get feedbackCategoryWish => 'Suggest an idea';

  @override
  String get feedbackCategoryGeneral => 'General feedback';

  @override
  String get feedbackCategoryLabel => 'Category';

  @override
  String get feedbackTitleLabel => 'Title:';

  @override
  String get feedbackTitleHint => 'Short summary of your feedback';

  @override
  String get feedbackTitleRequired => 'Please enter a title';

  @override
  String get feedbackTitleTooShort => 'Title too short (at least 5 characters)';

  @override
  String get feedbackMessageLabel => 'Your message:';

  @override
  String get feedbackMessageHint => 'Describe your feedback in detail...';

  @override
  String get feedbackMessageRequired => 'Please enter a message';

  @override
  String get feedbackMessageTooShort =>
      'Message too short (at least 20 characters)';

  @override
  String get feedbackEmailLabel => 'Your email (optional):';

  @override
  String get feedbackEmailHint =>
      'Only if you want us to contact you for questions';

  @override
  String get feedbackEmailPlaceholder => 'your@email.com';

  @override
  String get feedbackEmailInvalid => 'Please enter a valid email address';

  @override
  String get feedbackAttachImageLabel => 'Attach image (optional):';

  @override
  String get feedbackAttachImage => 'Attach image';

  @override
  String get feedbackSelectImage => 'Select image';

  @override
  String get feedbackSend => 'Send Feedback';

  @override
  String get feedbackCopyToClipboard => 'Copy to clipboard';

  @override
  String get feedbackCopiedToClipboard => 'Feedback copied to clipboard!';

  @override
  String get feedbackContactLabel => 'Contact';

  @override
  String get feedbackErrorOccurred =>
      'An error occurred. Report was copied to clipboard.';

  @override
  String get feedbackCouldNotSend => 'Feedback could not be sent';

  @override
  String feedbackErrorClipboardHint(String email) {
    return 'Your feedback was copied to clipboard. You can also send it to us by email at $email.';
  }

  @override
  String get feedbackTechnicalDetails => 'Technical details';

  @override
  String get actionChange => 'Change';

  @override
  String get actionRemove => 'Remove';

  @override
  String get onboardingNext => 'Next →';

  @override
  String get onboardingCreateProfile => 'Create Profile →';

  @override
  String get onboardingLetsGo => 'Let\'s Go! →';

  @override
  String get onboardingWelcomeTo => 'Welcome to';

  @override
  String get onboardingSubline =>
      'Your safe companion in everyday life with DID';

  @override
  String get onboardingDescription =>
      'Aurora supports you in organizing your daily life and communicating within your system.';

  @override
  String get onboardingPrivacyHeadline => 'Your Data Belongs to YOU';

  @override
  String get onboardingPrivacyPoint1 => 'All data stays locally on your device';

  @override
  String get onboardingPrivacyPoint2 => 'No cloud backup, no tracking, no ads';

  @override
  String get onboardingPrivacyPoint3 => 'You have full control';

  @override
  String get onboardingPrivacyPoint4 => 'Transparent and secure';

  @override
  String get onboardingMultiProfileHeadline => 'Many Voices, One App';

  @override
  String get onboardingLetsGoHeadline => 'Ready to Start?';

  @override
  String onboardingHelloName(String name) {
    return 'Hello $name!';
  }

  @override
  String get onboardingGladYoureHere => 'Glad you\'re here.';

  @override
  String get onboardingNotAlone => 'You\'re Not Alone';

  @override
  String get onboardingNotAloneDescription =>
      'You can chat with each other, share appointments, and support one another.';

  @override
  String get onboardingWhatYouCanDo => 'What You Can Do';

  @override
  String get onboardingChildAccessDescription =>
      'As a child profile, you have access to:';

  @override
  String get onboardingAdultAccessDescription =>
      'These features are available to you:';

  @override
  String get onboardingSafeSpace => 'Your Safe Space';

  @override
  String get onboardingSafeSpaceDescription =>
      'All your data stays locally on this device. No cloud backup, no tracking, no ads. You have full control.';

  @override
  String get onboardingHaveFun => 'Have fun with Aurora!';

  @override
  String get onboardingFeatureChatChild => 'Chat - Doodle and talk with others';

  @override
  String get onboardingFeatureDiaryChild => 'Diary - Write down your thoughts';

  @override
  String get onboardingFeatureGamesChild => 'Games - Have fun and relax';

  @override
  String get onboardingFeatureTimelineChild =>
      'Timeline - Capture important moments';

  @override
  String get onboardingFeatureChat =>
      'Chat - Messages, doodles, voice messages';

  @override
  String get onboardingFeatureCalendar =>
      'Calendar - Plan and manage appointments';

  @override
  String get onboardingFeatureContacts => 'Contacts - Save important people';

  @override
  String get onboardingFeatureMedication =>
      'Medication - Track medications and schedules';

  @override
  String get onboardingFeatureDiary =>
      'Diary - Record thoughts and experiences';

  @override
  String get onboardingFeatureFinder => 'Finder - Find places and things again';

  @override
  String get onboardingFeatureEmergency =>
      'Emergency - Quick help in crisis situations';

  @override
  String get onboardingFeatureMantras =>
      'Mantras - Calming phrases and affirmations';

  @override
  String get onboardingFeatureChatBasic => 'Chat - Basic features available';

  @override
  String get featureCarouselHeadline => 'What Aurora Can Do';

  @override
  String get featureCarouselSwipeHint => 'Swipe through the features →';

  @override
  String get featureCarouselChatTitle => 'Chat';

  @override
  String get featureCarouselChatSubtitle => 'Internal Communication';

  @override
  String get featureCarouselChatDescription =>
      'Messages, doodles & voice messages.\nShare thoughts, draw together, or talk with each other.';

  @override
  String get featureCarouselCalendarTitle => 'Calendar';

  @override
  String get featureCarouselCalendarSubtitle => 'Events & Appointments';

  @override
  String get featureCarouselCalendarDescription =>
      'Appointments with images & locations.\nKeep track of important dates with images and GPS positions.';

  @override
  String get featureCarouselDiaryTitle => 'Diary';

  @override
  String get featureCarouselDiarySubtitle => 'Private Thoughts';

  @override
  String get featureCarouselDiaryDescription =>
      'Visible to all or just for you.\nRecord thoughts - public for all profiles or private just for yourself.';

  @override
  String get featureCarouselFinderTitle => 'Finder';

  @override
  String get featureCarouselFinderSubtitle => 'Places & Things';

  @override
  String get featureCarouselFinderDescription =>
      'Find places and things again.\nSave important locations (with map) and items so you can find them again.';

  @override
  String get featureCarouselMedicationTitle => 'Medication';

  @override
  String get featureCarouselMedicationSubtitle => 'Medication Tracker';

  @override
  String get featureCarouselMedicationDescription =>
      'Medications & schedules.\nTrack medications, intake times, and as-needed medication.';

  @override
  String get featureCarouselGamesTitle => 'Games & Grounding';

  @override
  String get featureCarouselGamesSubtitle => 'Relaxation';

  @override
  String get featureCarouselGamesDescription =>
      'Games, breathing exercises & grounding.\nCalm yourself with puzzles, breathing exercises, and grounding techniques.';

  @override
  String get featureCarouselEmergencyTitle => 'Help Resources';

  @override
  String get featureCarouselEmergencySubtitle => 'Emergency Contacts';

  @override
  String get featureCarouselEmergencyDescription =>
      'Emergency contacts & quick help.\nStore important contacts for crisis situations.';

  @override
  String get featureCarouselInfoTitle => 'DID Information';

  @override
  String get featureCarouselInfoSubtitle => 'Knowledge & Resources';

  @override
  String get featureCarouselInfoDescription =>
      'Explained: What is DID?\nInformation about Dissociative Identity Disorder and resources.';

  @override
  String get commonUnknown => 'Unknown';

  @override
  String get timelineTitle => 'Timeline';

  @override
  String get timelineHistory => 'History';

  @override
  String timelineEntries(int count) {
    return '$count entries';
  }

  @override
  String get timelinePositionUpdated => 'Position updated';

  @override
  String timelineProfileActive(String name) {
    return '$name active';
  }

  @override
  String get timelineAppStarted => 'App started';

  @override
  String get timelineProfileSwitched => 'Profile switched';

  @override
  String timelineToday(String time) {
    return 'Today, $time';
  }

  @override
  String timelineYesterday(String time) {
    return 'Yesterday, $time';
  }

  @override
  String get timelineTrackingDisabledTitle => 'GPS tracking disabled';

  @override
  String get timelineTrackingDisabledSubtitle =>
      'The timeline shows your profile switches and GPS positions over time.\n\nEnable GPS tracking via the satellite icon in the top right to collect data.';

  @override
  String get timelineEmptyTitle => 'No data yet';

  @override
  String get timelineEmptySubtitle =>
      'GPS tracking is active. Your position is recorded every 2-3 minutes.\n\nProfile switches and GPS positions will appear here automatically.';

  @override
  String get gamesTitle => 'Games & Relaxation';

  @override
  String get gamesSubtitle =>
      'Simple games for distraction and relaxation.\nNo timers, no scores - just peace.';

  @override
  String get gamesComingSoon => 'Soon';

  @override
  String get gamesPuzzleTitle => 'Puzzle';

  @override
  String get gamesPuzzleSubtitle => 'Jigsaw or sliding puzzle';

  @override
  String get gamesPuzzleDescription => 'Relax with calming images';

  @override
  String get gamesBreathingTitle => 'Breathing Exercises';

  @override
  String get gamesBreathingSubtitle => 'Guided breathing techniques';

  @override
  String get gamesBreathingDescription =>
      'Calm yourself with simple breathing exercises';

  @override
  String get memoryCardHidden => 'Face down';

  @override
  String get memoryCardOpen => 'Face up';

  @override
  String get memoryCardFound => 'Pair found';

  @override
  String get memoryAllFound => 'All pairs are found.';

  @override
  String get memoryNewGame => 'New game';

  @override
  String get gamesDrawingSend => 'Send to the chat';

  @override
  String get gamesDrawingEmpty => 'Draw something, then you can send it';

  @override
  String get gamesDrawingSent => 'Your picture is now in the chat.';

  @override
  String memoryCardPosition(int position, int total) {
    return 'Card $position of $total';
  }

  @override
  String get gamesMemoryTitle => 'Memory';

  @override
  String get gamesMemorySubtitle => 'Find matching pairs';

  @override
  String get gamesMemoryDescription =>
      'Relaxed memory game without time pressure';

  @override
  String get gamesDrawingTitle => 'Drawing';

  @override
  String get gamesDrawingSubtitle => 'Free painting & doodles';

  @override
  String get gamesDrawingDescription => 'Express yourself creatively';

  @override
  String get puzzleCreateTitle => 'Create Puzzle';

  @override
  String get puzzleRelaxationTitle => 'Puzzle for Relaxation';

  @override
  String get puzzleRelaxationSubtitle =>
      'Choose your puzzle type and difficulty. Take your time - there\'s no scoring.';

  @override
  String get puzzleTypeLabel => 'Puzzle Type';

  @override
  String get puzzleTypeJigsaw => 'Jigsaw';

  @override
  String get puzzleTypeJigsawDescription => 'Drag pieces to the right place';

  @override
  String get puzzleTypeSliding => 'Sliding Puzzle';

  @override
  String get puzzleTypeSlidingDescription => 'Move pieces by tapping';

  @override
  String get puzzleDifficultyLabel => 'Difficulty';

  @override
  String get puzzleDifficultyEasy => 'Easy';

  @override
  String get puzzleDifficultyEasyDescription =>
      '3×3 grid - perfect for relaxing';

  @override
  String get puzzleDifficultyMedium => 'Medium';

  @override
  String get puzzleDifficultyMediumDescription =>
      '4×4 grid - a small challenge';

  @override
  String get puzzleDifficultyHard => 'Hard';

  @override
  String get puzzleDifficultyHardDescription => '5×5 grid - for puzzle pros';

  @override
  String get puzzleSelectImageAndStart => 'Select image & start';

  @override
  String get puzzleJigsawTitle => 'Jigsaw Puzzle';

  @override
  String get puzzleSlidingTitle => 'Sliding Puzzle';

  @override
  String puzzleMoves(int count) {
    return 'Moves: $count';
  }

  @override
  String get puzzlePreparing => 'Preparing puzzle...';

  @override
  String get puzzleAvailablePieces => 'Available Pieces';

  @override
  String get puzzleTapToMove => 'Tap a piece to move it';

  @override
  String get puzzleShowHint => 'Show hint';

  @override
  String puzzleHintMovablePieces(int count) {
    return 'Hint: You can move $count pieces';
  }

  @override
  String get puzzleSolved => 'Puzzle solved!';

  @override
  String puzzleSolvedInMoves(int count) {
    return 'You solved the puzzle in $count moves.';
  }

  @override
  String puzzleErrorLoadingImage(String error) {
    return 'Error loading image: $error';
  }

  @override
  String puzzleErrorSharing(String error) {
    return 'Error sharing: $error';
  }

  @override
  String get puzzleImagePickerTitle => 'Select Image';

  @override
  String get puzzleImagePickerSubtitle =>
      'Choose a calming image for your puzzle';

  @override
  String get puzzleImageLoading => 'Loading image...';

  @override
  String get puzzleImageLoadFailed => 'Image could not be loaded';

  @override
  String get puzzleImageSourceGallery => 'Gallery';

  @override
  String get puzzleImageSourceGallerySubtitle =>
      'Choose an image from your gallery';

  @override
  String get puzzleImageSourceCamera => 'Camera';

  @override
  String get puzzleImageSourceCameraSubtitle => 'Take a new photo';

  @override
  String get puzzleImageSourceOnline => 'Online';

  @override
  String get puzzleImageSourceOnlineSubtitle =>
      'Calming image from the internet';

  @override
  String get puzzleSelectCategory => 'Select Category';

  @override
  String get errorNoProfileSelected => 'No profile selected';

  @override
  String get mantrasTitle => 'Mantras';

  @override
  String get mantrasComingSoonTitle => 'Mantras - Coming Soon ✨';

  @override
  String get mantrasComingSoonSubtitle =>
      'Calming affirmations and positive mantras for difficult moments';

  @override
  String get helpResourcesTitle => 'Help Resources';

  @override
  String get helpHotlinesTitle => '24/7 Emergency Hotlines';

  @override
  String get helpHotlinesSubtitle => 'Professional support - available anytime';

  @override
  String get helpMoreResourcesTitle => 'More resources coming soon';

  @override
  String get helpMoreResourcesDescription =>
      'In future updates:\n• Therapy resources\n• Support groups\n• Information about DID\n• Crisis plans & strategies';

  @override
  String get moreTitle => 'More Features';

  @override
  String get moreHelpResources => 'Help Resources';

  @override
  String get moreHelpResourcesDescription =>
      'Information and links to professional support';

  @override
  String get moreGames => 'Games & Relaxation';

  @override
  String get moreGamesDescription =>
      'Breathing exercises, memory games and more for distraction';

  @override
  String get moreSettings => 'Settings';

  @override
  String get moreSettingsDescription => 'App configuration and privacy';

  @override
  String get permissionsTitle => 'Rights & Permissions';

  @override
  String get permissionsNoProfiles => 'No profiles available';

  @override
  String get permissionsInfoText =>
      'Here you can manage permissions for each profile. Tap on a profile to see details.';

  @override
  String get permissionsAllRightsAdmin => 'All rights (Administrator)';

  @override
  String permissionsCount(int count) {
    return '$count permissions';
  }

  @override
  String get permissionsAdminBadge => 'Admin';

  @override
  String get permissionsAdministrator => 'Administrator';

  @override
  String permissionsDetailTitle(String name) {
    return 'Permissions: $name';
  }

  @override
  String get permissionsChangeError => 'Permission could not be changed';

  @override
  String get permissionsMakeAdminTitle => 'Appoint Administrator';

  @override
  String permissionsMakeAdminMessage(String name) {
    return '$name will become an administrator with all rights. Continue?';
  }

  @override
  String get permissionsMakeAdminButton => 'Make Administrator';

  @override
  String get permissionsMakeAdminSubtitle => 'Grants all rights';

  @override
  String get permissionsRevokeAdminTitle => 'Remove Administrator Status';

  @override
  String permissionsRevokeAdminMessage(String name) {
    return '$name will lose all admin rights and receive standard permissions. Continue?';
  }

  @override
  String get permissionsRevokeAdminSubtitle => 'Resets to standard permissions';

  @override
  String get permissionsRevokeAdminError =>
      'Admin status could not be removed. The first profile must remain administrator.';

  @override
  String permissionsActiveCount(int active, int total) {
    return '$active / $total active';
  }

  @override
  String get permissionsCategorySystem => 'System Permissions';

  @override
  String get permissionsCategoryChat => 'Chat';

  @override
  String get permissionsCategoryCalendar => 'Calendar';

  @override
  String get permissionsCategoryMedication => 'Medication';

  @override
  String get permissionsCategoryContacts => 'Contacts';

  @override
  String get permissionsCategoryFinder => 'Finder (Places & Items)';

  @override
  String get permissionsCategoryDiary => 'Diary';

  @override
  String get permissionsCategoryEmergency => 'Emergency Contacts';

  @override
  String get permissionsCategorySecurity => 'Security';

  @override
  String profileAgeYears(int age) {
    return '$age years';
  }

  @override
  String get groundingTitle => 'Ground';

  @override
  String get groundingChooseLabel => 'Or pick something';

  @override
  String get groundingDoneAgain => 'Again';

  @override
  String get groundingDoneOther => 'Something else';

  @override
  String get groundingDoneCall => 'Call someone';

  @override
  String get groundingOrientationTitle => 'Here and now';

  @override
  String get groundingOrientationStep1 => 'Today is';

  @override
  String get groundingOrientationStep2 =>
      'Look around. Where are you right now?';

  @override
  String get groundingOrientationStep3 =>
      'Say who you are, out loud or quietly.';

  @override
  String get groundingOrientationStep4 =>
      'Today\'s body is not the body from back then.';

  @override
  String get groundingOrientationStep5 => 'What you remember is over.';

  @override
  String get groundingOrientationStep6 => 'You are here.';

  @override
  String get groundingSensesTitle => 'See, hear, feel';

  @override
  String get groundingSensesStep1 => 'Five things you can see.';

  @override
  String get groundingSensesStep2 => 'Four things you can hear.';

  @override
  String get groundingSensesStep3 => 'Three things you can touch.';

  @override
  String get groundingSensesStep4 => 'Two things you can smell.';

  @override
  String get groundingSensesStep5 => 'One thing you can taste.';

  @override
  String get groundingSensesStep6 => 'You are here.';

  @override
  String get groundingBodyTitle => 'Feel the body';

  @override
  String get groundingBodyStep1 => 'Put both feet flat on the floor.';

  @override
  String get groundingBodyStep2 => 'Press your heels down.';

  @override
  String get groundingBodyStep3 => 'Take something cold in your hand.';

  @override
  String get groundingBodyStep4 => 'Hold it as long as you like.';

  @override
  String get groundingBodyStep5 => 'Feel your back against the chair.';

  @override
  String get groundingBodyStep6 => 'The ground is carrying you.';

  @override
  String get groundingContainerTitle => 'Put it away';

  @override
  String get groundingContainerStep1 =>
      'Picture a container. As big as you want.';

  @override
  String get groundingContainerStep2 => 'It has a lid that closes tight.';

  @override
  String get groundingContainerStep3 =>
      'Put inside what is too much right now.';

  @override
  String get groundingContainerStep4 => 'Close the lid.';

  @override
  String get groundingContainerStep5 => 'Place it somewhere you choose.';

  @override
  String get groundingContainerStep6 => 'You can open it again. Not now.';

  @override
  String get groundingBreathTitle => 'Breath';

  @override
  String get groundingBreathStep1 => 'Breathe in and count to four.';

  @override
  String get groundingBreathStep2 => 'Hold briefly.';

  @override
  String get groundingBreathStep3 => 'Breathe out and count to six.';

  @override
  String get groundingBreathStep4 => 'Again. No rush.';

  @override
  String get groundingBreathStep5 => 'Slower out than in. That is enough.';

  @override
  String get medicationNameLabel => 'Medication name';

  @override
  String get medicationDosageLabel => 'Dose';

  @override
  String get medicationDosageHint => 'e.g. 1 tablet, 10 mg, 5 ml';

  @override
  String get medicationNameRequired => 'Enter a name';

  @override
  String get medicationDosageRequired => 'Enter a dose';

  @override
  String get medicationTypeQuestion => 'What kind of medication?';

  @override
  String get medicationTypeDailyTitle => 'Daily medication';

  @override
  String get medicationTypeDailyExplanation => 'At set times, every day';

  @override
  String get medicationTypeAsNeededTitle => 'As-needed medication';

  @override
  String get medicationTypeAsNeededExplanation => 'Only when you need it';

  @override
  String get medicationWhenToTake => 'When to take it?';

  @override
  String get medicationSectionMorning => 'Morning';

  @override
  String get medicationSectionMidday => 'Midday';

  @override
  String get medicationSectionEvening => 'Evening';

  @override
  String get medicationSectionNight => 'Night';

  @override
  String get medicationOtherTime => 'Another time';

  @override
  String get medicationSectionNotChosen => 'not selected';

  @override
  String get medicationTimeRequired => 'Add at least one time to take it';

  @override
  String get medicationAsNeededSettings => 'As-needed settings';

  @override
  String get medicationMaxDosesLabel => 'Maximum per day *';

  @override
  String get medicationMaxDosesHint => 'e.g. 3';

  @override
  String get medicationMaxDosesHelper => 'How often may this be taken per day?';

  @override
  String get medicationMaxDosesRequired => 'Required for as-needed medication';

  @override
  String get medicationMaxDosesInvalid => 'Enter a number greater than 0';

  @override
  String get medicationMaxDosesMissing => 'Enter the maximum per day';

  @override
  String get medicationMinIntervalLabel => 'Minimum gap in hours (optional)';

  @override
  String get medicationMinIntervalHint => 'e.g. 4';

  @override
  String get medicationMinIntervalHelper => 'Shortest time between two doses';

  @override
  String get medicationMinIntervalInvalid => 'Enter a number of 0 or more';

  @override
  String get medicationRemindersTitle => 'Aurora will remind you';

  @override
  String get medicationRemindersOff =>
      'Aurora stays quiet. The medication stays in your list; you decide when to look.';

  @override
  String get medicationRemindersDaily =>
      'At each time Aurora speaks up three times: 30 minutes before, 10 minutes before and at the time itself. If you do not respond, once more 10 minutes later.';

  @override
  String get medicationRemindersNoInterval =>
      'Without a minimum gap there is no moment for Aurora to wait for. Enter a gap below if you want a reminder as soon as the next dose is allowed.';

  @override
  String get medicationRemindersAsNeeded =>
      'After a dose Aurora tells you as soon as the next one is allowed, announcing it 30, 10 and 5 minutes ahead.';

  @override
  String get medicationPeriodTitle => 'Period (optional)';

  @override
  String get medicationStartDate => 'Start date';

  @override
  String get medicationEndDate => 'End date';

  @override
  String get medicationNotesLabel => 'Notes (optional)';

  @override
  String get medicationNotesHint => 'e.g. take with food';

  @override
  String get medicationDescriptionLabel => 'Detailed description (optional)';

  @override
  String get medicationDescriptionHint =>
      'Helps tell similar medications apart';

  @override
  String get medicationPhotoTitle => 'Photo of the pill (optional)';

  @override
  String get medicationPhotoHint =>
      'A photo helps you recognise it and avoid mix-ups';

  @override
  String get medicationPhotoTake => 'Take a photo';

  @override
  String get medicationPhotoRetake => 'Take a new photo';

  @override
  String medicationPhotoError(String error) {
    return 'The photo could not be loaded: $error';
  }

  @override
  String get medicationActiveTitle => 'Active';

  @override
  String get medicationActiveOn => 'Shown in the daily list';

  @override
  String get medicationActiveOff => 'Archived';

  @override
  String get medicationDeleteTitle => 'Delete medication?';

  @override
  String get medicationDeleteMessage =>
      'Do you really want to delete this medication?';

  @override
  String get medicationDeleteConfirmMessage =>
      'This medication will be deleted permanently.';

  @override
  String get medicationDeleted => 'Medication deleted';

  @override
  String get medicationIntakeTimesLabel => 'Times to take it';

  @override
  String get medicationMaxDailyLabel => 'Max. per day';

  @override
  String get medicationMinGapLabel => 'Min. gap';

  @override
  String get medicationStatusLabel => 'Status';

  @override
  String get medicationStatusTaken => 'Taken';

  @override
  String get medicationStatusRefused => 'Refused';

  @override
  String get medicationStatusSnoozed => 'Later';

  @override
  String get medicationTake => 'Take';

  @override
  String get medicationTakeAnyway => 'Take it anyway';

  @override
  String get medicationDailyLimitReached => 'Daily limit reached';

  @override
  String get medicationAddFeedback => 'Add how it went';

  @override
  String get medicationFeedbackYourExperience => 'How it went for you';

  @override
  String get medicationRefusalTitle => 'Note that it was refused';

  @override
  String get medicationIntakesLabel => 'Doses';

  @override
  String get medicationNoProfileSelected => 'No profile selected';

  @override
  String get medicationNoLogPermission => 'No permission to record doses';

  @override
  String get commonGallery => 'Gallery';

  @override
  String get commonCamera => 'Camera';

  @override
  String get medicationStatusSkipped => 'Skipped';

  @override
  String medicationWillBeRefused(String name) {
    return '$name will be marked as refused.';
  }

  @override
  String clockTime(String time) {
    return '$time';
  }

  @override
  String medicationReminderAtTime(String time) {
    return 'Reminder at $time';
  }

  @override
  String medicationSnoozedUntil(String name, String time) {
    return '$name — reminder at $time';
  }

  @override
  String medicationAtTime(String time) {
    return 'at $time';
  }

  @override
  String medicationDoseCountToday(int available, int max) {
    return 'Available: $available of $max today';
  }

  @override
  String medicationLastTaken(String time) {
    return 'Last taken: $time';
  }

  @override
  String medicationNextPossible(String time) {
    return 'Next dose possible at $time';
  }

  @override
  String medicationNoteLabel(String note) {
    return 'Note: $note';
  }

  @override
  String medicationLimitWarning(int count, String name) {
    return 'You have already taken $count doses of $name today. That is the daily limit.';
  }

  @override
  String medicationTakenConfirmation(String name) {
    return '$name taken';
  }

  @override
  String get anchorTitle => 'Anchor';

  @override
  String get anchorSectionWhenHard => 'When it is hard';

  @override
  String get anchorSectionEveryday => 'Everyday';

  @override
  String get anchorSectionWhenCalm => 'When it is calm';

  @override
  String get fabMedication => 'Medication';

  @override
  String get fabDiaryEntry => 'Entry';

  @override
  String get fabContact => 'Contact';

  @override
  String get appQuitTitle => 'Close the app?';

  @override
  String get appQuitMessage => 'Do you really want to close Aurora?';

  @override
  String get emergencyResetTitle => 'Emergency reset';

  @override
  String get emergencyResetWarning =>
      'WARNING: all data will be deleted for good.\n\nProfiles, messages, appointments, medications, contacts — everything.\n\nThis step cannot be undone.';

  @override
  String get emergencyResetConfirm => 'DELETE EVERYTHING';

  @override
  String get pwResetCancelledTitle => 'Reset cancelled';

  @override
  String get pwResetCancelledMessage =>
      'The running password reset was cancelled with the old password. Your profile is active now.';

  @override
  String get pwResetUnderstood => 'Got it';

  @override
  String get pwResetNowActiveTitle => 'New password active';

  @override
  String get pwResetNowActiveMessage =>
      'The new password became active automatically once the waiting time ran out. Your profile is active now.';

  @override
  String get pwResetTitle => 'Reset password';

  @override
  String get pwResetAnswerQuestions =>
      'Answer the security questions to reset it right away';

  @override
  String pwResetAnswerN(int number) {
    return 'Answer $number';
  }

  @override
  String get pwResetForgotAnswers =>
      'Forgotten the answers?\nStart the 24-hour timer';

  @override
  String get pwResetAnswerAll => 'Please answer every question';

  @override
  String get pwResetAnswersWrong =>
      'Those answers are not right.\n\nYou can try again or start the 24-hour timer.';

  @override
  String get pwResetCheckAnswers => 'Check answers';

  @override
  String get pwResetSetNewTitle => 'Set a new password';

  @override
  String get pwResetAnswersCorrect => 'Security questions answered correctly.';

  @override
  String get pwResetImmediateHint =>
      'Enter your new password. It becomes active right away.';

  @override
  String get pwResetNewPassword => 'New password';

  @override
  String get pwResetConfirmPassword => 'Confirm password';

  @override
  String get pwResetTooShort => 'The password needs at least 4 characters';

  @override
  String get pwResetMismatch => 'The passwords do not match';

  @override
  String get pwResetChanged =>
      'Password changed.\n\nYou can sign in with the new one now.';

  @override
  String get pwResetSetPassword => 'Set password';

  @override
  String get pwResetTimerHint =>
      'Enter your new password.\n\nOnce started, a 24-hour timer runs; after that you can activate the new password.';

  @override
  String pwResetStarted(String waitTime) {
    return 'Password reset started.\n\nYour old password stays active. In $waitTime you can activate the new one.';
  }

  @override
  String get pwResetStartError => 'The password reset could not be started';

  @override
  String get pwResetStart => 'Start reset';

  @override
  String get pwResetRunningTitle => 'Password reset in progress';

  @override
  String get pwResetWhatsHappening => 'What is happening?';

  @override
  String get pwResetRunningExplanation =>
      'You set a new password a short while ago. For safety, a 24-hour timer is now running.\n\n';

  @override
  String pwResetRemaining(String time) {
    return 'Time left: $time';
  }

  @override
  String get pwResetReadyTitle => 'Ready to activate';

  @override
  String get pwResetWaitOver => 'The waiting time is over.';

  @override
  String pwResetReadyExplanation(String startTime) {
    return 'You set a new password at $startTime. The 24-hour safety period has now passed.';
  }

  @override
  String get pwResetIrreversible =>
      'If you activate it, your OLD password is replaced by the NEW one for good.';

  @override
  String get pwResetActivated =>
      'New password activated.\n\nYou can sign in with it now.';

  @override
  String get pwResetActivateError => 'The password could not be activated';

  @override
  String get pwResetActivate => 'Activate the new password';

  @override
  String get profileCurrentlyActive => 'Profile in use right now';

  @override
  String get profilePasswordProtected => 'This profile is password protected';

  @override
  String get profilePasswordLabel => 'Password';

  @override
  String get settingsMapCacheClearQuestion => 'Delete all stored map tiles?';

  @override
  String get settingsMapCacheCleared => 'Map cache cleared';

  @override
  String get settingsMapPredownloadComingSoon =>
      'Downloading maps in advance comes in a later version';

  @override
  String get settingsCacheLimitTitle => 'Set the cache limit';

  @override
  String settingsCacheLimitValue(int size) {
    return 'Maximum cache size: $size MB';
  }

  @override
  String settingsCacheLimitMegabytes(int size) {
    return '$size MB';
  }

  @override
  String get settingsCacheLimitExplanation =>
      'When the cache passes this limit, the oldest tiles are deleted automatically.';

  @override
  String get settingsAllDataDeleted => 'All data has been deleted';

  @override
  String get settingsDeleteIncomplete =>
      'Not everything could be deleted. Please try again.';

  @override
  String get settingsTrackingEnableTitle => 'Turn on continuous tracking?';

  @override
  String get settingsTrackingWhatItDoes => 'What this mode does:';

  @override
  String get settingsDataStaysHere => 'Your data stays on this device';

  @override
  String get settingsDataStaysHereExplanation =>
      'Aurora stores all data locally only.';

  @override
  String get settingsBackgroundGpsBattery =>
      'Background GPS can use more battery.';

  @override
  String get settingsAndroidStatus => 'Android status:';

  @override
  String get settingsActivate => 'Turn on';

  @override
  String get settingsDeactivate => 'Turn off';

  @override
  String get settingsTrackingDisableTitle => 'Turn off continuous tracking?';

  @override
  String get settingsTrackingDisableExplanation =>
      'GPS tracking goes back to being set per profile.';

  @override
  String get settingsTestNotificationSent => 'Test notification sent';

  @override
  String get settingsAndroidSettingNeeded => 'An Android setting is needed';

  @override
  String settingsPermissionNeededFor(String permission) {
    return 'To use continuous tracking you need the “$permission” permission.';
  }

  @override
  String get settingsStepByStep => 'Here it is, step by step:';

  @override
  String get settingsOpenAndroidSettings => 'Open the Android settings';

  @override
  String get settingsOpenNow => 'Open now';

  @override
  String get settingsInTheSettings => 'In the settings';

  @override
  String get settingsBackToAurora =>
      'Back to Aurora\nThe app notices the change on its own.';

  @override
  String get settingsUnderstood => 'Got it';

  @override
  String settingsResetPendingFor(String name, String time) {
    return 'Profile: $name\nTime left: $time';
  }

  @override
  String settingsWhatIs(String name) {
    return 'What is “$name”?';
  }

  @override
  String get settingsAdminTrackingExplanation =>
      'As an admin you can set GPS tracking for EVERY profile at once. When it is on:';

  @override
  String settingsPrerequisite(String permission) {
    return 'You first need the Android permission “$permission”.';
  }

  @override
  String get settingsGpsPermission => 'GPS permission';

  @override
  String get settingsBackgroundReady =>
      'Everything is ready for continuous tracking.';

  @override
  String settingsHowToEnable(String permission) {
    return 'How to turn on “$permission”';
  }

  @override
  String get settingsLocationStaysHere =>
      'Your location data stays on this device.';

  @override
  String get settingsTrackingAlwaysOn => 'Tracking always on';

  @override
  String get settingsHowNotificationsWork => 'How do notifications work?';

  @override
  String get settingsSendTestNotification => 'Send a test notification';

  @override
  String get settingsCheckNotificationsWork =>
      'Check that notifications arrive';

  @override
  String get settingsQueue => 'Queue';

  @override
  String get settingsScheduledNotifications => 'Scheduled notifications:';

  @override
  String settingsNextAt(String time) {
    return 'Next: $time';
  }

  @override
  String settingsCacheUsage(String used, String limit, String count) {
    return '$used MB of $limit MB • $count tiles';
  }

  @override
  String settingsPercent(int value) {
    return '$value%';
  }

  @override
  String get settingsCacheLimitLabel => 'Cache limit';

  @override
  String get settingsPredownloadMaps => 'Download maps in advance';

  @override
  String get settingsPredownloadSubtitle =>
      'Downloads maps for an area around you';

  @override
  String get settingsClearCache => 'Clear the cache';

  @override
  String get settingsClearCacheSubtitle => 'Delete all stored map tiles';

  @override
  String get settingsDiscreetRemindersTitle => 'Reminders without the details';

  @override
  String get settingsDiscreetRemindersOn =>
      'The lock screen only says “Aurora — reminder”. What it means, you see after unlocking.';

  @override
  String get settingsDiscreetRemindersOff =>
      'The lock screen shows the name and dose, or the appointment, in plain words.';

  @override
  String get settingsWhatAuroraSends => 'What Aurora sends';

  @override
  String get settingsWhatAuroraSendsSubtitle =>
      'Read every transmission word for word';

  @override
  String get settingsAlwaysAllow => 'Allow all the time';

  @override
  String get settingsAlwaysAllowRequired =>
      'The “Allow all the time” location permission is needed';

  @override
  String get settingsLocalOnly =>
      'Aurora stores all data locally only. No cloud, no servers, nothing sent.';

  @override
  String get settingsTrackingDisableFull =>
      'GPS tracking goes back to being set per profile.\n\nEach profile can then turn it on and off for itself.';

  @override
  String get settingsAlwaysAllowNeeded =>
      'To use continuous tracking you need the “Allow all the time” permission.';

  @override
  String get settingsWhatIsAlwaysOn => 'What is “tracking always on”?';

  @override
  String get settingsAlwaysAllowPrerequisite =>
      'You first need the Android permission “Allow all the time”, so tracking keeps running when the app is closed.';

  @override
  String get settingsHowToEnableAlwaysAllow =>
      'How to turn on “Allow all the time”:';

  @override
  String get settingsLocationStaysOffline =>
      'Your location data stays on this device. Aurora works offline, with no server connection.';

  @override
  String settingsCountValue(int count) {
    return '$count';
  }

  @override
  String settingsTilesCount(String used, String limit, String count) {
    return '$used MB of $limit MB • $count tiles';
  }

  @override
  String settingsMaxStorage(int size) {
    return '$size MB maximum storage';
  }

  @override
  String errorWithDetail(String error) {
    return 'Error: $error';
  }

  @override
  String get securityQuestionsFillAll =>
      'Fill in all three questions and answers';

  @override
  String get securityQuestionsSaved =>
      'Security questions saved.\n\nYou can now use them to reset your password.';

  @override
  String get securityQuestionsRemoveTitle => 'Remove the security questions?';

  @override
  String get securityQuestionsRemoveWarning =>
      'Without the security questions, the 24-hour timer is the only way left to reset your password.';

  @override
  String get securityQuestionsRemoved => 'Security questions removed';

  @override
  String get securityQuestionsSetupTitle => 'Set up security questions';

  @override
  String get securityQuestionsSetupExplanation =>
      'Set up three security questions so you can reset your password quickly.';

  @override
  String get securityQuestionsChooseWisely =>
      'Pick questions whose answers you will never forget';

  @override
  String securityQuestionN(int number) {
    return 'Question $number';
  }

  @override
  String securityAnswerToQuestionN(int number) {
    return 'Answer to question $number';
  }

  @override
  String get securityQuestionHint1 => 'e.g. name of my first pet?';

  @override
  String get securityQuestionHint2 => 'e.g. where my mother was born?';

  @override
  String get securityQuestionHint3 => 'e.g. my favourite film as a child?';

  @override
  String get errorReportPreviewTitle => 'Preview of the error report';

  @override
  String get errorReportWhatIsSent => 'This is what gets sent:';

  @override
  String get errorReportContactSection => 'Contact (optional)';

  @override
  String get errorReportContactExplanation =>
      'Only if you want us to be able to reach you with questions:';

  @override
  String get errorReportEmailLabel => 'Email address (optional)';

  @override
  String get errorReportNewsletter => 'Sign up for news';

  @override
  String get errorReportNewsletterSubtitle =>
      'Get news about Aurora, at most once a month';

  @override
  String get errorReportEmailUseOnly =>
      'We use your email address only for questions about this report.';

  @override
  String get errorReportCopy => 'Copy';

  @override
  String get errorReportCopied => 'Report copied to the clipboard';

  @override
  String errorReportAutoGenerated(String type) {
    return 'Automatically generated report ($type).';
  }

  @override
  String get errorReportQueued =>
      'Report accepted. It goes out as soon as you are online again.';

  @override
  String get errorReportFailed => 'The report could not be sent';

  @override
  String get errorReportCopyToClipboard => 'Copy to the clipboard';

  @override
  String permissionsLevel(int level) {
    return 'Level $level';
  }

  @override
  String get permissionsSectionExplanation =>
      'Decide which areas this profile can use. Each area can be set on its own:';

  @override
  String get permissionsChildPreset => 'Child preset';

  @override
  String get permissionsAdultPreset => 'Adult preset';

  @override
  String get permissionsCategoryEmergencyDiary => 'Emergency diary';

  @override
  String get permissionsCategoryHelp => 'Help';

  @override
  String get permissionsCategoryMantras => 'Mantras';

  @override
  String get permissionsCategoryGames => 'Games';

  @override
  String get permissionsChangeableLater =>
      'You can change the permissions any time in the settings';

  @override
  String get errorReportRoute =>
      'The report goes straight to the developers; if that fails, Aurora opens your email app. What was sent is listed in the settings under “What Aurora sends”.';

  @override
  String get errorReportEmailPrivacy =>
      'We use your email address only for questions about this report and pass it to no one.';

  @override
  String errorReportAutoBody(String type) {
    return 'Automatically generated report ($type). The details are in the device diagnostics.';
  }

  @override
  String errorReportClipboardFallback(String email) {
    return 'The report is in the clipboard. You can also send it to us by email at $email.';
  }

  @override
  String get mapAddressNotFound => 'Address not found';

  @override
  String get mapNeedsInternet =>
      'Aurora needs the internet to search addresses';

  @override
  String get mapDataEnabled => 'Map data turned on — the map is loading';

  @override
  String get mapTapOrSearch => 'Tap the map or search for an address';

  @override
  String get mapAddressLoading => 'Loading the address…';

  @override
  String get mapPickTitle => 'Add a place';

  @override
  String get mapTapSearchOrLocate =>
      'Tap the map, search for an address, or use your location';

  @override
  String get mapSearchHint =>
      'Search for an address (e.g. 3 Church Street, Coswig)';

  @override
  String get mapDataNotLoaded => 'Map data not loaded';

  @override
  String get mapEnableToMark => 'Turn on map data to mark places on the map.';

  @override
  String get mapDataFromOsm =>
      'The map data comes from OpenStreetMap.\nAurora needs an internet connection once for that.';

  @override
  String get mapZoomIn => 'Zoom in';

  @override
  String get mapZoomOut => 'Zoom out';

  @override
  String get mapToMyLocation => 'To my location';

  @override
  String get feedbackSheetTitle => 'Get in touch with the developer';

  @override
  String get feedbackSheetIntro =>
      'Aurora is in open beta and lives on your feedback.';

  @override
  String get feedbackReplyOnlyIfWanted => 'Only if you would like a reply';

  @override
  String errorOpening(String error) {
    return 'Could not open it: $error';
  }

  @override
  String errorLinkNotOpened(String url) {
    return 'The link could not be opened: $url';
  }

  @override
  String get thankYouTitle => 'Thank you.';

  @override
  String get thankYouReportSent =>
      'Your report arrived and helps us make Aurora better.';

  @override
  String get thankYouReportRecorded => 'Your error report has been recorded';

  @override
  String get thankYouJoinCommunity => 'Join the community';

  @override
  String get thankYouDiscord => 'Discord server';

  @override
  String get thankYouDiscordSubtitle => 'Talk with other users and the team';

  @override
  String get thankYouMoreContact => 'Other ways to reach us';

  @override
  String get thankYouEmailSupport => 'Email support';

  @override
  String get thankYouWhatsNext => 'What happens next?';

  @override
  String get thankYouBackToApp => 'Back to Aurora';

  @override
  String get transparencyDeleteTitle => 'Delete this entry?';

  @override
  String get transparencyDeleteMessage =>
      'The entry disappears from this list. What has already been sent does not come back because of it.';

  @override
  String get transparencyIntro =>
      'Here you see every transmission that left your device — word for word.';

  @override
  String get transparencyNothingSent => 'Nothing has been sent yet.';

  @override
  String get transparencySendUsageData => 'Send anonymous usage data';

  @override
  String get transparencyIrreversible =>
      'What has already been sent cannot be called back. It is on its way.';

  @override
  String imagePickerAnimalError(String error) {
    return 'The animal avatar could not be selected: $error';
  }

  @override
  String get imagePickerCameraNeeded =>
      'Aurora needs camera permission to take photos';

  @override
  String get imagePickerGalleryNeeded =>
      'Aurora needs gallery permission to pick images';

  @override
  String get imagePickerAllowInSettings => 'Allow it in the settings';

  @override
  String get imagePickerOpenSettings => 'Open the settings';

  @override
  String imagePickerPickError(String error) {
    return 'The image could not be selected: $error';
  }

  @override
  String imagePickerSaveError(String error) {
    return 'The image could not be saved: $error';
  }

  @override
  String get feedbackThankYouTitle => 'Your feedback has been recorded';

  @override
  String get feedbackThankYouMessage =>
      'Thank you! Your feedback helps us improve Aurora.';

  @override
  String get feedbackStayInTouch => 'Stay in touch';

  @override
  String get feedbackAuroraDiscord => 'Aurora on Discord';

  @override
  String get feedbackWebsite => 'Website';

  @override
  String get feedbackEmail => 'Email';

  @override
  String get crashTitle => 'Something went wrong';

  @override
  String get crashMessage =>
      'Aurora hit an unexpected error. Your data is not affected by it.';

  @override
  String get crashTechnicalDetails => 'Technical details';

  @override
  String get crashReport => 'Report the error';

  @override
  String get crashRestart => 'Restart the app';

  @override
  String get crashContinue => 'Carry on anyway';

  @override
  String get doodleSendDrawing => 'Send the drawing';

  @override
  String get doodleSticker => 'Sticker';

  @override
  String get doodleStrokeWidth => 'Line width';

  @override
  String get doodleStrokeThin => 'Thin line';

  @override
  String get doodleStrokeMedium => 'Medium line';

  @override
  String get doodleStrokeThick => 'Thick line';

  @override
  String get imagePickerDrawYourself => 'Draw it yourself';

  @override
  String get doodleAvatarTitle => 'Draw your picture';

  @override
  String get doodleAvatarDone => 'Done';

  @override
  String get doodleAvatarEmptyHint => 'Draw something first';

  @override
  String get permCreateProfilesLabel => 'Add a part';

  @override
  String get permCreateProfilesDesc => 'Take a new part into Aurora';

  @override
  String get permDeactivateProfilesLabel => 'Hide a part';

  @override
  String get permDeactivateProfilesDesc =>
      'Hide a part for a while — visible again later';

  @override
  String get permManagePermissionsLabel => 'Manage rights';

  @override
  String get permManagePermissionsDesc => 'Decide what other parts may do';

  @override
  String get permAccessSettingsLabel => 'App settings';

  @override
  String get permAccessSettingsDesc => 'Set up and adjust Aurora';

  @override
  String get permViewChatLabel => 'Read the chat';

  @override
  String get permViewChatDesc => 'See messages in the internal chat';

  @override
  String get permSendChatMessageLabel => 'May send anything';

  @override
  String get permSendChatMessageDesc =>
      'One right covering every kind of message — replaces the single rights below';

  @override
  String get permSendTextMessageLabel => 'Write text';

  @override
  String get permSendTextMessageDesc => 'Put written messages into the chat';

  @override
  String get permSendDoodleLabel => 'Draw';

  @override
  String get permSendDoodleDesc => 'Share drawings and scribbles';

  @override
  String get permSendVoiceMessageLabel => 'Speak';

  @override
  String get permSendVoiceMessageDesc =>
      'Record something and send your own voice';

  @override
  String get permSendImageLabel => 'Send pictures';

  @override
  String get permSendImageDesc => 'Take photos or share them from the gallery';

  @override
  String get permSendVideoLabel => 'Send videos';

  @override
  String get permSendVideoDesc =>
      'Record videos or share them from the gallery';

  @override
  String get permDeleteOwnMessagesLabel => 'Delete your own messages';

  @override
  String get permDeleteOwnMessagesDesc =>
      'Take back only what you wrote yourself';

  @override
  String get permDeleteAllMessagesLabel => 'Delete other parts\' messages';

  @override
  String get permDeleteAllMessagesDesc =>
      'Remove messages from other parts too — this cannot be undone';

  @override
  String get permViewCalendarLabel => 'See the calendar';

  @override
  String get permViewCalendarDesc => 'See what is coming up';

  @override
  String get permCreateEventsLabel => 'Add an appointment';

  @override
  String get permCreateEventsDesc => 'Put new appointments into the calendar';

  @override
  String get permEditOwnEventsLabel => 'Change your own appointments';

  @override
  String get permEditOwnEventsDesc =>
      'Edit only appointments you added yourself';

  @override
  String get permEditAllEventsLabel => 'Change every appointment';

  @override
  String get permEditAllEventsDesc => 'Edit other parts\' appointments too';

  @override
  String get permDeleteOwnEventsLabel => 'Delete your own appointments';

  @override
  String get permDeleteOwnEventsDesc =>
      'Remove only appointments you added yourself';

  @override
  String get permDeleteAllEventsLabel => 'Delete every appointment';

  @override
  String get permDeleteAllEventsDesc =>
      'Remove other parts\' appointments too — this cannot be undone';

  @override
  String get permAttachEventMediaLabel => 'Appointment attachments';

  @override
  String get permAttachEventMediaDesc =>
      'Attach pictures and notes to an appointment';

  @override
  String get permCommentOnCalendarEventsLabel => 'Comment';

  @override
  String get permCommentOnCalendarEventsDesc => 'Add a note to an appointment';

  @override
  String get permViewMedicationLabel => 'See the medications';

  @override
  String get permViewMedicationDesc => 'See what the body gets and when';

  @override
  String get permManageMedicationLabel => 'Manage medications';

  @override
  String get permManageMedicationDesc => 'Add, change and remove medications';

  @override
  String get permLogMedicationLabel => 'Confirm a dose';

  @override
  String get permLogMedicationDesc => 'Tick off what has already been taken';

  @override
  String get permOverrideMedicationLogLabel => 'Undo a dose entry';

  @override
  String get permOverrideMedicationLogDesc =>
      'Change a confirmation another part made';

  @override
  String get permCommentOnMedicationLabel => 'Comment';

  @override
  String get permCommentOnMedicationDesc => 'Add a note to a medication';

  @override
  String get permViewOwnDiaryLabel => 'Your own diary';

  @override
  String get permViewOwnDiaryDesc => 'Read only your own entries';

  @override
  String get permViewAllDiariesLabel => 'Every diary';

  @override
  String get permViewAllDiariesDesc => 'Read other parts\' entries too';

  @override
  String get permWriteDiaryLabel => 'Write in the diary';

  @override
  String get permWriteDiaryDesc => 'Write something in the diary';

  @override
  String get permViewContactsLabel => 'See the contacts';

  @override
  String get permViewContactsDesc => 'See who is around you';

  @override
  String get permManageContactsLabel => 'Manage contacts';

  @override
  String get permManageContactsDesc => 'Add, change and remove people';

  @override
  String get permCommentOnContactsLabel => 'Comment';

  @override
  String get permCommentOnContactsDesc => 'Add a note to a person';

  @override
  String get permViewFinderLabel => 'See the finder';

  @override
  String get permViewFinderDesc =>
      'Look up where something is or where you were';

  @override
  String get permManageFinderLabel => 'Manage the finder';

  @override
  String get permManageFinderDesc =>
      'Add, change and remove places and objects';

  @override
  String get permCommentOnFinderEntriesLabel => 'Comment';

  @override
  String get permCommentOnFinderEntriesDesc =>
      'Add a note to a place or object';

  @override
  String get permCreateDiaryEntryLabel => 'Write an entry';

  @override
  String get permCreateDiaryEntryDesc => 'Create a new diary entry';

  @override
  String get permEditOwnDiaryEntriesLabel => 'Change your own entries';

  @override
  String get permEditOwnDiaryEntriesDesc =>
      'Edit only entries you wrote yourself';

  @override
  String get permEditAllDiaryEntriesLabel => 'Change every entry';

  @override
  String get permEditAllDiaryEntriesDesc => 'Edit other parts\' entries too';

  @override
  String get permDeleteOwnDiaryEntriesLabel => 'Delete your own entries';

  @override
  String get permDeleteOwnDiaryEntriesDesc =>
      'Remove only entries you wrote yourself';

  @override
  String get permDeleteAllDiaryEntriesLabel => 'Delete every entry';

  @override
  String get permDeleteAllDiaryEntriesDesc =>
      'Remove other parts\' entries too — this cannot be undone';

  @override
  String get permCommentOnDiaryEntriesLabel => 'Comment';

  @override
  String get permCommentOnDiaryEntriesDesc => 'Add a note to an entry';

  @override
  String get permViewSharedEntriesLabel => 'Shared entries';

  @override
  String get permViewSharedEntriesDesc =>
      'Read entries shared with more than one part';

  @override
  String get permViewEmergencyContactsLabel => 'See the emergency contacts';

  @override
  String get permViewEmergencyContactsDesc =>
      'See who can be reached in an emergency';

  @override
  String get permCallEmergencyContactsLabel => 'Call';

  @override
  String get permCallEmergencyContactsDesc =>
      'Call someone straight away in an emergency';

  @override
  String get permEditEmergencyContactsLabel => 'Edit the emergency contacts';

  @override
  String get permEditEmergencyContactsDesc =>
      'Add, change and remove emergency contacts';

  @override
  String get permResetPasswordsLabel => 'Reset passwords';

  @override
  String get permResetPasswordsDesc => 'Set a new password for another part';

  @override
  String get permChangeOwnPasswordLabel => 'Change your own password';

  @override
  String get permChangeOwnPasswordDesc =>
      'Set a new password for yourself only';

  @override
  String get permEnableBiometricsLabel => 'Turn on biometrics';

  @override
  String get permEnableBiometricsDesc =>
      'Sign in with a fingerprint or your face';

  @override
  String get permViewChatTabLabel => 'Chat area';

  @override
  String get permViewChatTabDesc => 'See the chat at all';

  @override
  String get permViewFeedbackTabLabel => 'Feedback area';

  @override
  String get permViewFeedbackTabDesc => 'Write to the people building Aurora';

  @override
  String get permViewCalendarTabLabel => 'Calendar area';

  @override
  String get permViewCalendarTabDesc => 'See the calendar at all';

  @override
  String get permViewMedicationTabLabel => 'Medication area';

  @override
  String get permViewMedicationTabDesc => 'See the medication plan at all';

  @override
  String get permViewDiaryTabLabel => 'Diary area';

  @override
  String get permViewDiaryTabDesc => 'See the diary at all';

  @override
  String get permViewContactsTabLabel => 'Contacts area';

  @override
  String get permViewContactsTabDesc => 'See the contacts at all';

  @override
  String get permViewFinderTabLabel => 'Finder area';

  @override
  String get permViewFinderTabDesc => 'See the finder at all';

  @override
  String get permViewEmergencyTabLabel => 'Emergency area';

  @override
  String get permViewEmergencyTabDesc => 'See the emergency help at all';

  @override
  String get permViewHelpTabLabel => 'Help area';

  @override
  String get permViewHelpTabDesc => 'See help and support services at all';

  @override
  String get permViewMantrasTabLabel => 'Mantras area';

  @override
  String get permViewMantrasTabDesc => 'See the mantras at all';

  @override
  String get permViewGamesTabLabel => 'Games area';

  @override
  String get permViewGamesTabDesc => 'See the games at all';

  @override
  String get permViewTimelineTabLabel => 'Timeline area';

  @override
  String get permViewTimelineTabDesc =>
      'See when which part was there — and where';

  @override
  String permissionYouNeed(String permission) {
    return 'You need: $permission';
  }

  @override
  String get fact01 =>
      'DID (dissociative identity disorder) affects around 1–2% of people.';

  @override
  String get fact02 =>
      'Everyone in a system can have their own likes, skills and memories.';

  @override
  String get fact03 =>
      'Talking with each other inside is an important step towards stability and healing.';

  @override
  String get fact04 =>
      'Dissociation is a natural way the mind protects itself.';

  @override
  String get fact05 =>
      'Many people with DID function well and lead successful lives.';

  @override
  String get fact06 =>
      'Aurora was built specifically for people in a system to talk with each other.';

  @override
  String get fact07 =>
      'The chat area lets you talk safely inside, without any other app.';

  @override
  String get fact08 =>
      'Every profile can have its own permissions — from full access to a narrow set.';

  @override
  String get fact09 =>
      'The first profile automatically becomes the admin, with every permission.';

  @override
  String get fact10 =>
      'The calendar makes important appointments visible to everyone in the system.';

  @override
  String get fact11 =>
      'In the medication area you can manage both daily and as-needed medications.';

  @override
  String get fact12 =>
      'The finder helps you note down lost things and find them again.';

  @override
  String get fact13 =>
      'The emergency diary records difficult situations for your therapist.';

  @override
  String get fact14 =>
      'Mantras can help you ground yourself during dissociation or stress.';

  @override
  String get fact15 =>
      'In the contacts area you can rate important people and add notes about them.';

  @override
  String get fact16 => 'You can pick a colour of its own for every profile.';

  @override
  String get fact17 =>
      'Voice messages let you communicate even when writing is hard.';

  @override
  String get fact18 =>
      'Scribbles in the chat help you show feelings you cannot put into words.';

  @override
  String get fact19 =>
      'Your entries stay on your device. Only what you write in the feedback form is sent.';

  @override
  String get fact20 =>
      'Checking in regularly with everyone inside helps you work together.';

  @override
  String get fact21 => 'A shared calendar avoids double bookings and stress.';

  @override
  String get fact22 =>
      'Notes in the emergency diary can be a real help in therapy.';

  @override
  String get fact23 =>
      'Everyone inside may have needs of their own — that is entirely normal.';

  @override
  String get fact24 =>
      'Grounding exercises can help you stay in the here and now.';

  @override
  String get fact25 =>
      'Routines give everyone in the system safety and structure.';

  @override
  String get fact26 => 'Breaks matter — for everyone inside, too.';

  @override
  String get fact27 =>
      'You can hide profiles any time and bring them back later.';

  @override
  String get fact28 => 'The admin can adjust permissions at any time.';

  @override
  String get fact29 => 'As-needed medications can be logged on the spot.';

  @override
  String get fact30 =>
      'In the chat you can address particular people directly.';

  @override
  String get fact31 => 'Aurora uses strong encryption for sensitive data.';

  @override
  String get fact32 => 'Passwords are never stored in plain text.';

  @override
  String get fact33 =>
      'Resetting a password takes 24 hours, as a safety measure.';

  @override
  String get fact34 =>
      'All chat messages stay private and are stored on the device.';

  @override
  String get fact35 => 'Every step towards better communication is a success.';

  @override
  String get fact36 => 'It is fine to disagree with each other inside.';

  @override
  String get fact37 => 'Working together makes you strong — inside, too.';

  @override
  String get fact38 => 'You are not alone — many people live well with DID.';

  @override
  String get sliderChat0 => '👁️ Read the chat and draw';

  @override
  String get sliderChat1 =>
      '✅ Everything in the chat: text, drawings, voice, pictures, videos';

  @override
  String get sliderCalendar0 => '❌ No access to the calendar';

  @override
  String get sliderCalendar1 => '👁️ See appointments';

  @override
  String get sliderCalendar2 => '📅 Add and change your own appointments';

  @override
  String get sliderCalendar3 =>
      '✅ Manage every appointment and add attachments';

  @override
  String get sliderMedication0 => '❌ No access to medications';

  @override
  String get sliderMedication1 => '👁️ See the medication list';

  @override
  String get sliderMedication2 => '✅ Confirm doses';

  @override
  String get sliderDiary0 => '❌ No access to the diary';

  @override
  String get sliderDiary1 => '👁️ Read only your own diary';

  @override
  String get sliderDiary2 => '📝 Write in your own diary';

  @override
  String get sliderDiary3 => '✅ Read and write in every diary';

  @override
  String get sliderContacts0 => '❌ No access to contacts';

  @override
  String get sliderContacts1 => '👁️ See the contacts';

  @override
  String get sliderContacts2 => '💬 See the contacts and add notes';

  @override
  String get sliderContacts3 => '✅ Manage contacts: add, change, delete';

  @override
  String get sliderFinder0 => '❌ No access to the finder';

  @override
  String get sliderFinder1 => '👁️ See the entries';

  @override
  String get sliderFinder2 => '✅ Manage the entries';

  @override
  String get sliderEmergencyDiary0 => '❌ No access to the emergency diary';

  @override
  String get sliderEmergencyDiary1 => '👁️ See the entries';

  @override
  String get sliderEmergencyDiary2 =>
      '💬 Add and comment on entries, change your own';

  @override
  String get sliderEmergencyDiary3 => '✅ Manage every entry';

  @override
  String get sliderEmergency0 => '❌ No access to emergency contacts';

  @override
  String get sliderEmergency1 => '👁️ See the emergency contacts';

  @override
  String get sliderEmergency2 => '📞 See and call the emergency contacts';

  @override
  String get sliderEmergency3 => '✅ Manage the emergency contacts';

  @override
  String get sliderHelp0 => '❌ No access to help';

  @override
  String get sliderHelp1 => '✅ See help and support services';

  @override
  String get sliderMantras0 => '❌ No access to mantras';

  @override
  String get sliderMantras1 => '✅ Use the mantras';

  @override
  String get sliderGames0 => '❌ No access to games';

  @override
  String get sliderGames1 => '✅ Play the games';

  @override
  String get settingsDeleteAll => 'Delete everything';

  @override
  String get settingsCacheClearHint =>
      'The maps load again next time you open them. This can free up storage.';

  @override
  String get settingsGpsWhileInUse => 'Allowed while in use ✓';

  @override
  String get settingsGpsNotAllowed => 'Not allowed';

  @override
  String settingsGpsStatusLine(String status) {
    return '⚠️ $status';
  }

  @override
  String get settingsGpsBackgroundRuns =>
      'GPS runs continuously in the background';

  @override
  String get settingsGpsOverridesAll =>
      'Overrides the tracking setting of EVERY profile';

  @override
  String get settingsStepTapPermission => 'Tap “Permissions”';

  @override
  String get settingsStepTapLocation => 'Tap “Location”';

  @override
  String get settingsStepChooseAlways => 'Choose “Allow all the time”';

  @override
  String get settingsStepOpenSettings =>
      'Tap “Open the Android settings” below';

  @override
  String get settingsStepPermissionLocation =>
      'Choose “Permissions” → “Location”';

  @override
  String get settingsPositionAlways => 'The position is recorded continuously';

  @override
  String get settingsOverridesProfiles =>
      'Overrides the setting of each individual profile';

  @override
  String get settingsAllProfilesTracked =>
      'Every profile is recorded automatically';

  @override
  String get settingsOpenGpsSettings => 'Open the GPS settings';

  @override
  String get settingsGpsRunsForAll => 'GPS runs continuously for every profile';

  @override
  String get settingsNotifAsNeeded =>
      'As-needed medication: Aurora speaks up as soon as the next dose is allowed — 30, 10 and 5 minutes ahead';

  @override
  String get settingsNotifWorksClosed => 'Works even when the app is closed';

  @override
  String get aboutTitle => 'About Aurora';

  @override
  String get aboutChat =>
      'Talk with each other — with text, pictures, videos and voice messages';

  @override
  String get aboutCalendar =>
      'Shared appointments with reminders and attachments';

  @override
  String get aboutMedication => 'Medication plans with a record of every dose';

  @override
  String get aboutEmergencyDiary =>
      'A shared logbook for crises and important events';

  @override
  String get aboutContacts =>
      'Your own ratings and notes about the people around you';

  @override
  String get aboutFinder => 'Find places and objects again';

  @override
  String get aboutLocalOnly => 'All data stays on your device — no cloud';

  @override
  String get telemetryQuestion => 'Will you help make Aurora better?';

  @override
  String get telemetryExplanation =>
      'Aurora can count which areas get opened and where things break off. Only the name of the event, the day and the app version are sent — no text, no location and nothing that leads back to you. Each message goes out right away, so the time it arrives is also the time you were using Aurora.';

  @override
  String get telemetryChangeLater =>
      'You can change this any time in the settings under “What Aurora sends”. Every single message that left your device is listed there too.';

  @override
  String get transparencyIntroFull =>
      'Here you see every transmission that left your device — complete and word for word.';

  @override
  String get transparencyIrreversibleFull =>
      'What has already been sent cannot be called back. It is not linked to you — which is also why it cannot be found and deleted.';

  @override
  String get transparencyWaitingForConnection => 'Waiting for a connection';

  @override
  String get privacyTitle => 'Privacy notice';

  @override
  String get privacyAtAGlance => 'Privacy at a glance';

  @override
  String get privacyWhatIsStored => 'What data is stored?';

  @override
  String get privacyTransmission => 'Data transmission';

  @override
  String get privacyDeletion => 'Deleting data';

  @override
  String get privacyMinors => 'Protection of minors';

  @override
  String get privacyChanges => 'Changes to this notice';

  @override
  String get privacyClosing => 'Aurora — your data stays with you.';

  @override
  String get mediaImageNotOpened => 'The picture could not be opened';

  @override
  String get mediaVideoNotOpened => 'The video could not be opened';

  @override
  String get mediaFromGallery => 'From the gallery';

  @override
  String get mediaPickImage => 'Choose a picture';

  @override
  String get mediaPickVideo => 'Choose a video';

  @override
  String get transportDirectToDevelopers => 'Straight to the developers';

  @override
  String get transportSendFailed =>
      'Sending failed. Try again later or send it by email.';

  @override
  String get transportRejected => 'The server refused the message.';

  @override
  String get transportUnreachable => 'The server cannot be reached right now.';

  @override
  String get transparencyArrived => 'Delivered';

  @override
  String transparencyNotSent(String reason) {
    return 'Not sent: $reason';
  }

  @override
  String get transparencyReasonUnknown => 'reason unknown';

  @override
  String get transportTryLaterOrEmail => 'Try again later or send it by email.';

  @override
  String get transportEmailInstead =>
      'You can send your feedback by email instead.';

  @override
  String get crashDialogTitle => 'Aurora crashed';

  @override
  String get errorDialogTitle => 'Aurora noticed a problem';

  @override
  String get errorHelpUsFix => 'Would you help us fix it?';

  @override
  String get errorSendingFailed => 'Something went wrong while sending.';

  @override
  String get feedbackContactOptions => 'Ways to reach us';

  @override
  String get feedbackInvalidEmail => 'That email address is not valid';

  @override
  String get feedbackArrived => 'Thank you for your feedback. It arrived.';

  @override
  String get feedbackQueued =>
      'Accepted. It goes out as soon as you are online again.';

  @override
  String get feedbackSendFailed => 'Sending failed. Try again later.';

  @override
  String get profilePickImage => 'Choose a profile picture';

  @override
  String get profilePasswordOptional =>
      'Protect your profile with a password (optional)';

  @override
  String get profilePasswordOptionalMin =>
      'Protect your profile with a password (optional, at least 4 characters)';

  @override
  String get thankYouWeReceived =>
      'We received your report and will write to you by email if we have questions.';

  @override
  String get thankYouWeCheck => 'We look at your report';

  @override
  String get thankYouWeFix => 'We work on a fix';

  @override
  String get thankYouYouGetMail =>
      'You get an email as soon as the fix is ready';

  @override
  String get thankYouNextUpdate => 'The fix comes with the next update';

  @override
  String get mapGpsLoading => 'GPS is loading…';

  @override
  String get mapGpsPositionLoading => 'Loading the position…';

  @override
  String get mapAllowLocation =>
      'Allow location access to see where you are on the map';

  @override
  String mapLastKnownPosition(String age) {
    return 'The map shows your last known position: $age.';
  }

  @override
  String get pwResetThenReplaced => '✓ Only then is the old password replaced';

  @override
  String get pwResetCanActivateNow => 'Your new password can be activated now';

  @override
  String get pwResetRunningShort => 'Reset in progress…';

  @override
  String get moodVeryHappy => 'Very happy';

  @override
  String get moodHappy => 'Happy';

  @override
  String get moodAnxious => 'Anxious';

  @override
  String get moodAngry => 'Angry';

  @override
  String get emergencyPositionUnavailable => 'Position not available';

  @override
  String get emergencyPositionNoPermission =>
      'Position not available (no permission)';

  @override
  String get emergencyMessageSubject => 'Emergency message from Aurora';

  @override
  String autoLogoutAfter(int minutes) {
    return 'Sign out automatically after $minutes minutes of no use';
  }

  @override
  String get pwResetBannerReady => 'Password ready to activate';

  @override
  String get doodleHistory => 'Step through the history';

  @override
  String get doodleDraw => 'Draw';

  @override
  String get doodleSendEmptyHint => 'Draw first — then you can send';

  @override
  String get anchorTelemetryNotice =>
      'Anonymous counting is on — what Aurora sends';

  @override
  String get timePhaseMorning => 'morning';

  @override
  String get timePhaseMidday => 'midday';

  @override
  String get timePhaseAfternoon => 'afternoon';

  @override
  String get timePhaseEvening => 'evening';

  @override
  String get timePhaseNight => 'night';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingDay => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get anchorSwitchProfile => 'That\'s not me';

  @override
  String get greetingNight => 'Hello';

  @override
  String get quickTimelineYou => '(You)';

  @override
  String todayEvents(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count appointments today',
      one: '1 appointment today',
    );
    return '$_temp0';
  }

  @override
  String todayMedications(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count medications today',
      one: '1 medication today',
    );
    return '$_temp0';
  }

  @override
  String workSurfaceActiveProfile(String name) {
    return '$name is here right now';
  }

  @override
  String get doodleUndo => 'Undo';

  @override
  String get doodleClear => 'Clear everything';

  @override
  String get finderPersonName => 'Name of the person';

  @override
  String get finderPlaceTitle => 'Title for this place';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get puzzleCategoryAnimals => 'Cute, calming animals';

  @override
  String get puzzleCategoryWater => 'Sea and water';

  @override
  String get puzzleCategoryFlowers => 'Colourful flowers and plants';

  @override
  String get gpsTrackingOffTap => 'Recording off — tap to turn on';

  @override
  String get gpsTrackingOnTap => 'Recording on — tap to turn off';

  @override
  String get gpsNoPermissionHint =>
      'Without location permission Aurora cannot start recording. You can grant it in the Android settings under Apps → Aurora → Permissions.';

  @override
  String get settingsCouldNotOpen => 'The settings could not be opened.';

  @override
  String get settingsOpenAppSettings => 'Open the app settings';

  @override
  String get gpsWaitingFirstUpdate => 'Waiting for the first position…';

  @override
  String get imagePickerOpenCamera => 'Open the camera';

  @override
  String get imagePickerFromGallery => 'Choose from the gallery';

  @override
  String get imagePickerAnimalAvatar => 'Choose an animal avatar';

  @override
  String get animalAvatarDog => 'Dog';

  @override
  String get animalAvatarCat => 'Cat';

  @override
  String get animalAvatarGiraffe => 'Giraffe';

  @override
  String get puzzleDragPieces => 'Drag the pieces into place';

  @override
  String get puzzleTapPieces => 'Move the pieces by tapping them';

  @override
  String get feedbackTabSend => 'Send feedback';

  @override
  String get pwResetRunningFull =>
      'You set a new password a short while ago. For safety, a 24-hour timer is now running.\n\n✓ Your OLD password stays active\n✓ Once the time is up you can activate the new one\n✓ Only then is the old one replaced';

  @override
  String get transportRejectedFull =>
      'The server refused the message. Send it by email instead.';

  @override
  String get transportUnreachableFull =>
      'The server cannot be reached right now. Try again later or send it by email.';

  @override
  String transportFailedWithCode(String code) {
    return 'Sending failed ($code). You can send your feedback by email instead.';
  }

  @override
  String get transportNoMailApp =>
      'No email app could be opened. You can copy the text and send it yourself.';

  @override
  String get emergencySmsSubject => 'Emergency message from Aurora';

  @override
  String get pwResetBannerRunning => 'Password reset in progress';

  @override
  String get puzzleDragHint => 'Drag the pieces into place';

  @override
  String get puzzleTapHint => 'Move the pieces by tapping them';

  @override
  String get medicationConfirm => 'Confirm';

  @override
  String get medicationAddFirstAsNeeded =>
      'Add your first as-needed medication';

  @override
  String medicationTakenBy(String name) {
    return '✓ Taken by $name';
  }

  @override
  String medicationRefusedBy(String name) {
    return '✗ Refused by $name';
  }

  @override
  String get imprintPerLaw => 'Information under § 5 TMG (German law)';

  @override
  String get imprintResponsible => 'Responsible for the content';

  @override
  String get timelineSkipped => 'skipped';

  @override
  String get timelineDueSoon => 'Due soon';

  @override
  String get medicationLater => 'later';

  @override
  String get debugLogHint =>
      'This report holds technical details about the app. Copy it with the button in the top right to send it along when something goes wrong.';

  @override
  String get unsavedChangesTitle => 'Unsaved changes';

  @override
  String get hotlineForYoung => 'For children and young people';

  @override
  String get hotlineAnonymousFree => 'Free and anonymous';

  @override
  String get hotlineHoursNumberAgainstSorrow => 'Mon–Sat 2 pm – 8 pm';

  @override
  String get hotlineInfoNotAcute => 'Information, not acute help';

  @override
  String get hotlineHoursDepressionInfo =>
      'Mon, Tue, Thu 1–5 pm · Wed, Fri 8:30 am – 12:30 pm';

  @override
  String get hotlineChatUnder25 => 'Chat counselling, for everyone under 25';

  @override
  String get helpEmergencyDangerTitle => 'If someone is in immediate danger';

  @override
  String get helpEmergencyDangerBody =>
      'The emergency number works day and night, even without credit.';

  @override
  String get helpEmergencyCallEmergencyNumber => 'Emergency call 112';

  @override
  String get helpTalkTitle => 'If you need to talk or want advice';

  @override
  String get helpGroupRoundTheClock => 'Available around the clock';

  @override
  String get helpGroupLimitedHours => 'Available at certain times';

  @override
  String helpSourcesCheckedOn(String datum) {
    return 'Details checked on $datum';
  }

  @override
  String get cameraCouldNotOpen => 'The camera could not be opened';

  @override
  String get feedbackDeviceDiagnostics => '--- Device diagnostics ---';

  @override
  String get eventNoReminder =>
      'The appointment is only in the calendar. Aurora will not speak up on its own.';

  @override
  String get unsavedChangesMessage =>
      'You made changes.\n\nDo you want to save them?';

  @override
  String get confirmSave => 'Save';

  @override
  String get videoCouldNotLoad => 'The video could not be loaded';

  @override
  String get finderDaily => 'daily';

  @override
  String get mapNotAvailable => 'Map not available';

  @override
  String get medicationAnotherDose =>
      'Do you want to take another dose anyway?';

  @override
  String get feedbackThankYouReceived =>
      'We received your feedback and will write to you by email if we have questions.';

  @override
  String get positionAgeYesterday => 'from yesterday';

  @override
  String get timePickerTitle => 'Choose a time';

  @override
  String get reminderPermissionMissingTitle =>
      'Aurora is not allowed to remind you right now';

  @override
  String reminderPermissionMissingBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Reminders are switched on for $count intake times. Without the device\'s permission none of them arrive.',
      one:
          'Reminders are switched on for one intake time. Without the device\'s permission it will not arrive.',
    );
    return '$_temp0';
  }

  @override
  String get reminderPermissionMissingAction => 'Grant permission';

  @override
  String get timePickerHours => 'Hours';

  @override
  String get timePickerMinutes => 'Minutes';

  @override
  String get commentsNoneYet => 'No comments yet';

  @override
  String get notificationDiscreetBody => 'Reminder — tap to see';

  @override
  String get reminderNoPermission =>
      'Without notification permission Aurora cannot remind you. You can grant it in the Android settings under Apps → Aurora → Notifications.';

  @override
  String get telemetryConsentAccept => 'Yes, gladly';

  @override
  String get telemetryConsentDecline => 'Continue without';

  @override
  String get transparencyGroupTelemetry => 'Telemetry';

  @override
  String get telemetryExampleIntro => 'This is what a message looks like:';

  @override
  String get telemetryExampleEvent => 'Event';

  @override
  String get telemetryExampleDay => 'Day';

  @override
  String get telemetryExampleVersion => 'App version';

  @override
  String get onboardingDismiss => 'Don\'t show again';

  @override
  String get eventStart => 'Start';

  @override
  String get eventEnd => 'End';

  @override
  String get chatCapturePhoto => 'Take a photo';

  @override
  String get chatCaptureImageShort => 'Photo';

  @override
  String get doodleErase => 'Erase';

  @override
  String get chatRecordVideo => 'Record a video';

  @override
  String get chatRecordVideoSubtitle => 'Create a new video';

  @override
  String get actionDiscard => 'Discard';

  @override
  String get actionKeep => 'Keep';

  @override
  String get actionDetails => 'Details';

  @override
  String get resetWaitingPeriodTitle => 'Waiting period for the reset';

  @override
  String get fieldNameHint => 'e.g. Max, Anna, Leo';

  @override
  String get fieldPasswordHint => 'At least 4 characters';

  @override
  String get fieldPasswordConfirmHint => 'Repeat password';

  @override
  String get fieldPasswordEnterHint => 'Enter password';

  @override
  String get feedbackCommunityJoin => 'Join our community';

  @override
  String get feedbackDiscord => 'Discord server';

  @override
  String get feedbackGithub => 'GitHub';

  @override
  String get feedbackGithubSubtitle => 'Bug reports & issues';

  @override
  String get timelineProfileSwitch => 'Profile switch';

  @override
  String get debugLogReportTitle => 'Debug log report';

  @override
  String get formPickImage => 'Choose an image';

  @override
  String get permissionGrant => 'Grant permission';

  @override
  String get pwResetRestart => 'Start again';

  @override
  String get navBackToAnchor => 'To the anchor';

  @override
  String get mapGpsPositionLoadingHint => 'Just a moment';

  @override
  String get voiceRecordingStartFailed => 'The voice recording could not start';

  @override
  String get voiceRecordingStopFailed =>
      'The voice recording could not be stopped';

  @override
  String get voiceRecordingDiscardFailed =>
      'The voice recording could not be discarded';

  @override
  String get trackingPermissionDeniedHint =>
      'Location permission denied. Turn it on in the settings.';

  @override
  String get pwResetVisibleToAll => 'The waiting period is visible to everyone';

  @override
  String get pwResetRestartResetsTimer =>
      'Note: starting again resets the waiting period';

  @override
  String get pwResetActivatedAtNextLogin =>
      'The new password is activated at the next login';

  @override
  String get imagePickerCameraDeniedForever =>
      'The camera permission was denied permanently. Turn it on in the settings.';

  @override
  String get imagePickerGalleryDeniedForever =>
      'The gallery permission was denied permanently. Turn it on in the settings.';

  @override
  String get permissionCameraTitle => 'Camera permission';

  @override
  String get permissionGalleryTitle => 'Gallery permission';

  @override
  String get profileResetFristExplanation =>
      'That is how long a password reset waits before it takes effect. Log in during that time and it is called off.';

  @override
  String get cameraNotFound => 'No camera found';

  @override
  String get validationNameRequired => 'Please enter a name';

  @override
  String get validationPasswordRequired => 'Please enter a password';

  @override
  String get transportCopyManually =>
      'You can copy the text and send it yourself.';

  @override
  String get statusSending => 'Sending...';

  @override
  String get errorReportSendButton => 'Send report';

  @override
  String get settingsGpsStatusAlwaysReady => '✅ Always allowed (ready!)';

  @override
  String get gpsActive => 'GPS on';

  @override
  String get gpsOff => 'GPS off';

  @override
  String get gpsStatusUnknown => 'GPS status unknown';

  @override
  String get gpsPermissionMissing => 'Location permission missing';

  @override
  String get gpsServiceDisabled => 'Location service disabled';

  @override
  String get permissionMissingShort => 'Permission missing';

  @override
  String get pwResetWrongPassword => 'Wrong password';

  @override
  String get pwResetStartTitle => 'Start the password reset?';

  @override
  String get pwResetExpired => 'The waiting period is over';

  @override
  String get pwResetForgotPassword => 'Forgot your password?';

  @override
  String get commentWritePlaceholder => 'Write a comment...';

  @override
  String get profileVisibilityTitle => 'Which profiles this belongs to';

  @override
  String get addressUnknown => 'Unknown address';

  @override
  String get activateNow => 'Turn on now';

  @override
  String get eventRemindMe => 'Reminder';

  @override
  String get noProfileAvailable => 'No profile yet';

  @override
  String get ratingVeryNegative => 'Very negative';

  @override
  String get ratingVeryPositive => 'Very positive';

  @override
  String get errorReportHelpUs => 'Help us fix the problem';

  @override
  String get errorReportDetailsSection => 'Report details';

  @override
  String get trackingLabel => 'Location tracking: ';

  @override
  String trackingLastUpdate(Object time) {
    return 'Last update: $time';
  }

  @override
  String profileSwitchError(Object error) {
    return 'Could not switch profile: $error';
  }

  @override
  String get gpsError => 'Location error';

  @override
  String get statusActive => 'On';

  @override
  String get statusPaused => 'Paused';

  @override
  String timeSecondsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seconds ago',
      one: 'a second ago',
    );
    return '$_temp0';
  }

  @override
  String timeInMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count minutes',
      one: 'in a minute',
    );
    return '$_temp0';
  }

  @override
  String timeInHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count hours',
      one: 'in an hour',
    );
    return '$_temp0';
  }

  @override
  String timeInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count days',
      one: 'in a day',
    );
    return '$_temp0';
  }

  @override
  String get languageFollowApp => 'App language';

  @override
  String get profileLanguageSubtitle =>
      'The language Aurora speaks with this part';

  @override
  String get contactCategoryFamily => 'Family';

  @override
  String get contactCategoryFriends => 'Friends';

  @override
  String get contactCategoryTherapists => 'Therapists';

  @override
  String get contactCategoryDoctors => 'Doctors';

  @override
  String get contactCategoryEmergency => 'Emergency';

  @override
  String get contactCategoryOther => 'Other';

  @override
  String get finderTypeLocation => 'Place';

  @override
  String get finderTypeItem => 'Item';

  @override
  String get diaryPriorityLow => 'Low';

  @override
  String get diaryPriorityMedium => 'Medium';

  @override
  String get diaryPriorityHigh => 'High';

  @override
  String get diaryPriorityCritical => 'Critical';

  @override
  String get moodNeutral => 'Neutral';

  @override
  String get moodSad => 'Sad';

  @override
  String get moodVerySad => 'Very sad';

  @override
  String get moodExcited => 'Excited';

  @override
  String timeHoursMinutesAgo(Object hours, Object minutes) {
    return '$hours hr $minutes min ago';
  }

  @override
  String presenceLastFront(Object when) {
    return 'last $when';
  }

  @override
  String get privacyGlanceBody =>
      'Aurora keeps everything on your device. Three things leave it — and only when you trigger or allow them: feedback you send, telemetry after you agree to it, and the map requests to OpenStreetMap.\n\nWhat was sent and when is written out word for word in Settings under “What Aurora sends”. None of it leads back to you.';

  @override
  String get privacyStoredBody =>
      'This data sits in the local database on your device:\n\n• Parts and settings\n• Messages between parts\n• Calendar appointments\n• Medication plans and doses taken\n• Journal and emergency entries\n• Contacts with ratings and notes\n• Places and items from the finder\n• Location history and switches between parts\n• Pictures, videos and voice messages\n\nNone of it is transmitted.';

  @override
  String get privacyTransmissionBody =>
      'Feedback — only when you send the form. It carries your text, the app version and the device model. No name, no identifier, no location.\n\nTelemetry — only after you explicitly agree, and you can withdraw that at any time. An event carries three fields: what happened, on which day, with which app version. No time of day, no identifier.\n\nMaps — when a map is shown and when an address is resolved, the visible map section and your IP address go to OpenStreetMap. That is the condition for there being a map at all.\n\nNever transmitted: location history, parts, messages, appointments, medication, journal and contacts.';

  @override
  String get privacyPermissions => 'Permissions';

  @override
  String get privacyPermissionsBody =>
      '• Location — for the map, the location history and the emergency screen. It stays on the device.\n• Background location — only if you switch on continuous recording. Without that switch it is not needed.\n• Camera and microphone — for photos and voice messages.\n• Storage — to load pictures and videos from your gallery.\n• Notifications and alarms — for medication and appointment reminders.\n\nEvery permission can be revoked in the system settings. The app will then say what no longer works.';

  @override
  String get privacySecurity => 'Data security';

  @override
  String get privacySecurityBody =>
      '• All data is local; there is no cloud sync.\n• Parts can be protected with a password.\n• There are no user accounts and no sign-in.\n\nBackups are your own responsibility. If the device is lost or breaks, the data is gone — that is the price of it living nowhere else.';

  @override
  String get privacyDeletionBody =>
      '• You can delete individual entries and messages.\n• Parts can be deactivated or deleted.\n• Settings has “Delete all data”.\n• Uninstalling the app takes everything with it.\n\nDeleted data cannot be restored.';

  @override
  String get privacyRights => 'Your rights';

  @override
  String get privacyRightsBody =>
      'Under the GDPR you have the right to access, rectification, erasure, restriction, data portability and objection. Because all data sits on your device, you exercise most of these directly in the app.\n\nFor feedback you have sent and for telemetry, contact the address below. You also have the right to lodge a complaint with a data protection authority.';

  @override
  String get privacyMinorsBody =>
      'Aurora may be used by minors. No data is collected about them that is not collected about anyone else — which means none, apart from the three routes named above.\n\nFor younger users it makes sense for a guardian to help with the setup.';

  @override
  String get privacyChangesBody =>
      'This statement may change as the app is updated. The version currently in force is the one shown here, and it carries its date below.';

  @override
  String get privacyContact => 'Controller and contact';

  @override
  String privacyAsOf(Object date) {
    return 'As of: $date';
  }

  @override
  String get startupFailedTitle => 'Aurora could not start';

  @override
  String get startupFailedBody =>
      'Something went wrong while starting up. You can try again. If that does not help, all stored data can be deleted — Aurora then starts empty.';

  @override
  String get startupRetry => 'Try again';

  @override
  String get startupDeleteAll => 'Delete all data';

  @override
  String get startupDeleteIncomplete =>
      'Not everything could be deleted. Some data is still here.';

  @override
  String get reminderPermissionBlocked =>
      'Aurora is not allowed to remind you yet. You can grant permission in the system settings.';

  @override
  String get reminderOpenSettings => 'Open settings';

  @override
  String get settingsTrackingPermissionNeeded =>
      'Aurora needs access to your location to keep track of your way.';

  @override
  String get settingsHowToEnableLocation => 'How to allow location:';

  @override
  String get settingsStepChooseWhileUsing => 'Choose \"While using the app\"';

  @override
  String get settingsTrackingNotice =>
      'While Aurora is keeping track, a notification stays in your status bar. No notification, no recording.';

  @override
  String get locationTrackingNotificationTitle =>
      'Aurora is keeping track of your way';

  @override
  String get locationTrackingNotificationBody =>
      'So you can find your places again later. Stays on your device.';

  @override
  String profileContinueAs(String name) {
    return 'Continue as $name';
  }

  @override
  String get profileContinueInProgress => 'One moment …';

  @override
  String get trackingPausedTitle => 'Recording paused';

  @override
  String get trackingPausedBody =>
      'After the restart, Aurora only records your route again once you open it. Tap here.';

  @override
  String get aboutAuroraSemantics => 'About Aurora';

  @override
  String get openTimelineSemantics => 'Open timeline';

  @override
  String get timeMapSemantics => 'Open timeline: map with time and place';
}
