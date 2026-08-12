# Feature-Spezifikationen

## 1. Chat-System

### Beschreibung
Internes Chat-System für Kommunikation zwischen verschiedenen Persönlichkeiten.

### Funktionen
- Erstellen von Chat-Nachrichten mit Absender-Profil
- Anzeige aller Nachrichten in chronologischer Reihenfolge
- Profil-Kennzeichnung (Name, Farbe, Avatar)
- Zeitstempel für jede Nachricht
- Optional: Nachricht als "gelesen" markieren
- Optional: Anhänge (Bilder, Notizen)

### Datenmodell
```dart
class ChatMessage {
  String id;
  String profileId;
  String content;
  DateTime timestamp;
  bool isRead;
}
```

---

## 2. Profilverwaltung

### Beschreibung
Verwaltung verschiedener Persönlichkeiten mit individuellen Eigenschaften.

### Funktionen
- Profil erstellen/bearbeiten/löschen
- Name festlegen
- Avatar-Bild auswählen (Foto oder Icon)
- Wunschfarbe wählen (für UI-Kennzeichnung)
- Optional: Alter, Beschreibung, Vorlieben
- Profilwechsel für App-Nutzung

### Datenmodell
```dart
class Profile {
  String id;
  String name;
  String? avatarPath;
  Color preferredColor;
  int? age;
  String? description;
  DateTime createdAt;
}
```

---

## 3. Kalender

### Beschreibung
Gemeinsamer Kalender für Termine und Aufgaben aller Persönlichkeiten.

### Funktionen
- Termine erstellen/bearbeiten/löschen
- Titel, Datum, Uhrzeit, Dauer
- Zuordnung zu einem oder mehreren Profilen
- Erinnerungen/Benachrichtigungen
- Monats-/Wochen-/Tagesansicht
- Optional: Kategorien (Arzttermin, privat, etc.)

### Datenmodell
```dart
class CalendarEvent {
  String id;
  String title;
  DateTime startTime;
  DateTime endTime;
  List<String> profileIds;
  String? description;
  List<DateTime> reminders;
}
```

---

## 4. Tagebuch

### Beschreibung
Persönliche Tagebucheinträge für jede Persönlichkeit.

### Funktionen
- Einträge erstellen/bearbeiten/löschen
- Text-Editor mit Formatierung
- Zuordnung zu Profil
- Datum/Zeitstempel
- Optional: Stimmungs-Tracking
- Optional: Bilder anhängen
- Suchfunktion

### Datenmodell
```dart
class DiaryEntry {
  String id;
  String profileId;
  String title;
  String content;
  DateTime createdAt;
  DateTime? modifiedAt;
  String? mood;
}
```

---

## 5. Notfallkontakte

### Beschreibung
Schnellzugriff auf wichtige Telefonnummern in Krisensituationen.

### Funktionen
- Liste von Notfallkontakten
- Name, Telefonnummer, Beschreibung
- Sortierung nach Priorität
- Direktwahl-Button
- Vordefinierte Kontakte (Telefonseelsorge, etc.)
- Eigene Kontakte hinzufügen

### Datenmodell
```dart
class EmergencyContact {
  String id;
  String name;
  String phoneNumber;
  String? description;
  int priority;
  bool isPredefined;
}
```

---

## 6. Hilfsangebote

### Beschreibung
Informationen und Links zu professioneller Unterstützung.

### Funktionen
- Liste von Hilfsorganisationen
- Therapie-Ressourcen
- Informationsmaterial über DIS
- Selbsthilfegruppen
- Optional: Weblinks zu externen Ressourcen

### Datenmodell
```dart
class HelpResource {
  String id;
  String title;
  String description;
  String? phoneNumber;
  String? website;
  String? email;
  ResourceType type; // Enum: therapy, info, support_group, etc.
}
```

---

## 7. Mantras

### Beschreibung
Beruhigende Affirmationen und positive Mantras für schwierige Momente.

### Funktionen
- Liste vordefinierter Mantras
- Eigene Mantras erstellen
- Kategorien (Beruhigung, Selbstwert, Sicherheit)
- Zufalls-Mantra anzeigen
- Favoriten markieren

### Datenmodell
```dart
class Mantra {
  String id;
  String text;
  String category;
  bool isFavorite;
  bool isPredefined;
}
```

---

## 8. Spiele

### Beschreibung
Einfache Spiele zur Ablenkung und Entspannung.

### Funktionen
- Atemübungen (geführt)
- Memory-Spiel
- Puzzle
- Zeichnen/Malen
- Musik/Sounds (beruhigend)

### Implementierung
- Separate Komponenten pro Spiel
- Einfache, intuitive UI
- Keine Punktesysteme oder Wettkampf
- Fokus auf Entspannung