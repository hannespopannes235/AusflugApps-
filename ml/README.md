# SpotterDex – Core-ML-Trainings-Pipeline

Diese Pipeline erzeugt das Modell `SpotterDexClassifier.mlpackage`, das der
`SpotView`/`SpotViewModel` der App für die On-Device-Foto-Erkennung lädt.

> **Warum nicht schon im Repo?** Ein Bildklassifikator braucht einen großen
> Foto-Datensatz und Apples **Create ML** (nur macOS). Beides ist in der
> Cloud-/CI-Umgebung nicht verfügbar. Stattdessen liefert dieser Ordner eine
> **reproduzierbare, rechtlich saubere Pipeline**, die du lokal auf deinem Mac
> ausführst. Das Ergebnis ist ein einziges `.mlpackage`.

## Architektur-Hintergrund

Die App ist bereits vollständig vorbereitet:

- `SpotViewModel` sucht beim Start `SpotterDexClassifier.mlmodelc`/`.mlpackage`
  im Bundle. Fehlt es → **Mock-Modus** (simulierte Ergebnisse, sichtbar
  durch ein oranges Banner). Sobald das Modell vorhanden ist, läuft echte
  Vision-Inferenz – **kein Code-Change nötig**.
- Der Modell-Output ist der **ICAO-Code** (z. B. `A20N`). `SpotViewModel`
  verknüpft ihn 1:1 mit der SwiftData-DB → Treffer verlinkt direkt auf die
  Detailseite. Deshalb **müssen die Klassen-Labels exakt die ICAO-Codes aus
  `aircraft_seed_v1.json` sein** (siehe `aircraft_classes.json`).

## Schritte

### 0. Voraussetzungen
- macOS mit Xcode (für `swift` + CreateML-Framework)
- Python 3.9+ : `pip install requests`

### 1. Datensatz bauen (rechtlich sauber)

```bash
cd ml
python3 build_dataset.py --per-class 150
```

- Lädt pro Typ bis zu 150 Fotos aus der passenden Wikimedia-Commons-Kategorie.
- **Nur freie Lizenzen** (CC0, CC BY, CC BY-SA, Public Domain) werden
  übernommen; NC/ND wird verworfen.
- Schreibt `dataset/credits.csv` + `credits.json` mit Urheber, Lizenz,
  Lizenz-URL und Quellseite **für jedes Bild** → Attribution jederzeit belegbar.

Ergebnis-Layout (Create-ML-konform):

```
dataset/
  A20N/  A20N_0000.jpg …
  B738/  B738_0000.jpg …
  …
  credits.csv
  credits.json
```

> **Qualität prüfen:** In der Zusammenfassung markiert das Skript Typen mit
> < 50 Bildern. Bei zu wenig Daten die Commons-Kategorie in
> `aircraft_classes.json` anpassen oder eigene (CC-lizenzierte oder selbst
> fotografierte) Bilder in den jeweiligen Ordner legen.

### 2. Modell trainieren

```bash
swift train_classifier.swift
```

- Trainiert einen `MLImageClassifier` mit Augmentations (Flip/Rotation/Blur/
  Noise/Exposure → robuster gegen reale Spotter-Bedingungen).
- Gibt Trainings- und Validierungs-Accuracy aus.
- Exportiert `SpotterDexClassifier.mlpackage`.

*(Alternativ: Create-ML-App öffnen → „Image Classifier" → `dataset/`-Ordner
ziehen → trainieren → als `SpotterDexClassifier.mlpackage` exportieren.)*

### 3. In die App einbinden

1. `SpotterDexClassifier.mlpackage` nach `SpotterDex/SpotterDex/ML/` ziehen.
2. In Xcode: Datei zum Target **SpotterDex** hinzufügen (Häkchen bei
   „Target Membership"). Xcode kompiliert das Modell automatisch beim Build.
3. App neu bauen → das orange „Entwicklungsmodus"-Banner verschwindet, echte
   Erkennung ist aktiv.

### 4. Bildrechte in der App (optional, empfohlen)

`dataset/credits.csv` dokumentiert die **Trainingsbilder**. Für in der App
angezeigte Fotos nutzt SpotterDex bereits den Live-Abruf der Commons-Attribution
(`WikimediaPhotoService`). Die Trainings-Credits gehören nicht ins App-Bundle,
sollten aber als Lizenz-Nachweis aufbewahrt werden (z. B. im Repo unter `ml/`).

## Konfidenz-Schwellen (in `SpotViewModel`)

| Konfidenz | Anzeige            |
|-----------|--------------------|
| ≥ 0.70    | hoch (grün)        |
| ≥ 0.40    | mittel (orange)    |
| < 0.15    | „Kein Flugzeug erkannt" |

Anpassbar in `classifyWithVision` / `ClassificationResult.level`.
