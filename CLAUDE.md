# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Aurora** is a Flutter app for supporting people with Dissociative Identity Disorder (DIS). It provides a secure, private environment for managing different personalities and internal communication.

**Key Principle**: Maximum privacy - all data stored locally, no cloud sync. Nothing leaves the device without explicit consent, everything that does is inspectable, and nothing permits re-identification.

## Architecture

### Data Flow: DataEntry Architecture

**Core Concept**: All data flows through a centralized `DataEntry` class, which provides unified API for read/write operations and handles validation, logging, and event publishing.

```
UI/Modules → DataEntry → EventBus → Services → Hive (Persistence)
                ↓
            Validation
            Logging
            Events
```

**Key Components**:

1. **DataEntry** (`lib/core/data_entry.dart`)
   - Centralized API for all data operations
   - Combines Commands (write) and Queries (read) in one interface
   - Handles validation and logging
   - Publishes events to EventBus

2. **EventBus** (`lib/core/event_bus.dart`)
   - RxDart-based event distribution
   - Services subscribe to relevant events
   - Event types defined in `lib/core/events/`

3. **Services** (`lib/services/`)
   - Business logic and data management
   - Use Hive boxes for persistence
   - Subscribe to events via EventBus
   - Examples: `ProfileService`, `ChatService`, `CalendarService`

4. **Dependency Injection** (`lib/core/di/injection.dart`)
   - GetIt-based DI container
   - All services registered as singletons
   - Initialize Hive boxes during setup

### Profile System & Permissions

**Multi-Profile System**:
- Each profile represents a different personality
- Profiles have individual colors, avatars, and settings
- One profile can be designated as "Admin"

**Role-Based Access Control (RBAC)**:
- Permissions defined in `lib/models/permission.dart`
- Permissions control access to tabs and features
- Examples: `viewChatTab`, `createEvents`, `manageMedication`
- Admin profile has unrestricted access
- Age-based permission defaults in profile creation

**Profile Avatar System**:
- Supports both file paths and asset paths
- File paths: `avatar_123.jpg` (stored in attachments directory)
- Asset paths: `assets/images/Hund.png` (bundled animal avatars)
- `ProfileImageWidget` automatically detects and loads correct type
- `ProfileAvatarPickerBottomSheet` provides unified picker (Camera, Gallery, Animal templates)

### Navigation Architecture

**4-Layer Navigation System** (`lib/main.dart`):
1. **AppBar** - Logo, title, settings button
2. **ProfileSwitcherBar** - Quick profile switching
3. **CarouselTabNavigator** - Carousel-style feature navigation
4. **PageView** - Content area with tab screens

**Permission-Based Tab Filtering**:
- Tabs defined in `_allTabDefinitions` with required permissions
- Chat tab always visible (core functionality)
- Other tabs filtered based on active profile permissions
- Tab visibility updates reactively when profile changes

### Data Persistence

**Technology**: Hive (local NoSQL database)
- Type-safe with generated adapters
- All models in `lib/models/` use `@HiveType` annotations
- Adapters generated via `build_runner`

**Storage Strategy**:
- Profiles, messages, events, medications all persisted
- Attachments (images, audio, video) in separate directory via `AttachmentHelper`
- UTF-16 safe string handling for emoji support

### Attachment System

**AttachmentHelper** (`lib/utils/attachment_helper.dart`):
- Manages files in app documents directory under `attachments/`
- Relative paths stored in database (e.g., `avatar_123.jpg`, `doodle_abc.png`)
- Full paths resolved at runtime via `getAttachmentFile()`
- Supports: avatars, doodles, voice messages, images, videos

**Important**: Always use relative paths in database, never absolute paths.

## Code Patterns & Standards

### UTF-16 Safety
**Critical**: When working with user-generated strings (names, messages), always use `runes` instead of subscript access to avoid UTF-16 crashes with emojis.

```dart
// ❌ WRONG - crashes with emojis
final initial = name[0];

// ✅ CORRECT - UTF-16 safe
final runes = name.runes.toList();
final initial = String.fromCharCode(runes.first);
```

