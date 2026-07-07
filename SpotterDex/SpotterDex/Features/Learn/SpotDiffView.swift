import SwiftUI
import SwiftData

/// Modus 3: Zwei Verwechslungspartner unterscheiden – einen Spec-Wert
/// dem richtigen der beiden Typen zuordnen.
struct SpotDiffView: View {
    let aircraft: [Aircraft]
    let viewModel: LearnViewModel

    @Environment(\.modelContext) private var modelContext
    @Query private var allRecords: [LearningRecord]

    @State private var aircraftA: Aircraft?
    @State private var aircraftB: Aircraft?
    @State private var question:  DiffQuestion?
    @State private var choices:   [String] = []
    @State private var selected:  String?
    @State private var showResult = false

    private let mode = LearnMode.spotDiff

    struct DiffQuestion {
        let label: String
        let correctAnswer: String
    }

    var body: some View {
        VStack(spacing: 0) {
            QuizSessionBar(viewModel: viewModel)
            Divider()
            if let a = aircraftA, let b = aircraftB, let q = question {
                ScrollView {
                    VStack(spacing: 20) {
                        silhouettePair(a, b)
                        questionCard(a, q)
                        choiceList(q)
                        if showResult { resultBanner(a, q) }
                    }
                    .padding()
                }
            } else {
                ContentUnavailableView(
                    "Keine Verwechslungspartner",
                    systemImage: "questionmark.diamond",
                    description: Text("Es werden Typen mit Lookalikes in der Datenbank benötigt.")
                )
            }
        }
        .navigationTitle("Verwechslung")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { nextQuestion() }
    }

    // MARK: – Silhouetten-Paar

    private func silhouettePair(_ a: Aircraft, _ b: Aircraft) -> some View {
        let maxW = max(1, max(a.wingspan, b.wingspan))
        let maxL = max(1, max(a.length, b.length))
        let base: CGFloat = 100

        return HStack(alignment: .bottom, spacing: 24) {
            ForEach([(a, Color.blue), (b, Color.orange)], id: \.0.icaoCode) { craft, color in
                VStack(spacing: 4) {
                    AircraftSilhouetteView(wingspan: craft.wingspan, length: craft.length, color: color)
                        .frame(
                            width:  CGFloat(craft.wingspan / maxW) * base,
                            height: CGFloat(craft.length   / maxL) * base
                        )
                    Text(craft.icaoCode)
                        .font(.caption.monospaced().bold())
                        .foregroundStyle(color)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(craft.variant)
            }
            Spacer(minLength: 0)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Silhouettenvergleich \(a.variant) und \(b.variant)")
    }

    // MARK: – Frage-Karte

    private func questionCard(_ a: Aircraft, _ q: DiffQuestion) -> some View {
        VStack(spacing: 4) {
            Text("Was gilt für")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(a.variant)
                .font(.headline)
                .foregroundStyle(.blue)
            Text("(\(q.label))?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Was ist die \(q.label) von \(a.variant)?")
    }

    // MARK: – Antwort-Liste

    private func choiceList(_ q: DiffQuestion) -> some View {
        VStack(spacing: 10) {
            ForEach(choices, id: \.self) { choice in
                let state: ChoiceButtonState = {
                    guard showResult else { return .idle }
                    if choice == q.correctAnswer { return .correct }
                    if choice == selected        { return .wrong   }
                    return .idle
                }()
                ChoiceButton(label: choice, subtitle: nil, state: state) {
                    guard !showResult else { return }
                    answer(choice, question: q)
                }
            }
        }
    }

    // MARK: – Ergebnis

    private func resultBanner(_ a: Aircraft, _ q: DiffQuestion) -> some View {
        QuizResultBanner(
            correct:   selected == q.correctAnswer,
            wrongText: "Falsch – korrekt: \(q.correctAnswer)"
        ) { nextQuestion() }
    }

    // MARK: – Logik

    private func answer(_ choice: String, question: DiffQuestion) {
        selected = choice
        showResult = true
        let correct = choice == question.correctAnswer
        viewModel.recordAnswer(correct: correct)
        if let a = aircraftA {
            viewModel.record(for: a, mode: mode, in: allRecords, context: modelContext)
                .recordAnswer(correct: correct)
        }
    }

    private func nextQuestion() {
        selected   = nil
        showResult = false

        // Kandidaten: Typen mit mindestens einem UNTERSCHEIDBAREN Lookalike in
        // der DB. Partner, die in allen Spec-Werten identisch sind, würden eine
        // degenerierte Frage erzeugen (nur eine Antwortoption, automatisch
        // "richtig") und werden deshalb schon hier ausgeschlossen.
        func distinguishablePartners(of a: Aircraft) -> [Aircraft] {
            a.lookalikes
                .compactMap { icao in aircraft.first { $0.icaoCode == icao } }
                .filter { partner in QuizSpec.base.contains { $0.value(a) != $0.value(partner) } }
        }
        let candidates = aircraft.filter { !distinguishablePartners(of: $0).isEmpty }
        guard !candidates.isEmpty else { aircraftA = nil; aircraftB = nil; question = nil; return }

        guard let a = viewModel.pickAircraft(from: candidates, records: allRecords, mode: mode),
              let b = distinguishablePartners(of: a).randomElement()
        else { aircraftA = nil; aircraftB = nil; question = nil; return }

        aircraftA = a
        aircraftB = b

        // Spec wählen, bei dem sich A und B unterscheiden (durch die
        // Kandidaten-Filterung oben garantiert nicht leer).
        let diffSpecs = QuizSpec.base.filter { $0.value(a) != $0.value(b) }
        guard let chosen = diffSpecs.randomElement() else { return }
        let correctVal = chosen.value(a)
        let wrongVal   = chosen.value(b)

        // Bis zu 2 weitere Ablenkungswerte aus dem restlichen Pool
        let extra = aircraft
            .filter { $0.icaoCode != a.icaoCode && $0.icaoCode != b.icaoCode }
            .map { chosen.value($0) }
            .filter { $0 != correctVal && $0 != wrongVal }
        let extraUnique = Array(Set(extra)).shuffled().prefix(2)

        choices  = ([correctVal, wrongVal] + extraUnique).shuffled()
        question = DiffQuestion(label: chosen.label, correctAnswer: correctVal)
    }
}
