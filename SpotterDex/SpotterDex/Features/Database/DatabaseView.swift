import SwiftUI
import SwiftData

struct DatabaseView: View {
    // Basis-Query sortiert nach Hersteller → Variante.
    // Phase 3+: @Query mit dynamischem #Predicate für große Datasets.
    @Query(sort: [
        SortDescriptor(\Aircraft.manufacturer),
        SortDescriptor(\Aircraft.variant)
    ]) private var allAircraft: [Aircraft]

    @State private var viewModel = DatabaseViewModel()

    private var filtered: [Aircraft] {
        allAircraft.filter { viewModel.isMatching($0) }
    }

    private var availableManufacturers: [String] {
        Array(Set(allAircraft.map(\.manufacturer))).sorted()
    }

    var body: some View {
        Group {
            if allAircraft.isEmpty {
                ContentUnavailableView(
                    "Datenbank wird geladen…",
                    systemImage: "airplane.slash",
                    description: Text("Bitte einen Moment warten.")
                )
            } else if filtered.isEmpty {
                ContentUnavailableView.search(text: viewModel.searchText)
            } else {
                aircraftList
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "ICAO, Typ, Hersteller…")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                FilterMenuView(viewModel: viewModel,
                               availableManufacturers: availableManufacturers)
            }
        }
        .navigationTitle("Datenbank")
        .navigationBarTitleDisplayMode(.large)
    }

    private var aircraftList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(filtered) { aircraft in
                    NavigationLink {
                        AircraftDetailView(aircraft: aircraft)
                    } label: {
                        AircraftRowView(aircraft: aircraft)
                    }
                    .buttonStyle(.plain)
                    Divider().padding(.leading, 64)
                }
            }
        }
    }
}

#Preview {
    NavigationStack { DatabaseView() }
        .modelContainer(for: Aircraft.self, inMemory: true)
}
