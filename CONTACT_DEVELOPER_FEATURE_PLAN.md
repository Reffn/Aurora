# Contact Developer Feature - Implementation Plan

**Feature**: Globaler "Kontakt zum Entwickler" Button mit Feedback-Formular
**Status**: 📋 Dokumentation (Implementierung später am Hauptrechner)
**Geschätzte Implementierungszeit**: 1-2 Tage
**Version**: Aurora 3.0.6+

---

## 1. Feature-Übersicht

### Vision
Ein globaler, animierter Chamäleon-Button (Floating Action Button) unten rechts auf **allen Screens**, der Nutzern direkten Kontakt zum 3ofus-Team ermöglicht. Aurora ist in der Open Beta und auf Feedback der Community angewiesen.

### Kernfunktionalität
1. **Globaler FAB**: Chamäleon-Button auf allen Screens sichtbar
2. **Subtile Animation**: Sanftes Pulsieren zur Aufmerksamkeit
3. **Feedback-Formular**: In-App Formular mit Kategorien (Bug, Feature, Feedback)
4. **Externe Kontaktoptionen**: Discord Server, Website, E-Mail
5. **3ofus Team Branding**: Klare Zuordnung zum Entwicklerteam

### Warum wichtig?
- **Open Beta Phase**: Aktives Feedback sammeln für Full Release
- **Community Building**: Discord-Server als zentrale Anlaufstelle
- **Transparenz**: Direkte Kommunikation mit Entwicklern
- **Bug Reports**: Strukturierte Fehlererfassung
- **Feature Requests**: Nutzer können Wünsche äußern

---

## 2. UI/UX Design

### 2.1 Globaler Chamäleon-FAB

**Position**: Unten rechts, 16px Abstand zu Bildschirmrand
**Design**:
```dart
FloatingActionButton(
  heroTag: 'contact_developer_fab', // Eindeutige Tag für Hero-Transitions
  backgroundColor: Color(0xFF9D84B7), // Aurora Lila
  child: Image.asset(
    'assets/images/chameleon.png', // Chamäleon-Logo
    width: 32,
    height: 32,
  ),
  onPressed: () => _showFeedbackBottomSheet(context),
)
```

**Animation**: Subtiles Pulsieren (Scale 1.0 → 1.05 → 1.0)
- Loop-Dauer: 2000ms
- Curve: `Curves.easeInOut`
- Pattern: `TweenAnimationBuilder<double>` (siehe AnimatedEmptyState-Pattern)

**Elevation**:
- Standard: 6.0
- Hover (Desktop): 8.0

### 2.2 Bottom Sheet Layout

**Trigger**: Tap auf Chamäleon-FAB
**Typ**: Modal Bottom Sheet
**Design**:

```
┌─────────────────────────────────────┐
│  Kontakt zum Entwickler             │ ← Header
│  ────────────────────────────────   │
│                                     │
│  🦎 3ofus Team                      │ ← Branding
│  Aurora ist in der Open Beta und   │
│  auf dein Feedback angewiesen!     │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Feedback senden             │   │ ← Tab 1 (Standard)
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ Kontaktmöglichkeiten        │   │ ← Tab 2
│  └─────────────────────────────┘   │
│                                     │
│  [Dynamischer Inhalt]              │
│                                     │
└─────────────────────────────────────┘
```

**Technische Details**:
- `showModalBottomSheet<void>()`
- `shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16)))`
- `isScrollControlled: true` (für Keyboard-Support)
- `SafeArea` Padding

### 2.3 Tab 1: Feedback-Formular

**Inhalt**:
```
┌─────────────────────────────────────┐
│  Kategorie wählen:                 │
│  [ ] 🐛 Bug Report                 │ ← Radio Buttons
│  [ ] ✨ Feature Request            │
│  [●] 💬 Allgemeines Feedback       │
│                                     │
│  Deine Nachricht:                  │
│  ┌─────────────────────────────┐   │
│  │ [Textfeld]                  │   │ ← TextField (maxLines: 8)
│  │                             │   │
│  │                             │   │
│  └─────────────────────────────┘   │
│                                     │
│  📧 Optional: Deine E-Mail         │
│  ┌─────────────────────────────┐   │
│  │ user@example.com            │   │ ← TextField (Email-Validator)
│  └─────────────────────────────┘   │
│                                     │
│  [Senden]                          │ ← ElevatedButton (primär)
│                                     │
└─────────────────────────────────────┘
```

**Formular-Felder**:
1. **Kategorie** (erforderlich):
   - 🐛 Bug Report
   - ✨ Feature Request
   - 💬 Allgemeines Feedback
   - RadioListTile mit Icons

2. **Nachricht** (erforderlich):
   - TextField, multiline (3-8 Zeilen)
   - maxLength: 1000 Zeichen
   - Validator: mindestens 10 Zeichen

