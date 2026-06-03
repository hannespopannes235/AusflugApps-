import Foundation
import Observation

@Observable
final class CompareViewModel {
    var selectedAircraft: [Aircraft] = []

    var canAddMore: Bool { selectedAircraft.count < 3 }

    func addAircraft(_ aircraft: Aircraft) {
        guard canAddMore else { return }
        guard !selectedAircraft.contains(where: { $0.icaoCode == aircraft.icaoCode }) else { return }
        selectedAircraft.append(aircraft)
    }

    func removeAircraft(at index: Int) {
        guard selectedAircraft.indices.contains(index) else { return }
        selectedAircraft.remove(at: index)
    }

    /// True wenn sich der Wert am gegebenen KeyPath zwischen den gewählten Typen unterscheidet.
    func isDifferent<T: Equatable>(_ keyPath: KeyPath<Aircraft, T>) -> Bool {
        guard selectedAircraft.count > 1 else { return false }
        let first = selectedAircraft[0][keyPath: keyPath]
        return selectedAircraft.dropFirst().contains { $0[keyPath: keyPath] != first }
    }
}
