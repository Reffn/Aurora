import 'package:dis_app/core/events/app_event.dart';
import 'package:dis_app/models/profile.dart';

/// Event: Neues Profil wurde erstellt
class ProfileCreatedEvent extends AppEvent {
  ProfileCreatedEvent(this.profile);
  final Profile profile;
}

/// Event: Profil wurde gespeichert
class ProfileSavedEvent extends AppEvent {
  ProfileSavedEvent(this.profile);
  final Profile profile;
}

/// Event: Profil wurde aktualisiert
class ProfileUpdatedEvent extends AppEvent {
  ProfileUpdatedEvent(this.profile);
  final Profile profile;
}

/// Event: Profil wurde deaktiviert (Soft Delete)
class ProfileDeactivatedEvent extends AppEvent {
  ProfileDeactivatedEvent(this.profileId);
  final String profileId;
}

/// Event: Profil wurde reaktiviert
class ProfileReactivatedEvent extends AppEvent {
  ProfileReactivatedEvent(this.profileId);
  final String profileId;
}

/// Event: Alle Profile wurden angefordert
class ProfilesRequestedEvent extends AppEvent {
  ProfilesRequestedEvent();
}

/// Event: Profile wurden geladen
class ProfilesLoadedEvent extends AppEvent {
  ProfilesLoadedEvent(this.profiles);
  final List<Profile> profiles;
}

/// Event: Aktives Profil wurde gewechselt
class ActiveProfileChangedEvent extends AppEvent {
  ActiveProfileChangedEvent(this.profile);
  final Profile profile;
}

/// Event: Passwort-Reset wurde gestartet
class PasswordResetStartedEvent extends AppEvent {
  PasswordResetStartedEvent(this.profile);
  final Profile profile;
}

/// Event: Passwort-Reset wurde abgebrochen (durch korrektes altes Passwort)
class PasswordResetCancelledEvent extends AppEvent {
  PasswordResetCancelledEvent(this.profile);
  final Profile profile;
}

/// Event: Passwort-Reset wurde aktiviert (neues Passwort ist jetzt aktiv)
class PasswordResetActivatedEvent extends AppEvent {
  PasswordResetActivatedEvent(this.profile);
  final Profile profile;
}
