# ML-Bundle-Ordner

Hier gehört das trainierte Modell **`SpotterDexClassifier.mlpackage`** hinein.

Es wird **nicht** ins Git-Repo eingecheckt (siehe `.gitignore`), sondern lokal
mit der Pipeline unter `ml/` erzeugt:

```bash
cd ml
python3 build_dataset.py --per-class 150   # CC-lizenzierte Trainingsbilder
swift train_classifier.swift               # → SpotterDexClassifier.mlpackage
```

Anschließend das `.mlpackage` in diesen Ordner ziehen und in Xcode zur
**Target-Membership** von „SpotterDex" hinzufügen. Der `SpotViewModel` lädt es
dann automatisch; bis dahin läuft der App-Spotter im Mock-Modus.

Vollständige Anleitung: `ml/README.md` im Repo-Root.
