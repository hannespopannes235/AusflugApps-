import SwiftUI

/// Wiederverwendbares Statuslabel mit Farb-Codierung.
struct StatusBadge: View {
    let status: AircraftStatus

    var body: some View {
        Text(status.rawValue)
            .font(.caption2.weight(.medium))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(.capsule)
    }

    private var color: Color {
        switch status {
        case .inProduction:    .green
        case .outOfProduction: .orange
        case .retired:         .secondary
        case .prototype:       .blue
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        ForEach(AircraftStatus.allCases, id: \.self) { StatusBadge(status: $0) }
    }
    .padding()
}
