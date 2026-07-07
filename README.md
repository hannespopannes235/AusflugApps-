# SpotterDex

Native iOS-App für Planespotter – Flugzeugtypen nachschlagen, vergleichen, lernen und per Foto erkennen.

## Anforderungen

| Tool | Version |
|------|---------|
| Xcode | 15.3+ |
| iOS Deployment Target | 17.0+ |
| Swift | 5.9+ |

## Projekt öffnen

```bash
open SpotterDex/SpotterDex.xcodeproj
```

## Architektur

```
SpotterDex/
├── SpotterDex/
│   ├── Features/       # Feature-Module (AircraftList, Detail, Recognition, …)
│   ├── Shared/         # Wiederverwendbare UI-Komponenten & Utilities
│   ├── Resources/      # Lokalisierung, Fonts, sonstige Assets
│   ├── Data/           # SwiftData-Modelle & Repositories
│   └── ML/             # Core ML-Modelle & Inferenz-Code
└── SpotterDexTests/    # XCTest Unit-Tests
```

## Entwicklungsstrategie

Phasen werden strikt nacheinander abgenommen (siehe CLAUDE.md):

| Phase | Inhalt |
|-------|--------|
| 0 | Setup & Projektstruktur (diese Phase) |
| 1 | Datenmodell Aircraft + SwiftData |
| 2 | AircraftList-Feature (LazyVStack, Suche, Filter) |
| 3 | Detail-Ansicht (Maße, Vergleich, Merkmale) |
| 4 | Foto-Erkennung via Core ML |
| 5 | Lernmodus & Favoriten mit iCloud-Sync |

## Lizenz

Projektinterne Nutzung. Bilddaten erfordern separate Lizenzangabe je Asset.
