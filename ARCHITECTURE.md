# Architektur-Dokumentation

> **⚠️ Veraltet — nicht als Quelle verwenden.**
>
> Dieses Dokument beschreibt einen Stand mit In-Memory-State,
> SharedPreferences und sqflite. Nichts davon ist heute noch wahr: Aurora
> persistiert ausschließlich über Hive, und jeder Zugriff aus der Oberfläche
> läuft über `DataEntry`.
>
> Die verbindliche Beschreibung steht in `CLAUDE.md` und
> `ARCHITECTURE_DECISIONS.md`. Widersprechen sich zwei Dokumente, gilt immer
> das ADR. Diese Datei bleibt als Zeitdokument stehen, weil sie erklärt,
> woher einzelne Altlasten kommen.

## Überblick

Die DIS-Hilfe-App nutzt eine **Event-Driven Architecture** mit einem zentralen Stream-basierten Event-Bus. Dies ermöglicht lose Kopplung zwischen Modulen und reaktive Datenflüsse.

## Architektur-Diagramm

```
┌─────────────────────────────────────────────────────────┐
│                     UI Layer (Flutter)                   │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐          │
│  │ Chat │ │Profile│ │Calendar│ │Diary│ │ ...  │          │
│  └──┬───┘ └───┬──┘ └───┬──┘ └───┬──┘ └───┬──┘          │
└─────┼─────────┼────────┼────────┼────────┼─────────────┘
      │         │        │        │        │
      ▼         ▼        ▼        ▼        ▼
┌─────────────────────────────────────────────────────────┐
│                      API Layer                           │
│  ┌────────────────────────────────────────────────┐     │
│  │         Central API Interface                   │     │
│  │  - Validierung                                  │     │
│  │  - Transformation                               │     │
│  │  - Event-Erstellung                             │     │
│  └────────────────┬───────────────────────────────┘     │
└───────────────────┼─────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────────────────────┐
│              Core - Event Bus / Collector                │
│  ┌────────────────────────────────────────────────┐     │
│  │    StreamController / RxDart Subjects          │     │
│  │                                                 │     │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐    │     │
│  │  │  Events  │  │ Commands │  │  Queries │    │     │
│  │  │  Stream  │  │  Stream  │  │  Stream  │    │     │
│  │  └────┬─────┘  └────┬─────┘  └────┬─────┘    │     │
│  └───────┼─────────────┼─────────────┼───────────┘     │
└──────────┼─────────────┼─────────────┼─────────────────┘
           │             │             │
           ▼             ▼             ▼
┌─────────────────────────────────────────────────────────┐
│            Services Layer (In-Memory State)              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐              │
│  │  Chat    │  │ Profile  │  │ Calendar │  ...         │
│  │ Service  │  │ Service  │  │ Service  │              │
│  │          │  │          │  │          │              │
│  │ List<>   │  │ List<>   │  │ List<>   │  (Memory)    │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘              │
└───────┼─────────────┼─────────────┼─────────────────────┘
        │             │             │
        ▼             ▼             ▼
┌─────────────────────────────────────────────────────────┐
│       Optional: SharedPreferences (Persistierung)        │
│         Profile, Tagebuch als JSON speichern             │
└─────────────────────────────────────────────────────────┘
```

## Komponenten

### 1. API Layer

**Zweck**: Zentrale Schnittstelle für alle Modul-Interaktionen

**Verantwortlichkeiten**:
- Empfang von Anfragen aus UI-Modulen
- Validierung eingehender Daten
- Transformation in Events
- Weiterleitung an Event-Bus

**Beispiel**:
```dart
class ApiLayer {
  final EventBus _eventBus;

  Future<void> createChatMessage(ChatMessage message) async {
    // Validierung
    if (message.content.isEmpty) throw ValidationException();

    // Event erstellen und publishen
    _eventBus.publish(ChatMessageCreatedEvent(message));
  }
}
```

### 2. Core - Event Bus / Stream Collector

**Zweck**: Zentrale Event-Verteilung via Streams

**Technologie**: RxDart `BehaviorSubject` / `PublishSubject`

**Verantwortlichkeiten**:
- Event-Streaming
- Subscription-Management
- Event-History (optional)
- Fehlerbehandlung

**Event-Typen**:
- **Events**: Etwas ist passiert (z.B. `ChatMessageCreated`)
- **Commands**: Aktion ausführen (z.B. `CreateChatMessage`)
- **Queries**: Daten abfragen (z.B. `GetChatHistory`)

**Implementierung**:
```dart
class EventBus {
  final _eventController = StreamController<AppEvent>.broadcast();

  Stream<T> on<T extends AppEvent>() {
    return _eventController.stream.where((event) => event is T).cast<T>();
  }

  void publish(AppEvent event) {
    _eventController.add(event);
  }
}
```

