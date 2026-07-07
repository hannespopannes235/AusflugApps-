#!/usr/bin/env swift
//
// SpotterDex – Core-ML-Bildklassifikator trainieren
// ==================================================
//
// Trainiert mit Apples CreateML-Framework einen Image Classifier aus dem von
// build_dataset.py erzeugten `dataset/`-Ordner (Unterordner = ICAO-Labels) und
// exportiert genau das Modell, das die App erwartet:
//
//     SpotterDexClassifier.mlpackage
//
// AUSFÜHREN (nur macOS – CreateML ist macOS-only):
//     swift train_classifier.swift
//   oder mit Optionen:
//     swift train_classifier.swift --data ./dataset --out ./SpotterDexClassifier.mlpackage
//
// Danach das .mlpackage nach SpotterDex/SpotterDex/ML/ ziehen (siehe README.md).
// Das Modell wird vom SpotViewModel automatisch geladen – kein Code-Change nötig.

import Foundation
#if canImport(CreateML)
import CreateML

// MARK: – Argumente

func arg(_ name: String, default def: String) -> String {
    let a = CommandLine.arguments
    if let i = a.firstIndex(of: name), i + 1 < a.count { return a[i + 1] }
    return def
}

let dataPath = arg("--data", default: "./dataset")
let outPath  = arg("--out",  default: "./SpotterDexClassifier.mlpackage")

let dataURL = URL(fileURLWithPath: dataPath, isDirectory: true)
let outURL  = URL(fileURLWithPath: outPath)

guard FileManager.default.fileExists(atPath: dataURL.path) else {
    print("❌ Datensatz nicht gefunden: \(dataURL.path)")
    print("   Zuerst 'python3 build_dataset.py' ausführen.")
    exit(1)
}

print("📂 Datensatz:  \(dataURL.path)")
print("📦 Ausgabe:    \(outURL.path)")
print("🛠  Training startet … (das kann je nach Datenmenge einige Minuten dauern)\n")

do {
    // Datenquelle: Ordner mit ICAO-benannten Unterordnern.
    let source = MLImageClassifier.DataSource.labeledDirectories(at: dataURL)

    // Augmentations machen das Modell robuster gegen Perspektive/Licht/Rauschen –
    // wichtig bei realen Spotter-Fotos (verschiedene Winkel, Wetter, Lackierungen).
    var params = MLImageClassifier.ModelParameters(
        validation: .split(strategy: .automatic),
        maxIterations: 25,
        augmentation: [.flip, .rotation, .blur, .noise, .exposure]
    )

    let classifier = try MLImageClassifier(trainingData: source, parameters: params)

    // Validierungs-Genauigkeit ausgeben.
    let validationAccuracy = (1.0 - classifier.validationMetrics.classificationError) * 100
    let trainingAccuracy   = (1.0 - classifier.trainingMetrics.classificationError) * 100
    print(String(format: "\n✅ Training fertig. Trainings-Accuracy: %.1f %%, Validierungs-Accuracy: %.1f %%",
                 trainingAccuracy, validationAccuracy))
    if validationAccuracy < 70 {
        print("⚠️  Validierungs-Accuracy < 70 %. Mehr/diversere Bilder pro Typ verbessern das Ergebnis.")
    }

    // Export als .mlpackage mit Metadaten (Bildrechte-Hinweis inklusive).
    let metadata = MLModelMetadata(
        author: "SpotterDex",
        shortDescription: "Flugzeugtyp-Klassifikator (ICAO-Codes). Trainiert auf CC-lizenzierten Wikimedia-Commons-Fotos – Attribution in dataset/credits.csv.",
        version: "1.0"
    )
    try classifier.write(to: outURL, metadata: metadata)
    print("\n📦 Exportiert nach: \(outURL.path)")
    print("Nächster Schritt: .mlpackage nach SpotterDex/SpotterDex/ML/ ziehen (siehe README.md).")
} catch {
    print("❌ Training fehlgeschlagen: \(error)")
    exit(1)
}

#else
print("❌ CreateML ist nicht verfügbar. Dieses Skript läuft nur auf macOS.")
exit(1)
#endif