3. **E-Mail** (optional):
   - TextField, keyboardType: TextInputType.emailAddress
   - Validator: Email-Format wenn ausgefüllt
   - Hinweis: "Nur wenn du eine Antwort wünschst"

**Senden-Button**:
- Öffnet Standard-E-Mail-Client mit vorausgefüllter E-Mail
- Empfänger: `aurora@3ofus.de` (oder finale E-Mail-Adresse)
- Betreff: `[Aurora Feedback] {Kategorie}`
- Body: Formatierter Text mit Kategorie, Nachricht, optional E-Mail

### 2.4 Tab 2: Kontaktmöglichkeiten

**Inhalt**:
```
┌─────────────────────────────────────┐
│  Weitere Kontaktmöglichkeiten:     │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 💬 Discord Server           │   │ ← ListTile
│  │ Tritt unserer Community bei│   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 🌐 Website                  │   │ ← ListTile
│  │ www.3ofus.de                │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 📧 E-Mail                   │   │ ← ListTile
│  │ aurora@3ofus.de             │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 🐙 GitHub                   │   │ ← ListTile (optional)
│  │ Bug Reports & Issues        │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

**Kontakt-Optionen** (ListTiles):
1. **Discord Server**:
   - Icon: `Icons.discord` oder Custom Discord Icon
   - Leading: Lila Kreis mit Icon
   - Title: "Discord Server"
   - Subtitle: "Tritt unserer Community bei"
   - onTap: `launchUrl('https://discord.gg/[INVITE_CODE]')`

2. **Website**:
   - Icon: `Icons.language`
   - Leading: Blauer Kreis mit Icon
   - Title: "Website"
   - Subtitle: "www.3ofus.de"
   - onTap: `launchUrl('https://www.3ofus.de')`

3. **E-Mail**:
   - Icon: `Icons.email`
   - Leading: Grüner Kreis mit Icon
   - Title: "E-Mail"
   - Subtitle: "aurora@3ofus.de"
   - onTap: `launchUrl('mailto:aurora@3ofus.de')`

4. **GitHub** (optional):
   - Icon: `Icons.code`
   - Leading: Oranger Kreis mit Icon
   - Title: "GitHub"
   - Subtitle: "Bug Reports & Issues"
   - onTap: `launchUrl('https://github.com/3ofus/aurora')`

**Styling**:
- ListTile mit color-coded Kreisen (wie ImagePickerBottomSheet)
- Trailing: `Icon(Icons.open_in_new, size: 16)` für externe Links
- Tap-Feedback: InkWell Ripple-Effekt

---

## 3. Technische Implementierung

### 3.1 Datenmodell

#### FeedbackCategory Enum
```dart
// lib/models/feedback_category.dart
enum FeedbackCategory {
  bugReport,
  featureRequest,
  generalFeedback;

  String get displayName {
    switch (this) {
      case FeedbackCategory.bugReport:
        return 'Bug Report';
      case FeedbackCategory.featureRequest:
        return 'Feature Request';
      case FeedbackCategory.generalFeedback:
        return 'Allgemeines Feedback';
    }
  }

  String get icon {
    switch (this) {
      case FeedbackCategory.bugReport:
        return '🐛';
      case FeedbackCategory.featureRequest:
        return '✨';
      case FeedbackCategory.generalFeedback:
        return '💬';
    }
  }

  String get emailSubjectPrefix {
    switch (this) {
      case FeedbackCategory.bugReport:
        return '[Bug]';
      case FeedbackCategory.featureRequest:
        return '[Feature]';
      case FeedbackCategory.generalFeedback:
        return '[Feedback]';
    }
  }
}
```

### 3.2 Widget-Architektur

#### 3.2.1 ContactDeveloperFAB (Globaler Button)

```dart
// lib/widgets/contact_developer_fab.dart
import 'package:flutter/material.dart';
import 'package:dis_app/widgets/feedback_bottom_sheet.dart';

/// Globaler Floating Action Button für Entwickler-Kontakt
///
/// Zeigt ein animiertes Chamäleon-Icon und öffnet das Feedback-Bottom-Sheet.
/// Wird global in main.dart über allen Screens angezeigt.
class ContactDeveloperFAB extends StatefulWidget {
  const ContactDeveloperFAB({super.key});

  @override
  State<ContactDeveloperFAB> createState() => _ContactDeveloperFABState();
}

class _ContactDeveloperFABState extends State<ContactDeveloperFAB> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: _PulsingFAB(
        onPressed: () => _showFeedbackBottomSheet(context),
      ),
    );
  }

  void _showFeedbackBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const FeedbackBottomSheet(),
    );
  }
}

/// Pulsierender FAB mit Chamäleon-Icon
class _PulsingFAB extends StatefulWidget {
  final VoidCallback onPressed;

  const _PulsingFAB({required this.onPressed});

  @override
  State<_PulsingFAB> createState() => _PulsingFABState();
}

