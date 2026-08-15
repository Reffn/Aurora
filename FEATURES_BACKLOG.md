# 📋 Feature Backlog

Detaillierte Feature-Spezifikationen für Aurora, sortiert nach Priorität und Version.

---

## 🗺️ Karten & Standort Features

### [v3.1] Finder Screen mit Karte

**Priorität:** 🔴 Hoch
**Status:** 📋 Geplant
**Aufwand:** ~3-4 Tage

#### User Stories

**US-1: Orte speichern**
> Als DIS-Patient möchte ich wichtige Orte (Arzt, Therapie, Zuhause) mit Karte speichern, damit ich sie später wiederfinde und meinen Innenpersonen mitteilen kann.

**US-2: Gegenstände verwalten**
> Als DIS-Patient möchte ich Gegenstände mit Beschreibung speichern (wo sie liegen), damit ich sie nach Dissoziation wiederfinde.

**US-3: Auf Karte anzeigen**
> Als Nutzer möchte ich alle gespeicherten Orte auf einer Karte sehen, um räumliche Orientierung zu haben.

#### Akzeptanzkriterien

**Muss:**
- [ ] Zwei Tabs: "Orte" und "Dinge" (ähnlich Medikamente-Screen)
- [ ] Orte-Tab: Liste mit Ort-Cards (ähnlich ContactCard)
- [ ] Dinge-Tab: Liste mit Ding-Cards
- [ ] Create/Edit-Screen mit Formular
- [ ] Für Orte: Interaktive Karte zum Auswählen (Map-Picker)
- [ ] GPS-Koordinaten speichern (latitude/longitude)
- [ ] Adresse manuell eingeben (Textfeld)
- [ ] Foto anhängen (optional, via ImagePicker)
- [ ] Tags hinzufügen (wichtig, notfall, täglich, custom)
- [ ] Suche nach Titel/Beschreibung/Tags
- [ ] Filter nach Tags
- [ ] Detail-Screen mit Karte (nur Anzeige, nicht editierbar)
- [ ] DataEntry Integration (create/update/delete)
- [ ] ValueListenableBuilder für reaktive Updates

**Sollte:**
- [ ] "In Maps öffnen"-Button (externe Navi-App)
- [ ] Sortierung (Alphabet, Erstellungsdatum, Wichtigkeit)
- [ ] Bulk-Actions (mehrere löschen)

**Kann:**
- [ ] Offline-Karten-Download-Dialog (opt-in)
- [ ] Regionen-Auswahl für Offline-Tiles
- [ ] Cache-Verwaltung (Größe anzeigen, löschen)

#### Technische Details

**Dependencies:**
```yaml
dependencies:
  flutter_map: ^7.0.2  # Karten-Anzeige
  latlong2: ^0.9.1     # GPS-Koordinaten
  geolocator: ^13.0.1  # Standort-Services
  # Bereits vorhanden: image_picker
```

**Neue Dateien:**
```
lib/modules/finder/
├── finder_screen.dart            # Haupt-Screen mit Tabs (refactor existing)
├── finder_form_screen.dart       # Create/Edit Screen
├── finder_detail_screen.dart     # Detail-Ansicht
└── widgets/
    ├── finder_item_card.dart     # List-Card (ähnlich ContactCard)
    ├── location_item_card.dart   # Spezielle Card für Orte
    ├── thing_item_card.dart      # Spezielle Card für Dinge
    ├── map_picker.dart           # Map zum Ort auswählen
    ├── map_view.dart             # Map nur zum Anzeigen
    └── tag_chip_list.dart        # Tags als Chips anzeigen
```

**DataEntry Methods:**
```dart
// In lib/core/data_entry.dart
Future<void> createFinderItem(FinderItem item);
Future<void> updateFinderItem(FinderItem item);
Future<void> deleteFinderItem(String itemId);
List<FinderItem> getFinderItems(); // Bereits vorhanden
List<FinderItem> getFinderItemsByType(FinderItemType type);
List<FinderItem> searchFinderItems(String query);
```

#### UI/UX Design

**FinderScreen Layout:**
```
┌─────────────────────────────┐
│  Aurora                  ⚙️  │
├─────────────────────────────┤
│  Profile Switcher Bar        │
├─────────────────────────────┤
│  Tabs: [ Orte | Dinge ]      │
├─────────────────────────────┤
│  🔍 Suche...                 │
├─────────────────────────────┤
│  📍 Arztpraxis               │
│  Dr. Müller, Hauptstr. 12    │
│  🏷️ wichtig, täglich          │
├─────────────────────────────┤
│  🏠 Zuhause                  │
│  Musterweg 5, 12345 Stadt    │
│  🏷️ safe-place               │
├─────────────────────────────┤
│  [+ Neuer Ort]               │
└─────────────────────────────┘
```

