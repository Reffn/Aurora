# 🏗️ Architecture Decision Records (ADR)

Dokumentation wichtiger architektonischer Entscheidungen für Aurora.

**Format basierend auf:** [Michael Nygard's ADR Template](https://github.com/joelparkerhenderson/architecture-decision-record)

---

## ADR-001: DataEntry-Architektur für zentralisierte Datenoperationen

**Status:** ✅ Accepted (Implementiert in v3.0)

**Kontext:**
- Ursprünglich direkte Service-Zugriffe in UI-Widgets
- Schwer zu testen und zu warten
- Inkonsistente Datenoperationen
- Logging und Validation über viele Files verteilt

**Entscheidung:**
Implementierung einer **DataEntry-Klasse** als zentrale API für alle Datenoperationen (CQRS-ähnlich):
- Kombiniert Commands (Write) und Queries (Read)
- Validation und Logging zentral
- EventBus für reaktive Updates
- Services bleiben als Backend-Layer

**Konsequenzen:**
✅ **Positiv:**
- Konsistente API für UI-Layer
- Einfacheres Testing (Mock DataEntry)
- Zentrales Logging aller Datenoperationen
- Klare Trennung: UI → DataEntry → Services → Hive

❌ **Negativ:**
- Zusätzliche Abstraktionsschicht
- Mehr Boilerplate (jede Operation braucht DataEntry-Method)
- Migration bestehender direkter Service-Zugriffe nötig

**Alternativen:**
- Direkte Service-Zugriffe (abgelehnt: zu verstreut)
- Repository Pattern (abgelehnt: zu komplex für lokale DB)
- BLoC Pattern (abgelehnt: Overkill für einfache CRUD-Ops)

---

## ADR-002: Hive CE für lokale Datenspeicherung

**Status:** ✅ Accepted (v1.0)

**Kontext:**
- Privacy-First: Alle Daten müssen lokal bleiben
- Offline-First: Keine Cloud-Anbindung
- Schnelle Performance nötig
- Type-Safe Persistierung

**Entscheidung:**
**Hive CE** (Community Edition) als NoSQL-Datenbank:
- Type-Safe mit Code-Generation
- Schnell (keine SQL-Parsing)
- Einfache API
- Lazy Box-Loading möglich

**Konsequenzen:**
✅ **Positiv:**
- Sehr schnell (in-memory mit Disk-Sync)
- Einfache API (key-value)
- Type-Safety mit Annotations
- Keine Migrations nötig (flexibles Schema)
- Community Edition: Aktiv maintained

❌ **Negativ:**
- Keine Relations (müssen manuell verwaltet werden)
- Keine komplexen Queries (alle Queries in Dart)
- Code-Generation nötig nach Model-Änderungen

**Alternativen:**
- SQLite (sqflite): Abgelehnt - zu komplex, Migrations nötig
- SharedPreferences: Abgelehnt - nur für simple Key-Value
- Isar: Erwogen - ähnlich wie Hive, aber weniger etabliert

---

## ADR-003: GetIt für Dependency Injection

**Status:** ✅ Accepted (v1.0)

**Kontext:**
- Services müssen app-weit verfügbar sein
- Testing: Services mockbar machen
- Vermeidung von Singletons (testability)

**Entscheidung:**
**GetIt** als Service Locator Pattern:
- Singletons für Services registrieren
- Lazy Initialization
- Einfaches Setup in `injection.dart`

**Konsequenzen:**
✅ **Positiv:**
- Sehr einfache API
- Kein BuildContext nötig (getIt<T>() anywhere)
- Leicht zu mocken für Tests

❌ **Negativ:**
- Service Locator = Anti-Pattern in manchen Architekturen
- Compile-Time Safety fehlt (Fehler erst zur Runtime)

**Alternativen:**
- Provider: Abgelehnt - braucht BuildContext
- Riverpod: Erwogen - komplexer, aber moderne Alternative (evtl. für v4.0)
- get_it + injectable: Möglich für Zukunft (Code-Gen für DI)

---

## ADR-004: EventBus für reaktive Updates

**Status:** ✅ Accepted (v3.0)

**Kontext:**
- UI muss auf Datenänderungen reagieren
- Services müssen auf Events reagieren (z.B. ProfileChanged)
- ValueListenableBuilder für Hive-Boxes funktioniert nicht überall

**Entscheidung:**
**EventBus mit RxDart** für app-weite Events:
- DataEntry publiziert Events nach Datenänderungen
- Services subscriben zu relevanten Events
- UI kann auch subscriben (zusätzlich zu ValueListenableBuilder)

**Konsequenzen:**
✅ **Positiv:**
- Entkopplung: Publisher kennt Subscriber nicht
- Flexible: Neue Subscriber einfach hinzufügbar
- Kombinierbar mit ValueListenableBuilder

❌ **Negativ:**
- Debugging schwieriger (implizite Abhängigkeiten)
- Memory Leaks wenn Subscriptions nicht disposed
- Event-Reihenfolge nicht garantiert

**Alternativen:**
- Nur ValueListenableBuilder: Abgelehnt - nicht für alle Use Cases
- Stream Controllers: Ähnlich, aber EventBus ist einfacher
- Bloc/Cubit: Zu komplex für unsere Needs

---

## ADR-005: Offline-Karten mit flutter_map (Geplant v3.1)

**Status:** 📋 Proposed

**Kontext:**
- Finder-Feature braucht Kartenansicht
- Notfall-Feature braucht Standort auf Karte
- Timeline braucht Route auf Karte
- Privacy: Keine Google Maps (Telemetrie)
- Offline-First: Karten müssen ohne Internet funktionieren

**Entscheidung:**
**flutter_map** mit OpenStreetMap Tiles:
- Open Source
- OSM = freie Kartendaten
- Offline-Tiles-Caching möglich
- Keine API-Keys nötig

**Konsequenzen:**
✅ **Positiv:**
- Privacy-freundlich (keine Google-Tracking)
- Kostenlos
- Offline-Fähig (nach Tile-Download)
- Anpassbar (eigene Tile-Server möglich)

❌ **Negativ:**
- Offline-Tiles = großer Download (~100MB+ pro Region)
- User muss Region auswählen
- Komplexer als Google Maps
- Weniger Features (kein Street View, kein Traffic)

**Konsequenzen für User:**
- Beim ersten Start: Dialog "Karten-Region herunterladen?"
- Ohne Download: Nur Online-Tiles (braucht Internet)
- Settings: Region-Management, Cache löschen

**Alternativen:**
- Google Maps (google_maps_flutter): Abgelehnt - Privacy-Bedenken, API-Key nötig
- Mapbox: Erwogen - API-Key nötig, nicht vollständig kostenlos
- Apple Maps (iOS): Abgelehnt - nur iOS
- Statische Karten-Bilder: Abgelehnt - schlechte UX

**Offene Fragen:**
- Welche Regions zur Auswahl? (Deutschland, Europa, Custom)
- Tile-Server: Eigener oder Public OSM?
- Cache-Size-Limit? (500MB, 1GB?)

---

## ADR-006: Permission-Based Access Control (RBAC)

**Status:** ✅ Accepted (v3.0)

**Kontext:**
- Multi-Profil-System: Jede Innenperson ist anders
- Manche Innenpersonen brauchen Einschränkungen (z.B. Kinder)
- Flexibilität: Admin kann Permissions vergeben

**Entscheidung:**
**Role-Based Access Control** mit granularen Permissions:
- Jedes Profil hat Liste von Permissions
- Admin-Profil: Unrestricted Access
- Age-based Defaults (Kind < 12: eingeschränkt)
- Permissions für: Tabs, Actions (Chat senden, Events erstellen, etc.)

**Konsequenzen:**
✅ **Positiv:**
- Granular kontrollierbar
- Sicher für Kinder-Profile
- Flexibel erweiterbar (neue Permissions einfach hinzufügbar)

❌ **Negativ:**
- Komplexität: Viele Permissions zu managen
- UI-Checks überall nötig
- Permissions können vergessen werden (Code-Review wichtig)

**Alternativen:**
- Einfaches Admin/Non-Admin: Abgelehnt - zu unflexibel
- Roles (Admin, User, Child): Erwogen - weniger flexibel als Permissions
- No Permissions: Abgelehnt - Sicherheitsrisiko

---

## ADR-007: Profile-Avatare mit Asset + File-Path Support

**Status:** ✅ Accepted (v3.0.1)

**Kontext:**
- User wollen Custom-Avatare (Fotos)
- App sollte Default-Avatare anbieten (Tier-Bilder)
- Mix aus Assets (bundled) und User-Fotos (Files)

**Entscheidung:**
**Dual-Path System** in `ProfileImageWidget`:
- Asset-Paths: `assets/images/Hund.png` (bundled)
- File-Paths: `avatar_123.jpg` (relative, in attachments/)
- Automatische Detection: Existiert File? → FileImage, sonst AssetImage

**Konsequenzen:**
✅ **Positiv:**
- Flexibel: Asset-Avatare + Custom-Fotos
- Einfach zu erweitern (neue Assets hinzufügen)
- Relative Paths = Device-unabhängig

❌ **Negativ:**
- Zwei Code-Pfade (Asset vs. File)
- Fehleranfällig wenn File nicht existiert

**Implementation:**
```dart
// ProfileImageWidget
if (avatarPath.startsWith('assets/')) {
  return AssetImage(avatarPath);
} else {
  final file = await AttachmentHelper.getAttachmentFile(avatarPath);
  return FileImage(file);
}
```

---

## ADR-008: WidgetsBindingObserver für Keyboard-Detection

**Status:** ✅ Accepted (v3.0.1)

**Kontext:**
- Chat: Doodle-Feld soll verschwinden wenn Tastatur offen
- MediaQuery.viewInsets funktioniert nicht in PageView (gecached)
- BuildContext nicht immer aktuell

**Entscheidung:**
**WidgetsBindingObserver** in ChatScreen:
- `didChangeMetrics()` callback bei Keyboard-Änderungen
- State-Variable `_keyboardVisible` für UI
- Unabhängig von Widget-Tree

**Konsequenzen:**
✅ **Positiv:**
- Zuverlässig (direkt vom OS)
- Funktioniert in PageView
- Einfach zu implementieren

❌ **Negativ:**
- Mixin nötig in StatefulWidget
- Muss in initState()/dispose() registriert/entfernt werden

**Alternativen:**
- MediaQuery.of(context).viewInsets: Abgelehnt - funktioniert nicht in PageView
- LayoutBuilder: Erwogen - komplexer, gleiche Probleme
- Timer-based checking: Abgelehnt - ineffizient

---

## ADR-009: UTF-16 Safe String-Handling mit Runes

**Status:** ✅ Accepted (v3.0)

**Kontext:**
- User nutzen Emojis (oft bei DIS: Emotionen ausdrücken)
- Dart Strings sind UTF-16
- `string[0]` kann bei Emojis crashen (Surrogat-Paare)

**Entscheidung:**
**Immer Runes verwenden** für String-Operationen:
```dart
// ❌ Falsch (crasht bei Emoji)
final initial = name[0];

// ✅ Richtig (UTF-16 safe)
final runes = name.runes.toList();
final initial = String.fromCharCode(runes.first);
```

**Konsequenzen:**
✅ **Positiv:**
- Keine Crashes bei Emojis
- Funktioniert mit allen Unicode-Zeichen

❌ **Negativ:**
- Mehr Code (runes.toList())
- Performance-Overhead (minimal)

**Wo angewendet:**
- ProfileCard (Initials)
- ChatMessageBubble (Sender-Initial)
- Alle Text-Truncations

---

## ADR-010: Passwort-Reset mit Security Questions

**Status:** ✅ Accepted (v3.0)

**Kontext:**
- User können Passwort vergessen
- Keine Email/Cloud-Account (Privacy!)
- Sicherheit: Kein einfacher "Passwort vergessen?"-Button

**Entscheidung:**
**Security Questions** + Time-Based Reset:
- User beantwortet 3 Security Questions bei Setup
- Bei Reset: Fragen beantworten → Pending Password gesetzt
- Pending Password wird nach 24h (oder Debug: 10min) aktiv
- Alter Passwort bleibt gültig bis Timeout

**Konsequenzen:**
✅ **Positiv:**
- Kein Cloud-Service nötig
- Sicher: 24h Wartezeit verhindert Missbrauch
- User behält Zugriff auch bei vergessener Security-Antwort (24h warten)

❌ **Negativ:**
- Komplexer als einfacher Reset
- User muss 24h warten (akzeptabel für Security)

**Alternativen:**
- Email-Reset: Abgelehnt - braucht Cloud, Privacy-Problem
- SMS-Reset: Abgelehnt - braucht Telefonnummer
- Biometric Reset: Erwogen - nicht auf allen Geräten verfügbar
- Kein Reset: Abgelehnt - User verliert Daten bei vergessenem Passwort

---

## ADR-011: Medikamente mit zwei Tabs (Regulär + Bedarf)

**Status:** ✅ Accepted (v3.0.1)

**Kontext:**
- Medikamente-Typen: Regelmäßig vs. Bei Bedarf
- Unterschiedliche UI-Needs (Schedule vs. Quick-Take)
- Clutter vermeiden

**Entscheidung:**
**Zwei Tabs** im MedicationScreen:
- Tab 1: Reguläre Medikamente (mit Schedule)
- Tab 2: Bedarfsmedikation (Quick-Take-Button)

**Konsequenzen:**
✅ **Positiv:**
- Klare Trennung
- Bessere UX (Bedarf = schnell zugreifbar)
- Skalierbar (weitere Tabs möglich)

❌ **Negativ:**
- Mehr Code (zwei Card-Widgets)
- User muss zwischen Tabs switchen

**Pattern:**
- Gleiche Pattern auch für Finder (Orte vs. Dinge)
- Wiederverwendbar für andere Features

---

## Zukünftige Entscheidungen (TBD)

### ADR-012: Timeline Hintergrund-Tracking (v3.3)
**Status:** 📋 Proposed
**Fragen:**
- Android: WorkManager oder AlarmManager?
- iOS: Background Location Permissions (Dauerhaft vs. Bei Nutzung)?
- Battery Impact: Wie oft tracken? (1min, 5min, 15min?)
- Encryption: LocationHistory-Box verschlüsseln?

### ADR-013: Offline-Tiles Storage Strategy (v3.1)
**Status:** 📋 Proposed
**Fragen:**
- Wo speichern? (App Documents, Cache, External Storage?)
- Cache-Eviction-Strategy? (LRU, Time-based?)
- Size-Limit? (500MB, 1GB, unlimited?)

### ADR-014: Notfall-Nachricht Transport (v3.2)
**Status:** 📋 Proposed
**Fragen:**
- SMS direkt oder Share-Intent?
- WhatsApp-Integration? (url_launcher)
- Email als Fallback?

---

*Letzte Aktualisierung: 2025-10-20*
*Dokument-Version: 1.0*
