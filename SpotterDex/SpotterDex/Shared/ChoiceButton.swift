import SwiftUI

// MARK: – Gemeinsame Quiz-Bausteine
// (SessionBar und ResultBanner waren zuvor 3× wortgleich in den Quiz-Views dupliziert)

/// Kopfzeile aller Quiz-Modi: Session-Streak + Trefferquote.
struct QuizSessionBar: View {
    let viewModel: LearnViewModel

    var body: some View {
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
}

/// Ergebnis-Banner aller Quiz-Modi.
/// Wichtig für VoiceOver: Nur der TEXT wird kombiniert – der „Nächste
/// Frage"-Button bleibt ein eigenes, fokussierbares Element (das frühere
/// .combine über den gesamten Banner machte ihn unerreichbar).
struct QuizResultBanner: View {
    let correct: Bool
    let wrongText: String          // z. B. "Falsch – es war A320neo"
    var detail: String? = nil      // optionale Merkhilfe-Zeile
    let next: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 8) {
                Label(
                    correct ? "Richtig!" : wrongText,
                    systemImage: correct ? "checkmark.circle.fill" : "xmark.circle.fill"
                )
                .font(.headline)
                .foregroundStyle(correct ? .green : .red)
                if let detail {
                    Text(detail)
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityElement(children: .combine)
            Button("Nächste Frage") { next() }
                .buttonStyle(.borderedProminent)
                .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
    }
}

enum ChoiceButtonState { case idle, correct, wrong }

/// Wiederverwendbare Antwort-Schaltfläche für alle Quiz-Modi.
struct ChoiceButton: View {
    let label: String
    let subtitle: String?
    let state: ChoiceButtonState
    let action: () -> Void

    private var bg: Color {
        switch state {
        case .idle:    return .clear
        case .correct: return Color.green.opacity(0.15)
        case .wrong:   return Color.red.opacity(0.15)
        }
    }

    private var border: Color {
        switch state {
        case .idle:    return Color.secondary.opacity(0.3)
        case .correct: return .green
        case .wrong:   return .red
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(label)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(bg)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(border, lineWidth: state == .idle ? 0.5 : 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityHint(
            state == .correct ? "Richtige Antwort" :
            state == .wrong   ? "Falsche Antwort"  : "Antwort wählen"
        )
    }
}
