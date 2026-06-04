import SwiftUI
import SwiftData

/// Modus 1: Flugzeugtyp anhand der Draufsicht-Silhouette erraten.
struct SilhouetteQuizView: View {
    let aircraft: [Aircraft]
    let viewModel: LearnViewModel

    @Environment(\.modelContext) private var modelContext
    @Query private var allRecords: [LearningRecord]

    @State private var target:     Aircraft?
    @State private var choices:    [Aircraft] = []
    @State private var selected:   Aircraft?
    @State private var showResult  = false

    private let mode = LearnMode.silhouette

    var body: some View {
        VStack(spacing: 0) {
            sessionBar
            Divider()
            if let target {
                ScrollView {
                    VStack(spacing: 24) {
                        silhouetteCard(target)
                        choiceGrid(target)
                        if showResult { resultBanner(target) }
                    }
                    .padding()
                }
            } else {
                ContentUnavailableView(
                    "Nicht genug Typen",
                    systemImage: "skew",
                    description: Text("Mindestens 4 Flugzeuge werden benötigt.")
                )
            }
        }
        .navigationTitle("Silhouette")
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

    // MARK: – Silhouette

    private func silhouetteCard(_ a: Aircraft) -> some View {
        AircraftSilhouetteView(wingspan: a.wingspan, length: a.length, color: .primary)
            .frame(width: 160, height: 160)
            .padding(24)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            .accessibilityLabel("Flugzeugsilhouette – Typ unbekannt. Tippe auf eine Antwort.")
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
        if choice.icaoCode == target.icaoCode   { return .correct }
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
        target     = viewModel.pickAircraft(from: aircraft, records: allRecords, mode: mode)
        guard let t = target else { return }
        choices    = buildChoices(for: t)
    }

    /// Bevorzugt Lookalikes als Ablenkungsantworten – didaktisch wertvoller,
    /// da der Nutzer genau diese Typen im echten Leben verwechseln würde.
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
