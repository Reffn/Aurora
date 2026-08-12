// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Aurora';

  @override
  String get appSubtitle => 'Ta compagne sûre au quotidien avec le TDI';

  @override
  String get appDescription =>
      'Aurora t’accompagne pour organiser ton quotidien et la communication au sein de ton système.';

  @override
  String get tabChat => 'Chat';

  @override
  String get tabFeedback => 'Retours';

  @override
  String get tabCalendar => 'Calendrier';

  @override
  String get tabMedication => 'Médicaments';

  @override
  String get tabDiary => 'Journal';

  @override
  String get tabContacts => 'Contacts';

  @override
  String get tabFinder => 'Repères';

  @override
  String get tabEmergency => 'Urgence';

  @override
  String get tabHelp => 'Aide';

  @override
  String get tabMantras => 'Mantras';

  @override
  String get tabGames => 'Jeux';

  @override
  String get tabTimeline => 'Chronologie';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionEdit => 'Modifier';

  @override
  String get actionClose => 'Fermer';

  @override
  String get actionContinue => 'Continuer';

  @override
  String get actionConfirm => 'Confirmer';

  @override
  String get actionBack => 'Retour';

  @override
  String get actionQuit => 'Quitter';

  @override
  String get actionSend => 'Envoyer';

  @override
  String get actionShare => 'Partager';

  @override
  String get actionDone => 'Terminé';

  @override
  String get mainSettingLogout => 'Réglages / Déconnexion';

  @override
  String get dialogExitTitle => 'Quitter l’application ?';

  @override
  String get dialogExitMessage => 'Tu veux vraiment quitter Aurora ?';

  @override
  String get menuProfileEdit => 'Modifier le profil';

  @override
  String get menuSettings => 'Réglages';

  @override
  String get menuLogout => 'Déconnexion';

  @override
  String get profileMenuTitle => 'Profil et réglages';

  @override
  String get presenceRecentTitle => 'Qui était là ?';

  @override
  String get eventLocationTitle => 'Où cela se passe-t-il ?';

  @override
  String get eventLocationOther => 'Un autre endroit';

  @override
  String get eventLocationNone => 'Aucun lieu';

  @override
  String get eventLocationLabel => 'Lieu';

  @override
  String get eventLocationUnnamed => 'Lieu sur la carte';

  @override
  String get mapLocationNeeded =>
      'Aurora a besoin de ta position pour cette carte. Elle reste sur l\'appareil.';

  @override
  String get mapLocationAllow => 'Autoriser';

  @override
  String get profileSelectionTitle => 'Qui est là en ce moment ?';

  @override
  String get profileNewProfile => 'Nouveau profil';

  @override
  String get profileCreationTitle => 'Créer un nouveau profil';

  @override
  String get profileCreationSubtitle => 'Qui veut se présenter ?';

  @override
  String get profileCreationDescription =>
      'Crée ton profil personnel avec un nom, une couleur et un avatar. Chaque profil se règle séparément et reçoit des droits adaptés à l’âge.';

  @override
  String get profileEditTitle => 'Modifier le profil';

  @override
  String get profileEditSubtitle => 'Ajuste tes réglages';

  @override
  String get profileSectionIdentity => '👤 Identité';

  @override
  String get profileSectionAge => '🎂 Âge';

  @override
  String get profileSectionColor => '🎨 Couleur';

  @override
  String get profileSectionSecurity => '🔒 Questions de sécurité';

  @override
  String get profileWhoAreYou => 'Qui es-tu ?';

  @override
  String get profileWhoAreYouDescription =>
      'Écris ton nom et choisis un avatar. Ainsi, tout le monde dans le système peut te reconnaître et te distinguer. Tu peux aussi prendre une photo, en choisir une dans la galerie ou utiliser un des petits animaux.';

  @override
  String get profileColorTitle => 'Ta couleur à toi';

  @override
  String get profileColorDescription =>
      'Ta couleur te rend reconnaissable dans le système.';

  @override
  String get profileAgeTitle => 'Quel âge as-tu ?';

  @override
  String get profileAgeDescription =>
      'Ton âge détermine les fonctions auxquelles tu as accès.';

  @override
  String get profileSecurityTitle => 'Protège ton profil';

  @override
  String get profileSecurityDescription =>
      'Si tu veux, tu peux mettre un mot de passe (4 caractères au minimum).';

  @override
  String get profilePasswordOptionalInfo =>
      'Le mot de passe est facultatif. Laisse les champs vides si tu n’en veux pas.';

  @override
  String get profileModeChild => 'Mode enfant';

  @override
  String get profileModeFullAccess => 'Accès complet';

  @override
  String get profileModeChildDescription =>
      'Accès à : Chat (dessins), Journal, Jeux, Chronologie';

  @override
  String get profileModeFullDescription =>
      'Accès à : toutes les fonctions (Chat, Calendrier, Contacts, Médicaments, etc.)';

  @override
  String get profileActionSaveChanges => 'Enregistrer les modifications';

  @override
  String get profileActionCreateProfile => 'Créer le profil ✓';

  @override
  String get profileDeactivateTitle => 'Désactiver le profil ?';

  @override
  String profileDeactivateMessage(String name) {
    return 'Tu veux désactiver le profil « $name » ?\n\nIl sera masqué, mais tu pourras le réactiver plus tard.';
  }

  @override
  String get profileDeactivated => 'Profil désactivé';

  @override
  String get profileDeactivate => 'Désactiver';

  @override
  String get profileEditComingSoon => 'La modification arrive bientôt';

  @override
  String get profileNameExists => 'Un profil porte déjà ce nom';

  @override
  String get fieldName => 'Nom';

  @override
  String get fieldPassword => 'Mot de passe';

  @override
  String get fieldPasswordConfirm => 'Répéter le mot de passe';

  @override
  String get fieldAge => 'Âge';

  @override
  String get fieldColor => 'Couleur';

  @override
  String get fieldAvatar => 'Avatar';

  @override
  String get validationRequired => 'Champ obligatoire';

  @override
  String get validationPasswordLength => '4 caractères au minimum';

  @override
  String get validationPasswordMismatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String errorGeneric(String error) {
    return 'Erreur : $error';
  }

  @override
  String get errorNoProfile => 'Aucun profil sélectionné';

  @override
  String get errorNoPermission => 'Tu n’as pas le droit d’envoyer des messages';

  @override
  String get chatTitle => 'Chat';

  @override
  String get chatEmptyTitle => 'Pas encore de messages';

  @override
  String get chatEmptySubtitle => 'Partage ce que tu penses avec le système';

  @override
  String get chatMessageDoodle => '[Dessin]';

  @override
  String get chatMessageVoice => '[Message vocal]';

  @override
  String get chatMessageImage => '[Image]';

  @override
  String get chatMessageVideo => '[Vidéo]';

  @override
  String chatErrorSending(String error) {
    return 'Erreur à l’envoi : $error';
  }

  @override
  String chatErrorSendingVoice(String error) {
    return 'Erreur à l’envoi du message vocal : $error';
  }

  @override
  String chatErrorSendingImage(String error) {
    return 'Erreur à l’envoi de l’image : $error';
  }

  @override
  String chatErrorSendingVideo(String error) {
    return 'Erreur à l’envoi de la vidéo : $error';
  }

  @override
  String chatErrorSendingDoodle(String error) {
    return 'Erreur à l’envoi : $error';
  }

  @override
  String get chatRecordingInProgress => 'Enregistrement en cours...';

  @override
  String get chatRecordingHint =>
      'Appuie sur Arrêter pour envoyer le message vocal';

  @override
  String get chatRecordingStop => 'Arrêter';

  @override
  String get chatErrorMicPermission => 'Autorisation du microphone requise';

  @override
  String get chatErrorRecordingStart =>
      'Impossible de démarrer l\'enregistrement';

  @override
  String get chatInputHint => 'Écrire un message...';

  @override
  String get chatMessageFieldLabel => 'Message';

  @override
  String get chatAddMedia => 'Ajouter d\'autres médias';

  @override
  String get chatSendMessage => 'Envoyer le message';

  @override
  String get chatMediaSheetTitle => 'Ajouter des médias';

  @override
  String get chatNoPermissionHint => 'Pas d\'autorisation d\'envoyer';

  @override
  String get calendarTitle => 'Calendrier';

  @override
  String get medicationTitle => 'Médicaments';

  @override
  String get medicationNewTitle => 'Nouveau médicament';

  @override
  String get medicationEditTitle => 'Modifier le médicament';

  @override
  String get medicationDetailTitle => 'Détails du médicament';

  @override
  String get medicationNotFound => 'Médicament introuvable';

  @override
  String get medicationNotFoundMessage => 'Ce médicament n\'existe plus';

  @override
  String get medicationTabDaily => 'Médicaments quotidiens';

  @override
  String get medicationTabAsNeeded => 'Médicaments au besoin';

  @override
  String get medicationEmptyTitle => 'Aucun médicament 💊';

  @override
  String get medicationEmptySubtitle => 'Ajoute ton premier médicament';

  @override
  String get medicationEmptyAsNeededTitle => 'Aucun médicament au besoin 🩹';

  @override
  String get medicationEmptyAsNeededSubtitle =>
      'Ajoute ton premier médicament au besoin';

  @override
  String get medicationToday => 'Aujourd’hui';

  @override
  String get medicationStatMedications => 'Médicaments';

  @override
  String get medicationStatDoses => 'Prises';

  @override
  String medicationMarkedTaken(String name) {
    return '$name noté comme pris';
  }

  @override
  String medicationMarkedRefused(String name) {
    return '$name noté comme refusé';
  }

  @override
  String get medicationRefusalDialogTitle => 'Noter le refus';

  @override
  String medicationRefusalDialogMessage(String name) {
    return '$name sera noté comme refusé.';
  }

  @override
  String get medicationRefusalReasonLabel => 'Motif (facultatif)';

  @override
  String get medicationRefusalReasonHint => 'p. ex. nausées, fatigue, etc.';

  @override
  String get medicationRefusalWithoutNote => 'Sans note';

  @override
  String get medicationFeedbackDialogTitle => 'Ajouter une note';

  @override
  String medicationFeedbackQuestion(String name) {
    return 'Comment tu t’es senti·e après avoir pris $name ?';
  }

  @override
  String get medicationFeedbackLabel => 'Ton ressenti';

  @override
  String get medicationFeedbackHint =>
      'p. ex. « ça m’a fatigué·e », « ça m’a bien aidé·e », etc.';

  @override
  String get medicationFeedbackSaved => 'Note enregistrée';

  @override
  String get medicationFeedbackViewTitle => 'Notes';

  @override
  String get diaryTitle => 'Journal';

  @override
  String get diaryEmptyTitle => 'Ton journal t’attend ! ✨';

  @override
  String get diaryEmptySubtitle =>
      'Recueille tes pensées, tes vécus et tes moments';

  @override
  String get contactsTitle => 'Contacts';

  @override
  String get contactsFilterAll => 'Tous';

  @override
  String get contactsEmptyTitle => 'Pas encore de contacts 👥';

  @override
  String get contactsEmptySubtitle => 'Touche + pour ajouter un contact';

  @override
  String get contactsEmptyFilteredTitle => 'Aucun contact trouvé 🔍';

  @override
  String get contactsEmptyFilteredSubtitle => 'Essaie un autre filtre';

  @override
  String get finderTitle => 'Repères';

  @override
  String get finderTabLocations => 'Lieux';

  @override
  String get finderTabItems => 'Objets';

  @override
  String get finderEmptyLocationsTitle => 'Pas encore de lieux';

  @override
  String get finderEmptyItemsTitle => 'Pas encore d’objets';

  @override
  String get finderEmptyLocationsSubtitle => 'Touche + pour ajouter un lieu';

  @override
  String get finderEmptyItemsSubtitle => 'Touche + pour ajouter un objet';

  @override
  String get emergencyTitle => 'Urgence';

  @override
  String get emergencyEmptyTitle => 'Pas encore de contacts d’urgence';

  @override
  String get emergencyEmptySubtitle =>
      'Ajoute des contacts avec la catégorie « Urgence » pour les voir ici.';

  @override
  String get emergencyEmptyDescription =>
      'Ces contacts peuvent être prévenus vite en cas d’urgence.';

  @override
  String get emergencyEmptyAddContact => 'Ajouter un contact d’urgence';

  @override
  String get emergencyEmptyOpenHelp => 'Aide et numéros d’urgence';

  @override
  String get emergencySendSmsAll => 'Envoyer un SMS d’URGENCE à tout le monde';

  @override
  String get emergencyShareAll => 'Envoyer à tout le monde via l’app';

  @override
  String get emergencySmsDialogTitle =>
      'Envoyer un SMS d’URGENCE à tout le monde ?';

  @override
  String emergencySmsDialogMessage(int count) {
    return 'Le message d’urgence sera envoyé à $count contacts.';
  }

  @override
  String get emergencySendNow => 'Envoyer maintenant';

  @override
  String get emergencyMessagePreparing => 'Préparation du message d’urgence...';

  @override
  String emergencyErrorSms(String error) {
    return 'Erreur à l’envoi du SMS : $error';
  }

  @override
  String emergencyErrorShare(String error) {
    return 'Erreur au partage : $error';
  }

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsSectionDebug => '🔧 Options de développement';

  @override
  String get settingsDebugInfo =>
      'Ces options ne sont visibles que pendant le développement';

  @override
  String get settingsDebugSkipCooldown => '⏩ Régler le minuteur sur 20 s';

  @override
  String settingsDebugSkipCooldownInfo(String name, String time) {
    return 'Profil : $name\nRestant : $time';
  }

  @override
  String get settingsDebugCooldownSet =>
      '⏩ Minuteur réglé sur 20 secondes !\nAprès 20 s, le mot de passe peut être activé.';

  @override
  String get settingsDebugCooldownError => '❌ Erreur au réglage du minuteur';

  @override
  String get settingsDeleteAllData => 'Supprimer toutes les données';

  @override
  String get settingsDeleteAllDataSubtitle =>
      'Supprime tous les profils, messages, événements et pièces jointes';

  @override
  String get settingsDeleteConfirmTitle => '⚠️ Attention';

  @override
  String get settingsDeleteConfirmMessage =>
      'Cette action supprimera TOUTES les données :\n\n• Tous les profils\n• Tous les messages du chat\n• Tous les événements du calendrier\n• Tous les médicaments et le journal des prises\n• Tous les contacts\n• Tous les objets des repères\n• Toutes les entrées du journal de crise\n• Toutes les données de navigation\n• Tous les réglages\n• Tous les dessins joints\n\nC’est IRRÉVERSIBLE !';

  @override
  String get settingsDeleteSuccess => '✅ Toutes les données ont été supprimées';

  @override
  String get settingsSectionManagement => 'Administration';

  @override
  String get settingsPermissions => 'Droits et permissions';

  @override
  String get settingsPermissionsSubtitle =>
      'Gérer les droits d’accès des profils';

  @override
  String get settingsSectionGlobal => 'Réglages globaux';

  @override
  String get settingsGlobalTrackingInfo =>
      'C’est quoi, le « suivi permanent » ?';

  @override
  String get settingsGlobalTrackingDescription =>
      'En tant qu’administratrice, tu peux piloter le GPS de TOUS les profils depuis un seul endroit. Quand c’est activé :';

  @override
  String get settingsGlobalTrackingBullet1 =>
      'La position est enregistrée en continu';

  @override
  String get settingsGlobalTrackingBullet2 => 'Ça fonctionne en arrière-plan';

  @override
  String get settingsGlobalTrackingBullet3 =>
      'Ça prime sur les réglages de chaque profil';

  @override
  String get settingsGlobalTrackingBullet4 =>
      'Tous les profils sont suivis automatiquement';

  @override
  String get settingsGlobalTrackingRequirement =>
      'Condition : l’autorisation Android « Toujours autoriser » doit être activée pour que le suivi fonctionne quand l’app est fermée.';

  @override
  String get settingsGpsPermissionTitle => 'Autorisation GPS';

  @override
  String get settingsGpsStatusDisabled => 'Service GPS désactivé';

  @override
  String get settingsGpsStatusDenied => 'Autorisation refusée';

  @override
  String get settingsGpsStatusDeniedForever => 'Refusée définitivement';

  @override
  String get settingsGpsStatusWhileInUse => 'Seulement pendant l’utilisation';

  @override
  String get settingsGpsStatusAlways => 'Toujours autorisée ✓';

  @override
  String get settingsGpsStatusUnknown => 'Inconnu';

  @override
  String get settingsGpsReady => 'Parfait ! Le suivi en arrière-plan est prêt.';

  @override
  String get settingsGpsInstructions =>
      'Comment activer « Toujours autoriser » :';

  @override
  String get settingsGpsStep1 => 'Touche « Ouvrir les réglages Android » ↓';

  @override
  String get settingsGpsStep2 => 'Choisis « Autorisations » → « Position »';

  @override
  String get settingsGpsStep3 => 'Choisis « Toujours autoriser »';

  @override
  String get settingsGpsOpenSettings => 'Ouvrir les réglages Android';

  @override
  String get settingsGpsOpenLocationSettings =>
      'Ouvrir les réglages de position';

  @override
  String get settingsGpsPrivacyNote =>
      'Ta position reste sur cet appareil. Les cartes la transmettent à OpenStreetMap, jamais à nous.';

  @override
  String get settingsTrackingPermanent => 'Suivi permanent';

  @override
  String get settingsTrackingPermanentOn =>
      'Le GPS tourne en permanence pour tous les profils';

  @override
  String get settingsTrackingPermanentOff =>
      'Le GPS seulement au besoin, profil par profil';

  @override
  String get settingsTrackingPermissionRequired =>
      'Autorisation de localisation nécessaire';

  @override
  String get settingsTrackingEnabled => '✅ Suivi permanent activé';

  @override
  String get settingsTrackingDisabled => '✅ Suivi permanent désactivé';

  @override
  String get settingsSectionLegal => 'Mentions légales';

  @override
  String get settingsImpressum => 'Mentions légales';

  @override
  String get settingsImpressumSubtitle => 'Informations légales';

  @override
  String get settingsPrivacy => 'Politique de confidentialité';

  @override
  String get settingsPrivacySubtitle => 'Comment nous protégeons tes données';

  @override
  String get settingsAppVersion => 'Version de l’app';

  @override
  String get settingsSectionDiagnostics => 'Diagnostic et assistance';

  @override
  String get settingsDebugLog => 'Générer un rapport de diagnostic';

  @override
  String get settingsDebugLogSubtitle =>
      'Crée des informations techniques à partager';

  @override
  String settingsDebugLogError(String error) {
    return '❌ Erreur à la génération du rapport : $error';
  }

  @override
  String get settingsSectionNotifications => 'Notifications';

  @override
  String get settingsNotificationsSubtitle =>
      'Rappels pour les médicaments et les rendez-vous';

  @override
  String get settingsNotificationsInfo =>
      'Comment fonctionnent les notifications ?';

  @override
  String get settingsNotificationsBullet1 =>
      'Médicaments quotidiens : -30 min, -10 min, 0 min puis rappels toutes les +10 min';

  @override
  String get settingsNotificationsBullet2 =>
      'Médicaments au besoin : rappels de disponibilité (-30 min, -10 min, -5 min, 0 min)';

  @override
  String get settingsNotificationsBullet3 =>
      'Rendez-vous : rappels réglables (de 15 min à 1 jour avant)';

  @override
  String get settingsNotificationsBullet4 =>
      'Ça fonctionne même quand l’app est fermée';

  @override
  String get settingsNotificationsTest => 'Envoyer une notification test';

  @override
  String get settingsNotificationsTestSubtitle =>
      'Vérifie que les notifications marchent';

  @override
  String get settingsNotificationsTestSent => '✅ Notification test envoyée';

  @override
  String get settingsNotificationsQueue => 'File d’attente';

  @override
  String get settingsNotificationsQueuePending => 'Notifications programmées :';

  @override
  String settingsNotificationsQueueNext(String time) {
    return 'Prochaine : $time';
  }

  @override
  String get settingsSectionMaps => 'Cartes et position';

  @override
  String get settingsMapsSubtitle =>
      'Les tuiles de carte se téléchargent et s’enregistrent automatiquement quand tu les regardes';

  @override
  String get settingsCacheStorage => 'Stockage du cache';

  @override
  String settingsCacheSize(int size, int limit, String count) {
    return '$size Mo / $limit Mo • $count tuiles';
  }

  @override
  String get settingsCacheLimit => 'Limite du cache';

  @override
  String settingsCacheLimitSubtitle(int limit) {
    return '$limit Mo de taille maximale';
  }

  @override
  String get settingsCacheLimitDialogTitle => 'Définir la limite du cache';

  @override
  String settingsCacheLimitDialogLabel(int size) {
    return 'Taille maximale du cache : $size Mo';
  }

  @override
  String get settingsCacheLimitDialogInfo =>
      'Quand le cache dépasse cette limite, les tuiles les plus anciennes sont supprimées automatiquement.';

  @override
  String settingsCacheLimitSet(int limit) {
    return '✅ Limite du cache fixée à $limit Mo';
  }

  @override
  String get settingsCachePreDownload => 'Télécharger les cartes à l’avance';

  @override
  String get settingsCachePreDownloadSubtitle =>
      'Télécharger les cartes dans un rayon donné';

  @override
  String get settingsCachePreDownloadPlaceholder =>
      '🚧 Le téléchargement à l’avance arrivera en phase 4';

  @override
  String get settingsCacheClear => 'Vider le cache';

  @override
  String get settingsCacheClearSubtitle =>
      'Supprimer toutes les tuiles de carte enregistrées';

  @override
  String get settingsCacheClearDialogTitle => 'Vider le cache des cartes';

  @override
  String get settingsCacheClearDialogMessage =>
      'Tu veux supprimer toutes les tuiles de carte enregistrées ?\n\nLes cartes se rechargeront la prochaine fois que tu les regarderas. Ça peut libérer de la place.';

  @override
  String get settingsCacheClearConfirm => 'Vider le cache';

  @override
  String get settingsCacheCleared => '✅ Cache des cartes vidé';

  @override
  String get settingsSectionApp => 'Réglages de l’app';

  @override
  String get settingsTimeFormat => 'Format de l’heure';

  @override
  String get settingsTimeFormatSystem => 'Celui du système';

  @override
  String get settingsTimeFormat12h => 'Format 12 heures';

  @override
  String get settingsTimeFormat24h => 'Format 24 heures';

  @override
  String get settingsTimeFormatSystemSubtitle =>
      'Suit les réglages du système Android';

  @override
  String get settingsTimeFormat12hExample => 'p. ex. 2:30 PM';

  @override
  String get settingsTimeFormat24hExample => 'p. ex. 14:30';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageChanged => 'Langue modifiée';

  @override
  String get onboardingSelectLanguage => 'Choisissez votre langue';

  @override
  String get onboardingWelcomeTitle => 'Bienvenue sur';

  @override
  String get onboardingWelcomeSubtitle =>
      'Ta compagne sûre au quotidien avec le TDI';

  @override
  String get onboardingWelcomeDescription =>
      'Aurora t’accompagne pour organiser ton quotidien et la communication au sein de ton système.';

  @override
  String get onboardingPrivacyTitle => 'Tes données t’appartiennent';

  @override
  String get onboardingPrivacyBullet1 =>
      'Toutes les données restent sur ton appareil';

  @override
  String get onboardingPrivacyBullet2 =>
      'Pas de sauvegarde dans le cloud, pas de pistage, pas de pub';

  @override
  String get onboardingPrivacyBullet3 => 'C’est toi qui décides';

  @override
  String get onboardingPrivacyBullet4 => 'Transparent et sûr';

  @override
  String get onboardingMultiProfileTitle => 'Plusieurs voix, une seule app';

  @override
  String get onboardingMultiProfileDescription =>
      'Chaque alter peut avoir son propre profil, avec ses couleurs, ses réglages et ses droits.';

  @override
  String get onboardingLetsGoTitle => 'Prêt·e à commencer ?';

  @override
  String get onboardingLetsGoDescription =>
      'Crée ton premier profil maintenant. Le premier devient automatiquement le profil d’administration, avec tous les droits.';

  @override
  String get onboardingButtonNext => 'Suivant →';

  @override
  String get onboardingButtonCreateProfile => 'Créer le profil →';

  @override
  String get splashLoading => 'Aurora se charge';

  @override
  String get splashDidYouKnow => 'Le savais-tu ?';

  @override
  String get splashEmergencyWipeTitle => 'Effacement d’urgence';

  @override
  String get splashEmergencyWipeMessage =>
      'ATTENTION : toutes les données seront supprimées définitivement !\n\n• Tous les profils\n• Tous les messages\n• Toutes les entrées du journal\n• Tous les contacts\n• Tous les médicaments\n\nContinuer ?';

  @override
  String get splashEmergencyWipeConfirm => 'TOUT SUPPRIMER';

  @override
  String get passwordResetBannerReady =>
      'Le mot de passe est prêt à être activé';

  @override
  String get passwordResetBannerRunning =>
      'Réinitialisation du mot de passe en cours';

  @override
  String passwordResetBannerProfile(String name) {
    return 'Profil : $name';
  }

  @override
  String passwordResetBannerRemaining(String name, String time) {
    return 'Profil : $name • Restant : $time';
  }

  @override
  String get dialogWarning => 'Attention';

  @override
  String get dialogConfirm => 'Confirmer';

  @override
  String get dialogUnderstood => 'Compris';

  @override
  String get dialogYes => 'Oui';

  @override
  String get dialogNo => 'Non';

  @override
  String get permissionGpsRequired =>
      '⚠️ L’autorisation GPS « Toujours autoriser » est nécessaire';

  @override
  String get permissionTrackingDialogTitle => 'Activer le suivi permanent ?';

  @override
  String get permissionTrackingDialogHeading => 'Ce que fait ce mode :';

  @override
  String get permissionTrackingBullet1 =>
      'Le GPS tourne en permanence en arrière-plan';

  @override
  String get permissionTrackingBullet2 =>
      'Ça prime sur les réglages de suivi de TOUS les profils';

  @override
  String get permissionTrackingBullet3 =>
      'La chronologie enregistre tous les déplacements automatiquement';

  @override
  String get permissionTrackingPrivacyTitle =>
      'Tes données restent sur cet appareil';

  @override
  String get permissionTrackingPrivacyMessage =>
      'Aurora enregistre toutes les données uniquement sur cet appareil. Pas de pistage, pas de pub, rien de partagé.';

  @override
  String get permissionTrackingBatteryWarning =>
      'Le GPS en arrière-plan peut user la batterie plus vite.';

  @override
  String get permissionTrackingAndroidStatus => 'État côté Android :';

  @override
  String get permissionTrackingActivate => 'Activer';

  @override
  String get permissionTrackingDeactivate => 'Désactiver';

  @override
  String get permissionTrackingDeactivateTitle =>
      'Désactiver le suivi permanent ?';

  @override
  String get permissionTrackingDeactivateMessage =>
      'Le suivi GPS sera de nouveau piloté profil par profil.\n\nChaque profil pourra alors l’activer ou le désactiver de son côté.';

  @override
  String get permissionGuidanceTitle => 'Un réglage Android est nécessaire';

  @override
  String get permissionGuidanceMessage =>
      'Pour utiliser le suivi permanent, il te faut l’autorisation « Toujours autoriser ».';

  @override
  String get permissionGuidanceStepsTitle => 'Je te guide pas à pas :';

  @override
  String get permissionGuidanceStep1Title => 'Ouvrir les réglages Android';

  @override
  String get permissionGuidanceStep1Button => 'Ouvrir maintenant';

  @override
  String get permissionGuidanceStep2Title => 'Dans les réglages';

  @override
  String get permissionGuidanceStep2Bullet1 => 'Touche « Autorisations »';

  @override
  String get permissionGuidanceStep2Bullet2 => 'Touche « Position »';

  @override
  String get permissionGuidanceStep2Bullet3 => 'Choisis « Toujours autoriser »';

  @override
  String get permissionGuidanceStep3Message =>
      'Reviens dans Aurora\nL’app détectera le changement toute seule.';

  @override
  String get messageError => 'Erreur';

  @override
  String get messageSuccess => 'C’est fait';

  @override
  String get messageWarning => 'Attention';

  @override
  String get messageInfo => 'Information';

  @override
  String get messageLoading => 'Chargement...';

  @override
  String get misc24HourFormat => 'Format 24 heures';

  @override
  String get misc12HourFormat => 'Format 12 heures';

  @override
  String get miscSystemDefault => 'Celui du système';

  @override
  String get miscUnknown => 'Inconnu';

  @override
  String get chatDayYesterday => 'Hier';

  @override
  String get miscToday => 'Aujourd’hui';

  @override
  String get miscAll => 'Tous';

  @override
  String get notificationChannelName => 'Notifications Aurora';

  @override
  String get notificationChannelDescription =>
      'Rappels pour médicaments et rendez-vous';

  @override
  String get notificationMedicationReminder => 'Rappel de médicament';

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
    return '$name - $dosage prendre maintenant';
  }

  @override
  String get notificationMedicationAvailableSoon =>
      'Médicament au besoin bientôt disponible';

  @override
  String get notificationMedicationAvailableNow =>
      'Médicament au besoin maintenant disponible';

  @override
  String notificationMedicationAvailableBody(String name) {
    return '$name peut être pris';
  }

  @override
  String get notificationEventReminder => 'Rappel de rendez-vous';

  @override
  String notificationEventBody(String title, String time) {
    return '$title $time';
  }

  @override
  String get notificationTestTitle => 'Notification de test';

  @override
  String get notificationTestBody => 'Les notifications fonctionnent !';

  @override
  String notificationTimeInMinutes(int minutes) {
    return 'dans $minutes minutes';
  }

  @override
  String get notificationTimeIn1Hour => 'dans 1 heure';

  @override
  String notificationTimeInHours(int hours) {
    return 'dans $hours heures';
  }

  @override
  String get notificationTimeNow => 'maintenant';

  @override
  String get notificationMedicationTakeNowTitle =>
      'Prendre le médicament maintenant !';

  @override
  String get notificationMedicationNotTakenYet => 'Pas encore pris !';

  @override
  String get actionCreate => 'Créer';

  @override
  String get commonDescription => 'Description';

  @override
  String get commonNotes => 'Notes';

  @override
  String get commonOptional => 'Facultatif';

  @override
  String get commonCategory => 'Catégorie';

  @override
  String get commonStartTime => 'Heure de début';

  @override
  String get commonEndTime => 'Heure de fin';

  @override
  String get commonVisibleFor => 'Visible pour';

  @override
  String get commonUnnamed => 'Sans nom';

  @override
  String get commentsTitle => 'Commentaires';

  @override
  String get eventCreate => 'Créer un rendez-vous';

  @override
  String get eventNewTitle => 'Nouveau rendez-vous';

  @override
  String get eventEditTitle => 'Modifier le rendez-vous';

  @override
  String get eventDetailTitle => 'Rendez-vous';

  @override
  String get eventNotFound => 'Rendez-vous introuvable';

  @override
  String get eventNotFoundMessage => 'Ce rendez-vous n\'existe plus';

  @override
  String get eventDeleteTitle => 'Supprimer le rendez-vous ?';

  @override
  String get eventDeleteMessage =>
      'Veux-tu vraiment supprimer ce rendez-vous ?';

  @override
  String get eventDeleteConfirmMessage =>
      'Ce rendez-vous sera supprimé définitivement.';

  @override
  String get eventDeleted => 'Rendez-vous supprimé';

  @override
  String get eventUpdated => 'Rendez-vous enregistré';

  @override
  String get eventCreated => 'Rendez-vous créé';

  @override
  String get eventSelectProfileRequired => 'Choisis au moins un profil';

  @override
  String get eventEndTimeError =>
      'L\'heure de fin doit être après l\'heure de début';

  @override
  String get eventTitleLabel => 'Titre';

  @override
  String get eventTitleLabelRequired => 'Titre *';

  @override
  String get eventTitleRequired => 'Saisis un titre';

  @override
  String get eventTitleHint => 'p. ex. rendez-vous médical';

  @override
  String get eventCategoryLabel => 'Catégorie (facultatif)';

  @override
  String get eventCategoryHint => 'p. ex. rendez-vous médical, privé, etc.';

  @override
  String get eventDescriptionLabel => 'Description (facultatif)';

  @override
  String contactDistanceAway(String distance) {
    return 'à $distance';
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
      other: '$hours heures',
      one: '1 heure',
    );
    return '$_temp0';
  }

  @override
  String get eventReminderDay => '1 jour';

  @override
  String eventReminderNotice(String when) {
    return 'Aurora te prévient $when avant le rendez-vous.';
  }

  @override
  String eventReminderBefore(int minutes) {
    return 'Rappel $minutes min avant';
  }

  @override
  String eventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rendez-vous',
      one: '1 rendez-vous',
      zero: 'Aucun rendez-vous',
    );
    return '$_temp0';
  }

  @override
  String get noEventsToday => 'Aucun rendez-vous ce jour-là';

  @override
  String get calendarNothingPlannedToday => 'Rien n’est prévu aujourd’hui.';

  @override
  String get calendarNothingPlannedOnDay => 'Rien n’est prévu ce jour-là.';

  @override
  String get calendarUpcomingTitle => 'À venir';

  @override
  String get calendarChooseDay => 'Voir un autre jour';

  @override
  String get eventForWhom => 'Pour qui est ce rendez-vous ?';

  @override
  String get eventMoreDetails => 'Informations supplémentaires';

  @override
  String get contactTitle => 'Contact';

  @override
  String get contactNewTitle => 'Nouveau contact';

  @override
  String get contactEditTitle => 'Modifier le contact';

  @override
  String get contactNotFound => 'Contact introuvable';

  @override
  String get contactDeleteTitle => 'Supprimer le contact ?';

  @override
  String get contactDeleteMessage =>
      'Ce contact sera supprimé définitivement. Cette action est irréversible.';

  @override
  String get contactImagePickerTitle => 'Choisir une image de contact';

  @override
  String get contactNameLabel => 'Nom *';

  @override
  String get contactNameRequired => 'Saisis un nom';

  @override
  String get contactRelationLabel => 'Relation';

  @override
  String get contactRelationHint => 'p. ex. mère, thérapeute, ami...';

  @override
  String get contactMarkAsEmergency => 'Marquer comme contact d\'urgence';

  @override
  String get contactEmergencyDescription =>
      'Ce contact apparaît dans la vue d\'urgence et peut être prévenu rapidement';

  @override
  String get contactPhoneLabel => 'Téléphone';

  @override
  String get contactEmailLabel => 'E-mail';

  @override
  String get contactDefaultRating => 'Évaluation par défaut';

  @override
  String get contactDefaultRatingDescription =>
      'Tous les profils voient cette évaluation par défaut. Chaque profil peut donner la sienne plus tard.';

  @override
  String get contactPersonalRating => 'Évaluation personnelle';

  @override
  String get contactLocationSection => '📍 Lieu (facultatif)';

  @override
  String get contactLocationTitle => '📍 Lieu';

  @override
  String get contactLocationDescription =>
      'Ajoute un lieu (par exemple domicile ou adresse du cabinet)';

  @override
  String get contactLocationSet => 'Définir la position';

  @override
  String get contactLocationChange => 'Modifier la position';

  @override
  String get contactAddressLabel => 'Adresse';

  @override
  String get contactAddressHint =>
      'Détectée automatiquement une fois la position définie';

  @override
  String get contactVisibleToAll => 'Tous les profils peuvent voir ce contact';

  @override
  String get contactInfoSection => 'Informations';

  @override
  String get gpsPermissionRequired => 'Autorisation GPS requise';

  @override
  String get gpsTrackingDisabled => 'Suivi GPS désactivé';

  @override
  String get emergencyContactLabel => 'Contact d\'urgence';

  @override
  String get diaryEntryNewTitle => 'Nouvelle entrée';

  @override
  String get diaryEntryEditTitle => 'Modifier l\'entrée';

  @override
  String get diaryEntryDetailTitle => 'Détails de l\'entrée';

  @override
  String get diaryEntryNotFound => 'Entrée introuvable';

  @override
  String get diaryEntryNotFoundMessage => 'Cette entrée n\'existe plus';

  @override
  String get diaryEntryDeleteTitle => 'Supprimer l\'entrée';

  @override
  String get diaryEntryDeleteMessage =>
      'Veux-tu vraiment supprimer cette entrée ? Tous les commentaires seront également supprimés.';

  @override
  String get diaryEntryDeleted => 'Entrée supprimée';

  @override
  String get diaryEntryUpdated => 'Entrée mise à jour';

  @override
  String get diaryEntryCreated => 'Entrée créée';

  @override
  String get diaryTitleHint => 'Que s\'est-il passé ?';

  @override
  String get diaryTitleRequired => 'Saisis un titre';

  @override
  String get diaryDescriptionHint => 'Décris ce qui s\'est passé...';

  @override
  String get diaryDescriptionRequired => 'Saisis une description';

  @override
  String get diaryPriorityLabel => 'Priorité';

  @override
  String get diaryImagesLabel => 'Images';

  @override
  String get diaryNoImagesYet => 'Aucune image pour l\'instant';

  @override
  String get diaryImagePickerComingSoon => 'Le choix d\'images arrive bientôt';

  @override
  String get diaryCannotEditEntry => 'Tu ne peux pas modifier cette entrée';

  @override
  String get diaryCannotCreateEntry => 'Tu ne peux pas créer d\'entrées';

  @override
  String get commonError => 'Erreur';

  @override
  String get commonNoPermission => 'Pas d\'autorisation';

  @override
  String get commonEdited => 'Modifié';

  @override
  String get commonTitle => 'Titre';

  @override
  String get profileNotSelected => 'Aucun profil sélectionné';

  @override
  String get actionAdd => 'Ajouter';

  @override
  String commonSaveError(String error) {
    return 'Erreur lors de l\'enregistrement : $error';
  }

  @override
  String get timeJustNow => 'à l’instant';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count minutes',
      one: 'il y a une minute',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count heures',
      one: 'il y a une heure',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count jours',
      one: 'il y a un jour',
    );
    return '$_temp0';
  }

  @override
  String get emergencyCall => 'Appeler';

  @override
  String get emergencyCallTooltip => 'Appeler le contact';

  @override
  String get emergencyNoPhone => 'Aucun numéro de téléphone';

  @override
  String get emergencySms => 'SMS';

  @override
  String get emergencySmsTooltip => 'Envoyer un SMS d\'urgence';

  @override
  String get emergencyApp => 'Application';

  @override
  String get emergencyShareTooltip => 'Partager via une application';

  @override
  String emergencyErrorCall(String error) {
    return 'Erreur lors de l\'appel : $error';
  }

  @override
  String emergencyErrorOpen(String error) {
    return 'Erreur lors de l\'ouverture : $error';
  }

  @override
  String get actionOpen => 'Ouvrir';

  @override
  String get finderLocationEditTitle => 'Modifier le lieu';

  @override
  String get finderItemEditTitle => 'Modifier l\'objet';

  @override
  String get finderLocationNewTitle => 'Nouveau lieu';

  @override
  String get finderItemNewTitle => 'Nouvel objet';

  @override
  String get finderSetPosition => 'Définir la position';

  @override
  String get finderChangePosition => 'Modifier la position';

  @override
  String get finderAddressLabel => 'Adresse';

  @override
  String get finderStorageLocationLabel => 'Lieu de rangement';

  @override
  String get finderStorageLocationHint => 'p. ex. cuisine, deuxième tiroir';

  @override
  String get finderChoosePhoto => 'Choisir une photo';

  @override
  String get finderAddPhoto => 'Ajouter une photo';

  @override
  String get finderAddTag => 'Ajouter une étiquette';

  @override
  String get finderNotFound => 'Introuvable';

  @override
  String get finderNotFoundMessage => 'Élément introuvable';

  @override
  String get finderDeleteTitle => 'Supprimer ?';

  @override
  String finderDeleteMessage(String title) {
    return 'Veux-tu vraiment supprimer $title ?';
  }

  @override
  String get commonRequired => 'Champ obligatoire';

  @override
  String get feedbackTitle => 'Envoyer un commentaire';

  @override
  String get feedbackPrivacyInfo =>
      'Ton commentaire est traité de façon confidentielle et uniquement en interne. Tes retours nous aident à améliorer Aurora !';

  @override
  String get feedbackSelectCategory => 'Choisis une catégorie :';

  @override
  String get fieldPasswordShow => 'Afficher le mot de passe';

  @override
  String get fieldPasswordHide => 'Masquer le mot de passe';

  @override
  String get feedbackCategoryBug => 'Signaler un problème';

  @override
  String get feedbackCategoryWish => 'Proposer une idée';

  @override
  String get feedbackCategoryGeneral => 'Retour général';

  @override
  String get feedbackCategoryLabel => 'Catégorie';

  @override
  String get feedbackTitleLabel => 'Titre :';

  @override
  String get feedbackTitleHint => 'Un bref résumé de ton commentaire';

  @override
  String get feedbackTitleRequired => 'Saisis un titre';

  @override
  String get feedbackTitleTooShort =>
      'Titre trop court (au moins 5 caractères)';

  @override
  String get feedbackMessageLabel => 'Ton message :';

  @override
  String get feedbackMessageHint => 'Décris ton commentaire en détail...';

  @override
  String get feedbackMessageRequired => 'Saisis un message';

  @override
  String get feedbackMessageTooShort =>
      'Message trop court (au moins 20 caractères)';

  @override
  String get feedbackEmailLabel => 'Ton e-mail (facultatif) :';

  @override
  String get feedbackEmailHint =>
      'Seulement si tu veux qu\'on te recontacte en cas de questions';

  @override
  String get feedbackEmailPlaceholder => 'toi@exemple.fr';

  @override
  String get feedbackEmailInvalid => 'Saisis une adresse e-mail valide';

  @override
  String get feedbackAttachImageLabel => 'Joindre une image (facultatif) :';

  @override
  String get feedbackAttachImage => 'Joindre une image';

  @override
  String get feedbackSelectImage => 'Choisir une image';

  @override
  String get feedbackSend => 'Envoyer le commentaire';

  @override
  String get feedbackCopyToClipboard => 'Copier dans le presse-papiers';

  @override
  String get feedbackCopiedToClipboard =>
      'Commentaire copié dans le presse-papiers !';

  @override
  String get feedbackContactLabel => 'Contact';

  @override
  String get feedbackErrorOccurred =>
      'Une erreur est survenue. Le rapport a été copié dans le presse-papiers.';

  @override
  String get feedbackCouldNotSend => 'Le commentaire n\'a pas pu être envoyé';

  @override
  String feedbackErrorClipboardHint(String email) {
    return 'Ton commentaire a été copié dans le presse-papiers. Tu peux aussi nous l\'envoyer par e-mail à $email.';
  }

  @override
  String get feedbackTechnicalDetails => 'Détails techniques';

  @override
  String get actionChange => 'Modifier';

  @override
  String get actionRemove => 'Retirer';

  @override
  String get onboardingNext => 'Suivant →';

  @override
  String get onboardingCreateProfile => 'Créer un profil →';

  @override
  String get onboardingLetsGo => 'C\'est parti ! →';

  @override
  String get onboardingWelcomeTo => 'Bienvenue dans';

  @override
  String get onboardingSubline => 'Ta compagne sûre au quotidien avec le TDI';

  @override
  String get onboardingDescription =>
      'Aurora t\'accompagne pour organiser ton quotidien et la communication au sein de ton système.';

  @override
  String get onboardingPrivacyHeadline => 'Tes données t\'appartiennent';

  @override
  String get onboardingPrivacyPoint1 =>
      'Toutes les données restent sur ton appareil';

  @override
  String get onboardingPrivacyPoint2 =>
      'Pas de sauvegarde dans le cloud, pas de pistage, pas de publicité';

  @override
  String get onboardingPrivacyPoint3 => 'Tu gardes le contrôle';

  @override
  String get onboardingPrivacyPoint4 => 'Transparent et sûr';

  @override
  String get onboardingMultiProfileHeadline => 'Plusieurs voix, une seule app';

  @override
  String get onboardingLetsGoHeadline => 'Prêt à commencer ?';

  @override
  String onboardingHelloName(String name) {
    return 'Bonjour $name !';
  }

  @override
  String get onboardingGladYoureHere => 'Content que tu sois là.';

  @override
  String get onboardingNotAlone => 'Tu n\'es pas seul';

  @override
  String get onboardingNotAloneDescription =>
      'Vous pouvez discuter, partager des rendez-vous et vous soutenir mutuellement.';

  @override
  String get onboardingWhatYouCanDo => 'Ce que tu peux faire';

  @override
  String get onboardingChildAccessDescription =>
      'Avec un profil enfant, tu as accès à :';

  @override
  String get onboardingAdultAccessDescription =>
      'Ces fonctions te sont accessibles :';

  @override
  String get onboardingSafeSpace => 'Ton espace sûr';

  @override
  String get onboardingSafeSpaceDescription =>
      'Tout ce que tu écris reste sur cet appareil. Seul ce que tu envoies toi-même part, et tu peux toujours le relire.';

  @override
  String get onboardingHaveFun => 'Bonne route avec Aurora !';

  @override
  String get onboardingFeatureChatChild =>
      'Chat : gribouiller et parler avec les autres';

  @override
  String get onboardingFeatureDiaryChild => 'Journal : écrire tes pensées';

  @override
  String get onboardingFeatureGamesChild => 'Jeux : s\'amuser et se détendre';

  @override
  String get onboardingFeatureTimelineChild =>
      'Frise : garder les moments importants';

  @override
  String get onboardingFeatureChat =>
      'Chat : messages, gribouillages, messages vocaux';

  @override
  String get onboardingFeatureCalendar =>
      'Calendrier : planifier et gérer les rendez-vous';

  @override
  String get onboardingFeatureContacts =>
      'Contacts : enregistrer les personnes importantes';

  @override
  String get onboardingFeatureMedication =>
      'Médication : suivre médicaments et prises';

  @override
  String get onboardingFeatureDiary => 'Journal : noter pensées et expériences';

  @override
  String get onboardingFeatureFinder => 'Repères : retrouver lieux et objets';

  @override
  String get onboardingFeatureEmergency =>
      'Urgence : aide rapide en cas de crise';

  @override
  String get onboardingFeatureMantras =>
      'Mantras : phrases apaisantes et affirmations';

  @override
  String get onboardingFeatureChatBasic =>
      'Chat : fonctions de base disponibles';

  @override
  String get featureCarouselHeadline => 'Tout ce qu\'Aurora sait faire';

  @override
  String get featureCarouselSwipeHint => 'Fais défiler les fonctions →';

  @override
  String get featureCarouselChatTitle => 'Chat';

  @override
  String get featureCarouselChatSubtitle => 'Communication interne';

  @override
  String get featureCarouselChatDescription =>
      'Messages, gribouillages et messages vocaux.\nPartagez des pensées, dessinez ensemble ou parlez-vous.';

  @override
  String get featureCarouselCalendarTitle => 'Calendrier';

  @override
  String get featureCarouselCalendarSubtitle => 'Rendez-vous';

  @override
  String get featureCarouselCalendarDescription =>
      'Des rendez-vous avec images et lieux.\nGardez les rendez-vous importants en vue, avec images et positions GPS.';

  @override
  String get featureCarouselDiaryTitle => 'Journal';

  @override
  String get featureCarouselDiarySubtitle => 'Pensées privées';

  @override
  String get featureCarouselDiaryDescription =>
      'Visible pour tous ou seulement pour toi.\nGardez vos pensées : en commun pour tous les profils ou en privé.';

  @override
  String get featureCarouselFinderTitle => 'Repères';

  @override
  String get featureCarouselFinderSubtitle => 'Lieux et objets';

  @override
  String get featureCarouselFinderDescription =>
      'Retrouvez lieux et objets.\nEnregistrez les lieux importants (avec carte) et les objets pour les retrouver.';

  @override
  String get featureCarouselMedicationTitle => 'Médication';

  @override
  String get featureCarouselMedicationSubtitle => 'Suivi des médicaments';

  @override
  String get featureCarouselMedicationDescription =>
      'Médicaments et heures de prise.\nSuivez les médicaments, les heures de prise et les médicaments au besoin.';

  @override
  String get featureCarouselGamesTitle => 'Jeux et ancrage';

  @override
  String get featureCarouselGamesSubtitle => 'Détente';

  @override
  String get featureCarouselGamesDescription =>
      'Jeux, respiration et ancrage.\nApaisez-vous avec des casse-tête, des exercices de respiration et des techniques d\'ancrage.';

  @override
  String get featureCarouselEmergencyTitle => 'Aide';

  @override
  String get featureCarouselEmergencySubtitle => 'Contacts d\'urgence';

  @override
  String get featureCarouselEmergencyDescription =>
      'Contacts d\'urgence et aide rapide.\nEnregistrez les contacts importants pour les moments de crise.';

  @override
  String get featureCarouselInfoTitle => 'Informations sur le TDI';

  @override
  String get featureCarouselInfoSubtitle => 'Savoir et ressources';

  @override
  String get featureCarouselInfoDescription =>
      'Expliqué : qu\'est-ce que le TDI ?\nDes informations sur le trouble dissociatif de l\'identité et des ressources.';

  @override
  String get commonUnknown => 'Inconnu';

  @override
  String get timelineTitle => 'Frise chronologique';

  @override
  String get timelineHistory => 'Historique';

  @override
  String timelineEntries(int count) {
    return '$count entrées';
  }

  @override
  String get timelinePositionUpdated => 'Position mise à jour';

  @override
  String timelineProfileActive(String name) {
    return '$name actif';
  }

  @override
  String get timelineAppStarted => 'Application démarrée';

  @override
  String get timelineProfileSwitched => 'Profil changé';

  @override
  String timelineToday(String time) {
    return 'Aujourd\'hui, $time';
  }

  @override
  String timelineYesterday(String time) {
    return 'Hier, $time';
  }

  @override
  String get timelineTrackingDisabledTitle => 'Suivi GPS désactivé';

  @override
  String get timelineTrackingDisabledSubtitle =>
      'La frise montre tes changements de profil et tes positions GPS au fil du temps.\n\nActive le suivi GPS avec le symbole satellite en haut à droite pour collecter des données.';

  @override
  String get timelineEmptyTitle => 'Pas encore de données';

  @override
  String get timelineEmptySubtitle =>
      'Le suivi GPS est actif. Ta position est enregistrée toutes les 2 à 3 minutes.\n\nLes changements de profil et les positions GPS apparaissent ici automatiquement.';

  @override
  String get gamesTitle => 'Jeux et détente';

  @override
  String get gamesSubtitle =>
      'Des jeux simples pour se changer les idées et se détendre.\nPas de chrono, pas de points : juste du calme.';

  @override
  String get gamesComingSoon => 'Bientôt';

  @override
  String get gamesPuzzleTitle => 'Puzzle';

  @override
  String get gamesPuzzleSubtitle => 'Puzzle ou taquin';

  @override
  String get gamesPuzzleDescription => 'Détends-toi avec des images apaisantes';

  @override
  String get gamesBreathingTitle => 'Exercices de respiration';

  @override
  String get gamesBreathingSubtitle => 'Techniques de respiration guidées';

  @override
  String get gamesBreathingDescription =>
      'Apaise-toi avec des exercices de respiration simples';

  @override
  String get memoryCardHidden => 'Face cachée';

  @override
  String get memoryCardOpen => 'Face visible';

  @override
  String get memoryCardFound => 'Paire trouvée';

  @override
  String get memoryAllFound => 'Toutes les paires sont trouvées.';

  @override
  String get memoryNewGame => 'Nouvelle partie';

  @override
  String get gamesDrawingSend => 'Envoyer dans le chat';

  @override
  String get gamesDrawingEmpty =>
      'Dessine quelque chose, puis tu pourras l’envoyer';

  @override
  String get gamesDrawingSent => 'Ton dessin est maintenant dans le chat.';

  @override
  String memoryCardPosition(int position, int total) {
    return 'Carte $position sur $total';
  }

  @override
  String get gamesMemoryTitle => 'Memory';

  @override
  String get gamesMemorySubtitle => 'Trouve les paires';

  @override
  String get gamesMemoryDescription =>
      'Un jeu de memory tranquille, sans chrono';

  @override
  String get gamesDrawingTitle => 'Dessiner';

  @override
  String get gamesDrawingSubtitle => 'Dessin libre et gribouillages';

  @override
  String get gamesDrawingDescription => 'Exprime-toi de façon créative';

  @override
  String get puzzleCreateTitle => 'Créer un puzzle';

  @override
  String get puzzleRelaxationTitle => 'Puzzle pour se détendre';

  @override
  String get puzzleRelaxationSubtitle =>
      'Choisis le type de puzzle et la difficulté. Prends ton temps : rien n\'est noté.';

  @override
  String get puzzleTypeLabel => 'Type de puzzle';

  @override
  String get puzzleTypeJigsaw => 'Classique';

  @override
  String get puzzleTypeJigsawDescription =>
      'Fais glisser les pièces au bon endroit';

  @override
  String get puzzleTypeSliding => 'Taquin';

  @override
  String get puzzleTypeSlidingDescription =>
      'Déplace les pièces en appuyant dessus';

  @override
  String get puzzleDifficultyLabel => 'Difficulté';

  @override
  String get puzzleDifficultyEasy => 'Facile';

  @override
  String get puzzleDifficultyEasyDescription =>
      'Grille 3×3, parfait pour se détendre';

  @override
  String get puzzleDifficultyMedium => 'Moyenne';

  @override
  String get puzzleDifficultyMediumDescription => 'Grille 4×4, un petit défi';

  @override
  String get puzzleDifficultyHard => 'Difficile';

  @override
  String get puzzleDifficultyHardDescription => 'Grille 5×5, pour les habitués';

  @override
  String get puzzleSelectImageAndStart => 'Choisir une image et commencer';

  @override
  String get puzzleJigsawTitle => 'Puzzle classique';

  @override
  String get puzzleSlidingTitle => 'Taquin';

  @override
  String puzzleMoves(int count) {
    return 'Coups : $count';
  }

  @override
  String get puzzlePreparing => 'Préparation du puzzle...';

  @override
  String get puzzleAvailablePieces => 'Pièces disponibles';

  @override
  String get puzzleTapToMove => 'Appuie sur une pièce pour la déplacer';

  @override
  String get puzzleShowHint => 'Afficher l\'aide';

  @override
  String puzzleHintMovablePieces(int count) {
    return 'Astuce : tu peux déplacer $count pièces';
  }

  @override
  String get puzzleSolved => 'Puzzle résolu !';

  @override
  String puzzleSolvedInMoves(int count) {
    return 'Tu as résolu le puzzle en $count coups.';
  }

  @override
  String puzzleErrorLoadingImage(String error) {
    return 'Erreur lors du chargement de l\'image : $error';
  }

  @override
  String puzzleErrorSharing(String error) {
    return 'Erreur lors du partage : $error';
  }

  @override
  String get puzzleImagePickerTitle => 'Choisir une image';

  @override
  String get puzzleImagePickerSubtitle =>
      'Choisis une image apaisante pour ton puzzle';

  @override
  String get puzzleImageLoading => 'Chargement de l\'image...';

  @override
  String get puzzleImageLoadFailed => 'L\'image n\'a pas pu être chargée';

  @override
  String get puzzleImageSourceGallery => 'Galerie';

  @override
  String get puzzleImageSourceGallerySubtitle =>
      'Choisir une image dans ta galerie';

  @override
  String get puzzleImageSourceCamera => 'Appareil photo';

  @override
  String get puzzleImageSourceCameraSubtitle => 'Prendre une nouvelle photo';

  @override
  String get puzzleImageSourceOnline => 'En ligne';

  @override
  String get puzzleImageSourceOnlineSubtitle =>
      'Une image apaisante depuis internet';

  @override
  String get puzzleSelectCategory => 'Choisir une catégorie';

  @override
  String get errorNoProfileSelected => 'Aucun profil sélectionné';

  @override
  String get mantrasTitle => 'Mantras';

  @override
  String get mantrasComingSoonTitle => 'Mantras : bientôt ✨';

  @override
  String get mantrasComingSoonSubtitle =>
      'Des affirmations apaisantes et des mantras pour les moments difficiles';

  @override
  String get helpResourcesTitle => 'Aide';

  @override
  String get helpHotlinesTitle => 'Lignes d\'urgence 24h/24';

  @override
  String get helpHotlinesSubtitle => 'Un soutien professionnel, à toute heure';

  @override
  String get helpMoreResourcesTitle => 'D\'autres ressources à venir';

  @override
  String get helpMoreResourcesDescription =>
      'Dans les prochaines versions :\n• Ressources thérapeutiques\n• Groupes d\'entraide\n• Documentation sur le TDI\n• Plans de crise et stratégies';

  @override
  String get moreTitle => 'Autres fonctions';

  @override
  String get moreHelpResources => 'Aide';

  @override
  String get moreHelpResourcesDescription =>
      'Informations et liens vers un soutien professionnel';

  @override
  String get moreGames => 'Jeux et détente';

  @override
  String get moreGamesDescription =>
      'Respiration, memory et plus pour se changer les idées';

  @override
  String get moreSettings => 'Réglages';

  @override
  String get moreSettingsDescription =>
      'Configuration de l\'application et confidentialité';

  @override
  String get permissionsTitle => 'Droits et autorisations';

  @override
  String get permissionsNoProfiles => 'Aucun profil';

  @override
  String get permissionsInfoText =>
      'Ici, tu peux gérer les autorisations de chaque profil. Appuie sur un profil pour voir le détail.';

  @override
  String get permissionsAllRightsAdmin => 'Tous les droits (administrateur)';

  @override
  String permissionsCount(int count) {
    return '$count autorisations';
  }

  @override
  String get permissionsAdminBadge => 'Admin';

  @override
  String get permissionsAdministrator => 'Administrateur';

  @override
  String permissionsDetailTitle(String name) {
    return 'Autorisations : $name';
  }

  @override
  String get permissionsChangeError =>
      'L\'autorisation n\'a pas pu être modifiée';

  @override
  String get permissionsMakeAdminTitle => 'Nommer un administrateur';

  @override
  String permissionsMakeAdminMessage(String name) {
    return '$name deviendra administrateur avec tous les droits. Continuer ?';
  }

  @override
  String get permissionsMakeAdminButton => 'Nommer administrateur';

  @override
  String get permissionsMakeAdminSubtitle => 'Donne tous les droits';

  @override
  String get permissionsRevokeAdminTitle =>
      'Retirer le statut d\'administrateur';

  @override
  String permissionsRevokeAdminMessage(String name) {
    return '$name perdra tous les droits d\'administrateur et recevra les autorisations standard. Continuer ?';
  }

  @override
  String get permissionsRevokeAdminSubtitle => 'Rétablit les droits standard';

  @override
  String get permissionsRevokeAdminError =>
      'Le statut d\'administrateur n\'a pas pu être retiré. Le premier profil doit rester administrateur.';

  @override
  String permissionsActiveCount(int active, int total) {
    return '$active / $total actifs';
  }

  @override
  String get permissionsCategorySystem => 'Autorisations du système';

  @override
  String get permissionsCategoryChat => 'Chat';

  @override
  String get permissionsCategoryCalendar => 'Calendrier';

  @override
  String get permissionsCategoryMedication => 'Médicaments';

  @override
  String get permissionsCategoryContacts => 'Contacts';

  @override
  String get permissionsCategoryFinder => 'Repères (lieux et objets)';

  @override
  String get permissionsCategoryDiary => 'Journal';

  @override
  String get permissionsCategoryEmergency => 'Contacts d\'urgence';

  @override
  String get permissionsCategorySecurity => 'Sécurité';

  @override
  String profileAgeYears(int age) {
    return '$age ans';
  }

  @override
  String get groundingTitle => 'Appui';

  @override
  String get groundingChooseLabel => 'Ou choisis quelque chose';

  @override
  String get groundingDoneAgain => 'Encore une fois';

  @override
  String get groundingDoneOther => 'Autre chose';

  @override
  String get groundingDoneCall => 'Appeler quelqu\'un';

  @override
  String get groundingOrientationTitle => 'Ici et maintenant';

  @override
  String get groundingOrientationStep1 => 'Aujourd\'hui, nous sommes';

  @override
  String get groundingOrientationStep2 =>
      'Regarde autour de toi. Où es-tu, là ?';

  @override
  String get groundingOrientationStep3 =>
      'Dis qui tu es, à voix haute ou tout bas.';

  @override
  String get groundingOrientationStep4 =>
      'Le corps d\'aujourd\'hui n\'est pas celui d\'avant.';

  @override
  String get groundingOrientationStep5 => 'Ce dont tu te souviens est passé.';

  @override
  String get groundingOrientationStep6 => 'Tu es ici.';

  @override
  String get groundingSensesTitle => 'Voir, entendre, sentir';

  @override
  String get groundingSensesStep1 => 'Cinq choses que tu vois.';

  @override
  String get groundingSensesStep2 => 'Quatre choses que tu entends.';

  @override
  String get groundingSensesStep3 => 'Trois choses que tu peux toucher.';

  @override
  String get groundingSensesStep4 => 'Deux choses que tu sens.';

  @override
  String get groundingSensesStep5 => 'Une chose que tu goûtes.';

  @override
  String get groundingSensesStep6 => 'Tu es ici.';

  @override
  String get groundingBodyTitle => 'Sentir le corps';

  @override
  String get groundingBodyStep1 => 'Pose les deux pieds à plat sur le sol.';

  @override
  String get groundingBodyStep2 => 'Appuie les talons vers le bas.';

  @override
  String get groundingBodyStep3 =>
      'Prends quelque chose de froid dans la main.';

  @override
  String get groundingBodyStep4 => 'Tiens-le aussi longtemps que tu veux.';

  @override
  String get groundingBodyStep5 => 'Sens ton dos contre le dossier.';

  @override
  String get groundingBodyStep6 => 'Le sol te porte.';

  @override
  String get groundingContainerTitle => 'Mettre de côté';

  @override
  String get groundingContainerStep1 =>
      'Imagine un contenant. Aussi grand que tu veux.';

  @override
  String get groundingContainerStep2 => 'Il a un couvercle qui ferme bien.';

  @override
  String get groundingContainerStep3 =>
      'Mets dedans ce qui est trop lourd maintenant.';

  @override
  String get groundingContainerStep4 => 'Referme le couvercle.';

  @override
  String get groundingContainerStep5 => 'Pose-le à un endroit que tu choisis.';

  @override
  String get groundingContainerStep6 =>
      'Tu pourras le rouvrir. Pas maintenant.';

  @override
  String get groundingBreathTitle => 'Respiration';

  @override
  String get groundingBreathStep1 => 'Inspire et compte jusqu\'à quatre.';

  @override
  String get groundingBreathStep2 => 'Retiens un instant.';

  @override
  String get groundingBreathStep3 => 'Expire et compte jusqu\'à six.';

  @override
  String get groundingBreathStep4 => 'Encore. Sans te presser.';

  @override
  String get groundingBreathStep5 =>
      'Plus lentement dehors que dedans. Cela suffit.';

  @override
  String get medicationNameLabel => 'Nom du médicament';

  @override
  String get medicationDosageLabel => 'Dose';

  @override
  String get medicationDosageHint => 'p. ex. 1 comprimé, 10 mg, 5 ml';

  @override
  String get medicationNameRequired => 'Saisis un nom';

  @override
  String get medicationDosageRequired => 'Saisis la dose';

  @override
  String get medicationTypeQuestion => 'Quel type de médicament ?';

  @override
  String get medicationTypeDailyTitle => 'Médicament quotidien';

  @override
  String get medicationTypeDailyExplanation => 'À heures fixes, tous les jours';

  @override
  String get medicationTypeAsNeededTitle => 'Médicament au besoin';

  @override
  String get medicationTypeAsNeededExplanation =>
      'Seulement quand tu en as besoin';

  @override
  String get medicationWhenToTake => 'Quand le prendre ?';

  @override
  String get medicationSectionMorning => 'Le matin';

  @override
  String get medicationSectionMidday => 'À midi';

  @override
  String get medicationSectionEvening => 'Le soir';

  @override
  String get medicationSectionNight => 'La nuit';

  @override
  String get medicationOtherTime => 'Une autre heure';

  @override
  String get medicationSectionNotChosen => 'non sélectionné';

  @override
  String get medicationTimeRequired => 'Ajoute au moins une heure de prise';

  @override
  String get medicationAsNeededSettings => 'Réglages du médicament au besoin';

  @override
  String get medicationMaxDosesLabel => 'Maximum par jour *';

  @override
  String get medicationMaxDosesHint => 'p. ex. 3';

  @override
  String get medicationMaxDosesHelper =>
      'Combien de fois par jour peut-il être pris ?';

  @override
  String get medicationMaxDosesRequired =>
      'Obligatoire pour un médicament au besoin';

  @override
  String get medicationMaxDosesInvalid => 'Saisis un nombre supérieur à 0';

  @override
  String get medicationMaxDosesMissing => 'Indique le maximum par jour';

  @override
  String get medicationMinIntervalLabel =>
      'Écart minimum en heures (facultatif)';

  @override
  String get medicationMinIntervalHint => 'p. ex. 4';

  @override
  String get medicationMinIntervalHelper => 'Temps minimum entre deux prises';

  @override
  String get medicationMinIntervalInvalid =>
      'Saisis un nombre supérieur ou égal à 0';

  @override
  String get medicationRemindersTitle => 'Aurora te le rappellera';

  @override
  String get medicationRemindersOff =>
      'Aurora ne dit rien. Le médicament reste dans ta liste, tu décides quand la consulter.';

  @override
  String get medicationRemindersDaily =>
      'À chaque heure de prise, Aurora se manifeste trois fois : 30 minutes avant, 10 minutes avant et à l\'heure même. Sans réaction de ta part, encore une fois 10 minutes plus tard.';

  @override
  String get medicationRemindersNoInterval =>
      'Sans écart minimum, il n\'y a aucun moment qu\'Aurora puisse attendre. Indique un écart ci-dessous si tu veux être prévenu dès que la prochaine dose est permise.';

  @override
  String get medicationRemindersAsNeeded =>
      'Après une prise, Aurora te prévient dès que la suivante est permise et l\'annonce 30, 10 et 5 minutes à l\'avance.';

  @override
  String get medicationPeriodTitle => 'Période (facultatif)';

  @override
  String get medicationStartDate => 'Date de début';

  @override
  String get medicationEndDate => 'Date de fin';

  @override
  String get medicationNotesLabel => 'Notes (facultatif)';

  @override
  String get medicationNotesHint => 'p. ex. à prendre pendant le repas';

  @override
  String get medicationDescriptionLabel => 'Description détaillée (facultatif)';

  @override
  String get medicationDescriptionHint =>
      'Aide à distinguer des médicaments qui se ressemblent';

  @override
  String get medicationPhotoTitle => 'Photo du comprimé (facultatif)';

  @override
  String get medicationPhotoHint =>
      'Une photo aide à le reconnaître et évite les confusions';

  @override
  String get medicationPhotoTake => 'Prendre une photo';

  @override
  String get medicationPhotoRetake => 'Reprendre une photo';

  @override
  String medicationPhotoError(String error) {
    return 'La photo n\'a pas pu être chargée : $error';
  }

  @override
  String get medicationActiveTitle => 'Actif';

  @override
  String get medicationActiveOn => 'Apparaît dans la liste du jour';

  @override
  String get medicationActiveOff => 'Archivé';

  @override
  String get medicationDeleteTitle => 'Supprimer le médicament ?';

  @override
  String get medicationDeleteMessage =>
      'Veux-tu vraiment supprimer ce médicament ?';

  @override
  String get medicationDeleteConfirmMessage =>
      'Ce médicament sera supprimé définitivement.';

  @override
  String get medicationDeleted => 'Médicament supprimé';

  @override
  String get medicationIntakeTimesLabel => 'Heures de prise';

  @override
  String get medicationMaxDailyLabel => 'Max. par jour';

  @override
  String get medicationMinGapLabel => 'Écart min.';

  @override
  String get medicationStatusLabel => 'Statut';

  @override
  String get medicationStatusTaken => 'Pris';

  @override
  String get medicationStatusRefused => 'Refusé';

  @override
  String get medicationStatusSnoozed => 'Plus tard';

  @override
  String get medicationTake => 'Prendre';

  @override
  String get medicationTakeAnyway => 'Le prendre quand même';

  @override
  String get medicationDailyLimitReached => 'Limite du jour atteinte';

  @override
  String get medicationAddFeedback => 'Ajouter comment ça s\'est passé';

  @override
  String get medicationFeedbackYourExperience =>
      'Comment ça s\'est passé pour toi';

  @override
  String get medicationRefusalTitle => 'Noter le refus';

  @override
  String get medicationIntakesLabel => 'Prises';

  @override
  String get medicationNoProfileSelected => 'Aucun profil sélectionné';

  @override
  String get medicationNoLogPermission =>
      'Pas d\'autorisation pour enregistrer les prises';

  @override
  String get commonGallery => 'Galerie';

  @override
  String get commonCamera => 'Appareil photo';

  @override
  String get medicationStatusSkipped => 'Sauté';

  @override
  String medicationWillBeRefused(String name) {
    return '$name sera noté comme refusé.';
  }

  @override
  String clockTime(String time) {
    return '$time';
  }

  @override
  String medicationReminderAtTime(String time) {
    return 'Rappel à $time';
  }

  @override
  String medicationSnoozedUntil(String name, String time) {
    return '$name — rappel à $time';
  }

  @override
  String medicationAtTime(String time) {
    return 'à $time';
  }

  @override
  String medicationDoseCountToday(int available, int max) {
    return 'Disponibles : $available sur $max aujourd\'hui';
  }

  @override
  String medicationLastTaken(String time) {
    return 'Dernière prise : $time';
  }

  @override
  String medicationNextPossible(String time) {
    return 'Prochaine prise possible à $time';
  }

  @override
  String medicationNoteLabel(String note) {
    return 'Note : $note';
  }

  @override
  String medicationLimitWarning(int count, String name) {
    return 'Tu as déjà pris $count doses de $name aujourd\'hui. C\'est la limite du jour.';
  }

  @override
  String medicationTakenConfirmation(String name) {
    return '$name pris';
  }

  @override
  String get anchorTitle => 'Ancre';

  @override
  String get anchorSectionWhenHard => 'Quand c\'est dur';

  @override
  String get anchorSectionEveryday => 'Au quotidien';

  @override
  String get anchorSectionWhenCalm => 'Quand c\'est calme';

  @override
  String get fabMedication => 'Médicament';

  @override
  String get fabDiaryEntry => 'Entrée';

  @override
  String get fabContact => 'Contact';

  @override
  String get appQuitTitle => 'Fermer l\'application ?';

  @override
  String get appQuitMessage => 'Veux-tu vraiment fermer Aurora ?';

  @override
  String get emergencyResetTitle => 'Réinitialisation d\'urgence';

  @override
  String get emergencyResetWarning =>
      'AVERTISSEMENT : toutes les données seront supprimées définitivement.\n\nProfils, messages, rendez-vous, médicaments, contacts — tout.\n\nCette étape est irréversible.';

  @override
  String get emergencyResetConfirm => 'TOUT SUPPRIMER';

  @override
  String get pwResetCancelledTitle => 'Réinitialisation annulée';

  @override
  String get pwResetCancelledMessage =>
      'La réinitialisation en cours a été annulée avec l\'ancien mot de passe. Ton profil est maintenant actif.';

  @override
  String get pwResetUnderstood => 'Compris';

  @override
  String get pwResetNowActiveTitle => 'Nouveau mot de passe actif';

  @override
  String get pwResetNowActiveMessage =>
      'Le nouveau mot de passe s\'est activé automatiquement à la fin du délai. Ton profil est maintenant actif.';

  @override
  String get pwResetTitle => 'Réinitialiser le mot de passe';

  @override
  String get pwResetAnswerQuestions =>
      'Réponds aux questions de sécurité pour réinitialiser tout de suite';

  @override
  String pwResetAnswerN(int number) {
    return 'Réponse $number';
  }

  @override
  String get pwResetForgotAnswers =>
      'Réponses oubliées ?\nLance le compte à rebours de 24 heures';

  @override
  String get pwResetAnswerAll => 'Réponds à toutes les questions';

  @override
  String get pwResetAnswersWrong =>
      'Ces réponses ne sont pas les bonnes.\n\nTu peux réessayer ou lancer le compte à rebours de 24 heures.';

  @override
  String get pwResetCheckAnswers => 'Vérifier les réponses';

  @override
  String get pwResetSetNewTitle => 'Définir un nouveau mot de passe';

  @override
  String get pwResetAnswersCorrect =>
      'Questions de sécurité correctement répondues.';

  @override
  String get pwResetImmediateHint =>
      'Saisis ton nouveau mot de passe. Il sera actif tout de suite.';

  @override
  String get pwResetNewPassword => 'Nouveau mot de passe';

  @override
  String get pwResetConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get pwResetTooShort =>
      'Le mot de passe doit faire au moins 4 caractères';

  @override
  String get pwResetMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get pwResetChanged =>
      'Mot de passe modifié.\n\nTu peux maintenant te connecter avec le nouveau.';

  @override
  String get pwResetSetPassword => 'Définir le mot de passe';

  @override
  String get pwResetTimerHint =>
      'Saisis ton nouveau mot de passe.\n\nUn compte à rebours de 24 heures démarre ; ensuite, tu pourras l\'activer.';

  @override
  String pwResetStarted(String waitTime) {
    return 'Réinitialisation lancée.\n\nTon ancien mot de passe reste actif. Dans $waitTime, tu pourras activer le nouveau.';
  }

  @override
  String get pwResetStartError => 'La réinitialisation n\'a pas pu démarrer';

  @override
  String get pwResetStart => 'Lancer la réinitialisation';

  @override
  String get pwResetRunningTitle => 'Réinitialisation en cours';

  @override
  String get pwResetWhatsHappening => 'Que se passe-t-il ?';

  @override
  String get pwResetRunningExplanation =>
      'Tu as défini un nouveau mot de passe il y a peu. Par sécurité, un compte à rebours de 24 heures est en cours.\n\n';

  @override
  String pwResetRemaining(String time) {
    return 'Temps restant : $time';
  }

  @override
  String get pwResetReadyTitle => 'Prêt à activer';

  @override
  String get pwResetWaitOver => 'Le délai est écoulé.';

  @override
  String pwResetReadyExplanation(String startTime) {
    return 'Tu as défini un nouveau mot de passe le $startTime. Le délai de sécurité de 24 heures est écoulé.';
  }

  @override
  String get pwResetIrreversible =>
      'Si tu actives, ton ANCIEN mot de passe est remplacé définitivement par le NOUVEAU.';

  @override
  String get pwResetActivated =>
      'Nouveau mot de passe activé.\n\nTu peux maintenant t\'en servir pour te connecter.';

  @override
  String get pwResetActivateError => 'Le mot de passe n\'a pas pu être activé';

  @override
  String get pwResetActivate => 'Activer le nouveau mot de passe';

  @override
  String get profileCurrentlyActive => 'Profil actuellement utilisé';

  @override
  String get profilePasswordProtected =>
      'Ce profil est protégé par un mot de passe';

  @override
  String get profilePasswordLabel => 'Mot de passe';

  @override
  String get settingsMapCacheClearQuestion =>
      'Supprimer toutes les tuiles de carte enregistrées ?';

  @override
  String get settingsMapCacheCleared => 'Cache des cartes vidé';

  @override
  String get settingsMapPredownloadComingSoon =>
      'Le téléchargement à l\'avance arrivera dans une version ultérieure';

  @override
  String get settingsCacheLimitTitle => 'Définir la limite du cache';

  @override
  String settingsCacheLimitValue(int size) {
    return 'Taille maximale du cache : $size Mo';
  }

  @override
  String settingsCacheLimitMegabytes(int size) {
    return '$size Mo';
  }

  @override
  String get settingsCacheLimitExplanation =>
      'Quand le cache dépasse cette limite, les tuiles les plus anciennes sont supprimées automatiquement.';

  @override
  String get settingsAllDataDeleted => 'Toutes les données ont été supprimées';

  @override
  String get settingsDeleteIncomplete =>
      'Tout n\'a pas pu être supprimé. Veuillez réessayer.';

  @override
  String get settingsTrackingEnableTitle => 'Activer le suivi permanent ?';

  @override
  String get settingsTrackingWhatItDoes => 'Ce que fait ce mode :';

  @override
  String get settingsDataStaysHere => 'Tes données restent sur cet appareil';

  @override
  String get settingsDataStaysHereExplanation =>
      'Aurora enregistre toutes les données uniquement en local.';

  @override
  String get settingsBackgroundGpsBattery =>
      'Le GPS en arrière-plan peut consommer plus de batterie.';

  @override
  String get settingsAndroidStatus => 'État Android :';

  @override
  String get settingsActivate => 'Activer';

  @override
  String get settingsDeactivate => 'Désactiver';

  @override
  String get settingsTrackingDisableTitle => 'Désactiver le suivi permanent ?';

  @override
  String get settingsTrackingDisableExplanation =>
      'Le suivi GPS redevient réglable par profil.';

  @override
  String get settingsTestNotificationSent => 'Notification de test envoyée';

  @override
  String get settingsAndroidSettingNeeded =>
      'Un réglage Android est nécessaire';

  @override
  String settingsPermissionNeededFor(String permission) {
    return 'Pour le suivi permanent, il te faut l\'autorisation « $permission ».';
  }

  @override
  String get settingsStepByStep => 'Voici, étape par étape :';

  @override
  String get settingsOpenAndroidSettings => 'Ouvrir les réglages Android';

  @override
  String get settingsOpenNow => 'Ouvrir maintenant';

  @override
  String get settingsInTheSettings => 'Dans les réglages';

  @override
  String get settingsBackToAurora =>
      'Retour à Aurora\nL\'application détecte le changement toute seule.';

  @override
  String get settingsUnderstood => 'Compris';

  @override
  String settingsResetPendingFor(String name, String time) {
    return 'Profil : $name\nTemps restant : $time';
  }

  @override
  String settingsWhatIs(String name) {
    return 'Qu\'est-ce que « $name » ?';
  }

  @override
  String get settingsAdminTrackingExplanation =>
      'En tant qu\'administrateur, tu peux régler le suivi GPS pour TOUS les profils d\'un coup. Quand c\'est activé :';

  @override
  String settingsPrerequisite(String permission) {
    return 'Il faut d\'abord l\'autorisation Android « $permission ».';
  }

  @override
  String get settingsGpsPermission => 'Autorisation GPS';

  @override
  String get settingsBackgroundReady =>
      'Tout est prêt pour le suivi permanent.';

  @override
  String settingsHowToEnable(String permission) {
    return 'Comment activer « $permission »';
  }

  @override
  String get settingsLocationStaysHere =>
      'Tes données de position restent sur cet appareil.';

  @override
  String get settingsTrackingAlwaysOn => 'Suivi toujours actif';

  @override
  String get settingsHowNotificationsWork =>
      'Comment fonctionnent les notifications ?';

  @override
  String get settingsSendTestNotification => 'Envoyer une notification de test';

  @override
  String get settingsCheckNotificationsWork =>
      'Vérifie que les notifications arrivent';

  @override
  String get settingsQueue => 'File d\'attente';

  @override
  String get settingsScheduledNotifications => 'Notifications programmées :';

  @override
  String settingsNextAt(String time) {
    return 'Prochaine : $time';
  }

  @override
  String settingsCacheUsage(String used, String limit, String count) {
    return '$used Mo sur $limit Mo • $count tuiles';
  }

  @override
  String settingsPercent(int value) {
    return '$value %';
  }

  @override
  String get settingsCacheLimitLabel => 'Limite du cache';

  @override
  String get settingsPredownloadMaps => 'Télécharger les cartes à l\'avance';

  @override
  String get settingsPredownloadSubtitle =>
      'Télécharge les cartes d\'une zone autour de toi';

  @override
  String get settingsClearCache => 'Vider le cache';

  @override
  String get settingsClearCacheSubtitle =>
      'Supprimer toutes les tuiles de carte enregistrées';

  @override
  String get settingsDiscreetRemindersTitle => 'Rappels sans le contenu';

  @override
  String get settingsDiscreetRemindersOn =>
      'L\'écran de verrouillage n\'affiche que « Aurora — rappel ». Ce dont il s\'agit, tu le vois après déverrouillage.';

  @override
  String get settingsDiscreetRemindersOff =>
      'L\'écran de verrouillage affiche le nom et la dose, ou le rendez-vous, en clair.';

  @override
  String get settingsWhatAuroraSends => 'Ce qu\'Aurora envoie';

  @override
  String get settingsWhatAuroraSendsSubtitle =>
      'Consulte chaque envoi mot pour mot';

  @override
  String get settingsAlwaysAllow => 'Toujours autoriser';

  @override
  String get settingsAlwaysAllowRequired =>
      'L\'autorisation de localisation « Toujours autoriser » est nécessaire';

  @override
  String get settingsLocalOnly =>
      'Aurora enregistre toutes les données uniquement en local. Pas de cloud, pas de serveurs, aucun envoi.';

  @override
  String get settingsTrackingDisableFull =>
      'Le suivi GPS redevient réglable par profil.\n\nChaque profil pourra l\'activer et le désactiver lui-même.';

  @override
  String get settingsAlwaysAllowNeeded =>
      'Pour le suivi permanent, il te faut l\'autorisation « Toujours autoriser ».';

  @override
  String get settingsWhatIsAlwaysOn =>
      'Qu\'est-ce que « suivi toujours actif » ?';

  @override
  String get settingsAlwaysAllowPrerequisite =>
      'Il faut d\'abord l\'autorisation Android « Toujours autoriser », pour que le suivi continue quand l\'application est fermée.';

  @override
  String get settingsHowToEnableAlwaysAllow =>
      'Comment activer « Toujours autoriser » :';

  @override
  String get settingsLocationStaysOffline =>
      'Tes données de position restent sur cet appareil. Aurora fonctionne hors ligne, sans connexion à un serveur.';

  @override
  String settingsCountValue(int count) {
    return '$count';
  }

  @override
  String settingsTilesCount(String used, String limit, String count) {
    return '$used Mo sur $limit Mo • $count tuiles';
  }

  @override
  String settingsMaxStorage(int size) {
    return '$size Mo de stockage maximum';
  }

  @override
  String errorWithDetail(String error) {
    return 'Erreur : $error';
  }

  @override
  String get securityQuestionsFillAll =>
      'Remplis les trois questions et réponses';

  @override
  String get securityQuestionsSaved =>
      'Questions de sécurité enregistrées.\n\nTu peux maintenant t\'en servir pour réinitialiser ton mot de passe.';

  @override
  String get securityQuestionsRemoveTitle =>
      'Retirer les questions de sécurité ?';

  @override
  String get securityQuestionsRemoveWarning =>
      'Sans les questions de sécurité, le compte à rebours de 24 heures est le seul moyen restant de réinitialiser ton mot de passe.';

  @override
  String get securityQuestionsRemoved => 'Questions de sécurité retirées';

  @override
  String get securityQuestionsSetupTitle =>
      'Configurer des questions de sécurité';

  @override
  String get securityQuestionsSetupExplanation =>
      'Configure trois questions de sécurité pour pouvoir réinitialiser vite ton mot de passe.';

  @override
  String get securityQuestionsChooseWisely =>
      'Choisis des questions dont tu n\'oublieras jamais les réponses';

  @override
  String securityQuestionN(int number) {
    return 'Question $number';
  }

  @override
  String securityAnswerToQuestionN(int number) {
    return 'Réponse à la question $number';
  }

  @override
  String get securityQuestionHint1 => 'p. ex. le nom de mon premier animal ?';

  @override
  String get securityQuestionHint2 =>
      'p. ex. le lieu de naissance de ma mère ?';

  @override
  String get securityQuestionHint3 =>
      'p. ex. mon film préféré quand j\'étais enfant ?';

  @override
  String get errorReportPreviewTitle => 'Aperçu du rapport d\'erreur';

  @override
  String get errorReportWhatIsSent => 'Voici ce qui est envoyé :';

  @override
  String get errorReportContactSection => 'Contact (facultatif)';

  @override
  String get errorReportContactExplanation =>
      'Seulement si tu veux qu\'on puisse te joindre en cas de questions :';

  @override
  String get errorReportEmailLabel => 'Adresse e-mail (facultatif)';

  @override
  String get errorReportNewsletter => 'S\'inscrire aux actualités';

  @override
  String get errorReportNewsletterSubtitle =>
      'Reçois des nouvelles d\'Aurora, au plus une fois par mois';

  @override
  String get errorReportEmailUseOnly =>
      'Nous n\'utilisons ton e-mail que pour des questions sur ce rapport.';

  @override
  String get errorReportCopy => 'Copier';

  @override
  String get errorReportCopied => 'Rapport copié dans le presse-papiers';

  @override
  String errorReportAutoGenerated(String type) {
    return 'Rapport généré automatiquement ($type).';
  }

  @override
  String get errorReportQueued =>
      'Rapport accepté. Il partira dès que tu seras de nouveau en ligne.';

  @override
  String get errorReportFailed => 'Le rapport n\'a pas pu être envoyé';

  @override
  String get errorReportCopyToClipboard => 'Copier dans le presse-papiers';

  @override
  String permissionsLevel(int level) {
    return 'Niveau $level';
  }

  @override
  String get permissionsSectionExplanation =>
      'Décide quels espaces ce profil peut utiliser. Chaque espace se règle séparément :';

  @override
  String get permissionsChildPreset => 'Préréglage enfant';

  @override
  String get permissionsAdultPreset => 'Préréglage adulte';

  @override
  String get permissionsCategoryEmergencyDiary => 'Journal d\'urgence';

  @override
  String get permissionsCategoryHelp => 'Aide';

  @override
  String get permissionsCategoryMantras => 'Mantras';

  @override
  String get permissionsCategoryGames => 'Jeux';

  @override
  String get permissionsChangeableLater =>
      'Tu peux modifier les autorisations à tout moment dans les réglages';

  @override
  String get errorReportRoute =>
      'Le rapport part directement aux développeurs ; si cela échoue, Aurora ouvre ton application e-mail. Ce qui a été envoyé figure dans les réglages, sous « Ce qu\'Aurora envoie ».';

  @override
  String get errorReportEmailPrivacy =>
      'Nous n\'utilisons ton e-mail que pour des questions sur ce rapport et ne le transmettons à personne.';

  @override
  String errorReportAutoBody(String type) {
    return 'Rapport généré automatiquement ($type). Les détails figurent dans le diagnostic de l\'appareil.';
  }

  @override
  String errorReportClipboardFallback(String email) {
    return 'Le rapport est dans le presse-papiers. Tu peux aussi nous l\'envoyer par e-mail à $email.';
  }

  @override
  String get mapAddressNotFound => 'Adresse introuvable';

  @override
  String get mapNeedsInternet =>
      'Aurora a besoin d\'internet pour chercher des adresses';

  @override
  String get mapDataEnabled =>
      'Données cartographiques activées — la carte se charge';

  @override
  String get mapTapOrSearch => 'Appuie sur la carte ou cherche une adresse';

  @override
  String get mapAddressLoading => 'Chargement de l\'adresse…';

  @override
  String get mapPickTitle => 'Ajouter un lieu';

  @override
  String get mapTapSearchOrLocate =>
      'Appuie sur la carte, cherche une adresse ou utilise ta position';

  @override
  String get mapSearchHint =>
      'Chercher une adresse (p. ex. 3 rue de l\'Église, Coswig)';

  @override
  String get mapDataNotLoaded => 'Données cartographiques non chargées';

  @override
  String get mapEnableToMark =>
      'Active les données cartographiques pour marquer des lieux sur la carte.';

  @override
  String get mapDataFromOsm =>
      'Les données cartographiques viennent d\'OpenStreetMap.\nAurora a besoin d\'une connexion internet une seule fois.';

  @override
  String get mapZoomIn => 'Agrandir';

  @override
  String get mapZoomOut => 'Réduire';

  @override
  String get mapToMyLocation => 'Vers ma position';

  @override
  String get feedbackSheetTitle => 'Contacter le développeur';

  @override
  String get feedbackSheetIntro =>
      'Aurora est en bêta ouverte et vit de tes retours.';

  @override
  String get feedbackReplyOnlyIfWanted => 'Seulement si tu veux une réponse';

  @override
  String errorOpening(String error) {
    return 'Impossible d\'ouvrir : $error';
  }

  @override
  String errorLinkNotOpened(String url) {
    return 'Le lien n\'a pas pu être ouvert : $url';
  }

  @override
  String get thankYouTitle => 'Merci !';

  @override
  String get thankYouReportSent =>
      'Ton rapport est bien arrivé et nous aide à améliorer Aurora.';

  @override
  String get thankYouReportRecorded => 'Ton rapport d\'erreur a été enregistré';

  @override
  String get thankYouJoinCommunity => 'Rejoins la communauté';

  @override
  String get thankYouDiscord => 'Serveur Discord';

  @override
  String get thankYouDiscordSubtitle =>
      'Échange avec d\'autres personnes et l\'équipe';

  @override
  String get thankYouMoreContact => 'Autres façons de nous joindre';

  @override
  String get thankYouEmailSupport => 'Assistance par e-mail';

  @override
  String get thankYouWhatsNext => 'Et ensuite ?';

  @override
  String get thankYouBackToApp => 'Retour à Aurora';

  @override
  String get transparencyDeleteTitle => 'Supprimer cette entrée ?';

  @override
  String get transparencyDeleteMessage =>
      'L\'entrée disparaît de cette liste. Ce qui a déjà été envoyé n\'en revient pas pour autant.';

  @override
  String get transparencyIntro =>
      'Ici, tu vois chaque envoi parti de ton appareil — mot pour mot.';

  @override
  String get transparencyNothingSent => 'Rien n\'a encore été envoyé.';

  @override
  String get transparencySendUsageData =>
      'Envoyer des données d\'usage anonymes';

  @override
  String get transparencyIrreversible =>
      'Ce qui a déjà été envoyé ne peut pas être rappelé. C\'est parti.';

  @override
  String imagePickerAnimalError(String error) {
    return 'L\'avatar animal n\'a pas pu être choisi : $error';
  }

  @override
  String get imagePickerCameraNeeded =>
      'Aurora a besoin de l\'autorisation caméra pour prendre des photos';

  @override
  String get imagePickerGalleryNeeded =>
      'Aurora a besoin de l\'autorisation galerie pour choisir des images';

  @override
  String get imagePickerAllowInSettings => 'L\'autoriser dans les réglages';

  @override
  String get imagePickerOpenSettings => 'Ouvrir les réglages';

  @override
  String imagePickerPickError(String error) {
    return 'L\'image n\'a pas pu être choisie : $error';
  }

  @override
  String imagePickerSaveError(String error) {
    return 'L\'image n\'a pas pu être enregistrée : $error';
  }

  @override
  String get feedbackThankYouTitle => 'Ton retour a bien été enregistré';

  @override
  String get feedbackThankYouMessage =>
      'Merci ! Ton retour nous aide à améliorer Aurora.';

  @override
  String get feedbackStayInTouch => 'Restons en contact';

  @override
  String get feedbackAuroraDiscord => 'Aurora sur Discord';

  @override
  String get feedbackWebsite => 'Site web';

  @override
  String get feedbackEmail => 'E-mail';

  @override
  String get crashTitle => 'Quelque chose s\'est mal passé';

  @override
  String get crashMessage =>
      'Aurora a rencontré une erreur inattendue. Tes données ne sont pas touchées.';

  @override
  String get crashTechnicalDetails => 'Détails techniques';

  @override
  String get crashReport => 'Signaler l\'erreur';

  @override
  String get crashRestart => 'Redémarrer l\'application';

  @override
  String get crashContinue => 'Continuer quand même';

  @override
  String get doodleSendDrawing => 'Envoyer le dessin';

  @override
  String get doodleSticker => 'Autocollant';

  @override
  String get doodleStrokeWidth => 'Épaisseur du trait';

  @override
  String get doodleStrokeThin => 'Trait fin';

  @override
  String get doodleStrokeMedium => 'Trait moyen';

  @override
  String get doodleStrokeThick => 'Trait épais';

  @override
  String get imagePickerDrawYourself => 'Le dessiner soi-même';

  @override
  String get doodleAvatarTitle => 'Dessine ton image';

  @override
  String get doodleAvatarDone => 'Terminé';

  @override
  String get doodleAvatarEmptyHint => 'Dessine d\'abord quelque chose';

  @override
  String get permCreateProfilesLabel => 'Ajouter une part';

  @override
  String get permCreateProfilesDesc =>
      'Accueillir une nouvelle part dans Aurora';

  @override
  String get permDeactivateProfilesLabel => 'Masquer une part';

  @override
  String get permDeactivateProfilesDesc =>
      'Masquer une part un moment — visible à nouveau plus tard';

  @override
  String get permManagePermissionsLabel => 'Gérer les droits';

  @override
  String get permManagePermissionsDesc =>
      'Décider de ce que les autres parts peuvent faire';

  @override
  String get permAccessSettingsLabel => 'Réglages de l\'application';

  @override
  String get permAccessSettingsDesc => 'Configurer et ajuster Aurora';

  @override
  String get permViewChatLabel => 'Lire le chat';

  @override
  String get permViewChatDesc => 'Voir les messages du chat interne';

  @override
  String get permSendChatMessageLabel => 'Pouvoir tout envoyer';

  @override
  String get permSendChatMessageDesc =>
      'Un droit qui couvre tout type de message — remplace les droits ci-dessous';

  @override
  String get permSendTextMessageLabel => 'Écrire du texte';

  @override
  String get permSendTextMessageDesc =>
      'Mettre des messages écrits dans le chat';

  @override
  String get permSendDoodleLabel => 'Dessiner';

  @override
  String get permSendDoodleDesc => 'Partager dessins et gribouillages';

  @override
  String get permSendVoiceMessageLabel => 'Parler';

  @override
  String get permSendVoiceMessageDesc =>
      'Enregistrer quelque chose et envoyer sa propre voix';

  @override
  String get permSendImageLabel => 'Envoyer des images';

  @override
  String get permSendImageDesc =>
      'Prendre des photos ou les partager depuis la galerie';

  @override
  String get permSendVideoLabel => 'Envoyer des vidéos';

  @override
  String get permSendVideoDesc =>
      'Enregistrer des vidéos ou les partager depuis la galerie';

  @override
  String get permDeleteOwnMessagesLabel => 'Supprimer ses propres messages';

  @override
  String get permDeleteOwnMessagesDesc =>
      'Ne retirer que ce qu\'on a écrit soi-même';

  @override
  String get permDeleteAllMessagesLabel =>
      'Supprimer les messages d\'autres parts';

  @override
  String get permDeleteAllMessagesDesc =>
      'Retirer aussi les messages d\'autres parts — c\'est irréversible';

  @override
  String get permViewCalendarLabel => 'Voir le calendrier';

  @override
  String get permViewCalendarDesc => 'Voir ce qui arrive';

  @override
  String get permCreateEventsLabel => 'Ajouter un rendez-vous';

  @override
  String get permCreateEventsDesc =>
      'Mettre de nouveaux rendez-vous au calendrier';

  @override
  String get permEditOwnEventsLabel => 'Modifier ses propres rendez-vous';

  @override
  String get permEditOwnEventsDesc =>
      'Modifier seulement les rendez-vous qu\'on a ajoutés soi-même';

  @override
  String get permEditAllEventsLabel => 'Modifier tous les rendez-vous';

  @override
  String get permEditAllEventsDesc =>
      'Modifier aussi les rendez-vous d\'autres parts';

  @override
  String get permDeleteOwnEventsLabel => 'Supprimer ses propres rendez-vous';

  @override
  String get permDeleteOwnEventsDesc =>
      'Retirer seulement les rendez-vous qu\'on a ajoutés soi-même';

  @override
  String get permDeleteAllEventsLabel => 'Supprimer tous les rendez-vous';

  @override
  String get permDeleteAllEventsDesc =>
      'Retirer aussi les rendez-vous d\'autres parts — c\'est irréversible';

  @override
  String get permAttachEventMediaLabel => 'Pièces jointes du rendez-vous';

  @override
  String get permAttachEventMediaDesc =>
      'Joindre images et notes à un rendez-vous';

  @override
  String get permCommentOnCalendarEventsLabel => 'Commenter';

  @override
  String get permCommentOnCalendarEventsDesc =>
      'Ajouter un mot à un rendez-vous';

  @override
  String get permViewMedicationLabel => 'Voir les médicaments';

  @override
  String get permViewMedicationDesc => 'Voir ce que le corps reçoit et quand';

  @override
  String get permManageMedicationLabel => 'Gérer les médicaments';

  @override
  String get permManageMedicationDesc =>
      'Ajouter, modifier et retirer des médicaments';

  @override
  String get permLogMedicationLabel => 'Confirmer une prise';

  @override
  String get permLogMedicationDesc => 'Cocher ce qui a déjà été pris';

  @override
  String get permOverrideMedicationLogLabel => 'Annuler une prise notée';

  @override
  String get permOverrideMedicationLogDesc =>
      'Modifier une confirmation faite par une autre part';

  @override
  String get permCommentOnMedicationLabel => 'Commenter';

  @override
  String get permCommentOnMedicationDesc => 'Ajouter un mot à un médicament';

  @override
  String get permViewOwnDiaryLabel => 'Son propre journal';

  @override
  String get permViewOwnDiaryDesc => 'Ne lire que ses propres entrées';

  @override
  String get permViewAllDiariesLabel => 'Tous les journaux';

  @override
  String get permViewAllDiariesDesc => 'Lire aussi les entrées d\'autres parts';

  @override
  String get permWriteDiaryLabel => 'Écrire dans le journal';

  @override
  String get permWriteDiaryDesc => 'Écrire quelque chose dans le journal';

  @override
  String get permViewContactsLabel => 'Voir les contacts';

  @override
  String get permViewContactsDesc => 'Voir qui fait partie de l\'entourage';

  @override
  String get permManageContactsLabel => 'Gérer les contacts';

  @override
  String get permManageContactsDesc =>
      'Ajouter, modifier et retirer des personnes';

  @override
  String get permCommentOnContactsLabel => 'Commenter';

  @override
  String get permCommentOnContactsDesc =>
      'Ajouter un mot au sujet d\'une personne';

  @override
  String get permViewFinderLabel => 'Voir les repères';

  @override
  String get permViewFinderDesc =>
      'Retrouver où est quelque chose ou où l\'on est allé';

  @override
  String get permManageFinderLabel => 'Gérer les repères';

  @override
  String get permManageFinderDesc =>
      'Ajouter, modifier et retirer lieux et objets';

  @override
  String get permCommentOnFinderEntriesLabel => 'Commenter';

  @override
  String get permCommentOnFinderEntriesDesc =>
      'Ajouter un mot à un lieu ou un objet';

  @override
  String get permCreateDiaryEntryLabel => 'Écrire une entrée';

  @override
  String get permCreateDiaryEntryDesc => 'Créer une nouvelle entrée de journal';

  @override
  String get permEditOwnDiaryEntriesLabel => 'Modifier ses propres entrées';

  @override
  String get permEditOwnDiaryEntriesDesc =>
      'Modifier seulement les entrées qu\'on a écrites soi-même';

  @override
  String get permEditAllDiaryEntriesLabel => 'Modifier toutes les entrées';

  @override
  String get permEditAllDiaryEntriesDesc =>
      'Modifier aussi les entrées d\'autres parts';

  @override
  String get permDeleteOwnDiaryEntriesLabel => 'Supprimer ses propres entrées';

  @override
  String get permDeleteOwnDiaryEntriesDesc =>
      'Retirer seulement les entrées qu\'on a écrites soi-même';

  @override
  String get permDeleteAllDiaryEntriesLabel => 'Supprimer toutes les entrées';

  @override
  String get permDeleteAllDiaryEntriesDesc =>
      'Retirer aussi les entrées d\'autres parts — c\'est irréversible';

  @override
  String get permCommentOnDiaryEntriesLabel => 'Commenter';

  @override
  String get permCommentOnDiaryEntriesDesc => 'Ajouter un mot à une entrée';

  @override
  String get permViewSharedEntriesLabel => 'Entrées partagées';

  @override
  String get permViewSharedEntriesDesc =>
      'Lire les entrées partagées avec plusieurs parts';

  @override
  String get permViewEmergencyContactsLabel => 'Voir les contacts d\'urgence';

  @override
  String get permViewEmergencyContactsDesc =>
      'Voir qui est joignable en cas d\'urgence';

  @override
  String get permCallEmergencyContactsLabel => 'Appeler';

  @override
  String get permCallEmergencyContactsDesc =>
      'Appeler quelqu\'un directement en cas d\'urgence';

  @override
  String get permEditEmergencyContactsLabel =>
      'Modifier les contacts d\'urgence';

  @override
  String get permEditEmergencyContactsDesc =>
      'Ajouter, modifier et retirer des contacts d\'urgence';

  @override
  String get permResetPasswordsLabel => 'Réinitialiser les mots de passe';

  @override
  String get permResetPasswordsDesc =>
      'Définir un nouveau mot de passe pour une autre part';

  @override
  String get permChangeOwnPasswordLabel => 'Changer son propre mot de passe';

  @override
  String get permChangeOwnPasswordDesc =>
      'Définir un nouveau mot de passe pour soi seulement';

  @override
  String get permEnableBiometricsLabel => 'Activer la biométrie';

  @override
  String get permEnableBiometricsDesc =>
      'Se connecter avec l\'empreinte ou le visage';

  @override
  String get permViewChatTabLabel => 'Espace chat';

  @override
  String get permViewChatTabDesc => 'Voir le chat tout court';

  @override
  String get permViewFeedbackTabLabel => 'Espace commentaires';

  @override
  String get permViewFeedbackTabDesc =>
      'Écrire à celles et ceux qui développent Aurora';

  @override
  String get permViewCalendarTabLabel => 'Espace calendrier';

  @override
  String get permViewCalendarTabDesc => 'Voir le calendrier tout court';

  @override
  String get permViewMedicationTabLabel => 'Espace médicaments';

  @override
  String get permViewMedicationTabDesc =>
      'Voir le plan de médication tout court';

  @override
  String get permViewDiaryTabLabel => 'Espace journal';

  @override
  String get permViewDiaryTabDesc => 'Voir le journal tout court';

  @override
  String get permViewContactsTabLabel => 'Espace contacts';

  @override
  String get permViewContactsTabDesc => 'Voir les contacts tout court';

  @override
  String get permViewFinderTabLabel => 'Espace repères';

  @override
  String get permViewFinderTabDesc => 'Voir les repères tout court';

  @override
  String get permViewEmergencyTabLabel => 'Espace urgence';

  @override
  String get permViewEmergencyTabDesc => 'Voir l\'aide d\'urgence tout court';

  @override
  String get permViewHelpTabLabel => 'Espace aide';

  @override
  String get permViewHelpTabDesc =>
      'Voir l\'aide et les points de contact tout court';

  @override
  String get permViewMantrasTabLabel => 'Espace mantras';

  @override
  String get permViewMantrasTabDesc => 'Voir les mantras tout court';

  @override
  String get permViewGamesTabLabel => 'Espace jeux';

  @override
  String get permViewGamesTabDesc => 'Voir les jeux tout court';

  @override
  String get permViewTimelineTabLabel => 'Espace frise';

  @override
  String get permViewTimelineTabDesc =>
      'Voir quand telle part était là — et à quel endroit';

  @override
  String permissionYouNeed(String permission) {
    return 'Il te faut : $permission';
  }

  @override
  String get fact01 =>
      'Le TDI (trouble dissociatif de l\'identité) touche environ 1 à 2 % de la population.';

  @override
  String get fact02 =>
      'Chaque personne d\'un système peut avoir ses propres goûts, capacités et souvenirs.';

  @override
  String get fact03 =>
      'La communication intérieure est un pas important vers la stabilité et la guérison.';

  @override
  String get fact04 =>
      'La dissociation est une réaction de protection naturelle du psychisme.';

  @override
  String get fact05 =>
      'Beaucoup de personnes vivant avec un TDI fonctionnent bien et mènent une vie réussie.';

  @override
  String get fact06 =>
      'Aurora a été conçue spécialement pour que les personnes d\'un système échangent entre elles.';

  @override
  String get fact07 =>
      'L\'espace chat permet d\'échanger en sécurité, sans autre application.';

  @override
  String get fact08 =>
      'Chaque profil peut avoir ses propres droits — de l\'accès complet à un ensemble restreint.';

  @override
  String get fact09 =>
      'Le premier profil devient automatiquement administrateur, avec tous les droits.';

  @override
  String get fact10 =>
      'Le calendrier rend les rendez-vous importants visibles pour tout le système.';

  @override
  String get fact11 =>
      'Dans l\'espace médicaments, tu peux gérer les médicaments quotidiens et ceux au besoin.';

  @override
  String get fact12 =>
      'Les repères aident à noter les objets perdus et à les retrouver.';

  @override
  String get fact13 =>
      'Le journal d\'urgence consigne les situations difficiles pour ton thérapeute.';

  @override
  String get fact14 =>
      'Les mantras peuvent aider à s\'ancrer en cas de dissociation ou de stress.';

  @override
  String get fact15 =>
      'Dans l\'espace contacts, tu peux évaluer des personnes importantes et ajouter des notes.';

  @override
  String get fact16 => 'Tu peux choisir une couleur propre à chaque profil.';

  @override
  String get fact17 =>
      'Les messages vocaux permettent de communiquer même quand écrire est difficile.';

  @override
  String get fact18 =>
      'Les gribouillages dans le chat aident à exprimer des sentiments sans mots.';

  @override
  String get fact19 =>
      'Tes entrées restent sur ton appareil. Seul ce que tu écris dans le formulaire de commentaires est envoyé.';

  @override
  String get fact20 =>
      'Faire régulièrement le point avec tout le système favorise la coopération.';

  @override
  String get fact21 =>
      'Un calendrier commun évite les doubles réservations et le stress.';

  @override
  String get fact22 =>
      'Les notes du journal d\'urgence peuvent beaucoup aider en thérapie.';

  @override
  String get fact23 =>
      'Chaque personne du système peut avoir ses propres besoins — c\'est tout à fait normal.';

  @override
  String get fact24 =>
      'Les exercices d\'ancrage aident à rester dans l\'ici et maintenant.';

  @override
  String get fact25 =>
      'Les routines donnent sécurité et structure à tout le système.';

  @override
  String get fact26 =>
      'Les pauses comptent — pour les personnes du système aussi.';

  @override
  String get fact27 =>
      'Tu peux masquer des profils à tout moment et les rétablir plus tard.';

  @override
  String get fact28 =>
      'L\'administrateur peut ajuster les droits à tout moment.';

  @override
  String get fact29 =>
      'Les médicaments au besoin peuvent être notés sur le moment.';

  @override
  String get fact30 =>
      'Dans le chat, tu peux t\'adresser à des personnes précises.';

  @override
  String get fact31 =>
      'Aurora utilise un chiffrement fort pour les données sensibles.';

  @override
  String get fact32 => 'Les mots de passe ne sont jamais enregistrés en clair.';

  @override
  String get fact33 =>
      'Réinitialiser un mot de passe prend 24 heures, par sécurité.';

  @override
  String get fact34 =>
      'Tous les messages du chat restent privés et sont stockés sur l\'appareil.';

  @override
  String get fact35 =>
      'Chaque pas vers une meilleure communication est une réussite.';

  @override
  String get fact36 =>
      'Il est normal d\'avoir des avis différents au sein du système.';

  @override
  String get fact37 => 'Coopérer rend fort — à l\'intérieur aussi.';

  @override
  String get fact38 =>
      'Tu n\'es pas seul — beaucoup de gens vivent bien avec un TDI.';

  @override
  String get sliderChat0 => '👁️ Lire le chat et dessiner';

  @override
  String get sliderChat1 =>
      '✅ Tout dans le chat : texte, dessins, voix, images, vidéos';

  @override
  String get sliderCalendar0 => '❌ Pas d\'accès au calendrier';

  @override
  String get sliderCalendar1 => '👁️ Voir les rendez-vous';

  @override
  String get sliderCalendar2 => '📅 Créer et modifier ses propres rendez-vous';

  @override
  String get sliderCalendar3 =>
      '✅ Gérer tous les rendez-vous et ajouter des pièces jointes';

  @override
  String get sliderMedication0 => '❌ Pas d\'accès aux médicaments';

  @override
  String get sliderMedication1 => '👁️ Voir la liste des médicaments';

  @override
  String get sliderMedication2 => '✅ Confirmer les prises';

  @override
  String get sliderDiary0 => '❌ Pas d\'accès au journal';

  @override
  String get sliderDiary1 => '👁️ Ne lire que son propre journal';

  @override
  String get sliderDiary2 => '📝 Écrire dans son propre journal';

  @override
  String get sliderDiary3 => '✅ Lire et écrire dans tous les journaux';

  @override
  String get sliderContacts0 => '❌ Pas d\'accès aux contacts';

  @override
  String get sliderContacts1 => '👁️ Voir les contacts';

  @override
  String get sliderContacts2 => '💬 Voir les contacts et commenter';

  @override
  String get sliderContacts3 =>
      '✅ Gérer les contacts : créer, modifier, supprimer';

  @override
  String get sliderFinder0 => '❌ Pas d\'accès aux repères';

  @override
  String get sliderFinder1 => '👁️ Voir les entrées';

  @override
  String get sliderFinder2 => '✅ Gérer les entrées';

  @override
  String get sliderEmergencyDiary0 => '❌ Pas d\'accès au journal d\'urgence';

  @override
  String get sliderEmergencyDiary1 => '👁️ Voir les entrées';

  @override
  String get sliderEmergencyDiary2 =>
      '💬 Créer et commenter des entrées, modifier les siennes';

  @override
  String get sliderEmergencyDiary3 => '✅ Gérer toutes les entrées';

  @override
  String get sliderEmergency0 => '❌ Pas d\'accès aux contacts d\'urgence';

  @override
  String get sliderEmergency1 => '👁️ Voir les contacts d\'urgence';

  @override
  String get sliderEmergency2 => '📞 Voir et appeler les contacts d\'urgence';

  @override
  String get sliderEmergency3 => '✅ Gérer les contacts d\'urgence';

  @override
  String get sliderHelp0 => '❌ Pas d\'accès à l\'aide';

  @override
  String get sliderHelp1 => '✅ Voir l\'aide et les points de contact';

  @override
  String get sliderMantras0 => '❌ Pas d\'accès aux mantras';

  @override
  String get sliderMantras1 => '✅ Utiliser les mantras';

  @override
  String get sliderGames0 => '❌ Pas d\'accès aux jeux';

  @override
  String get sliderGames1 => '✅ Jouer';

  @override
  String get settingsDeleteAll => 'Tout supprimer';

  @override
  String get settingsCacheClearHint =>
      'Les cartes se rechargeront à la prochaine ouverture. Cela peut libérer de l\'espace.';

  @override
  String get settingsGpsWhileInUse => 'Autorisé pendant l\'utilisation ✓';

  @override
  String get settingsGpsNotAllowed => 'Non autorisé';

  @override
  String settingsGpsStatusLine(String status) {
    return '⚠️ $status';
  }

  @override
  String get settingsGpsBackgroundRuns =>
      'Le GPS tourne en permanence en arrière-plan';

  @override
  String get settingsGpsOverridesAll =>
      'Remplace le réglage de suivi de TOUS les profils';

  @override
  String get settingsStepTapPermission => 'Appuie sur « Autorisations »';

  @override
  String get settingsStepTapLocation => 'Appuie sur « Position »';

  @override
  String get settingsStepChooseAlways => 'Choisis « Toujours autoriser »';

  @override
  String get settingsStepOpenSettings =>
      'Appuie ci-dessous sur « Ouvrir les réglages Android »';

  @override
  String get settingsStepPermissionLocation =>
      'Choisis « Autorisations » → « Position »';

  @override
  String get settingsPositionAlways => 'La position est enregistrée en continu';

  @override
  String get settingsOverridesProfiles =>
      'Remplace le réglage de chaque profil';

  @override
  String get settingsAllProfilesTracked =>
      'Tous les profils sont enregistrés automatiquement';

  @override
  String get settingsOpenGpsSettings => 'Ouvrir les réglages GPS';

  @override
  String get settingsGpsRunsForAll =>
      'Le GPS tourne en permanence pour tous les profils';

  @override
  String get settingsNotifAsNeeded =>
      'Médicament au besoin : Aurora prévient dès que la dose suivante est permise — 30, 10 et 5 minutes avant';

  @override
  String get settingsNotifWorksClosed =>
      'Fonctionne même quand l\'application est fermée';

  @override
  String get aboutTitle => 'À propos d\'Aurora';

  @override
  String get aboutChat =>
      'Se parler — par texte, images, vidéos et messages vocaux';

  @override
  String get aboutCalendar =>
      'Rendez-vous partagés avec rappels et pièces jointes';

  @override
  String get aboutMedication =>
      'Plans de médication avec le relevé de chaque prise';

  @override
  String get aboutEmergencyDiary =>
      'Un carnet partagé pour les crises et les moments importants';

  @override
  String get aboutContacts =>
      'Tes évaluations et notes sur les personnes de ton entourage';

  @override
  String get aboutFinder => 'Retrouver lieux et objets';

  @override
  String get aboutLocalOnly =>
      'Toutes les données restent sur ton appareil — pas de cloud';

  @override
  String get telemetryQuestion => 'Veux-tu aider à améliorer Aurora ?';

  @override
  String get telemetryExplanation =>
      'Aurora peut compter quels espaces sont ouverts et où les parcours s\'interrompent. Seuls le nom de l\'événement, le jour et la version de l\'application sont envoyés — aucun texte, aucun lieu et rien qui remonte jusqu\'à toi. Chaque message part immédiatement : l\'heure de réception est donc aussi l\'heure à laquelle tu as utilisé Aurora.';

  @override
  String get telemetryChangeLater =>
      'Tu peux changer cela à tout moment dans les réglages, sous « Ce qu\'Aurora envoie ». Chaque message parti de ton appareil y figure aussi.';

  @override
  String get transparencyIntroFull =>
      'Ici, tu vois chaque envoi parti de ton appareil — complet et mot pour mot.';

  @override
  String get transparencyIrreversibleFull =>
      'Ce qui a déjà été envoyé ne peut pas être rappelé. Ce n\'est pas rattaché à toi — c\'est aussi pourquoi on ne peut ni le retrouver ni le supprimer.';

  @override
  String get transparencyWaitingForConnection => 'En attente de connexion';

  @override
  String get privacyTitle => 'Politique de confidentialité';

  @override
  String get privacyAtAGlance => 'La confidentialité en bref';

  @override
  String get privacyWhatIsStored => 'Quelles données sont enregistrées ?';

  @override
  String get privacyTransmission => 'Transmission des données';

  @override
  String get privacyDeletion => 'Suppression des données';

  @override
  String get privacyMinors => 'Protection des mineurs';

  @override
  String get privacyChanges => 'Modifications de cette politique';

  @override
  String get privacyClosing => 'Aurora — tes données restent chez toi.';

  @override
  String get mediaImageNotOpened => 'L\'image n\'a pas pu être ouverte';

  @override
  String get mediaVideoNotOpened => 'La vidéo n\'a pas pu être ouverte';

  @override
  String get mediaFromGallery => 'Depuis la galerie';

  @override
  String get mediaPickImage => 'Choisir une image';

  @override
  String get mediaPickVideo => 'Choisir une vidéo';

  @override
  String get transportDirectToDevelopers => 'Directement aux développeurs';

  @override
  String get transportSendFailed =>
      'L\'envoi a échoué. Réessaie plus tard ou envoie-le par e-mail.';

  @override
  String get transportRejected => 'Le serveur a refusé le message.';

  @override
  String get transportUnreachable =>
      'Le serveur n\'est pas joignable pour le moment.';

  @override
  String get transparencyArrived => 'Arrivé';

  @override
  String transparencyNotSent(String reason) {
    return 'Non envoyé : $reason';
  }

  @override
  String get transparencyReasonUnknown => 'raison inconnue';

  @override
  String get transportTryLaterOrEmail =>
      'Réessaie plus tard ou envoie-le par e-mail.';

  @override
  String get transportEmailInstead =>
      'Tu peux envoyer ton retour par e-mail à la place.';

  @override
  String get crashDialogTitle => 'Aurora a planté';

  @override
  String get errorDialogTitle => 'Aurora a repéré un problème';

  @override
  String get errorHelpUsFix => 'Veux-tu nous aider à le corriger ?';

  @override
  String get errorSendingFailed => 'Une erreur est survenue lors de l\'envoi.';

  @override
  String get feedbackContactOptions => 'Comment nous joindre';

  @override
  String get feedbackInvalidEmail => 'Cette adresse e-mail n\'est pas valide';

  @override
  String get feedbackArrived => 'Merci pour ton retour ! Il est bien arrivé.';

  @override
  String get feedbackQueued =>
      'Accepté. Il partira dès que tu seras de nouveau en ligne.';

  @override
  String get feedbackSendFailed => 'L\'envoi a échoué. Réessaie plus tard.';

  @override
  String get profilePickImage => 'Choisir une photo de profil';

  @override
  String get profilePasswordOptional =>
      'Protège ton profil avec un mot de passe (facultatif)';

  @override
  String get profilePasswordOptionalMin =>
      'Protège ton profil avec un mot de passe (facultatif, au moins 4 caractères)';

  @override
  String get thankYouWeReceived =>
      'Nous avons reçu ton rapport et t\'écrirons par e-mail en cas de questions.';

  @override
  String get thankYouWeCheck => 'Nous examinons ton rapport';

  @override
  String get thankYouWeFix => 'Nous travaillons à une solution';

  @override
  String get thankYouYouGetMail =>
      'Tu recevras un e-mail dès que la correction sera prête';

  @override
  String get thankYouNextUpdate =>
      'La correction arrivera avec la prochaine mise à jour';

  @override
  String get mapGpsLoading => 'Chargement du GPS…';

  @override
  String get mapGpsPositionLoading => 'Chargement de la position…';

  @override
  String get mapAllowLocation =>
      'Autorise l\'accès à la position pour te voir sur la carte';

  @override
  String mapLastKnownPosition(String age) {
    return 'La carte montre ta dernière position connue : $age.';
  }

  @override
  String get pwResetThenReplaced =>
      '✓ Ce n\'est qu\'alors que l\'ancien mot de passe est remplacé';

  @override
  String get pwResetCanActivateNow =>
      'Ton nouveau mot de passe peut être activé maintenant';

  @override
  String get pwResetRunningShort => 'Réinitialisation en cours…';

  @override
  String get moodVeryHappy => 'Très heureux';

  @override
  String get moodHappy => 'Heureux';

  @override
  String get moodAnxious => 'Anxieux';

  @override
  String get moodAngry => 'En colère';

  @override
  String get emergencyPositionUnavailable => 'Position non disponible';

  @override
  String get emergencyPositionNoPermission =>
      'Position non disponible (pas d\'autorisation)';

  @override
  String get emergencyMessageSubject => 'Message d\'urgence d\'Aurora';

  @override
  String autoLogoutAfter(int minutes) {
    return 'Déconnexion automatique après $minutes minutes sans activité';
  }

  @override
  String get pwResetBannerReady => 'Mot de passe prêt à activer';

  @override
  String get doodleHistory => 'Parcourir l\'historique';

  @override
  String get doodleDraw => 'Dessiner';

  @override
  String get doodleSendEmptyHint =>
      'Dessine d\'abord — ensuite tu peux envoyer';

  @override
  String get anchorTelemetryNotice =>
      'Le comptage anonyme est actif — ce qu\'Aurora envoie';

  @override
  String get timePhaseMorning => 'le matin';

  @override
  String get timePhaseMidday => 'à midi';

  @override
  String get timePhaseAfternoon => 'l\'après-midi';

  @override
  String get timePhaseEvening => 'le soir';

  @override
  String get timePhaseNight => 'la nuit';

  @override
  String get greetingMorning => 'Bonjour';

  @override
  String get greetingDay => 'Bonjour';

  @override
  String get greetingEvening => 'Bonsoir';

  @override
  String get anchorSwitchProfile => 'Ce n\'est pas moi';

  @override
  String get greetingNight => 'Bonsoir';

  @override
  String get quickTimelineYou => '(Toi)';

  @override
  String todayEvents(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rendez-vous aujourd\'hui',
      one: '1 rendez-vous aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String todayMedications(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count médicaments aujourd\'hui',
      one: '1 médicament aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String workSurfaceActiveProfile(String name) {
    return '$name est là en ce moment';
  }

  @override
  String get doodleUndo => 'Annuler';

  @override
  String get doodleClear => 'Tout effacer';

  @override
  String get finderPersonName => 'Nom de la personne';

  @override
  String get finderPlaceTitle => 'Titre pour ce lieu';

  @override
  String get commonLoading => 'Chargement…';

  @override
  String get puzzleCategoryAnimals => 'Des animaux mignons et apaisants';

  @override
  String get puzzleCategoryWater => 'Mer et eau';

  @override
  String get puzzleCategoryFlowers => 'Fleurs et plantes colorées';

  @override
  String get gpsTrackingOffTap =>
      'Enregistrement désactivé — appuie pour l\'activer';

  @override
  String get gpsTrackingOnTap =>
      'Enregistrement activé — appuie pour le désactiver';

  @override
  String get gpsNoPermissionHint =>
      'Sans l\'autorisation de localisation, Aurora ne peut pas démarrer l\'enregistrement. Tu peux l\'accorder dans les réglages Android, sous Applis → Aurora → Autorisations.';

  @override
  String get settingsCouldNotOpen => 'Les réglages n\'ont pas pu être ouverts.';

  @override
  String get settingsOpenAppSettings => 'Ouvrir les réglages de l\'application';

  @override
  String get gpsWaitingFirstUpdate => 'En attente de la première position…';

  @override
  String get imagePickerOpenCamera => 'Ouvrir l\'appareil photo';

  @override
  String get imagePickerFromGallery => 'Choisir dans la galerie';

  @override
  String get imagePickerAnimalAvatar => 'Choisir un avatar animal';

  @override
  String get animalAvatarDog => 'Chien';

  @override
  String get animalAvatarCat => 'Chat';

  @override
  String get animalAvatarGiraffe => 'Girafe';

  @override
  String get puzzleDragPieces => 'Fais glisser les pièces au bon endroit';

  @override
  String get puzzleTapPieces => 'Déplace les pièces en appuyant dessus';

  @override
  String get feedbackTabSend => 'Envoyer un commentaire';

  @override
  String get pwResetRunningFull =>
      'Tu as défini un nouveau mot de passe il y a peu. Par sécurité, un compte à rebours de 24 heures est en cours.\n\n✓ Ton ANCIEN mot de passe reste actif\n✓ Une fois le délai écoulé, tu pourras activer le nouveau\n✓ Ce n\'est qu\'alors que l\'ancien est remplacé';

  @override
  String get transportRejectedFull =>
      'Le serveur a refusé le message. Envoie-le par e-mail à la place.';

  @override
  String get transportUnreachableFull =>
      'Le serveur n\'est pas joignable pour le moment. Réessaie plus tard ou envoie-le par e-mail.';

  @override
  String transportFailedWithCode(String code) {
    return 'L\'envoi a échoué ($code). Tu peux envoyer ton retour par e-mail à la place.';
  }

  @override
  String get transportNoMailApp =>
      'Aucune application e-mail n\'a pu être ouverte. Tu peux copier le texte et l\'envoyer toi-même.';

  @override
  String get emergencySmsSubject => 'Message d\'urgence d\'Aurora';

  @override
  String get pwResetBannerRunning => 'Réinitialisation en cours';

  @override
  String get puzzleDragHint => 'Fais glisser les pièces au bon endroit';

  @override
  String get puzzleTapHint => 'Déplace les pièces en appuyant dessus';

  @override
  String get medicationConfirm => 'Confirmer';

  @override
  String get medicationAddFirstAsNeeded =>
      'Ajoute ton premier médicament au besoin';

  @override
  String medicationTakenBy(String name) {
    return '✓ Pris par $name';
  }

  @override
  String medicationRefusedBy(String name) {
    return '✗ Refusé par $name';
  }

  @override
  String get imprintPerLaw =>
      'Mentions légales selon le § 5 TMG (loi allemande)';

  @override
  String get imprintResponsible => 'Responsable du contenu';

  @override
  String get timelineSkipped => 'sauté';

  @override
  String get timelineDueSoon => 'Bientôt';

  @override
  String get medicationLater => 'plus tard';

  @override
  String get debugLogHint =>
      'Ce rapport contient des détails techniques sur l\'application. Copie-le avec le bouton en haut à droite pour l\'envoyer en cas de problème.';

  @override
  String get unsavedChangesTitle => 'Modifications non enregistrées';

  @override
  String get hotlineForYoung => 'Pour les enfants et les jeunes';

  @override
  String get hotlineAnonymousFree => 'Gratuit et anonyme';

  @override
  String get hotlineHoursNumberAgainstSorrow => 'Lun–Sam 14h–20h';

  @override
  String get hotlineInfoNotAcute => 'Informations, pas d\'aide d\'urgence';

  @override
  String get hotlineHoursDepressionInfo =>
      'Lun, Mar, Jeu 13h–17h · Mer, Ven 8h30–12h30';

  @override
  String get hotlineChatUnder25 => 'Conseil par chat, pour les moins de 25 ans';

  @override
  String get helpEmergencyDangerTitle => 'Si quelqu\'un est en danger immédiat';

  @override
  String get helpEmergencyDangerBody =>
      'Le numéro d\'urgence fonctionne jour et nuit, même sans crédit.';

  @override
  String get helpEmergencyCallEmergencyNumber => 'Urgences 112';

  @override
  String get helpTalkTitle => 'Si tu as besoin de parler ou d\'un conseil';

  @override
  String get helpGroupRoundTheClock => 'Joignable 24h/24';

  @override
  String get helpGroupLimitedHours => 'Joignable à certaines heures';

  @override
  String helpSourcesCheckedOn(String datum) {
    return 'Informations vérifiées le $datum';
  }

  @override
  String get cameraCouldNotOpen => 'L\'appareil photo n\'a pas pu être ouvert';

  @override
  String get feedbackDeviceDiagnostics => '--- Diagnostic de l\'appareil ---';

  @override
  String get eventNoReminder =>
      'Le rendez-vous n\'est que dans le calendrier. Aurora ne se manifestera pas d\'elle-même.';

  @override
  String get unsavedChangesMessage =>
      'Tu as fait des modifications.\n\nVeux-tu les enregistrer ?';

  @override
  String get confirmSave => 'Enregistrer';

  @override
  String get videoCouldNotLoad => 'La vidéo n\'a pas pu être chargée';

  @override
  String get finderDaily => 'chaque jour';

  @override
  String get mapNotAvailable => 'Carte non disponible';

  @override
  String get medicationAnotherDose =>
      'Veux-tu quand même prendre une dose de plus ?';

  @override
  String get feedbackThankYouReceived =>
      'Nous avons reçu ton retour et t\'écrirons par e-mail en cas de questions.';

  @override
  String get positionAgeYesterday => 'd\'hier';

  @override
  String get timePickerTitle => 'Choisir l\'heure';

  @override
  String get reminderPermissionMissingTitle =>
      'Aurora ne peut pas te le rappeler pour l\'instant';

  @override
  String reminderPermissionMissingBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Les rappels sont activés pour $count heures de prise. Sans l\'autorisation de l\'appareil, aucun n\'arrive.',
      one:
          'Les rappels sont activés pour une heure de prise. Sans l\'autorisation de l\'appareil, il n\'arrivera pas.',
    );
    return '$_temp0';
  }

  @override
  String get reminderPermissionMissingAction => 'Donner l\'autorisation';

  @override
  String get timePickerHours => 'Heures';

  @override
  String get timePickerMinutes => 'Minutes';

  @override
  String get commentsNoneYet => 'Pas encore de commentaires';

  @override
  String get notificationDiscreetBody => 'Rappel — appuie pour voir';

  @override
  String get reminderNoPermission =>
      'Sans l autorisation de notification, Aurora ne peut pas te le rappeler. Tu peux l accorder dans les réglages Android, sous Applis → Aurora → Notifications.';

  @override
  String get telemetryConsentAccept => 'Oui, volontiers';

  @override
  String get telemetryConsentDecline => 'Continuer sans';

  @override
  String get transparencyGroupTelemetry => 'Télémétrie';

  @override
  String get telemetryExampleIntro => 'Voici à quoi ressemble un message :';

  @override
  String get telemetryExampleEvent => 'Événement';

  @override
  String get telemetryExampleDay => 'Jour';

  @override
  String get telemetryExampleVersion => 'Version de l\'app';

  @override
  String get onboardingDismiss => 'Ne plus afficher';

  @override
  String get eventStart => 'Début';

  @override
  String get eventEnd => 'Fin';

  @override
  String get chatCapturePhoto => 'Prendre une photo';

  @override
  String get chatCaptureImageShort => 'Photo';

  @override
  String get doodleErase => 'Gommer';

  @override
  String get chatRecordVideo => 'Enregistrer une vidéo';

  @override
  String get chatRecordVideoSubtitle => 'Créer une nouvelle vidéo';

  @override
  String get actionDiscard => 'Jeter';

  @override
  String get actionKeep => 'Garder';

  @override
  String get actionDetails => 'Détails';

  @override
  String get resetWaitingPeriodTitle =>
      'Délai d’attente pour la réinitialisation';

  @override
  String get fieldNameHint => 'p. ex. Max, Anna, Léo';

  @override
  String get fieldPasswordHint => '4 caractères au minimum';

  @override
  String get fieldPasswordConfirmHint => 'Répéter le mot de passe';

  @override
  String get fieldPasswordEnterHint => 'Saisis le mot de passe';

  @override
  String get feedbackCommunityJoin => 'Rejoins notre communauté';

  @override
  String get feedbackDiscord => 'Serveur Discord';

  @override
  String get feedbackGithub => 'GitHub';

  @override
  String get feedbackGithubSubtitle => 'Bugs et tickets';

  @override
  String get timelineProfileSwitch => 'Changement de profil';

  @override
  String get debugLogReportTitle => 'Rapport de diagnostic';

  @override
  String get formPickImage => 'Choisir une image';

  @override
  String get permissionGrant => 'Accorder l’autorisation';

  @override
  String get pwResetRestart => 'Relancer';

  @override
  String get navBackToAnchor => 'Vers l’ancre';

  @override
  String get mapGpsPositionLoadingHint => 'Un instant';

  @override
  String get voiceRecordingStartFailed =>
      'L’enregistrement n’a pas pu démarrer';

  @override
  String get voiceRecordingStopFailed =>
      'L’enregistrement n’a pas pu être arrêté';

  @override
  String get voiceRecordingDiscardFailed =>
      'L’enregistrement n’a pas pu être jeté';

  @override
  String get trackingPermissionDeniedHint =>
      'Autorisation de position refusée. Active-la dans les réglages.';

  @override
  String get pwResetVisibleToAll => 'Le délai court à la vue de tout le monde';

  @override
  String get pwResetRestartResetsTimer =>
      'À noter : relancer remet le délai à zéro';

  @override
  String get pwResetActivatedAtNextLogin =>
      'Le nouveau mot de passe s’active à la prochaine connexion';

  @override
  String get imagePickerCameraDeniedForever =>
      'L’autorisation d’accès à la caméra a été refusée définitivement. Active-la dans les réglages.';

  @override
  String get imagePickerGalleryDeniedForever =>
      'L’autorisation d’accès à la galerie a été refusée définitivement. Active-la dans les réglages.';

  @override
  String get permissionCameraTitle => 'Autorisation caméra';

  @override
  String get permissionGalleryTitle => 'Autorisation galerie';

  @override
  String get profileResetFristExplanation =>
      'C’est le temps qu’attend une réinitialisation de mot de passe avant de prendre effet. Si tu te connectes pendant ce délai, elle est annulée.';

  @override
  String get cameraNotFound => 'Aucune caméra trouvée';

  @override
  String get validationNameRequired => 'Saisis un nom';

  @override
  String get validationPasswordRequired => 'Saisis le mot de passe';

  @override
  String get transportCopyManually =>
      'Tu peux copier le texte et l’envoyer toi-même.';

  @override
  String get statusSending => 'Envoi...';

  @override
  String get errorReportSendButton => 'Envoyer le rapport';

  @override
  String get settingsGpsStatusAlwaysReady => '✅ Toujours autorisée (prêt !)';

  @override
  String get gpsActive => 'GPS actif';

  @override
  String get gpsOff => 'GPS éteint';

  @override
  String get gpsStatusUnknown => 'État du GPS inconnu';

  @override
  String get gpsPermissionMissing => 'Autorisation de position manquante';

  @override
  String get gpsServiceDisabled => 'Service de position désactivé';

  @override
  String get permissionMissingShort => 'Autorisation manquante';

  @override
  String get pwResetWrongPassword => 'Mot de passe incorrect';

  @override
  String get pwResetStartTitle => 'Lancer la réinitialisation ?';

  @override
  String get pwResetExpired => 'Le délai est écoulé';

  @override
  String get pwResetForgotPassword => 'Mot de passe oublié ?';

  @override
  String get commentWritePlaceholder => 'Écris un commentaire...';

  @override
  String get profileVisibilityTitle => 'À quels profils cela appartient';

  @override
  String get addressUnknown => 'Adresse inconnue';

  @override
  String get activateNow => 'Activer maintenant';

  @override
  String get eventRemindMe => 'Rappel';

  @override
  String get noProfileAvailable => 'Pas encore de profil';

  @override
  String get ratingVeryNegative => 'Très négatif';

  @override
  String get ratingVeryPositive => 'Très positif';

  @override
  String get errorReportHelpUs => 'Aide-nous à corriger le problème';

  @override
  String get errorReportDetailsSection => 'Détails du rapport';

  @override
  String get trackingLabel => 'Suivi GPS : ';

  @override
  String trackingLastUpdate(Object time) {
    return 'Dernière mise à jour : $time';
  }

  @override
  String profileSwitchError(Object error) {
    return 'Impossible de changer de profil : $error';
  }

  @override
  String get gpsError => 'Erreur GPS';

  @override
  String get statusActive => 'Actif';

  @override
  String get statusPaused => 'En pause';

  @override
  String timeSecondsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count secondes',
      one: 'il y a une seconde',
    );
    return '$_temp0';
  }

  @override
  String timeInMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dans $count minutes',
      one: 'dans une minute',
    );
    return '$_temp0';
  }

  @override
  String timeInHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dans $count heures',
      one: 'dans une heure',
    );
    return '$_temp0';
  }

  @override
  String timeInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dans $count jours',
      one: 'dans un jour',
    );
    return '$_temp0';
  }

  @override
  String get languageFollowApp => 'Langue de l\'application';

  @override
  String get profileLanguageSubtitle =>
      'La langue dans laquelle Aurora parle à cette part';

  @override
  String get contactCategoryFamily => 'Famille';

  @override
  String get contactCategoryFriends => 'Amis';

  @override
  String get contactCategoryTherapists => 'Thérapeutes';

  @override
  String get contactCategoryDoctors => 'Médecins';

  @override
  String get contactCategoryEmergency => 'Urgence';

  @override
  String get contactCategoryOther => 'Autre';

  @override
  String get finderTypeLocation => 'Lieu';

  @override
  String get finderTypeItem => 'Objet';

  @override
  String get diaryPriorityLow => 'Faible';

  @override
  String get diaryPriorityMedium => 'Moyenne';

  @override
  String get diaryPriorityHigh => 'Élevée';

  @override
  String get diaryPriorityCritical => 'Critique';

  @override
  String get moodNeutral => 'Neutre';

  @override
  String get moodSad => 'Triste';

  @override
  String get moodVerySad => 'Très triste';

  @override
  String get moodExcited => 'Excité';

  @override
  String timeHoursMinutesAgo(Object hours, Object minutes) {
    return 'il y a $hours h $minutes min';
  }

  @override
  String presenceLastFront(Object when) {
    return 'dernière fois $when';
  }

  @override
  String get privacyGlanceBody =>
      'Aurora conserve tout sur ton appareil. Trois choses en sortent, et seulement si tu les déclenches ou les autorises : les retours que tu envoies, la télémétrie après ton accord, et les requêtes de cartes vers OpenStreetMap.\n\nCe qui a été envoyé et quand figure mot pour mot dans les Réglages, sous « Ce qu’Aurora envoie ». Rien de tout cela ne remonte jusqu’à toi.';

  @override
  String get privacyStoredBody =>
      'Ces données se trouvent dans la base locale de ton appareil :\n\n• Parts et réglages\n• Messages entre les parts\n• Rendez-vous de l’agenda\n• Plans de médication et prises\n• Entrées du journal et d’urgence\n• Contacts avec évaluations et notes\n• Lieux et objets du chercheur\n• Historique de position et changements de part\n• Images, vidéos et messages vocaux\n\nRien de tout cela n’est transmis.';

  @override
  String get privacyTransmissionBody =>
      'Retours — uniquement quand tu envoies le formulaire. Ils contiennent ton texte, la version de l’app et le modèle de l’appareil. Aucun nom, aucun identifiant, aucun lieu.\n\nTélémétrie — uniquement après ton accord explicite, que tu peux retirer à tout moment. Un événement porte trois champs : ce qui s’est passé, quel jour, avec quelle version de l’app. Pas d’heure, pas d’identifiant.\n\nCartes — à l’affichage d’une carte et à la résolution d’une adresse, la portion de carte visible et ton adresse IP partent vers OpenStreetMap. C’est la condition pour qu’il y ait une carte.\n\nJamais transmis : historique de position, parts, messages, rendez-vous, médicaments, journal et contacts.';

  @override
  String get privacyPermissions => 'Autorisations';

  @override
  String get privacyPermissionsBody =>
      '• Position — pour la carte, l’historique de position et l’écran d’urgence. Elle reste sur l’appareil.\n• Position en arrière-plan — seulement si tu actives l’enregistrement continu. Sans cet interrupteur, elle est inutile.\n• Appareil photo et micro — pour les photos et les messages vocaux.\n• Stockage — pour charger images et vidéos depuis ta galerie.\n• Notifications et alarmes — pour les rappels de médicaments et de rendez-vous.\n\nChaque autorisation peut être retirée dans les réglages du système. L’app dira alors ce qui ne fonctionne plus.';

  @override
  String get privacySecurity => 'Sécurité des données';

  @override
  String get privacySecurityBody =>
      '• Toutes les données sont locales ; il n’y a aucune synchronisation dans le nuage.\n• Les parts peuvent être protégées par un mot de passe.\n• Il n’y a ni compte utilisateur ni connexion.\n\nLes sauvegardes sont ta responsabilité. Si l’appareil est perdu ou cassé, les données le sont aussi — c’est le prix de leur absence ailleurs.';

  @override
  String get privacyDeletionBody =>
      '• Tu peux supprimer des entrées et des messages isolés.\n• Les parts peuvent être désactivées ou supprimées.\n• Les Réglages proposent « Supprimer toutes les données ».\n• Désinstaller l’app emporte tout avec elle.\n\nCe qui est supprimé ne peut pas être récupéré.';

  @override
  String get privacyRights => 'Tes droits';

  @override
  String get privacyRightsBody =>
      'Le RGPD te donne droit à l’accès, à la rectification, à l’effacement, à la limitation, à la portabilité et à l’opposition. Comme toutes les données sont sur ton appareil, tu exerces la plupart de ces droits directement dans l’app.\n\nPour les retours envoyés et pour la télémétrie, adresse-toi à l’adresse ci-dessous. Tu as aussi le droit d’introduire une réclamation auprès d’une autorité de protection des données.';

  @override
  String get privacyMinorsBody =>
      'Aurora peut être utilisée par des mineurs. Aucune donnée les concernant n’est collectée qui ne le soit pour n’importe qui d’autre — c’est-à-dire aucune, hormis les trois voies nommées plus haut.\n\nPour les plus jeunes, il est judicieux qu’un adulte responsable accompagne la configuration.';

  @override
  String get privacyChangesBody =>
      'Cette déclaration peut évoluer avec les mises à jour de l’app. La version en vigueur est celle affichée ici et porte sa date en bas.';

  @override
  String get privacyContact => 'Responsable et contact';

  @override
  String privacyAsOf(Object date) {
    return 'Mise à jour : $date';
  }

  @override
  String get startupFailedTitle => 'Aurora n\'a pas pu démarrer';

  @override
  String get startupFailedBody =>
      'Un problème est survenu au démarrage. Tu peux réessayer. Si cela ne suffit pas, toutes les données enregistrées peuvent être supprimées — Aurora redémarrera vide.';

  @override
  String get startupRetry => 'Réessayer';

  @override
  String get startupDeleteAll => 'Supprimer toutes les données';

  @override
  String get startupDeleteIncomplete =>
      'Tout n\'a pas pu être supprimé. Une partie est encore là.';

  @override
  String get reminderPermissionBlocked =>
      'Aurora n\'a pas encore le droit de te rappeler. L\'autorisation se donne dans les réglages du système.';

  @override
  String get reminderOpenSettings => 'Ouvrir les réglages';

  @override
  String get settingsTrackingPermissionNeeded =>
      'Pour retenir ton chemin, Aurora a besoin d\'accéder à la localisation.';

  @override
  String get settingsHowToEnableLocation =>
      'Comment autoriser la localisation :';

  @override
  String get settingsStepChooseWhileUsing =>
      'Choisis « Lorsque l\'app est utilisée »';

  @override
  String get settingsTrackingNotice =>
      'Tant qu\'Aurora enregistre, une notification reste dans la barre. Pas de notification, pas d\'enregistrement.';

  @override
  String get locationTrackingNotificationTitle => 'Aurora retient ton chemin';

  @override
  String get locationTrackingNotificationBody =>
      'Pour que tu puisses retrouver tes lieux plus tard. Reste sur l\'appareil.';

  @override
  String profileContinueAs(String name) {
    return 'Continuer en tant que $name';
  }

  @override
  String get profileContinueInProgress => 'Un instant …';

  @override
  String get trackingPausedTitle => 'Enregistrement en pause';

  @override
  String get trackingPausedBody =>
      'Après le redémarrage, Aurora n\'enregistre à nouveau ton trajet qu\'une fois ouverte. Appuie ici.';

  @override
  String get aboutAuroraSemantics => 'À propos d\'Aurora';

  @override
  String get openTimelineSemantics => 'Ouvrir la chronologie';

  @override
  String get timeMapSemantics =>
      'Ouvrir la chronologie : carte avec heure et lieu';
}
