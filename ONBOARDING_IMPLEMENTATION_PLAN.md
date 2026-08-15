# Aurora - 3-Stufen Onboarding System

## Implementierungs-Plan & Dokumentation

**Erstellt:** 2025-01-02
**Status:** Geplant, noch nicht implementiert
**Priorität:** HOCH (Kritisch für Full Release)
**Geschätzter Aufwand:** 8-12 Stunden (~1,5-2 Tage)

---

## 📋 INHALTSVERZEICHNIS

1. [Übersicht](#übersicht)
2. [System-Architektur](#system-architektur)
3. [Stufe 1: Pre-Onboarding](#stufe-1-pre-onboarding)
4. [Stufe 2: Profile Creation Walkthrough](#stufe-2-profile-creation-walkthrough)
5. [Stufe 3: Post-Login Welcome](#stufe-3-post-login-welcome)
6. [Technische Implementierung](#technische-implementierung)
7. [Navigation Flow](#navigation-flow)
8. [Implementierungs-Checkliste](#implementierungs-checkliste)
9. [Testing-Szenarien](#testing-szenarien)
10. [Design-Spezifikationen](#design-spezifikationen)

---

## ÜBERSICHT

### Konzept

Das 3-Stufen Onboarding System bietet kontextbezogene Hilfe an drei kritischen Punkten:

1. **PRE-ONBOARDING** - Nach App-Installation, vor Profile Selection
2. **PROFILE CREATION WALKTHROUGH** - Während der Profil-Erstellung
3. **POST-LOGIN WELCOME** - Nach erstem Login mit neuem Profil

### Kernprinzipien

- ✅ **User Control:** "Nicht mehr anzeigen" Buttons geben Kontrolle
- ✅ **Kontextbezogen:** Hilfe genau wo sie gebraucht wird
- ✅ **Skalierbar:** Funktioniert für 1 oder 20 Profile
- ✅ **DIS-Sensibel:** Jeder Anteil wird individuell begrüßt
- ✅ **Nicht-invasiv:** Kann übersprungen oder dismissed werden

### Vorteile gegenüber alternativen Ansätzen

| Aspekt | Dieses System | Alternative: Single Onboarding |
|--------|---------------|--------------------------------|
| **Neue Anteile** | Werden beim ersten Login begrüßt | Müssen selbst entdecken |
| **Admin-Flow** | Kann mehrere Profile vorbereiten | Nur für Admin selbst |
| **Kontrolle** | Jeder kann dismissal | Einmalig, dann nie wieder |
| **Timing** | Contextual (wo gebraucht) | Frontloaded (alles am Anfang) |
| **Skalierung** | Unbegrenzt Profile | Nur für erstes Profil |

---

## SYSTEM-ARCHITEKTUR

### Komponenten-Übersicht

```
┌─────────────────────────────────────────────────────────┐
│                   3-STUFEN ONBOARDING                    │
└─────────────────────────────────────────────────────────┘
           │                │                │
    ┌──────▼──────┐  ┌─────▼──────┐  ┌──────▼──────┐
    │   STUFE 1   │  │  STUFE 2   │  │   STUFE 3   │
    │Pre-Onboard. │  │Profile Walk│  │Post-Login   │
    │(App-Level)  │  │(Integrated)│  │Welcome      │
    └─────────────┘  └────────────┘  │(Per-Profile)│
                                      └─────────────┘
```

### Storage-Strategie

```dart
// App-Level Flag (Hive Settings Box)
'pre_onboarding_dismissed': bool

// Profile-Level Flag (Profile Model)
hasSeenPostLoginWelcome: bool = false
```

### Navigation-Trigger

```
SplashScreen
    ↓
[Check: pre_onboarding_dismissed]
    ↓           ↓
   NO          YES
    ↓           ↓
Pre-Onboard  ProfileSelection
              ↓
         [Profile Login]
              ↓
    [Check: hasSeenPostLoginWelcome]
              ↓           ↓
             NO          YES
              ↓           ↓
        Post-Welcome   MainScreen
```

---

## STUFE 1: PRE-ONBOARDING

### Zweck

Einmalige Einführung in Aurora nach App-Installation, bevor Nutzer zur Profile Selection gelangt.

### Trigger

- **Wann:** Nach SplashScreen (3 Sekunden), vor ProfileSelectionScreen
- **Bedingung:** `pre_onboarding_dismissed == false` (oder Flag nicht gesetzt)
- **Einmalig:** Ja (es sei denn, Nutzer deinstalliert/reinstalliert App)

### Screen-Design

#### Screen 1: Welcome to Aurora

```
┌─────────────────────────────────────────┐
│                                         │
│          🌟 Aurora Logo                 │
│         (animated glow)                 │
│                                         │
│       Willkommen bei Aurora             │
│                                         │
│   Deine sichere Begleiterin im          │
│        Alltag mit DIS                   │
│                                         │
│                                         │
│                                         │
│     ┌───────────────────────┐           │
│     │      Weiter →         │           │
│     └───────────────────────┘           │
│                                         │
│                                         │
│      [Nicht mehr anzeigen]              │
│                                         │
│            ● ○ ○ ○                      │
└─────────────────────────────────────────┘
```

**Content:**
- **Headline:** "Willkommen bei Aurora"
- **Subline:** "Deine sichere Begleiterin im Alltag mit DIS"
- **Button:** "Weiter →"
- **Dismiss:** "Nicht mehr anzeigen" (Text-Button, unten)
- **Progress:** ● ○ ○ ○

---

#### Screen 2: Privacy First

```
┌─────────────────────────────────────────┐
│                                         │
│        🔒 Shield Icon                   │
│         (animated)                      │
│                                         │
│      Deine Daten gehören DIR            │
│                                         │
│  ┌───────────────────────────────┐     │
│  │                               │     │
│  │ ✓ Alle Daten nur auf          │     │
│  │   deinem Gerät                │     │
│  │                               │     │
│  │ ✓ Keine Cloud-                │     │
│  │   Synchronisation             │     │
│  │                               │     │
│  │ ✓ Keine Telemetrie            │     │
│  │   oder Tracking               │     │
│  │                               │     │
│  │ ✓ Open Source &               │     │
│  │   transparent                 │     │
│  │                               │     │
│  └───────────────────────────────┘     │
│                                         │
│     ┌───────────────────────┐           │
│     │      Weiter →         │           │
│     └───────────────────────┘           │
│                                         │
│      [Nicht mehr anzeigen]              │
│                                         │
│            ○ ● ○ ○                      │
└─────────────────────────────────────────┘
```

**Content:**
- **Headline:** "Deine Daten gehören DIR"
- **Bullet Points:**
  - ✓ Alle Daten nur auf deinem Gerät
  - ✓ Keine Cloud-Synchronisation
  - ✓ Keine Telemetrie oder Tracking
  - ✓ Open Source & transparent
- **Visual:** Crossed-out cloud icon (subtle)
- **Button:** "Weiter →"
- **Dismiss:** "Nicht mehr anzeigen"
- **Progress:** ○ ● ○ ○

---

#### Screen 3: Multi-Profile System

```
┌─────────────────────────────────────────┐
│                                         │
│     [4 Colored Circles]                 │
│    (animated, rotating)                 │
│                                         │
│     Viele Stimmen, eine App             │
│                                         │
│  ┌───────────────────────────────┐     │
│  │                               │     │
│  │ Aurora unterstützt mehrere    │     │
│  │ Profile – für jeden Anteil    │     │
│  │ im System.                    │     │
│  │                               │     │
│  │ Jedes Profil kann             │     │
│  │ individuell angepasst         │     │
│  │ werden:                       │     │
│  │                               │     │
│  │ • Eigener Name & Avatar       │     │
│  │ • Eigene Farbe                │     │
│  │ • Eigene Berechtigungen       │     │
│  │ • Optional: Passwortschutz    │     │
│  │                               │     │
│  └───────────────────────────────┘     │
│                                         │
│     ┌───────────────────────┐           │
│     │      Weiter →         │           │
│     └───────────────────────┘           │
│                                         │
│      [Nicht mehr anzeigen]              │
│                                         │
│            ○ ○ ● ○                      │
└─────────────────────────────────────────┘
```

**Content:**
- **Headline:** "Viele Stimmen, eine App"
- **Body:**
  - "Aurora unterstützt mehrere Profile – für jeden Anteil im System."
  - Bullet points: Name, Farbe, Berechtigungen, Passwort
- **Visual:** 4 colorful circles representing profiles (animated rotation)
- **Button:** "Weiter →"
- **Dismiss:** "Nicht mehr anzeigen"
- **Progress:** ○ ○ ● ○

---

#### Screen 4: Let's Go

```
┌─────────────────────────────────────────┐
│                                         │
│        ✨ Sparkles Icon                 │
│                                         │
│         Bereit anzufangen?              │
│                                         │
│  ┌───────────────────────────────┐     │
│  │                               │     │
│  │ Als nächstes erstellst du     │     │
│  │ dein erstes Profil.           │     │
│  │                               │     │
│  │ Als erstes Profil wirst du    │     │
│  │ automatisch Administrator     │     │
│  │ mit allen Rechten.            │     │
│  │                               │     │
│  │ Du kannst später weitere      │     │
│  │ Profile erstellen und         │     │
│  │ Berechtigungen anpassen.      │     │
│  │                               │     │
│  └───────────────────────────────┘     │
│                                         │
│     ┌───────────────────────┐           │
│     │  Profil erstellen →   │           │
│     └───────────────────────┘           │
│                                         │
│      [Nicht mehr anzeigen]              │
│                                         │
│            ○ ○ ○ ●                      │
└─────────────────────────────────────────┘
```

**Content:**
- **Headline:** "Bereit anzufangen?"
- **Body:**
  - "Als nächstes erstellst du dein erstes Profil."
  - "Als erstes Profil wirst du automatisch Administrator mit allen Rechten."
  - "Du kannst später weitere Profile erstellen und Berechtigungen anpassen."
- **Button:** "Profil erstellen →"
- **Dismiss:** "Nicht mehr anzeigen"
- **Progress:** ○ ○ ○ ●
- **Next:** → ProfileCreationScreen

---

### Technische Details

#### Datei-Struktur

```
lib/modules/onboarding/
  ├── pre_onboarding_screen.dart
  └── widgets/
      ├── dismissable_onboarding_wrapper.dart
      └── pre_onboarding_page.dart
```

#### Code-Snippet: PreOnboardingScreen

```dart
class PreOnboardingScreen extends StatefulWidget {
  const PreOnboardingScreen({super.key});

  @override
  State<PreOnboardingScreen> createState() => _PreOnboardingScreenState();
}

class _PreOnboardingScreenState extends State<PreOnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final List<Widget> _pages = const [
    PreOnboardingWelcomePage(),
    PreOnboardingPrivacyPage(),
    PreOnboardingMultiProfilePage(),
    PreOnboardingLetsGoPage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishOnboarding() {
    // Navigate to ProfileCreationScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ProfileSelectionScreen()),
    );
  }

  Future<void> _dismissOnboarding() async {
    final profileService = getIt<ProfileService>();
    await profileService.settingsBox.put('pre_onboarding_dismissed', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileSelectionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A1A2E),
                  const Color(0xFF16213E),
                ],
              ),
            ),
          ),

          // Content
          Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  children: _pages,
                ),
              ),

              // Dismiss button
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: TextButton(
                  onPressed: _dismissOnboarding,
                  child: Text(
                    'Nicht mehr anzeigen',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

#### Storage Flag

```dart
// In ProfileService or new OnboardingService
Future<bool> hasPreOnboardingBeenDismissed() async {
  return settingsBox.get('pre_onboarding_dismissed', defaultValue: false);
}

Future<void> dismissPreOnboarding() async {
  await settingsBox.put('pre_onboarding_dismissed', true);
}
```

---

## STUFE 2: PROFILE CREATION WALKTHROUGH

### Zweck

Schritt-für-Schritt Erklärungen WÄHREND der Profil-Erstellung, um Verwirrung zu vermeiden.

### Ansatz

**Nicht** eine separate Onboarding-Flow, sondern **Integration** von Erklärungen direkt in den bestehenden `ProfileCreationScreen`.

### Änderungen an ProfileCreationScreen

#### Card 1: Identity (Name, Avatar, Password)

**Aktuell:**
```dart
Card(
  child: Column(
    children: [
      TextField(/* Name */),
      // Avatar picker
      TextField(/* Password */),
    ],
  ),
)
```

**NEU - Mit Erklärungen:**
```dart
Card(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // NEW: Section Header
      Text(
        'Wer bist du?',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 8),

      // NEW: Explanation
      Text(
        'Dein Name hilft anderen im System, dich zu erkennen.',
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
      SizedBox(height: 16),

      TextField(
        decoration: InputDecoration(
          labelText: 'Name',
          hintText: 'z.B. Anna, Ben, Alex...',
        ),
      ),
      SizedBox(height: 16),

      // Avatar picker (unchanged)
      ProfileAvatarPickerBottomSheet(...),

      SizedBox(height: 16),

      // NEW: Password explanation with info icon
      Row(
        children: [
          Text('Passwort (optional)'),
          SizedBox(width: 8),
          Tooltip(
            message: 'Ein Passwort schützt dein Profil vor versehentlichem '
                     'Zugriff durch andere Anteile.',
            child: Icon(Icons.info_outline, size: 16),
          ),
        ],
      ),
      SizedBox(height: 8),
      TextField(
        decoration: InputDecoration(
          labelText: 'Passwort',
          hintText: 'Nur wenn du zusätzlichen Schutz möchtest',
        ),
        obscureText: true,
      ),
    ],
  ),
)
```

---

#### Card 2: Age

**Aktuell:**
```dart
Card(
  child: Column(
    children: [
      TextField(/* Age input */),
    ],
  ),
)
```

**NEU - Mit Erklärungen:**
```dart
Card(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // NEW: Section Header
      Text(
        'Wie alt bist du?',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 8),

      // NEW: Explanation
      Text(
        'Basierend auf deinem Alter werden sichere Standardberechtigungen gesetzt.',
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
      SizedBox(height: 16),

      // NEW: Info Box
      Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.child_care, size: 16, color: Colors.blue[700]),
                SizedBox(width: 8),
                Text(
                  'Kinder (<8 Jahre):',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              'Chat, Tagebuch, Spiele',
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.blue[700]),
                SizedBox(width: 8),
                Text(
                  'Erwachsene (≥8 Jahre):',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              'Alle Funktionen (Chat, Kalender, Medikamente, etc.)',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      SizedBox(height: 16),

      TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Alter in Jahren',
          hintText: 'z.B. 7, 18, 25...',
        ),
      ),
      SizedBox(height: 8),

      // NEW: Reassurance
      Text(
        'Ein Admin kann Berechtigungen später anpassen.',
        style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
      ),
    ],
  ),
)
```

---

#### Card 3: Color

**Aktuell:**
```dart
Card(
  child: Column(
    children: [
      ColorPicker(...),
    ],
  ),
)
```

**NEU - Mit Erklärungen:**
```dart
Card(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // NEW: Section Header
      Text(
        'Deine Lieblingsfarbe?',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 8),

      // NEW: Explanation
      Text(
        'Diese Farbe erscheint bei all deinen Aktionen im System – '
        'in Nachrichten, Kalendereinträgen und mehr.',
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
      SizedBox(height: 16),

      // Color Picker (unchanged)
      ColorPicker(...),

      SizedBox(height: 16),

      // NEW: Preview
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selectedColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selectedColor),
        ),
        child: Row(
          children: [
            Icon(Icons.palette, color: selectedColor),
            SizedBox(width: 12),
            Text(
              'So sieht deine Farbe aus',
              style: TextStyle(color: selectedColor),
            ),
          ],
        ),
      ),
    ],
  ),
)
```

---

#### Progress Indicator

**Add to bottom of ProfileCreationScreen:**

```dart
// NEW: Step Progress Indicator
Padding(
  padding: EdgeInsets.symmetric(vertical: 16),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _buildProgressDot(isActive: currentCard == 0),
      SizedBox(width: 8),
      _buildProgressDot(isActive: currentCard == 1),
      SizedBox(width: 8),
      _buildProgressDot(isActive: currentCard == 2),
    ],
  ),
)

