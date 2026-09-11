# Athlete's Mindful Companion

Ein interaktiver und dauerhafter mentaler Begleiter für Einzelsportler (Golf, Tennis u. a.), umgesetzt als Offline-First Flutter-App. Die App fokussiert auf **Gefühle, Trigger und Reflexion** statt auf Leistungsstatistiken und ersetzt einen menschlichen Mentalcoach durch einen stringenter, empathischer LLM-Dialogpartner.

## Konzeptumsetzung

- **Leistungszyklus (4 Phasen):** Vorbereitung → Durchführung → Reflexion → Transfer & Impuls (Closed-Loop).
- **Gefühle sichern:** Nuancierte Eindrücke über Slider, Chips und Sprachnotizen erfassen.
- **Micro-Insights:** Sofortige Rückmeldung nach jeder Eingabe; am Ende einer Reflexion eine optisch hervorgehobene Insight-Karte mit zentralem Trainingsimpuls.
- **Brücken-Strategie:** Der Impuls aus einer Reflexion wird zum Fokus der nächsten Einheit; lokale Erinnerungen (Pre-/Post-Session) schlagen die Brücke.
- **Langfristige Entwicklung:** Mentale Trends (z. B. „Gelassenheit steigt“) statt Ergebnisstatistiken.
- **Gedächtnis-Archiv:** Muster-Erkennung wiederkehrender Trigger, offene/trainierte Schlüsselmomente, Erfolgszimmer.
- **Intelligentes Schweigen:** Notifications lassen sich pausieren (Cancel-All).
- **Sportarten-agnostisch:** Golf, Tennis, Laufen, Allgemein wählbar.

## Architektur (Clean Architecture / Offline-First)

```
lib/
├── core/theme/                 Calm-UI Theme (Sage/Sand/Ink)
├── data/
│   ├── database/json_store.dart        Lokaler JSON-File-Store (Offline-First)
│   ├── repositories/session_repository.dart
│   └── services/                       Mistral-Engine, Mock-Engine, SecureStorage,
│                                        NotificationEngine, SpeechToText
├── domain/
│   ├── entities/models.dart            Session, KeyMoment, MentalTrend, ChatMessage
│   ├── services/                       ContextAssembler, LlmEngine, TrendAnalyzer
│   └── usecases/                       StartSession, UpdateSession, CompleteSession,
│                                        AddKeyMoment, ExportData
└── presentation/
    ├── providers/                      Riverpod Notifier (ActiveSession, MentalJourney, Archive)
    ├── screens/                        Dashboard, PreSession (Wizard), Coach (Chat),
    │                                   Archive, Settings
    └── widgets/                        EnergyBarometer, EmotionChips, InsightCard,
                                        TrendBar, ChatBubble, VoiceRecorderButton
```

- **State Management:** Riverpod (`flutter_riverpod`).
- **Datenhaltung:** Lokaler JSON-Store via `path_provider`; keine Backend-Abhängigkeit.
- **LLM:** Mistral-API (`mistral-small-latest`), konfigurierbarer Schlüssel in den Einstellungen (Secure Storage). Ohne Schlüssel läuft die App mit der Regel-basierten Mock-Engine (Offline-Fallback).
- **System-Prompt:** `assets/prompts/system_prompt.txt` (wertfrei, sportbezogen, fragend, Closed-Loop).

## Setup

```bash
flutter pub get
flutter run
```

Optional LLM aktivieren: in der App unter *Einstellungen* einen Mistral-API-Schlüssel hinterlegen.

## Tests

```bash
flutter test
```

Tests decken die `TrendAnalyzer`- und `PatternDetector`-Logik ab (Aggregation, Muster-Erkennung, Offen/Trainiert/Highlight-Splits).

## Datenschutz

Alle Daten verbleiben lokal. Bei Nutzung der LLM-API werden nur anonymisierte Transkripte gesendet.