This pattern is used throughout the codebase in profile avatars, chat bubbles, etc.

### Custom Lint Rules

The project includes custom lint rules in `dis_app_lints/`:
- `no_direct_service_access`: UI code must go through `DataEntry`, not `getIt<Service>()`
- `no_direct_gps_access`: location only via the location service, never the plugin
- `no_direct_notification_plugin`: schedule through `ReminderScheduler`
- `no_clock_in_reminder_rules`: reminder rules must not read the clock themselves
- `no_future_in_build`: no `Future` created inside `build()`
- `no_saved_events_listener`: use `ValueListenableBuilder` with `service.box.listenable()`
  instead of listening to `*SavedEvent`
- `no_raw_tracking_flag`: `gps_tracking_enabled` is the *wish* and belongs to
  `LocationTrackingService`. To ask whether recording is running, use
  `isTrackingRunning`

Run with: `dart run custom_lint`

### Logging

Centralized logging via `lib/core/logger.dart`:
```dart
logger.info(LogCategory.service, 'Action description', data: {...});
logger.error(LogCategory.dataEntry, 'Error message', data: {'error': e.toString()});
```

Categories: `ui`, `service`, `dataEntry`, `storage`, `network`

**There is no `error:` parameter.** `logger.error` takes `data` and
`stackTrace` only — pass the exception through `data`. An earlier version of
this file showed `error: e`, which does not compile.

## Key Implementation Details

### Profile Creation/Editing Flow
1. User inputs data in `ProfileIdentitySection`
2. Avatar selected via `ProfileAvatarPickerBottomSheet`
   - Camera/Gallery: Saves file, returns relative path
   - Animal template: Returns asset path directly
3. Form validated and submitted to `DataEntry`
4. `ProfileService` persists to Hive
5. Events published for UI updates

### Password Reset System
Design rules live in `.claude/rules/passwort-reset.md` (auto-loads when
working on password-reset files).

### Message Attachments
- Types: Doodle, Voice, Image, Video
- Stored via `AttachmentHelper`
- Referenced by filename in `ChatMessage` model
- Cleanup via `cleanupOrphanedAttachments()`

## Important Notes

- **Privacy First**: Three rules, no exceptions:
  - Nothing is sent without explicit consent. Feedback is user-triggered, so it needs no opt-in; telemetry is automatic and therefore requires opt-in (GDPR Art. 9 — in a DIS app every data point is health data by context)
  - Everything sent is inspectable in Settings → "Was Aurora sendet", verbatim and stored locally
  - Nothing permits re-identification: no profile IDs, no installation IDs, no session chains, no entry counts
- **Location Never Reaches Us**: Not in feedback, not in telemetry, not rounded, not as a country. Coordinates go to OpenStreetMap for maps and geocoding only (`geocoding_service.dart`, `overview_map.dart`); the emergency feature shares location with contacts the user picks. Location data is not anonymizable — a few coarse place-time points identify a person uniquely. A test asserts the payload schema has no location field
- **No Secrets in the Client**: A compile-time constant that is empty makes the compiler delete the whole code path — silently, invisible at runtime. This shipped once and left the feedback channel dead for eight months (see `docs/superpowers/specs/2026-08-04-feedback-rueckkanal-design.md`). Transport targets are runtime configuration, and CI fails the release build when none is configured
- **Interface Rules**: Before designing any screen, read `docs/oberflaechen-richtlinien.md`. Eleven rules derived from published research (W3C COGA, WCAG 2.2, mHealth colour studies, UK Home Office), each naming its source, plus eight check questions. The two that get broken most often: choice surfaces and content surfaces are not the same thing, and saturated colour is reserved for what has to be found in the worst state
- **Emoji Support**: Always use runes for string operations
- **DataEntry Pattern**: All data operations must go through `DataEntry`
- **Permissions**: Check profile permissions before UI actions
- **Hive Generation**: Run build_runner after model changes
- **Relative Paths**: Use relative paths for all file references in database
