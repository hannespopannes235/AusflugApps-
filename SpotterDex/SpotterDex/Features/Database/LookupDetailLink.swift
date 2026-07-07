import SwiftUI
import SwiftData

/// Navigierbarer Link zu einem Aircraft-Eintrag anhand seines ICAO-Codes.
/// Ist der Code nicht in der Datenbank, wird er als Plain-Text dargestellt.
struct LookupDetailLink: View {
    let icaoCode: String

    @Query private var matches: [Aircraft]

    init(icaoCode: String) {
        self.icaoCode = icaoCode
        let code = icaoCode
        _matches = Query(filter: #Predicate<Aircraft> { $0.icaoCode == code })
    }

    var body: some View {
        if let aircraft = matches.first {
            NavigationLink {
                AircraftDetailView(aircraft: aircraft)
            } label: {
                HStack(spacing: 6) {
                    Text(aircraft.icaoCode)
                        .font(.subheadline.monospaced())
                        .foregroundStyle(.tint)
                    Text("·")
                        .foregroundStyle(.tertiary)
                    Text(aircraft.variant)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .accessibilityLabel("Zu \(aircraft.variant) navigieren")
        } else {
            HStack(spacing: 6) {
                Text(icaoCode)
                    .font(.subheadline.monospaced())
                    .foregroundStyle(.secondary)
                Text("(nicht in Datenbank)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Spacer(minLength: 0)
            }
            .accessibilityLabel("Verwechslungspartner \(icaoCode), nicht in Datenbank")
        }
    }
}
