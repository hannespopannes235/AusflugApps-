import SwiftUI
import SwiftData

struct AircraftDetailView: View {
    @Bindable var aircraft: Aircraft
    @State private var photoCredit: WikimediaPhotoService.PhotoCredit?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                photoSection
                headerCard
                Divider()
                dimensionsSection
                performanceSection
                propulsionSection
                historySection
                if !aircraft.visualFeatures.isEmpty { visualFeaturesSection }
                if !aircraft.lookalikes.isEmpty     { lookalikeSection      }
            }
        }
        .navigationTitle(aircraft.variant)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { favoriteButton }
        }
        // Credits werden bei jedem Aufruf live von der Commons-API geladen.
        // Bei fehlendem Netz bleibt photoCredit nil → kein Crash, kein falscher Nachweis.
        .task(id: aircraft.icaoCode) {
            let icao   = aircraft.icaoCode
            let credit = await WikimediaPhotoService.fetchCredit(for: icao)
            // Guard gegen veraltete Antworten: Ein abgebrochener Alt-Task darf
            // den Credit der inzwischen angezeigten Maschine nicht überschreiben.
            guard aircraft.icaoCode == icao, !Task.isCancelled else { return }
            photoCredit = credit
        }
    }

    // MARK: – Foto / Silhouette

    @ViewBuilder
    private var photoSection: some View {
        if let imageURL = WikimediaPhotoService.imageURL(for: aircraft.icaoCode) {
            VStack(alignment: .leading, spacing: 0) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .frame(height: 220)
                            .clipped()
                            .accessibilityLabel("\(aircraft.variant) Foto")
                    case .failure:
                        // Offline oder Lade-Fehler → Silhouette
                        silhouetteFallback
                    case .empty:
                        Color(.systemGray5)
                            .frame(height: 220)
                            .overlay { ProgressView() }
                    @unknown default:
                        silhouetteFallback
                    }
                }

                // Bildnachweis – erst sichtbar wenn die API geantwortet hat
                if let credit = photoCredit {
                    HStack(spacing: 4) {
                        Image(systemName: "camera")
                            .imageScale(.small)
                            .accessibilityHidden(true)
                        Text("© \(credit.artist) · \(credit.license)")
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Spacer(minLength: 4)
                        Link("Quelle ↗", destination: credit.pageURL)
                            .foregroundStyle(.tint)
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(.regularMaterial)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(
                        "Bildnachweis: \(credit.artist), \(credit.license). Link zu Wikimedia Commons."
                    )
                }
            }
        } else {
            // Kein Foto für diesen Typ → Silhouette als Platzhalter
            silhouetteFallback
        }
    }

    private var silhouetteFallback: some View {
        AircraftSilhouetteView(
            wingspan: aircraft.wingspan,
            length:   aircraft.length,
            color:    .accentColor
        )
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .padding()
        .background(Color(.systemGray6))
        .accessibilityLabel("Silhouette von \(aircraft.variant)")
    }

    // MARK: – Header

    private var headerCard: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(aircraft.manufacturer)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(aircraft.family)
                    .font(.title3.bold())
                HStack(spacing: 10) {
                    Label(aircraft.icaoCode, systemImage: "airplane")
                        .font(.caption.monospaced())
                    if !aircraft.iataCode.isEmpty {
                        Label(aircraft.iataCode, systemImage: "ticket")
                            .font(.caption.monospaced())
                    }
                }
                .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            StatusBadge(status: aircraft.status)
        }
        .padding()
        .background(.regularMaterial)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(aircraft.variant), \(aircraft.manufacturer). " +
            "ICAO \(aircraft.icaoCode). \(aircraft.status.rawValue)."
        )
    }

    // MARK: – Spec Sections

    private var dimensionsSection: some View {
        SpecSection(title: "Abmessungen", systemImage: "ruler") {
            SpecRow("Spannweite", value: aircraft.wingspan.formatted(.number.precision(.fractionLength(2))), unit: "m")
            Divider().padding(.leading)
            SpecRow("Länge",      value: aircraft.length.formatted(.number.precision(.fractionLength(2))), unit: "m")
            Divider().padding(.leading)
            SpecRow("Höhe",       value: aircraft.height.formatted(.number.precision(.fractionLength(2))), unit: "m")
        }
    }

    private var performanceSection: some View {
        SpecSection(title: "Leistung", systemImage: "speedometer") {
            SpecRow("Reisegeschwindigkeit",
                    value: Int(aircraft.cruiseSpeed).formatted(), unit: "km/h")
            Divider().padding(.leading)
            SpecRow("Reichweite",
                    value: Int(aircraft.range).formatted(), unit: "km")
            Divider().padding(.leading)
            SpecRow("MTOW",
                    value: (aircraft.mtow / 1000).formatted(.number.precision(.fractionLength(1))), unit: "t")
        }
    }

    private var propulsionSection: some View {
        SpecSection(title: "Antrieb & Kabine", systemImage: "bolt") {
            SpecRow("Triebwerke",
                    value: "\(aircraft.engineCount)× \(aircraft.engineType.rawValue)")
            Divider().padding(.leading)
            SpecRow("Passagiere (max. 1-Kl.)",
                    value: aircraft.passengerCapacity.formatted(), unit: "Pax")
        }
    }

    private var historySection: some View {
        SpecSection(title: "Geschichte", systemImage: "calendar") {
            if let d = aircraft.firstFlightDate {
                SpecRow("Erstflug",
                        value: d.formatted(.dateTime.year()))
                Divider().padding(.leading)
            }
            SpecRow("Status", value: aircraft.status.rawValue)
        }
    }

    // MARK: – Erkennungsmerkmale

    private var visualFeaturesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Erkennungsmerkmale", systemImage: "eye")
            ForEach(Array(aircraft.visualFeatures.enumerated()), id: \.offset) { idx, feature in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.footnote)
                        .padding(.top, 2)
                        .accessibilityHidden(true)
                    Text(feature)
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal)
                .padding(.vertical, 7)
                if idx < aircraft.visualFeatures.count - 1 {
                    Divider().padding(.leading, 44)
                }
            }
            Divider()
        }
    }

    // MARK: – Verwechslungspartner

    private var lookalikeSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Verwechslungspartner", systemImage: "questionmark.diamond")
            ForEach(Array(aircraft.lookalikes.enumerated()), id: \.offset) { idx, icao in
                LookupDetailLink(icaoCode: icao)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                if idx < aircraft.lookalikes.count - 1 {
                    Divider().padding(.leading, 16)
                }
            }
            Divider()
        }
    }

    // MARK: – Favoriten-Button

    private var favoriteButton: some View {
        Button {
            aircraft.isFavorite.toggle()
        } label: {
            Image(systemName: aircraft.isFavorite ? "star.fill" : "star")
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(aircraft.isFavorite ? .yellow : .secondary)
                .imageScale(.large)
        }
        .accessibilityLabel(
            aircraft.isFavorite ? "Aus Favoriten entfernen" : "Zu Favoriten hinzufügen"
        )
    }
}

#Preview {
    NavigationStack {
        AircraftDetailView(aircraft: {
            let a = Aircraft(
                manufacturer: "Airbus", family: "A320", variant: "A320neo",
                icaoCode: "A20N", iataCode: "32N",
                firstFlightDate: Calendar.current.date(from: .init(year: 2014, month: 9, day: 25)),
                status: .inProduction,
                wingspan: 35.8, length: 37.57, height: 11.76,
                mtow: 79000, range: 6300, cruiseSpeed: 833,
                passengerCapacity: 165, engineType: .turbofan, engineCount: 2,
                visualFeatures: ["Sharklet-Winglets", "CFM LEAP oder PW1100G"],
                lookalikes: ["B738", "A321neo"]
            )
            return a
        }())
    }
    .modelContainer(for: Aircraft.self, inMemory: true)
}
