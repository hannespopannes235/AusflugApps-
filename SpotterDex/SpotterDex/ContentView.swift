import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "airplane")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .font(.system(size: 60))
            Text("SpotterDex")
                .font(.largeTitle)
                .bold()
            Text("Dein Flugzeug-Nachschlagewerk")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("SpotterDex – Dein Flugzeug-Nachschlagewerk")
    }
}

#Preview {
    ContentView()
}