class _PulsingFABState extends State<_PulsingFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FloatingActionButton(
        heroTag: 'contact_developer_fab',
        backgroundColor: const Color(0xFF9D84B7), // Aurora Lila
        elevation: 6,
        onPressed: widget.onPressed,
        child: Image.asset(
          'assets/images/chameleon.png',
          width: 32,
          height: 32,
          errorBuilder: (context, error, stackTrace) {
            // Fallback wenn Chamäleon-Asset fehlt
            return const Icon(Icons.contact_support, color: Colors.white);
          },
        ),
      ),
    );
  }
}
```

**Integration in main.dart**:
```dart
// lib/main.dart
@override
Widget build(BuildContext context) {
  return MaterialApp(
    // ... existing config
    home: Stack(
      children: [
        // Existing app content
        Scaffold(
          appBar: ...,
          body: ...,
        ),
        // Global FAB overlay
        const ContactDeveloperFAB(),
      ],
    ),
  );
}
```

#### 3.2.2 FeedbackBottomSheet (Bottom Sheet mit Tabs)

```dart
// lib/widgets/feedback_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:dis_app/models/feedback_category.dart';
import 'package:url_launcher/url_launcher.dart';

/// Bottom Sheet für Feedback und Entwickler-Kontakt
class FeedbackBottomSheet extends StatefulWidget {
  const FeedbackBottomSheet({super.key});

  @override
  State<FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends State<FeedbackBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Formular-State
  FeedbackCategory _selectedCategory = FeedbackCategory.generalFeedback;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildTabBar(),
            _buildTabBarView(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/chameleon.png',
                width: 40,
                height: 40,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.contact_support,
                  size: 40,
                  color: Color(0xFF9D84B7),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kontakt zum Entwickler',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '3ofus Team',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF9D84B7),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF9D84B7).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Color(0xFF9D84B7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Aurora ist in der Open Beta und auf dein Feedback angewiesen!',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: const Color(0xFF9D84B7),
      unselectedLabelColor: Colors.grey,
      indicatorColor: const Color(0xFF9D84B7),
      tabs: const [
        Tab(text: 'Feedback senden'),
        Tab(text: 'Kontaktmöglichkeiten'),
      ],
    );
  }

  Widget _buildTabBarView() {
    return SizedBox(
      height: 450, // Feste Höhe für Tab-Content
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildFeedbackForm(),
          _buildContactOptions(),
        ],
      ),
    );
  }

  // Tab 1: Feedback-Formular
  Widget _buildFeedbackForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kategorie wählen:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ...FeedbackCategory.values.map((category) {
              return RadioListTile<FeedbackCategory>(
                value: category,
                groupValue: _selectedCategory,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                title: Row(
                  children: [
                    Text(category.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(category.displayName),
                  ],
                ),
                activeColor: const Color(0xFF9D84B7),
                contentPadding: EdgeInsets.zero,
              );
            }),
            const SizedBox(height: 16),
            Text(
              'Deine Nachricht:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _messageController,
              maxLines: 6,
              maxLength: 1000,
              decoration: InputDecoration(
                hintText: 'Beschreibe dein Feedback...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF9D84B7),
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Bitte gib eine Nachricht ein';
                }
                if (value.trim().length < 10) {
                  return 'Nachricht zu kurz (mindestens 10 Zeichen)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Deine E-Mail (optional):',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Nur wenn du eine Antwort wünschst',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'deine@email.de',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF9D84B7),
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (!emailRegex.hasMatch(value)) {
                    return 'Ungültige E-Mail-Adresse';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sendFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9D84B7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Senden',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tab 2: Kontaktmöglichkeiten
  Widget _buildContactOptions() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildContactTile(
          icon: Icons.discord,
          color: const Color(0xFF5865F2), // Discord Blurple
          title: 'Discord Server',
          subtitle: 'Tritt unserer Community bei',
          url: 'https://discord.gg/INVITE_CODE', // TODO: Echten Invite-Link einfügen
        ),
        const SizedBox(height: 12),
        _buildContactTile(
          icon: Icons.language,
          color: const Color(0xFF2196F3), // Blau
          title: 'Website',
          subtitle: 'www.3ofus.de',
          url: 'https://www.3ofus.de',
        ),
        const SizedBox(height: 12),
        _buildContactTile(
          icon: Icons.email,
          color: const Color(0xFF4CAF50), // Grün
          title: 'E-Mail',
          subtitle: 'aurora@3ofus.de',
          url: 'mailto:aurora@3ofus.de',
        ),
        const SizedBox(height: 12),
        _buildContactTile(
          icon: Icons.code,
          color: const Color(0xFFFF9800), // Orange
          title: 'GitHub',
          subtitle: 'Bug Reports & Issues',
          url: 'https://github.com/3ofus/aurora', // TODO: Echte Repo-URL
        ),
      ],
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String url,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.open_in_new, size: 16),
        onTap: () => _launchUrl(url),
      ),
    );
  }

  // Feedback per E-Mail senden
  Future<void> _sendFeedback() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final category = _selectedCategory;
    final message = _messageController.text.trim();
    final email = _emailController.text.trim();

    // E-Mail-Body formatieren
    final emailBody = StringBuffer();
    emailBody.writeln('Kategorie: ${category.displayName}');
    emailBody.writeln();
    emailBody.writeln('Nachricht:');
    emailBody.writeln(message);

    if (email.isNotEmpty) {
      emailBody.writeln();
      emailBody.writeln('Antwort an: $email');
    }

    final emailUri = Uri(
      scheme: 'mailto',
      path: 'aurora@3ofus.de', // TODO: Finale E-Mail-Adresse
      queryParameters: {
        'subject': '${category.emailSubjectPrefix} Aurora Feedback',
        'body': emailBody.toString(),
      },
    );

    await _launchUrl(emailUri.toString());

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-Mail-Client geöffnet. Danke für dein Feedback!'),
          backgroundColor: Color(0xFF9D84B7),
        ),
      );
    }
  }

  // URL im Browser/E-Mail-Client öffnen
  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Link konnte nicht geöffnet werden: $urlString'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
