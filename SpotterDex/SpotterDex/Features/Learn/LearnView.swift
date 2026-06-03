import SwiftUI

struct LearnView: View {
    @State private var viewModel = LearnViewModel()

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "book.closed")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Lernen")
                .font(.title2).bold()
            Text("Kommt in Phase 5: Lernkarten, Fortschritt & iCloud-Sync")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Lernen")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview { NavigationStack { LearnView() } }
