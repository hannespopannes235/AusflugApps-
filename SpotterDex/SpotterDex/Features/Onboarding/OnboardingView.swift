import SwiftUI

/// Kurzes, überspringbares Onboarding (4 Seiten).
/// Wird beim ersten App-Start via ContentView gezeigt.
struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var currentPage = 0

    private let pages: [Page] = [
        Page(icon: "airplane.circle.fill",
             color: DS.Color.aviationBlue,
             title: "Willkommen bei SpotterDex",
             body: "Dein digitales Handbuch für Planespotter.\nFlugzeuge erkennen, vergleichen und meistern."),
        Page(icon: "list.bullet.rectangle.portrait.fill",
             color: DS.Color.runwayGreen,
             title: "Datenbank",
             body: "Über 10 Typen mit vollständigen Specs,\nSilhouetten, Erkennungsmerkmalen\nund Verwechslungspartnern."),
        Page(icon: "brain.head.profile.fill",
             color: DS.Color.amber,
             title: "Spielerisch Lernen",
             body: "Silhouetten raten, Specs zuordnen,\nVerwechslungspartner unterscheiden –\nmit Spaced Repetition für echten Lernfortschritt."),
        Page(icon: "camera.fill",
             color: DS.Color.alertRed,
             title: "Flugzeuge Spotten",
             body: "Fotografiere ein Flugzeug und\nSpotterDex erkennt den Typ automatisch –\nvollständig offline, on-device."),
    ]

    var body: some View {
        NavigationStack {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { idx, page in
                    pageView(page)
                        .tag(idx)
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .animation(.easeInOut, value: currentPage)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Überspringen") { onComplete() }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .safeAreaInset(edge: .bottom) {
                bottomBar
            }
        }
    }

    // MARK: – Seite

    private func pageView(_ page: Page) -> some View {
        VStack(spacing: DS.Spacing.l) {
            Spacer()
            Image(systemName: page.icon)
                .font(.system(size: 80, weight: .thin))
                .foregroundStyle(page.color)
                .accessibilityHidden(true)
            VStack(spacing: DS.Spacing.s) {
                Text(page.title)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                Text(page.body)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, DS.Spacing.xl)
            Spacer()
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(page.title). \(page.body)")
    }

    // MARK: – Navigation

    private var bottomBar: some View {
        HStack {
            if currentPage > 0 {
                Button {
                    withAnimation { currentPage -= 1 }
                } label: {
                    Image(systemName: "chevron.left")
                    Text("Zurück")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
            Spacer()
            if currentPage < pages.count - 1 {
                Button {
                    withAnimation { currentPage += 1 }
                } label: {
                    Text("Weiter")
                    Image(systemName: "chevron.right")
                }
                .font(.subheadline.bold())
                .buttonStyle(.borderedProminent)
                .tint(pages[currentPage].color)
            } else {
                Button("Los geht's!") { onComplete() }
                    .font(.subheadline.bold())
                    .buttonStyle(.borderedProminent)
                    .tint(DS.Color.runwayGreen)
            }
        }
        .padding(.horizontal, DS.Spacing.l)
        .padding(.bottom, DS.Spacing.l)
    }

    // MARK: – Datenstruktur

    private struct Page {
        let icon: String
        let color: Color
        let title: String
        let body: String
    }
}

#Preview {
    OnboardingView { }
}
