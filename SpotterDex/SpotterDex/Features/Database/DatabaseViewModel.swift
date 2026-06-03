import Foundation
import Observation

@Observable
final class DatabaseViewModel {
    var searchText: String = ""
    var selectedManufacturers: Set<String> = []
    var selectedStatuses: Set<AircraftStatus> = []
    var selectedEra: AircraftEra? = nil

    var hasActiveFilters: Bool {
        !selectedManufacturers.isEmpty || !selectedStatuses.isEmpty || selectedEra != nil
    }

    /// Gibt `true` zurück wenn der Aircraft alle aktiven Filter erfüllt.
    /// Hinweis Phase 3+: Bei großen Datasets auf #Predicate-basierte @Query umstellen.
    func isMatching(_ aircraft: Aircraft) -> Bool {
        let q = searchText.trimmingCharacters(in: .whitespaces)
        let matchesSearch = q.isEmpty
            || aircraft.variant.localizedCaseInsensitiveContains(q)
            || aircraft.family.localizedCaseInsensitiveContains(q)
            || aircraft.manufacturer.localizedCaseInsensitiveContains(q)
            || aircraft.icaoCode.localizedCaseInsensitiveContains(q)
            || aircraft.iataCode.localizedCaseInsensitiveContains(q)

        let matchesManufacturer = selectedManufacturers.isEmpty
            || selectedManufacturers.contains(aircraft.manufacturer)

        let matchesStatus = selectedStatuses.isEmpty
            || selectedStatuses.contains(aircraft.status)

        let matchesEra = selectedEra?.matches(aircraft.firstFlightDate) ?? true

        return matchesSearch && matchesManufacturer && matchesStatus && matchesEra
    }

    func toggleManufacturer(_ m: String) {
        selectedManufacturers.formSymmetricDifference([m])
    }

    func toggleStatus(_ s: AircraftStatus) {
        selectedStatuses.formSymmetricDifference([s])
    }

    func clearFilters() {
        selectedManufacturers.removeAll()
        selectedStatuses.removeAll()
        selectedEra = nil
    }
}