Widget _buildProgressDot({required bool isActive}) {
  return Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: isActive ? Theme.of(context).primaryColor : Colors.grey,
    ),
  );
}
```

---

### Technische Details

#### Dateien zu ändern

```
lib/modules/profile/profile_creation_screen.dart
  - Add section headers to each card
  - Add explanatory text
  - Add info tooltips
  - Add step progress indicator
  - Add age-based permission info box
  - Add color preview
```

#### Kein zusätzlicher Storage

**Keine Flags nötig** - Die Erklärungen sind permanent Teil des Profile Creation Screens.

---

## STUFE 3: POST-LOGIN WELCOME

### Zweck

Personalisierte Begrüßung für jedes neue Profil beim ersten Login, um zu zeigen:
- "Du bist nicht allein" (wenn andere Profile existieren)
- "Was du tun kannst" (basierend auf Berechtigungen)
- "Alles ist sicher"

### Trigger

- **Wann:** Nach erfolgreichem Profil-Login (Passwort-Check bestanden)
- **Bedingung:** `currentProfile.hasSeenPostLoginWelcome == false`
- **Individuell:** Ja - jedes Profil bekommt eigenes Welcome (unabhängig)

### Screen-Design

#### Screen 1: Personal Welcome

```
┌─────────────────────────────────────────┐
│                                         │
│                                         │
│          👋 Emoji                       │
│                                         │
│         Hallo [Name]!                   │
│                                         │
│      Schön, dass du da bist.            │
│                                         │
│                                         │
│   [Profile color accent bar/glow]       │
│                                         │
│                                         │
│     ┌───────────────────────┐           │
│     │      Weiter →         │           │
│     └───────────────────────┘           │
│                                         │
│                                         │
│      [Nicht mehr anzeigen]              │
│                                         │
│            ● ○ ○ ○                      │
└─────────────────────────────────────────┘
```

**Content:**
- **Headline:** "Hallo [Name]!" (dynamisch aus Profil)
- **Subline:** "Schön, dass du da bist."
- **Visual:** Profile color as accent (gradient or glow effect)
- **Button:** "Weiter →"
- **Dismiss:** "Nicht mehr anzeigen"
- **Progress:** ● ○ ○ ○

---

#### Screen 2: You're Not Alone (Conditional)

**Zeige NUR wenn andere Profile existieren:**

```
┌─────────────────────────────────────────┐
│                                         │
│        👥 Icon                          │
│                                         │
│      Du bist nicht allein.              │
│                                         │
│  ┌───────────────────────────────┐     │
│  │                               │     │
│  │  Andere sind auch hier:       │     │
│  │                               │     │
│  │  ┌─────┐  ┌─────┐  ┌─────┐   │     │
│  │  │ 😊  │  │ 🌸  │  │ 🐱  │   │     │
│  │  │Anna │  │ Ben │  │Clara│   │     │
│  │  └─────┘  └─────┘  └─────┘   │     │
│  │                               │     │
│  │  Ihr könnt miteinander        │     │
│  │  chatten und gemeinsam        │     │
│  │  organisieren.                │     │
│  │                               │     │
│  └───────────────────────────────┘     │
│                                         │
│     ┌───────────────────────┐           │
│     │      Weiter →         │           │
│     └───────────────────────┘           │
│                                         │
│      [Nicht mehr anzeigen]              │
│                                         │
│            ○ ● ○ ○                      │
└─────────────────────────────────────────┘
```

**Content:**
- **Headline:** "Du bist nicht allein."
- **Body:** "Andere sind auch hier:"
- **Visual:** Show 3-4 existing profile avatars + names (excluding current profile)
- **Subtext:** "Ihr könnt miteinander chatten und gemeinsam organisieren."
- **Button:** "Weiter →"
- **Dismiss:** "Nicht mehr anzeigen"
- **Progress:** ○ ● ○ ○

**Conditional Logic:**
```dart
if (profileService.activeProfiles.length > 1) {
  // Show this screen
} else {
  // Skip to next screen
}
```

---

#### Screen 3: What You Can Do

```
┌─────────────────────────────────────────┐
│                                         │
│        ✨ Sparkles Icon                 │
│                                         │
│        Was du tun kannst:               │
│                                         │
│  ┌───────────────────────────────┐     │
│  │                               │     │
│  │  ✓ Chat                       │     │
│  │    Mit anderen sprechen       │     │
│  │                               │     │
│  │  ✓ Kalender                   │     │
│  │    Termine sehen & erstellen  │     │
│  │                               │     │
│  │  ✓ Tagebuch                   │     │
│  │    Gedanken festhalten        │     │
│  │                               │     │
│  │  ✓ Spiele                     │     │
│  │    Entspannung & Ablenkung    │     │
│  │                               │     │
│  │  [... more based on perms]    │     │
│  │                               │     │
│  └───────────────────────────────┘     │
│                                         │
│     ┌───────────────────────┐           │
│     │      Weiter →         │           │
│     └───────────────────────┘           │
│                                         │
│      [Nicht mehr anzeigen]              │
│                                         │
│            ○ ○ ● ○                      │
└─────────────────────────────────────────┘
```

**Content:**
- **Headline:** "Was du tun kannst:"
- **Permissions-Based List:**
  - If `viewChatTab`: ✓ Chat - Mit anderen sprechen
  - If `viewCalendarTab`: ✓ Kalender - Termine sehen & erstellen
  - If `createCalendarEvents`: (add "erstellen" to Kalender line)
  - If `viewDiaryTab`: ✓ Tagebuch - Gedanken festhalten
  - If `viewGamesTab`: ✓ Spiele - Entspannung & Ablenkung
  - etc.
- **Dynamic:** Generate list based on `currentProfile.permissions`
- **Button:** "Weiter →"
- **Dismiss:** "Nicht mehr anzeigen"
- **Progress:** ○ ○ ● ○

---

#### Screen 4: Your Safe Space

```
┌─────────────────────────────────────────┐
│                                         │
│        🛡️ Shield Icon                   │
│                                         │
│     Dein persönlicher Bereich           │
│                                         │
│  ┌───────────────────────────────┐     │
│  │                               │     │
│  │  Dein Profil ist              │     │
│  │  passwortgeschützt.           │     │
│  │                               │     │
│  │  Niemand sonst kann es        │     │
│  │  nutzen – nur du.             │     │
│  │                               │     │
│  │  Alles bleibt privat und      │     │
│  │  sicher auf diesem Gerät.     │     │
│  │                               │     │
│  └───────────────────────────────┘     │
│                                         │
│     ┌───────────────────────┐           │
│     │   Los geht's! →       │           │
│     └───────────────────────┘           │
│                                         │
│                                         │
│      [Nicht mehr anzeigen]              │
│                                         │
│            ○ ○ ○ ●                      │
└─────────────────────────────────────────┘
```

**Content:**
- **Headline:** "Dein persönlicher Bereich"
- **Body:**
  - "Dein Profil ist passwortgeschützt."
  - "Niemand sonst kann es nutzen – nur du."
  - "Alles bleibt privat und sicher auf diesem Gerät."
- **Button:** "Los geht's! →" (final CTA)
- **Dismiss:** "Nicht mehr anzeigen"
- **Progress:** ○ ○ ○ ●
- **Next:** → MainScreen (app ready)

---

### Technische Details

#### Datei-Struktur

```
lib/modules/onboarding/
  ├── post_login_welcome_screen.dart
  └── widgets/
      ├── post_login_welcome_page.dart
      └── profile_permissions_list.dart