```

### 3.3 Assets

#### Chamäleon-Asset Anforderungen

**Dateiname**: `assets/images/chameleon.png` (oder `.webp` für kleinere Dateigröße)

**Spezifikationen**:
- Format: PNG (transparenter Hintergrund) oder WebP
- Größe: 512x512px (Original), automatisch skaliert
- Farbpalette: Aurora-kompatibel (Lila/Pink-Töne bevorzugt)
- Stil: Minimalistisch, freundlich, erkennbar als Chamäleon
- Verwendung: 32x32px im FAB, 40x40px im Bottom Sheet Header

**Alternativen bei fehlendem Asset**:
- Fallback: `Icons.contact_support` (Material Icon)
- Temporär: Logo-Icon als Placeholder

**pubspec.yaml Update**:
```yaml
flutter:
  assets:
    - assets/images/logo.png
    - assets/images/logo_icon.png
    # ... existing assets
    - assets/images/chameleon.png  # NEU
```

### 3.4 Konfiguration

#### Kontakt-URLs (zu aktualisieren)

**TODOs**:
```dart
// lib/utils/contact_config.dart
class ContactConfig {
  // E-Mail-Adressen
  static const String supportEmail = 'aurora@3ofus.de'; // TODO: Finale Adresse

  // Discord
  static const String discordInviteUrl = 'https://discord.gg/INVITE_CODE'; // TODO: Invite-Code

  // Website
  static const String websiteUrl = 'https://www.3ofus.de'; // TODO: Finale URL

  // GitHub (optional)
  static const String githubRepoUrl = 'https://github.com/3ofus/aurora'; // TODO: Repo-URL

  // Branding
  static const String teamName = '3ofus Team';
  static const String appName = 'Aurora';
}
```

---

## 4. Integration in Bestehende Architektur

### 4.1 main.dart Integration

**Problem**: Wie kann ein globaler FAB auf **allen** Screens angezeigt werden?

**Lösung**: Stack-Overlay über MaterialApp

```dart
// lib/main.dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aurora',
      theme: ...,
      home: Stack(
        children: [
          // Existing app scaffold
          _buildMainScaffold(),

          // Global FAB overlay
          const ContactDeveloperFAB(),
        ],
      ),
    );
  }

  Widget _buildMainScaffold() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const ProfileSwitcherBar(),
          const CarouselTabNavigator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              children: _filteredTabDefinitions
                  .map((tab) => tab.builder(context))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
```

**Alternative**: MaterialApp mit `builder`-Parameter
```dart
MaterialApp(
  builder: (context, child) {
    return Stack(
      children: [
        child!,
        const ContactDeveloperFAB(),
      ],
    );
  },
  home: ...,
)
```

### 4.2 Z-Index & Tap-Handling

**Problem**: FAB darf andere FABs nicht überlagern (z.B. Chat, Calendar)

**Lösung**:
1. **Positionierung**: `bottom: 16, right: 16` (Standard-Position)
2. **Bestehende FABs prüfen**:
   - Chat: Unten rechts → Konflikt!
   - Calendar: Unten rechts → Konflikt!
   - Contacts: Unten rechts → Konflikt!

**Anpassung**: Globaler FAB weiter nach rechts/oben verschieben
```dart
Positioned(
  right: 16,
  bottom: 88, // 72px (FAB) + 16px (Margin) = über lokalem FAB
  child: _PulsingFAB(...),
)
```

**Alternative**: Nur auf Screens ohne lokalen FAB anzeigen
```dart
// In ContactDeveloperFAB
@override
Widget build(BuildContext context) {
  // Screen-spezifische Logik
  final currentRoute = ModalRoute.of(context)?.settings.name;
  final hasLocalFAB = _screensWithLocalFAB.contains(currentRoute);

  if (hasLocalFAB) {
    return const SizedBox.shrink(); // Verstecken
  }

  return Positioned(...);
}
```

**Empfehlung**: Bottom: 88px für konsistente Sichtbarkeit

### 4.3 Performance-Überlegungen

**Animation optimieren**:
```dart
// Pulsing nur wenn Widget sichtbar
@override
void didChangeDependencies() {
  super.didChangeDependencies();

  // Pausiere Animation wenn App im Hintergrund
  WidgetsBinding.instance.addObserver(this);
}

