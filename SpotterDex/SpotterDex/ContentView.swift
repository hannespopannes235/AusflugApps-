import SwiftUI

struct ContentView: View {
    @AppStorage("com.spotterdex.onboardingDone") private var onboardingDone = false

    var body: some View {
        TabView {
            NavigationStack {
                DatabaseView()
            }
            .tabItem { Label("Datenbank", systemImage: "airplane") }

            NavigationStack {
                CompareView()
            }
            .tabItem { Label("Vergleich", systemImage: "arrow.left.arrow.right") }

            NavigationStack {
                LearnView()
            }
            .tabItem { Label("Lernen", systemImage: "book.closed") }

            NavigationStack {
                SpotView()
            }
            .tabItem { Label("Spotten", systemImage: "camera.viewfinder") }

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("Einstellungen", systemImage: "gearshape") }
        }
        .fullScreenCover(isPresented: .constant(!onboardingDone)) {
            OnboardingView {
                onboardingDone = true
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Aircraft.self, LearningRecord.self], inMemory: true)
}