```

#### Code-Snippet: PostLoginWelcomeScreen

```dart
class PostLoginWelcomeScreen extends StatefulWidget {
  final Profile currentProfile;

  const PostLoginWelcomeScreen({
    super.key,
    required this.currentProfile,
  });

  @override
  State<PostLoginWelcomeScreen> createState() => _PostLoginWelcomeScreenState();
}

class _PostLoginWelcomeScreenState extends State<PostLoginWelcomeScreen> {
  late PageController _pageController;
  late List<Widget> _pages;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _buildPages();
  }

  void _buildPages() {
    _pages = [
      // Screen 1: Personal Welcome
      PostLoginWelcomePage(
        profileName: widget.currentProfile.name,
        profileColor: widget.currentProfile.color,
      ),

      // Screen 2: You're Not Alone (conditional)
      if (_otherProfilesExist())
        PostLoginOtherProfilesPage(
          otherProfiles: _getOtherProfiles(),
        ),

      // Screen 3: What You Can Do
      PostLoginPermissionsPage(
        permissions: widget.currentProfile.permissions,
      ),

      // Screen 4: Your Safe Space
      PostLoginSafeSpacePage(),
    ];
  }

  bool _otherProfilesExist() {
    final profileService = getIt<ProfileService>();
    return profileService.activeProfiles.length > 1;
  }

  List<Profile> _getOtherProfiles() {
    final profileService = getIt<ProfileService>();
    return profileService.activeProfiles
        .where((p) => p.id != widget.currentProfile.id)
        .take(4) // Max 4 profiles shown
        .toList();
  }

  Future<void> _finishWelcome() async {
    // Mark as seen
    await _markWelcomeAsSeen();

    // Navigate to MainScreen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  Future<void> _dismissWelcome() async {
    await _markWelcomeAsSeen();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  Future<void> _markWelcomeAsSeen() async {
    // Update profile model
    final updatedProfile = widget.currentProfile.copyWith(
      hasSeenPostLoginWelcome: true,
    );

    final profileService = getIt<ProfileService>();
    await profileService.updateProfile(updatedProfile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background (using profile color)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.currentProfile.color.withOpacity(0.3),
                  const Color(0xFF1A1A2E),
                ],
              ),
            ),
          ),

          // Content
          Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  children: _pages,
                ),
              ),

              // Dismiss button
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: TextButton(
                  onPressed: _dismissWelcome,
                  child: Text(
                    'Nicht mehr anzeigen',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

#### Profile Model Update

**Add field to `lib/models/profile.dart`:**

```dart
@HiveType(typeId: 0)
class Profile extends HiveObject {
  // ... existing fields

  @HiveField(15) // Adjust index as needed
  bool hasSeenPostLoginWelcome;

  Profile({
    // ... existing parameters
    this.hasSeenPostLoginWelcome = false,
  });

  Profile copyWith({
    // ... existing parameters
    bool? hasSeenPostLoginWelcome,
  }) {
    return Profile(
      // ... existing fields
      hasSeenPostLoginWelcome: hasSeenPostLoginWelcome ?? this.hasSeenPostLoginWelcome,
    );
  }
}
```

**IMPORTANT:** After modifying Profile model, run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

#### Navigation Integration

**In `lib/modules/profile/profile_selection_screen.dart`:**

```dart
Future<void> _handleProfileLogin(Profile profile) async {
  // Existing password check logic...

  if (passwordCorrect) {
    // Check if welcome has been seen
    if (!profile.hasSeenPostLoginWelcome) {
      // Navigate to Post-Login Welcome
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PostLoginWelcomeScreen(currentProfile: profile),
        ),
      );
    } else {
      // Direct to MainScreen (existing behavior)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }
}
```

---

## TECHNISCHE IMPLEMENTIERUNG

### Gesamt-Dateistruktur

```
lib/
├── models/
│   └── profile.dart                           # MODIFY: Add hasSeenPostLoginWelcome
│
├── modules/
│   ├── onboarding/
│   │   ├── pre_onboarding_screen.dart         # NEW
│   │   ├── post_login_welcome_screen.dart     # NEW
│   │   └── widgets/
│   │       ├── dismissable_onboarding_wrapper.dart  # NEW (reusable)
│   │       ├── pre_onboarding_page.dart       # NEW (base widget)
│   │       ├── post_login_welcome_page.dart   # NEW (base widget)
│   │       └── onboarding_page_indicator.dart # NEW (● ○ ○ dots)
│   │
│   └── profile/
│       ├── profile_creation_screen.dart       # MODIFY: Add explanations
│       └── profile_selection_screen.dart      # MODIFY: Check post-login flag
│
└── main.dart                                  # MODIFY: Add pre-onboarding check
```

### Storage & State

#### Hive Settings Box (App-Level)

```dart
// Key: 'pre_onboarding_dismissed'
// Type: bool
// Default: false
// Purpose: Track if user has dismissed Pre-Onboarding

// Usage:
final profileService = getIt<ProfileService>();
final dismissed = profileService.settingsBox.get(
  'pre_onboarding_dismissed',
  defaultValue: false,
);
```

#### Profile Model (Profile-Level)

```dart
// Field: hasSeenPostLoginWelcome
// Type: bool
// Default: false
// Purpose: Track if profile has seen Post-Login Welcome

// Usage:
if (!currentProfile.hasSeenPostLoginWelcome) {
  // Show Post-Login Welcome
}
```

### Navigation Decision Tree (Detailed)

```
App Launch
    ↓
WidgetsFlutterBinding.ensureInitialized()
    ↓
runApp(MyApp())
    ↓
SplashScreenApp (minimum 3 seconds)
    ↓
buildRealApp()
    ↓
Check ProfileService.settingsBox.get('pre_onboarding_dismissed')
    ↓
┌───────────────────┴───────────────────┐
│                                       │
FALSE (or not set)                     TRUE
│                                       │
↓                                       ↓
PreOnboardingScreen                ProfileSelectionScreen
(4 screens, dismissable)            (standard behavior)
    ↓                                   │
User completes or dismisses             │
    ↓                                   │
Set 'pre_onboarding_dismissed' = true   │
    ↓                                   │
    └─────────────┬─────────────────────┘
                  ↓
         ProfileSelectionScreen
                  ↓
    ┌─────────────┴──────────────┐
    │                            │
User taps profile avatar    User taps "Neues Profil"
    │                            │
    ↓                            ↓
Password Check             ProfileCreationScreen
(if password set)          (with explanations - Stufe 2)
    ↓                            │
Password Correct                 │
    ↓                            │
Profile loaded as active         │
    ↓                            │
Check profile.hasSeenPostLoginWelcome   │
    ↓                            │
┌───────────┴──────────┐         │
│                      │         │
FALSE                 TRUE       │
│                      │         │
↓                      ↓         │
PostLoginWelcomeScreen MainScreen│
(4-5 screens)          (app ready)
    ↓                            │
User completes or dismisses      │
    ↓                            │
Set hasSeenPostLoginWelcome=true │
    ↓                            │
    └──────────┬─────────────────┘
               ↓
          MainScreen
         (app ready)
```

---

## IMPLEMENTIERUNGS-CHECKLISTE

### Phase 1: Infrastruktur & Models (2-3 Stunden)

#### Models
- [ ] **Profile Model Update**
  - [ ] Add field: `@HiveField(15) bool hasSeenPostLoginWelcome = false`
  - [ ] Add to constructor parameters
  - [ ] Add to `copyWith()` method
  - [ ] Run `build_runner` to regenerate adapters
  - [ ] Test: Hive adapter compiles without errors

#### Storage Helper Methods
- [ ] **ProfileService or OnboardingService**
  - [ ] Method: `Future<bool> hasPreOnboardingBeenDismissed()`
  - [ ] Method: `Future<void> dismissPreOnboarding()`
  - [ ] Test: Settings box read/write works

#### Widget Base Classes
- [ ] **Create reusable widgets**
  - [ ] `DismissableOnboardingWrapper` (handles "Nicht mehr anzeigen")
  - [ ] `OnboardingPageIndicator` (● ○ ○ dots)
  - [ ] `OnboardingContentCard` (shared card layout)
  - [ ] Test: Widgets render correctly

---

### Phase 2: Pre-Onboarding (3-4 Stunden)

#### Screen Creation
- [ ] **PreOnboardingScreen**
  - [ ] Create StatefulWidget with PageController
  - [ ] Implement 4 content pages
  - [ ] Add page navigation (swipe + button)
  - [ ] Add "Nicht mehr anzeigen" button
  - [ ] Wire up dismissal logic
  - [ ] Test: Can swipe through all screens
  - [ ] Test: "Nicht mehr anzeigen" sets flag correctly

#### Content Pages
- [ ] **PreOnboardingWelcomePage**
  - [ ] Aurora logo animation
  - [ ] Headline + subline text
  - [ ] Gradient background
  - [ ] Test: Renders correctly

- [ ] **PreOnboardingPrivacyPage**
  - [ ] Shield icon animation
  - [ ] 4 bullet points (✓ Alle Daten lokal, etc.)
  - [ ] Crossed-out cloud visual
  - [ ] Test: All text visible

- [ ] **PreOnboardingMultiProfilePage**
  - [ ] 4 colored circles animation
  - [ ] Explanation text
  - [ ] Bullet points (Name, Farbe, etc.)
  - [ ] Test: Animation smooth

- [ ] **PreOnboardingLetsGoPage**
  - [ ] Sparkles icon
  - [ ] "Bereit anzufangen?" text
  - [ ] Admin explanation
  - [ ] CTA: "Profil erstellen →"
  - [ ] Test: Button navigates to ProfileCreationScreen

#### Navigation Integration
- [ ] **main.dart**
  - [ ] Check `pre_onboarding_dismissed` flag in `buildRealApp()`
  - [ ] Route to PreOnboardingScreen if false
  - [ ] Route to ProfileSelectionScreen if true
  - [ ] Test: First launch shows onboarding
  - [ ] Test: After dismiss, shows ProfileSelectionScreen

---

### Phase 3: Profile Creation Walkthrough (2-3 Stunden)

#### ProfileCreationScreen Enhancements
- [ ] **Card 1: Identity**
  - [ ] Add section header: "Wer bist du?"
  - [ ] Add explanation text
  - [ ] Add password tooltip with info icon
  - [ ] Test: Text displays correctly

- [ ] **Card 2: Age**
  - [ ] Add section header: "Wie alt bist du?"
  - [ ] Add explanation text
  - [ ] Add info box with permission explanations
    - [ ] Kinder (<8): Chat, Tagebuch, Spiele
    - [ ] Erwachsene (≥8): Alle Funktionen
  - [ ] Add reassurance: "Admin kann anpassen"
  - [ ] Test: Info box styled correctly

- [ ] **Card 3: Color**
  - [ ] Add section header: "Deine Lieblingsfarbe?"
  - [ ] Add explanation text
  - [ ] Add color preview box
  - [ ] Test: Preview updates with color selection

#### Progress Indicator
- [ ] **Add step indicator**
  - [ ] Create `_buildProgressDot()` method
  - [ ] Show ● ○ ○ based on current card
  - [ ] Place at bottom of screen
  - [ ] Test: Indicator updates when switching cards

---

### Phase 4: Post-Login Welcome (3-4 Stunden)

#### Screen Creation
- [ ] **PostLoginWelcomeScreen**
  - [ ] Create StatefulWidget with PageController
  - [ ] Accept `currentProfile` parameter
  - [ ] Build pages dynamically (conditional "You're Not Alone")
  - [ ] Add page navigation
  - [ ] Add "Nicht mehr anzeigen" button
  - [ ] Wire up dismissal logic
  - [ ] Test: Can navigate through all screens

#### Content Pages
- [ ] **PostLoginWelcomePage**
  - [ ] Personalized headline: "Hallo [Name]!"
  - [ ] Profile color as gradient/accent
  - [ ] Emoji: 👋
  - [ ] Test: Name displayed correctly
  - [ ] Test: Color matches profile

- [ ] **PostLoginOtherProfilesPage** (Conditional)
  - [ ] Headline: "Du bist nicht allein."
  - [ ] Load other profiles (exclude current)
  - [ ] Display 3-4 profile avatars + names
  - [ ] Subtext: "Ihr könnt miteinander chatten..."
  - [ ] Test: Shows correct profiles
  - [ ] Test: Skips if only 1 profile exists

- [ ] **PostLoginPermissionsPage**
  - [ ] Headline: "Was du tun kannst:"
  - [ ] Generate permission list dynamically
    - [ ] If `viewChatTab`: ✓ Chat
    - [ ] If `viewCalendarTab`: ✓ Kalender
    - [ ] If `createCalendarEvents`: add "erstellen"
    - [ ] etc.
  - [ ] Test: Shows correct permissions
  - [ ] Test: Different for child vs adult profiles

- [ ] **PostLoginSafeSpacePage**
  - [ ] Headline: "Dein persönlicher Bereich"
  - [ ] Shield icon
  - [ ] Privacy reassurance text
  - [ ] CTA: "Los geht's! →"
  - [ ] Test: Navigates to MainScreen

#### Profile Flag Logic
- [ ] **Mark as seen**
  - [ ] Update profile: `hasSeenPostLoginWelcome = true`
  - [ ] Save via ProfileService
  - [ ] Test: Flag persists after app restart

#### Navigation Integration
- [ ] **ProfileSelectionScreen**
  - [ ] After successful login, check `hasSeenPostLoginWelcome`
  - [ ] If false → PostLoginWelcomeScreen
  - [ ] If true → MainScreen (existing behavior)
  - [ ] Test: First login shows welcome
  - [ ] Test: Second login skips welcome

---

### Phase 5: Testing & Polish (1-2 Stunden)

#### End-to-End Testing
- [ ] **First-time install flow**
  1. [ ] Install app (or clear data)
  2. [ ] Launch → SplashScreen → PreOnboarding
  3. [ ] Complete PreOnboarding → ProfileCreationScreen
  4. [ ] Create first profile → PostLoginWelcome
  5. [ ] Complete welcome → MainScreen
  6. [ ] Restart app → Should skip pre-onboarding
  7. [ ] Login → Should skip post-login welcome

- [ ] **Multiple profiles flow**
  1. [ ] Admin creates 2nd profile
  2. [ ] Logout, login as 2nd profile
  3. [ ] Should show PostLoginWelcome
  4. [ ] Screen 2 should show "You're Not Alone" with Admin profile
  5. [ ] Logout, login as 2nd profile again
  6. [ ] Should skip welcome (flag set)

- [ ] **Dismissal flow**
  1. [ ] Fresh install
  2. [ ] Pre-Onboarding: Tap "Nicht mehr anzeigen" on screen 2
  3. [ ] Should go to ProfileCreationScreen
  4. [ ] Create profile
  5. [ ] Post-Login Welcome: Tap "Nicht mehr anzeigen" on screen 1
  6. [ ] Should go to MainScreen
  7. [ ] Restart app → No onboarding shown

#### Edge Cases
- [ ] **No other profiles** (PostLoginWelcome)
  - [ ] Screen 2 should be skipped
  - [ ] Only 3 screens shown: Welcome, Permissions, Safe Space

- [ ] **Child profile (<8 years)**
  - [ ] PostLoginWelcome Screen 3 shows limited permissions
  - [ ] Only: Chat, Tagebuch, Spiele

- [ ] **Back navigation**
  - [ ] User can swipe back in onboarding
  - [ ] Progress dots update correctly

- [ ] **Orientation changes**
  - [ ] Onboarding survives rotation
  - [ ] PageView maintains position

#### Visual Polish
- [ ] **Animations**
  - [ ] Logo glow animation in PreOnboarding
  - [ ] Shield icon animation
  - [ ] Colored circles rotation
  - [ ] Page transitions smooth

- [ ] **Accessibility**
  - [ ] Semantic labels for screen readers
  - [ ] High contrast text
  - [ ] Tap targets minimum 48x48dp
  - [ ] Font sizes respect system settings

- [ ] **Consistency**
  - [ ] All screens use same gradient style
  - [ ] Button styles match app theme
  - [ ] Progress dots identical across flows
  - [ ] "Nicht mehr anzeigen" button placement consistent

---

## TESTING-SZENARIEN

### Scenario 1: Frische Installation (Hauptfall)

**Schritte:**
1. Installiere App oder lösche App-Daten
2. Starte App
3. Warte auf SplashScreen (3 Sekunden)
4. **Erwartung:** PreOnboardingScreen erscheint
5. Swipe durch alle 4 Screens
6. Tap "Profil erstellen →" auf Screen 4
7. **Erwartung:** ProfileCreationScreen öffnet sich
8. Fülle alle 3 Cards aus (Name, Alter, Farbe)
9. Tap "Profil erstellen"
10. **Erwartung:** PostLoginWelcomeScreen erscheint
11. Swipe durch alle Screens (3-4, abhängig von anderen Profilen)
12. Tap "Los geht's!" auf letztem Screen
13. **Erwartung:** MainScreen öffnet sich
14. App ist einsatzbereit

**Erwartetes Ergebnis:**
- ✅ Pre-Onboarding gezeigt
- ✅ Profile Creation mit Erklärungen
- ✅ Post-Login Welcome personalisiert
- ✅ MainScreen erreichbar

---

### Scenario 2: "Nicht mehr anzeigen" - Pre-Onboarding

**Schritte:**
1. Frische Installation
2. PreOnboarding erscheint
3. Auf Screen 2 tap "Nicht mehr anzeigen"
4. **Erwartung:** Direkt zu ProfileCreationScreen
5. Erstelle Profil
6. **Erwartung:** PostLoginWelcome erscheint (unabhängig)
7. Complete welcome
8. App neustarten
9. **Erwartung:** PreOnboarding wird NICHT mehr gezeigt

**Erwartetes Ergebnis:**
- ✅ Dismissal funktioniert
- ✅ Flag persistent
- ✅ Post-Login Welcome unabhängig

---

### Scenario 3: "Nicht mehr anzeigen" - Post-Login Welcome

**Schritte:**
1. Nach Profile Creation
2. PostLoginWelcome erscheint
3. Auf Screen 1 tap "Nicht mehr anzeigen"
4. **Erwartung:** Direkt zu MainScreen
5. Logout
6. Login mit gleichem Profil
7. **Erwartung:** Welcome wird NICHT mehr gezeigt

**Erwartetes Ergebnis:**
- ✅ Dismissal funktioniert
- ✅ Flag pro Profil persistent

---

### Scenario 4: Mehrere Profile (Admin erstellt für Anteile)

**Schritte:**
1. Admin erstellt sein Profil (durchläuft alle Onboardings)
2. In MainScreen: Tap ProfileSwitcherBar → "Neues Profil"
3. Erstelle 2. Profil (anderer Name, Alter, Farbe)
4. **Erwartung:** Nach Creation sofort zu MainScreen (kein Welcome)
5. Logout (tap ProfileSwitcherBar → anderes Profil wählen)
6. Login mit 2. Profil
7. **Erwartung:** PostLoginWelcome erscheint!
8. Screen 2 zeigt Admin-Profil: "Du bist nicht allein"
9. Complete welcome
10. Logout, login mit 2. Profil erneut
11. **Erwartung:** Kein Welcome (Flag gesetzt)

**Erwartetes Ergebnis:**
- ✅ Jedes Profil bekommt eigenes Welcome beim ERSTEN Login
- ✅ Screen 2 zeigt andere Profile korrekt
- ✅ Welcome nur einmal pro Profil

---

### Scenario 5: Kind-Profil (<8 Jahre)

**Schritte:**
1. Erstelle Profil mit Alter = 5
2. PostLoginWelcome erscheint
3. Navigate zu Screen 3 ("Was du tun kannst")
4. **Erwartung:** NUR zeigt:
   - ✓ Chat
   - ✓ Tagebuch
   - ✓ Spiele
5. **NICHT zeigt:**
   - Kalender (nur Lesen, nicht Erstellen)
   - Medikamente
   - Kontakte
   - etc.

**Erwartetes Ergebnis:**
- ✅ Permission-Liste dynamisch basierend auf Alter
- ✅ Kinder sehen nur kindgerechte Features

---

### Scenario 6: Profil ohne andere (allein)

**Schritte:**
1. Frische Installation
2. Erstelle erstes Profil
3. PostLoginWelcome erscheint
4. **Erwartung:** Screen 2 ("Du bist nicht allein") WIRD ÜBERSPRUNGEN
5. Nur 3 Screens gezeigt:
   - Screen 1: Hallo [Name]!
   - Screen 2: Was du tun kannst (originally Screen 3)
   - Screen 3: Dein persönlicher Bereich (originally Screen 4)

**Erwartetes Ergebnis:**
- ✅ Conditional logic funktioniert
- ✅ Kein "Du bist nicht allein" wenn tatsächlich allein

---

### Scenario 7: Orientation Change

**Schritte:**
1. Während PreOnboarding auf Screen 2
2. Rotiere Device (Portrait ↔ Landscape)
3. **Erwartung:** Screen bleibt bei Screen 2
4. Progress dots zeigen weiterhin ○ ● ○ ○
5. Kann weiterhin navigieren

**Erwartetes Ergebnis:**
- ✅ PageController überlebt Rotation
- ✅ State bleibt erhalten

---

### Scenario 8: Back Navigation

**Schritte:**
1. Während PreOnboarding auf Screen 3
2. Swipe zurück zu Screen 2
3. **Erwartung:** Progress dots: ○ ● ○ ○
4. Swipe zurück zu Screen 1
5. **Erwartung:** Progress dots: ● ○ ○ ○
6. Tap Android Back Button
7. **Erwartung:** App minimiert sich (kein Exit aus Onboarding)

**Erwartetes Ergebnis:**
- ✅ Back navigation funktioniert
- ✅ Progress korrekt
- ✅ System Back Button behandelt

---

## DESIGN-SPEZIFIKATIONEN

### Farben & Stile

#### Pre-Onboarding
```dart
// Gradient Background
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF1A1A2E), // Dark blue-grey
    Color(0xFF16213E), // Slightly lighter
  ],
)

// Primary Button (Weiter →)
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFFE8DCC4), // Aurora cream
    foregroundColor: Color(0xFF1A1A2E), // Dark text
    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)

// Dismiss Button (Nicht mehr anzeigen)
TextButton(
  style: TextButton.styleFrom(
    foregroundColor: Colors.white.withOpacity(0.7),
  ),
  child: Text(
    'Nicht mehr anzeigen',
    style: TextStyle(fontSize: 14),
  ),
)

// Progress Dots
Container(
  width: 10,
  height: 10,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: isActive ? Color(0xFFE8DCC4) : Colors.grey.shade600,
  ),
)
```

#### Post-Login Welcome
```dart
// Gradient Background (with profile color)
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    currentProfile.color.withOpacity(0.3), // Profile color accent
    Color(0xFF1A1A2E), // Dark base
  ],
)

// Same button styles as Pre-Onboarding
```

### Typography

```dart
// Headlines
TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Colors.white,
)

// Body Text
TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: Colors.white.withOpacity(0.9),
)

// Subtext / Explanations
TextStyle(
  fontSize: 14,
  color: Colors.grey.shade400,
)

// Bullet Points
TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: Colors.white,
)
```

### Spacing

```dart
// Screen Padding
EdgeInsets.symmetric(horizontal: 32, vertical: 40)

// Section Spacing
SizedBox(height: 24) // Between headline and body
SizedBox(height: 16) // Between body and list
SizedBox(height: 8)  // Between list items

// Button Spacing
SizedBox(height: 32) // Above primary button
```

### Animations

#### Logo Glow (Pre-Onboarding Screen 1)
```dart
AnimatedContainer(
  duration: Duration(seconds: 2),
  curve: Curves.easeInOut,
  decoration: BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: Color(0xFFE8DCC4).withOpacity(0.3),
        blurRadius: 40,
        spreadRadius: 10,
      ),
    ],
  ),
  child: Image.asset('assets/images/logo.png'),
)
```

#### Colored Circles (Pre-Onboarding Screen 3)
```dart
AnimatedRotation(
  turns: _rotationAnimation.value,
  duration: Duration(seconds: 20),
  child: Stack(
    children: [
      // 4 circles positioned in circle
      _buildColoredCircle(color: Colors.red, angle: 0),
      _buildColoredCircle(color: Colors.blue, angle: pi / 2),
      _buildColoredCircle(color: Colors.green, angle: pi),
      _buildColoredCircle(color: Colors.yellow, angle: 3 * pi / 2),
    ],
  ),
)
```

#### Page Transitions
```dart
PageView(
  controller: _pageController,
  physics: ClampingScrollPhysics(), // No overscroll
  children: _pages,
)

// When tapping "Weiter"
_pageController.nextPage(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
)
```

### Accessibility

```dart
// Semantic Labels
Semantics(
  label: 'Willkommen bei Aurora Onboarding',
  child: Text('Willkommen bei Aurora'),
)

// Tap Targets (minimum 48x48)
SizedBox(
  width: 48,
  height: 48,
  child: IconButton(...),
)

// High Contrast Mode
MediaQuery.of(context).platformBrightness == Brightness.light
  ? Colors.black
  : Colors.white
```

---

## GESCHÄTZTER AUFWAND

### Gesamt: 8-12 Stunden (~1,5-2 Tage)

| Phase | Task | Zeit |
|-------|------|------|
| **1** | Infrastruktur & Models | 2-3h |
| | - Profile Model Update | 0.5h |
| | - Storage Helper Methods | 0.5h |
| | - Reusable Widgets | 1-2h |
| **2** | Pre-Onboarding | 3-4h |
| | - PreOnboardingScreen | 1h |
| | - 4 Content Pages | 1.5h |
| | - Navigation Integration | 0.5h |
| | - Testing | 0.5-1h |
| **3** | Profile Creation Walkthrough | 2-3h |
| | - Card 1: Identity Explanations | 0.5h |
| | - Card 2: Age Info Box | 1h |
| | - Card 3: Color Preview | 0.5h |
| | - Progress Indicator | 0.5h |
| | - Testing | 0.5h |
| **4** | Post-Login Welcome | 3-4h |
| | - PostLoginWelcomeScreen | 1h |
| | - 4 Content Pages | 1.5h |
| | - Profile Flag Logic | 0.5h |
| | - Navigation Integration | 0.5h |
| | - Testing | 0.5-1h |
| **5** | Testing & Polish | 1-2h |
| | - End-to-End Testing | 0.5-1h |
| | - Edge Cases | 0.5h |
| | - Visual Polish | 0.5h |

---

## NEXT STEPS (NACH IMPLEMENTIERUNG)

### Weitere Features (Optional, später)

1. **Tutorial Overlays (Coach Marks)**
   - Zeige beim ersten Öffnen von MainScreen Tooltips
   - "Das ist der Chat-Tab" → Highlight Tab
   - "Hier wechselst du Profile" → Highlight ProfileSwitcherBar
   - Library: [showcaseview](https://pub.dev/packages/showcaseview)

2. **Onboarding Replay**
   - In Settings: "Onboarding erneut anzeigen"
   - Reset flags, replay flows
   - Nützlich für Demo oder wenn jemand verwirrt ist

3. **Personalisierung**
   - Mehrsprachigkeit (Deutsch, Englisch)
   - Dynamische Inhalte basierend auf Nutzerfeedback
   - A/B Testing verschiedener Onboarding-Texte

4. **Analytics (Privacy-Friendly)**
   - Lokal tracken: Wie viele überspringen Onboarding?
   - Wo springen Nutzer ab?
   - Nur für interne Optimierung, nie externe Übermittlung

---

## ANHANG

### Referenz-Code: Dismissable Wrapper

```dart
/// Reusable wrapper for onboarding screens with dismissal
class DismissableOnboardingWrapper extends StatelessWidget {
  final List<Widget> pages;
  final VoidCallback onDismiss;
  final VoidCallback onComplete;
  final String dismissText;

  const DismissableOnboardingWrapper({
    super.key,
    required this.pages,
    required this.onDismiss,
    required this.onComplete,
    this.dismissText = 'Nicht mehr anzeigen',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                ],
              ),
            ),
          ),

          // Content
          Column(
            children: [
              Expanded(
                child: PageView(
                  children: pages,
                ),
              ),

              // Dismiss button
              Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: TextButton(
                  onPressed: onDismiss,
                  child: Text(
                    dismissText,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### Referenz-Code: Page Indicator

```dart
/// Reusable page indicator dots (● ○ ○)
class OnboardingPageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const OnboardingPageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalPages,
        (index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == currentPage
                  ? Color(0xFFE8DCC4) // Aurora cream (active)
                  : Colors.grey.shade600, // Grey (inactive)
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## ZUSAMMENFASSUNG

Dieses 3-Stufen Onboarding System bietet:

1. ✅ **Pre-Onboarding** - Einmalige App-Einführung mit Privacy-Fokus
2. ✅ **Profile Creation Walkthrough** - Integrierte Erklärungen während Profil-Erstellung
3. ✅ **Post-Login Welcome** - Personalisierte Begrüßung für jedes neue Profil

**Vorteile:**
- Jeder Anteil wird individuell begrüßt
- User Control durch "Nicht mehr anzeigen"
- Skaliert perfekt für 1-20+ Profile
- DIS-sensibel und inklusiv
- Kontextbezogen statt frontloaded

**Geschätzter Aufwand:** 8-12 Stunden (1,5-2 Tage)

**Status:** Geplant, bereit zur Implementierung am großen Rechner

---

**Dokument-Ende**