**Form-Screen Layout:**
```
┌─────────────────────────────┐
│  < Ort hinzufügen            │
├─────────────────────────────┤
│  📷 [Foto hinzufügen]        │
├─────────────────────────────┤
│  Titel: _________________    │
│  Beschreibung: __________    │
├─────────────────────────────┤
│  🗺️ [Karte - Tap to select]│
│     Lat: 52.5200             │
│     Lon: 13.4050             │
├─────────────────────────────┤
│  Adresse: _______________    │
├─────────────────────────────┤
│  Tags: [wichtig] [notfall]   │
│  [+ Custom Tag]              │
├─────────────────────────────┤
│  [Abbrechen]   [Speichern]   │
└─────────────────────────────┘
```

#### Tests

- [ ] Unit Tests: DataEntry Methods
- [ ] Unit Tests: FinderService Methods
- [ ] Widget Tests: FinderScreen Tabs
- [ ] Widget Tests: FinderItemCard
- [ ] Integration Test: Create → List → Edit → Delete Flow

---

### [v3.2] Notfall mit Standort

**Priorität:** 🔴 Hoch
**Status:** 📋 Geplant
**Aufwand:** ~2 Tage
**Abhängigkeiten:** v3.1 (Finder mit Karte)

#### User Stories

**US-4: Schnelle Hilfe**
> Als DIS-Patient möchte ich im Notfall schnell meinen aktuellen Standort an Vertrauenspersonen senden, damit ich Hilfe bekomme wenn ich desorientiert bin.

**US-5: Wo bin ich?**
> Als Nutzer möchte ich nach Dissoziation schnell sehen wo ich bin, um Orientierung zu bekommen.

#### Akzeptanzkriterien

**Muss:**
- [ ] Notfall-Button (prominent, z.B. in AppBar oder FAB)
- [ ] Notfall-Dialog mit Optionen:
  - "Wo bin ich?" → Zeigt Karte mit aktuellem Standort
  - "Hilfe rufen" → Nachricht an Notfallkontakte
- [ ] Vorgefertigte Nachrichten-Templates:
  - "Ich brauche Hilfe. Mein Standort: [LINK]"
  - "Ich bin desorientiert. Wo bin ich? [LINK]"
  - Custom Templates editierbar
- [ ] Aktueller Standort automatisch einholen
- [ ] Standort als Google Maps Link formatieren
- [ ] An ausgewählte Notfallkontakte senden (SMS oder Share-Dialog)
- [ ] Bestätigungs-Dialog vor Senden
- [ ] Logging: Wann wurde Notfall ausgelöst

**Sollte:**
- [ ] Quick-Action: "Notfall" in Contacts-List (Kontakte mit Tag "notfall")
- [ ] Standort-History: Letzte 5 Notfall-Standorte speichern
- [ ] Safe Places auf Karte hervorheben

**Kann:**
- [ ] Geofencing: Alarm wenn Safe-Zone verlassen wird
- [ ] Auto-Notfall: Nach X Stunden außerhalb Safe-Zone

#### Technische Details

**Neue Dateien:**
```
lib/modules/emergency/
├── emergency_button.dart        # FAB oder AppBar Button
├── emergency_dialog.dart        # Notfall-Optionen Dialog
├── location_share_screen.dart   # "Wo bin ich?" mit Karte
└── emergency_message_templates.dart  # Templates verwalten
```

**DataEntry Methods:**
```dart
Future<void> sendEmergencyMessage(String contactId, String message);
Future<void> logEmergencyEvent(DateTime timestamp, double lat, double lon);
List<EmergencyLog> getEmergencyHistory();
```

#### UI/UX Design

**Notfall-Button:**
- Platzierung: FAB (Floating Action Button) in Main-Screen
- Farbe: Rot (dringend, Aufmerksamkeit)
- Icon: SOS oder Warnung

**Notfall-Dialog:**
```
┌─────────────────────────────┐
│  🚨 Notfall                  │
├─────────────────────────────┤
│  [📍 Wo bin ich?]            │
│  Zeigt Karte mit Standort    │
├─────────────────────────────┤
│  [📱 Hilfe rufen]            │
│  Sendet Nachricht an         │
│  Notfallkontakte             │
├─────────────────────────────┤
│  [Abbrechen]                 │
└─────────────────────────────┘
```

---

### [v3.3] Zeitachse/Timeline für Standortverlauf

