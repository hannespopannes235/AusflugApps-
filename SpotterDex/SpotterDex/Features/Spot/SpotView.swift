import SwiftUI
import PhotosUI
import SwiftData

struct SpotView: View {
    @State private var viewModel       = SpotViewModel()
    @State private var selectedItem:   PhotosPickerItem?
    @State private var showCamera      = false
    @State private var showLibraryPicker = false

    @Query private var allAircraft: [Aircraft]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Gewähltes Bild
                if let img = viewModel.selectedImage {
                    imagePreview(img)
                }

                // Entwicklungsmodus-Banner
                if viewModel.isMockMode {
                    mockModeBanner
                }

                // Zustandsabhängige Inhalte
                switch viewModel.state {
                case .idle:
                    captureButtons
                    mlPipelineCard
                case .processing:
                    processingView
                case .results(let results):
                    resultsView(results)
                    retryRow
                case .noAircraftDetected:
                    noAircraftView
                    retryRow
                case .modelUnavailable:
                    modelUnavailableView
                    captureButtons
                case .error(let msg):
                    errorView(msg)
                    retryRow
                }
            }
            .padding()
        }
        .navigationTitle("Spotten")
        .navigationBarTitleDisplayMode(.large)
        // Kamera-Sheet
        .sheet(isPresented: $showCamera) {
            CameraView(sourceType: .camera) { image in
                Task { await viewModel.classify(image: image, aircraft: allAircraft) }
            }
        }
        // Galerie via PhotosPicker
        .photosPicker(
            isPresented: $showLibraryPicker,
            selection: $selectedItem,
            matching: .images
        )
        .onChange(of: selectedItem) { _, newItem in
            guard let item = newItem else { return }
            Task {
                defer { selectedItem = nil }
                guard let data = try? await item.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) else { return }
                await viewModel.classify(image: image, aircraft: allAircraft)
            }
        }
    }

    // MARK: – Bild-Vorschau

    private func imagePreview(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .accessibilityLabel("Gewähltes Foto")
    }

    // MARK: – Entwicklungsmodus-Banner

    private var mockModeBanner: some View {
        Label("Entwicklungsmodus – kein Modell geladen", systemImage: "exclamationmark.triangle.fill")
            .font(.caption)
            .foregroundStyle(.orange)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.orange.opacity(0.12), in: Capsule())
            .accessibilityLabel("Hinweis: Entwicklungsmodus aktiv, Ergebnisse sind simuliert")
    }

    // MARK: – Aufnahme-Buttons

    private var captureButtons: some View {
        HStack(spacing: 12) {
            // Kamera
            Button {
                showCamera = true
            } label: {
                Label("Kamera", systemImage: "camera.fill")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.tint, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
            }
            .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
            .buttonStyle(.plain)

            // Bibliothek
            Button {
                showLibraryPicker = true
            } label: {
                Label("Bibliothek", systemImage: "photo.fill.on.rectangle.fill")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.secondary.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.primary)
            }
            .buttonStyle(.plain)
        }
        .font(.subheadline.bold())
    }

    // MARK: – Verarbeitung

    private var processingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.4)
            Text("Wird analysiert…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .accessibilityLabel("Bild wird analysiert")
    }

    // MARK: – Ergebnisse

    private func resultsView(_ results: [ClassificationResult]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top-Treffer prominent
            if let top = results.first {
                topResultCard(top)
            }
            // Weitere Treffer
            if results.count > 1 {
                SectionHeader(title: "Weitere Treffer", systemImage: "list.number")
                VStack(spacing: 8) {
                    ForEach(results.dropFirst()) { result in
                        confidenceRow(result)
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func topResultCard(_ result: ClassificationResult) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Konfidenz-Label
            HStack {
                Circle()
                    .fill(levelColor(result.level))
                    .frame(width: 8, height: 8)
                Text(levelLabel(result.level))
                    .font(.caption.bold())
                    .foregroundStyle(levelColor(result.level))
                Spacer()
                Text("\(result.confidencePercent) %")
                    .font(.caption.monospacedDigit().bold())
                    .foregroundStyle(levelColor(result.level))
            }

            // Typ-Name + Detailseiten-Link
            if let aircraft = result.aircraft {
                NavigationLink {
                    AircraftDetailView(aircraft: aircraft)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(aircraft.variant)
                                .font(.title3.bold())
                                .foregroundStyle(.primary)
                            Text("\(aircraft.manufacturer) · \(aircraft.icaoCode)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.tertiary)
                    }
                }
                .buttonStyle(.plain)
            } else {
                Text(result.displayName)
                    .font(.title3.bold())
                Text("(nicht in Datenbank)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            // Konfidenz-Balken
            confidenceBar(result.confidence, color: levelColor(result.level))

            // Niedrige Konfidenz-Warnung
            if result.level == .low {
                Label("Niedrige Konfidenz – Ergebnis unsicher", systemImage: "exclamationmark.circle")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(result.displayName), \(result.confidencePercent) % Konfidenz, " +
            levelLabel(result.level)
        )
    }

    private func confidenceRow(_ result: ClassificationResult) -> some View {
        HStack(spacing: 10) {
            if let aircraft = result.aircraft {
                NavigationLink {
                    AircraftDetailView(aircraft: aircraft)
                } label: {
                    HStack {
                        Text(aircraft.icaoCode)
                            .font(.caption.monospaced())
                            .foregroundStyle(.tint)
                            .frame(width: 44, alignment: .leading)
                        Text(result.displayName)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        Spacer()
                        confidenceBar(result.confidence, color: levelColor(result.level))
                            .frame(width: 80)
                        Text("\(result.confidencePercent) %")
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                            .frame(width: 36, alignment: .trailing)
                    }
                }
                .buttonStyle(.plain)
            } else {
                Text(result.icaoLabel)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .frame(width: 44, alignment: .leading)
                Text(result.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(result.confidencePercent) %")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(result.displayName), \(result.confidencePercent) %")
    }

    // MARK: – Konfidenz-Balken

    private func confidenceBar(_ confidence: Float, color: Color) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(color.opacity(0.15))
                RoundedRectangle(cornerRadius: 3)
                    .fill(color)
                    .frame(width: geo.size.width * CGFloat(confidence))
            }
        }
        .frame(height: 6)
        .accessibilityHidden(true)
    }

    // MARK: – Fehlerzustände

    private var noAircraftView: some View {
        ContentUnavailableView(
            "Kein Flugzeug erkannt",
            systemImage: "airplane.slash",
            description: Text(
                "Das Modell konnte keinen Flugzeugtyp sicher identifizieren.\n" +
                "Tipps: Gutes Licht, ganzes Flugzeug im Bild, Perspektive von der Seite."
            )
        )
    }

    private var modelUnavailableView: some View {
        VStack(spacing: 10) {
            Image(systemName: "cpu.fill")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("Kein Modell geladen")
                .font(.headline)
            Text("Modell mit der Pipeline in ml/ erzeugen (build_dataset.py → train_classifier.swift) und SpotterDexClassifier.mlpackage in den ML/-Ordner legen. Siehe ml/README.md.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .combine)
    }

    private func errorView(_ message: String) -> some View {
        ContentUnavailableView(
            "Fehler",
            systemImage: "xmark.circle",
            description: Text(message)
        )
    }

    // MARK: – Retry

    private var retryRow: some View {
        Button {
            viewModel.reset()
        } label: {
            Label("Neues Foto aufnehmen", systemImage: "arrow.counterclockwise")
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    // MARK: – ML-Pipeline-Info (Idle-Zustand)

    private var mlPipelineCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "ML-Pipeline", systemImage: "cpu")
            VStack(alignment: .leading, spacing: 8) {
                pipelineStep("1. Datensatz", detail: "ml/build_dataset.py – lädt CC-lizenzierte Commons-Fotos je ICAO-Typ, protokolliert jede Lizenz")
                Divider()
                pipelineStep("2. Training",  detail: "swift ml/train_classifier.swift – Create ML → SpotterDexClassifier.mlpackage")
                Divider()
                pipelineStep("3. Einbinden", detail: "mlpackage in ML/-Ordner ziehen, Target-Membership setzen → App neu bauen")
                Divider()
                pipelineStep("4. Bildrechte", detail: "Nur freie Lizenzen; Attribution-Belege in ml/dataset/credits.csv. Details: ml/README.md")
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
            Divider()
        }
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func pipelineStep(_ title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(.primary)
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(detail)")
    }

    // MARK: – Helpers

    private func levelColor(_ level: ClassificationResult.ConfidenceLevel) -> Color {
        switch level {
        case .high:   return .green
        case .medium: return .orange
        case .low:    return .red
        }
    }

    private func levelLabel(_ level: ClassificationResult.ConfidenceLevel) -> String {
        switch level {
        case .high:   return "Hohe Konfidenz"
        case .medium: return "Mittlere Konfidenz"
        case .low:    return "Niedrige Konfidenz"
        }
    }
}

#Preview {
    NavigationStack { SpotView() }
        .modelContainer(for: Aircraft.self, inMemory: true)
}
