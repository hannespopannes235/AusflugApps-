import SwiftUI

struct FilterMenuView: View {
    @Bindable var viewModel: DatabaseViewModel
    let availableManufacturers: [String]

    var body: some View {
        Menu {
            favoritesToggle
            manufacturerSection
            statusSection
            eraSection
            if viewModel.hasActiveFilters {
                Divider()
                Button("Filter zurücksetzen", role: .destructive) {
                    viewModel.clearFilters()
                }
            }
        } label: {
            Image(
                systemName: viewModel.hasActiveFilters
                    ? "line.3.horizontal.decrease.circle.fill"
                    : "line.3.horizontal.decrease.circle"
            )
            .symbolRenderingMode(.hierarchical)
        }
        .accessibilityLabel(viewModel.hasActiveFilters ? "Aktive Filter" : "Filter")
    }

    // MARK: – Sektionen

    private var favoritesToggle: some View {
        Toggle(isOn: $viewModel.favoritesOnly) {
            Label("Nur Favoriten", systemImage: "star")
        }
    }

    @ViewBuilder
    private var manufacturerSection: some View {
        Menu("Hersteller") {
            ForEach(availableManufacturers, id: \.self) { m in
                Toggle(m, isOn: Binding(
                    get: { viewModel.selectedManufacturers.contains(m) },
                    set: { _ in viewModel.toggleManufacturer(m) }
                ))
            }
        }
    }

    @ViewBuilder
    private var statusSection: some View {
        Menu("Status") {
            ForEach(AircraftStatus.allCases, id: \.self) { s in
                Toggle(s.rawValue, isOn: Binding(
                    get: { viewModel.selectedStatuses.contains(s) },
                    set: { _ in viewModel.toggleStatus(s) }
                ))
            }
        }
    }

    @ViewBuilder
    private var eraSection: some View {
        Menu("Ära") {
            Button(viewModel.selectedEra == nil ? "Alle ✓" : "Alle") {
                viewModel.selectedEra = nil
            }
            ForEach(AircraftEra.allCases) { era in
                Button(viewModel.selectedEra == era
                       ? "\(era.rawValue) ✓" : era.rawValue) {
                    viewModel.selectedEra = (viewModel.selectedEra == era) ? nil : era
                }
            }
        }
    }
}
