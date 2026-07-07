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
}
