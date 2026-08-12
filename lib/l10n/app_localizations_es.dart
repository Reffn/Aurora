// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Aurora';

  @override
  String get appSubtitle => 'Tu compañera segura en el día a día con TID';

  @override
  String get appDescription =>
      'Aurora te acompaña a organizar tu día a día y la comunicación dentro de tu sistema.';

  @override
  String get tabChat => 'Chat';

  @override
  String get tabFeedback => 'Comentarios';

  @override
  String get tabCalendar => 'Calendario';

  @override
  String get tabMedication => 'Medicación';

  @override
  String get tabDiary => 'Diario';

  @override
  String get tabContacts => 'Contactos';

  @override
  String get tabFinder => 'Buscador';

  @override
  String get tabEmergency => 'Emergencia';

  @override
  String get tabHelp => 'Ayuda';

  @override
  String get tabMantras => 'Mantras';

  @override
  String get tabGames => 'Juegos';

  @override
  String get tabTimeline => 'Cronología';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDelete => 'Borrar';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get actionConfirm => 'Confirmar';

  @override
  String get actionBack => 'Atrás';

  @override
  String get actionQuit => 'Salir';

  @override
  String get actionSend => 'Enviar';

  @override
  String get actionShare => 'Compartir';

  @override
  String get actionDone => 'Listo';

  @override
  String get mainSettingLogout => 'Ajustes / Cerrar sesión';

  @override
  String get dialogExitTitle => '¿Salir de la app?';

  @override
  String get dialogExitMessage => '¿Seguro que quieres salir de Aurora?';

  @override
  String get menuProfileEdit => 'Editar perfil';

  @override
  String get menuSettings => 'Ajustes';

  @override
  String get menuLogout => 'Cerrar sesión';

  @override
  String get profileMenuTitle => 'Perfil y ajustes';

  @override
  String get presenceRecentTitle => '¿Quién estuvo aquí?';

  @override
  String get eventLocationTitle => '¿Dónde tiene lugar?';

  @override
  String get eventLocationOther => 'Otro lugar';

  @override
  String get eventLocationNone => 'Sin lugar';

  @override
  String get eventLocationLabel => 'Lugar';

  @override
  String get eventLocationUnnamed => 'Lugar en el mapa';

  @override
  String get mapLocationNeeded =>
      'Aurora necesita tu ubicación para este mapa. Se queda en el dispositivo.';

  @override
  String get mapLocationAllow => 'Permitir';

  @override
  String get profileSelectionTitle => '¿Quién está aquí ahora?';

  @override
  String get profileNewProfile => 'Perfil nuevo';

  @override
  String get profileCreationTitle => 'Crear un perfil nuevo';

  @override
  String get profileCreationSubtitle => '¿Quién quiere presentarse?';

  @override
  String get profileCreationDescription =>
      'Crea tu perfil personal con nombre, color y avatar. Cada perfil se puede personalizar por separado y recibe permisos acordes a la edad.';

  @override
  String get profileEditTitle => 'Editar perfil';

  @override
  String get profileEditSubtitle => 'Ajusta tu configuración';

  @override
  String get profileSectionIdentity => '👤 Identidad';

  @override
  String get profileSectionAge => '🎂 Edad';

  @override
  String get profileSectionColor => '🎨 Color';

  @override
  String get profileSectionSecurity => '🔒 Preguntas de seguridad';

  @override
  String get profileWhoAreYou => '¿Quién eres?';

  @override
  String get profileWhoAreYouDescription =>
      'Escribe tu nombre y elige un avatar. Así todo el mundo en el sistema puede reconocerte y distinguirte. También puedes hacer una foto, elegir una de la galería o usar una de las plantillas de animales.';

  @override
  String get profileColorTitle => 'Tu color propio';

  @override
  String get profileColorDescription =>
      'Tu color te hace inconfundible dentro del sistema.';

  @override
  String get profileAgeTitle => '¿Cuántos años tienes?';

  @override
  String get profileAgeDescription =>
      'Tu edad determina qué funciones puedes usar.';

  @override
  String get profileSecurityTitle => 'Protege tu perfil';

  @override
  String get profileSecurityDescription =>
      'Si quieres, puedes poner una contraseña (mínimo 4 caracteres).';

  @override
  String get profilePasswordOptionalInfo =>
      'La contraseña es opcional. Deja los campos vacíos si no quieres poner ninguna.';

  @override
  String get profileModeChild => 'Modo infantil';

  @override
  String get profileModeFullAccess => 'Acceso completo';

  @override
  String get profileModeChildDescription =>
      'Acceso a: Chat (dibujos), Diario, Juegos, Cronología';

  @override
  String get profileModeFullDescription =>
      'Acceso a: todas las funciones (Chat, Calendario, Contactos, Medicación, etc.)';

  @override
  String get profileActionSaveChanges => 'Guardar cambios';

  @override
  String get profileActionCreateProfile => 'Crear perfil ✓';

  @override
  String get profileDeactivateTitle => '¿Desactivar el perfil?';

  @override
  String profileDeactivateMessage(String name) {
    return '¿Quieres desactivar el perfil «$name»?\n\nSe ocultará, pero podrás reactivarlo más adelante.';
  }

  @override
  String get profileDeactivated => 'Perfil desactivado';

  @override
  String get profileDeactivate => 'Desactivar';

  @override
  String get profileEditComingSoon => 'La edición llegará pronto';

  @override
  String get profileNameExists => 'Ya existe un perfil con ese nombre';

  @override
  String get fieldName => 'Nombre';

  @override
  String get fieldPassword => 'Contraseña';

  @override
  String get fieldPasswordConfirm => 'Repetir contraseña';

  @override
  String get fieldAge => 'Edad';

  @override
  String get fieldColor => 'Color';

  @override
  String get fieldAvatar => 'Avatar';

  @override
  String get validationRequired => 'Campo obligatorio';

  @override
  String get validationPasswordLength => 'Mínimo 4 caracteres';

  @override
  String get validationPasswordMismatch => 'Las contraseñas no coinciden';

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get errorNoProfile => 'Ningún perfil seleccionado';

  @override
  String get errorNoPermission =>
      'No tienes permiso para enviar mensajes de chat';

  @override
  String get chatTitle => 'Chat';

  @override
  String get chatEmptyTitle => 'Todavía no hay mensajes';

  @override
  String get chatEmptySubtitle => 'Comparte lo que piensas con el sistema';

  @override
  String get chatMessageDoodle => '[Dibujo]';

  @override
  String get chatMessageVoice => '[Mensaje de voz]';

  @override
  String get chatMessageImage => '[Imagen]';

  @override
  String get chatMessageVideo => '[Vídeo]';

  @override
  String chatErrorSending(String error) {
    return 'Error al enviar: $error';
  }

  @override
  String chatErrorSendingVoice(String error) {
    return 'Error al enviar el mensaje de voz: $error';
  }

  @override
  String chatErrorSendingImage(String error) {
    return 'Error al enviar la imagen: $error';
  }

  @override
  String chatErrorSendingVideo(String error) {
    return 'Error al enviar el vídeo: $error';
  }

  @override
  String chatErrorSendingDoodle(String error) {
    return 'Error al enviar: $error';
  }

  @override
  String get chatRecordingInProgress => 'Grabando...';

  @override
  String get chatRecordingHint => 'Toca Detener para enviar el mensaje de voz';

  @override
  String get chatRecordingStop => 'Detener';

  @override
  String get chatErrorMicPermission => 'Se necesita permiso para el micrófono';

  @override
  String get chatErrorRecordingStart => 'No se pudo iniciar la grabación';

  @override
  String get chatInputHint => 'Escribe un mensaje...';

  @override
  String get chatMessageFieldLabel => 'Mensaje';

  @override
  String get chatAddMedia => 'Añadir más contenido';

  @override
  String get chatSendMessage => 'Enviar mensaje';

  @override
  String get chatMediaSheetTitle => 'Añadir contenido';

  @override
  String get chatNoPermissionHint => 'Sin permiso para enviar';

  @override
  String get calendarTitle => 'Calendario';

  @override
  String get medicationTitle => 'Medicación';

  @override
  String get medicationNewTitle => 'Nuevo medicamento';

  @override
  String get medicationEditTitle => 'Editar medicamento';

  @override
  String get medicationDetailTitle => 'Detalles del medicamento';

  @override
  String get medicationNotFound => 'Medicamento no encontrado';

  @override
  String get medicationNotFoundMessage => 'Este medicamento ya no existe';

  @override
  String get medicationTabDaily => 'Medicación diaria';

  @override
  String get medicationTabAsNeeded => 'Medicación según necesidad';

  @override
  String get medicationEmptyTitle => 'Sin medicación 💊';

  @override
  String get medicationEmptySubtitle => 'Añade tu primer medicamento';

  @override
  String get medicationEmptyAsNeededTitle =>
      'Sin medicación según necesidad 🩹';

  @override
  String get medicationEmptyAsNeededSubtitle =>
      'Añade tu primer medicamento según necesidad';

  @override
  String get medicationToday => 'Hoy';

  @override
  String get medicationStatMedications => 'Medicamentos';

  @override
  String get medicationStatDoses => 'Dosis';

  @override
  String medicationMarkedTaken(String name) {
    return '$name marcado como tomado';
  }

  @override
  String medicationMarkedRefused(String name) {
    return '$name marcado como rechazado';
  }

  @override
  String get medicationRefusalDialogTitle => 'Anotar el rechazo';

  @override
  String medicationRefusalDialogMessage(String name) {
    return '$name se marcará como rechazado.';
  }

  @override
  String get medicationRefusalReasonLabel => 'Motivo (opcional)';

  @override
  String get medicationRefusalReasonHint => 'p. ej. náuseas, cansancio, etc.';

  @override
  String get medicationRefusalWithoutNote => 'Sin nota';

  @override
  String get medicationFeedbackDialogTitle => 'Añadir una nota';

  @override
  String medicationFeedbackQuestion(String name) {
    return '¿Cómo te sentiste después de tomar $name?';
  }

  @override
  String get medicationFeedbackLabel => 'Tu experiencia';

  @override
  String get medicationFeedbackHint =>
      'p. ej. «me dio sueño», «me ayudó mucho», etc.';

  @override
  String get medicationFeedbackSaved => 'Nota guardada';

  @override
  String get medicationFeedbackViewTitle => 'Notas';

  @override
  String get diaryTitle => 'Diario';

  @override
  String get diaryEmptyTitle => '¡Tu diario te espera! ✨';

  @override
  String get diaryEmptySubtitle =>
      'Recoge tus pensamientos, vivencias y momentos';

  @override
  String get contactsTitle => 'Contactos';

  @override
  String get contactsFilterAll => 'Todos';

  @override
  String get contactsEmptyTitle => 'Todavía no hay contactos 👥';

  @override
  String get contactsEmptySubtitle => 'Toca + para añadir un contacto';

  @override
  String get contactsEmptyFilteredTitle => 'No se han encontrado contactos 🔍';

  @override
  String get contactsEmptyFilteredSubtitle => 'Prueba con otro filtro';

  @override
  String get finderTitle => 'Buscador';

  @override
  String get finderTabLocations => 'Lugares';

  @override
  String get finderTabItems => 'Objetos';

  @override
  String get finderEmptyLocationsTitle => 'Todavía no hay lugares';

  @override
  String get finderEmptyItemsTitle => 'Todavía no hay objetos';

  @override
  String get finderEmptyLocationsSubtitle => 'Toca + para añadir un lugar';

  @override
  String get finderEmptyItemsSubtitle => 'Toca + para añadir un objeto';

  @override
  String get emergencyTitle => 'Emergencia';

  @override
  String get emergencyEmptyTitle => 'Todavía no hay contactos de emergencia';

  @override
  String get emergencyEmptySubtitle =>
      'Añade contactos con la categoría «Emergencia» para verlos aquí.';

  @override
  String get emergencyEmptyDescription =>
      'A estos contactos se les puede avisar rápido en una emergencia.';

  @override
  String get emergencyEmptyAddContact => 'Añadir contacto de emergencia';

  @override
  String get emergencyEmptyOpenHelp => 'Ayuda y teléfonos de crisis';

  @override
  String get emergencySendSmsAll => 'Enviar SMS de EMERGENCIA a todos';

  @override
  String get emergencyShareAll => 'Enviar a todos por la app';

  @override
  String get emergencySmsDialogTitle => '¿Enviar SMS de EMERGENCIA a todos?';

  @override
  String emergencySmsDialogMessage(int count) {
    return 'El mensaje de emergencia se enviará a $count contactos.';
  }

  @override
  String get emergencySendNow => 'Enviar ahora';

  @override
  String get emergencyMessagePreparing =>
      'Preparando el mensaje de emergencia...';

  @override
  String emergencyErrorSms(String error) {
    return 'Error al enviar el SMS: $error';
  }

  @override
  String emergencyErrorShare(String error) {
    return 'Error al compartir: $error';
  }

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSectionDebug => '🔧 Opciones de desarrollo';

  @override
  String get settingsDebugInfo =>
      'Estas opciones solo se ven durante el desarrollo';

  @override
  String get settingsDebugSkipCooldown => '⏩ Poner el temporizador en 20 s';

  @override
  String settingsDebugSkipCooldownInfo(String name, String time) {
    return 'Perfil: $name\nRestante: $time';
  }

  @override
  String get settingsDebugCooldownSet =>
      '⏩ ¡Temporizador puesto en 20 segundos!\nDespués de 20 s se puede activar la contraseña.';

  @override
  String get settingsDebugCooldownError => '❌ Error al poner el temporizador';

  @override
  String get settingsDeleteAllData => 'Borrar todos los datos';

  @override
  String get settingsDeleteAllDataSubtitle =>
      'Borra todos los perfiles, mensajes, eventos y adjuntos';

  @override
  String get settingsDeleteConfirmTitle => '⚠️ Aviso';

  @override
  String get settingsDeleteConfirmMessage =>
      'Esta acción borrará TODOS los datos:\n\n• Todos los perfiles\n• Todos los mensajes de chat\n• Todos los eventos del calendario\n• Toda la medicación y su registro de tomas\n• Todos los contactos\n• Todos los objetos del buscador\n• Todas las entradas del diario de crisis\n• Todos los datos de navegación\n• Todos los ajustes\n• Todos los dibujos adjuntos\n\n¡Esto NO se puede deshacer!';

  @override
  String get settingsDeleteSuccess => '✅ Se han borrado todos los datos';

  @override
  String get settingsSectionManagement => 'Administración';

  @override
  String get settingsPermissions => 'Derechos y permisos';

  @override
  String get settingsPermissionsSubtitle =>
      'Gestionar los derechos de acceso de los perfiles';

  @override
  String get settingsSectionGlobal => 'Ajustes globales';

  @override
  String get settingsGlobalTrackingInfo =>
      '¿Qué es el «seguimiento permanente»?';

  @override
  String get settingsGlobalTrackingDescription =>
      'Como administradora puedes controlar el GPS de TODOS los perfiles de forma central. Si está activado:';

  @override
  String get settingsGlobalTrackingBullet1 =>
      'La ubicación se registra de forma continua';

  @override
  String get settingsGlobalTrackingBullet2 => 'Funciona en segundo plano';

  @override
  String get settingsGlobalTrackingBullet3 =>
      'Prevalece sobre los ajustes de cada perfil';

  @override
  String get settingsGlobalTrackingBullet4 =>
      'Se hace seguimiento de todos los perfiles automáticamente';

  @override
  String get settingsGlobalTrackingRequirement =>
      'Requisito: el permiso de Android «Permitir siempre» tiene que estar activado para que el seguimiento funcione con la app cerrada.';

  @override
  String get settingsGpsPermissionTitle => 'Permiso de GPS';

  @override
  String get settingsGpsStatusDisabled => 'Servicio de GPS desactivado';

  @override
  String get settingsGpsStatusDenied => 'Permiso denegado';

  @override
  String get settingsGpsStatusDeniedForever => 'Denegado de forma permanente';

  @override
  String get settingsGpsStatusWhileInUse => 'Solo mientras usas la app';

  @override
  String get settingsGpsStatusAlways => 'Permitido siempre ✓';

  @override
  String get settingsGpsStatusUnknown => 'Desconocido';

  @override
  String get settingsGpsReady =>
      '¡Perfecto! El seguimiento en segundo plano está listo.';

  @override
  String get settingsGpsInstructions => 'Cómo activar «Permitir siempre»:';

  @override
  String get settingsGpsStep1 => 'Toca «Abrir ajustes de Android» ↓';

  @override
  String get settingsGpsStep2 => 'Elige «Permisos» → «Ubicación»';

  @override
  String get settingsGpsStep3 => 'Elige «Permitir siempre»';

  @override
  String get settingsGpsOpenSettings => 'Abrir ajustes de Android';

  @override
  String get settingsGpsOpenLocationSettings => 'Abrir ajustes de ubicación';

  @override
  String get settingsGpsPrivacyNote =>
      'Tu ubicación se queda en este dispositivo. Los mapas la pasan a OpenStreetMap, nunca a nosotros.';

  @override
  String get settingsTrackingPermanent => 'Seguimiento permanente';

  @override
  String get settingsTrackingPermanentOn =>
      'El GPS funciona de forma permanente para todos los perfiles';

  @override
  String get settingsTrackingPermanentOff =>
      'El GPS solo cuando cada perfil lo necesite';

  @override
  String get settingsTrackingPermissionRequired =>
      'Se necesita permiso de ubicación';

  @override
  String get settingsTrackingEnabled => '✅ Seguimiento permanente activado';

  @override
  String get settingsTrackingDisabled => '✅ Seguimiento permanente desactivado';

  @override
  String get settingsSectionLegal => 'Aspectos legales';

  @override
  String get settingsImpressum => 'Aviso legal';

  @override
  String get settingsImpressumSubtitle => 'Información legal';

  @override
  String get settingsPrivacy => 'Política de privacidad';

  @override
  String get settingsPrivacySubtitle => 'Cómo protegemos tus datos';

  @override
  String get settingsAppVersion => 'Versión de la app';

  @override
  String get settingsSectionDiagnostics => 'Diagnóstico y soporte';

  @override
  String get settingsDebugLog => 'Generar registro de diagnóstico';

  @override
  String get settingsDebugLogSubtitle =>
      'Crea información técnica de diagnóstico para compartir';

  @override
  String settingsDebugLogError(String error) {
    return '❌ Error al generar el registro de diagnóstico: $error';
  }

  @override
  String get settingsSectionNotifications => 'Avisos';

  @override
  String get settingsNotificationsSubtitle =>
      'Recordatorios de medicación y citas';

  @override
  String get settingsNotificationsInfo => '¿Cómo funcionan los avisos?';

  @override
  String get settingsNotificationsBullet1 =>
      'Medicación diaria: -30 min, -10 min, 0 min y repeticiones cada +10 min';

  @override
  String get settingsNotificationsBullet2 =>
      'Medicación según necesidad: avisos de disponibilidad (-30 min, -10 min, -5 min, 0 min)';

  @override
  String get settingsNotificationsBullet3 =>
      'Citas: recordatorios configurables (de 15 min a 1 día antes)';

  @override
  String get settingsNotificationsBullet4 =>
      'Funciona incluso con la app cerrada';

  @override
  String get settingsNotificationsTest => 'Enviar aviso de prueba';

  @override
  String get settingsNotificationsTestSubtitle =>
      'Comprueba si los avisos funcionan';

  @override
  String get settingsNotificationsTestSent => '✅ Aviso de prueba enviado';

  @override
  String get settingsNotificationsQueue => 'Cola';

  @override
  String get settingsNotificationsQueuePending => 'Avisos programados:';

  @override
  String settingsNotificationsQueueNext(String time) {
    return 'Siguiente: $time';
  }

  @override
  String get settingsSectionMaps => 'Mapas y ubicación';

  @override
  String get settingsMapsSubtitle =>
      'Las secciones del mapa se descargan y se guardan automáticamente al mirarlas';

  @override
  String get settingsCacheStorage => 'Almacenamiento en caché';

  @override
  String settingsCacheSize(int size, int limit, String count) {
    return '$size MB / $limit MB • $count secciones';
  }

  @override
  String get settingsCacheLimit => 'Límite de la caché';

  @override
  String settingsCacheLimitSubtitle(int limit) {
    return '$limit MB de tamaño máximo';
  }

  @override
  String get settingsCacheLimitDialogTitle => 'Poner un límite a la caché';

  @override
  String settingsCacheLimitDialogLabel(int size) {
    return 'Tamaño máximo de la caché: $size MB';
  }

  @override
  String get settingsCacheLimitDialogInfo =>
      'Cuando la caché pase de ese límite, se borrarán automáticamente las secciones más antiguas.';

  @override
  String settingsCacheLimitSet(int limit) {
    return '✅ Límite de la caché puesto en $limit MB';
  }

  @override
  String get settingsCachePreDownload => 'Descargar mapas por adelantado';

  @override
  String get settingsCachePreDownloadSubtitle =>
      'Descargar mapas dentro de un radio';

  @override
  String get settingsCachePreDownloadPlaceholder =>
      '🚧 La descarga por adelantado llegará en la fase 4';

  @override
  String get settingsCacheClear => 'Vaciar la caché';

  @override
  String get settingsCacheClearSubtitle =>
      'Borrar todas las secciones de mapa guardadas';

  @override
  String get settingsCacheClearDialogTitle => 'Vaciar la caché de mapas';

  @override
  String get settingsCacheClearDialogMessage =>
      '¿Quieres borrar todas las secciones de mapa guardadas?\n\nLos mapas se volverán a cargar la próxima vez que los mires. Esto puede ayudarte a liberar espacio.';

  @override
  String get settingsCacheClearConfirm => 'Vaciar la caché';

  @override
  String get settingsCacheCleared => '✅ Caché de mapas vaciada';

  @override
  String get settingsSectionApp => 'Ajustes de la app';

  @override
  String get settingsTimeFormat => 'Formato de hora';

  @override
  String get settingsTimeFormatSystem => 'El del sistema';

  @override
  String get settingsTimeFormat12h => 'Formato de 12 horas';

  @override
  String get settingsTimeFormat24h => 'Formato de 24 horas';

  @override
  String get settingsTimeFormatSystemSubtitle =>
      'Sigue los ajustes del sistema Android';

  @override
  String get settingsTimeFormat12hExample => 'p. ej. 2:30 PM';

  @override
  String get settingsTimeFormat24hExample => 'p. ej. 14:30';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageChanged => 'Idioma cambiado';

  @override
  String get onboardingSelectLanguage => 'Elige tu idioma';

  @override
  String get onboardingWelcomeTitle => 'Te damos la bienvenida a';

  @override
  String get onboardingWelcomeSubtitle =>
      'Tu compañera segura en el día a día con TID';

  @override
  String get onboardingWelcomeDescription =>
      'Aurora te acompaña a organizar tu día a día y la comunicación dentro de tu sistema.';

  @override
  String get onboardingPrivacyTitle => 'Tus datos son TUYOS';

  @override
  String get onboardingPrivacyBullet1 =>
      'Todos los datos se quedan en tu dispositivo';

  @override
  String get onboardingPrivacyBullet2 =>
      'Sin copia en la nube, sin rastreo, sin anuncios';

  @override
  String get onboardingPrivacyBullet3 => 'Tú tienes el control';

  @override
  String get onboardingPrivacyBullet4 => 'Transparente y seguro';

  @override
  String get onboardingMultiProfileTitle => 'Muchas voces, una app';

  @override
  String get onboardingMultiProfileDescription =>
      'Cada alter puede tener su propio perfil, con sus colores, sus ajustes y sus permisos.';

  @override
  String get onboardingLetsGoTitle => '¿List@ para empezar?';

  @override
  String get onboardingLetsGoDescription =>
      'Crea ahora tu primer perfil. El primero pasa a ser automáticamente el perfil de administración, con todos los derechos.';

  @override
  String get onboardingButtonNext => 'Siguiente →';

  @override
  String get onboardingButtonCreateProfile => 'Crear perfil →';

  @override
  String get splashLoading => 'Aurora se está cargando';

  @override
  String get splashDidYouKnow => '¿Sabías que...?';

  @override
  String get splashEmergencyWipeTitle => 'Borrado de emergencia';

  @override
  String get splashEmergencyWipeMessage =>
      'AVISO: ¡se borrarán todos los datos para siempre!\n\n• Todos los perfiles\n• Todos los mensajes\n• Todas las entradas del diario\n• Todos los contactos\n• Toda la medicación\n\n¿Continuar?';

  @override
  String get splashEmergencyWipeConfirm => 'BORRARLO TODO';

  @override
  String get passwordResetBannerReady =>
      'La contraseña está lista para activarse';

  @override
  String get passwordResetBannerRunning =>
      'Restablecimiento de contraseña en curso';

  @override
  String passwordResetBannerProfile(String name) {
    return 'Perfil: $name';
  }

  @override
  String passwordResetBannerRemaining(String name, String time) {
    return 'Perfil: $name • Restante: $time';
  }

  @override
  String get dialogWarning => 'Aviso';

  @override
  String get dialogConfirm => 'Confirmar';

  @override
  String get dialogUnderstood => 'Entendido';

  @override
  String get dialogYes => 'Sí';

  @override
  String get dialogNo => 'No';

  @override
  String get permissionGpsRequired =>
      '⚠️ Hace falta el permiso de GPS «Permitir siempre»';

  @override
  String get permissionTrackingDialogTitle =>
      '¿Activar el seguimiento permanente?';

  @override
  String get permissionTrackingDialogHeading => 'Lo que hace este modo:';

  @override
  String get permissionTrackingBullet1 =>
      'El GPS funciona de forma permanente en segundo plano';

  @override
  String get permissionTrackingBullet2 =>
      'Prevalece sobre los ajustes de seguimiento de TODOS los perfiles';

  @override
  String get permissionTrackingBullet3 =>
      'La cronología recoge todos los movimientos automáticamente';

  @override
  String get permissionTrackingPrivacyTitle =>
      'Tus datos se quedan en este dispositivo';

  @override
  String get permissionTrackingPrivacyMessage =>
      'Aurora guarda todos los datos solo en este dispositivo. Sin rastreo, sin anuncios, sin compartir nada.';

  @override
  String get permissionTrackingBatteryWarning =>
      'El GPS en segundo plano puede gastar más batería.';

  @override
  String get permissionTrackingAndroidStatus => 'Estado en Android:';

  @override
  String get permissionTrackingActivate => 'Activar';

  @override
  String get permissionTrackingDeactivate => 'Desactivar';

  @override
  String get permissionTrackingDeactivateTitle =>
      '¿Desactivar el seguimiento permanente?';

  @override
  String get permissionTrackingDeactivateMessage =>
      'El seguimiento por GPS volverá a controlarse perfil por perfil.\n\nCada perfil podrá activarlo o desactivarlo por su cuenta.';

  @override
  String get permissionGuidanceTitle => 'Hace falta un ajuste de Android';

  @override
  String get permissionGuidanceMessage =>
      'Para usar el seguimiento permanente necesitas el permiso «Permitir siempre».';

  @override
  String get permissionGuidanceStepsTitle => 'Te guío paso a paso:';

  @override
  String get permissionGuidanceStep1Title => 'Abrir los ajustes de Android';

  @override
  String get permissionGuidanceStep1Button => 'Abrir ahora';

  @override
  String get permissionGuidanceStep2Title => 'Dentro de los ajustes';

  @override
  String get permissionGuidanceStep2Bullet1 => 'Toca «Permisos»';

  @override
  String get permissionGuidanceStep2Bullet2 => 'Toca «Ubicación»';

  @override
  String get permissionGuidanceStep2Bullet3 => 'Elige «Permitir siempre»';

  @override
  String get permissionGuidanceStep3Message =>
      'Vuelve a Aurora\nLa app detectará el cambio sola.';

  @override
  String get messageError => 'Error';

  @override
  String get messageSuccess => 'Hecho';

  @override
  String get messageWarning => 'Aviso';

  @override
  String get messageInfo => 'Información';

  @override
  String get messageLoading => 'Cargando...';

  @override
  String get misc24HourFormat => 'Formato de 24 horas';

  @override
  String get misc12HourFormat => 'Formato de 12 horas';

  @override
  String get miscSystemDefault => 'El del sistema';

  @override
  String get miscUnknown => 'Desconocido';

  @override
  String get chatDayYesterday => 'Ayer';

  @override
  String get miscToday => 'Hoy';

  @override
  String get miscAll => 'Todos';

  @override
  String get notificationChannelName => 'Notificaciones de Aurora';

  @override
  String get notificationChannelDescription =>
      'Recordatorios de medicamentos y citas';

  @override
  String get notificationMedicationReminder => 'Recordatorio de medicamento';

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
    return '$name - $dosage tomar ahora';
  }

  @override
  String get notificationMedicationAvailableSoon =>
      'Medicamento a demanda disponible pronto';

  @override
  String get notificationMedicationAvailableNow =>
      'Medicamento a demanda disponible ahora';

  @override
  String notificationMedicationAvailableBody(String name) {
    return '$name puede tomarse';
  }

  @override
  String get notificationEventReminder => 'Recordatorio de cita';

  @override
  String notificationEventBody(String title, String time) {
    return '$title $time';
  }

  @override
  String get notificationTestTitle => 'Notificación de prueba';

  @override
  String get notificationTestBody => '¡Las notificaciones funcionan!';

  @override
  String notificationTimeInMinutes(int minutes) {
    return 'en $minutes minutos';
  }

  @override
  String get notificationTimeIn1Hour => 'en 1 hora';

  @override
  String notificationTimeInHours(int hours) {
    return 'en $hours horas';
  }

  @override
  String get notificationTimeNow => 'ahora';

  @override
  String get notificationMedicationTakeNowTitle => '¡Tomar medicamento ahora!';

  @override
  String get notificationMedicationNotTakenYet => '¡Aún no tomado!';

  @override
  String get actionCreate => 'Crear';

  @override
  String get commonDescription => 'Descripción';

  @override
  String get commonNotes => 'Notas';

  @override
  String get commonOptional => 'Opcional';

  @override
  String get commonCategory => 'Categoría';

  @override
  String get commonStartTime => 'Hora de inicio';

  @override
  String get commonEndTime => 'Hora de fin';

  @override
  String get commonVisibleFor => 'Visible para';

  @override
  String get commonUnnamed => 'Sin nombre';

  @override
  String get commentsTitle => 'Comentarios';

  @override
  String get eventCreate => 'Crear cita';

  @override
  String get eventNewTitle => 'Nueva cita';

  @override
  String get eventEditTitle => 'Editar cita';

  @override
  String get eventDetailTitle => 'Cita';

  @override
  String get eventNotFound => 'Cita no encontrada';

  @override
  String get eventNotFoundMessage => 'Esta cita ya no existe';

  @override
  String get eventDeleteTitle => '¿Borrar cita?';

  @override
  String get eventDeleteMessage => '¿Seguro que quieres borrar esta cita?';

  @override
  String get eventDeleteConfirmMessage =>
      'Esta cita se borrará definitivamente.';

  @override
  String get eventDeleted => 'Cita borrada';

  @override
  String get eventUpdated => 'Cita guardada';

  @override
  String get eventCreated => 'Cita creada';

  @override
  String get eventSelectProfileRequired => 'Elige al menos un perfil';

  @override
  String get eventEndTimeError =>
      'La hora de fin tiene que ser posterior a la de inicio';

  @override
  String get eventTitleLabel => 'Título';

  @override
  String get eventTitleLabelRequired => 'Título *';

  @override
  String get eventTitleRequired => 'Escribe un título';

  @override
  String get eventTitleHint => 'p. ej. cita médica';

  @override
  String get eventCategoryLabel => 'Categoría (opcional)';

  @override
  String get eventCategoryHint => 'p. ej. cita médica, personal, etc.';

  @override
  String get eventDescriptionLabel => 'Descripción (opcional)';

  @override
  String contactDistanceAway(String distance) {
    return 'a $distance';
  }

  @override
  String eventReminderMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutos',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String eventReminderHours(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours horas',
      one: '1 hora',
    );
    return '$_temp0';
  }

  @override
  String get eventReminderDay => '1 día';

  @override
  String eventReminderNotice(String when) {
    return 'Aurora te avisa $when antes de la cita.';
  }

  @override
  String eventReminderBefore(int minutes) {
    return 'Aviso $minutes min antes';
  }

  @override
  String eventCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count citas',
      one: '1 cita',
      zero: 'Sin citas',
    );
    return '$_temp0';
  }

  @override
  String get noEventsToday => 'No hay citas este día';

  @override
  String get calendarNothingPlannedToday => 'Hoy no hay nada previsto.';

  @override
  String get calendarNothingPlannedOnDay =>
      'No hay nada previsto para este día.';

  @override
  String get calendarUpcomingTitle => 'A continuación';

  @override
  String get calendarChooseDay => 'Ver otro día';

  @override
  String get eventForWhom => '¿Para quién es esta cita?';

  @override
  String get eventMoreDetails => 'Más información';

  @override
  String get contactTitle => 'Contacto';

  @override
  String get contactNewTitle => 'Nuevo contacto';

  @override
  String get contactEditTitle => 'Editar contacto';

  @override
  String get contactNotFound => 'Contacto no encontrado';

  @override
  String get contactDeleteTitle => '¿Borrar contacto?';

  @override
  String get contactDeleteMessage =>
      'Este contacto se borrará definitivamente. Esta acción no se puede deshacer.';

  @override
  String get contactImagePickerTitle => 'Elegir imagen de contacto';

  @override
  String get contactNameLabel => 'Nombre *';

  @override
  String get contactNameRequired => 'Escribe un nombre';

  @override
  String get contactRelationLabel => 'Relación';

  @override
  String get contactRelationHint => 'p. ej. madre, terapeuta, amigo...';

  @override
  String get contactMarkAsEmergency => 'Marcar como contacto de emergencia';

  @override
  String get contactEmergencyDescription =>
      'Este contacto aparece en la vista de emergencia y se le puede avisar rápidamente';

  @override
  String get contactPhoneLabel => 'Teléfono';

  @override
  String get contactEmailLabel => 'Correo electrónico';

  @override
  String get contactDefaultRating => 'Valoración predeterminada';

  @override
  String get contactDefaultRatingDescription =>
      'Todos los perfiles ven esta valoración de forma predeterminada. Cada perfil puede dar la suya más adelante.';

  @override
  String get contactPersonalRating => 'Valoración personal';

  @override
  String get contactLocationSection => '📍 Ubicación (opcional)';

  @override
  String get contactLocationTitle => '📍 Ubicación';

  @override
  String get contactLocationDescription =>
      'Añade una ubicación (por ejemplo, domicilio o dirección de la consulta)';

  @override
  String get contactLocationSet => 'Fijar la ubicación';

  @override
  String get contactLocationChange => 'Cambiar la ubicación';

  @override
  String get contactAddressLabel => 'Dirección';

  @override
  String get contactAddressHint =>
      'Se detecta automáticamente al fijar la ubicación';

  @override
  String get contactVisibleToAll =>
      'Todos los perfiles pueden ver este contacto';

  @override
  String get contactInfoSection => 'Información';

  @override
  String get gpsPermissionRequired => 'Se necesita permiso de GPS';

  @override
  String get gpsTrackingDisabled => 'Seguimiento GPS desactivado';

  @override
  String get emergencyContactLabel => 'Contacto de emergencia';

  @override
  String get diaryEntryNewTitle => 'Nueva entrada';

  @override
  String get diaryEntryEditTitle => 'Editar entrada';

  @override
  String get diaryEntryDetailTitle => 'Detalles de la entrada';

  @override
  String get diaryEntryNotFound => 'Entrada no encontrada';

  @override
  String get diaryEntryNotFoundMessage => 'Esta entrada ya no existe';

  @override
  String get diaryEntryDeleteTitle => 'Borrar entrada';

  @override
  String get diaryEntryDeleteMessage =>
      '¿Seguro que quieres borrar esta entrada? También se borrarán todos los comentarios.';

  @override
  String get diaryEntryDeleted => 'Entrada borrada';

  @override
  String get diaryEntryUpdated => 'Entrada actualizada';

  @override
  String get diaryEntryCreated => 'Entrada creada';

  @override
  String get diaryTitleHint => '¿Qué ha pasado?';

  @override
  String get diaryTitleRequired => 'Escribe un título';

  @override
  String get diaryDescriptionHint => 'Describe lo que pasó...';

  @override
  String get diaryDescriptionRequired => 'Escribe una descripción';

  @override
  String get diaryPriorityLabel => 'Prioridad';

  @override
  String get diaryImagesLabel => 'Imágenes';

  @override
  String get diaryNoImagesYet => 'Todavía no hay imágenes';

  @override
  String get diaryImagePickerComingSoon =>
      'La selección de imágenes llegará pronto';

  @override
  String get diaryCannotEditEntry => 'No puedes editar esta entrada';

  @override
  String get diaryCannotCreateEntry => 'No puedes crear entradas';

  @override
  String get commonError => 'Error';

  @override
  String get commonNoPermission => 'Sin permiso';

  @override
  String get commonEdited => 'Editado';

  @override
  String get commonTitle => 'Título';

  @override
  String get profileNotSelected => 'Ningún perfil seleccionado';

  @override
  String get actionAdd => 'Añadir';

  @override
  String commonSaveError(String error) {
    return 'Error al guardar: $error';
  }

  @override
  String get timeJustNow => 'ahora mismo';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count minutos',
      one: 'hace un minuto',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count horas',
      one: 'hace una hora',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count días',
      one: 'hace un día',
    );
    return '$_temp0';
  }

  @override
  String get emergencyCall => 'Llamar';

  @override
  String get emergencyCallTooltip => 'Llamar al contacto';

  @override
  String get emergencyNoPhone => 'No hay número de teléfono';

  @override
  String get emergencySms => 'SMS';

  @override
  String get emergencySmsTooltip => 'Enviar SMS de emergencia';

  @override
  String get emergencyApp => 'App';

  @override
  String get emergencyShareTooltip => 'Compartir con una app';

  @override
  String emergencyErrorCall(String error) {
    return 'Error al llamar: $error';
  }

  @override
  String emergencyErrorOpen(String error) {
    return 'Error al abrir: $error';
  }

  @override
  String get actionOpen => 'Abrir';

  @override
  String get finderLocationEditTitle => 'Editar lugar';

  @override
  String get finderItemEditTitle => 'Editar objeto';

  @override
  String get finderLocationNewTitle => 'Nuevo lugar';

  @override
  String get finderItemNewTitle => 'Nuevo objeto';

  @override
  String get finderSetPosition => 'Fijar la ubicación';

  @override
  String get finderChangePosition => 'Cambiar la ubicación';

  @override
  String get finderAddressLabel => 'Dirección';

  @override
  String get finderStorageLocationLabel => 'Dónde se guarda';

  @override
  String get finderStorageLocationHint => 'p. ej. cocina, segundo cajón';

  @override
  String get finderChoosePhoto => 'Elegir foto';

  @override
  String get finderAddPhoto => 'Añadir foto';

  @override
  String get finderAddTag => 'Añadir etiqueta';

  @override
  String get finderNotFound => 'No encontrado';

  @override
  String get finderNotFoundMessage => 'No se ha encontrado el elemento';

  @override
  String get finderDeleteTitle => '¿Borrar?';

  @override
  String finderDeleteMessage(String title) {
    return '¿Seguro que quieres borrar $title?';
  }

  @override
  String get commonRequired => 'Campo obligatorio';

  @override
  String get feedbackTitle => 'Enviar comentario';

  @override
  String get feedbackPrivacyInfo =>
      'Tu comentario se trata de forma confidencial y solo se procesa internamente. ¡Tus mensajes nos ayudan a mejorar Aurora!';

  @override
  String get feedbackSelectCategory => 'Elige una categoría:';

  @override
  String get fieldPasswordShow => 'Mostrar contraseña';

  @override
  String get fieldPasswordHide => 'Ocultar contraseña';

  @override
  String get feedbackCategoryBug => 'Informar de un fallo';

  @override
  String get feedbackCategoryWish => 'Proponer una idea';

  @override
  String get feedbackCategoryGeneral => 'Comentario general';

  @override
  String get feedbackCategoryLabel => 'Categoría';

  @override
  String get feedbackTitleLabel => 'Título:';

  @override
  String get feedbackTitleHint => 'Un resumen breve de tu comentario';

  @override
  String get feedbackTitleRequired => 'Escribe un título';

  @override
  String get feedbackTitleTooShort =>
      'Título demasiado corto (mínimo 5 caracteres)';

  @override
  String get feedbackMessageLabel => 'Tu mensaje:';

  @override
  String get feedbackMessageHint => 'Cuéntanos con detalle...';

  @override
  String get feedbackMessageRequired => 'Escribe un mensaje';

  @override
  String get feedbackMessageTooShort =>
      'Mensaje demasiado corto (mínimo 20 caracteres)';

  @override
  String get feedbackEmailLabel => 'Tu correo electrónico (opcional):';

  @override
  String get feedbackEmailHint =>
      'Solo si quieres que te escribamos si tenemos preguntas';

  @override
  String get feedbackEmailPlaceholder => 'tu@correo.es';

  @override
  String get feedbackEmailInvalid => 'Escribe una dirección de correo válida';

  @override
  String get feedbackAttachImageLabel => 'Adjuntar imagen (opcional):';

  @override
  String get feedbackAttachImage => 'Adjuntar imagen';

  @override
  String get feedbackSelectImage => 'Elegir imagen';

  @override
  String get feedbackSend => 'Enviar comentario';

  @override
  String get feedbackCopyToClipboard => 'Copiar al portapapeles';

  @override
  String get feedbackCopiedToClipboard =>
      '¡Comentario copiado al portapapeles!';

  @override
  String get feedbackContactLabel => 'Contacto';

  @override
  String get feedbackErrorOccurred =>
      'Ha ocurrido un error. El informe se ha copiado al portapapeles.';

  @override
  String get feedbackCouldNotSend => 'No se ha podido enviar el comentario';

  @override
  String feedbackErrorClipboardHint(String email) {
    return 'Tu comentario se ha copiado al portapapeles. También puedes enviárnoslo por correo a $email.';
  }

  @override
  String get feedbackTechnicalDetails => 'Detalles técnicos';

  @override
  String get actionChange => 'Cambiar';

  @override
  String get actionRemove => 'Quitar';

  @override
  String get onboardingNext => 'Siguiente →';

  @override
  String get onboardingCreateProfile => 'Crear perfil →';

  @override
  String get onboardingLetsGo => '¡Vamos allá! →';

  @override
  String get onboardingWelcomeTo => 'Te damos la bienvenida a';

  @override
  String get onboardingSubline => 'Tu compañera segura en el día a día con TID';

  @override
  String get onboardingDescription =>
      'Aurora te acompaña a organizar tu día a día y la comunicación dentro de tu sistema.';

  @override
  String get onboardingPrivacyHeadline => 'Tus datos son TUYOS';

  @override
  String get onboardingPrivacyPoint1 =>
      'Todos los datos se quedan en tu dispositivo';

  @override
  String get onboardingPrivacyPoint2 =>
      'Sin copia en la nube, sin rastreo, sin anuncios';

  @override
  String get onboardingPrivacyPoint3 => 'Tú tienes el control';

  @override
  String get onboardingPrivacyPoint4 => 'Transparente y seguro';

  @override
  String get onboardingMultiProfileHeadline => 'Muchas voces, una app';

  @override
  String get onboardingLetsGoHeadline => '¿Listo para empezar?';

  @override
  String onboardingHelloName(String name) {
    return '¡Hola, $name!';
  }

  @override
  String get onboardingGladYoureHere => 'Qué bien que estés aquí.';

  @override
  String get onboardingNotAlone => 'No estás solo';

  @override
  String get onboardingNotAloneDescription =>
      'Podéis escribiros, compartir citas y apoyaros mutuamente.';

  @override
  String get onboardingWhatYouCanDo => 'Lo que puedes hacer';

  @override
  String get onboardingChildAccessDescription =>
      'Con un perfil infantil tienes acceso a:';

  @override
  String get onboardingAdultAccessDescription =>
      'Tienes acceso a estas funciones:';

  @override
  String get onboardingSafeSpace => 'Tu espacio seguro';

  @override
  String get onboardingSafeSpaceDescription =>
      'Todo lo que escribes se queda en este dispositivo. Solo se envía lo que tú mismo envías, y siempre puedes volver a leerlo.';

  @override
  String get onboardingHaveFun => '¡Que disfrutes de Aurora!';

  @override
  String get onboardingFeatureChatChild =>
      'Chat: garabatear y hablar con los demás';

  @override
  String get onboardingFeatureDiaryChild => 'Diario: escribir tus pensamientos';

  @override
  String get onboardingFeatureGamesChild => 'Juegos: divertirse y descansar';

  @override
  String get onboardingFeatureTimelineChild =>
      'Línea del tiempo: guardar momentos importantes';

  @override
  String get onboardingFeatureChat => 'Chat: mensajes, garabatos, notas de voz';

  @override
  String get onboardingFeatureCalendar =>
      'Calendario: planificar y gestionar citas';

  @override
  String get onboardingFeatureContacts =>
      'Contactos: guardar personas importantes';

  @override
  String get onboardingFeatureMedication =>
      'Medicación: llevar el control de medicamentos y tomas';

  @override
  String get onboardingFeatureDiary =>
      'Diario: anotar pensamientos y vivencias';

  @override
  String get onboardingFeatureFinder => 'Buscador: reencontrar lugares y cosas';

  @override
  String get onboardingFeatureEmergency =>
      'Emergencia: ayuda rápida en momentos de crisis';

  @override
  String get onboardingFeatureMantras =>
      'Mantras: frases que calman y afirmaciones';

  @override
  String get onboardingFeatureChatBasic =>
      'Chat: funciones básicas disponibles';

  @override
  String get featureCarouselHeadline => 'Todo lo que Aurora sabe hacer';

  @override
  String get featureCarouselSwipeHint => 'Desliza por las funciones →';

  @override
  String get featureCarouselChatTitle => 'Chat';

  @override
  String get featureCarouselChatSubtitle => 'Comunicación interna';

  @override
  String get featureCarouselChatDescription =>
      'Mensajes, dibujos y notas de voz.\nCompartid pensamientos, dibujad juntos o habladlo.';

  @override
  String get featureCarouselCalendarTitle => 'Calendario';

  @override
  String get featureCarouselCalendarSubtitle => 'Citas';

  @override
  String get featureCarouselCalendarDescription =>
      'Citas con imágenes y lugares.\nTened a la vista las citas importantes, con imágenes y posiciones GPS.';

  @override
  String get featureCarouselDiaryTitle => 'Diario';

  @override
  String get featureCarouselDiarySubtitle => 'Pensamientos privados';

  @override
  String get featureCarouselDiaryDescription =>
      'Visible para todos o solo para ti.\nGuardad pensamientos: en común para todos los perfiles o en privado.';

  @override
  String get featureCarouselFinderTitle => 'Buscador';

  @override
  String get featureCarouselFinderSubtitle => 'Lugares y cosas';

  @override
  String get featureCarouselFinderDescription =>
      'Volved a encontrar lugares y cosas.\nGuardad lugares importantes (con mapa) y objetos para reencontrarlos.';

  @override
  String get featureCarouselMedicationTitle => 'Medicación';

  @override
  String get featureCarouselMedicationSubtitle => 'Control de medicamentos';

  @override
  String get featureCarouselMedicationDescription =>
      'Medicamentos y horas de toma.\nLlevad el control de los medicamentos, las horas y la medicación a demanda.';

  @override
  String get featureCarouselGamesTitle => 'Juegos y anclaje';

  @override
  String get featureCarouselGamesSubtitle => 'Calma';

  @override
  String get featureCarouselGamesDescription =>
      'Juegos, respiración y anclaje.\nCalmaos con rompecabezas, ejercicios de respiración y técnicas de anclaje.';

  @override
  String get featureCarouselEmergencyTitle => 'Ayuda';

  @override
  String get featureCarouselEmergencySubtitle => 'Contactos de emergencia';

  @override
  String get featureCarouselEmergencyDescription =>
      'Contactos de emergencia y ayuda rápida.\nGuardad los contactos importantes para momentos de crisis.';

  @override
  String get featureCarouselInfoTitle => 'Información sobre el TID';

  @override
  String get featureCarouselInfoSubtitle => 'Información y recursos';

  @override
  String get featureCarouselInfoDescription =>
      'Explicado: ¿qué es el TID?\nInformación sobre el trastorno de identidad disociativo y recursos de ayuda.';

  @override
  String get commonUnknown => 'Desconocido';

  @override
  String get timelineTitle => 'Línea del tiempo';

  @override
  String get timelineHistory => 'Historial';

  @override
  String timelineEntries(int count) {
    return '$count entradas';
  }

  @override
  String get timelinePositionUpdated => 'Posición actualizada';

  @override
  String timelineProfileActive(String name) {
    return '$name activo';
  }

  @override
  String get timelineAppStarted => 'App iniciada';

  @override
  String get timelineProfileSwitched => 'Cambio de perfil';

  @override
  String timelineToday(String time) {
    return 'Hoy, $time';
  }

  @override
  String timelineYesterday(String time) {
    return 'Ayer, $time';
  }

  @override
  String get timelineTrackingDisabledTitle => 'Seguimiento GPS desactivado';

  @override
  String get timelineTrackingDisabledSubtitle =>
      'La línea del tiempo muestra tus cambios de perfil y tus posiciones GPS a lo largo del tiempo.\n\nActiva el seguimiento GPS con el símbolo del satélite arriba a la derecha para recoger datos.';

  @override
  String get timelineEmptyTitle => 'Todavía no hay datos';

  @override
  String get timelineEmptySubtitle =>
      'El seguimiento GPS está activo. Tu posición se registra cada 2 o 3 minutos.\n\nLos cambios de perfil y las posiciones GPS aparecen aquí automáticamente.';

  @override
  String get gamesTitle => 'Juegos y calma';

  @override
  String get gamesSubtitle =>
      'Juegos sencillos para distraerse y descansar.\nSin cronómetros, sin puntos: solo calma.';

  @override
  String get gamesComingSoon => 'Pronto';

  @override
  String get gamesPuzzleTitle => 'Puzle';

  @override
  String get gamesPuzzleSubtitle => 'Rompecabezas o puzle deslizante';

  @override
  String get gamesPuzzleDescription => 'Relájate con imágenes que calman';

  @override
  String get gamesBreathingTitle => 'Ejercicios de respiración';

  @override
  String get gamesBreathingSubtitle => 'Respiración guiada';

  @override
  String get gamesBreathingDescription =>
      'Cálmate con ejercicios de respiración sencillos';

  @override
  String get memoryCardHidden => 'Boca abajo';

  @override
  String get memoryCardOpen => 'Boca arriba';

  @override
  String get memoryCardFound => 'Pareja encontrada';

  @override
  String get memoryAllFound => 'Todas las parejas están.';

  @override
  String get memoryNewGame => 'Partida nueva';

  @override
  String get gamesDrawingSend => 'Enviar al chat';

  @override
  String get gamesDrawingEmpty => 'Dibuja algo y luego podrás enviarlo';

  @override
  String get gamesDrawingSent => 'Tu dibujo está ahora en el chat.';

  @override
  String memoryCardPosition(int position, int total) {
    return 'Carta $position de $total';
  }

  @override
  String get gamesMemoryTitle => 'Memory';

  @override
  String get gamesMemorySubtitle => 'Encuentra las parejas';

  @override
  String get gamesMemoryDescription => 'Un memory tranquilo, sin prisa';

  @override
  String get gamesDrawingTitle => 'Dibujar';

  @override
  String get gamesDrawingSubtitle => 'Dibujo libre y garabatos';

  @override
  String get gamesDrawingDescription => 'Exprésate de forma creativa';

  @override
  String get puzzleCreateTitle => 'Crear puzle';

  @override
  String get puzzleRelaxationTitle => 'Puzle para relajarse';

  @override
  String get puzzleRelaxationSubtitle =>
      'Elige el tipo de puzle y la dificultad. Tómate tu tiempo: aquí nadie puntúa.';

  @override
  String get puzzleTypeLabel => 'Tipo de puzle';

  @override
  String get puzzleTypeJigsaw => 'De piezas';

  @override
  String get puzzleTypeJigsawDescription => 'Arrastra las piezas a su sitio';

  @override
  String get puzzleTypeSliding => 'Deslizante';

  @override
  String get puzzleTypeSlidingDescription => 'Mueve las piezas tocándolas';

  @override
  String get puzzleDifficultyLabel => 'Dificultad';

  @override
  String get puzzleDifficultyEasy => 'Fácil';

  @override
  String get puzzleDifficultyEasyDescription =>
      'Cuadrícula de 3×3, ideal para relajarse';

  @override
  String get puzzleDifficultyMedium => 'Media';

  @override
  String get puzzleDifficultyMediumDescription =>
      'Cuadrícula de 4×4, un pequeño reto';

  @override
  String get puzzleDifficultyHard => 'Difícil';

  @override
  String get puzzleDifficultyHardDescription =>
      'Cuadrícula de 5×5, para quien ya tiene práctica';

  @override
  String get puzzleSelectImageAndStart => 'Elegir imagen y empezar';

  @override
  String get puzzleJigsawTitle => 'Puzle de piezas';

  @override
  String get puzzleSlidingTitle => 'Puzle deslizante';

  @override
  String puzzleMoves(int count) {
    return 'Movimientos: $count';
  }

  @override
  String get puzzlePreparing => 'Preparando el puzle...';

  @override
  String get puzzleAvailablePieces => 'Piezas disponibles';

  @override
  String get puzzleTapToMove => 'Toca una pieza para moverla';

  @override
  String get puzzleShowHint => 'Mostrar ayuda';

  @override
  String puzzleHintMovablePieces(int count) {
    return 'Pista: puedes mover $count piezas';
  }

  @override
  String get puzzleSolved => '¡Puzle resuelto!';

  @override
  String puzzleSolvedInMoves(int count) {
    return 'Has resuelto el puzle en $count movimientos.';
  }

  @override
  String puzzleErrorLoadingImage(String error) {
    return 'Error al cargar la imagen: $error';
  }

  @override
  String puzzleErrorSharing(String error) {
    return 'Error al compartir: $error';
  }

  @override
  String get puzzleImagePickerTitle => 'Elegir imagen';

  @override
  String get puzzleImagePickerSubtitle =>
      'Elige una imagen que te calme para tu puzle';

  @override
  String get puzzleImageLoading => 'Cargando la imagen...';

  @override
  String get puzzleImageLoadFailed => 'No se ha podido cargar la imagen';

  @override
  String get puzzleImageSourceGallery => 'Galería';

  @override
  String get puzzleImageSourceGallerySubtitle =>
      'Elegir una imagen de tu galería';

  @override
  String get puzzleImageSourceCamera => 'Cámara';

  @override
  String get puzzleImageSourceCameraSubtitle => 'Hacer una foto nueva';

  @override
  String get puzzleImageSourceOnline => 'En línea';

  @override
  String get puzzleImageSourceOnlineSubtitle =>
      'Una imagen que calma, de internet';

  @override
  String get puzzleSelectCategory => 'Elegir categoría';

  @override
  String get errorNoProfileSelected => 'Ningún perfil seleccionado';

  @override
  String get mantrasTitle => 'Mantras';

  @override
  String get mantrasComingSoonTitle => 'Mantras: muy pronto ✨';

  @override
  String get mantrasComingSoonSubtitle =>
      'Afirmaciones que calman y mantras para los momentos difíciles';

  @override
  String get helpResourcesTitle => 'Ayuda';

  @override
  String get helpHotlinesTitle => 'Teléfonos de emergencia 24/7';

  @override
  String get helpHotlinesSubtitle => 'Apoyo profesional, a cualquier hora';

  @override
  String get helpMoreResourcesTitle => 'Pronto habrá más recursos';

  @override
  String get helpMoreResourcesDescription =>
      'En próximas versiones:\n• Recursos de terapia\n• Grupos de apoyo\n• Material informativo sobre el TID\n• Planes de crisis y estrategias';

  @override
  String get moreTitle => 'Más funciones';

  @override
  String get moreHelpResources => 'Ayuda';

  @override
  String get moreHelpResourcesDescription =>
      'Información y enlaces a apoyo profesional';

  @override
  String get moreGames => 'Juegos y calma';

  @override
  String get moreGamesDescription =>
      'Respiración, memory y más para distraerse';

  @override
  String get moreSettings => 'Ajustes';

  @override
  String get moreSettingsDescription => 'Configuración de la app y privacidad';

  @override
  String get permissionsTitle => 'Derechos y permisos';

  @override
  String get permissionsNoProfiles => 'No hay perfiles';

  @override
  String get permissionsInfoText =>
      'Aquí puedes gestionar los permisos de cada perfil. Toca un perfil para ver los detalles.';

  @override
  String get permissionsAllRightsAdmin => 'Todos los derechos (administrador)';

  @override
  String permissionsCount(int count) {
    return '$count permisos';
  }

  @override
  String get permissionsAdminBadge => 'Admin';

  @override
  String get permissionsAdministrator => 'Administrador';

  @override
  String permissionsDetailTitle(String name) {
    return 'Permisos: $name';
  }

  @override
  String get permissionsChangeError => 'No se ha podido cambiar el permiso';

  @override
  String get permissionsMakeAdminTitle => 'Nombrar administrador';

  @override
  String permissionsMakeAdminMessage(String name) {
    return '$name pasará a ser administrador con todos los derechos. ¿Seguir?';
  }

  @override
  String get permissionsMakeAdminButton => 'Hacer administrador';

  @override
  String get permissionsMakeAdminSubtitle => 'Concede todos los derechos';

  @override
  String get permissionsRevokeAdminTitle => 'Quitar el estado de administrador';

  @override
  String permissionsRevokeAdminMessage(String name) {
    return '$name perderá todos los derechos de administrador y tendrá los permisos estándar. ¿Seguir?';
  }

  @override
  String get permissionsRevokeAdminSubtitle => 'Vuelve a los derechos estándar';

  @override
  String get permissionsRevokeAdminError =>
      'No se ha podido quitar el estado de administrador. El primer perfil tiene que seguir siendo administrador.';

  @override
  String permissionsActiveCount(int active, int total) {
    return '$active / $total activos';
  }

  @override
  String get permissionsCategorySystem => 'Permisos del sistema';

  @override
  String get permissionsCategoryChat => 'Chat';

  @override
  String get permissionsCategoryCalendar => 'Calendario';

  @override
  String get permissionsCategoryMedication => 'Medicamentos';

  @override
  String get permissionsCategoryContacts => 'Contactos';

  @override
  String get permissionsCategoryFinder => 'Buscador (lugares y objetos)';

  @override
  String get permissionsCategoryDiary => 'Diario';

  @override
  String get permissionsCategoryEmergency => 'Contactos de emergencia';

  @override
  String get permissionsCategorySecurity => 'Seguridad';

  @override
  String profileAgeYears(int age) {
    return '$age años';
  }

  @override
  String get groundingTitle => 'Sostén';

  @override
  String get groundingChooseLabel => 'O elige tú algo';

  @override
  String get groundingDoneAgain => 'Otra vez';

  @override
  String get groundingDoneOther => 'Otra cosa';

  @override
  String get groundingDoneCall => 'Llamar a alguien';

  @override
  String get groundingOrientationTitle => 'Aquí y ahora';

  @override
  String get groundingOrientationStep1 => 'Hoy es';

  @override
  String get groundingOrientationStep2 =>
      'Mira a tu alrededor. ¿Dónde estás ahora?';

  @override
  String get groundingOrientationStep3 => 'Di quién eres, en voz alta o baja.';

  @override
  String get groundingOrientationStep4 =>
      'El cuerpo de hoy no es el de entonces.';

  @override
  String get groundingOrientationStep5 => 'Lo que recuerdas ya pasó.';

  @override
  String get groundingOrientationStep6 => 'Estás aquí.';

  @override
  String get groundingSensesTitle => 'Ver, oír, sentir';

  @override
  String get groundingSensesStep1 => 'Cinco cosas que ves.';

  @override
  String get groundingSensesStep2 => 'Cuatro cosas que oyes.';

  @override
  String get groundingSensesStep3 => 'Tres cosas que puedes tocar.';

  @override
  String get groundingSensesStep4 => 'Dos cosas que hueles.';

  @override
  String get groundingSensesStep5 => 'Una cosa que saboreas.';

  @override
  String get groundingSensesStep6 => 'Estás aquí.';

  @override
  String get groundingBodyTitle => 'Sentir el cuerpo';

  @override
  String get groundingBodyStep1 => 'Apoya los dos pies planos en el suelo.';

  @override
  String get groundingBodyStep2 => 'Empuja los talones hacia abajo.';

  @override
  String get groundingBodyStep3 => 'Coge algo frío con la mano.';

  @override
  String get groundingBodyStep4 => 'Sujétalo el tiempo que quieras.';

  @override
  String get groundingBodyStep5 => 'Nota tu espalda contra el respaldo.';

  @override
  String get groundingBodyStep6 => 'El suelo te sostiene.';

  @override
  String get groundingContainerTitle => 'Guardar bajo llave';

  @override
  String get groundingContainerStep1 =>
      'Imagina un recipiente. Tan grande como quieras.';

  @override
  String get groundingContainerStep2 => 'Tiene una tapa que cierra bien.';

  @override
  String get groundingContainerStep3 =>
      'Mete dentro lo que ahora es demasiado.';

  @override
  String get groundingContainerStep4 => 'Cierra la tapa.';

  @override
  String get groundingContainerStep5 => 'Ponlo en un sitio que elijas tú.';

  @override
  String get groundingContainerStep6 =>
      'Puedes volver a abrirlo. Pero no ahora.';

  @override
  String get groundingBreathTitle => 'Respiración';

  @override
  String get groundingBreathStep1 => 'Coge aire y cuenta hasta cuatro.';

  @override
  String get groundingBreathStep2 => 'Aguanta un momento.';

  @override
  String get groundingBreathStep3 => 'Suelta el aire y cuenta hasta seis.';

  @override
  String get groundingBreathStep4 => 'Otra vez. Sin prisa.';

  @override
  String get groundingBreathStep5 =>
      'Más lento al salir que al entrar. Con eso basta.';

  @override
  String get medicationNameLabel => 'Nombre del medicamento';

  @override
  String get medicationDosageLabel => 'Dosis';

  @override
  String get medicationDosageHint => 'p. ej. 1 comprimido, 10 mg, 5 ml';

  @override
  String get medicationNameRequired => 'Escribe un nombre';

  @override
  String get medicationDosageRequired => 'Escribe la dosis';

  @override
  String get medicationTypeQuestion => '¿Qué tipo de medicamento?';

  @override
  String get medicationTypeDailyTitle => 'Medicación diaria';

  @override
  String get medicationTypeDailyExplanation => 'A horas fijas, todos los días';

  @override
  String get medicationTypeAsNeededTitle => 'Medicación a demanda';

  @override
  String get medicationTypeAsNeededExplanation => 'Solo cuando lo necesitas';

  @override
  String get medicationWhenToTake => '¿Cuándo tomarlo?';

  @override
  String get medicationSectionMorning => 'Por la mañana';

  @override
  String get medicationSectionMidday => 'A mediodía';

  @override
  String get medicationSectionEvening => 'Por la tarde';

  @override
  String get medicationSectionNight => 'Por la noche';

  @override
  String get medicationOtherTime => 'Otra hora';

  @override
  String get medicationSectionNotChosen => 'sin seleccionar';

  @override
  String get medicationTimeRequired => 'Añade al menos una hora de toma';

  @override
  String get medicationAsNeededSettings => 'Ajustes de medicación a demanda';

  @override
  String get medicationMaxDosesLabel => 'Máximo al día *';

  @override
  String get medicationMaxDosesHint => 'p. ej. 3';

  @override
  String get medicationMaxDosesHelper =>
      '¿Cuántas veces se puede tomar al día?';

  @override
  String get medicationMaxDosesRequired =>
      'Obligatorio para la medicación a demanda';

  @override
  String get medicationMaxDosesInvalid => 'Escribe un número mayor que 0';

  @override
  String get medicationMaxDosesMissing => 'Indica el máximo al día';

  @override
  String get medicationMinIntervalLabel =>
      'Intervalo mínimo en horas (opcional)';

  @override
  String get medicationMinIntervalHint => 'p. ej. 4';

  @override
  String get medicationMinIntervalHelper => 'Tiempo mínimo entre dos tomas';

  @override
  String get medicationMinIntervalInvalid =>
      'Escribe un número igual o mayor que 0';

  @override
  String get medicationRemindersTitle => 'Aurora te avisará';

  @override
  String get medicationRemindersOff =>
      'Aurora no dice nada. El medicamento sigue en tu lista y tú decides cuándo mirarla.';

  @override
  String get medicationRemindersDaily =>
      'En cada hora de toma Aurora avisa tres veces: 30 minutos antes, 10 minutos antes y a la hora exacta. Si no respondes, una vez más 10 minutos después.';

  @override
  String get medicationRemindersNoInterval =>
      'Sin un intervalo mínimo no hay ningún momento que Aurora pueda esperar. Indica abajo un intervalo si quieres que te avise en cuanto se permita la siguiente dosis.';

  @override
  String get medicationRemindersAsNeeded =>
      'Tras una toma, Aurora te avisa en cuanto se permite la siguiente y la anuncia 30, 10 y 5 minutos antes.';

  @override
  String get medicationPeriodTitle => 'Periodo (opcional)';

  @override
  String get medicationStartDate => 'Fecha de inicio';

  @override
  String get medicationEndDate => 'Fecha de fin';

  @override
  String get medicationNotesLabel => 'Notas (opcional)';

  @override
  String get medicationNotesHint => 'p. ej. tomar con comida';

  @override
  String get medicationDescriptionLabel => 'Descripción detallada (opcional)';

  @override
  String get medicationDescriptionHint =>
      'Ayuda a distinguir medicamentos parecidos';

  @override
  String get medicationPhotoTitle => 'Foto de la pastilla (opcional)';

  @override
  String get medicationPhotoHint =>
      'Una foto ayuda a reconocerlo y evita confusiones';

  @override
  String get medicationPhotoTake => 'Hacer una foto';

  @override
  String get medicationPhotoRetake => 'Hacer otra foto';

  @override
  String medicationPhotoError(String error) {
    return 'No se ha podido cargar la foto: $error';
  }

  @override
  String get medicationActiveTitle => 'Activo';

  @override
  String get medicationActiveOn => 'Aparece en la lista del día';

  @override
  String get medicationActiveOff => 'Está archivado';

  @override
  String get medicationDeleteTitle => '¿Borrar el medicamento?';

  @override
  String get medicationDeleteMessage =>
      '¿Seguro que quieres borrar este medicamento?';

  @override
  String get medicationDeleteConfirmMessage =>
      'Este medicamento se borrará definitivamente.';

  @override
  String get medicationDeleted => 'Medicamento borrado';

  @override
  String get medicationIntakeTimesLabel => 'Horas de toma';

  @override
  String get medicationMaxDailyLabel => 'Máx. al día';

  @override
  String get medicationMinGapLabel => 'Intervalo mín.';

  @override
  String get medicationStatusLabel => 'Estado';

  @override
  String get medicationStatusTaken => 'Tomado';

  @override
  String get medicationStatusRefused => 'Rechazado';

  @override
  String get medicationStatusSnoozed => 'Más tarde';

  @override
  String get medicationTake => 'Tomar';

  @override
  String get medicationTakeAnyway => 'Tomarlo igualmente';

  @override
  String get medicationDailyLimitReached => 'Límite diario alcanzado';

  @override
  String get medicationAddFeedback => 'Añadir cómo te ha ido';

  @override
  String get medicationFeedbackYourExperience => 'Cómo te ha ido';

  @override
  String get medicationRefusalTitle => 'Anotar que se ha rechazado';

  @override
  String get medicationIntakesLabel => 'Tomas';

  @override
  String get medicationNoProfileSelected => 'Ningún perfil seleccionado';

  @override
  String get medicationNoLogPermission => 'Sin permiso para registrar tomas';

  @override
  String get commonGallery => 'Galería';

  @override
  String get commonCamera => 'Cámara';

  @override
  String get medicationStatusSkipped => 'Omitido';

  @override
  String medicationWillBeRefused(String name) {
    return '$name se marcará como rechazado.';
  }

  @override
  String clockTime(String time) {
    return '$time';
  }

  @override
  String medicationReminderAtTime(String time) {
    return 'Recordatorio a las $time';
  }

  @override
  String medicationSnoozedUntil(String name, String time) {
    return '$name — aviso a las $time';
  }

  @override
  String medicationAtTime(String time) {
    return 'a las $time';
  }

  @override
  String medicationDoseCountToday(int available, int max) {
    return 'Disponibles: $available de $max hoy';
  }

  @override
  String medicationLastTaken(String time) {
    return 'Última toma: $time';
  }

  @override
  String medicationNextPossible(String time) {
    return 'Siguiente toma posible a las $time';
  }

  @override
  String medicationNoteLabel(String note) {
    return 'Nota: $note';
  }

  @override
  String medicationLimitWarning(int count, String name) {
    return 'Hoy ya has tomado $count dosis de $name. Ese es el límite diario.';
  }

  @override
  String medicationTakenConfirmation(String name) {
    return '$name tomado';
  }

  @override
  String get anchorTitle => 'Ancla';

  @override
  String get anchorSectionWhenHard => 'Cuando cuesta';

  @override
  String get anchorSectionEveryday => 'Día a día';

  @override
  String get anchorSectionWhenCalm => 'Cuando hay calma';

  @override
  String get fabMedication => 'Medicamento';

  @override
  String get fabDiaryEntry => 'Entrada';

  @override
  String get fabContact => 'Contacto';

  @override
  String get appQuitTitle => '¿Cerrar la app?';

  @override
  String get appQuitMessage => '¿Seguro que quieres cerrar Aurora?';

  @override
  String get emergencyResetTitle => 'Restablecimiento de emergencia';

  @override
  String get emergencyResetWarning =>
      'AVISO: se borrarán todos los datos para siempre.\n\nPerfiles, mensajes, citas, medicamentos, contactos: todo.\n\nEste paso no se puede deshacer.';

  @override
  String get emergencyResetConfirm => 'BORRARLO TODO';

  @override
  String get pwResetCancelledTitle => 'Restablecimiento cancelado';

  @override
  String get pwResetCancelledMessage =>
      'El restablecimiento en curso se ha cancelado con la contraseña antigua. Tu perfil ya está activo.';

  @override
  String get pwResetUnderstood => 'Entendido';

  @override
  String get pwResetNowActiveTitle => 'Nueva contraseña activa';

  @override
  String get pwResetNowActiveMessage =>
      'La nueva contraseña se activó automáticamente al terminar el tiempo de espera. Tu perfil ya está activo.';

  @override
  String get pwResetTitle => 'Restablecer la contraseña';

  @override
  String get pwResetAnswerQuestions =>
      'Responde a las preguntas de seguridad para restablecerla ahora mismo';

  @override
  String pwResetAnswerN(int number) {
    return 'Respuesta $number';
  }

  @override
  String get pwResetForgotAnswers =>
      '¿Has olvidado las respuestas?\nInicia el temporizador de 24 horas';

  @override
  String get pwResetAnswerAll => 'Responde a todas las preguntas';

  @override
  String get pwResetAnswersWrong =>
      'Esas respuestas no son correctas.\n\nPuedes intentarlo otra vez o iniciar el temporizador de 24 horas.';

  @override
  String get pwResetCheckAnswers => 'Comprobar respuestas';

  @override
  String get pwResetSetNewTitle => 'Poner una contraseña nueva';

  @override
  String get pwResetAnswersCorrect =>
      'Has respondido bien a las preguntas de seguridad.';

  @override
  String get pwResetImmediateHint =>
      'Escribe tu nueva contraseña. Se activará de inmediato.';

  @override
  String get pwResetNewPassword => 'Nueva contraseña';

  @override
  String get pwResetConfirmPassword => 'Confirmar contraseña';

  @override
  String get pwResetTooShort => 'La contraseña necesita al menos 4 caracteres';

  @override
  String get pwResetMismatch => 'Las contraseñas no coinciden';

  @override
  String get pwResetChanged =>
      'Contraseña cambiada.\n\nYa puedes entrar con la nueva.';

  @override
  String get pwResetSetPassword => 'Poner la contraseña';

  @override
  String get pwResetTimerHint =>
      'Escribe tu nueva contraseña.\n\nAl empezar corre un temporizador de 24 horas; después podrás activarla.';

  @override
  String pwResetStarted(String waitTime) {
    return 'Restablecimiento iniciado.\n\nTu contraseña antigua sigue activa. En $waitTime podrás activar la nueva.';
  }

  @override
  String get pwResetStartError => 'No se ha podido iniciar el restablecimiento';

  @override
  String get pwResetStart => 'Iniciar restablecimiento';

  @override
  String get pwResetRunningTitle => 'Restablecimiento en curso';

  @override
  String get pwResetWhatsHappening => '¿Qué está pasando?';

  @override
  String get pwResetRunningExplanation =>
      'Hace poco pusiste una contraseña nueva. Por seguridad corre ahora un temporizador de 24 horas.\n\n';

  @override
  String pwResetRemaining(String time) {
    return 'Tiempo restante: $time';
  }

  @override
  String get pwResetReadyTitle => 'Listo para activar';

  @override
  String get pwResetWaitOver => 'El tiempo de espera ha terminado.';

  @override
  String pwResetReadyExplanation(String startTime) {
    return 'Pusiste una contraseña nueva el $startTime. El plazo de seguridad de 24 horas ya ha pasado.';
  }

  @override
  String get pwResetIrreversible =>
      'Si la activas, tu contraseña ANTIGUA será sustituida definitivamente por la NUEVA.';

  @override
  String get pwResetActivated =>
      'Nueva contraseña activada.\n\nYa puedes entrar con ella.';

  @override
  String get pwResetActivateError => 'No se ha podido activar la contraseña';

  @override
  String get pwResetActivate => 'Activar la nueva contraseña';

  @override
  String get profileCurrentlyActive => 'Perfil en uso ahora mismo';

  @override
  String get profilePasswordProtected =>
      'Este perfil está protegido con contraseña';

  @override
  String get profilePasswordLabel => 'Contraseña';

  @override
  String get settingsMapCacheClearQuestion =>
      '¿Borrar todas las teselas de mapa guardadas?';

  @override
  String get settingsMapCacheCleared => 'Caché de mapas vaciada';

  @override
  String get settingsMapPredownloadComingSoon =>
      'La descarga previa llegará en una versión posterior';

  @override
  String get settingsCacheLimitTitle => 'Fijar el límite de la caché';

  @override
  String settingsCacheLimitValue(int size) {
    return 'Tamaño máximo de la caché: $size MB';
  }

  @override
  String settingsCacheLimitMegabytes(int size) {
    return '$size MB';
  }

  @override
  String get settingsCacheLimitExplanation =>
      'Cuando la caché supera este límite, se borran automáticamente las teselas más antiguas.';

  @override
  String get settingsAllDataDeleted => 'Se han borrado todos los datos';

  @override
  String get settingsDeleteIncomplete =>
      'No se ha podido borrar todo. Inténtalo de nuevo.';

  @override
  String get settingsTrackingEnableTitle => '¿Activar el seguimiento continuo?';

  @override
  String get settingsTrackingWhatItDoes => 'Lo que hace este modo:';

  @override
  String get settingsDataStaysHere => 'Tus datos se quedan en este dispositivo';

  @override
  String get settingsDataStaysHereExplanation =>
      'Aurora guarda todos los datos solo en local.';

  @override
  String get settingsBackgroundGpsBattery =>
      'El GPS en segundo plano puede gastar más batería.';

  @override
  String get settingsAndroidStatus => 'Estado de Android:';

  @override
  String get settingsActivate => 'Activar';

  @override
  String get settingsDeactivate => 'Desactivar';

  @override
  String get settingsTrackingDisableTitle =>
      '¿Desactivar el seguimiento continuo?';

  @override
  String get settingsTrackingDisableExplanation =>
      'El seguimiento GPS vuelve a controlarse por perfil.';

  @override
  String get settingsTestNotificationSent => 'Notificación de prueba enviada';

  @override
  String get settingsAndroidSettingNeeded => 'Hace falta un ajuste de Android';

  @override
  String settingsPermissionNeededFor(String permission) {
    return 'Para usar el seguimiento continuo necesitas el permiso «$permission».';
  }

  @override
  String get settingsStepByStep => 'Te lo explico paso a paso:';

  @override
  String get settingsOpenAndroidSettings => 'Abrir los ajustes de Android';

  @override
  String get settingsOpenNow => 'Abrir ahora';

  @override
  String get settingsInTheSettings => 'En los ajustes';

  @override
  String get settingsBackToAurora =>
      'Vuelve a Aurora\nLa app detecta el cambio por sí sola.';

  @override
  String get settingsUnderstood => 'Entendido';

  @override
  String settingsResetPendingFor(String name, String time) {
    return 'Perfil: $name\nTiempo restante: $time';
  }

  @override
  String settingsWhatIs(String name) {
    return '¿Qué es «$name»?';
  }

  @override
  String get settingsAdminTrackingExplanation =>
      'Como administrador puedes controlar el seguimiento GPS de TODOS los perfiles a la vez. Cuando está activo:';

  @override
  String settingsPrerequisite(String permission) {
    return 'Antes hace falta el permiso de Android «$permission».';
  }

  @override
  String get settingsGpsPermission => 'Permiso de GPS';

  @override
  String get settingsBackgroundReady =>
      'Todo listo para el seguimiento continuo.';

  @override
  String settingsHowToEnable(String permission) {
    return 'Cómo activar «$permission»';
  }

  @override
  String get settingsLocationStaysHere =>
      'Tus datos de ubicación se quedan en este dispositivo.';

  @override
  String get settingsTrackingAlwaysOn => 'Seguimiento siempre activo';

  @override
  String get settingsHowNotificationsWork =>
      '¿Cómo funcionan las notificaciones?';

  @override
  String get settingsSendTestNotification =>
      'Enviar una notificación de prueba';

  @override
  String get settingsCheckNotificationsWork =>
      'Comprueba si llegan las notificaciones';

  @override
  String get settingsQueue => 'Cola';

  @override
  String get settingsScheduledNotifications => 'Notificaciones programadas:';

  @override
  String settingsNextAt(String time) {
    return 'Siguiente: $time';
  }

  @override
  String settingsCacheUsage(String used, String limit, String count) {
    return '$used MB de $limit MB • $count teselas';
  }

  @override
  String settingsPercent(int value) {
    return '$value %';
  }

  @override
  String get settingsCacheLimitLabel => 'Límite de la caché';

  @override
  String get settingsPredownloadMaps => 'Descargar mapas por adelantado';

  @override
  String get settingsPredownloadSubtitle =>
      'Descarga mapas de una zona a tu alrededor';

  @override
  String get settingsClearCache => 'Vaciar la caché';

  @override
  String get settingsClearCacheSubtitle =>
      'Borrar todas las teselas de mapa guardadas';

  @override
  String get settingsDiscreetRemindersTitle => 'Avisos sin contenido';

  @override
  String get settingsDiscreetRemindersOn =>
      'En la pantalla de bloqueo solo pone «Aurora — aviso». Lo que significa lo ves al desbloquear.';

  @override
  String get settingsDiscreetRemindersOff =>
      'La pantalla de bloqueo muestra el nombre y la dosis, o la cita, en claro.';

  @override
  String get settingsWhatAuroraSends => 'Lo que Aurora envía';

  @override
  String get settingsWhatAuroraSendsSubtitle =>
      'Consulta cada envío palabra por palabra';

  @override
  String get settingsAlwaysAllow => 'Permitir siempre';

  @override
  String get settingsAlwaysAllowRequired =>
      'Hace falta el permiso de ubicación «Permitir siempre»';

  @override
  String get settingsLocalOnly =>
      'Aurora guarda todos los datos solo en local. Sin nube, sin servidores, sin envíos.';

  @override
  String get settingsTrackingDisableFull =>
      'El seguimiento GPS vuelve a controlarse por perfil.\n\nCada perfil podrá activarlo y desactivarlo por su cuenta.';

  @override
  String get settingsAlwaysAllowNeeded =>
      'Para usar el seguimiento continuo necesitas el permiso «Permitir siempre».';

  @override
  String get settingsWhatIsAlwaysOn => '¿Qué es «seguimiento siempre activo»?';

  @override
  String get settingsAlwaysAllowPrerequisite =>
      'Antes hace falta el permiso de Android «Permitir siempre», para que el seguimiento siga con la app cerrada.';

  @override
  String get settingsHowToEnableAlwaysAllow =>
      'Cómo activar «Permitir siempre»:';

  @override
  String get settingsLocationStaysOffline =>
      'Tus datos de ubicación se quedan en este dispositivo. Aurora funciona sin conexión, sin servidores.';

  @override
  String settingsCountValue(int count) {
    return '$count';
  }

  @override
  String settingsTilesCount(String used, String limit, String count) {
    return '$used MB de $limit MB • $count teselas';
  }

  @override
  String settingsMaxStorage(int size) {
    return '$size MB de almacenamiento máximo';
  }

  @override
  String errorWithDetail(String error) {
    return 'Error: $error';
  }

  @override
  String get securityQuestionsFillAll =>
      'Rellena las tres preguntas y respuestas';

  @override
  String get securityQuestionsSaved =>
      'Preguntas de seguridad guardadas.\n\nYa puedes usarlas para restablecer la contraseña.';

  @override
  String get securityQuestionsRemoveTitle =>
      '¿Quitar las preguntas de seguridad?';

  @override
  String get securityQuestionsRemoveWarning =>
      'Sin las preguntas de seguridad, el temporizador de 24 horas será la única forma de restablecer la contraseña.';

  @override
  String get securityQuestionsRemoved => 'Preguntas de seguridad quitadas';

  @override
  String get securityQuestionsSetupTitle => 'Configurar preguntas de seguridad';

  @override
  String get securityQuestionsSetupExplanation =>
      'Configura tres preguntas de seguridad para poder restablecer la contraseña rápido.';

  @override
  String get securityQuestionsChooseWisely =>
      'Elige preguntas cuyas respuestas nunca olvidarás';

  @override
  String securityQuestionN(int number) {
    return 'Pregunta $number';
  }

  @override
  String securityAnswerToQuestionN(int number) {
    return 'Respuesta a la pregunta $number';
  }

  @override
  String get securityQuestionHint1 => 'p. ej. ¿nombre de mi primera mascota?';

  @override
  String get securityQuestionHint2 => 'p. ej. ¿dónde nació mi madre?';

  @override
  String get securityQuestionHint3 => 'p. ej. ¿mi película favorita de niño?';

  @override
  String get errorReportPreviewTitle => 'Vista previa del informe de error';

  @override
  String get errorReportWhatIsSent => 'Esto es lo que se envía:';

  @override
  String get errorReportContactSection => 'Contacto (opcional)';

  @override
  String get errorReportContactExplanation =>
      'Solo si quieres que podamos escribirte si tenemos preguntas:';

  @override
  String get errorReportEmailLabel => 'Dirección de correo (opcional)';

  @override
  String get errorReportNewsletter => 'Suscribirse a las novedades';

  @override
  String get errorReportNewsletterSubtitle =>
      'Recibe novedades sobre Aurora, como mucho una vez al mes';

  @override
  String get errorReportEmailUseOnly =>
      'Usamos tu correo solo para preguntas sobre este informe.';

  @override
  String get errorReportCopy => 'Copiar';

  @override
  String get errorReportCopied => 'Informe copiado al portapapeles';

  @override
  String errorReportAutoGenerated(String type) {
    return 'Informe generado automáticamente ($type).';
  }

  @override
  String get errorReportQueued =>
      'Informe aceptado. Se enviará en cuanto vuelvas a estar en línea.';

  @override
  String get errorReportFailed => 'No se ha podido enviar el informe';

  @override
  String get errorReportCopyToClipboard => 'Copiar al portapapeles';

  @override
  String permissionsLevel(int level) {
    return 'Nivel $level';
  }

  @override
  String get permissionsSectionExplanation =>
      'Decide qué áreas puede usar este perfil. Cada área se ajusta por separado:';

  @override
  String get permissionsChildPreset => 'Ajuste para niños';

  @override
  String get permissionsAdultPreset => 'Ajuste para adultos';

  @override
  String get permissionsCategoryEmergencyDiary => 'Diario de emergencia';

  @override
  String get permissionsCategoryHelp => 'Ayuda';

  @override
  String get permissionsCategoryMantras => 'Mantras';

  @override
  String get permissionsCategoryGames => 'Juegos';

  @override
  String get permissionsChangeableLater =>
      'Puedes cambiar los permisos cuando quieras en los ajustes';

  @override
  String get errorReportRoute =>
      'El informe va directo a los desarrolladores; si no funciona, Aurora abre tu app de correo. Lo enviado aparece en los ajustes, en «Lo que Aurora envía».';

  @override
  String get errorReportEmailPrivacy =>
      'Usamos tu correo solo para preguntas sobre este informe y no lo damos a nadie.';

  @override
  String errorReportAutoBody(String type) {
    return 'Informe generado automáticamente ($type). Los detalles están en el diagnóstico del dispositivo.';
  }

  @override
  String errorReportClipboardFallback(String email) {
    return 'El informe está en el portapapeles. También puedes enviárnoslo por correo a $email.';
  }

  @override
  String get mapAddressNotFound => 'Dirección no encontrada';

  @override
  String get mapNeedsInternet =>
      'Aurora necesita internet para buscar direcciones';

  @override
  String get mapDataEnabled =>
      'Datos de mapa activados: el mapa se está cargando';

  @override
  String get mapTapOrSearch => 'Toca el mapa o busca una dirección';

  @override
  String get mapAddressLoading => 'Cargando la dirección…';

  @override
  String get mapPickTitle => 'Añadir un lugar';

  @override
  String get mapTapSearchOrLocate =>
      'Toca el mapa, busca una dirección o usa tu ubicación';

  @override
  String get mapSearchHint =>
      'Buscar una dirección (p. ej. calle Iglesia 3, Coswig)';

  @override
  String get mapDataNotLoaded => 'Datos de mapa sin cargar';

  @override
  String get mapEnableToMark =>
      'Activa los datos de mapa para marcar lugares en él.';

  @override
  String get mapDataFromOsm =>
      'Los datos de mapa vienen de OpenStreetMap.\nAurora necesita conexión a internet una sola vez.';

  @override
  String get mapZoomIn => 'Acercar';

  @override
  String get mapZoomOut => 'Alejar';

  @override
  String get mapToMyLocation => 'A mi ubicación';

  @override
  String get feedbackSheetTitle => 'Contactar con el desarrollador';

  @override
  String get feedbackSheetIntro =>
      'Aurora está en beta abierta y vive de tus comentarios.';

  @override
  String get feedbackReplyOnlyIfWanted => 'Solo si quieres una respuesta';

  @override
  String errorOpening(String error) {
    return 'No se ha podido abrir: $error';
  }

  @override
  String errorLinkNotOpened(String url) {
    return 'No se ha podido abrir el enlace: $url';
  }

  @override
  String get thankYouTitle => '¡Gracias!';

  @override
  String get thankYouReportSent =>
      'Tu informe ha llegado y nos ayuda a mejorar Aurora.';

  @override
  String get thankYouReportRecorded => 'Se ha registrado tu informe de error';

  @override
  String get thankYouJoinCommunity => 'Únete a la comunidad';

  @override
  String get thankYouDiscord => 'Servidor de Discord';

  @override
  String get thankYouDiscordSubtitle =>
      'Habla con otras personas usuarias y con el equipo';

  @override
  String get thankYouMoreContact => 'Otras formas de contactarnos';

  @override
  String get thankYouEmailSupport => 'Soporte por correo';

  @override
  String get thankYouWhatsNext => '¿Qué pasa ahora?';

  @override
  String get thankYouBackToApp => 'Volver a Aurora';

  @override
  String get transparencyDeleteTitle => '¿Borrar esta entrada?';

  @override
  String get transparencyDeleteMessage =>
      'La entrada desaparece de esta lista. Lo ya enviado no vuelve por eso.';

  @override
  String get transparencyIntro =>
      'Aquí ves cada envío que ha salido de tu dispositivo, palabra por palabra.';

  @override
  String get transparencyNothingSent => 'Todavía no se ha enviado nada.';

  @override
  String get transparencySendUsageData => 'Enviar datos de uso anónimos';

  @override
  String get transparencyIrreversible =>
      'Lo que ya se ha enviado no se puede recuperar. Está en camino.';

  @override
  String imagePickerAnimalError(String error) {
    return 'No se ha podido elegir el avatar de animal: $error';
  }

  @override
  String get imagePickerCameraNeeded =>
      'Aurora necesita permiso de cámara para hacer fotos';

  @override
  String get imagePickerGalleryNeeded =>
      'Aurora necesita permiso de galería para elegir imágenes';

  @override
  String get imagePickerAllowInSettings => 'Permitirlo en los ajustes';

  @override
  String get imagePickerOpenSettings => 'Abrir los ajustes';

  @override
  String imagePickerPickError(String error) {
    return 'No se ha podido elegir la imagen: $error';
  }

  @override
  String imagePickerSaveError(String error) {
    return 'No se ha podido guardar la imagen: $error';
  }

  @override
  String get feedbackThankYouTitle => 'Hemos recibido tus comentarios';

  @override
  String get feedbackThankYouMessage =>
      '¡Gracias! Tus comentarios nos ayudan a mejorar Aurora.';

  @override
  String get feedbackStayInTouch => 'Sigamos en contacto';

  @override
  String get feedbackAuroraDiscord => 'Aurora en Discord';

  @override
  String get feedbackWebsite => 'Sitio web';

  @override
  String get feedbackEmail => 'Correo';

  @override
  String get crashTitle => 'Algo ha salido mal';

  @override
  String get crashMessage =>
      'Aurora ha encontrado un error inesperado. Tus datos no se ven afectados.';

  @override
  String get crashTechnicalDetails => 'Detalles técnicos';

  @override
  String get crashReport => 'Informar del error';

  @override
  String get crashRestart => 'Reiniciar la app';

  @override
  String get crashContinue => 'Seguir de todos modos';

  @override
  String get doodleSendDrawing => 'Enviar el dibujo';

  @override
  String get doodleSticker => 'Pegatina';

  @override
  String get doodleStrokeWidth => 'Grosor del trazo';

  @override
  String get doodleStrokeThin => 'Trazo fino';

  @override
  String get doodleStrokeMedium => 'Trazo medio';

  @override
  String get doodleStrokeThick => 'Trazo grueso';

  @override
  String get imagePickerDrawYourself => 'Dibujarlo tú';

  @override
  String get doodleAvatarTitle => 'Dibuja tu imagen';

  @override
  String get doodleAvatarDone => 'Listo';

  @override
  String get doodleAvatarEmptyHint => 'Dibuja algo primero';

  @override
  String get permCreateProfilesLabel => 'Añadir una parte';

  @override
  String get permCreateProfilesDesc => 'Incorporar una parte nueva a Aurora';

  @override
  String get permDeactivateProfilesLabel => 'Ocultar una parte';

  @override
  String get permDeactivateProfilesDesc =>
      'Ocultar una parte por un tiempo; se puede volver a mostrar';

  @override
  String get permManagePermissionsLabel => 'Gestionar los permisos';

  @override
  String get permManagePermissionsDesc =>
      'Decidir qué pueden hacer las demás partes';

  @override
  String get permAccessSettingsLabel => 'Ajustes de la app';

  @override
  String get permAccessSettingsDesc => 'Configurar y ajustar Aurora';

  @override
  String get permViewChatLabel => 'Leer el chat';

  @override
  String get permViewChatDesc => 'Ver los mensajes del chat interno';

  @override
  String get permSendChatMessageLabel => 'Poder enviar de todo';

  @override
  String get permSendChatMessageDesc =>
      'Un permiso que cubre todo tipo de mensaje; sustituye a los de abajo';

  @override
  String get permSendTextMessageLabel => 'Escribir texto';

  @override
  String get permSendTextMessageDesc => 'Poner mensajes escritos en el chat';

  @override
  String get permSendDoodleLabel => 'Dibujar';

  @override
  String get permSendDoodleDesc => 'Compartir dibujos y garabatos';

  @override
  String get permSendVoiceMessageLabel => 'Hablar';

  @override
  String get permSendVoiceMessageDesc => 'Grabar algo y enviar tu propia voz';

  @override
  String get permSendImageLabel => 'Enviar imágenes';

  @override
  String get permSendImageDesc => 'Hacer fotos o compartirlas desde la galería';

  @override
  String get permSendVideoLabel => 'Enviar vídeos';

  @override
  String get permSendVideoDesc =>
      'Grabar vídeos o compartirlos desde la galería';

  @override
  String get permDeleteOwnMessagesLabel => 'Borrar los mensajes propios';

  @override
  String get permDeleteOwnMessagesDesc => 'Retirar solo lo que has escrito tú';

  @override
  String get permDeleteAllMessagesLabel => 'Borrar mensajes de otras partes';

  @override
  String get permDeleteAllMessagesDesc =>
      'Quitar también mensajes de otras partes; esto no se puede deshacer';

  @override
  String get permViewCalendarLabel => 'Ver el calendario';

  @override
  String get permViewCalendarDesc => 'Ver lo que viene';

  @override
  String get permCreateEventsLabel => 'Añadir una cita';

  @override
  String get permCreateEventsDesc => 'Poner citas nuevas en el calendario';

  @override
  String get permEditOwnEventsLabel => 'Cambiar las citas propias';

  @override
  String get permEditOwnEventsDesc => 'Editar solo las citas que has puesto tú';

  @override
  String get permEditAllEventsLabel => 'Cambiar todas las citas';

  @override
  String get permEditAllEventsDesc =>
      'Editar también las citas de otras partes';

  @override
  String get permDeleteOwnEventsLabel => 'Borrar las citas propias';

  @override
  String get permDeleteOwnEventsDesc =>
      'Quitar solo las citas que has puesto tú';

  @override
  String get permDeleteAllEventsLabel => 'Borrar todas las citas';

  @override
  String get permDeleteAllEventsDesc =>
      'Quitar también las citas de otras partes; esto no se puede deshacer';

  @override
  String get permAttachEventMediaLabel => 'Adjuntos de la cita';

  @override
  String get permAttachEventMediaDesc => 'Adjuntar imágenes y notas a una cita';

  @override
  String get permCommentOnCalendarEventsLabel => 'Comentar';

  @override
  String get permCommentOnCalendarEventsDesc => 'Añadir algo a una cita';

  @override
  String get permViewMedicationLabel => 'Ver los medicamentos';

  @override
  String get permViewMedicationDesc => 'Ver qué recibe el cuerpo y cuándo';

  @override
  String get permManageMedicationLabel => 'Gestionar los medicamentos';

  @override
  String get permManageMedicationDesc =>
      'Añadir, cambiar y quitar medicamentos';

  @override
  String get permLogMedicationLabel => 'Confirmar una toma';

  @override
  String get permLogMedicationDesc => 'Marcar lo que ya se ha tomado';

  @override
  String get permOverrideMedicationLogLabel => 'Deshacer una toma';

  @override
  String get permOverrideMedicationLogDesc =>
      'Cambiar una confirmación hecha por otra parte';

  @override
  String get permCommentOnMedicationLabel => 'Comentar';

  @override
  String get permCommentOnMedicationDesc => 'Añadir algo a un medicamento';

  @override
  String get permViewOwnDiaryLabel => 'Tu propio diario';

  @override
  String get permViewOwnDiaryDesc => 'Leer solo las entradas propias';

  @override
  String get permViewAllDiariesLabel => 'Todos los diarios';

  @override
  String get permViewAllDiariesDesc =>
      'Leer también las entradas de otras partes';

  @override
  String get permWriteDiaryLabel => 'Escribir en el diario';

  @override
  String get permWriteDiaryDesc => 'Escribir algo en el diario';

  @override
  String get permViewContactsLabel => 'Ver los contactos';

  @override
  String get permViewContactsDesc => 'Ver quién está en tu entorno';

  @override
  String get permManageContactsLabel => 'Gestionar los contactos';

  @override
  String get permManageContactsDesc => 'Añadir, cambiar y quitar personas';

  @override
  String get permCommentOnContactsLabel => 'Comentar';

  @override
  String get permCommentOnContactsDesc => 'Añadir algo sobre una persona';

  @override
  String get permViewFinderLabel => 'Ver el buscador';

  @override
  String get permViewFinderDesc =>
      'Consultar dónde está algo o dónde has estado';

  @override
  String get permManageFinderLabel => 'Gestionar el buscador';

  @override
  String get permManageFinderDesc =>
      'Añadir, cambiar y quitar lugares y objetos';

  @override
  String get permCommentOnFinderEntriesLabel => 'Comentar';

  @override
  String get permCommentOnFinderEntriesDesc =>
      'Añadir algo a un lugar u objeto';

  @override
  String get permCreateDiaryEntryLabel => 'Escribir una entrada';

  @override
  String get permCreateDiaryEntryDesc => 'Crear una entrada nueva en el diario';

  @override
  String get permEditOwnDiaryEntriesLabel => 'Cambiar las entradas propias';

  @override
  String get permEditOwnDiaryEntriesDesc =>
      'Editar solo las entradas que has escrito tú';

  @override
  String get permEditAllDiaryEntriesLabel => 'Cambiar todas las entradas';

  @override
  String get permEditAllDiaryEntriesDesc =>
      'Editar también las entradas de otras partes';

  @override
  String get permDeleteOwnDiaryEntriesLabel => 'Borrar las entradas propias';

  @override
  String get permDeleteOwnDiaryEntriesDesc =>
      'Quitar solo las entradas que has escrito tú';

  @override
  String get permDeleteAllDiaryEntriesLabel => 'Borrar todas las entradas';

  @override
  String get permDeleteAllDiaryEntriesDesc =>
      'Quitar también las entradas de otras partes; esto no se puede deshacer';

  @override
  String get permCommentOnDiaryEntriesLabel => 'Comentar';

  @override
  String get permCommentOnDiaryEntriesDesc => 'Añadir algo a una entrada';

  @override
  String get permViewSharedEntriesLabel => 'Entradas compartidas';

  @override
  String get permViewSharedEntriesDesc =>
      'Leer entradas compartidas con varias partes';

  @override
  String get permViewEmergencyContactsLabel =>
      'Ver los contactos de emergencia';

  @override
  String get permViewEmergencyContactsDesc =>
      'Ver a quién se puede acudir en una emergencia';

  @override
  String get permCallEmergencyContactsLabel => 'Llamar';

  @override
  String get permCallEmergencyContactsDesc =>
      'Llamar a alguien directamente en una emergencia';

  @override
  String get permEditEmergencyContactsLabel =>
      'Editar los contactos de emergencia';

  @override
  String get permEditEmergencyContactsDesc =>
      'Añadir, cambiar y quitar contactos de emergencia';

  @override
  String get permResetPasswordsLabel => 'Restablecer contraseñas';

  @override
  String get permResetPasswordsDesc =>
      'Poner una contraseña nueva a otra parte';

  @override
  String get permChangeOwnPasswordLabel => 'Cambiar la contraseña propia';

  @override
  String get permChangeOwnPasswordDesc =>
      'Poner una contraseña nueva solo para ti';

  @override
  String get permEnableBiometricsLabel => 'Activar la biometría';

  @override
  String get permEnableBiometricsDesc => 'Entrar con huella o con la cara';

  @override
  String get permViewChatTabLabel => 'Área de chat';

  @override
  String get permViewChatTabDesc => 'Poder ver el chat';

  @override
  String get permViewFeedbackTabLabel => 'Área de comentarios';

  @override
  String get permViewFeedbackTabDesc => 'Escribir a quienes desarrollan Aurora';

  @override
  String get permViewCalendarTabLabel => 'Área de calendario';

  @override
  String get permViewCalendarTabDesc => 'Poder ver el calendario';

  @override
  String get permViewMedicationTabLabel => 'Área de medicamentos';

  @override
  String get permViewMedicationTabDesc => 'Poder ver el plan de medicación';

  @override
  String get permViewDiaryTabLabel => 'Área de diario';

  @override
  String get permViewDiaryTabDesc => 'Poder ver el diario';

  @override
  String get permViewContactsTabLabel => 'Área de contactos';

  @override
  String get permViewContactsTabDesc => 'Poder ver los contactos';

  @override
  String get permViewFinderTabLabel => 'Área del buscador';

  @override
  String get permViewFinderTabDesc => 'Poder ver el buscador';

  @override
  String get permViewEmergencyTabLabel => 'Área de emergencia';

  @override
  String get permViewEmergencyTabDesc => 'Poder ver la ayuda de emergencia';

  @override
  String get permViewHelpTabLabel => 'Área de ayuda';

  @override
  String get permViewHelpTabDesc =>
      'Poder ver la ayuda y los servicios de apoyo';

  @override
  String get permViewMantrasTabLabel => 'Área de mantras';

  @override
  String get permViewMantrasTabDesc => 'Poder ver los mantras';

  @override
  String get permViewGamesTabLabel => 'Área de juegos';

  @override
  String get permViewGamesTabDesc => 'Poder ver los juegos';

  @override
  String get permViewTimelineTabLabel => 'Área de la línea del tiempo';

  @override
  String get permViewTimelineTabDesc =>
      'Ver cuándo estuvo cada parte, y en qué lugar';

  @override
  String permissionYouNeed(String permission) {
    return 'Necesitas: $permission';
  }

  @override
  String get fact01 =>
      'El TID (trastorno de identidad disociativo) afecta a cerca del 1-2 % de la población.';

  @override
  String get fact02 =>
      'Cada persona de un sistema puede tener sus propios gustos, capacidades y recuerdos.';

  @override
  String get fact03 =>
      'La comunicación interna es un paso importante hacia la estabilidad y la sanación.';

  @override
  String get fact04 =>
      'La disociación es una reacción natural de protección de la psique.';

  @override
  String get fact05 =>
      'Muchas personas con TID funcionan bien y llevan vidas plenas.';

  @override
  String get fact06 =>
      'Aurora se creó específicamente para que las personas de un sistema hablen entre sí.';

  @override
  String get fact07 =>
      'El área de chat permite hablar de forma segura dentro, sin otras apps.';

  @override
  String get fact08 =>
      'Cada perfil puede tener sus propios permisos, desde acceso total hasta muy limitado.';

  @override
  String get fact09 =>
      'El primer perfil pasa a ser automáticamente el administrador, con todos los permisos.';

  @override
  String get fact10 =>
      'El calendario hace visibles las citas importantes para todas las personas del sistema.';

  @override
  String get fact11 =>
      'En el área de medicamentos puedes gestionar los diarios y los que se toman a demanda.';

  @override
  String get fact12 =>
      'El buscador ayuda a anotar objetos perdidos y volver a encontrarlos.';

  @override
  String get fact13 =>
      'El diario de emergencia registra situaciones difíciles para tu terapeuta.';

  @override
  String get fact14 =>
      'Los mantras pueden ayudarte a aterrizar durante la disociación o el estrés.';

  @override
  String get fact15 =>
      'En el área de contactos puedes valorar a personas importantes y añadir notas.';

  @override
  String get fact16 => 'Puedes elegir un color propio para cada perfil.';

  @override
  String get fact17 =>
      'Las notas de voz permiten comunicarse incluso cuando escribir cuesta.';

  @override
  String get fact18 =>
      'Los garabatos en el chat ayudan a expresar sentimientos que no caben en palabras.';

  @override
  String get fact19 =>
      'Tus entradas se quedan en tu dispositivo. Solo se envía lo que escribes en el formulario de comentarios.';

  @override
  String get fact20 =>
      'Hacer revisiones periódicas con todo el sistema mejora la colaboración.';

  @override
  String get fact21 => 'Un calendario compartido evita solapamientos y estrés.';

  @override
  String get fact22 =>
      'Las notas del diario de emergencia pueden ayudar mucho en terapia.';

  @override
  String get fact23 =>
      'Cada persona del sistema puede tener sus propias necesidades: es completamente normal.';

  @override
  String get fact24 =>
      'Los ejercicios de anclaje ayudan a permanecer en el aquí y ahora.';

  @override
  String get fact25 =>
      'Las rutinas dan seguridad y estructura a todo el sistema.';

  @override
  String get fact26 =>
      'Las pausas importan, también para las personas del sistema.';

  @override
  String get fact27 =>
      'Puedes ocultar perfiles cuando quieras y recuperarlos más tarde.';

  @override
  String get fact28 =>
      'El administrador puede ajustar los permisos cuando quiera.';

  @override
  String get fact29 =>
      'Los medicamentos a demanda se pueden registrar en el momento.';

  @override
  String get fact30 => 'En el chat puedes dirigirte a personas concretas.';

  @override
  String get fact31 => 'Aurora usa cifrado fuerte para los datos sensibles.';

  @override
  String get fact32 => 'Las contraseñas nunca se guardan en claro.';

  @override
  String get fact33 =>
      'Restablecer una contraseña tarda 24 horas, por seguridad.';

  @override
  String get fact34 =>
      'Todos los mensajes del chat son privados y se guardan en el dispositivo.';

  @override
  String get fact35 => 'Cada paso hacia una mejor comunicación es un logro.';

  @override
  String get fact36 =>
      'Está bien tener opiniones distintas dentro del sistema.';

  @override
  String get fact37 => 'Colaborar da fuerza, también dentro.';

  @override
  String get fact38 => 'No estás solo: muchas personas viven bien con TID.';

  @override
  String get sliderChat0 => '👁️ Leer el chat y dibujar';

  @override
  String get sliderChat1 =>
      '✅ Todo en el chat: texto, dibujos, voz, imágenes, vídeos';

  @override
  String get sliderCalendar0 => '❌ Sin acceso al calendario';

  @override
  String get sliderCalendar1 => '👁️ Ver las citas';

  @override
  String get sliderCalendar2 => '📅 Crear y cambiar las citas propias';

  @override
  String get sliderCalendar3 => '✅ Gestionar todas las citas y añadir adjuntos';

  @override
  String get sliderMedication0 => '❌ Sin acceso a los medicamentos';

  @override
  String get sliderMedication1 => '👁️ Ver la lista de medicamentos';

  @override
  String get sliderMedication2 => '✅ Confirmar las tomas';

  @override
  String get sliderDiary0 => '❌ Sin acceso al diario';

  @override
  String get sliderDiary1 => '👁️ Leer solo el diario propio';

  @override
  String get sliderDiary2 => '📝 Escribir en el diario propio';

  @override
  String get sliderDiary3 => '✅ Leer y escribir en todos los diarios';

  @override
  String get sliderContacts0 => '❌ Sin acceso a los contactos';

  @override
  String get sliderContacts1 => '👁️ Ver los contactos';

  @override
  String get sliderContacts2 => '💬 Ver los contactos y comentar';

  @override
  String get sliderContacts3 => '✅ Gestionar contactos: crear, cambiar, borrar';

  @override
  String get sliderFinder0 => '❌ Sin acceso al buscador';

  @override
  String get sliderFinder1 => '👁️ Ver las entradas';

  @override
  String get sliderFinder2 => '✅ Gestionar las entradas';

  @override
  String get sliderEmergencyDiary0 => '❌ Sin acceso al diario de emergencia';

  @override
  String get sliderEmergencyDiary1 => '👁️ Ver las entradas';

  @override
  String get sliderEmergencyDiary2 =>
      '💬 Crear y comentar entradas, cambiar las propias';

  @override
  String get sliderEmergencyDiary3 => '✅ Gestionar todas las entradas';

  @override
  String get sliderEmergency0 => '❌ Sin acceso a los contactos de emergencia';

  @override
  String get sliderEmergency1 => '👁️ Ver los contactos de emergencia';

  @override
  String get sliderEmergency2 =>
      '📞 Ver y llamar a los contactos de emergencia';

  @override
  String get sliderEmergency3 => '✅ Gestionar los contactos de emergencia';

  @override
  String get sliderHelp0 => '❌ Sin acceso a la ayuda';

  @override
  String get sliderHelp1 => '✅ Ver la ayuda y los servicios de apoyo';

  @override
  String get sliderMantras0 => '❌ Sin acceso a los mantras';

  @override
  String get sliderMantras1 => '✅ Usar los mantras';

  @override
  String get sliderGames0 => '❌ Sin acceso a los juegos';

  @override
  String get sliderGames1 => '✅ Jugar';

  @override
  String get settingsDeleteAll => 'Borrarlo todo';

  @override
  String get settingsCacheClearHint =>
      'Los mapas se cargarán de nuevo la próxima vez. Esto puede liberar espacio.';

  @override
  String get settingsGpsWhileInUse => 'Permitido durante el uso ✓';

  @override
  String get settingsGpsNotAllowed => 'No permitido';

  @override
  String settingsGpsStatusLine(String status) {
    return '⚠️ $status';
  }

  @override
  String get settingsGpsBackgroundRuns =>
      'El GPS funciona todo el tiempo en segundo plano';

  @override
  String get settingsGpsOverridesAll =>
      'Sustituye el ajuste de seguimiento de TODOS los perfiles';

  @override
  String get settingsStepTapPermission => 'Toca «Permisos»';

  @override
  String get settingsStepTapLocation => 'Toca «Ubicación»';

  @override
  String get settingsStepChooseAlways => 'Elige «Permitir siempre»';

  @override
  String get settingsStepOpenSettings =>
      'Toca abajo «Abrir los ajustes de Android»';

  @override
  String get settingsStepPermissionLocation => 'Elige «Permisos» → «Ubicación»';

  @override
  String get settingsPositionAlways =>
      'La posición se registra de forma continua';

  @override
  String get settingsOverridesProfiles => 'Sustituye el ajuste de cada perfil';

  @override
  String get settingsAllProfilesTracked =>
      'Todos los perfiles se registran automáticamente';

  @override
  String get settingsOpenGpsSettings => 'Abrir los ajustes de GPS';

  @override
  String get settingsGpsRunsForAll =>
      'El GPS funciona todo el tiempo para todos los perfiles';

  @override
  String get settingsNotifAsNeeded =>
      'Medicación a demanda: Aurora avisa en cuanto se permite la siguiente dosis, 30, 10 y 5 minutos antes';

  @override
  String get settingsNotifWorksClosed => 'Funciona también con la app cerrada';

  @override
  String get aboutTitle => 'Sobre Aurora';

  @override
  String get aboutChat =>
      'Hablar entre vosotros: con texto, imágenes, vídeos y notas de voz';

  @override
  String get aboutCalendar => 'Citas compartidas con avisos y adjuntos';

  @override
  String get aboutMedication =>
      'Planes de medicación con registro de cada toma';

  @override
  String get aboutEmergencyDiary =>
      'Un cuaderno compartido para crisis y momentos importantes';

  @override
  String get aboutContacts =>
      'Tus valoraciones y notas sobre las personas de tu entorno';

  @override
  String get aboutFinder => 'Volver a encontrar lugares y objetos';

  @override
  String get aboutLocalOnly =>
      'Todos los datos se quedan en tu dispositivo: sin nube';

  @override
  String get telemetryQuestion => '¿Nos ayudas a mejorar Aurora?';

  @override
  String get telemetryExplanation =>
      'Aurora puede contar qué áreas se abren y dónde se interrumpen los procesos. Solo se envía el nombre del evento, el día y la versión de la app: ningún texto, ninguna ubicación y nada que lleve hasta ti. Cada mensaje se envía de inmediato, así que la hora de llegada es también la hora en la que usaste Aurora.';

  @override
  String get telemetryChangeLater =>
      'Puedes cambiarlo cuando quieras en los ajustes, en «Lo que Aurora envía». Allí también aparece cada mensaje que ha salido de tu dispositivo.';

  @override
  String get transparencyIntroFull =>
      'Aquí ves cada envío que ha salido de tu dispositivo, completo y palabra por palabra.';

  @override
  String get transparencyIrreversibleFull =>
      'Lo que ya se ha enviado no se puede recuperar. No está asociado a ti, y por eso tampoco se puede encontrar ni borrar.';

  @override
  String get transparencyWaitingForConnection => 'Esperando conexión';

  @override
  String get privacyTitle => 'Aviso de privacidad';

  @override
  String get privacyAtAGlance => 'La privacidad de un vistazo';

  @override
  String get privacyWhatIsStored => '¿Qué datos se guardan?';

  @override
  String get privacyTransmission => 'Envío de datos';

  @override
  String get privacyDeletion => 'Borrado de datos';

  @override
  String get privacyMinors => 'Protección de menores';

  @override
  String get privacyChanges => 'Cambios en este aviso';

  @override
  String get privacyClosing => 'Aurora: tus datos se quedan contigo.';

  @override
  String get mediaImageNotOpened => 'No se ha podido abrir la imagen';

  @override
  String get mediaVideoNotOpened => 'No se ha podido abrir el vídeo';

  @override
  String get mediaFromGallery => 'De la galería';

  @override
  String get mediaPickImage => 'Elegir una imagen';

  @override
  String get mediaPickVideo => 'Elegir un vídeo';

  @override
  String get transportDirectToDevelopers => 'Directo a los desarrolladores';

  @override
  String get transportSendFailed =>
      'No se ha podido enviar. Inténtalo más tarde o mándalo por correo.';

  @override
  String get transportRejected => 'El servidor ha rechazado el mensaje.';

  @override
  String get transportUnreachable =>
      'Ahora mismo no se puede contactar con el servidor.';

  @override
  String get transparencyArrived => 'Entregado';

  @override
  String transparencyNotSent(String reason) {
    return 'No enviado: $reason';
  }

  @override
  String get transparencyReasonUnknown => 'motivo desconocido';

  @override
  String get transportTryLaterOrEmail =>
      'Inténtalo más tarde o mándalo por correo.';

  @override
  String get transportEmailInstead =>
      'Puedes enviar tus comentarios por correo en su lugar.';

  @override
  String get crashDialogTitle => 'Aurora se ha cerrado de golpe';

  @override
  String get errorDialogTitle => 'Aurora ha detectado un problema';

  @override
  String get errorHelpUsFix => '¿Nos ayudas a arreglarlo?';

  @override
  String get errorSendingFailed => 'Ha ocurrido un error al enviar.';

  @override
  String get feedbackContactOptions => 'Formas de contactarnos';

  @override
  String get feedbackInvalidEmail => 'Esa dirección de correo no es válida';

  @override
  String get feedbackArrived => '¡Gracias por tus comentarios! Han llegado.';

  @override
  String get feedbackQueued =>
      'Aceptado. Se enviará en cuanto vuelvas a estar en línea.';

  @override
  String get feedbackSendFailed =>
      'No se ha podido enviar. Inténtalo más tarde.';

  @override
  String get profilePickImage => 'Elegir imagen de perfil';

  @override
  String get profilePasswordOptional =>
      'Protege tu perfil con una contraseña (opcional)';

  @override
  String get profilePasswordOptionalMin =>
      'Protege tu perfil con una contraseña (opcional, mínimo 4 caracteres)';

  @override
  String get thankYouWeReceived =>
      'Hemos recibido tu informe y te escribiremos por correo si tenemos preguntas.';

  @override
  String get thankYouWeCheck => 'Revisamos tu informe';

  @override
  String get thankYouWeFix => 'Trabajamos en una solución';

  @override
  String get thankYouYouGetMail =>
      'Recibirás un correo en cuanto la solución esté lista';

  @override
  String get thankYouNextUpdate =>
      'La solución llegará con la próxima actualización';

  @override
  String get mapGpsLoading => 'Cargando el GPS…';

  @override
  String get mapGpsPositionLoading => 'Cargando la posición…';

  @override
  String get mapAllowLocation =>
      'Permite el acceso a la ubicación para verte en el mapa';

  @override
  String mapLastKnownPosition(String age) {
    return 'El mapa muestra tu última posición conocida: $age.';
  }

  @override
  String get pwResetThenReplaced =>
      '✓ Solo entonces se sustituye la contraseña antigua';

  @override
  String get pwResetCanActivateNow => 'Ya puedes activar tu nueva contraseña';

  @override
  String get pwResetRunningShort => 'Restablecimiento en curso…';

  @override
  String get moodVeryHappy => 'Muy feliz';

  @override
  String get moodHappy => 'Feliz';

  @override
  String get moodAnxious => 'Con ansiedad';

  @override
  String get moodAngry => 'Enfadado';

  @override
  String get emergencyPositionUnavailable => 'Posición no disponible';

  @override
  String get emergencyPositionNoPermission =>
      'Posición no disponible (sin permiso)';

  @override
  String get emergencyMessageSubject => 'Mensaje de emergencia de Aurora';

  @override
  String autoLogoutAfter(int minutes) {
    return 'Cerrar sesión automáticamente tras $minutes minutos sin uso';
  }

  @override
  String get pwResetBannerReady => 'Contraseña lista para activar';

  @override
  String get doodleHistory => 'Recorrer el historial';

  @override
  String get doodleDraw => 'Dibujar';

  @override
  String get doodleSendEmptyHint => 'Dibuja primero — luego puedes enviar';

  @override
  String get anchorTelemetryNotice =>
      'El recuento anónimo está activado — lo que envía Aurora';

  @override
  String get timePhaseMorning => 'por la mañana';

  @override
  String get timePhaseMidday => 'al mediodía';

  @override
  String get timePhaseAfternoon => 'por la tarde';

  @override
  String get timePhaseEvening => 'al anochecer';

  @override
  String get timePhaseNight => 'de noche';

  @override
  String get greetingMorning => 'Buenos días';

  @override
  String get greetingDay => 'Buenas tardes';

  @override
  String get greetingEvening => 'Buenas noches';

  @override
  String get anchorSwitchProfile => 'No soy yo';

  @override
  String get greetingNight => 'Hola';

  @override
  String get quickTimelineYou => '(Tú)';

  @override
  String todayEvents(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count citas hoy',
      one: '1 cita hoy',
    );
    return '$_temp0';
  }

  @override
  String todayMedications(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count medicamentos hoy',
      one: '1 medicamento hoy',
    );
    return '$_temp0';
  }

  @override
  String workSurfaceActiveProfile(String name) {
    return '$name está aquí ahora';
  }

  @override
  String get doodleUndo => 'Deshacer';

  @override
  String get doodleClear => 'Borrarlo todo';

  @override
  String get finderPersonName => 'Nombre de la persona';

  @override
  String get finderPlaceTitle => 'Título para este lugar';

  @override
  String get commonLoading => 'Cargando…';

  @override
  String get puzzleCategoryAnimals => 'Animales tiernos que calman';

  @override
  String get puzzleCategoryWater => 'Mar y agua';

  @override
  String get puzzleCategoryFlowers => 'Flores y plantas de colores';

  @override
  String get gpsTrackingOffTap => 'Registro desactivado: toca para activarlo';

  @override
  String get gpsTrackingOnTap => 'Registro activado: toca para desactivarlo';

  @override
  String get gpsNoPermissionHint =>
      'Sin el permiso de ubicación, Aurora no puede empezar a registrar. Puedes concederlo en los ajustes de Android, en Apps → Aurora → Permisos.';

  @override
  String get settingsCouldNotOpen => 'No se han podido abrir los ajustes.';

  @override
  String get settingsOpenAppSettings => 'Abrir los ajustes de la app';

  @override
  String get gpsWaitingFirstUpdate => 'Esperando la primera posición…';

  @override
  String get imagePickerOpenCamera => 'Abrir la cámara';

  @override
  String get imagePickerFromGallery => 'Elegir de la galería';

  @override
  String get imagePickerAnimalAvatar => 'Elegir un avatar de animal';

  @override
  String get animalAvatarDog => 'Perro';

  @override
  String get animalAvatarCat => 'Gato';

  @override
  String get animalAvatarGiraffe => 'Jirafa';

  @override
  String get puzzleDragPieces => 'Arrastra las piezas a su sitio';

  @override
  String get puzzleTapPieces => 'Mueve las piezas tocándolas';

  @override
  String get feedbackTabSend => 'Enviar comentarios';

  @override
  String get pwResetRunningFull =>
      'Hace poco pusiste una contraseña nueva. Por seguridad corre ahora un temporizador de 24 horas.\n\n✓ Tu contraseña ANTIGUA sigue activa\n✓ Al terminar el plazo podrás activar la nueva\n✓ Solo entonces se sustituye la antigua';

  @override
  String get transportRejectedFull =>
      'El servidor ha rechazado el mensaje. Mándalo por correo en su lugar.';

  @override
  String get transportUnreachableFull =>
      'Ahora mismo no se puede contactar con el servidor. Inténtalo más tarde o mándalo por correo.';

  @override
  String transportFailedWithCode(String code) {
    return 'No se ha podido enviar ($code). Puedes enviar tus comentarios por correo en su lugar.';
  }

  @override
  String get transportNoMailApp =>
      'No se ha podido abrir ninguna app de correo. Puedes copiar el texto y enviarlo tú.';

  @override
  String get emergencySmsSubject => 'Mensaje de emergencia de Aurora';

  @override
  String get pwResetBannerRunning => 'Restablecimiento en curso';

  @override
  String get puzzleDragHint => 'Arrastra las piezas a su sitio';

  @override
  String get puzzleTapHint => 'Mueve las piezas tocándolas';

  @override
  String get medicationConfirm => 'Confirmar';

  @override
  String get medicationAddFirstAsNeeded =>
      'Añade tu primer medicamento a demanda';

  @override
  String medicationTakenBy(String name) {
    return '✓ Tomado por $name';
  }

  @override
  String medicationRefusedBy(String name) {
    return '✗ Rechazado por $name';
  }

  @override
  String get imprintPerLaw => 'Información según el § 5 TMG (ley alemana)';

  @override
  String get imprintResponsible => 'Responsable del contenido';

  @override
  String get timelineSkipped => 'omitido';

  @override
  String get timelineDueSoon => 'Pronto';

  @override
  String get medicationLater => 'más tarde';

  @override
  String get debugLogHint =>
      'Este informe contiene datos técnicos de la app. Cópialo con el botón de arriba a la derecha para enviarlo si algo falla.';

  @override
  String get unsavedChangesTitle => 'Cambios sin guardar';

  @override
  String get hotlineForYoung => 'Para niños y jóvenes';

  @override
  String get hotlineAnonymousFree => 'Gratuito y anónimo';

  @override
  String get hotlineHoursNumberAgainstSorrow => 'Lu–Sa 14–20 h';

  @override
  String get hotlineInfoNotAcute => 'Información, no ayuda aguda';

  @override
  String get hotlineHoursDepressionInfo =>
      'Lu, Ma, Ju 13–17 h · Mi, Vi 8:30–12:30 h';

  @override
  String get hotlineChatUnder25 =>
      'Asesoramiento por chat, para menores de 25 años';

  @override
  String get helpEmergencyDangerTitle => 'Si alguien está en peligro inmediato';

  @override
  String get helpEmergencyDangerBody =>
      'El número de emergencia funciona día y noche, incluso sin saldo.';

  @override
  String get helpEmergencyCallEmergencyNumber => 'Emergencias 112';

  @override
  String get helpTalkTitle => 'Si necesitas hablar o quieres asesoramiento';

  @override
  String get helpGroupRoundTheClock => 'Disponible las 24 horas';

  @override
  String get helpGroupLimitedHours => 'Disponible en horarios concretos';

  @override
  String helpSourcesCheckedOn(String datum) {
    return 'Datos verificados el $datum';
  }

  @override
  String get cameraCouldNotOpen => 'No se ha podido abrir la cámara';

  @override
  String get feedbackDeviceDiagnostics => '--- Diagnóstico del dispositivo ---';

  @override
  String get eventNoReminder =>
      'La cita solo está en el calendario. Aurora no avisará por su cuenta.';

  @override
  String get unsavedChangesMessage =>
      'Has hecho cambios.\n\n¿Quieres guardarlos?';

  @override
  String get confirmSave => 'Guardar';

  @override
  String get videoCouldNotLoad => 'No se ha podido cargar el vídeo';

  @override
  String get finderDaily => 'a diario';

  @override
  String get mapNotAvailable => 'Mapa no disponible';

  @override
  String get medicationAnotherDose =>
      '¿Quieres tomar otra dosis de todos modos?';

  @override
  String get feedbackThankYouReceived =>
      'Hemos recibido tus comentarios y te escribiremos por correo si tenemos preguntas.';

  @override
  String get positionAgeYesterday => 'de ayer';

  @override
  String get timePickerTitle => 'Elegir la hora';

  @override
  String get reminderPermissionMissingTitle =>
      'Aurora no puede recordarte ahora mismo';

  @override
  String reminderPermissionMissingBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Los recordatorios están activados para $count horas de toma. Sin el permiso del dispositivo no llega ninguno.',
      one:
          'Los recordatorios están activados para una hora de toma. Sin el permiso del dispositivo no llegará.',
    );
    return '$_temp0';
  }

  @override
  String get reminderPermissionMissingAction => 'Dar permiso';

  @override
  String get timePickerHours => 'Horas';

  @override
  String get timePickerMinutes => 'Minutos';

  @override
  String get commentsNoneYet => 'Todavía sin comentarios';

  @override
  String get notificationDiscreetBody => 'Aviso: toca para verlo';

  @override
  String get reminderNoPermission =>
      'Sin permiso de notificaciones, Aurora no puede avisarte. Puedes concederlo en los ajustes de Android, en Apps → Aurora → Notificaciones.';

  @override
  String get telemetryConsentAccept => 'Sí, con gusto';

  @override
  String get telemetryConsentDecline => 'Continuar sin';

  @override
  String get transparencyGroupTelemetry => 'Telemetría';

  @override
  String get telemetryExampleIntro => 'Así se ve un mensaje:';

  @override
  String get telemetryExampleEvent => 'Evento';

  @override
  String get telemetryExampleDay => 'Día';

  @override
  String get telemetryExampleVersion => 'Versión de la app';

  @override
  String get onboardingDismiss => 'No mostrar más';

  @override
  String get eventStart => 'Inicio';

  @override
  String get eventEnd => 'Fin';

  @override
  String get chatCapturePhoto => 'Hacer una foto';

  @override
  String get chatCaptureImageShort => 'Foto';

  @override
  String get doodleErase => 'Borrar';

  @override
  String get chatRecordVideo => 'Grabar un vídeo';

  @override
  String get chatRecordVideoSubtitle => 'Crear un vídeo nuevo';

  @override
  String get actionDiscard => 'Descartar';

  @override
  String get actionKeep => 'Conservar';

  @override
  String get actionDetails => 'Detalles';

  @override
  String get resetWaitingPeriodTitle => 'Plazo de espera al restablecer';

  @override
  String get fieldNameHint => 'p. ej. Max, Ana, Leo';

  @override
  String get fieldPasswordHint => 'Mínimo 4 caracteres';

  @override
  String get fieldPasswordConfirmHint => 'Repetir contraseña';

  @override
  String get fieldPasswordEnterHint => 'Escribe la contraseña';

  @override
  String get feedbackCommunityJoin => 'Únete a nuestra comunidad';

  @override
  String get feedbackDiscord => 'Servidor de Discord';

  @override
  String get feedbackGithub => 'GitHub';

  @override
  String get feedbackGithubSubtitle => 'Errores e incidencias';

  @override
  String get timelineProfileSwitch => 'Cambio de perfil';

  @override
  String get debugLogReportTitle => 'Informe de diagnóstico';

  @override
  String get formPickImage => 'Elegir una imagen';

  @override
  String get permissionGrant => 'Conceder el permiso';

  @override
  String get pwResetRestart => 'Empezar de nuevo';

  @override
  String get navBackToAnchor => 'Al ancla';

  @override
  String get mapGpsPositionLoadingHint => 'Un momento, por favor';

  @override
  String get voiceRecordingStartFailed => 'No se ha podido empezar a grabar';

  @override
  String get voiceRecordingStopFailed =>
      'No se ha podido terminar la grabación';

  @override
  String get voiceRecordingDiscardFailed =>
      'No se ha podido descartar la grabación';

  @override
  String get trackingPermissionDeniedHint =>
      'Permiso de ubicación denegado. Actívalo en los ajustes.';

  @override
  String get pwResetVisibleToAll =>
      'El plazo corre a la vista de todo el mundo';

  @override
  String get pwResetRestartResetsTimer =>
      'Ojo: volver a empezar reinicia el plazo';

  @override
  String get pwResetActivatedAtNextLogin =>
      'La contraseña nueva se activa en el próximo inicio de sesión';

  @override
  String get imagePickerCameraDeniedForever =>
      'El permiso de cámara se ha denegado para siempre. Actívalo en los ajustes.';

  @override
  String get imagePickerGalleryDeniedForever =>
      'El permiso de galería se ha denegado para siempre. Actívalo en los ajustes.';

  @override
  String get permissionCameraTitle => 'Permiso de cámara';

  @override
  String get permissionGalleryTitle => 'Permiso de galería';

  @override
  String get profileResetFristExplanation =>
      'Ese es el tiempo que espera un restablecimiento de contraseña antes de surtir efecto. Si inicias sesión durante ese plazo, se cancela.';

  @override
  String get cameraNotFound => 'No se ha encontrado ninguna cámara';

  @override
  String get validationNameRequired => 'Escribe un nombre';

  @override
  String get validationPasswordRequired => 'Escribe la contraseña';

  @override
  String get transportCopyManually => 'Puedes copiar el texto y enviarlo tú.';

  @override
  String get statusSending => 'Enviando...';

  @override
  String get errorReportSendButton => 'Enviar el informe';

  @override
  String get settingsGpsStatusAlwaysReady => '✅ Permitido siempre (¡listo!)';

  @override
  String get gpsActive => 'GPS activo';

  @override
  String get gpsOff => 'GPS apagado';

  @override
  String get gpsStatusUnknown => 'Estado del GPS desconocido';

  @override
  String get gpsPermissionMissing => 'Falta el permiso de ubicación';

  @override
  String get gpsServiceDisabled => 'Servicio de ubicación desactivado';

  @override
  String get permissionMissingShort => 'Falta el permiso';

  @override
  String get pwResetWrongPassword => 'Contraseña incorrecta';

  @override
  String get pwResetStartTitle => '¿Empezar el restablecimiento?';

  @override
  String get pwResetExpired => 'El plazo ha terminado';

  @override
  String get pwResetForgotPassword => '¿Has olvidado la contraseña?';

  @override
  String get commentWritePlaceholder => 'Escribe un comentario...';

  @override
  String get profileVisibilityTitle => 'A qué perfiles pertenece';

  @override
  String get addressUnknown => 'Dirección desconocida';

  @override
  String get activateNow => 'Activar ahora';

  @override
  String get eventRemindMe => 'Recordatorio';

  @override
  String get noProfileAvailable => 'Todavía no hay ningún perfil';

  @override
  String get ratingVeryNegative => 'Muy negativo';

  @override
  String get ratingVeryPositive => 'Muy positivo';

  @override
  String get errorReportHelpUs => 'Ayúdanos a arreglar el fallo';

  @override
  String get errorReportDetailsSection => 'Detalles del informe';

  @override
  String get trackingLabel => 'Seguimiento GPS: ';

  @override
  String trackingLastUpdate(Object time) {
    return 'Última actualización: $time';
  }

  @override
  String profileSwitchError(Object error) {
    return 'No se ha podido cambiar de perfil: $error';
  }

  @override
  String get gpsError => 'Error de GPS';

  @override
  String get statusActive => 'Activo';

  @override
  String get statusPaused => 'En pausa';

  @override
  String timeSecondsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count segundos',
      one: 'hace un segundo',
    );
    return '$_temp0';
  }

  @override
  String timeInMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'en $count minutos',
      one: 'en un minuto',
    );
    return '$_temp0';
  }

  @override
  String timeInHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'en $count horas',
      one: 'en una hora',
    );
    return '$_temp0';
  }

  @override
  String timeInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'en $count días',
      one: 'en un día',
    );
    return '$_temp0';
  }

  @override
  String get languageFollowApp => 'Idioma de la aplicación';

  @override
  String get profileLanguageSubtitle =>
      'El idioma en el que Aurora habla con esta parte';

  @override
  String get contactCategoryFamily => 'Familia';

  @override
  String get contactCategoryFriends => 'Amigos';

  @override
  String get contactCategoryTherapists => 'Terapeutas';

  @override
  String get contactCategoryDoctors => 'Médicos';

  @override
  String get contactCategoryEmergency => 'Emergencia';

  @override
  String get contactCategoryOther => 'Otros';

  @override
  String get finderTypeLocation => 'Lugar';

  @override
  String get finderTypeItem => 'Objeto';

  @override
  String get diaryPriorityLow => 'Baja';

  @override
  String get diaryPriorityMedium => 'Media';

  @override
  String get diaryPriorityHigh => 'Alta';

  @override
  String get diaryPriorityCritical => 'Crítica';

  @override
  String get moodNeutral => 'Neutral';

  @override
  String get moodSad => 'Triste';

  @override
  String get moodVerySad => 'Muy triste';

  @override
  String get moodExcited => 'Emocionado';

  @override
  String timeHoursMinutesAgo(Object hours, Object minutes) {
    return 'hace $hours h $minutes min';
  }

  @override
  String presenceLastFront(Object when) {
    return 'última vez $when';
  }

  @override
  String get privacyGlanceBody =>
      'Aurora guarda todo en tu dispositivo. Tres cosas salen de él, y solo si tú las provocas o las permites: los comentarios que envías, la telemetría tras tu consentimiento y las peticiones de mapas a OpenStreetMap.\n\nQué se envió y cuándo aparece palabra por palabra en Ajustes, en «Lo que Aurora envía». Nada de ello conduce hasta ti.';

  @override
  String get privacyStoredBody =>
      'Estos datos están en la base de datos local de tu dispositivo:\n\n• Partes y ajustes\n• Mensajes entre partes\n• Citas del calendario\n• Planes de medicación y tomas\n• Entradas del diario y de emergencia\n• Contactos con valoraciones y notas\n• Lugares y objetos del buscador\n• Historial de ubicación y cambios de parte\n• Imágenes, vídeos y mensajes de voz\n\nNada de esto se transmite.';

  @override
  String get privacyTransmissionBody =>
      'Comentarios: solo cuando envías el formulario. Contienen tu texto, la versión de la app y el modelo del dispositivo. Ningún nombre, ningún identificador, ninguna ubicación.\n\nTelemetría: solo tras tu consentimiento expreso, que puedes retirar en cualquier momento. Un evento lleva tres campos: qué ocurrió, qué día y con qué versión de la app. Sin hora, sin identificador.\n\nMapas: al mostrar un mapa y al resolver una dirección, la sección visible del mapa y tu dirección IP van a OpenStreetMap. Es la condición para que exista un mapa.\n\nNunca se transmiten: historial de ubicación, partes, mensajes, citas, medicación, diario ni contactos.';

  @override
  String get privacyPermissions => 'Permisos';

  @override
  String get privacyPermissionsBody =>
      '• Ubicación: para el mapa, el historial de ubicación y la pantalla de emergencia. Permanece en el dispositivo.\n• Ubicación en segundo plano: solo si activas el registro continuo. Sin ese interruptor no hace falta.\n• Cámara y micrófono: para fotos y mensajes de voz.\n• Almacenamiento: para cargar imágenes y vídeos de tu galería.\n• Notificaciones y alarmas: para recordatorios de medicación y citas.\n\nCada permiso se puede retirar en los ajustes del sistema. La app dirá entonces qué deja de funcionar.';

  @override
  String get privacySecurity => 'Seguridad de los datos';

  @override
  String get privacySecurityBody =>
      '• Todos los datos son locales; no hay sincronización en la nube.\n• Las partes pueden protegerse con contraseña.\n• No hay cuentas de usuario ni inicio de sesión.\n\nLas copias de seguridad son responsabilidad tuya. Si pierdes el dispositivo o se rompe, los datos se pierden: ese es el precio de que no estén en ningún otro sitio.';

  @override
  String get privacyDeletionBody =>
      '• Puedes borrar entradas y mensajes concretos.\n• Las partes se pueden desactivar o borrar.\n• En Ajustes existe «Borrar todos los datos».\n• Al desinstalar la app desaparece todo con ella.\n\nLo borrado no se puede recuperar.';

  @override
  String get privacyRights => 'Tus derechos';

  @override
  String get privacyRightsBody =>
      'Según el RGPD tienes derecho de acceso, rectificación, supresión, limitación, portabilidad y oposición. Como todos los datos están en tu dispositivo, ejerces la mayoría directamente en la app.\n\nPara los comentarios enviados y para la telemetría, dirígete a la dirección de abajo. También tienes derecho a presentar una reclamación ante una autoridad de protección de datos.';

  @override
  String get privacyMinorsBody =>
      'Aurora puede ser usada por menores. No se recogen sobre ellos datos distintos de los de cualquier otra persona, es decir, ninguno salvo por las tres vías mencionadas arriba.\n\nCon usuarios más jóvenes tiene sentido que una persona responsable acompañe la configuración.';

  @override
  String get privacyChangesBody =>
      'Esta declaración puede cambiar con las actualizaciones de la app. La versión vigente es la que ves aquí y lleva su fecha abajo.';

  @override
  String get privacyContact => 'Responsable y contacto';

  @override
  String privacyAsOf(Object date) {
    return 'Actualizado: $date';
  }

  @override
  String get startupFailedTitle => 'Aurora no ha podido iniciarse';

  @override
  String get startupFailedBody =>
      'Algo ha fallado al arrancar. Puedes intentarlo de nuevo. Si no funciona, se pueden borrar todos los datos guardados; Aurora empezará vacía.';

  @override
  String get startupRetry => 'Intentarlo de nuevo';

  @override
  String get startupDeleteAll => 'Borrar todos los datos';

  @override
  String get startupDeleteIncomplete =>
      'No se pudo borrar todo. Una parte sigue aquí.';

  @override
  String get reminderPermissionBlocked =>
      'Aurora aún no puede avisarte. Puedes conceder el permiso en los ajustes del sistema.';

  @override
  String get reminderOpenSettings => 'Abrir ajustes';

  @override
  String get settingsTrackingPermissionNeeded =>
      'Para registrar tu camino, Aurora necesita acceso a la ubicación.';

  @override
  String get settingsHowToEnableLocation => 'Cómo dar acceso a la ubicación:';

  @override
  String get settingsStepChooseWhileUsing =>
      'Elige «Mientras usas la aplicación»';

  @override
  String get settingsTrackingNotice =>
      'Mientras Aurora registra, hay una notificación en la barra. Sin notificación, no se registra.';

  @override
  String get locationTrackingNotificationTitle => 'Aurora recuerda tu camino';

  @override
  String get locationTrackingNotificationBody =>
      'Para que luego puedas encontrar tus lugares. Se queda en el dispositivo.';

  @override
  String profileContinueAs(String name) {
    return 'Continuar como $name';
  }

  @override
  String get profileContinueInProgress => 'Un momento …';

  @override
  String get trackingPausedTitle => 'Registro en pausa';

  @override
  String get trackingPausedBody =>
      'Tras el reinicio, Aurora vuelve a registrar tu recorrido solo cuando la abres. Toca aquí.';

  @override
  String get aboutAuroraSemantics => 'Acerca de Aurora';

  @override
  String get openTimelineSemantics => 'Abrir línea de tiempo';

  @override
  String get timeMapSemantics => 'Abrir línea de tiempo: mapa con hora y lugar';
}
