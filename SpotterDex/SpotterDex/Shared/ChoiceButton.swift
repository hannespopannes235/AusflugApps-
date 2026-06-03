import SwiftUI

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