**Priorität:** 🟡 Mittel
**Status:** 📋 Geplant
**Aufwand:** ~3-4 Tage
**Abhängigkeiten:** v3.1 (Finder mit Karte)

#### User Stories

**US-6: Blackout-Tracking**
> Als DIS-Patient möchte ich nach einem Blackout sehen wo ich war, damit ich Gedächtnislücken füllen kann.

**US-7: Muster erkennen**
> Als Nutzer möchte ich meinen Standortverlauf über Tage/Wochen sehen, um Muster zu erkennen (z.B. regelmäßige Orte).

#### Akzeptanzkriterien

**Muss:**
- [ ] Opt-In: Nutzer muss Tracking explizit aktivieren
- [ ] Privacy-Einstellungen:
  - Tracking aktivieren/deaktivieren
  - Aufzeichnungs-Intervall (1min, 5min, 15min)
  - Auto-Löschen nach X Tagen (7, 30, 90, nie)
- [ ] Hintergrund-Standort-Tracking (Android WorkManager)
- [ ] Timeline-Screen mit:
  - Tag-Ansicht (heute, gestern, Datum wählen)
  - Woche-Ansicht (Übersicht)
  - Monat-Ansicht (Heatmap?)
- [ ] Karte mit Route für gewählten Zeitraum
- [ ] Zeitstempel für jeden Punkt
- [ ] "Wo war ich?"-Suche: Zeitraum eingeben → Route zeigen
- [ ] Manuell löschen: Einzelne Punkte oder ganzer Tag
- [ ] Datenexport: Timeline als GPX oder KML

**Sollte:**
- [ ] Statistiken: Meistbesuchte Orte
- [ ] Verweildauer an Orten berechnen
- [ ] Integration mit Finder: Gespeicherte Orte auf Timeline markieren

**Kann:**
- [ ] Profile-spezifisch: Welche Innenperson war wo?
- [ ] Notizen zu Timeline-Punkten (was passiert ist)
- [ ] Foto zu Timeline-Punkt anhängen

#### Technische Details

**Dependencies:**
```yaml
dependencies:
  geolocator: ^13.0.1          # Bereits für v3.1
  workmanager: ^0.5.2          # Background Tasks (Android)
  # iOS: Background Location Permission
```

**Neue Dateien:**
```
lib/modules/timeline/
├── timeline_screen.dart         # Haupt-Screen
├── timeline_day_view.dart       # Tag-Ansicht
├── timeline_week_view.dart      # Woche-Ansicht
├── timeline_map_view.dart       # Karte mit Route
├── timeline_settings_screen.dart # Privacy & Settings
└── widgets/
    ├── timeline_point_card.dart  # Einzelner Punkt
    └── location_history_map.dart # Route auf Karte
```

**Models:**
```dart
@HiveType(typeId: 17)
class LocationHistoryPoint {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double latitude;

  @HiveField(2)
  final double longitude;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final String? profileId;  // Welche Innenperson (optional)

  @HiveField(5)
  final String? note;  // Optional: Was passiert ist
}
```

**Background Service:**
```dart
// Android: WorkManager periodic task
// iOS: Background Location Updates
void registerLocationTracking() {
  Workmanager().registerPeriodicTask(
    "location-tracking",
    "locationTask",
    frequency: Duration(minutes: 5), // Aus Settings
  );
}
```

#### Privacy & Security

⚠️ **Sehr sensible Daten!**
- Standortverlauf nur lokal speichern
- Verschlüsselung der LocationHistory-Box (Hive Encryption)
- Klar kommunizieren: "Daten bleiben auf deinem Gerät"
- Einfaches Löschen ermöglichen
- Keine Daten teilen ohne explizite User-Aktion

#### UI/UX Design

**Timeline-Screen:**
```
┌─────────────────────────────┐
│  < Timeline                  │
├─────────────────────────────┤
│  [Heute] [Gestern] [Datum ▼]│
├─────────────────────────────┤
│  🗺️ [Karte mit Route]       │
│                              │
├─────────────────────────────┤
│  ⏰ 14:23 📍 Arztpraxis      │
│  Verweildauer: 45min         │
├─────────────────────────────┤
│  ⏰ 12:15 📍 Restaurant      │
│  Verweildauer: 1h 10min      │
├─────────────────────────────┤
│  ⏰ 09:00 📍 Zuhause         │
│                              │
└─────────────────────────────┘
```

---

## 🌐 Translation Service

### [v3.4] ML Kit Integration für Übersetzungen

**Priorität:** 🟢 Niedrig
**Status:** 📋 Backlog
**Aufwand:** ~2-3 Tage

#### User Stories