@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused) {
    _controller.stop();
  } else if (state == AppLifecycleState.resumed) {
    _controller.repeat();
  }
}
```

**Image Caching**:
- Chamäleon-Asset wird automatisch von Flutter gecacht
- Kein zusätzlicher Code erforderlich

---

## 5. Testing-Strategie

### 5.1 Unit Tests

**Zu testen**:
1. **FeedbackCategory Enum**:
   - `displayName` korrekt
   - `icon` korrekt
   - `emailSubjectPrefix` korrekt

2. **Email-Validierung**:
   - Gültige E-Mails akzeptiert
   - Ungültige E-Mails abgelehnt
   - Leere E-Mail erlaubt (optional)

**Beispiel-Test**:
```dart
// test/models/feedback_category_test.dart
void main() {
  test('FeedbackCategory.bugReport hat korrekten displayName', () {
    expect(FeedbackCategory.bugReport.displayName, 'Bug Report');
  });

  test('FeedbackCategory.bugReport hat korrektes Icon', () {
    expect(FeedbackCategory.bugReport.icon, '🐛');
  });
}
```

### 5.2 Widget Tests

**Zu testen**:
1. **ContactDeveloperFAB**:
   - Rendert korrekt
   - Chamäleon-Icon sichtbar
   - Tap öffnet Bottom Sheet
   - Pulsing-Animation aktiv

2. **FeedbackBottomSheet**:
   - Header rendert korrekt (3ofus Branding)
   - Tab-Wechsel funktioniert
   - Formular-Validierung (leere Nachricht, zu kurze Nachricht)
   - Kategorie-Auswahl ändert State
   - Senden-Button öffnet E-Mail-Client

**Beispiel-Test**:
```dart
// test/widgets/contact_developer_fab_test.dart
void main() {
  testWidgets('ContactDeveloperFAB öffnet Bottom Sheet bei Tap', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: const [ContactDeveloperFAB()],
          ),
        ),
      ),
    );

    // FAB finden
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);

    // Tap
    await tester.tap(fab);
    await tester.pumpAndSettle();

    // Bottom Sheet sichtbar
    expect(find.byType(FeedbackBottomSheet), findsOneWidget);
  });
}
```

### 5.3 Integration Tests

**Szenarien**:
1. **Kompletter Feedback-Flow**:
   - App starten
   - Chamäleon-FAB tappen
   - Kategorie wählen (Bug Report)
   - Nachricht eingeben
   - E-Mail eingeben (optional)
   - Senden tappen
   - E-Mail-Client öffnet (Mock)

2. **Kontaktoptionen**:
   - Discord-Link öffnen
   - Website-Link öffnen
   - E-Mail-Link öffnen
   - GitHub-Link öffnen

3. **Formular-Validierung**:
   - Leere Nachricht → Fehler
   - Zu kurze Nachricht → Fehler
   - Ungültige E-Mail → Fehler
   - Gültige Eingaben → Erfolg

### 5.4 Manuelle Tests

**Checkliste**:
- [ ] Chamäleon-Asset korrekt angezeigt (kein Fallback-Icon)
- [ ] Pulsing-Animation smooth (kein Lag)
- [ ] FAB auf allen Screens sichtbar
- [ ] Keine Überlagerung mit lokalen FABs
- [ ] Bottom Sheet öffnet/schließt smooth
- [ ] Tab-Wechsel funktioniert
- [ ] Formular-Validierung zeigt Fehler
- [ ] E-Mail-Client öffnet mit vorausgefüllten Daten
- [ ] Discord-Link öffnet in Browser/App
- [ ] Website-Link öffnet in Browser
- [ ] GitHub-Link öffnet in Browser
- [ ] Keyboard-Handling (Bottom Sheet scrollt nicht weg)
- [ ] Dark Mode kompatibel
- [ ] Accessibility (Screen Reader)

---

## 6. Accessibility & UX

### 6.1 Screen Reader Support

**Semantics für FAB**:
```dart
Semantics(
  label: 'Kontakt zum Entwickler',
  hint: 'Tippe, um Feedback zu senden oder Kontaktmöglichkeiten zu sehen',
  child: FloatingActionButton(...),
)
```

**Formular-Felder**:
- Alle TextFields haben `labelText` oder Semantics
- Fehlermeldungen werden vorgelesen

### 6.2 Dark Mode

**Farbanpassungen**:
```dart
// Dynamische Farben basierend auf Theme
final primaryColor = Theme.of(context).colorScheme.primary;
final backgroundColor = Theme.of(context).colorScheme.surface;

