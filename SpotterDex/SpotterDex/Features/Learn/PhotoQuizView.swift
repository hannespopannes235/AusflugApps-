import SwiftUI
import SwiftData

/// Modus „Foto": Flugzeugtyp anhand eines echten Wikimedia-Commons-Fotos erraten.
///
/// Warum Foto statt Silhouette? Die generische Draufsicht-Silhouette kodiert nur
/// Spannweite × Länge – Schmalrumpf-Muster (A320 / 737 / A220) sind darin nahezu
/// deckungsgleich. Ein echtes Foto zeigt die tatsächlichen Erkennungsmerkmale
/// (Triebwerksform, Nase, Winglets, Heck) und macht die Aufgabe sinnvoll.
///
/// Offline-Verhalten: Lädt das Foto nicht (kein Netz), wird automatisch die
/// neutrale Silhouette als Fallback gezeigt – die Runde bleibt spielbar.
struct PhotoQuizView: View {
    let aircraft: [Aircraft]
    let viewModel: LearnViewModel

    @Environment(\.modelContext) private var modelContext
    @Query private var allRecords: [LearningRecord]

    @State private var target:   Aircraft?
    @State private var choices:  [Aircraft] = []
    @State private var selected: Aircraft?
    @State private var showResult = false
    @State private var credit: WikimediaPhotoService.PhotoCredit?

    private let mode = LearnMode.photo

    var body: some View {
        VStack(spacing: 0) {
            sessionBar
            Divider()
            if let target {
                ScrollView {
                    VStack(spacing: 24) {
                        photoCard(target)
                        choiceGrid(target)
                        if showResult { resultBanner(target) }
                    }
                    .padding()
                }
            } else {
                ContentUnavailableView(
                    "Nicht genug Typen",
                    systemImage: "photo",
                    description: Text("Mindestens 4 Flugzeuge werden benötigt.")
                )
            }
        }
        .navigationTitle("Foto")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { nextQuestion() }
    }

    // MARK: – Session Bar

    private var sessionBar: some View {
        HStack {
            Label("\(viewModel.sessionStreak)", systemImage: "flame.fill")
                .font(.subheadline.bold())
                .foregroundStyle(.orange)
            Spacer()
            Text("\(viewModel.sessionCorrect) / \(viewModel.sessionTotal) korrekt")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Streak \(viewModel.sessionStreak), " +
            "\(viewModel.sessionCorrect) von \(viewModel.sessionTotal) korrekt"
        )
    }

    // MARK: – Foto-Karte (mit Silhouetten-Fallback offline)

    private func photoCard(_ a: Aircraft) -> some View {
        VStack(spacing: 0) {
            if let url = WikimediaPhotoService.imageURL(for: a.icaoCode) {
                // CachedRemoteImage statt AsyncImage: einmal geladene Fotos liegen
                // im Disk-Cache → das Foto-Quiz bleibt auch offline spielbar.
                CachedRemoteImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(height: 220)
                        .clipped()
                } placeholder: {
                    Color(.systemGray5)
                        .frame(height: 220)
                        .overlay { ProgressView() }
                } fallback: {   // offline & nicht gecacht → Silhouette
                    silhouetteFallback(a)
                }
            } else {
                silhouetteFallback(a)
            }

            // Bildnachweis: Urheber + Lizenz verraten den Typ nicht und dürfen
            // schon während der Frage stehen. Die Quelle-URL (Dateiname enthält
            // den Typ) erscheint erst NACH der Antwort.
            if let credit {
                HStack(spacing: 4) {
                    Image(systemName: "camera").imageScale(.small).accessibilityHidden(true)
                    Text("© \(credit.artist) · \(credit.license)")
                        .lineLimit(1).truncationMode(.middle)
                    if showResult {
                        Spacer(minLength: 4)
                        Link("Quelle ↗", destination: credit.pageURL)
                            .foregroundStyle(.tint)
                    }
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.regularMaterial)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Foto eines Flugzeugs – Typ raten. Tippe auf eine Antwort.")
    }

    private func silhouetteFallback(_ a: Aircraft) -> some View {
        // Neutrale Farbe: Herstellerfarbe würde die Antwort verraten.
        AircraftSilhouetteView(wingspan: a.wingspan, length: a.length, color: .secondary)
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .background(Color(.systemGray6))
    }

    // MARK: – Antwort-Grid

    private func choiceGrid(_ target: Aircraft) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(choices, id: \.icaoCode) { choice in
                ChoiceButton(
                    label: choice.variant,
                    subtitle: choice.icaoCode,
                    state: buttonState(for: choice, target: target)
                ) {
                    guard !showResult else { return }
                    answer(choice, target: target)
                }
            }
        }
    }

    private func buttonState(for choice: Aircraft, target: Aircraft) -> ChoiceButtonState {
        guard showResult else { return .idle }
        if choice.icaoCode == target.icaoCode    { return .correct }
        if choice.icaoCode == selected?.icaoCode { return .wrong   }
        return .idle
    }

    // MARK: – Ergebnis

    private func resultBanner(_ target: Aircraft) -> some View {
        let correct = selected?.icaoCode == target.icaoCode
        return VStack(spacing: 8) {
            Label(
                correct ? "Richtig!" : "Falsch – es war \(target.variant)",
                systemImage: correct ? "checkmark.circle.fill" : "xmark.circle.fill"
            )
            .font(.headline)
            .foregroundStyle(correct ? .green : .red)
            Text("\(target.manufacturer) \(target.family)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Button("Nächste Frage") { nextQuestion() }
                .buttonStyle(.borderedProminent)
                .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .combine)
    }

    // MARK: – Logik

    private func answer(_ choice: Aircraft, target: Aircraft) {
        selected = choice
        showResult = true
        let correct = choice.icaoCode == target.icaoCode
        viewModel.recordAnswer(correct: correct)
        viewModel.record(for: target, mode: mode, in: allRecords, context: modelContext)
            .recordAnswer(correct: correct)
    }

    private func nextQuestion() {
        guard aircraft.count >= 4 else { target = nil; return }
        selected   = nil
        showResult = false
        credit     = nil
        let t = viewModel.pickAircraft(from: aircraft, records: allRecords, mode: mode)
        target  = t
        guard let t else { return }
        choices = buildChoices(for: t)

        // Bildnachweis live laden (kein hartcodierter Credit).
        Task {
            let c = await WikimediaPhotoService.fetchCredit(for: t.icaoCode)
            await MainActor.run { if target?.icaoCode == t.icaoCode { credit = c } }
        }
    }

    /// Bevorzugt Lookalikes als Distraktoren – beim Foto-Quiz sind diese echten
    /// Verwechslungspartner tatsächlich unterscheidbar (anders als in der Silhouette).
    private func buildChoices(for target: Aircraft) -> [Aircraft] {
        let lookalikes = target.lookalikes
            .compactMap { icao in aircraft.first { $0.icaoCode == icao } }
            .shuffled()
        let others = aircraft
            .filter { $0.icaoCode != target.icaoCode && !target.lookalikes.contains($0.icaoCode) }
            .shuffled()
        let distractors = Array((lookalikes + others).prefix(3))
        return ([target] + distractors).shuffled()
    }
}