**US-8: Chat übersetzen**
> Als DIS-Patient mit mehrsprachigem Innensystem möchte ich Chat-Nachrichten automatisch übersetzen, damit alle Innenpersonen kommunizieren können.

#### Akzeptanzkriterien

**Muss:**
- [ ] ML Kit Translation Integration
- [ ] Language Detection in Chat-Nachrichten
- [ ] Übersetzen-Button bei Nachrichten
- [ ] Target-Language pro Profil einstellbar
- [ ] Offline-Modelle nach Download

**Sollte:**
- [ ] Auto-Translate Option (immer übersetzen)
- [ ] Model-Management (Download, Delete)

#### Technische Details

**Dependencies:**
```yaml
dependencies:
  google_mlkit_translation: ^0.13.1
```

**Implementation:**
- Basiert auf bestehendem `TranslationService` (bereits als Stub vorhanden)
- Chat-Message mit "Translate"-Action erweitern
- Settings: Preferred Language pro Profil

---

## 📖 Tagebuch & Journaling

### [v3.5] Erweitertes Notfall-Tagebuch

**Priorität:** 🟢 Niedrig
**Status:** 📋 Backlog
**Aufwand:** ~2 Tage

#### User Stories

**US-9: Mood Tracking**
> Als Nutzer möchte ich meine Stimmung täglich tracken, um Muster zu erkennen.

**US-10: Reflexion**
> Als Nutzer möchte ich ausführliche Tagebuch-Einträge mit Bildern schreiben.

#### Akzeptanzkriterien

**Muss:**
- [ ] Mood-Slider (1-10) beim Eintrag
- [ ] Foto-Anhänge in Tagebuch-Einträgen
- [ ] Tags für Einträge
- [ ] Statistiken: Mood über Zeit
- [ ] Export als PDF

---

## 💾 Backup & Sync

### [v3.6] Backup-Funktionen

**Priorität:** 🟡 Mittel
**Status:** 📋 Backlog
**Aufwand:** ~3 Tage

#### User Stories

**US-11: Datensicherung**
> Als Nutzer möchte ich meine Daten sichern, falls mein Gerät verloren geht.

#### Akzeptanzkriterien

**Muss:**
- [ ] Lokales Backup (ZIP mit Verschlüsselung)
- [ ] Export/Import zwischen Geräten
- [ ] Backup-Passwort

**Sollte:**
- [ ] Optional: Verschlüsseltes Cloud-Backup (Google Drive, Dropbox)
- [ ] Auto-Backup (täglich/wöchentlich)

---

## 🔔 Smart Reminders

### [v3.7] Intelligente Erinnerungen

**Priorität:** 🟢 Niedrig
**Status:** 📋 Backlog
**Aufwand:** ~2 Tage

#### User Stories

**US-12: Medikamenten-Erinnerungen**
> Als Nutzer möchte ich Erinnerungen für Medikamente, damit ich keine Einnahme vergesse.

#### Akzeptanzkriterien

**Muss:**
- [ ] Lokale Notifications (flutter_local_notifications - bereits vorhanden)
- [ ] Erinnerungen für Medikamente (einmalig, täglich, wöchentlich)
- [ ] Erinnerungen für Termine
- [ ] Snooze-Funktion

---

## 🎨 UI/UX Verbesserungen

### [v3.x] Laufende Verbesserungen

**Priorität:** 🔵 Laufend
**Status:** 🚧 In Progress

#### Akzeptanzkriterien

- [ ] Deprecated `withOpacity()` → `withValues()` Migration
- [ ] BuildContext async gaps beheben (100+ Stellen)
- [ ] Unused Imports/Variables entfernen
- [ ] Type Inference Failures beheben
- [ ] Custom Avatar Upload
- [ ] Weitere Tier-Avatare
- [ ] Themes (Hell/Dunkel/Custom)
- [ ] Accessibility (TalkBack, VoiceOver)

---

## 📊 Analytics & Insights (Privacy-freundlich)

### [v3.8] Lokale Analytics

**Priorität:** 🟢 Niedrig
**Status:** 📋 Backlog

#### User Stories

**US-13: Nutzungs-Statistiken**
> Als Nutzer möchte ich sehen wie oft ich die App nutze, um Fortschritt zu tracken.

#### Akzeptanzkriterien

**Muss:**
- [ ] Lokale Statistiken (keine Telemetrie!)
- [ ] Nutzung pro Feature (Chat, Kalender, etc.)
- [ ] Charts/Graphs
- [ ] Export als PDF

---

*Letzte Aktualisierung: 2025-10-20*
*Dokument-Version: 1.0*