FloatingActionButton(
  backgroundColor: primaryColor, // Passt sich Theme an
  ...
)
```

**Kontrast**:
- Text auf Buttons: WCAG AA-konform (mindestens 4.5:1)
- FAB-Icon: Weiß auf Lila (hoher Kontrast)

### 6.3 Error Handling

**Netzwerk-Fehler**:
```dart
try {
  await launchUrl(url);
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Fehler beim Öffnen: ${e.toString()}'),
      backgroundColor: Colors.red,
      action: SnackBarAction(
        label: 'Erneut versuchen',
        onPressed: () => launchUrl(url),
      ),
    ),
  );
}
```

**Asset-Loading Fehler**:
- Chamäleon-Bild: `errorBuilder` mit Fallback-Icon
- Graceful degradation

---

## 7. Implementierungs-Checkliste

### Phase 1: Asset & Konfiguration (30 Min)
- [ ] Chamäleon-Asset erstellen/hinzufügen (`assets/images/chameleon.png`)
- [ ] Asset in `pubspec.yaml` registrieren
- [ ] `ContactConfig` Datei mit finalen URLs erstellen
- [ ] Discord Invite-Code eintragen
- [ ] Website-URL bestätigen
- [ ] Support-E-Mail-Adresse festlegen
- [ ] GitHub-Repo-URL (falls öffentlich)

### Phase 2: Datenmodell (30 Min)
- [ ] `lib/models/feedback_category.dart` erstellen
- [ ] Enum mit 3 Kategorien (Bug, Feature, General)
- [ ] `displayName`, `icon`, `emailSubjectPrefix` implementieren
- [ ] Unit Tests für Enum schreiben

### Phase 3: ContactDeveloperFAB (1-2 Stunden)
- [ ] `lib/widgets/contact_developer_fab.dart` erstellen
- [ ] `_PulsingFAB` Widget mit AnimationController
- [ ] Scale-Animation (1.0 → 1.05 → 1.0, 2s Loop)
- [ ] FloatingActionButton mit Chamäleon-Icon
- [ ] Positioned Wrapper (bottom: 88, right: 16)
- [ ] Bottom Sheet Trigger implementieren
- [ ] Lifecycle Observer für Animation-Pause
- [ ] Widget Tests schreiben

### Phase 4: FeedbackBottomSheet (2-3 Stunden)
- [ ] `lib/widgets/feedback_bottom_sheet.dart` erstellen
- [ ] TabController Setup (2 Tabs)
- [ ] Header mit Chamäleon + 3ofus Branding
- [ ] Info-Banner ("Open Beta, Feedback willkommen")
- [ ] TabBar (Feedback senden | Kontaktmöglichkeiten)
- [ ] Tab 1: Feedback-Formular
  - [ ] RadioListTiles für Kategorien
  - [ ] TextFormField für Nachricht (Validierung: 10+ Zeichen)
  - [ ] TextFormField für E-Mail (optional, Email-Format)
  - [ ] Senden-Button
- [ ] Tab 2: Kontaktoptionen
  - [ ] Discord ListTile mit Icon + URL
  - [ ] Website ListTile
  - [ ] E-Mail ListTile
  - [ ] GitHub ListTile (optional)
- [ ] `_sendFeedback()` Methode (mailto: URI)
- [ ] `_launchUrl()` Methode mit Error Handling
- [ ] Widget Tests schreiben

### Phase 5: main.dart Integration (30 Min)
- [ ] Stack-Overlay in `main.dart` hinzufügen
- [ ] `ContactDeveloperFAB` über Scaffold
- [ ] Z-Index Konflikt mit lokalen FABs prüfen
- [ ] Position anpassen falls nötig (bottom: 88)
- [ ] Testen auf allen Screens

### Phase 6: Testing (1-2 Stunden)
- [ ] Unit Tests für FeedbackCategory
- [ ] Widget Tests für ContactDeveloperFAB
- [ ] Widget Tests für FeedbackBottomSheet
- [ ] Integration Test: Kompletter Flow
- [ ] Manuelle Tests (siehe Checkliste 5.4)
- [ ] Dark Mode testen
- [ ] Screen Reader testen
- [ ] Performance testen (Animation-Lag?)

### Phase 7: Dokumentation & Polish (30 Min)
- [ ] Code-Kommentare überprüfen
- [ ] README.md Update (neues Feature erwähnen)
- [ ] Screenshots für Dokumentation
- [ ] Changelog-Eintrag (`CHANGELOG.md`)

---

## 8. Zeitschätzung

**Gesamt: 1-2 Tage**

| Phase | Aufgabe | Zeit |
|-------|---------|------|
| 1 | Asset & Konfiguration | 30 Min |
| 2 | Datenmodell | 30 Min |
| 3 | ContactDeveloperFAB | 1-2 Std |
| 4 | FeedbackBottomSheet | 2-3 Std |
| 5 | main.dart Integration | 30 Min |
| 6 | Testing | 1-2 Std |
| 7 | Dokumentation & Polish | 30 Min |
| **Total** | | **6-9 Std** |

**Annahmen**:
- Chamäleon-Asset bereits vorhanden (oder schnell erstellt)
- Finale Kontakt-URLs bekannt
- Keine größeren Bug-Fixes während Testing

---

## 9. Offene Fragen / TODOs

### Zu klären vor Implementierung:
1. **Discord Server**:
   - [ ] Existiert bereits ein 3ofus Discord Server?
   - [ ] Falls ja: Invite-Code generieren (nie ablaufend, unbegrenzte Nutzungen)
   - [ ] Falls nein: Discord Server erstellen

2. **Website**:
   - [ ] Ist www.3ofus.de die finale URL?
   - [ ] Gibt es eine Landing Page für Aurora?

3. **E-Mail**:
   - [ ] Finale Support-E-Mail-Adresse festlegen
   - [ ] Postfach einrichten und überwachen
   - [ ] Auto-Reply konfigurieren? ("Danke für dein Feedback, wir melden uns bald")

4. **GitHub**:
   - [ ] Ist das Repository öffentlich?
   - [ ] Falls nein: GitHub-Link weglassen
   - [ ] Falls ja: Issue-Templates für Bug Reports/Feature Requests erstellen

5. **Chamäleon-Design**:
   - [ ] Gibt es bereits ein Chamäleon-Logo/Maskottchen?
   - [ ] Soll es erstellt werden? (Designer kontaktieren)
   - [ ] Temporär Fallback-Icon verwenden?

6. **Branding**:
   - [ ] "3ofus Team" korrekte Schreibweise?
   - [ ] Weitere Branding-Elemente (Farben, Fonts)?

### Zukünftige Erweiterungen:
- **In-App Analytics**: Feedback-Kategorien tracken (welche am häufigsten?)
- **FAQ-Bereich**: Häufige Fragen direkt in der App beantworten
- **Changelog im Bottom Sheet**: "Was ist neu?" Tab
- **GitHub Integration**: Direkt Issues aus der App erstellen (via GitHub API)
- **Push Notifications**: Bei neuen Antworten auf Discord benachrichtigen

---

## 10. Best Practices & Hinweise

### Code-Qualität
- ✅ **Dart Analyzer**: Alle Warnungen beheben (`flutter analyze`)
- ✅ **Custom Lints**: Lint-Regeln einhalten (`dart run custom_lint`)
- ✅ **Kommentare**: Alle öffentlichen APIs dokumentieren
- ✅ **Formatierung**: `dart format .` vor Commit

### Privacy-First
- ✅ **Keine Telemetrie**: Feedback wird NICHT automatisch gesendet
- ✅ **Nutzer-Kontrolle**: Explizite Aktion erforderlich (Tap auf Senden)
- ✅ **Opt-In E-Mail**: E-Mail-Adresse ist optional
- ✅ **Transparenz**: Nutzer sieht, was gesendet wird (E-Mail-Client öffnet)

### Accessibility
- ✅ **Semantics**: Screen Reader Support für alle Elemente
- ✅ **Kontrast**: WCAG AA-konform
- ✅ **Tap-Targets**: Mindestens 48x48px (Material Guidelines)
- ✅ **Keyboard Navigation**: Tab-Order logisch

### Performance
- ✅ **Animation**: 60 FPS (keine dropped frames)
- ✅ **Asset Size**: Chamäleon <100KB (optimiert)
- ✅ **Lazy Loading**: Bottom Sheet nur bei Tap gerendert
- ✅ **Memory**: Animation pausiert wenn App im Hintergrund

---

## 11. Beispiel-Flows

### Flow 1: Bug Report senden

```
1. Nutzer ist im Chat-Tab
2. Sieht pulsierenden Chamäleon-FAB (unten rechts, über lokalem FAB)
3. Tippt auf Chamäleon → Bottom Sheet öffnet
4. Sieht Header: "Kontakt zum Entwickler" + 3ofus Branding
5. Standardmäßig auf Tab "Feedback senden"
6. Wählt Kategorie: 🐛 Bug Report
7. Gibt Nachricht ein: "Chat-Nachricht wird nicht angezeigt wenn..."
8. Optional: Gibt E-Mail ein für Rückmeldung
9. Tippt auf "Senden"
10. E-Mail-Client öffnet mit vorausgefüllter E-Mail
    - An: aurora@3ofus.de
    - Betreff: [Bug] Aurora Feedback
    - Body: "Kategorie: Bug Report\n\nNachricht:\nChat-Nachricht wird nicht angezeigt wenn...\n\nAntwort an: user@example.com"
