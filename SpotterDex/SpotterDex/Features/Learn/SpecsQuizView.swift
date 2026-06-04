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

    private let specExtractors: [(String, (Aircraft) -> String)] = [
        ("Spannweite", { $0.wingspan.formatted(.number.precision(.fractionLength(1))) + " m" }),
        ("Länge",      { $0.length.formatted(.number.precision(.fractionLength(1))) + " m" }),
        ("Reichweite", { Int($0.range).formatted() + " km" }),
        ("MTOW",       { (Int($0.mtow / 1_000)).formatted() + " t" }),
        ("Passagiere", { $0.passengerCapacity.formatted() + " Pax" }),
        ("Triebwerke", { "\($0.engineCount)× \($0.engineType.rawValue)" }),
    ]

    var body: some View {
        VStack(spacing: 0) {
            sessionBar
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
                .font(.system(size: 36, weight: .bold, design: .monospaced))
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
        let correct = selected?.icaoCode == target.icaoCode
        return VStack(spacing: 8) {
            Label(
                correct ? "Richtig!" : "Falsch – es war \(target.variant)",
                systemImage: correct ? "checkmark.circle.fill" : "xmark.circle.fill"
            )
            .font(.headline)
            .foregroundStyle(correct ? .green : .red)
            // Spec-Wert als Merkhilfe wiederholen, damit der Nutzer ihn einprägen kann
            Text("\(spec.label): \(spec.value)")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            Button("Nächste Frage") { nextQuestion() }
                .buttonStyle(.borderedProminent)
                .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            correct ? "Richtig! \(spec.label): \(spec.value)" :
                      "Falsch. Es war \(target.variant). \(spec.label): \(spec.value)"
        )
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
              let ext = specExtractors.randomElement() else { return }
        currentSpec = SpecQuestion(label: ext.0, value: ext.1(t))
        choices     = buildChoices(for: t)
    }

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
