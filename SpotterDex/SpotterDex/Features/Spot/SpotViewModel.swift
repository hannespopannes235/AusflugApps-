import Foundation
import CoreML
import Vision
import UIKit
import Observation

// MARK: – State

enum SpotState {
    case idle
    case processing
    case results([ClassificationResult])
    case noAircraftDetected
    case modelUnavailable        // Modell noch nicht trainiert / nicht im Bundle
    case error(String)
}

// MARK: – ViewModel

/// Kapselt die Core-ML-Inferenz.
///
/// ## ML-Pipeline (Übersicht)
///
/// **1. Datensatz**
/// - Ca. 100–500 Bilder pro Klasse; Klassen-Label = ICAO-Code (z. B. "A20N")
/// - Diverse Perspektiven (Seitenansicht, Landeansicht, Draufsicht)
/// - Unterschiedliche Lichtverhältnisse, Airports, Lackierungen
/// - Nur Bilder mit CC-BY / CC-BY-SA-Lizenz oder eigene Aufnahmen nutzen
///   (Quelle belegen; imageLicense-Feld im Aircraft-Modell nutzen)
///
/// **2. Training mit Create ML**
/// 1. Create ML App öffnen → "New Document" → "Image Classifier"
/// 2. Trainings-Ordner wählen (Unterordner = ICAO-Labels)
/// 3. Augmentations aktivieren (Flip, Rotation, Blur, Noise)
/// 4. Training starten → nach Abschluss als "SpotterDexClassifier.mlpackage" exportieren
///
/// **3. Integration in Xcode**
/// 1. SpotterDexClassifier.mlpackage in den ML/-Ordner des Projekts ziehen
/// 2. In project.pbxproj als PBXFileReference + PBXBuildFile registrieren
///    (oder direkt in Xcode hineinziehen)
/// 3. App neu bauen – dieser ViewModel findet das Modell automatisch
///
/// **4. Konfidenz-Schwellen** (in classifyWithVision konfigurierbar)
/// - ≥ 0.70 → hohe Konfidenz (grün)
/// - ≥ 0.40 → mittlere Konfidenz (orange)
/// - < 0.15 gesamt → "Kein Flugzeug erkannt"-Fallback

@Observable
final class SpotViewModel {
    var state: SpotState = .idle
    var selectedImage: UIImage?
    var isMockMode: Bool = false     // true solange kein echtes Modell im Bundle

    private var vnModel: VNCoreMLModel?

    init() { loadModel() }

    // MARK: – Model Loading

    private func loadModel() {
        // Sucht SpotterDexClassifier.mlmodelc (kompilierte Form) oder .mlpackage im Bundle.
        let urls = [
            Bundle.main.url(forResource: "SpotterDexClassifier", withExtension: "mlmodelc"),
            Bundle.main.url(forResource: "SpotterDexClassifier", withExtension: "mlpackage"),
        ]
        for case let url? in urls {
            if let mlModel = try? MLModel(contentsOf: url),
               let model   = try? VNCoreMLModel(for: mlModel) {
                vnModel    = model
                isMockMode = false
                return
            }
        }
        isMockMode = true   // Entwicklungsmodus – Mock-Ergebnisse aktiv
    }

    // MARK: – Classification Entry Point

    /// Klassifiziert ein Bild. Muss aus einem @MainActor-Kontext gerufen werden
    /// (z. B. SwiftUI-Task), damit State-Updates thread-sicher sind.
    func classify(image: UIImage, aircraft: [Aircraft]) async {
        await MainActor.run {
            selectedImage = image
            state = .processing
        }

        if isMockMode {
            await classifyMock(aircraft: aircraft)
        } else if let model = vnModel {
            await classifyWithVision(image: image, model: model, aircraft: aircraft)
        } else {
            await MainActor.run { state = .modelUnavailable }
        }
    }

    func reset() {
        selectedImage = nil
        state = .idle
    }

    // MARK: – Vision / Core ML

    private func classifyWithVision(
        image: UIImage,
        model: VNCoreMLModel,
        aircraft: [Aircraft]
    ) async {
        // Vision-Arbeit auf Background-Thread auslagern (VNImageRequestHandler.perform ist blockierend).
        let observations: [VNClassificationObservation] = await Task.detached(priority: .userInitiated) {
            guard let cgImage = image.cgImage else { return [] }
            let request = VNCoreMLRequest(model: model)
            request.imageCropAndScaleOption = .centerCrop
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
            return (request.results as? [VNClassificationObservation]) ?? []
        }.value

        let top3 = observations.prefix(3).filter { $0.confidence > 0.05 }

        await MainActor.run {
            guard let topConf = top3.first?.confidence, topConf >= 0.15 else {
                state = .noAircraftDetected
                return
            }
            let results = top3.map { obs in
                ClassificationResult(
                    aircraft: aircraft.first { $0.icaoCode == obs.identifier },
                    icaoLabel: obs.identifier,
                    confidence: obs.confidence
                )
            }
            state = .results(Array(results))
        }
    }

    // MARK: – Entwicklungs-Mock

    /// Gibt plausibel verteilte Ergebnisse zurück, solange kein echtes Modell vorhanden ist.
    private func classifyMock(aircraft: [Aircraft]) async {
        guard !aircraft.isEmpty else {
            await MainActor.run { state = .noAircraftDetected }
            return
        }
        try? await Task.sleep(for: .milliseconds(900))
        let pool  = aircraft.shuffled().prefix(3)
        let confs: [Float] = [0.78, 0.15, 0.07]
        let results = zip(pool, confs).map { a, c in
            ClassificationResult(aircraft: a, icaoLabel: a.icaoCode, confidence: c)
        }
        await MainActor.run { state = .results(Array(results)) }
    }
}