11. Nutzer sendet E-Mail im Client
12. Bottom Sheet schließt
13. SnackBar: "E-Mail-Client geöffnet. Danke für dein Feedback!"
```

### Flow 2: Discord beitreten

```
1. Nutzer öffnet Chamäleon-Bottom-Sheet
2. Wechselt zu Tab "Kontaktmöglichkeiten"
3. Sieht 4 Optionen: Discord, Website, E-Mail, GitHub
4. Tippt auf "Discord Server"
5. Browser/Discord-App öffnet mit Invite-Link
6. Nutzer tritt Server bei
7. Sieht #aurora-feedback Kanal
```

### Flow 3: Feature Request ohne E-Mail

```
1. Chamäleon-FAB → Bottom Sheet
2. Tab "Feedback senden" (Standard)
3. Kategorie: ✨ Feature Request
4. Nachricht: "Wäre cool wenn es eine Export-Funktion gäbe"
5. E-Mail-Feld leer lassen
6. "Senden" → E-Mail-Client öffnet
7. Betreff: [Feature] Aurora Feedback
8. Nutzer sendet ohne E-Mail-Adresse
```

---

## 12. Anhang: Code-Snippets

### A. URL Launcher Helper

```dart
// lib/utils/url_launcher_helper.dart
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class UrlLauncherHelper {
  static Future<bool> launchExternalUrl(
    BuildContext context,
    String urlString, {
    bool showErrorSnackBar = true,
  }) async {
    final url = Uri.parse(urlString);

    if (await canLaunchUrl(url)) {
      final success = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      return success;
    } else {
      if (showErrorSnackBar && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Link konnte nicht geöffnet werden: $urlString'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  static Future<bool> sendEmail({
    required String to,
    String? subject,
    String? body,
    BuildContext? context,
  }) async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: to,
      queryParameters: {
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      },
    );

    return launchExternalUrl(
      context!,
      emailUri.toString(),
      showErrorSnackBar: context != null,
    );
  }
}
```

### B. Animated Scale Button

```dart
// Wiederverwendbarer Button mit Tap-Animation
class AnimatedScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const AnimatedScaleButton({
    required this.child,
    required this.onPressed,
    super.key,
  });

  @override
  State<AnimatedScaleButton> createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<AnimatedScaleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
