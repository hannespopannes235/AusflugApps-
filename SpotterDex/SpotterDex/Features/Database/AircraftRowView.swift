import SwiftUI

struct AircraftRowView: View {
    let aircraft: Aircraft

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: leadingIcon)
                .font(.title2)
                .foregroundStyle(.secondary)
                .frame(width: 36)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline) {
                    Text(aircraft.variant)
                        .font(.headline)
                    if aircraft.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                            .accessibilityHidden(true)   // Label unten nennt "Favorit"
                    }
                    Spacer()
                    Text(aircraft.icaoCode)
                        .font(.caption.monospaced())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.quaternary)
                        .clipShape(.capsule)
                }
                Text(aircraft.manufacturer)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    StatusBadge(status: aircraft.status)
                    Text("\(aircraft.engineCount)× \(aircraft.engineType.rawValue)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .contentShape(.rect)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(aircraft.variant), \(aircraft.manufacturer). " +
            "ICAO \(aircraft.icaoCode). \(aircraft.status.rawValue)." +
            (aircraft.isFavorite ? " Favorit." : "")
        )
    }

    private var leadingIcon: String {
        switch aircraft.engineType {
        case .turboprop, .piston: "propeller"
        default: "airplane"
        }
    }
}
