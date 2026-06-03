import SwiftUI

// MARK: – SpecRow

/// Einzeiliges Label-Value-Paar, Dynamic-Type-sicher.
struct SpecRow: View {
    let label: String
    let value: String
    let unit: String?

    init(_ label: String, value: String, unit: String? = nil) {
        self.label = label
        self.value = value
        self.unit  = unit
    }

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer(minLength: 8)
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(value)
                    .font(.subheadline.monospacedDigit())
                    .fontWeight(.medium)
                if let unit {
                    Text(unit)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 7)
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)\(unit.map { " \($0)" } ?? "")")
    }
}

// MARK: – SpecSection

/// Abschnitt mit Header + beliebigen Spec-Zeilen.
struct SpecSection<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: title, systemImage: systemImage)
            content()
            Divider()
        }
    }
}

// MARK: – SectionHeader

struct SectionHeader: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 6)
    }
}
