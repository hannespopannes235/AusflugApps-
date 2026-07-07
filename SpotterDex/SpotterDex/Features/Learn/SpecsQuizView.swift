import SwiftUI
import SwiftData

/// Modus 2: Spec-Wert dem richtigen Flugzeugtyp zuordnen.
struct SpecsQuizView: View {
    let aircraft: [Aircraft]
    let viewModel: LearnViewModel

    @Environment(\.modelContext) private var modelContext
    @Query private var allRecords: [LearningRecord]

    @State private var target:     Aircraft?
    @State private var choices:    [Aircraft] = []
    @State private var selected:   Aircraft?
    @State private var showResult  = false
    @State private var currentSpec: SpecQuestion?

    private let mode = LearnMode.specs

    struct SpecQuestion {
        let label: String
        let value: String
    }

    var body: some View {
        VStack(spacing: 0) {
            QuizSessionBar(viewModel: viewModel)
            Divider()
            if let target, let spec = currentSpec {
                ScrollView {
                    VStack(spacing: 24) {
                        specCard(spec)
                        choiceGrid(target)
                        if showResult { resultBanner(target, spec: spec) }
                    }
                    .padding()
                }
            } else {
                ContentUnavailableView(
                    "Nicht genug Typen",
                    systemImage: "list.bullet.clipboard",
                    description: Text("Mindestens 4 Flugzeuge werden benötigt.")
                )
            }
        }
        .navigationTitle("Specs")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { nextQuestion() }
    }

    // MARK: – Spec-Karte

    private func specCard(_ spec: SpecQuestion) -> some View {
        VStack(spacing: 8) {
            Text("Welchem Typ gehört dieser Wert?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Text(spec.label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(spec.value)
                // Text-Style statt fester Größe → skaliert mit Dynamic Type
                .font(.system(.largeTitle, design: .monospaced).bold())
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(spec.label): \(spec.value). Welchem Flugzeugtyp gehört dieser Wert?")
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

    private func resultBanner(_ target: Aircraft, spec: SpecQuestion) -> some View {
        QuizResultBanner(
            correct:   selected?.icaoCode == target.icaoCode,
            wrongText: "Falsch – es war \(target.variant)",
            detail:    "\(spec.label): \(spec.value)"   // Merkhilfe zum Einprägen
        ) { nextQuestion() }
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
        guard let t = target,
              let ext = QuizSpec.extended.randomElement() else { return }
        currentSpec = SpecQuestion(label: ext.label, value: ext.value(t))
        choices     = viewModel.buildChoices(for: t, from: aircraft)
    }
}
