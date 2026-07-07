## Projekt: SpotterDex (iOS App für Planespotter)
Zweck: Flugzeugtypen nachschlagen, vergleichen, lernen, per Foto erkennen. Offline-first.
Zielgruppe: Enthusiasten/Planespotter (fachlich vorgebildet).

### Tech (verbindlich)
- Swift, SwiftUI, iOS 17+
- Architektur: MVVM + modular (Feature-Module)
- Persistenz: SwiftData, OFFLINE-FIRST
- ML: Core ML on-device
- Optional iCloud-Sync für Favoriten/Lernfortschritt
- Accessibility Pflicht: VoiceOver, Dynamic Type
- Performance: große Listen via LazyVStack

### Arbeitsregeln
- Phasen STRIKT nacheinander. Keine neue Phase ohne bestätigte Checkliste.
- Bereits abgenommene Strukturen nicht ohne Hinweis ändern.
- Annahmen offenlegen. Bei Unklarheit nachfragen statt raten.
- Pro Phase: lauffähiger, kommentierter Code + kurze Erklärung + 1 Commit.

### Datenmodell "Aircraft" (Referenz)
Hersteller, Familie, Variante, ICAO/IATA-Code, Erstflug, Status,
Maße (Spannweite/Länge/Höhe), MTOW, Reichweite, Pax-Kapazität,
Triebwerk-Typ/-Anzahl, Reisegeschwindigkeit, visuelle Erkennungsmerkmale,
typische Verwechslungspartner, Bild + Lizenzangabe.
