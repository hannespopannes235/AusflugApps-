import SwiftUI

struct ContentView: View {
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
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Aircraft.self, inMemory: true)
}
