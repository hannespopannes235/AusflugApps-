import SwiftUI

struct SpotView: View {
    @State private var viewModel = SpotViewModel()

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Spotten")
                .font(.title2).bold()
            Text("Kommt in Phase 4: Foto-Erkennung via Core ML")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Spotten")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview { NavigationStack { SpotView() } }
