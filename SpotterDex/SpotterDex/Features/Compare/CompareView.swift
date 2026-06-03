import SwiftUI

struct CompareView: View {
    @State private var viewModel = CompareViewModel()

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Vergleich")
                .font(.title2).bold()
            Text("Kommt in Phase 3: Zwei Typen nebeneinander vergleichen")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Vergleich")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview { NavigationStack { CompareView() } }
