// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Aurora';

  @override
  String get appSubtitle =>
      'La tua compagna sicura nella vita di ogni giorno con il DID';

  @override
  String get appDescription =>
      'Aurora ti accompagna a organizzare le tue giornate e la comunicazione dentro il tuo sistema.';

  @override
  String get tabChat => 'Chat';

  @override
  String get tabFeedback => 'Riscontri';

  @override
  String get tabCalendar => 'Calendario';

  @override
  String get tabMedication => 'Farmaci';

  @override
  String get tabDiary => 'Diario';

  @override
  String get tabContacts => 'Contatti';

  @override
  String get tabFinder => 'Ritrova';

  @override
  String get tabEmergency => 'Emergenza';

  @override
  String get tabHelp => 'Aiuto';

  @override
  String get tabMantras => 'Mantra';

  @override
  String get tabGames => 'Giochi';

  @override
  String get tabTimeline => 'Linea del tempo';

  @override
  String get actionSave => 'Salva';

  @override
  String get actionCancel => 'Annulla';

  @override
  String get actionDelete => 'Elimina';

  @override
  String get actionEdit => 'Modifica';

  @override
  String get actionClose => 'Chiudi';

  @override
  String get actionContinue => 'Continua';

  @override
  String get actionConfirm => 'Conferma';

  @override
  String get actionBack => 'Indietro';

  @override
  String get actionQuit => 'Esci';

  @override
  String get actionSend => 'Invia';

  @override
  String get actionShare => 'Condividi';

  @override
  String get actionDone => 'Fatto';

  @override
  String get mainSettingLogout => 'Impostazioni / Esci';

  @override
  String get dialogExitTitle => 'Uscire dall’app?';

  @override
  String get dialogExitMessage => 'Vuoi davvero uscire da Aurora?';

  @override
  String get menuProfileEdit => 'Modifica profilo';

  @override
  String get menuSettings => 'Impostazioni';

  @override
  String get menuLogout => 'Esci';

  @override
  String get profileMenuTitle => 'Profilo e impostazioni';

  @override
  String get presenceRecentTitle => 'Chi c\'era?';

  @override
  String get eventLocationTitle => 'Dove si svolge?';

  @override
  String get eventLocationOther => 'Un altro luogo';

  @override
  String get eventLocationNone => 'Nessun luogo';

  @override
  String get eventLocationLabel => 'Luogo';

  @override
  String get eventLocationUnnamed => 'Luogo sulla mappa';

  @override
  String get mapLocationNeeded =>
      'Aurora ha bisogno della tua posizione per questa mappa. Resta sul dispositivo.';

  @override
  String get mapLocationAllow => 'Consenti';

  @override
  String get profileSelectionTitle => 'Chi c\'è in questo momento?';

  @override
  String get profileNewProfile => 'Nuovo profilo';

  @override
  String get profileCreationTitle => 'Crea un nuovo profilo';

  @override
  String get profileCreationSubtitle => 'Chi ha voglia di presentarsi?';

  @override
  String get profileCreationDescription =>
      'Crea il tuo profilo con nome, colore e avatar. Ogni profilo si imposta per conto suo e riceve permessi adatti all’età.';

  @override
  String get profileEditTitle => 'Modifica profilo';

  @override
  String get profileEditSubtitle => 'Sistema le tue impostazioni';

  @override
  String get profileSectionIdentity => '👤 Identità';

  @override
  String get profileSectionAge => '🎂 Età';

  @override
  String get profileSectionColor => '🎨 Colore';

  @override
  String get profileSectionSecurity => '🔒 Domande di sicurezza';

  @override
  String get profileWhoAreYou => 'Chi sei?';

  @override
  String get profileWhoAreYouDescription =>
      'Scrivi il tuo nome e scegli un avatar. Così tutti nel sistema possono riconoscerti e distinguerti. Puoi anche scattare una foto, sceglierne una dalla galleria o usare uno degli animaletti.';

  @override
  String get profileColorTitle => 'Il tuo colore';

  @override
  String get profileColorDescription =>
      'Il tuo colore ti rende inconfondibile nel sistema.';

  @override
  String get profileAgeTitle => 'Quanti anni hai?';

  @override
  String get profileAgeDescription =>
      'La tua età decide quali funzioni puoi usare.';

  @override
  String get profileSecurityTitle => 'Proteggi il tuo profilo';

  @override
  String get profileSecurityDescription =>
      'Se vuoi, puoi mettere una password (almeno 4 caratteri).';

  @override
  String get profilePasswordOptionalInfo =>
      'La password è facoltativa. Lascia i campi vuoti se non ne vuoi una.';

  @override
  String get profileModeChild => 'Modalità bambin*';

  @override
  String get profileModeFullAccess => 'Accesso completo';

  @override
  String get profileModeChildDescription =>
      'Accesso a: Chat (disegni), Diario, Giochi, Linea del tempo';

  @override
  String get profileModeFullDescription =>
      'Accesso a: tutte le funzioni (Chat, Calendario, Contatti, Farmaci, ecc.)';

  @override
  String get profileActionSaveChanges => 'Salva le modifiche';

  @override
  String get profileActionCreateProfile => 'Crea il profilo ✓';

  @override
  String get profileDeactivateTitle => 'Disattivare il profilo?';

  @override
  String profileDeactivateMessage(String name) {
    return 'Vuoi disattivare il profilo «$name»?\n\nSarà nascosto, ma potrai riattivarlo più avanti.';
  }

  @override
  String get profileDeactivated => 'Profilo disattivato';

  @override
  String get profileDeactivate => 'Disattiva';

  @override
  String get profileEditComingSoon => 'La modifica arriverà presto';

  @override
  String get profileNameExists => 'Esiste già un profilo con questo nome';

  @override
  String get fieldName => 'Nome';

  @override
  String get fieldPassword => 'Password';

  @override
  String get fieldPasswordConfirm => 'Ripeti la password';

  @override
  String get fieldAge => 'Età';

  @override
  String get fieldColor => 'Colore';

  @override
  String get fieldAvatar => 'Avatar';

  @override
  String get validationRequired => 'Campo obbligatorio';

  @override
  String get validationPasswordLength => 'Almeno 4 caratteri';

  @override
  String get validationPasswordMismatch => 'Le password non coincidono';

  @override
  String errorGeneric(String error) {
    return 'Errore: $error';
  }

  @override
  String get errorNoProfile => 'Nessun profilo selezionato';

  @override
  String get errorNoPermission =>
      'Non hai il permesso di inviare messaggi in chat';

  @override
  String get chatTitle => 'Chat';

  @override
  String get chatEmptyTitle => 'Ancora nessun messaggio';

  @override
  String get chatEmptySubtitle => 'Condividi quello che pensi con il sistema';

  @override
  String get chatMessageDoodle => '[Disegno]';

  @override
  String get chatMessageVoice => '[Messaggio vocale]';

  @override
  String get chatMessageImage => '[Immagine]';

  @override
  String get chatMessageVideo => '[Video]';

  @override
  String chatErrorSending(String error) {
    return 'Errore nell’invio: $error';
  }

  @override
  String chatErrorSendingVoice(String error) {
    return 'Errore nell’invio del messaggio vocale: $error';
  }

  @override
  String chatErrorSendingImage(String error) {
    return 'Errore nell’invio dell’immagine: $error';
  }

  @override
  String chatErrorSendingVideo(String error) {
    return 'Errore nell’invio del video: $error';
  }

  @override
  String chatErrorSendingDoodle(String error) {
    return 'Errore nell’invio: $error';
  }

  @override
  String get chatRecordingInProgress => 'Registrazione in corso...';

  @override
  String get chatRecordingHint => 'Tocca Stop per inviare il messaggio vocale';

  @override
  String get chatRecordingStop => 'Stop';

  @override
  String get chatErrorMicPermission =>
      'Serve l\'autorizzazione per il microfono';

  @override
  String get chatErrorRecordingStart => 'Impossibile avviare la registrazione';

  @override
  String get chatInputHint => 'Scrivi un messaggio...';

  @override
  String get chatMessageFieldLabel => 'Messaggio';

  @override
  String get chatAddMedia => 'Aggiungi altri contenuti';

  @override
  String get chatSendMessage => 'Invia messaggio';

  @override
  String get chatMediaSheetTitle => 'Aggiungi contenuti';

  @override
  String get chatNoPermissionHint => 'Nessuna autorizzazione per inviare';

  @override
  String get calendarTitle => 'Calendario';

  @override
  String get medicationTitle => 'Farmaci';

  @override
  String get medicationNewTitle => 'Nuovo farmaco';

  @override
  String get medicationEditTitle => 'Modifica farmaco';

  @override
  String get medicationDetailTitle => 'Dettagli del farmaco';

  @override
  String get medicationNotFound => 'Farmaco non trovato';

  @override
  String get medicationNotFoundMessage => 'Questo farmaco non esiste più';

  @override
  String get medicationTabDaily => 'Farmaci quotidiani';

  @override
  String get medicationTabAsNeeded => 'Farmaci al bisogno';

  @override
  String get medicationEmptyTitle => 'Nessun farmaco 💊';

  @override
  String get medicationEmptySubtitle => 'Aggiungi il tuo primo farmaco';

  @override
  String get medicationEmptyAsNeededTitle => 'Nessun farmaco al bisogno 🩹';

  @override
  String get medicationEmptyAsNeededSubtitle =>
      'Aggiungi il tuo primo farmaco al bisogno';

  @override
  String get medicationToday => 'Oggi';

  @override
  String get medicationStatMedications => 'Farmaci';

  @override
  String get medicationStatDoses => 'Dosi';

  @override
  String medicationMarkedTaken(String name) {
    return '$name segnato come preso';
  }

  @override
  String medicationMarkedRefused(String name) {
    return '$name segnato come rifiutato';
  }

  @override
  String get medicationRefusalDialogTitle => 'Annotare il rifiuto';

  @override
  String medicationRefusalDialogMessage(String name) {
    return '$name sarà segnato come rifiutato.';
  }

  @override
  String get medicationRefusalReasonLabel => 'Motivo (facoltativo)';

  @override
  String get medicationRefusalReasonHint => 'p. es. nausea, stanchezza, ecc.';

  @override
  String get medicationRefusalWithoutNote => 'Senza nota';

  @override
  String get medicationFeedbackDialogTitle => 'Aggiungi una nota';

  @override
  String medicationFeedbackQuestion(String name) {
    return 'Come ti sei sentit* dopo aver preso $name?';
  }

  @override
  String get medicationFeedbackLabel => 'Come è andata';

  @override
  String get medicationFeedbackHint =>
      'p. es. «mi ha messo sonno», «mi ha aiutato molto», ecc.';

  @override
  String get medicationFeedbackSaved => 'Nota salvata';

  @override
  String get medicationFeedbackViewTitle => 'Note';

  @override
  String get diaryTitle => 'Diario';

  @override
  String get diaryEmptyTitle => 'Il tuo diario ti aspetta! ✨';

  @override
  String get diaryEmptySubtitle =>
      'Raccogli i tuoi pensieri, le tue esperienze e i tuoi momenti';

  @override
  String get contactsTitle => 'Contatti';

  @override
  String get contactsFilterAll => 'Tutti';

  @override
  String get contactsEmptyTitle => 'Ancora nessun contatto 👥';

  @override
  String get contactsEmptySubtitle => 'Tocca + per aggiungere un contatto';

  @override
  String get contactsEmptyFilteredTitle => 'Nessun contatto trovato 🔍';

  @override
  String get contactsEmptyFilteredSubtitle => 'Prova con un altro filtro';

  @override
  String get finderTitle => 'Ritrova';

  @override
  String get finderTabLocations => 'Luoghi';

  @override
  String get finderTabItems => 'Oggetti';

  @override
  String get finderEmptyLocationsTitle => 'Ancora nessun luogo';

  @override
  String get finderEmptyItemsTitle => 'Ancora nessun oggetto';

  @override
  String get finderEmptyLocationsSubtitle => 'Tocca + per aggiungere un luogo';

  @override
  String get finderEmptyItemsSubtitle => 'Tocca + per aggiungere un oggetto';

  @override
  String get emergencyTitle => 'Emergenza';

  @override
  String get emergencyEmptyTitle => 'Ancora nessun contatto di emergenza';

  @override
  String get emergencyEmptySubtitle =>
      'Aggiungi contatti con la categoria «Emergenza» per vederli qui.';

  @override
  String get emergencyEmptyDescription =>
      'Questi contatti possono essere avvisati in fretta in caso di emergenza.';

  @override
  String get emergencyEmptyAddContact => 'Aggiungi contatto di emergenza';

  @override
  String get emergencyEmptyOpenHelp => 'Aiuto e numeri di emergenza';

  @override
  String get emergencySendSmsAll => 'Invia un SMS di EMERGENZA a tutti';

  @override
  String get emergencyShareAll => 'Invia a tutti tramite l’app';

  @override
  String get emergencySmsDialogTitle => 'Inviare un SMS di EMERGENZA a tutti?';

  @override
  String emergencySmsDialogMessage(int count) {
    return 'Il messaggio di emergenza sarà inviato a $count contatti.';
  }

  @override
  String get emergencySendNow => 'Invia ora';

  @override
  String get emergencyMessagePreparing =>
      'Preparo il messaggio di emergenza...';

  @override
  String emergencyErrorSms(String error) {
    return 'Errore nell’invio dell’SMS: $error';
  }

  @override
  String emergencyErrorShare(String error) {
    return 'Errore nella condivisione: $error';
  }

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsSectionDebug => '🔧 Opzioni di sviluppo';

  @override
  String get settingsDebugInfo =>
      'Queste opzioni si vedono solo durante lo sviluppo';

  @override
  String get settingsDebugSkipCooldown => '⏩ Imposta il timer su 20 s';

  @override
  String settingsDebugSkipCooldownInfo(String name, String time) {
    return 'Profilo: $name\nMancano: $time';
  }

  @override
  String get settingsDebugCooldownSet =>
      '⏩ Timer impostato su 20 secondi!\nDopo 20 s la password può essere attivata.';

  @override
  String get settingsDebugCooldownError => '❌ Errore nell’impostare il timer';

  @override
  String get settingsDeleteAllData => 'Elimina tutti i dati';

  @override
  String get settingsDeleteAllDataSubtitle =>
      'Elimina tutti i profili, i messaggi, gli eventi e gli allegati';

  @override
  String get settingsDeleteConfirmTitle => '⚠️ Attenzione';

  @override
  String get settingsDeleteConfirmMessage =>
      'Questa azione eliminerà TUTTI i dati:\n\n• Tutti i profili\n• Tutti i messaggi in chat\n• Tutti gli eventi del calendario\n• Tutti i farmaci e il registro delle assunzioni\n• Tutti i contatti\n• Tutti gli oggetti da ritrovare\n• Tutte le voci del diario delle crisi\n• Tutti i dati di navigazione\n• Tutte le impostazioni\n• Tutti i disegni allegati\n\nNON si può tornare indietro!';

  @override
  String get settingsDeleteSuccess => '✅ Tutti i dati sono stati eliminati';

  @override
  String get settingsSectionManagement => 'Amministrazione';

  @override
  String get settingsPermissions => 'Diritti e permessi';

  @override
  String get settingsPermissionsSubtitle =>
      'Gestisci i diritti di accesso dei profili';

  @override
  String get settingsSectionGlobal => 'Impostazioni globali';

  @override
  String get settingsGlobalTrackingInfo => 'Cos’è il «rilevamento permanente»?';

  @override
  String get settingsGlobalTrackingDescription =>
      'Come amministratrice puoi comandare il GPS di TUTTI i profili da un unico posto. Quando è attivo:';

  @override
  String get settingsGlobalTrackingBullet1 =>
      'La posizione viene registrata di continuo';

  @override
  String get settingsGlobalTrackingBullet2 => 'Funziona in secondo piano';

  @override
  String get settingsGlobalTrackingBullet3 =>
      'Ha la precedenza sulle impostazioni dei singoli profili';

  @override
  String get settingsGlobalTrackingBullet4 =>
      'Tutti i profili vengono rilevati in automatico';

  @override
  String get settingsGlobalTrackingRequirement =>
      'Requisito: il permesso Android «Consenti sempre» deve essere attivo perché il rilevamento funzioni ad app chiusa.';

  @override
  String get settingsGpsPermissionTitle => 'Permesso GPS';

  @override
  String get settingsGpsStatusDisabled => 'Servizio GPS disattivato';

  @override
  String get settingsGpsStatusDenied => 'Permesso negato';

  @override
  String get settingsGpsStatusDeniedForever => 'Negato per sempre';

  @override
  String get settingsGpsStatusWhileInUse => 'Solo mentre usi l’app';

  @override
  String get settingsGpsStatusAlways => 'Sempre consentito ✓';

  @override
  String get settingsGpsStatusUnknown => 'Sconosciuto';

  @override
  String get settingsGpsReady =>
      'Perfetto! Il rilevamento in secondo piano è pronto.';

  @override
  String get settingsGpsInstructions => 'Come attivare «Consenti sempre»:';

  @override
  String get settingsGpsStep1 => 'Tocca «Apri le impostazioni di Android» ↓';

  @override
  String get settingsGpsStep2 => 'Scegli «Permessi» → «Posizione»';

  @override
  String get settingsGpsStep3 => 'Scegli «Consenti sempre»';

  @override
  String get settingsGpsOpenSettings => 'Apri le impostazioni di Android';

  @override
  String get settingsGpsOpenLocationSettings =>
      'Apri le impostazioni di posizione';

  @override
  String get settingsGpsPrivacyNote =>
      'La tua posizione resta su questo dispositivo. Le mappe la passano a OpenStreetMap, mai a noi.';

  @override
  String get settingsTrackingPermanent => 'Rilevamento permanente';

  @override
  String get settingsTrackingPermanentOn =>
      'Il GPS resta acceso per tutti i profili';

  @override
  String get settingsTrackingPermanentOff =>
      'Il GPS solo quando serve, profilo per profilo';

  @override
  String get settingsTrackingPermissionRequired =>
      'Serve l\'autorizzazione alla posizione';

  @override
  String get settingsTrackingEnabled => '✅ Rilevamento permanente attivato';

  @override
  String get settingsTrackingDisabled => '✅ Rilevamento permanente disattivato';

  @override
  String get settingsSectionLegal => 'Note legali';

  @override
  String get settingsImpressum => 'Note legali';

  @override
  String get settingsImpressumSubtitle => 'Informazioni legali';

  @override
  String get settingsPrivacy => 'Informativa sulla privacy';

  @override
  String get settingsPrivacySubtitle => 'Come proteggiamo i tuoi dati';

  @override
  String get settingsAppVersion => 'Versione dell’app';

  @override
  String get settingsSectionDiagnostics => 'Diagnostica e supporto';

  @override
  String get settingsDebugLog => 'Genera un rapporto diagnostico';

  @override
  String get settingsDebugLogSubtitle =>
      'Crea informazioni tecniche da condividere';

  @override
  String settingsDebugLogError(String error) {
    return '❌ Errore nel generare il rapporto: $error';
  }

  @override
  String get settingsSectionNotifications => 'Notifiche';

  @override
  String get settingsNotificationsSubtitle =>
      'Promemoria per farmaci e appuntamenti';

  @override
  String get settingsNotificationsInfo => 'Come funzionano le notifiche?';

  @override
  String get settingsNotificationsBullet1 =>
      'Farmaci quotidiani: -30 min, -10 min, 0 min e ripetizioni ogni +10 min';

  @override
  String get settingsNotificationsBullet2 =>
      'Farmaci al bisogno: promemoria di disponibilità (-30 min, -10 min, -5 min, 0 min)';

  @override
  String get settingsNotificationsBullet3 =>
      'Appuntamenti: promemoria regolabili (da 15 min a 1 giorno prima)';

  @override
  String get settingsNotificationsBullet4 => 'Funziona anche ad app chiusa';

  @override
  String get settingsNotificationsTest => 'Invia una notifica di prova';

  @override
  String get settingsNotificationsTestSubtitle =>
      'Controlla se le notifiche funzionano';

  @override
  String get settingsNotificationsTestSent => '✅ Notifica di prova inviata';

  @override
  String get settingsNotificationsQueue => 'Coda';

  @override
  String get settingsNotificationsQueuePending => 'Notifiche programmate:';

  @override
  String settingsNotificationsQueueNext(String time) {
    return 'Prossima: $time';
  }

  @override
  String get settingsSectionMaps => 'Mappe e posizione';

  @override
  String get settingsMapsSubtitle =>
      'I riquadri della mappa si scaricano e si salvano da soli quando li guardi';

  @override
  String get settingsCacheStorage => 'Spazio della cache';

  @override
  String settingsCacheSize(int size, int limit, String count) {
    return '$size MB / $limit MB • $count riquadri';
  }

  @override
  String get settingsCacheLimit => 'Limite della cache';

  @override
  String settingsCacheLimitSubtitle(int limit) {
    return '$limit MB di dimensione massima';
  }

  @override
  String get settingsCacheLimitDialogTitle => 'Imposta il limite della cache';

  @override
  String settingsCacheLimitDialogLabel(int size) {
    return 'Dimensione massima della cache: $size MB';
  }

  @override
  String get settingsCacheLimitDialogInfo =>
      'Quando la cache supera questo limite, i riquadri più vecchi vengono eliminati da soli.';

  @override
  String settingsCacheLimitSet(int limit) {
    return '✅ Limite della cache impostato a $limit MB';
  }

  @override
  String get settingsCachePreDownload => 'Scarica le mappe in anticipo';

  @override
  String get settingsCachePreDownloadSubtitle =>
      'Scarica le mappe entro un raggio';

  @override
  String get settingsCachePreDownloadPlaceholder =>
      '🚧 Lo scaricamento in anticipo arriva nella fase 4';

  @override
  String get settingsCacheClear => 'Svuota la cache';

  @override
  String get settingsCacheClearSubtitle =>
      'Elimina tutti i riquadri di mappa salvati';

  @override
  String get settingsCacheClearDialogTitle => 'Svuotare la cache delle mappe';

  @override
  String get settingsCacheClearDialogMessage =>
      'Vuoi eliminare tutti i riquadri di mappa salvati?\n\nLe mappe si ricaricheranno la prossima volta che le guardi. Può servire a liberare spazio.';

  @override
  String get settingsCacheClearConfirm => 'Svuota la cache';

  @override
  String get settingsCacheCleared => '✅ Cache delle mappe svuotata';

  @override
  String get settingsSectionApp => 'Impostazioni dell’app';

  @override
  String get settingsTimeFormat => 'Formato dell’ora';

  @override
  String get settingsTimeFormatSystem => 'Quello del sistema';

  @override
  String get settingsTimeFormat12h => 'Formato 12 ore';

  @override
  String get settingsTimeFormat24h => 'Formato 24 ore';

  @override
  String get settingsTimeFormatSystemSubtitle =>
      'Segue le impostazioni di Android';

  @override
  String get settingsTimeFormat12hExample => 'p. es. 2:30 PM';

  @override
  String get settingsTimeFormat24hExample => 'p. es. 14:30';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsLanguageChanged => 'Lingua cambiata';

  @override
  String get onboardingSelectLanguage => 'Scegli la tua lingua';

  @override
  String get onboardingWelcomeTitle => 'Ti diamo il benvenuto in';

  @override
  String get onboardingWelcomeSubtitle =>
      'La tua compagna sicura nella vita di ogni giorno con il DID';

  @override
  String get onboardingWelcomeDescription =>
      'Aurora ti accompagna a organizzare le tue giornate e la comunicazione dentro il tuo sistema.';

  @override
  String get onboardingPrivacyTitle => 'I tuoi dati sono TUOI';

  @override
  String get onboardingPrivacyBullet1 =>
      'Tutti i dati restano sul tuo dispositivo';

  @override
  String get onboardingPrivacyBullet2 =>
      'Nessun backup nel cloud, nessun tracciamento, nessuna pubblicità';

  @override
  String get onboardingPrivacyBullet3 => 'Decidi tu';

  @override
  String get onboardingPrivacyBullet4 => 'Trasparente e sicuro';

  @override
  String get onboardingMultiProfileTitle => 'Tante voci, una sola app';

  @override
  String get onboardingMultiProfileDescription =>
      'Ogni alter può avere il suo profilo, con i suoi colori, le sue impostazioni e i suoi permessi.';

  @override
  String get onboardingLetsGoTitle => 'Pront* a cominciare?';

  @override
  String get onboardingLetsGoDescription =>
      'Crea ora il tuo primo profilo. Il primo diventa in automatico il profilo di amministrazione, con tutti i diritti.';

  @override
  String get onboardingButtonNext => 'Avanti →';

  @override
  String get onboardingButtonCreateProfile => 'Crea il profilo →';

  @override
  String get splashLoading => 'Aurora si sta caricando';

  @override
  String get splashDidYouKnow => 'Lo sapevi?';

  @override
  String get splashEmergencyWipeTitle => 'Cancellazione d’emergenza';

  @override
  String get splashEmergencyWipeMessage =>
      'ATTENZIONE: tutti i dati saranno eliminati per sempre!\n\n• Tutti i profili\n• Tutti i messaggi\n• Tutte le voci del diario\n• Tutti i contatti\n• Tutti i farmaci\n\nContinuare?';

  @override
  String get splashEmergencyWipeConfirm => 'ELIMINA TUTTO';

  @override
  String get passwordResetBannerReady =>
      'La password è pronta per essere attivata';

  @override
  String get passwordResetBannerRunning =>
      'Reimpostazione della password in corso';

  @override
  String passwordResetBannerProfile(String name) {
    return 'Profilo: $name';
  }

  @override
  String passwordResetBannerRemaining(String name, String time) {
    return 'Profilo: $name • Mancano: $time';
  }

  @override
  String get dialogWarning => 'Attenzione';

  @override
  String get dialogConfirm => 'Conferma';

  @override
  String get dialogUnderstood => 'Ho capito';

  @override
  String get dialogYes => 'Sì';

  @override
  String get dialogNo => 'No';

  @override
  String get permissionGpsRequired =>
      '⚠️ Serve il permesso GPS «Consenti sempre»';

  @override
  String get permissionTrackingDialogTitle =>
      'Attivare il rilevamento permanente?';

  @override
  String get permissionTrackingDialogHeading => 'Cosa fa questa modalità:';

  @override
  String get permissionTrackingBullet1 =>
      'Il GPS resta acceso in secondo piano';

  @override
  String get permissionTrackingBullet2 =>
      'Ha la precedenza sulle impostazioni di rilevamento di TUTTI i profili';

  @override
  String get permissionTrackingBullet3 =>
      'La linea del tempo registra tutti gli spostamenti da sola';

  @override
  String get permissionTrackingPrivacyTitle =>
      'I tuoi dati restano su questo dispositivo';

  @override
  String get permissionTrackingPrivacyMessage =>
      'Aurora salva tutti i dati solo su questo dispositivo. Nessun tracciamento, nessuna pubblicità, niente condiviso.';

  @override
  String get permissionTrackingBatteryWarning =>
      'Il GPS in secondo piano può consumare più batteria.';

  @override
  String get permissionTrackingAndroidStatus => 'Stato su Android:';

  @override
  String get permissionTrackingActivate => 'Attiva';

  @override
  String get permissionTrackingDeactivate => 'Disattiva';

  @override
  String get permissionTrackingDeactivateTitle =>
      'Disattivare il rilevamento permanente?';

  @override
  String get permissionTrackingDeactivateMessage =>
      'Il rilevamento GPS tornerà a essere gestito profilo per profilo.\n\nOgni profilo potrà attivarlo o disattivarlo per conto suo.';

  @override
  String get permissionGuidanceTitle => 'Serve un’impostazione di Android';

  @override
  String get permissionGuidanceMessage =>
      'Per usare il rilevamento permanente ti serve il permesso «Consenti sempre».';

  @override
  String get permissionGuidanceStepsTitle => 'Ti guido passo passo:';

  @override
  String get permissionGuidanceStep1Title => 'Apri le impostazioni di Android';

  @override
  String get permissionGuidanceStep1Button => 'Apri ora';

  @override
  String get permissionGuidanceStep2Title => 'Dentro le impostazioni';

  @override
  String get permissionGuidanceStep2Bullet1 => 'Tocca «Permessi»';

  @override
  String get permissionGuidanceStep2Bullet2 => 'Tocca «Posizione»';

  @override
  String get permissionGuidanceStep2Bullet3 => 'Scegli «Consenti sempre»';

  @override
  String get permissionGuidanceStep3Message =>
      'Torna in Aurora\nL’app si accorge del cambiamento da sola.';

  @override
  String get messageError => 'Errore';

  @override
  String get messageSuccess => 'Fatto';

  @override
  String get messageWarning => 'Attenzione';

  @override
  String get messageInfo => 'Informazione';

  @override
  String get messageLoading => 'Sto caricando...';

  @override
  String get misc24HourFormat => 'Formato 24 ore';

  @override
  String get misc12HourFormat => 'Formato 12 ore';

  @override
  String get miscSystemDefault => 'Quello del sistema';

  @override
  String get miscUnknown => 'Sconosciuto';

  @override
  String get chatDayYesterday => 'Ieri';

  @override
  String get miscToday => 'Oggi';

  @override
  String get miscAll => 'Tutti';

  @override
  String get notificationChannelName => 'Notifiche Aurora';

  @override
  String get notificationChannelDescription =>
      'Promemoria per farmaci e appuntamenti';

  @override
  String get notificationMedicationReminder => 'Promemoria farmaco';

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
    return '$name - $dosage assumere ora';
  }

  @override
  String get notificationMedicationAvailableSoon =>
      'Farmaco al bisogno presto disponibile';

  @override
  String get notificationMedicationAvailableNow =>
      'Farmaco al bisogno ora disponibile';

  @override
  String notificationMedicationAvailableBody(String name) {
    return '$name può essere assunto';
  }

  @override
  String get notificationEventReminder => 'Promemoria appuntamento';

  @override
  String notificationEventBody(String title, String time) {
    return '$title $time';
  }

  @override
  String get notificationTestTitle => 'Notifica di test';

  @override
  String get notificationTestBody => 'Le notifiche funzionano!';

  @override
  String notificationTimeInMinutes(int minutes) {
    return 'tra $minutes minuti';
  }

  @override
  String get notificationTimeIn1Hour => 'tra 1 ora';

  @override
  String notificationTimeInHours(int hours) {
    return 'tra $hours ore';
  }

  @override
  String get notificationTimeNow => 'ora';

  @override
  String get notificationMedicationTakeNowTitle =>
      'Assumere il farmaco adesso!';

  @override
  String get notificationMedicationNotTakenYet => 'Non ancora assunto!';

  @override
  String get actionCreate => 'Crea';

  @override
  String get commonDescription => 'Descrizione';

  @override
  String get commonNotes => 'Note';

  @override
  String get commonOptional => 'Facoltativo';

  @override
  String get commonCategory => 'Categoria';

  @override
  String get commonStartTime => 'Ora di inizio';

  @override
  String get commonEndTime => 'Ora di fine';

  @override
  String get commonVisibleFor => 'Visibile per';

  @override
  String get commonUnnamed => 'Senza nome';

  @override
  String get commentsTitle => 'Commenti';

  @override
  String get eventCreate => 'Crea appuntamento';

  @override
  String get eventNewTitle => 'Nuovo appuntamento';

  @override
  String get eventEditTitle => 'Modifica appuntamento';

  @override
  String get eventDetailTitle => 'Appuntamento';

  @override
  String get eventNotFound => 'Appuntamento non trovato';

  @override
  String get eventNotFoundMessage => 'Questo appuntamento non esiste più';

  @override
  String get eventDeleteTitle => 'Eliminare l\'appuntamento?';

  @override
  String get eventDeleteMessage =>
      'Vuoi davvero eliminare questo appuntamento?';

  @override
  String get eventDeleteConfirmMessage =>
      'Questo appuntamento verrà eliminato definitivamente.';

  @override
  String get eventDeleted => 'Appuntamento eliminato';

  @override
  String get eventUpdated => 'Appuntamento salvato';

  @override
  String get eventCreated => 'Appuntamento creato';

  @override
  String get eventSelectProfileRequired => 'Scegli almeno un profilo';

  @override
  String get eventEndTimeError =>
      'L\'ora di fine deve essere dopo quella di inizio';

  @override
  String get eventTitleLabel => 'Titolo';

  @override
  String get eventTitleLabelRequired => 'Titolo *';

  @override
  String get eventTitleRequired => 'Inserisci un titolo';

  @override
  String get eventTitleHint => 'ad es. visita medica';

  @override
  String get eventCategoryLabel => 'Categoria (facoltativo)';

  @override
  String get eventCategoryHint => 'ad es. visita medica, personale, ecc.';

  @override
  String get eventDescriptionLabel => 'Descrizione (facoltativo)';

  @override
  String contactDistanceAway(String distance) {
    return 'a $distance';
  }

  @override
  String eventReminderMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minuti',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String eventReminderHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours ore',
      one: '1 ora',
    );
    return '$_temp0';
  }

  @override
  String get eventReminderDay => '1 giorno';

  @override
  String eventReminderNotice(String when) {
    return 'Aurora ti avvisa $when prima dell\'appuntamento.';
  }

  @override
  String eventReminderBefore(int minutes) {
    return 'Promemoria $minutes min prima';
  }

  @override
  String eventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count appuntamenti',
      one: '1 appuntamento',
      zero: 'Nessun appuntamento',
    );
    return '$_temp0';
  }

  @override
  String get noEventsToday => 'Nessun appuntamento in questo giorno';

  @override
  String get calendarNothingPlannedToday => 'Oggi non c’è nulla in programma.';

  @override
  String get calendarNothingPlannedOnDay =>
      'Non c’è nulla in programma per questo giorno.';

  @override
  String get calendarUpcomingTitle => 'Prossimi appuntamenti';

  @override
  String get calendarChooseDay => 'Guarda un altro giorno';

  @override
  String get eventForWhom => 'Per chi è questo appuntamento?';

  @override
  String get eventMoreDetails => 'Altri dettagli';

  @override
  String get contactTitle => 'Contatto';

  @override
  String get contactNewTitle => 'Nuovo contatto';

  @override
  String get contactEditTitle => 'Modifica contatto';

  @override
  String get contactNotFound => 'Contatto non trovato';

  @override
  String get contactDeleteTitle => 'Eliminare il contatto?';

  @override
  String get contactDeleteMessage =>
      'Questo contatto verrà eliminato definitivamente. L\'azione non può essere annullata.';

  @override
  String get contactImagePickerTitle => 'Scegli l\'immagine del contatto';

  @override
  String get contactNameLabel => 'Nome *';

  @override
  String get contactNameRequired => 'Inserisci un nome';

  @override
  String get contactRelationLabel => 'Relazione';

  @override
  String get contactRelationHint => 'ad es. madre, terapeuta, amico...';

  @override
  String get contactMarkAsEmergency => 'Segna come contatto di emergenza';

  @override
  String get contactEmergencyDescription =>
      'Questo contatto compare nella schermata di emergenza e può essere avvisato rapidamente';

  @override
  String get contactPhoneLabel => 'Telefono';

  @override
  String get contactEmailLabel => 'E-mail';

  @override
  String get contactDefaultRating => 'Valutazione predefinita';

  @override
  String get contactDefaultRatingDescription =>
      'Tutti i profili vedono questa valutazione come predefinita. Ogni profilo può darne una propria più tardi.';

  @override
  String get contactPersonalRating => 'Valutazione personale';

  @override
  String get contactLocationSection => '📍 Luogo (facoltativo)';

  @override
  String get contactLocationTitle => '📍 Luogo';

  @override
  String get contactLocationDescription =>
      'Aggiungi un luogo (ad esempio casa o indirizzo dello studio)';

  @override
  String get contactLocationSet => 'Imposta posizione';

  @override
  String get contactLocationChange => 'Cambia posizione';

  @override
  String get contactAddressLabel => 'Indirizzo';

  @override
  String get contactAddressHint =>
      'Rilevato automaticamente quando la posizione è impostata';

  @override
  String get contactVisibleToAll =>
      'Tutti i profili possono vedere questo contatto';

  @override
  String get contactInfoSection => 'Informazioni';

  @override
  String get gpsPermissionRequired => 'Serve l\'autorizzazione GPS';

  @override
  String get gpsTrackingDisabled => 'Tracciamento GPS disattivato';

  @override
  String get emergencyContactLabel => 'Contatto di emergenza';

  @override
  String get diaryEntryNewTitle => 'Nuova voce';

  @override
  String get diaryEntryEditTitle => 'Modifica voce';

  @override
  String get diaryEntryDetailTitle => 'Dettagli della voce';

  @override
  String get diaryEntryNotFound => 'Voce non trovata';

  @override
  String get diaryEntryNotFoundMessage => 'Questa voce non esiste più';

  @override
  String get diaryEntryDeleteTitle => 'Elimina voce';

  @override
  String get diaryEntryDeleteMessage =>
      'Vuoi davvero eliminare questa voce? Verranno eliminati anche tutti i commenti.';

  @override
  String get diaryEntryDeleted => 'Voce eliminata';

  @override
  String get diaryEntryUpdated => 'Voce aggiornata';

  @override
  String get diaryEntryCreated => 'Voce creata';

  @override
  String get diaryTitleHint => 'Cosa è successo?';

  @override
  String get diaryTitleRequired => 'Inserisci un titolo';

  @override
  String get diaryDescriptionHint => 'Descrivi cosa è successo...';

  @override
  String get diaryDescriptionRequired => 'Inserisci una descrizione';

  @override
  String get diaryPriorityLabel => 'Priorità';

  @override
  String get diaryImagesLabel => 'Immagini';

  @override
  String get diaryNoImagesYet => 'Ancora nessuna immagine';

  @override
  String get diaryImagePickerComingSoon =>
      'La scelta delle immagini arriverà presto';

  @override
  String get diaryCannotEditEntry => 'Non puoi modificare questa voce';

  @override
  String get diaryCannotCreateEntry => 'Non puoi creare voci';

  @override
  String get commonError => 'Errore';

  @override
  String get commonNoPermission => 'Nessuna autorizzazione';

  @override
  String get commonEdited => 'Modificato';

  @override
  String get commonTitle => 'Titolo';

  @override
  String get profileNotSelected => 'Nessun profilo selezionato';

  @override
  String get actionAdd => 'Aggiungi';

  @override
  String commonSaveError(String error) {
    return 'Errore durante il salvataggio: $error';
  }

  @override
  String get timeJustNow => 'proprio ora';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minuti fa',
      one: 'un minuto fa',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ore fa',
      one: 'un’ora fa',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni fa',
      one: 'un giorno fa',
    );
    return '$_temp0';
  }

  @override
  String get emergencyCall => 'Chiama';

  @override
  String get emergencyCallTooltip => 'Chiama il contatto';

  @override
  String get emergencyNoPhone => 'Nessun numero di telefono';

  @override
  String get emergencySms => 'SMS';

  @override
  String get emergencySmsTooltip => 'Invia SMS di emergenza';

  @override
  String get emergencyApp => 'App';

  @override
  String get emergencyShareTooltip => 'Condividi tramite un\'app';

  @override
  String emergencyErrorCall(String error) {
    return 'Errore durante la chiamata: $error';
  }

  @override
  String emergencyErrorOpen(String error) {
    return 'Errore durante l\'apertura: $error';
  }

  @override
  String get actionOpen => 'Apri';

  @override
  String get finderLocationEditTitle => 'Modifica luogo';

  @override
  String get finderItemEditTitle => 'Modifica oggetto';

  @override
  String get finderLocationNewTitle => 'Nuovo luogo';

  @override
  String get finderItemNewTitle => 'Nuovo oggetto';

  @override
  String get finderSetPosition => 'Imposta posizione';

  @override
  String get finderChangePosition => 'Cambia posizione';

  @override
  String get finderAddressLabel => 'Indirizzo';

  @override
  String get finderStorageLocationLabel => 'Dove si conserva';

  @override
  String get finderStorageLocationHint => 'ad es. cucina, secondo cassetto';

  @override
  String get finderChoosePhoto => 'Scegli una foto';

  @override
  String get finderAddPhoto => 'Aggiungi una foto';

  @override
  String get finderAddTag => 'Aggiungi un\'etichetta';

  @override
  String get finderNotFound => 'Non trovato';

  @override
  String get finderNotFoundMessage => 'Elemento non trovato';

  @override
  String get finderDeleteTitle => 'Eliminare?';

  @override
  String finderDeleteMessage(String title) {
    return 'Vuoi davvero eliminare $title?';
  }

  @override
  String get commonRequired => 'Campo obbligatorio';

  @override
  String get feedbackTitle => 'Invia un commento';

  @override
  String get feedbackPrivacyInfo =>
      'Il tuo commento è trattato in modo riservato e usato solo internamente. I tuoi riscontri ci aiutano a migliorare Aurora!';

  @override
  String get feedbackSelectCategory => 'Scegli una categoria:';

  @override
  String get fieldPasswordShow => 'Mostra la password';

  @override
  String get fieldPasswordHide => 'Nascondi la password';

  @override
  String get feedbackCategoryBug => 'Segnalare un problema';

  @override
  String get feedbackCategoryWish => 'Proporre un’idea';

  @override
  String get feedbackCategoryGeneral => 'Riscontro generale';

  @override
  String get feedbackCategoryLabel => 'Categoria';

  @override
  String get feedbackTitleLabel => 'Titolo:';

  @override
  String get feedbackTitleHint => 'Un breve riassunto del tuo commento';

  @override
  String get feedbackTitleRequired => 'Inserisci un titolo';

  @override
  String get feedbackTitleTooShort =>
      'Titolo troppo corto (almeno 5 caratteri)';

  @override
  String get feedbackMessageLabel => 'Il tuo messaggio:';

  @override
  String get feedbackMessageHint => 'Descrivi il tuo commento nel dettaglio...';

  @override
  String get feedbackMessageRequired => 'Inserisci un messaggio';

  @override
  String get feedbackMessageTooShort =>
      'Messaggio troppo corto (almeno 20 caratteri)';

  @override
  String get feedbackEmailLabel => 'La tua e-mail (facoltativo):';

  @override
  String get feedbackEmailHint =>
      'Solo se vuoi che ti scriviamo in caso di domande';

  @override
  String get feedbackEmailPlaceholder => 'tu@esempio.it';

  @override
  String get feedbackEmailInvalid => 'Inserisci un indirizzo e-mail valido';

  @override
  String get feedbackAttachImageLabel => 'Allega un\'immagine (facoltativo):';

  @override
  String get feedbackAttachImage => 'Allega un\'immagine';

  @override
  String get feedbackSelectImage => 'Scegli un\'immagine';

  @override
  String get feedbackSend => 'Invia commento';

  @override
  String get feedbackCopyToClipboard => 'Copia negli appunti';

  @override
  String get feedbackCopiedToClipboard => 'Commento copiato negli appunti!';

  @override
  String get feedbackContactLabel => 'Contatto';

  @override
  String get feedbackErrorOccurred =>
      'Si è verificato un errore. Il rapporto è stato copiato negli appunti.';

  @override
  String get feedbackCouldNotSend =>
      'Non è stato possibile inviare il commento';

  @override
  String feedbackErrorClipboardHint(String email) {
    return 'Il tuo commento è stato copiato negli appunti. Puoi anche inviarcelo per e-mail a $email.';
  }

  @override
  String get feedbackTechnicalDetails => 'Dettagli tecnici';

  @override
  String get actionChange => 'Modifica';

  @override
  String get actionRemove => 'Rimuovi';

  @override
  String get onboardingNext => 'Avanti →';

  @override
  String get onboardingCreateProfile => 'Crea profilo →';

  @override
  String get onboardingLetsGo => 'Si comincia! →';

  @override
  String get onboardingWelcomeTo => 'Benvenuto in';

  @override
  String get onboardingSubline =>
      'La tua compagna sicura nella vita con il DID';

  @override
  String get onboardingDescription =>
      'Aurora ti accompagna nell\'organizzare la giornata e la comunicazione dentro il tuo sistema.';

  @override
  String get onboardingPrivacyHeadline => 'I tuoi dati sono TUOI';

  @override
  String get onboardingPrivacyPoint1 =>
      'Tutti i dati restano sul tuo dispositivo';

  @override
  String get onboardingPrivacyPoint2 =>
      'Nessun backup nel cloud, nessun tracciamento, nessuna pubblicità';

  @override
  String get onboardingPrivacyPoint3 => 'Il controllo è tuo';

  @override
  String get onboardingPrivacyPoint4 => 'Trasparente e sicuro';

  @override
  String get onboardingMultiProfileHeadline => 'Tante voci, una sola app';

  @override
  String get onboardingLetsGoHeadline => 'Pronto per iniziare?';

  @override
  String onboardingHelloName(String name) {
    return 'Ciao $name!';
  }

  @override
  String get onboardingGladYoureHere => 'Bello che tu sia qui.';

  @override
  String get onboardingNotAlone => 'Non sei solo';

  @override
  String get onboardingNotAloneDescription =>
      'Potete scrivervi, condividere appuntamenti e sostenervi a vicenda.';

  @override
  String get onboardingWhatYouCanDo => 'Cosa puoi fare';

  @override
  String get onboardingChildAccessDescription =>
      'Con un profilo bambino hai accesso a:';

  @override
  String get onboardingAdultAccessDescription =>
      'Hai accesso a queste funzioni:';

  @override
  String get onboardingSafeSpace => 'Il tuo spazio sicuro';

  @override
  String get onboardingSafeSpaceDescription =>
      'Tutto ciò che scrivi resta su questo dispositivo. Viene inviato solo ciò che invii tu, e puoi sempre rileggerlo.';

  @override
  String get onboardingHaveFun => 'Buon proseguimento con Aurora!';

  @override
  String get onboardingFeatureChatChild =>
      'Chat: scarabocchiare e parlare con gli altri';

  @override
  String get onboardingFeatureDiaryChild => 'Diario: scrivere i tuoi pensieri';

  @override
  String get onboardingFeatureGamesChild => 'Giochi: divertirsi e rilassarsi';

  @override
  String get onboardingFeatureTimelineChild =>
      'Linea del tempo: conservare i momenti importanti';

  @override
  String get onboardingFeatureChat =>
      'Chat: messaggi, scarabocchi, messaggi vocali';

  @override
  String get onboardingFeatureCalendar =>
      'Calendario: pianificare e gestire gli appuntamenti';

  @override
  String get onboardingFeatureContacts =>
      'Contatti: salvare le persone importanti';

  @override
  String get onboardingFeatureMedication =>
      'Farmaci: tenere traccia di farmaci e assunzioni';

  @override
  String get onboardingFeatureDiary =>
      'Diario: annotare pensieri ed esperienze';

  @override
  String get onboardingFeatureFinder => 'Trova: ritrovare luoghi e cose';

  @override
  String get onboardingFeatureEmergency =>
      'Emergenza: aiuto rapido nei momenti di crisi';

  @override
  String get onboardingFeatureMantras =>
      'Mantra: frasi che calmano e affermazioni';

  @override
  String get onboardingFeatureChatBasic => 'Chat: funzioni di base disponibili';

  @override
  String get featureCarouselHeadline => 'Tutto quello che Aurora sa fare';

  @override
  String get featureCarouselSwipeHint => 'Scorri tra le funzioni →';

  @override
  String get featureCarouselChatTitle => 'Chat';

  @override
  String get featureCarouselChatSubtitle => 'Comunicazione interna';

  @override
  String get featureCarouselChatDescription =>
      'Messaggi, scarabocchi e messaggi vocali.\nCondividete pensieri, disegnate insieme o parlatevi.';

  @override
  String get featureCarouselCalendarTitle => 'Calendario';

  @override
  String get featureCarouselCalendarSubtitle => 'Appuntamenti';

  @override
  String get featureCarouselCalendarDescription =>
      'Appuntamenti con immagini e luoghi.\nTenete d\'occhio gli appuntamenti importanti, con immagini e posizioni GPS.';

  @override
  String get featureCarouselDiaryTitle => 'Diario';

  @override
  String get featureCarouselDiarySubtitle => 'Pensieri privati';

  @override
  String get featureCarouselDiaryDescription =>
      'Visibile a tutti o solo a te.\nAnnotate i pensieri: in comune per tutti i profili o in privato.';

  @override
  String get featureCarouselFinderTitle => 'Trova';

  @override
  String get featureCarouselFinderSubtitle => 'Luoghi e cose';

  @override
  String get featureCarouselFinderDescription =>
      'Ritrovate luoghi e cose.\nSalvate luoghi importanti (con mappa) e oggetti per ritrovarli.';

  @override
  String get featureCarouselMedicationTitle => 'Farmaci';

  @override
  String get featureCarouselMedicationSubtitle => 'Monitoraggio dei farmaci';

  @override
  String get featureCarouselMedicationDescription =>
      'Farmaci e orari di assunzione.\nTenete traccia dei farmaci, degli orari e dei farmaci al bisogno.';

  @override
  String get featureCarouselGamesTitle => 'Giochi e radicamento';

  @override
  String get featureCarouselGamesSubtitle => 'Calma';

  @override
  String get featureCarouselGamesDescription =>
      'Giochi, respirazione e radicamento.\nCalmatevi con rompicapi, esercizi di respirazione e tecniche di radicamento.';

  @override
  String get featureCarouselEmergencyTitle => 'Aiuto';

  @override
  String get featureCarouselEmergencySubtitle => 'Contatti di emergenza';

  @override
  String get featureCarouselEmergencyDescription =>
      'Contatti di emergenza e aiuto rapido.\nSalvate i contatti importanti per i momenti di crisi.';

  @override
  String get featureCarouselInfoTitle => 'Informazioni sul DID';

  @override
  String get featureCarouselInfoSubtitle => 'Informazioni e risorse';

  @override
  String get featureCarouselInfoDescription =>
      'Spiegato: che cos\'è il DID?\nInformazioni sul disturbo dissociativo dell\'identità e risorse.';

  @override
  String get commonUnknown => 'Sconosciuto';

  @override
  String get timelineTitle => 'Linea del tempo';

  @override
  String get timelineHistory => 'Cronologia';

  @override
  String timelineEntries(int count) {
    return '$count voci';
  }

  @override
  String get timelinePositionUpdated => 'Posizione aggiornata';

  @override
  String timelineProfileActive(String name) {
    return '$name attivo';
  }

  @override
  String get timelineAppStarted => 'App avviata';

  @override
  String get timelineProfileSwitched => 'Profilo cambiato';

  @override
  String timelineToday(String time) {
    return 'Oggi, $time';
  }

  @override
  String timelineYesterday(String time) {
    return 'Ieri, $time';
  }

  @override
  String get timelineTrackingDisabledTitle => 'Tracciamento GPS disattivato';

  @override
  String get timelineTrackingDisabledSubtitle =>
      'La linea del tempo mostra i tuoi cambi di profilo e le posizioni GPS nel tempo.\n\nAttiva il tracciamento GPS con il simbolo del satellite in alto a destra per raccogliere dati.';

  @override
  String get timelineEmptyTitle => 'Ancora nessun dato';

  @override
  String get timelineEmptySubtitle =>
      'Il tracciamento GPS è attivo. La tua posizione viene registrata ogni 2-3 minuti.\n\nI cambi di profilo e le posizioni GPS compaiono qui automaticamente.';

  @override
  String get gamesTitle => 'Giochi e relax';

  @override
  String get gamesSubtitle =>
      'Giochi semplici per distrarsi e rilassarsi.\nNiente timer, niente punti: solo calma.';

  @override
  String get gamesComingSoon => 'Presto';

  @override
  String get gamesPuzzleTitle => 'Puzzle';

  @override
  String get gamesPuzzleSubtitle => 'Puzzle o rompicapo scorrevole';

  @override
  String get gamesPuzzleDescription => 'Rilassati con immagini che calmano';

  @override
  String get gamesBreathingTitle => 'Esercizi di respirazione';

  @override
  String get gamesBreathingSubtitle => 'Tecniche di respirazione guidate';

  @override
  String get gamesBreathingDescription =>
      'Calmati con semplici esercizi di respirazione';

  @override
  String get memoryCardHidden => 'Coperta';

  @override
  String get memoryCardOpen => 'Scoperta';

  @override
  String get memoryCardFound => 'Coppia trovata';

  @override
  String get memoryAllFound => 'Tutte le coppie sono trovate.';

  @override
  String get memoryNewGame => 'Nuova partita';

  @override
  String get gamesDrawingSend => 'Manda nella chat';

  @override
  String get gamesDrawingEmpty => 'Disegna qualcosa, poi potrai mandarlo';

  @override
  String get gamesDrawingSent => 'Il tuo disegno ora è nella chat.';

  @override
  String memoryCardPosition(int position, int total) {
    return 'Carta $position di $total';
  }

  @override
  String get gamesMemoryTitle => 'Memory';

  @override
  String get gamesMemorySubtitle => 'Trova le coppie';

  @override
  String get gamesMemoryDescription => 'Un memory tranquillo, senza fretta';

  @override
  String get gamesDrawingTitle => 'Disegnare';

  @override
  String get gamesDrawingSubtitle => 'Disegno libero e scarabocchi';

  @override
  String get gamesDrawingDescription => 'Esprimiti in modo creativo';

  @override
  String get puzzleCreateTitle => 'Crea puzzle';

  @override
  String get puzzleRelaxationTitle => 'Puzzle per rilassarsi';

  @override
  String get puzzleRelaxationSubtitle =>
      'Scegli il tipo di puzzle e la difficoltà. Prenditi tempo: qui non si dà un voto.';

  @override
  String get puzzleTypeLabel => 'Tipo di puzzle';

  @override
  String get puzzleTypeJigsaw => 'A incastro';

  @override
  String get puzzleTypeJigsawDescription => 'Trascina i pezzi al posto giusto';

  @override
  String get puzzleTypeSliding => 'Scorrevole';

  @override
  String get puzzleTypeSlidingDescription => 'Sposta i pezzi toccandoli';

  @override
  String get puzzleDifficultyLabel => 'Difficoltà';

  @override
  String get puzzleDifficultyEasy => 'Facile';

  @override
  String get puzzleDifficultyEasyDescription =>
      'Griglia 3×3, perfetta per rilassarsi';

  @override
  String get puzzleDifficultyMedium => 'Media';

  @override
  String get puzzleDifficultyMediumDescription =>
      'Griglia 4×4, una piccola sfida';

  @override
  String get puzzleDifficultyHard => 'Difficile';

  @override
  String get puzzleDifficultyHardDescription =>
      'Griglia 5×5, per chi ha già pratica';

  @override
  String get puzzleSelectImageAndStart => 'Scegli un\'immagine e inizia';

  @override
  String get puzzleJigsawTitle => 'Puzzle a incastro';

  @override
  String get puzzleSlidingTitle => 'Rompicapo scorrevole';

  @override
  String puzzleMoves(int count) {
    return 'Mosse: $count';
  }

  @override
  String get puzzlePreparing => 'Preparazione del puzzle...';

  @override
  String get puzzleAvailablePieces => 'Pezzi disponibili';

  @override
  String get puzzleTapToMove => 'Tocca un pezzo per spostarlo';

  @override
  String get puzzleShowHint => 'Mostra l\'aiuto';

  @override
  String puzzleHintMovablePieces(int count) {
    return 'Suggerimento: puoi spostare $count pezzi';
  }

  @override
  String get puzzleSolved => 'Puzzle risolto!';

  @override
  String puzzleSolvedInMoves(int count) {
    return 'Hai risolto il puzzle in $count mosse.';
  }

  @override
  String puzzleErrorLoadingImage(String error) {
    return 'Errore durante il caricamento dell\'immagine: $error';
  }

  @override
  String puzzleErrorSharing(String error) {
    return 'Errore durante la condivisione: $error';
  }

  @override
  String get puzzleImagePickerTitle => 'Scegli un\'immagine';

  @override
  String get puzzleImagePickerSubtitle =>
      'Scegli un\'immagine che ti calma per il tuo puzzle';

  @override
  String get puzzleImageLoading => 'Caricamento dell\'immagine...';

  @override
  String get puzzleImageLoadFailed =>
      'Non è stato possibile caricare l\'immagine';

  @override
  String get puzzleImageSourceGallery => 'Galleria';

  @override
  String get puzzleImageSourceGallerySubtitle =>
      'Scegli un\'immagine dalla tua galleria';

  @override
  String get puzzleImageSourceCamera => 'Fotocamera';

  @override
  String get puzzleImageSourceCameraSubtitle => 'Scatta una nuova foto';

  @override
  String get puzzleImageSourceOnline => 'Online';

  @override
  String get puzzleImageSourceOnlineSubtitle =>
      'Un\'immagine che calma, da internet';

  @override
  String get puzzleSelectCategory => 'Scegli una categoria';

  @override
  String get errorNoProfileSelected => 'Nessun profilo selezionato';

  @override
  String get mantrasTitle => 'Mantra';

  @override
  String get mantrasComingSoonTitle => 'Mantra: presto disponibili ✨';

  @override
  String get mantrasComingSoonSubtitle =>
      'Affermazioni che calmano e mantra per i momenti difficili';

  @override
  String get helpResourcesTitle => 'Aiuto';

  @override
  String get helpHotlinesTitle => 'Linee di emergenza 24 ore su 24';

  @override
  String get helpHotlinesSubtitle => 'Sostegno professionale, a qualsiasi ora';

  @override
  String get helpMoreResourcesTitle => 'Altre risorse in arrivo';

  @override
  String get helpMoreResourcesDescription =>
      'Nei prossimi aggiornamenti:\n• Risorse terapeutiche\n• Gruppi di auto-aiuto\n• Materiale informativo sul DID\n• Piani di crisi e strategie';

  @override
  String get moreTitle => 'Altre funzioni';

  @override
  String get moreHelpResources => 'Aiuto';

  @override
  String get moreHelpResourcesDescription =>
      'Informazioni e link a sostegno professionale';

  @override
  String get moreGames => 'Giochi e relax';

  @override
  String get moreGamesDescription =>
      'Respirazione, memory e altro per distrarsi';

  @override
  String get moreSettings => 'Impostazioni';

  @override
  String get moreSettingsDescription => 'Configurazione dell\'app e privacy';

  @override
  String get permissionsTitle => 'Diritti e autorizzazioni';

  @override
  String get permissionsNoProfiles => 'Nessun profilo';

  @override
  String get permissionsInfoText =>
      'Qui puoi gestire le autorizzazioni di ogni profilo. Tocca un profilo per vedere i dettagli.';

  @override
  String get permissionsAllRightsAdmin => 'Tutti i diritti (amministratore)';

  @override
  String permissionsCount(int count) {
    return '$count autorizzazioni';
  }

  @override
  String get permissionsAdminBadge => 'Admin';

  @override
  String get permissionsAdministrator => 'Amministratore';

  @override
  String permissionsDetailTitle(String name) {
    return 'Autorizzazioni: $name';
  }

  @override
  String get permissionsChangeError =>
      'Non è stato possibile modificare l\'autorizzazione';

  @override
  String get permissionsMakeAdminTitle => 'Nominare amministratore';

  @override
  String permissionsMakeAdminMessage(String name) {
    return '$name diventerà amministratore con tutti i diritti. Continuare?';
  }

  @override
  String get permissionsMakeAdminButton => 'Rendi amministratore';

  @override
  String get permissionsMakeAdminSubtitle => 'Concede tutti i diritti';

  @override
  String get permissionsRevokeAdminTitle =>
      'Togliere lo stato di amministratore';

  @override
  String permissionsRevokeAdminMessage(String name) {
    return '$name perderà tutti i diritti di amministratore e avrà le autorizzazioni standard. Continuare?';
  }

  @override
  String get permissionsRevokeAdminSubtitle => 'Riporta ai diritti standard';

  @override
  String get permissionsRevokeAdminError =>
      'Non è stato possibile togliere lo stato di amministratore. Il primo profilo deve restare amministratore.';

  @override
  String permissionsActiveCount(int active, int total) {
    return '$active / $total attivi';
  }

  @override
  String get permissionsCategorySystem => 'Autorizzazioni di sistema';

  @override
  String get permissionsCategoryChat => 'Chat';

  @override
  String get permissionsCategoryCalendar => 'Calendario';

  @override
  String get permissionsCategoryMedication => 'Farmaci';

  @override
  String get permissionsCategoryContacts => 'Contatti';

  @override
  String get permissionsCategoryFinder => 'Trova (luoghi e oggetti)';

  @override
  String get permissionsCategoryDiary => 'Diario';

  @override
  String get permissionsCategoryEmergency => 'Contatti di emergenza';

  @override
  String get permissionsCategorySecurity => 'Sicurezza';

  @override
  String profileAgeYears(int age) {
    return '$age anni';
  }

  @override
  String get groundingTitle => 'Appiglio';

  @override
  String get groundingChooseLabel => 'Oppure scegli tu qualcosa';

  @override
  String get groundingDoneAgain => 'Ancora';

  @override
  String get groundingDoneOther => 'Qualcos\'altro';

  @override
  String get groundingDoneCall => 'Chiamare qualcuno';

  @override
  String get groundingOrientationTitle => 'Qui e ora';

  @override
  String get groundingOrientationStep1 => 'Oggi è';

  @override
  String get groundingOrientationStep2 => 'Guardati intorno. Dove sei adesso?';

  @override
  String get groundingOrientationStep3 => 'Di\' chi sei, ad alta voce o piano.';

  @override
  String get groundingOrientationStep4 =>
      'Il corpo di oggi non è quello di allora.';

  @override
  String get groundingOrientationStep5 => 'Ciò che ricordi è passato.';

  @override
  String get groundingOrientationStep6 => 'Sei qui.';

  @override
  String get groundingSensesTitle => 'Vedere, sentire, toccare';

  @override
  String get groundingSensesStep1 => 'Cinque cose che vedi.';

  @override
  String get groundingSensesStep2 => 'Quattro cose che senti.';

  @override
  String get groundingSensesStep3 => 'Tre cose che puoi toccare.';

  @override
  String get groundingSensesStep4 => 'Due cose che odori.';

  @override
  String get groundingSensesStep5 => 'Una cosa che assapori.';

  @override
  String get groundingSensesStep6 => 'Sei qui.';

  @override
  String get groundingBodyTitle => 'Sentire il corpo';

  @override
  String get groundingBodyStep1 => 'Appoggia entrambi i piedi a terra.';

  @override
  String get groundingBodyStep2 => 'Spingi i talloni verso il basso.';

  @override
  String get groundingBodyStep3 => 'Prendi in mano qualcosa di freddo.';

  @override
  String get groundingBodyStep4 => 'Tienilo quanto vuoi.';

  @override
  String get groundingBodyStep5 => 'Senti la schiena contro lo schienale.';

  @override
  String get groundingBodyStep6 => 'Il pavimento ti sostiene.';

  @override
  String get groundingContainerTitle => 'Mettere via';

  @override
  String get groundingContainerStep1 =>
      'Immagina un contenitore. Grande quanto vuoi.';

  @override
  String get groundingContainerStep2 => 'Ha un coperchio che chiude bene.';

  @override
  String get groundingContainerStep3 =>
      'Mettici dentro ciò che adesso è troppo.';

  @override
  String get groundingContainerStep4 => 'Chiudi il coperchio.';

  @override
  String get groundingContainerStep5 => 'Mettilo in un posto che scegli tu.';

  @override
  String get groundingContainerStep6 => 'Puoi riaprirlo. Non adesso.';

  @override
  String get groundingBreathTitle => 'Respiro';

  @override
  String get groundingBreathStep1 => 'Inspira e conta fino a quattro.';

  @override
  String get groundingBreathStep2 => 'Trattieni un attimo.';

  @override
  String get groundingBreathStep3 => 'Espira e conta fino a sei.';

  @override
  String get groundingBreathStep4 => 'Di nuovo. Senza fretta.';

  @override
  String get groundingBreathStep5 => 'Più lento fuori che dentro. Basta così.';

  @override
  String get medicationNameLabel => 'Nome del farmaco';

  @override
  String get medicationDosageLabel => 'Dose';

  @override
  String get medicationDosageHint => 'ad es. 1 compressa, 10 mg, 5 ml';

  @override
  String get medicationNameRequired => 'Inserisci un nome';

  @override
  String get medicationDosageRequired => 'Inserisci la dose';

  @override
  String get medicationTypeQuestion => 'Che tipo di farmaco?';

  @override
  String get medicationTypeDailyTitle => 'Farmaco quotidiano';

  @override
  String get medicationTypeDailyExplanation => 'A orari fissi, ogni giorno';

  @override
  String get medicationTypeAsNeededTitle => 'Farmaco al bisogno';

  @override
  String get medicationTypeAsNeededExplanation => 'Solo quando ne hai bisogno';

  @override
  String get medicationWhenToTake => 'Quando prenderlo?';

  @override
  String get medicationSectionMorning => 'Al mattino';

  @override
  String get medicationSectionMidday => 'A mezzogiorno';

  @override
  String get medicationSectionEvening => 'Alla sera';

  @override
  String get medicationSectionNight => 'Di notte';

  @override
  String get medicationOtherTime => 'Un altro orario';

  @override
  String get medicationSectionNotChosen => 'non selezionato';

  @override
  String get medicationTimeRequired =>
      'Aggiungi almeno un orario di assunzione';

  @override
  String get medicationAsNeededSettings =>
      'Impostazioni del farmaco al bisogno';

  @override
  String get medicationMaxDosesLabel => 'Massimo al giorno *';

  @override
  String get medicationMaxDosesHint => 'ad es. 3';

  @override
  String get medicationMaxDosesHelper =>
      'Quante volte al giorno si può prendere?';

  @override
  String get medicationMaxDosesRequired =>
      'Obbligatorio per il farmaco al bisogno';

  @override
  String get medicationMaxDosesInvalid => 'Inserisci un numero maggiore di 0';

  @override
  String get medicationMaxDosesMissing => 'Indica il massimo al giorno';

  @override
  String get medicationMinIntervalLabel =>
      'Intervallo minimo in ore (facoltativo)';

  @override
  String get medicationMinIntervalHint => 'ad es. 4';

  @override
  String get medicationMinIntervalHelper => 'Tempo minimo tra due assunzioni';

  @override
  String get medicationMinIntervalInvalid =>
      'Inserisci un numero maggiore o uguale a 0';

  @override
  String get medicationRemindersTitle => 'Aurora te lo ricorderà';

  @override
  String get medicationRemindersOff =>
      'Aurora non dice nulla. Il farmaco resta nella tua lista e decidi tu quando guardarla.';

  @override
  String get medicationRemindersDaily =>
      'A ogni orario Aurora si fa sentire tre volte: 30 minuti prima, 10 minuti prima e all\'ora stessa. Se non rispondi, ancora una volta 10 minuti dopo.';

  @override
  String get medicationRemindersNoInterval =>
      'Senza un intervallo minimo non c\'è alcun momento che Aurora possa attendere. Indica sotto un intervallo se vuoi essere avvisato appena la dose successiva è consentita.';

  @override
  String get medicationRemindersAsNeeded =>
      'Dopo un\'assunzione Aurora ti avvisa appena la successiva è consentita e la annuncia 30, 10 e 5 minuti prima.';

  @override
  String get medicationPeriodTitle => 'Periodo (facoltativo)';

  @override
  String get medicationStartDate => 'Data di inizio';

  @override
  String get medicationEndDate => 'Data di fine';

  @override
  String get medicationNotesLabel => 'Note (facoltativo)';

  @override
  String get medicationNotesHint => 'ad es. da prendere durante i pasti';

  @override
  String get medicationDescriptionLabel =>
      'Descrizione dettagliata (facoltativo)';

  @override
  String get medicationDescriptionHint => 'Aiuta a distinguere farmaci simili';

  @override
  String get medicationPhotoTitle => 'Foto della pastiglia (facoltativo)';

  @override
  String get medicationPhotoHint =>
      'Una foto aiuta a riconoscerlo ed evita gli scambi';

  @override
  String get medicationPhotoTake => 'Scatta una foto';

  @override
  String get medicationPhotoRetake => 'Scatta un\'altra foto';

  @override
  String medicationPhotoError(String error) {
    return 'Non è stato possibile caricare la foto: $error';
  }

  @override
  String get medicationActiveTitle => 'Attivo';

  @override
  String get medicationActiveOn => 'Compare nella lista del giorno';

  @override
  String get medicationActiveOff => 'Archiviato';

  @override
  String get medicationDeleteTitle => 'Eliminare il farmaco?';

  @override
  String get medicationDeleteMessage =>
      'Vuoi davvero eliminare questo farmaco?';

  @override
  String get medicationDeleteConfirmMessage =>
      'Questo farmaco verrà eliminato definitivamente.';

  @override
  String get medicationDeleted => 'Farmaco eliminato';

  @override
  String get medicationIntakeTimesLabel => 'Orari di assunzione';

  @override
  String get medicationMaxDailyLabel => 'Max. al giorno';

  @override
  String get medicationMinGapLabel => 'Intervallo min.';

  @override
  String get medicationStatusLabel => 'Stato';

  @override
  String get medicationStatusTaken => 'Preso';

  @override
  String get medicationStatusRefused => 'Rifiutato';

  @override
  String get medicationStatusSnoozed => 'Più tardi';

  @override
  String get medicationTake => 'Prendi';

  @override
  String get medicationTakeAnyway => 'Prendilo lo stesso';

  @override
  String get medicationDailyLimitReached => 'Limite giornaliero raggiunto';

  @override
  String get medicationAddFeedback => 'Aggiungi com\'è andata';

  @override
  String get medicationFeedbackYourExperience => 'Com\'è andata per te';

  @override
  String get medicationRefusalTitle => 'Annotare il rifiuto';

  @override
  String get medicationIntakesLabel => 'Assunzioni';

  @override
  String get medicationNoProfileSelected => 'Nessun profilo selezionato';

  @override
  String get medicationNoLogPermission =>
      'Nessuna autorizzazione per registrare le assunzioni';

  @override
  String get commonGallery => 'Galleria';

  @override
  String get commonCamera => 'Fotocamera';

  @override
  String get medicationStatusSkipped => 'Saltato';

  @override
  String medicationWillBeRefused(String name) {
    return '$name verrà segnato come rifiutato.';
  }

  @override
  String clockTime(String time) {
    return '$time';
  }

  @override
  String medicationReminderAtTime(String time) {
    return 'Promemoria alle $time';
  }

  @override
  String medicationSnoozedUntil(String name, String time) {
    return '$name — promemoria alle $time';
  }

  @override
  String medicationAtTime(String time) {
    return 'alle $time';
  }

  @override
  String medicationDoseCountToday(int available, int max) {
    return 'Disponibili: $available su $max oggi';
  }

  @override
  String medicationLastTaken(String time) {
    return 'Ultima assunzione: $time';
  }

  @override
  String medicationNextPossible(String time) {
    return 'Prossima assunzione possibile alle $time';
  }

  @override
  String medicationNoteLabel(String note) {
    return 'Nota: $note';
  }

  @override
  String medicationLimitWarning(int count, String name) {
    return 'Oggi hai già preso $count dosi di $name. È il limite giornaliero.';
  }

  @override
  String medicationTakenConfirmation(String name) {
    return '$name preso';
  }

  @override
  String get anchorTitle => 'Ancora';

  @override
  String get anchorSectionWhenHard => 'Quando è dura';

  @override
  String get anchorSectionEveryday => 'Ogni giorno';

  @override
  String get anchorSectionWhenCalm => 'Quando c\'è calma';

  @override
  String get fabMedication => 'Farmaco';

  @override
  String get fabDiaryEntry => 'Voce';

  @override
  String get fabContact => 'Contatto';

  @override
  String get appQuitTitle => 'Chiudere l\'app?';

  @override
  String get appQuitMessage => 'Vuoi davvero chiudere Aurora?';

  @override
  String get emergencyResetTitle => 'Ripristino di emergenza';

  @override
  String get emergencyResetWarning =>
      'AVVISO: tutti i dati verranno eliminati per sempre.\n\nProfili, messaggi, appuntamenti, farmaci, contatti: tutto.\n\nQuesto passo non può essere annullato.';

  @override
  String get emergencyResetConfirm => 'ELIMINA TUTTO';

  @override
  String get pwResetCancelledTitle => 'Reimpostazione annullata';

  @override
  String get pwResetCancelledMessage =>
      'La reimpostazione in corso è stata annullata con la vecchia password. Il tuo profilo è ora attivo.';

  @override
  String get pwResetUnderstood => 'Ho capito';

  @override
  String get pwResetNowActiveTitle => 'Nuova password attiva';

  @override
  String get pwResetNowActiveMessage =>
      'La nuova password si è attivata da sola alla fine dell\'attesa. Il tuo profilo è ora attivo.';

  @override
  String get pwResetTitle => 'Reimpostare la password';

  @override
  String get pwResetAnswerQuestions =>
      'Rispondi alle domande di sicurezza per reimpostarla subito';

  @override
  String pwResetAnswerN(int number) {
    return 'Risposta $number';
  }

  @override
  String get pwResetForgotAnswers =>
      'Hai dimenticato le risposte?\nAvvia il conto alla rovescia di 24 ore';

  @override
  String get pwResetAnswerAll => 'Rispondi a tutte le domande';

  @override
  String get pwResetAnswersWrong =>
      'Le risposte non sono corrette.\n\nPuoi riprovare oppure avviare il conto alla rovescia di 24 ore.';

  @override
  String get pwResetCheckAnswers => 'Controlla le risposte';

  @override
  String get pwResetSetNewTitle => 'Imposta una nuova password';

  @override
  String get pwResetAnswersCorrect =>
      'Hai risposto correttamente alle domande di sicurezza.';

  @override
  String get pwResetImmediateHint =>
      'Inserisci la tua nuova password. Sarà attiva subito.';

  @override
  String get pwResetNewPassword => 'Nuova password';

  @override
  String get pwResetConfirmPassword => 'Conferma la password';

  @override
  String get pwResetTooShort => 'La password deve avere almeno 4 caratteri';

  @override
  String get pwResetMismatch => 'Le password non coincidono';

  @override
  String get pwResetChanged =>
      'Password cambiata.\n\nOra puoi accedere con quella nuova.';

  @override
  String get pwResetSetPassword => 'Imposta la password';

  @override
  String get pwResetTimerHint =>
      'Inserisci la tua nuova password.\n\nParte un conto alla rovescia di 24 ore; dopo potrai attivarla.';

  @override
  String pwResetStarted(String waitTime) {
    return 'Reimpostazione avviata.\n\nLa vecchia password resta attiva. Tra $waitTime potrai attivare quella nuova.';
  }

  @override
  String get pwResetStartError =>
      'Non è stato possibile avviare la reimpostazione';

  @override
  String get pwResetStart => 'Avvia la reimpostazione';

  @override
  String get pwResetRunningTitle => 'Reimpostazione in corso';

  @override
  String get pwResetWhatsHappening => 'Cosa sta succedendo?';

  @override
  String get pwResetRunningExplanation =>
      'Poco fa hai impostato una nuova password. Per sicurezza è in corso un conto alla rovescia di 24 ore.\n\n';

  @override
  String pwResetRemaining(String time) {
    return 'Tempo rimasto: $time';
  }

  @override
  String get pwResetReadyTitle => 'Pronta da attivare';

  @override
  String get pwResetWaitOver => 'L\'attesa è finita.';

  @override
  String pwResetReadyExplanation(String startTime) {
    return 'Hai impostato una nuova password il $startTime. Il periodo di sicurezza di 24 ore è trascorso.';
  }

  @override
  String get pwResetIrreversible =>
      'Se la attivi, la tua VECCHIA password viene sostituita per sempre da quella NUOVA.';

  @override
  String get pwResetActivated =>
      'Nuova password attivata.\n\nOra puoi accedere con quella.';

  @override
  String get pwResetActivateError =>
      'Non è stato possibile attivare la password';

  @override
  String get pwResetActivate => 'Attiva la nuova password';

  @override
  String get profileCurrentlyActive => 'Profilo attualmente in uso';

  @override
  String get profilePasswordProtected =>
      'Questo profilo è protetto da password';

  @override
  String get profilePasswordLabel => 'Password';

  @override
  String get settingsMapCacheClearQuestion =>
      'Eliminare tutte le tessere di mappa salvate?';

  @override
  String get settingsMapCacheCleared => 'Cache delle mappe svuotata';

  @override
  String get settingsMapPredownloadComingSoon =>
      'Il download anticipato arriverà in una versione futura';

  @override
  String get settingsCacheLimitTitle => 'Imposta il limite della cache';

  @override
  String settingsCacheLimitValue(int size) {
    return 'Dimensione massima della cache: $size MB';
  }

  @override
  String settingsCacheLimitMegabytes(int size) {
    return '$size MB';
  }

  @override
  String get settingsCacheLimitExplanation =>
      'Quando la cache supera questo limite, le tessere più vecchie vengono eliminate automaticamente.';

  @override
  String get settingsAllDataDeleted => 'Tutti i dati sono stati eliminati';

  @override
  String get settingsDeleteIncomplete =>
      'Non è stato possibile eliminare tutto. Riprova.';

  @override
  String get settingsTrackingEnableTitle =>
      'Attivare il tracciamento continuo?';

  @override
  String get settingsTrackingWhatItDoes => 'Cosa fa questa modalità:';

  @override
  String get settingsDataStaysHere =>
      'I tuoi dati restano su questo dispositivo';

  @override
  String get settingsDataStaysHereExplanation =>
      'Aurora salva tutti i dati solo in locale.';

  @override
  String get settingsBackgroundGpsBattery =>
      'Il GPS in secondo piano può consumare più batteria.';

  @override
  String get settingsAndroidStatus => 'Stato di Android:';

  @override
  String get settingsActivate => 'Attiva';

  @override
  String get settingsDeactivate => 'Disattiva';

  @override
  String get settingsTrackingDisableTitle =>
      'Disattivare il tracciamento continuo?';

  @override
  String get settingsTrackingDisableExplanation =>
      'Il tracciamento GPS torna a essere gestito per profilo.';

  @override
  String get settingsTestNotificationSent => 'Notifica di prova inviata';

  @override
  String get settingsAndroidSettingNeeded =>
      'Serve un\'impostazione di Android';

  @override
  String settingsPermissionNeededFor(String permission) {
    return 'Per il tracciamento continuo ti serve l\'autorizzazione «$permission».';
  }

  @override
  String get settingsStepByStep => 'Ecco, passo per passo:';

  @override
  String get settingsOpenAndroidSettings => 'Apri le impostazioni di Android';

  @override
  String get settingsOpenNow => 'Apri ora';

  @override
  String get settingsInTheSettings => 'Nelle impostazioni';

  @override
  String get settingsBackToAurora =>
      'Torna ad Aurora\nL\'app rileva la modifica da sola.';

  @override
  String get settingsUnderstood => 'Ho capito';

  @override
  String settingsResetPendingFor(String name, String time) {
    return 'Profilo: $name\nTempo rimasto: $time';
  }

  @override
  String settingsWhatIs(String name) {
    return 'Che cos\'è «$name»?';
  }

  @override
  String get settingsAdminTrackingExplanation =>
      'Come amministratore puoi impostare il tracciamento GPS per TUTTI i profili in una volta. Quando è attivo:';

  @override
  String settingsPrerequisite(String permission) {
    return 'Serve prima l\'autorizzazione Android «$permission».';
  }

  @override
  String get settingsGpsPermission => 'Autorizzazione GPS';

  @override
  String get settingsBackgroundReady =>
      'Tutto pronto per il tracciamento continuo.';

  @override
  String settingsHowToEnable(String permission) {
    return 'Come attivare «$permission»';
  }

  @override
  String get settingsLocationStaysHere =>
      'I tuoi dati di posizione restano su questo dispositivo.';

  @override
  String get settingsTrackingAlwaysOn => 'Tracciamento sempre attivo';

  @override
  String get settingsHowNotificationsWork => 'Come funzionano le notifiche?';

  @override
  String get settingsSendTestNotification => 'Invia una notifica di prova';

  @override
  String get settingsCheckNotificationsWork =>
      'Verifica che le notifiche arrivino';

  @override
  String get settingsQueue => 'Coda';

  @override
  String get settingsScheduledNotifications => 'Notifiche programmate:';

  @override
  String settingsNextAt(String time) {
    return 'Prossima: $time';
  }

  @override
  String settingsCacheUsage(String used, String limit, String count) {
    return '$used MB su $limit MB • $count tessere';
  }

  @override
  String settingsPercent(int value) {
    return '$value%';
  }

  @override
  String get settingsCacheLimitLabel => 'Limite della cache';

  @override
  String get settingsPredownloadMaps => 'Scarica le mappe in anticipo';

  @override
  String get settingsPredownloadSubtitle =>
      'Scarica le mappe di una zona intorno a te';

  @override
  String get settingsClearCache => 'Svuota la cache';

  @override
  String get settingsClearCacheSubtitle =>
      'Elimina tutte le tessere di mappa salvate';

  @override
  String get settingsDiscreetRemindersTitle => 'Promemoria senza contenuto';

  @override
  String get settingsDiscreetRemindersOn =>
      'Sulla schermata di blocco compare solo «Aurora — promemoria». Cosa significa, lo vedi dopo lo sblocco.';

  @override
  String get settingsDiscreetRemindersOff =>
      'La schermata di blocco mostra nome e dose, oppure l\'appuntamento, in chiaro.';

  @override
  String get settingsWhatAuroraSends => 'Cosa invia Aurora';

  @override
  String get settingsWhatAuroraSendsSubtitle =>
      'Leggi ogni invio parola per parola';

  @override
  String get settingsAlwaysAllow => 'Consenti sempre';

  @override
  String get settingsAlwaysAllowRequired =>
      'Serve l\'autorizzazione di posizione «Consenti sempre»';

  @override
  String get settingsLocalOnly =>
      'Aurora salva tutti i dati solo in locale. Niente cloud, niente server, nessun invio.';

  @override
  String get settingsTrackingDisableFull =>
      'Il tracciamento GPS torna a essere gestito per profilo.\n\nOgni profilo potrà attivarlo e disattivarlo da sé.';

  @override
  String get settingsAlwaysAllowNeeded =>
      'Per il tracciamento continuo ti serve l\'autorizzazione «Consenti sempre».';

  @override
  String get settingsWhatIsAlwaysOn =>
      'Che cos\'è «tracciamento sempre attivo»?';

  @override
  String get settingsAlwaysAllowPrerequisite =>
      'Serve prima l\'autorizzazione Android «Consenti sempre», così il tracciamento continua anche ad app chiusa.';

  @override
  String get settingsHowToEnableAlwaysAllow =>
      'Come attivare «Consenti sempre»:';

  @override
  String get settingsLocationStaysOffline =>
      'I tuoi dati di posizione restano su questo dispositivo. Aurora funziona offline, senza connessione a un server.';

  @override
  String settingsCountValue(int count) {
    return '$count';
  }

  @override
  String settingsTilesCount(String used, String limit, String count) {
    return '$used MB su $limit MB • $count tessere';
  }

  @override
  String settingsMaxStorage(int size) {
    return '$size MB di spazio massimo';
  }

  @override
  String errorWithDetail(String error) {
    return 'Errore: $error';
  }

  @override
  String get securityQuestionsFillAll =>
      'Compila tutte e tre le domande e risposte';

  @override
  String get securityQuestionsSaved =>
      'Domande di sicurezza salvate.\n\nOra puoi usarle per reimpostare la password.';

  @override
  String get securityQuestionsRemoveTitle =>
      'Togliere le domande di sicurezza?';

  @override
  String get securityQuestionsRemoveWarning =>
      'Senza le domande di sicurezza, il conto alla rovescia di 24 ore è l\'unico modo rimasto per reimpostare la password.';

  @override
  String get securityQuestionsRemoved => 'Domande di sicurezza rimosse';

  @override
  String get securityQuestionsSetupTitle => 'Imposta le domande di sicurezza';

  @override
  String get securityQuestionsSetupExplanation =>
      'Imposta tre domande di sicurezza per poter reimpostare in fretta la password.';

  @override
  String get securityQuestionsChooseWisely =>
      'Scegli domande di cui non dimenticherai mai le risposte';

  @override
  String securityQuestionN(int number) {
    return 'Domanda $number';
  }

  @override
  String securityAnswerToQuestionN(int number) {
    return 'Risposta alla domanda $number';
  }

  @override
  String get securityQuestionHint1 => 'ad es. il nome del mio primo animale?';

  @override
  String get securityQuestionHint2 => 'ad es. dove è nata mia madre?';

  @override
  String get securityQuestionHint3 =>
      'ad es. il mio film preferito da bambino?';

  @override
  String get errorReportPreviewTitle => 'Anteprima del rapporto di errore';

  @override
  String get errorReportWhatIsSent => 'Ecco cosa viene inviato:';

  @override
  String get errorReportContactSection => 'Contatto (facoltativo)';

  @override
  String get errorReportContactExplanation =>
      'Solo se vuoi che possiamo contattarti in caso di domande:';

  @override
  String get errorReportEmailLabel => 'Indirizzo e-mail (facoltativo)';

  @override
  String get errorReportNewsletter => 'Iscriviti alle novità';

  @override
  String get errorReportNewsletterSubtitle =>
      'Ricevi notizie su Aurora, al massimo una volta al mese';

  @override
  String get errorReportEmailUseOnly =>
      'Usiamo la tua e-mail solo per domande su questo rapporto.';

  @override
  String get errorReportCopy => 'Copia';

  @override
  String get errorReportCopied => 'Rapporto copiato negli appunti';

  @override
  String errorReportAutoGenerated(String type) {
    return 'Rapporto generato automaticamente ($type).';
  }

  @override
  String get errorReportQueued =>
      'Rapporto accettato. Partirà appena tornerai online.';

  @override
  String get errorReportFailed => 'Non è stato possibile inviare il rapporto';

  @override
  String get errorReportCopyToClipboard => 'Copia negli appunti';

  @override
  String permissionsLevel(int level) {
    return 'Livello $level';
  }

  @override
  String get permissionsSectionExplanation =>
      'Decidi quali aree può usare questo profilo. Ogni area si imposta singolarmente:';

  @override
  String get permissionsChildPreset => 'Preimpostazione bambino';

  @override
  String get permissionsAdultPreset => 'Preimpostazione adulto';

  @override
  String get permissionsCategoryEmergencyDiary => 'Diario di emergenza';

  @override
  String get permissionsCategoryHelp => 'Aiuto';

  @override
  String get permissionsCategoryMantras => 'Mantra';

  @override
  String get permissionsCategoryGames => 'Giochi';

  @override
  String get permissionsChangeableLater =>
      'Puoi cambiare le autorizzazioni quando vuoi nelle impostazioni';

  @override
  String get errorReportRoute =>
      'Il rapporto va direttamente agli sviluppatori; se non riesce, Aurora apre la tua app di posta. Cosa è stato inviato è elencato nelle impostazioni, sotto «Cosa invia Aurora».';

  @override
  String get errorReportEmailPrivacy =>
      'Usiamo la tua e-mail solo per domande su questo rapporto e non la passiamo a nessuno.';

  @override
  String errorReportAutoBody(String type) {
    return 'Rapporto generato automaticamente ($type). I dettagli sono nella diagnostica del dispositivo.';
  }

  @override
  String errorReportClipboardFallback(String email) {
    return 'Il rapporto è negli appunti. Puoi anche inviarcelo per e-mail a $email.';
  }

  @override
  String get mapAddressNotFound => 'Indirizzo non trovato';

  @override
  String get mapNeedsInternet =>
      'Aurora ha bisogno di internet per cercare indirizzi';

  @override
  String get mapDataEnabled =>
      'Dati della mappa attivati: la mappa si sta caricando';

  @override
  String get mapTapOrSearch => 'Tocca la mappa o cerca un indirizzo';

  @override
  String get mapAddressLoading => 'Caricamento dell\'indirizzo…';

  @override
  String get mapPickTitle => 'Aggiungi un luogo';

  @override
  String get mapTapSearchOrLocate =>
      'Tocca la mappa, cerca un indirizzo oppure usa la tua posizione';

  @override
  String get mapSearchHint =>
      'Cerca un indirizzo (ad es. via Chiesa 3, Coswig)';

  @override
  String get mapDataNotLoaded => 'Dati della mappa non caricati';

  @override
  String get mapEnableToMark =>
      'Attiva i dati della mappa per segnare luoghi su di essa.';

  @override
  String get mapDataFromOsm =>
      'I dati della mappa vengono da OpenStreetMap.\nAd Aurora serve una connessione internet una volta sola.';

  @override
  String get mapZoomIn => 'Ingrandisci';

  @override
  String get mapZoomOut => 'Riduci';

  @override
  String get mapToMyLocation => 'Alla mia posizione';

  @override
  String get feedbackSheetTitle => 'Contatta lo sviluppatore';

  @override
  String get feedbackSheetIntro =>
      'Aurora è in beta aperta e vive dei tuoi riscontri.';

  @override
  String get feedbackReplyOnlyIfWanted => 'Solo se vuoi una risposta';

  @override
  String errorOpening(String error) {
    return 'Impossibile aprire: $error';
  }

  @override
  String errorLinkNotOpened(String url) {
    return 'Non è stato possibile aprire il link: $url';
  }

  @override
  String get thankYouTitle => 'Grazie!';

  @override
  String get thankYouReportSent =>
      'Il tuo rapporto è arrivato e ci aiuta a migliorare Aurora.';

  @override
  String get thankYouReportRecorded =>
      'Il tuo rapporto di errore è stato registrato';

  @override
  String get thankYouJoinCommunity => 'Unisciti alla comunità';

  @override
  String get thankYouDiscord => 'Server Discord';

  @override
  String get thankYouDiscordSubtitle =>
      'Scambia con altre persone e con il team';

  @override
  String get thankYouMoreContact => 'Altri modi per contattarci';

  @override
  String get thankYouEmailSupport => 'Assistenza via e-mail';

  @override
  String get thankYouWhatsNext => 'E adesso?';

  @override
  String get thankYouBackToApp => 'Torna ad Aurora';

  @override
  String get transparencyDeleteTitle => 'Eliminare questa voce?';

  @override
  String get transparencyDeleteMessage =>
      'La voce sparisce da questa lista. Ciò che è già stato inviato non torna indietro per questo.';

  @override
  String get transparencyIntro =>
      'Qui vedi ogni invio partito dal tuo dispositivo, parola per parola.';

  @override
  String get transparencyNothingSent => 'Non è ancora stato inviato nulla.';

  @override
  String get transparencySendUsageData => 'Invia dati d\'uso anonimi';

  @override
  String get transparencyIrreversible =>
      'Ciò che è già stato inviato non può essere richiamato. È in viaggio.';

  @override
  String imagePickerAnimalError(String error) {
    return 'Non è stato possibile scegliere l\'avatar animale: $error';
  }

  @override
  String get imagePickerCameraNeeded =>
      'Ad Aurora serve l\'autorizzazione della fotocamera per scattare foto';

  @override
  String get imagePickerGalleryNeeded =>
      'Ad Aurora serve l\'autorizzazione della galleria per scegliere immagini';

  @override
  String get imagePickerAllowInSettings => 'Consentilo nelle impostazioni';

  @override
  String get imagePickerOpenSettings => 'Apri le impostazioni';

  @override
  String imagePickerPickError(String error) {
    return 'Non è stato possibile scegliere l\'immagine: $error';
  }

  @override
  String imagePickerSaveError(String error) {
    return 'Non è stato possibile salvare l\'immagine: $error';
  }

  @override
  String get feedbackThankYouTitle => 'Il tuo riscontro è stato registrato';

  @override
  String get feedbackThankYouMessage =>
      'Grazie! Il tuo riscontro ci aiuta a migliorare Aurora.';

  @override
  String get feedbackStayInTouch => 'Restiamo in contatto';

  @override
  String get feedbackAuroraDiscord => 'Aurora su Discord';

  @override
  String get feedbackWebsite => 'Sito web';

  @override
  String get feedbackEmail => 'E-mail';

  @override
  String get crashTitle => 'Qualcosa è andato storto';

  @override
  String get crashMessage =>
      'Aurora ha incontrato un errore inatteso. I tuoi dati non ne sono toccati.';

  @override
  String get crashTechnicalDetails => 'Dettagli tecnici';

  @override
  String get crashReport => 'Segnala l\'errore';

  @override
  String get crashRestart => 'Riavvia l\'app';

  @override
  String get crashContinue => 'Continua comunque';

  @override
  String get doodleSendDrawing => 'Invia il disegno';

  @override
  String get doodleSticker => 'Adesivo';

  @override
  String get doodleStrokeWidth => 'Spessore del tratto';

  @override
  String get doodleStrokeThin => 'Tratto sottile';

  @override
  String get doodleStrokeMedium => 'Tratto medio';

  @override
  String get doodleStrokeThick => 'Tratto spesso';

  @override
  String get imagePickerDrawYourself => 'Disegnalo tu';

  @override
  String get doodleAvatarTitle => 'Disegna la tua immagine';

  @override
  String get doodleAvatarDone => 'Fatto';

  @override
  String get doodleAvatarEmptyHint => 'Disegna prima qualcosa';

  @override
  String get permCreateProfilesLabel => 'Aggiungere una parte';

  @override
  String get permCreateProfilesDesc => 'Accogliere una nuova parte in Aurora';

  @override
  String get permDeactivateProfilesLabel => 'Nascondere una parte';

  @override
  String get permDeactivateProfilesDesc =>
      'Nascondere una parte per un po\'; si può rendere di nuovo visibile';

  @override
  String get permManagePermissionsLabel => 'Gestire i diritti';

  @override
  String get permManagePermissionsDesc =>
      'Decidere cosa possono fare le altre parti';

  @override
  String get permAccessSettingsLabel => 'Impostazioni dell\'app';

  @override
  String get permAccessSettingsDesc => 'Configurare e regolare Aurora';

  @override
  String get permViewChatLabel => 'Leggere la chat';

  @override
  String get permViewChatDesc => 'Vedere i messaggi della chat interna';

  @override
  String get permSendChatMessageLabel => 'Poter inviare tutto';

  @override
  String get permSendChatMessageDesc =>
      'Un diritto che copre ogni tipo di messaggio; sostituisce quelli sotto';

  @override
  String get permSendTextMessageLabel => 'Scrivere testo';

  @override
  String get permSendTextMessageDesc => 'Mettere messaggi scritti nella chat';

  @override
  String get permSendDoodleLabel => 'Disegnare';

  @override
  String get permSendDoodleDesc => 'Condividere disegni e scarabocchi';

  @override
  String get permSendVoiceMessageLabel => 'Parlare';

  @override
  String get permSendVoiceMessageDesc =>
      'Registrare qualcosa e inviare la propria voce';

  @override
  String get permSendImageLabel => 'Inviare immagini';

  @override
  String get permSendImageDesc => 'Scattare foto o condividerle dalla galleria';

  @override
  String get permSendVideoLabel => 'Inviare video';

  @override
  String get permSendVideoDesc =>
      'Registrare video o condividerli dalla galleria';

  @override
  String get permDeleteOwnMessagesLabel => 'Eliminare i propri messaggi';

  @override
  String get permDeleteOwnMessagesDesc => 'Ritirare solo ciò che si è scritto';

  @override
  String get permDeleteAllMessagesLabel =>
      'Eliminare i messaggi di altre parti';

  @override
  String get permDeleteAllMessagesDesc =>
      'Rimuovere anche i messaggi di altre parti; non si può annullare';

  @override
  String get permViewCalendarLabel => 'Vedere il calendario';

  @override
  String get permViewCalendarDesc => 'Vedere cosa c\'è in arrivo';

  @override
  String get permCreateEventsLabel => 'Aggiungere un appuntamento';

  @override
  String get permCreateEventsDesc =>
      'Mettere nuovi appuntamenti nel calendario';

  @override
  String get permEditOwnEventsLabel => 'Modificare i propri appuntamenti';

  @override
  String get permEditOwnEventsDesc =>
      'Modificare solo gli appuntamenti aggiunti da sé';

  @override
  String get permEditAllEventsLabel => 'Modificare tutti gli appuntamenti';

  @override
  String get permEditAllEventsDesc =>
      'Modificare anche gli appuntamenti di altre parti';

  @override
  String get permDeleteOwnEventsLabel => 'Eliminare i propri appuntamenti';

  @override
  String get permDeleteOwnEventsDesc =>
      'Rimuovere solo gli appuntamenti aggiunti da sé';

  @override
  String get permDeleteAllEventsLabel => 'Eliminare tutti gli appuntamenti';

  @override
  String get permDeleteAllEventsDesc =>
      'Rimuovere anche gli appuntamenti di altre parti; non si può annullare';

  @override
  String get permAttachEventMediaLabel => 'Allegati dell\'appuntamento';

  @override
  String get permAttachEventMediaDesc =>
      'Allegare immagini e note a un appuntamento';

  @override
  String get permCommentOnCalendarEventsLabel => 'Commentare';

  @override
  String get permCommentOnCalendarEventsDesc =>
      'Aggiungere qualcosa a un appuntamento';

  @override
  String get permViewMedicationLabel => 'Vedere i farmaci';

  @override
  String get permViewMedicationDesc => 'Vedere cosa riceve il corpo e quando';

  @override
  String get permManageMedicationLabel => 'Gestire i farmaci';

  @override
  String get permManageMedicationDesc =>
      'Aggiungere, modificare e rimuovere farmaci';

  @override
  String get permLogMedicationLabel => 'Confermare un\'assunzione';

  @override
  String get permLogMedicationDesc => 'Spuntare ciò che è già stato preso';

  @override
  String get permOverrideMedicationLogLabel =>
      'Annullare un\'assunzione registrata';

  @override
  String get permOverrideMedicationLogDesc =>
      'Modificare una conferma fatta da un\'altra parte';

  @override
  String get permCommentOnMedicationLabel => 'Commentare';

  @override
  String get permCommentOnMedicationDesc => 'Aggiungere qualcosa a un farmaco';

  @override
  String get permViewOwnDiaryLabel => 'Il proprio diario';

  @override
  String get permViewOwnDiaryDesc => 'Leggere solo le proprie voci';

  @override
  String get permViewAllDiariesLabel => 'Tutti i diari';

  @override
  String get permViewAllDiariesDesc => 'Leggere anche le voci di altre parti';

  @override
  String get permWriteDiaryLabel => 'Scrivere nel diario';

  @override
  String get permWriteDiaryDesc => 'Scrivere qualcosa nel diario';

  @override
  String get permViewContactsLabel => 'Vedere i contatti';

  @override
  String get permViewContactsDesc => 'Vedere chi fa parte della cerchia';

  @override
  String get permManageContactsLabel => 'Gestire i contatti';

  @override
  String get permManageContactsDesc =>
      'Aggiungere, modificare e rimuovere persone';

  @override
  String get permCommentOnContactsLabel => 'Commentare';

  @override
  String get permCommentOnContactsDesc => 'Aggiungere qualcosa su una persona';

  @override
  String get permViewFinderLabel => 'Vedere Trova';

  @override
  String get permViewFinderDesc => 'Cercare dov\'è qualcosa o dove si è stati';

  @override
  String get permManageFinderLabel => 'Gestire Trova';

  @override
  String get permManageFinderDesc =>
      'Aggiungere, modificare e rimuovere luoghi e oggetti';

  @override
  String get permCommentOnFinderEntriesLabel => 'Commentare';

  @override
  String get permCommentOnFinderEntriesDesc =>
      'Aggiungere qualcosa a un luogo o oggetto';

  @override
  String get permCreateDiaryEntryLabel => 'Scrivere una voce';

  @override
  String get permCreateDiaryEntryDesc => 'Creare una nuova voce di diario';

  @override
  String get permEditOwnDiaryEntriesLabel => 'Modificare le proprie voci';

  @override
  String get permEditOwnDiaryEntriesDesc =>
      'Modificare solo le voci scritte da sé';

  @override
  String get permEditAllDiaryEntriesLabel => 'Modificare tutte le voci';

  @override
  String get permEditAllDiaryEntriesDesc =>
      'Modificare anche le voci di altre parti';

  @override
  String get permDeleteOwnDiaryEntriesLabel => 'Eliminare le proprie voci';

  @override
  String get permDeleteOwnDiaryEntriesDesc =>
      'Rimuovere solo le voci scritte da sé';

  @override
  String get permDeleteAllDiaryEntriesLabel => 'Eliminare tutte le voci';

  @override
  String get permDeleteAllDiaryEntriesDesc =>
      'Rimuovere anche le voci di altre parti; non si può annullare';

  @override
  String get permCommentOnDiaryEntriesLabel => 'Commentare';

  @override
  String get permCommentOnDiaryEntriesDesc => 'Aggiungere qualcosa a una voce';

  @override
  String get permViewSharedEntriesLabel => 'Voci condivise';

  @override
  String get permViewSharedEntriesDesc =>
      'Leggere voci condivise con più parti';

  @override
  String get permViewEmergencyContactsLabel => 'Vedere i contatti di emergenza';

  @override
  String get permViewEmergencyContactsDesc =>
      'Vedere chi è raggiungibile in caso di emergenza';

  @override
  String get permCallEmergencyContactsLabel => 'Chiamare';

  @override
  String get permCallEmergencyContactsDesc =>
      'Chiamare qualcuno subito in caso di emergenza';

  @override
  String get permEditEmergencyContactsLabel =>
      'Modificare i contatti di emergenza';

  @override
  String get permEditEmergencyContactsDesc =>
      'Aggiungere, modificare e rimuovere contatti di emergenza';

  @override
  String get permResetPasswordsLabel => 'Reimpostare le password';

  @override
  String get permResetPasswordsDesc =>
      'Impostare una nuova password per un\'altra parte';

  @override
  String get permChangeOwnPasswordLabel => 'Cambiare la propria password';

  @override
  String get permChangeOwnPasswordDesc =>
      'Impostare una nuova password solo per sé';

  @override
  String get permEnableBiometricsLabel => 'Attivare la biometria';

  @override
  String get permEnableBiometricsDesc =>
      'Accedere con l\'impronta o con il viso';

  @override
  String get permViewChatTabLabel => 'Area chat';

  @override
  String get permViewChatTabDesc => 'Vedere la chat';

  @override
  String get permViewFeedbackTabLabel => 'Area commenti';

  @override
  String get permViewFeedbackTabDesc => 'Scrivere a chi sviluppa Aurora';

  @override
  String get permViewCalendarTabLabel => 'Area calendario';

  @override
  String get permViewCalendarTabDesc => 'Vedere il calendario';

  @override
  String get permViewMedicationTabLabel => 'Area farmaci';

  @override
  String get permViewMedicationTabDesc => 'Vedere il piano dei farmaci';

  @override
  String get permViewDiaryTabLabel => 'Area diario';

  @override
  String get permViewDiaryTabDesc => 'Vedere il diario';

  @override
  String get permViewContactsTabLabel => 'Area contatti';

  @override
  String get permViewContactsTabDesc => 'Vedere i contatti';

  @override
  String get permViewFinderTabLabel => 'Area Trova';

  @override
  String get permViewFinderTabDesc => 'Vedere Trova';

  @override
  String get permViewEmergencyTabLabel => 'Area emergenza';

  @override
  String get permViewEmergencyTabDesc => 'Vedere l\'aiuto di emergenza';

  @override
  String get permViewHelpTabLabel => 'Area aiuto';

  @override
  String get permViewHelpTabDesc => 'Vedere aiuto e punti di riferimento';

  @override
  String get permViewMantrasTabLabel => 'Area mantra';

  @override
  String get permViewMantrasTabDesc => 'Vedere i mantra';

  @override
  String get permViewGamesTabLabel => 'Area giochi';

  @override
  String get permViewGamesTabDesc => 'Vedere i giochi';

  @override
  String get permViewTimelineTabLabel => 'Area linea del tempo';

  @override
  String get permViewTimelineTabDesc =>
      'Vedere quando c\'era quale parte, e in quale luogo';

  @override
  String permissionYouNeed(String permission) {
    return 'Ti serve: $permission';
  }

  @override
  String get fact01 =>
      'Il DID (disturbo dissociativo dell\'identità) riguarda circa l\'1-2% della popolazione.';

  @override
  String get fact02 =>
      'Ogni persona di un sistema può avere gusti, capacità e ricordi propri.';

  @override
  String get fact03 =>
      'La comunicazione interna è un passo importante verso stabilità e guarigione.';

  @override
  String get fact04 =>
      'La dissociazione è una naturale reazione di protezione della psiche.';

  @override
  String get fact05 =>
      'Molte persone con DID funzionano bene e conducono vite riuscite.';

  @override
  String get fact06 =>
      'Aurora è stata creata apposta perché le persone di un sistema parlino tra loro.';

  @override
  String get fact07 =>
      'L\'area chat consente di parlare in sicurezza, senza altre app.';

  @override
  String get fact08 =>
      'Ogni profilo può avere i propri diritti, dall\'accesso completo a uno molto ristretto.';

  @override
  String get fact09 =>
      'Il primo profilo diventa automaticamente amministratore, con tutti i diritti.';

  @override
  String get fact10 =>
      'Il calendario rende visibili gli appuntamenti importanti a tutto il sistema.';

  @override
  String get fact11 =>
      'Nell\'area farmaci puoi gestire sia quelli quotidiani sia quelli al bisogno.';

  @override
  String get fact12 =>
      'Trova aiuta ad annotare gli oggetti persi e a ritrovarli.';

  @override
  String get fact13 =>
      'Il diario di emergenza registra le situazioni difficili per il terapeuta.';

  @override
  String get fact14 =>
      'I mantra possono aiutare a radicarsi durante dissociazione o stress.';

  @override
  String get fact15 =>
      'Nell\'area contatti puoi valutare persone importanti e aggiungere note.';

  @override
  String get fact16 => 'Puoi scegliere un colore proprio per ogni profilo.';

  @override
  String get fact17 =>
      'I messaggi vocali permettono di comunicare anche quando scrivere è faticoso.';

  @override
  String get fact18 =>
      'Gli scarabocchi in chat aiutano a esprimere sentimenti senza parole.';

  @override
  String get fact19 =>
      'Le tue voci restano sul tuo dispositivo. Viene inviato solo ciò che scrivi nel modulo dei commenti.';

  @override
  String get fact20 =>
      'Fare il punto regolarmente con tutto il sistema aiuta a collaborare.';

  @override
  String get fact21 =>
      'Un calendario condiviso evita sovrapposizioni e stress.';

  @override
  String get fact22 =>
      'Le note del diario di emergenza possono aiutare molto in terapia.';

  @override
  String get fact23 =>
      'Ogni persona del sistema può avere bisogni propri: è del tutto normale.';

  @override
  String get fact24 =>
      'Gli esercizi di radicamento aiutano a restare nel qui e ora.';

  @override
  String get fact25 =>
      'Le routine danno sicurezza e struttura a tutto il sistema.';

  @override
  String get fact26 => 'Le pause contano, anche per le persone del sistema.';

  @override
  String get fact27 =>
      'Puoi nascondere i profili quando vuoi e riportarli indietro più tardi.';

  @override
  String get fact28 =>
      'L\'amministratore può modificare i diritti in qualsiasi momento.';

  @override
  String get fact29 =>
      'I farmaci al bisogno si possono registrare sul momento.';

  @override
  String get fact30 => 'In chat puoi rivolgerti a persone precise.';

  @override
  String get fact31 => 'Aurora usa una cifratura forte per i dati sensibili.';

  @override
  String get fact32 => 'Le password non vengono mai salvate in chiaro.';

  @override
  String get fact33 =>
      'Reimpostare una password richiede 24 ore, per sicurezza.';

  @override
  String get fact34 =>
      'Tutti i messaggi della chat restano privati e sono salvati sul dispositivo.';

  @override
  String get fact35 =>
      'Ogni passo verso una comunicazione migliore è un successo.';

  @override
  String get fact36 => 'Va bene avere opinioni diverse dentro il sistema.';

  @override
  String get fact37 => 'Collaborare rende forti, anche dentro.';

  @override
  String get fact38 => 'Non sei solo: molte persone vivono bene con il DID.';

  @override
  String get sliderChat0 => '👁️ Leggere la chat e disegnare';

  @override
  String get sliderChat1 =>
      '✅ Tutto in chat: testo, disegni, voce, immagini, video';

  @override
  String get sliderCalendar0 => '❌ Nessun accesso al calendario';

  @override
  String get sliderCalendar1 => '👁️ Vedere gli appuntamenti';

  @override
  String get sliderCalendar2 => '📅 Creare e modificare i propri appuntamenti';

  @override
  String get sliderCalendar3 =>
      '✅ Gestire tutti gli appuntamenti e aggiungere allegati';

  @override
  String get sliderMedication0 => '❌ Nessun accesso ai farmaci';

  @override
  String get sliderMedication1 => '👁️ Vedere l\'elenco dei farmaci';

  @override
  String get sliderMedication2 => '✅ Confermare le assunzioni';

  @override
  String get sliderDiary0 => '❌ Nessun accesso al diario';

  @override
  String get sliderDiary1 => '👁️ Leggere solo il proprio diario';

  @override
  String get sliderDiary2 => '📝 Scrivere nel proprio diario';

  @override
  String get sliderDiary3 => '✅ Leggere e scrivere in tutti i diari';

  @override
  String get sliderContacts0 => '❌ Nessun accesso ai contatti';

  @override
  String get sliderContacts1 => '👁️ Vedere i contatti';

  @override
  String get sliderContacts2 => '💬 Vedere i contatti e commentare';

  @override
  String get sliderContacts3 =>
      '✅ Gestire i contatti: creare, modificare, eliminare';

  @override
  String get sliderFinder0 => '❌ Nessun accesso a Trova';

  @override
  String get sliderFinder1 => '👁️ Vedere le voci';

  @override
  String get sliderFinder2 => '✅ Gestire le voci';

  @override
  String get sliderEmergencyDiary0 => '❌ Nessun accesso al diario di emergenza';

  @override
  String get sliderEmergencyDiary1 => '👁️ Vedere le voci';

  @override
  String get sliderEmergencyDiary2 =>
      '💬 Creare e commentare voci, modificare le proprie';

  @override
  String get sliderEmergencyDiary3 => '✅ Gestire tutte le voci';

  @override
  String get sliderEmergency0 => '❌ Nessun accesso ai contatti di emergenza';

  @override
  String get sliderEmergency1 => '👁️ Vedere i contatti di emergenza';

  @override
  String get sliderEmergency2 => '📞 Vedere e chiamare i contatti di emergenza';

  @override
  String get sliderEmergency3 => '✅ Gestire i contatti di emergenza';

  @override
  String get sliderHelp0 => '❌ Nessun accesso all\'aiuto';

  @override
  String get sliderHelp1 => '✅ Vedere aiuto e punti di riferimento';

  @override
  String get sliderMantras0 => '❌ Nessun accesso ai mantra';

  @override
  String get sliderMantras1 => '✅ Usare i mantra';

  @override
  String get sliderGames0 => '❌ Nessun accesso ai giochi';

  @override
  String get sliderGames1 => '✅ Giocare';

  @override
  String get settingsDeleteAll => 'Elimina tutto';

  @override
  String get settingsCacheClearHint =>
      'Le mappe si ricaricheranno alla prossima apertura. Può liberare spazio.';

  @override
  String get settingsGpsWhileInUse => 'Consentito durante l\'uso ✓';

  @override
  String get settingsGpsNotAllowed => 'Non consentito';

  @override
  String settingsGpsStatusLine(String status) {
    return '⚠️ $status';
  }

  @override
  String get settingsGpsBackgroundRuns =>
      'Il GPS gira di continuo in secondo piano';

  @override
  String get settingsGpsOverridesAll =>
      'Sostituisce l\'impostazione di tracciamento di TUTTI i profili';

  @override
  String get settingsStepTapPermission => 'Tocca «Autorizzazioni»';

  @override
  String get settingsStepTapLocation => 'Tocca «Posizione»';

  @override
  String get settingsStepChooseAlways => 'Scegli «Consenti sempre»';

  @override
  String get settingsStepOpenSettings =>
      'Tocca sotto «Apri le impostazioni di Android»';

  @override
  String get settingsStepPermissionLocation =>
      'Scegli «Autorizzazioni» → «Posizione»';

  @override
  String get settingsPositionAlways =>
      'La posizione viene registrata di continuo';

  @override
  String get settingsOverridesProfiles =>
      'Sostituisce l\'impostazione di ogni profilo';

  @override
  String get settingsAllProfilesTracked =>
      'Tutti i profili vengono registrati automaticamente';

  @override
  String get settingsOpenGpsSettings => 'Apri le impostazioni GPS';

  @override
  String get settingsGpsRunsForAll =>
      'Il GPS gira di continuo per tutti i profili';

  @override
  String get settingsNotifAsNeeded =>
      'Farmaco al bisogno: Aurora avvisa appena la dose successiva è consentita, 30, 10 e 5 minuti prima';

  @override
  String get settingsNotifWorksClosed => 'Funziona anche ad app chiusa';

  @override
  String get aboutTitle => 'Su Aurora';

  @override
  String get aboutChat =>
      'Parlarsi: con testo, immagini, video e messaggi vocali';

  @override
  String get aboutCalendar =>
      'Appuntamenti condivisi con promemoria e allegati';

  @override
  String get aboutMedication =>
      'Piani dei farmaci con il registro di ogni assunzione';

  @override
  String get aboutEmergencyDiary =>
      'Un diario condiviso per crisi ed eventi importanti';

  @override
  String get aboutContacts =>
      'Le tue valutazioni e note sulle persone attorno a te';

  @override
  String get aboutFinder => 'Ritrovare luoghi e oggetti';

  @override
  String get aboutLocalOnly =>
      'Tutti i dati restano sul tuo dispositivo: niente cloud';

  @override
  String get telemetryQuestion => 'Ci aiuti a migliorare Aurora?';

  @override
  String get telemetryExplanation =>
      'Aurora può contare quali aree vengono aperte e dove i percorsi si interrompono. Vengono inviati solo il nome dell\'evento, il giorno e la versione dell\'app: nessun testo, nessun luogo e niente che riporti a te. Ogni messaggio parte subito, quindi l\'ora di arrivo è anche l\'ora in cui hai usato Aurora.';

  @override
  String get telemetryChangeLater =>
      'Puoi cambiarlo quando vuoi nelle impostazioni, sotto «Cosa invia Aurora». Lì trovi anche ogni singolo messaggio partito dal tuo dispositivo.';

  @override
  String get transparencyIntroFull =>
      'Qui vedi ogni invio partito dal tuo dispositivo: completo e parola per parola.';

  @override
  String get transparencyIrreversibleFull =>
      'Ciò che è già stato inviato non può essere richiamato. Non è collegato a te, ed è anche per questo che non si può trovare né eliminare.';

  @override
  String get transparencyWaitingForConnection => 'In attesa di connessione';

  @override
  String get privacyTitle => 'Informativa sulla privacy';

  @override
  String get privacyAtAGlance => 'La privacy in breve';

  @override
  String get privacyWhatIsStored => 'Quali dati vengono salvati?';

  @override
  String get privacyTransmission => 'Trasmissione dei dati';

  @override
  String get privacyDeletion => 'Eliminazione dei dati';

  @override
  String get privacyMinors => 'Tutela dei minori';

  @override
  String get privacyChanges => 'Modifiche a questa informativa';

  @override
  String get privacyClosing => 'Aurora: i tuoi dati restano con te.';

  @override
  String get mediaImageNotOpened => 'Non è stato possibile aprire l\'immagine';

  @override
  String get mediaVideoNotOpened => 'Non è stato possibile aprire il video';

  @override
  String get mediaFromGallery => 'Dalla galleria';

  @override
  String get mediaPickImage => 'Scegli un\'immagine';

  @override
  String get mediaPickVideo => 'Scegli un video';

  @override
  String get transportDirectToDevelopers => 'Direttamente agli sviluppatori';

  @override
  String get transportSendFailed =>
      'Invio non riuscito. Riprova più tardi o mandalo per e-mail.';

  @override
  String get transportRejected => 'Il server ha rifiutato il messaggio.';

  @override
  String get transportUnreachable =>
      'Il server non è raggiungibile al momento.';

  @override
  String get transparencyArrived => 'Arrivato';

  @override
  String transparencyNotSent(String reason) {
    return 'Non inviato: $reason';
  }

  @override
  String get transparencyReasonUnknown => 'motivo sconosciuto';

  @override
  String get transportTryLaterOrEmail =>
      'Riprova più tardi o mandalo per e-mail.';

  @override
  String get transportEmailInstead =>
      'Puoi inviare il tuo riscontro per e-mail invece.';

  @override
  String get crashDialogTitle => 'Aurora si è chiusa all\'improvviso';

  @override
  String get errorDialogTitle => 'Aurora ha notato un problema';

  @override
  String get errorHelpUsFix => 'Ci aiuti a sistemarlo?';

  @override
  String get errorSendingFailed =>
      'Si è verificato un errore durante l\'invio.';

  @override
  String get feedbackContactOptions => 'Come contattarci';

  @override
  String get feedbackInvalidEmail => 'Questo indirizzo e-mail non è valido';

  @override
  String get feedbackArrived => 'Grazie per il tuo riscontro! È arrivato.';

  @override
  String get feedbackQueued => 'Accettato. Partirà appena tornerai online.';

  @override
  String get feedbackSendFailed => 'Invio non riuscito. Riprova più tardi.';

  @override
  String get profilePickImage => 'Scegli l\'immagine del profilo';

  @override
  String get profilePasswordOptional =>
      'Proteggi il tuo profilo con una password (facoltativo)';

  @override
  String get profilePasswordOptionalMin =>
      'Proteggi il tuo profilo con una password (facoltativo, almeno 4 caratteri)';

  @override
  String get thankYouWeReceived =>
      'Abbiamo ricevuto il tuo rapporto e ti scriveremo per e-mail in caso di domande.';

  @override
  String get thankYouWeCheck => 'Esaminiamo il tuo rapporto';

  @override
  String get thankYouWeFix => 'Lavoriamo a una soluzione';

  @override
  String get thankYouYouGetMail =>
      'Riceverai un\'e-mail appena la soluzione sarà pronta';

  @override
  String get thankYouNextUpdate =>
      'La soluzione arriverà con il prossimo aggiornamento';

  @override
  String get mapGpsLoading => 'Caricamento del GPS…';

  @override
  String get mapGpsPositionLoading => 'Caricamento della posizione…';

  @override
  String get mapAllowLocation =>
      'Consenti l\'accesso alla posizione per vederti sulla mappa';

  @override
  String mapLastKnownPosition(String age) {
    return 'La mappa mostra la tua ultima posizione nota: $age.';
  }

  @override
  String get pwResetThenReplaced =>
      '✓ Solo allora la vecchia password viene sostituita';

  @override
  String get pwResetCanActivateNow => 'Ora puoi attivare la tua nuova password';

  @override
  String get pwResetRunningShort => 'Reimpostazione in corso…';

  @override
  String get moodVeryHappy => 'Molto felice';

  @override
  String get moodHappy => 'Felice';

  @override
  String get moodAnxious => 'In ansia';

  @override
  String get moodAngry => 'Arrabbiato';

  @override
  String get emergencyPositionUnavailable => 'Posizione non disponibile';

  @override
  String get emergencyPositionNoPermission =>
      'Posizione non disponibile (nessuna autorizzazione)';

  @override
  String get emergencyMessageSubject => 'Messaggio di emergenza da Aurora';

  @override
  String autoLogoutAfter(int minutes) {
    return 'Disconnessione automatica dopo $minutes minuti di inattività';
  }

  @override
  String get pwResetBannerReady => 'Password pronta da attivare';

  @override
  String get doodleHistory => 'Scorrere la cronologia';

  @override
  String get doodleDraw => 'Disegnare';

  @override
  String get doodleSendEmptyHint => 'Prima disegna — poi puoi inviare';

  @override
  String get anchorTelemetryNotice =>
      'Il conteggio anonimo è attivo — cosa invia Aurora';

  @override
  String get timePhaseMorning => 'di mattina';

  @override
  String get timePhaseMidday => 'a mezzogiorno';

  @override
  String get timePhaseAfternoon => 'di pomeriggio';

  @override
  String get timePhaseEvening => 'di sera';

  @override
  String get timePhaseNight => 'di notte';

  @override
  String get greetingMorning => 'Buongiorno';

  @override
  String get greetingDay => 'Buongiorno';

  @override
  String get greetingEvening => 'Buonasera';

  @override
  String get anchorSwitchProfile => 'Non sono io';

  @override
  String get greetingNight => 'Buonasera';

  @override
  String get quickTimelineYou => '(Tu)';

  @override
  String todayEvents(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count appuntamenti oggi',
      one: '1 appuntamento oggi',
    );
    return '$_temp0';
  }

  @override
  String todayMedications(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count farmaci oggi',
      one: '1 farmaco oggi',
    );
    return '$_temp0';
  }

  @override
  String workSurfaceActiveProfile(String name) {
    return '$name è qui adesso';
  }

  @override
  String get doodleUndo => 'Annulla';

  @override
  String get doodleClear => 'Cancella tutto';

  @override
  String get finderPersonName => 'Nome della persona';

  @override
  String get finderPlaceTitle => 'Titolo per questo luogo';

  @override
  String get commonLoading => 'Caricamento…';

  @override
  String get puzzleCategoryAnimals => 'Animali teneri che calmano';

  @override
  String get puzzleCategoryWater => 'Mare e acqua';

  @override
  String get puzzleCategoryFlowers => 'Fiori e piante colorati';

  @override
  String get gpsTrackingOffTap =>
      'Registrazione disattivata: tocca per attivarla';

  @override
  String get gpsTrackingOnTap => 'Registrazione attiva: tocca per disattivarla';

  @override
  String get gpsNoPermissionHint =>
      'Senza l\'autorizzazione di posizione Aurora non può avviare la registrazione. Puoi concederla nelle impostazioni di Android, in App → Aurora → Autorizzazioni.';

  @override
  String get settingsCouldNotOpen =>
      'Non è stato possibile aprire le impostazioni.';

  @override
  String get settingsOpenAppSettings => 'Apri le impostazioni dell\'app';

  @override
  String get gpsWaitingFirstUpdate => 'In attesa della prima posizione…';

  @override
  String get imagePickerOpenCamera => 'Apri la fotocamera';

  @override
  String get imagePickerFromGallery => 'Scegli dalla galleria';

  @override
  String get imagePickerAnimalAvatar => 'Scegli un avatar animale';

  @override
  String get animalAvatarDog => 'Cane';

  @override
  String get animalAvatarCat => 'Gatto';

  @override
  String get animalAvatarGiraffe => 'Giraffa';

  @override
  String get puzzleDragPieces => 'Trascina i pezzi al posto giusto';

  @override
  String get puzzleTapPieces => 'Sposta i pezzi toccandoli';

  @override
  String get feedbackTabSend => 'Invia un commento';

  @override
  String get pwResetRunningFull =>
      'Poco fa hai impostato una nuova password. Per sicurezza è in corso un conto alla rovescia di 24 ore.\n\n✓ La tua VECCHIA password resta attiva\n✓ Allo scadere potrai attivare quella nuova\n✓ Solo allora la vecchia viene sostituita';

  @override
  String get transportRejectedFull =>
      'Il server ha rifiutato il messaggio. Mandalo per e-mail invece.';

  @override
  String get transportUnreachableFull =>
      'Il server non è raggiungibile al momento. Riprova più tardi o mandalo per e-mail.';

  @override
  String transportFailedWithCode(String code) {
    return 'Invio non riuscito ($code). Puoi inviare il tuo riscontro per e-mail invece.';
  }

  @override
  String get transportNoMailApp =>
      'Non è stato possibile aprire nessuna app di posta. Puoi copiare il testo e inviarlo tu.';

  @override
  String get emergencySmsSubject => 'Messaggio di emergenza da Aurora';

  @override
  String get pwResetBannerRunning => 'Reimpostazione in corso';

  @override
  String get puzzleDragHint => 'Trascina i pezzi al posto giusto';

  @override
  String get puzzleTapHint => 'Sposta i pezzi toccandoli';

  @override
  String get medicationConfirm => 'Conferma';

  @override
  String get medicationAddFirstAsNeeded =>
      'Aggiungi il tuo primo farmaco al bisogno';

  @override
  String medicationTakenBy(String name) {
    return '✓ Preso da $name';
  }

  @override
  String medicationRefusedBy(String name) {
    return '✗ Rifiutato da $name';
  }

  @override
  String get imprintPerLaw =>
      'Informazioni ai sensi del § 5 TMG (legge tedesca)';

  @override
  String get imprintResponsible => 'Responsabile del contenuto';

  @override
  String get timelineSkipped => 'saltato';

  @override
  String get timelineDueSoon => 'A breve';

  @override
  String get medicationLater => 'più tardi';

  @override
  String get debugLogHint =>
      'Questo rapporto contiene dettagli tecnici sull\'app. Copialo con il pulsante in alto a destra per inviarlo in caso di problemi.';

  @override
  String get unsavedChangesTitle => 'Modifiche non salvate';

  @override
  String get hotlineForYoung => 'Per bambini e ragazzi';

  @override
  String get hotlineAnonymousFree => 'Gratuito e anonimo';

  @override
  String get hotlineHoursNumberAgainstSorrow => 'Lun–Sab 14–20';

  @override
  String get hotlineInfoNotAcute => 'Informazioni, non aiuto acuto';

  @override
  String get hotlineHoursDepressionInfo =>
      'Lun, Mar, Gio 13–17 · Mer, Ven 8:30–12:30';

  @override
  String get hotlineChatUnder25 =>
      'Consulenza in chat, per chi ha meno di 25 anni';

  @override
  String get helpEmergencyDangerTitle => 'Se qualcuno è in pericolo immediato';

  @override
  String get helpEmergencyDangerBody =>
      'Il numero di emergenza risponde giorno e notte, anche senza credito.';

  @override
  String get helpEmergencyCallEmergencyNumber => 'Emergenze 112';

  @override
  String get helpTalkTitle => 'Se hai bisogno di parlare o di una consulenza';

  @override
  String get helpGroupRoundTheClock => 'Raggiungibile 24 ore su 24';

  @override
  String get helpGroupLimitedHours => 'Raggiungibile in orari precisi';

  @override
  String helpSourcesCheckedOn(String datum) {
    return 'Dati verificati il $datum';
  }

  @override
  String get cameraCouldNotOpen => 'Non è stato possibile aprire la fotocamera';

  @override
  String get feedbackDeviceDiagnostics => '--- Diagnostica del dispositivo ---';

  @override
  String get eventNoReminder =>
      'L\'appuntamento è solo nel calendario. Aurora non si farà sentire da sola.';

  @override
  String get unsavedChangesMessage =>
      'Hai fatto delle modifiche.\n\nVuoi salvarle?';

  @override
  String get confirmSave => 'Salva';

  @override
  String get videoCouldNotLoad => 'Non è stato possibile caricare il video';

  @override
  String get finderDaily => 'ogni giorno';

  @override
  String get mapNotAvailable => 'Mappa non disponibile';

  @override
  String get medicationAnotherDose => 'Vuoi comunque prendere un\'altra dose?';

  @override
  String get feedbackThankYouReceived =>
      'Abbiamo ricevuto il tuo riscontro e ti scriveremo per e-mail in caso di domande.';

  @override
  String get positionAgeYesterday => 'di ieri';

  @override
  String get timePickerTitle => 'Scegli l\'orario';

  @override
  String get reminderPermissionMissingTitle =>
      'Aurora non può ricordartelo al momento';

  @override
  String reminderPermissionMissingBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'I promemoria sono attivi per $count orari di assunzione. Senza il permesso del dispositivo non ne arriva nessuno.',
      one:
          'I promemoria sono attivi per un orario di assunzione. Senza il permesso del dispositivo non arriverà.',
    );
    return '$_temp0';
  }

  @override
  String get reminderPermissionMissingAction => 'Concedi il permesso';

  @override
  String get timePickerHours => 'Ore';

  @override
  String get timePickerMinutes => 'Minuti';

  @override
  String get commentsNoneYet => 'Ancora nessun commento';

  @override
  String get notificationDiscreetBody => 'Promemoria: tocca per vedere';

  @override
  String get reminderNoPermission =>
      'Senza l autorizzazione per le notifiche Aurora non può ricordartelo. Puoi concederla nelle impostazioni di Android, in App → Aurora → Notifiche.';

  @override
  String get telemetryConsentAccept => 'Sì, volentieri';

  @override
  String get telemetryConsentDecline => 'Continua senza';

  @override
  String get transparencyGroupTelemetry => 'Telemetria';

  @override
  String get telemetryExampleIntro => 'Ecco come appare un messaggio:';

  @override
  String get telemetryExampleEvent => 'Evento';

  @override
  String get telemetryExampleDay => 'Giorno';

  @override
  String get telemetryExampleVersion => 'Versione dell\'app';

  @override
  String get onboardingDismiss => 'Non mostrare più';

  @override
  String get eventStart => 'Inizio';

  @override
  String get eventEnd => 'Fine';

  @override
  String get chatCapturePhoto => 'Scatta una foto';

  @override
  String get chatCaptureImageShort => 'Foto';

  @override
  String get doodleErase => 'Cancella';

  @override
  String get chatRecordVideo => 'Registra un video';

  @override
  String get chatRecordVideoSubtitle => 'Crea un nuovo video';

  @override
  String get actionDiscard => 'Scarta';

  @override
  String get actionKeep => 'Tieni';

  @override
  String get actionDetails => 'Dettagli';

  @override
  String get resetWaitingPeriodTitle => 'Tempo di attesa per la reimpostazione';

  @override
  String get fieldNameHint => 'p. es. Max, Anna, Leo';

  @override
  String get fieldPasswordHint => 'Almeno 4 caratteri';

  @override
  String get fieldPasswordConfirmHint => 'Ripeti la password';

  @override
  String get fieldPasswordEnterHint => 'Scrivi la password';

  @override
  String get feedbackCommunityJoin => 'Unisciti alla nostra community';

  @override
  String get feedbackDiscord => 'Server Discord';

  @override
  String get feedbackGithub => 'GitHub';

  @override
  String get feedbackGithubSubtitle => 'Bug e segnalazioni';

  @override
  String get timelineProfileSwitch => 'Cambio di profilo';

  @override
  String get debugLogReportTitle => 'Rapporto diagnostico';

  @override
  String get formPickImage => 'Scegli un’immagine';

  @override
  String get permissionGrant => 'Concedi il permesso';

  @override
  String get pwResetRestart => 'Ricomincia';

  @override
  String get navBackToAnchor => 'All’ancora';

  @override
  String get mapGpsPositionLoadingHint => 'Un attimo';

  @override
  String get voiceRecordingStartFailed =>
      'Non è stato possibile avviare la registrazione';

  @override
  String get voiceRecordingStopFailed =>
      'Non è stato possibile terminare la registrazione';

  @override
  String get voiceRecordingDiscardFailed =>
      'Non è stato possibile scartare la registrazione';

  @override
  String get trackingPermissionDeniedHint =>
      'Permesso di posizione negato. Attivalo nelle impostazioni.';

  @override
  String get pwResetVisibleToAll =>
      'Il tempo di attesa scorre alla vista di tutti';

  @override
  String get pwResetRestartResetsTimer =>
      'Nota: ricominciare azzera il tempo di attesa';

  @override
  String get pwResetActivatedAtNextLogin =>
      'La nuova password si attiva al prossimo accesso';

  @override
  String get imagePickerCameraDeniedForever =>
      'Il permesso per la fotocamera è stato negato per sempre. Attivalo nelle impostazioni.';

  @override
  String get imagePickerGalleryDeniedForever =>
      'Il permesso per la galleria è stato negato per sempre. Attivalo nelle impostazioni.';

  @override
  String get permissionCameraTitle => 'Permesso fotocamera';

  @override
  String get permissionGalleryTitle => 'Permesso galleria';

  @override
  String get profileResetFristExplanation =>
      'È il tempo che una reimpostazione della password aspetta prima di valere. Se accedi entro quel tempo, si annulla.';

  @override
  String get cameraNotFound => 'Nessuna fotocamera trovata';

  @override
  String get validationNameRequired => 'Scrivi un nome';

  @override
  String get validationPasswordRequired => 'Scrivi la password';

  @override
  String get transportCopyManually => 'Puoi copiare il testo e inviarlo tu.';

  @override
  String get statusSending => 'Invio in corso...';

  @override
  String get errorReportSendButton => 'Invia il rapporto';

  @override
  String get settingsGpsStatusAlwaysReady => '✅ Sempre consentito (pronto!)';

  @override
  String get gpsActive => 'GPS attivo';

  @override
  String get gpsOff => 'GPS spento';

  @override
  String get gpsStatusUnknown => 'Stato del GPS sconosciuto';

  @override
  String get gpsPermissionMissing => 'Manca il permesso di posizione';

  @override
  String get gpsServiceDisabled => 'Servizio di posizione disattivato';

  @override
  String get permissionMissingShort => 'Manca il permesso';

  @override
  String get pwResetWrongPassword => 'Password sbagliata';

  @override
  String get pwResetStartTitle => 'Avviare la reimpostazione?';

  @override
  String get pwResetExpired => 'Il tempo di attesa è finito';

  @override
  String get pwResetForgotPassword => 'Hai dimenticato la password?';

  @override
  String get commentWritePlaceholder => 'Scrivi un commento...';

  @override
  String get profileVisibilityTitle => 'A quali profili appartiene';

  @override
  String get addressUnknown => 'Indirizzo sconosciuto';

  @override
  String get activateNow => 'Attiva ora';

  @override
  String get eventRemindMe => 'Promemoria';

  @override
  String get noProfileAvailable => 'Ancora nessun profilo';

  @override
  String get ratingVeryNegative => 'Molto negativo';

  @override
  String get ratingVeryPositive => 'Molto positivo';

  @override
  String get errorReportHelpUs => 'Aiutaci a sistemare il problema';

  @override
  String get errorReportDetailsSection => 'Dettagli del rapporto';

  @override
  String get trackingLabel => 'Rilevamento GPS: ';

  @override
  String trackingLastUpdate(Object time) {
    return 'Ultimo aggiornamento: $time';
  }

  @override
  String profileSwitchError(Object error) {
    return 'Non è stato possibile cambiare profilo: $error';
  }

  @override
  String get gpsError => 'Errore GPS';

  @override
  String get statusActive => 'Attivo';

  @override
  String get statusPaused => 'In pausa';

  @override
  String timeSecondsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count secondi fa',
      one: 'un secondo fa',
    );
    return '$_temp0';
  }

  @override
  String timeInMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tra $count minuti',
      one: 'tra un minuto',
    );
    return '$_temp0';
  }

  @override
  String timeInHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tra $count ore',
      one: 'tra un’ora',
    );
    return '$_temp0';
  }

  @override
  String timeInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tra $count giorni',
      one: 'tra un giorno',
    );
    return '$_temp0';
  }

  @override
  String get languageFollowApp => 'Lingua dell\'app';

  @override
  String get profileLanguageSubtitle =>
      'La lingua in cui Aurora parla con questa parte';

  @override
  String get contactCategoryFamily => 'Famiglia';

  @override
  String get contactCategoryFriends => 'Amici';

  @override
  String get contactCategoryTherapists => 'Terapeuti';

  @override
  String get contactCategoryDoctors => 'Medici';

  @override
  String get contactCategoryEmergency => 'Emergenza';

  @override
  String get contactCategoryOther => 'Altro';

  @override
  String get finderTypeLocation => 'Luogo';

  @override
  String get finderTypeItem => 'Oggetto';

  @override
  String get diaryPriorityLow => 'Bassa';

  @override
  String get diaryPriorityMedium => 'Media';

  @override
  String get diaryPriorityHigh => 'Alta';

  @override
  String get diaryPriorityCritical => 'Critica';

  @override
  String get moodNeutral => 'Neutro';

  @override
  String get moodSad => 'Triste';

  @override
  String get moodVerySad => 'Molto triste';

  @override
  String get moodExcited => 'Emozionato';

  @override
  String timeHoursMinutesAgo(Object hours, Object minutes) {
    return '$hours h $minutes min fa';
  }

  @override
  String presenceLastFront(Object when) {
    return 'ultima volta $when';
  }

  @override
  String get privacyGlanceBody =>
      'Aurora conserva tutto sul tuo dispositivo. Tre cose lo lasciano, e solo se sei tu a farle partire o a permetterle: il feedback che invii, la telemetria dopo il tuo consenso e le richieste di mappe a OpenStreetMap.\n\nChe cosa è stato inviato e quando è scritto parola per parola nelle Impostazioni, sotto «Che cosa invia Aurora». Nulla di tutto ciò riconduce a te.';

  @override
  String get privacyStoredBody =>
      'Questi dati stanno nel database locale del tuo dispositivo:\n\n• Parti e impostazioni\n• Messaggi tra le parti\n• Appuntamenti del calendario\n• Piani terapeutici e assunzioni\n• Voci del diario e di emergenza\n• Contatti con valutazioni e note\n• Luoghi e oggetti del cercatore\n• Cronologia della posizione e cambi di parte\n• Immagini, video e messaggi vocali\n\nNulla di questo viene trasmesso.';

  @override
  String get privacyTransmissionBody =>
      'Feedback — solo quando invii il modulo. Contiene il tuo testo, la versione dell’app e il modello del dispositivo. Nessun nome, nessun identificativo, nessun luogo.\n\nTelemetria — solo dopo il tuo consenso esplicito, che puoi revocare in qualsiasi momento. Un evento porta tre campi: che cosa è successo, in quale giorno, con quale versione dell’app. Nessun orario, nessun identificativo.\n\nMappe — quando si mostra una mappa e si risolve un indirizzo, la porzione di mappa visibile e il tuo indirizzo IP vanno a OpenStreetMap. È la condizione perché una mappa esista.\n\nMai trasmessi: cronologia della posizione, parti, messaggi, appuntamenti, farmaci, diario e contatti.';

  @override
  String get privacyPermissions => 'Autorizzazioni';

  @override
  String get privacyPermissionsBody =>
      '• Posizione — per la mappa, la cronologia della posizione e la schermata di emergenza. Resta sul dispositivo.\n• Posizione in background — solo se attivi la registrazione continua. Senza quell’interruttore non serve.\n• Fotocamera e microfono — per foto e messaggi vocali.\n• Memoria — per caricare immagini e video dalla galleria.\n• Notifiche e sveglie — per i promemoria di farmaci e appuntamenti.\n\nOgni autorizzazione può essere revocata nelle impostazioni di sistema. L’app dirà allora che cosa non funziona più.';

  @override
  String get privacySecurity => 'Sicurezza dei dati';

  @override
  String get privacySecurityBody =>
      '• Tutti i dati sono locali; non esiste sincronizzazione nel cloud.\n• Le parti possono essere protette con una password.\n• Non ci sono account utente né accesso.\n\nI backup sono una tua responsabilità. Se il dispositivo si perde o si rompe, i dati sono persi: è il prezzo del fatto che non stiano da nessun’altra parte.';

  @override
  String get privacyDeletionBody =>
      '• Puoi cancellare singole voci e messaggi.\n• Le parti si possono disattivare o cancellare.\n• Nelle Impostazioni c’è «Cancella tutti i dati».\n• Disinstallando l’app sparisce tutto con essa.\n\nCiò che è cancellato non si può recuperare.';

  @override
  String get privacyRights => 'I tuoi diritti';

  @override
  String get privacyRightsBody =>
      'Il GDPR ti riconosce il diritto di accesso, rettifica, cancellazione, limitazione, portabilità e opposizione. Poiché tutti i dati stanno sul tuo dispositivo, la maggior parte la eserciti direttamente nell’app.\n\nPer il feedback inviato e per la telemetria rivolgiti all’indirizzo qui sotto. Hai inoltre il diritto di presentare reclamo a un’autorità per la protezione dei dati.';

  @override
  String get privacyMinorsBody =>
      'Aurora può essere usata da minori. Su di loro non si raccolgono dati diversi da quelli di chiunque altro — cioè nessuno, salvo per le tre vie indicate sopra.\n\nPer gli utenti più giovani è sensato che una persona responsabile accompagni la configurazione.';

  @override
  String get privacyChangesBody =>
      'Questa dichiarazione può cambiare con gli aggiornamenti dell’app. La versione in vigore è quella mostrata qui e porta la sua data in fondo.';

  @override
  String get privacyContact => 'Titolare e contatto';

  @override
  String privacyAsOf(Object date) {
    return 'Aggiornato: $date';
  }

  @override
  String get startupFailedTitle => 'Aurora non è riuscita ad avviarsi';

  @override
  String get startupFailedBody =>
      'Qualcosa non ha funzionato all\'avvio. Puoi riprovare. Se non basta, è possibile eliminare tutti i dati salvati: Aurora ripartirà vuota.';

  @override
  String get startupRetry => 'Riprova';

  @override
  String get startupDeleteAll => 'Elimina tutti i dati';

  @override
  String get startupDeleteIncomplete =>
      'Non è stato possibile eliminare tutto. Una parte è ancora qui.';

  @override
  String get reminderPermissionBlocked =>
      'Aurora non può ancora ricordarti nulla. Puoi concedere l\'autorizzazione nelle impostazioni di sistema.';

  @override
  String get reminderOpenSettings => 'Apri le impostazioni';

  @override
  String get settingsTrackingPermissionNeeded =>
      'Per ricordare il tuo percorso, Aurora ha bisogno di accedere alla posizione.';

  @override
  String get settingsHowToEnableLocation => 'Come consentire la posizione:';

  @override
  String get settingsStepChooseWhileUsing => 'Scegli «Mentre usi l\'app»';

  @override
  String get settingsTrackingNotice =>
      'Mentre Aurora registra, una notifica resta nella barra. Senza notifica, nessuna registrazione.';

  @override
  String get locationTrackingNotificationTitle =>
      'Aurora ricorda il tuo percorso';

  @override
  String get locationTrackingNotificationBody =>
      'Così potrai ritrovare i tuoi luoghi. Resta sul dispositivo.';

  @override
  String profileContinueAs(String name) {
    return 'Continua come $name';
  }

  @override
  String get profileContinueInProgress => 'Un momento …';

  @override
  String get trackingPausedTitle => 'Registrazione in pausa';

  @override
  String get trackingPausedBody =>
      'Dopo il riavvio, Aurora registra di nuovo il tuo percorso solo quando la apri. Tocca qui.';

  @override
  String get aboutAuroraSemantics => 'Informazioni su Aurora';

  @override
  String get openTimelineSemantics => 'Apri la cronologia';

  @override
  String get timeMapSemantics => 'Apri la cronologia: mappa con ora e luogo';
}