### 3. Services Layer (In-Memory State)

**Zweck**: Business-Logik und In-Memory Daten-Management

**Verantwortlichkeiten**:
- Event-Subscription
- Datenverarbeitung
- **In-Memory State** (Listen/Maps im Speicher)
- Neue Events publishen
- Optional: Persistierung via SharedPreferences

**Beispiel**:
```dart
class ChatService {
  final EventBus _eventBus;
  final List<ChatMessage> _messages = [];

  ChatService(this._eventBus) {
    // Subscribe to events
    _eventBus.on<ChatMessageCreatedEvent>().listen(_handleMessageCreated);
  }

  void _handleMessageCreated(ChatMessageCreatedEvent event) {
    _messages.add(event.message);
    _eventBus.publish(ChatMessageSavedEvent(event.message));
  }

  List<ChatMessage> get messages => List.unmodifiable(_messages);
}
```

### 4. UI Layer (Flutter Widgets)

**Zweck**: Benutzer-Interface und Interaktion

**Verantwortlichkeiten**:
- Event-Subscription für UI-Updates
- User-Input über API senden
- State-Management (BLoC/Provider)

**Beispiel**:
```dart
class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = eventBus.on<ChatMessageSavedEvent>().listen((event) {
      setState(() {
        // Update UI
      });
    });
  }

  void _sendMessage(String text) {
    apiLayer.createChatMessage(ChatMessage(text: text));
  }
}
```

## Datenfluss

### Beispiel: Chat-Nachricht senden

1. **User** tippt Nachricht in UI
2. **UI** ruft `apiLayer.createChatMessage()` auf
3. **API Layer** validiert und publisht `ChatMessageCreatedEvent`
4. **Event Bus** verteilt Event an alle Subscriber
5. **ChatService** empfängt Event und speichert in DB
6. **ChatService** publisht `ChatMessageSavedEvent`
7. **UI** empfängt Event und aktualisiert Anzeige

```
User Input → API → Event Bus → Service → Database
                        ↓
                   UI (Stream)
```

## Vorteile dieser Architektur

✅ **Lose Kopplung**: Module kennen sich nicht direkt
✅ **Testbarkeit**: Einfaches Mocking von Events
✅ **Skalierbarkeit**: Neue Module einfach hinzufügen
✅ **Reaktivität**: UI reagiert automatisch auf Daten-Änderungen
✅ **Debugging**: Event-Log für Nachvollziehbarkeit

## Technologie-Stack

- **Flutter/Dart**: UI Framework
- **RxDart**: Reactive Extensions für Streams
- **sqflite**: Lokale SQLite-Datenbank
- **get_it**: Dependency Injection
- **Optional**: flutter_bloc für UI-State-Management

## Ordnerstruktur

```
lib/
├── api/
│   ├── api_layer.dart
│   └── validators/
├── core/
│   ├── event_bus.dart
│   ├── events/
│   │   ├── app_event.dart
│   │   ├── chat_events.dart
│   │   ├── profile_events.dart
│   │   └── ...
│   └── di/
│       └── injection.dart
├── models/
│   ├── chat_message.dart
│   ├── profile.dart
│   └── ...
├── services/
│   ├── chat_service.dart
│   ├── profile_service.dart
│   ├── calendar_service.dart
│   └── storage_service.dart  # Optional: SharedPreferences wrapper
├── modules/
│   ├── chat/
│   │   ├── chat_screen.dart
│   │   └── widgets/
│   ├── profile/
│   ├── calendar/
│   └── ...
└── main.dart
```

## Datenpersistierung (Optional)

Da der Chat intern zwischen Persönlichkeiten stattfindet, werden **alle Daten im Speicher gehalten**. Optional können wichtige Daten persistiert werden:

**Was persistiert werden kann**:
- **Profile** - Via SharedPreferences als JSON
- **Tagebuch-Einträge** - Falls längerfristige Aufzeichnungen gewünscht
- **Kalender-Events** - Für längerfristige Termine

**Was NICHT persistiert wird**:
- **Chat-Nachrichten** - Bleiben nur im aktuellen Session-Speicher
- **Temporäre UI-States**

## Vorteile des In-Memory-Ansatzes

✅ **Einfachheit** - Keine komplexe Datenbank-Migration
✅ **Geschwindigkeit** - Direkter Speicherzugriff ohne I/O
✅ **Privatsphäre** - Sensitive Chat-Daten bleiben nicht auf Gerät
✅ **Leichtgewichtig** - Weniger Dependencies

## Nächste Schritte

1. ✅ Event-Bus-Implementierung
2. ✅ Basis-Events definieren
3. In-Memory Services implementieren
4. UI-Module mit Stream-Subscriptions
5. Optional: Storage-Service für Profile-Persistierung