```

### C. Theme-Aware Colors

```dart
// Extension für Theme-basierte Farben
extension ContactDeveloperTheme on BuildContext {
  Color get chamäleonColor => const Color(0xFF9D84B7); // Aurora Lila

  Color get feedbackFormFocusColor =>
      Theme.of(this).brightness == Brightness.dark
          ? const Color(0xFFE8A0BF) // Rosa für Dark Mode
          : const Color(0xFF9D84B7); // Lila für Light Mode

  Color get contactCardColor =>
      Theme.of(this).colorScheme.surfaceVariant;
}
```

---

## 13. Zusammenfassung

### Was wird implementiert?
Ein globaler, animierter Chamäleon-Floating-Action-Button, der Nutzern ermöglicht:
1. **Strukturiertes Feedback** zu senden (Bug, Feature, Allgemein)
2. **Discord-Community** beizutreten
3. **Website** zu besuchen
4. **Direkten E-Mail-Kontakt** aufzunehmen
5. **GitHub Issues** zu erstellen (optional)

### Warum wichtig?
- Aurora ist in **Open Beta** und braucht Nutzer-Feedback
- **Community Building** via Discord
- **Transparenz** und direkte Kommunikation mit Entwicklern (3ofus Team)
- **Strukturierte Bug-Reports** sammeln

### Technische Highlights:
- ✅ Globaler FAB mit subtiler Puls-Animation
- ✅ Tabbed Bottom Sheet (Formular + Kontakte)
- ✅ Formular-Validierung (10+ Zeichen, E-Mail-Format)
- ✅ URL Launcher Integration (Discord, Website, E-Mail, GitHub)
- ✅ Privacy-First (kein Auto-Tracking, Nutzer-Kontrolle)
- ✅ Accessibility (Screen Reader, WCAG-konform)
- ✅ Dark Mode Support

### Nächste Schritte:
1. ✅ **Dokumentation erstellt** (dieses Dokument)
2. ⏳ **Assets sammeln** (Chamäleon-Logo, Kontakt-URLs)
3. ⏳ **Implementierung** auf Hauptrechner (1-2 Tage)
4. ⏳ **Testing** (alle Flows durchgehen)
5. ⏳ **Release** in nächster Aurora-Version (3.0.7+?)

---

**Autor**: Claude (3ofus Team)
**Erstellt**: 2025-11-02
**Für**: Aurora DIS Support App
**Status**: Bereit zur Implementierung 🚀
