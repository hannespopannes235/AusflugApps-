import SwiftUI

struct DatabaseView: View {
    @State private var viewModel = DatabaseViewModel()

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "airplane")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Datenbank")
                .font(.title2).bold()
            Text("Kommt in Phase 2: Flugzeug-Liste mit Suche & Filter")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Datenbank")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview { NavigationStack { DatabaseView() } }
