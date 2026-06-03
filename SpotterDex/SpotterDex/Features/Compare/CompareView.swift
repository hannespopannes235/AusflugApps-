import SwiftUI
import SwiftData

struct CompareView: View {
    @State private var viewModel = CompareViewModel()
    @State private var showingPicker = false

    @Query(sort: [
        SortDescriptor(\Aircraft.manufacturer),
        SortDescriptor(\Aircraft.variant)
    ]) private var allAircraft: [Aircraft]

    private let slotColors: [Color] = [.blue, .orange, .green]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                slotStrip
                if viewModel.selectedAircraft.count >= 2 {
                    Divider()
                    silhouetteSection
                    specComparisonTable
                } else {
                    emptyHint
                }
            }
        }
        .navigationTitle("Vergleich")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingPicker) {
            AircraftPickerSheet(viewModel: viewModel, allAircraft: allAircraft)
        }
    }

    // MARK: – Slot strip

    private var slotStrip: some View {
        HStack(alignment: .top, spacing: 8) {
            ForEach(0..<3, id: \.self) { idx in
                if idx < viewModel.selectedAircraft.count {
                    slotCard(viewModel.selectedAircraft[idx], index: idx)
                } else if idx == viewModel.selectedAircraft.count && viewModel.canAddMore {
                    addSlotButton
                } else {
                    Color.clear
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
    }

    private func slotCard(_ aircraft: Aircraft, index: Int) -> some View {
        VStack(spacing: 4) {
            Text(aircraft.icaoCode)
                .font(.caption.monospaced())
                .foregroundStyle(slotColors[index % slotColors.count])
            Text(aircraft.variant)
                .font(.caption2)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
            Button {
                viewModel.removeAircraft(at: index)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Entfernen: \(aircraft.variant)")
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
        .accessibilityElement(children: .combine)
    }

    private var addSlotButton: some View {
        Button {
            showingPicker = true
        } label: {
            VStack(spacing: 4) {
                Image(systemName: "plus.circle")
                    .font(.title3)
                Text("Hinzufügen")
                    .font(.caption2)
            }
            .foregroundStyle(.tint)
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Flugzeug zum Vergleich hinzufügen")
    }

    // MARK: – Silhouette comparison

    private var silhouetteSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Größenvergleich", systemImage: "skew")
            let aircraft = viewModel.selectedAircraft
            let maxWingspan = max(1, aircraft.map(\.wingspan).max() ?? 1)
            let maxLength   = max(1, aircraft.map(\.length).max()   ?? 1)
            let containerW: CGFloat = 90
            let containerH: CGFloat = 90

            HStack(alignment: .bottom, spacing: 20) {
                ForEach(Array(aircraft.enumerated()), id: \.offset) { idx, a in
                    let w = CGFloat(a.wingspan / maxWingspan) * containerW
                    let h = CGFloat(a.length   / maxLength)   * containerH
                    VStack(spacing: 4) {
                        AircraftSilhouetteView(
                            wingspan: a.wingspan,
                            length:   a.length,
                            color:    slotColors[idx % slotColors.count]
                        )
                        .frame(width: w, height: h)
                        Text(a.icaoCode)
                            .font(.caption2.monospaced())
                            .foregroundStyle(slotColors[idx % slotColors.count])
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(
                        "\(a.variant): Spannweite \(Int(a.wingspan)) m, " +
                        "Länge \(Int(a.length)) m"
                    )
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
            Divider()
        }
    }

    // MARK: – Spec comparison table

    private var specComparisonTable: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Spec-Vergleich", systemImage: "tablecells")
            compareRow("Spannweite", unit: "m") {
                $0.wingspan.formatted(.number.precision(.fractionLength(2)))
            }
            Divider().padding(.leading)
            compareRow("Länge", unit: "m") {
                $0.length.formatted(.number.precision(.fractionLength(2)))
            }
            Divider().padding(.leading)
            compareRow("Höhe", unit: "m") {
                $0.height.formatted(.number.precision(.fractionLength(2)))
            }
            Divider().padding(.leading)
            compareRow("MTOW", unit: "t") {
                ($0.mtow / 1000).formatted(.number.precision(.fractionLength(1)))
            }
            Divider().padding(.leading)
            compareRow("Reichweite", unit: "km") {
                Int($0.range).formatted()
            }
            Divider().padding(.leading)
            compareRow("Reisegeschw.", unit: "km/h") {
                Int($0.cruiseSpeed).formatted()
            }
            Divider().padding(.leading)
            compareRow("Passagiere", unit: "Pax") {
                $0.passengerCapacity.formatted()
            }
            Divider().padding(.leading)
            compareRow("Triebwerke") {
                "\($0.engineCount)× \($0.engineType.rawValue)"
            }
            Divider()
        }
    }

    private func compareRow(
        _ label: String,
        unit: String? = nil,
        value: (Aircraft) -> String
    ) -> some View {
        let aircraft = viewModel.selectedAircraft
        let values   = aircraft.map { value($0) }
        let isDiff   = Set(values).count > 1

        return HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(minWidth: 120, alignment: .leading)
            Spacer(minLength: 4)
            HStack(spacing: 14) {
                ForEach(Array(aircraft.enumerated()), id: \.offset) { idx, a in
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(value(a))
                            .font(.subheadline.monospacedDigit())
                            .fontWeight(isDiff ? .semibold : .regular)
                            .foregroundStyle(isDiff ? slotColors[idx % slotColors.count] : .primary)
                        if let unit {
                            Text(unit)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 7)
        .padding(.horizontal)
        .background(isDiff ? Color.yellow.opacity(0.06) : Color.clear)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(values.joined(separator: ", "))")
    }

    // MARK: – Empty hint

    private var emptyHint: some View {
        ContentUnavailableView(
            "Mindestens 2 Typen wählen",
            systemImage: "arrow.left.arrow.right",
            description: Text("Tippe auf + um bis zu 3 Flugzeuge hinzuzufügen.")
        )
        .padding(.top, 40)
    }
}

// MARK: – Aircraft Picker Sheet

struct AircraftPickerSheet: View {
    let viewModel: CompareViewModel
    let allAircraft: [Aircraft]

    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss

    private var filtered: [Aircraft] {
        guard !searchText.isEmpty else { return allAircraft }
        let q = searchText
        return allAircraft.filter {
            $0.variant.localizedCaseInsensitiveContains(q)      ||
            $0.manufacturer.localizedCaseInsensitiveContains(q) ||
            $0.icaoCode.localizedCaseInsensitiveContains(q)
        }
    }

    var body: some View {
        NavigationStack {
            List(filtered) { aircraft in
                let alreadySelected = viewModel.selectedAircraft.contains {
                    $0.icaoCode == aircraft.icaoCode
                }
                Button {
                    guard !alreadySelected else { return }
                    viewModel.addAircraft(aircraft)
                    dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(aircraft.variant)
                                .font(.subheadline)
                                .foregroundStyle(alreadySelected ? .secondary : .primary)
                            Text("\(aircraft.manufacturer) · \(aircraft.icaoCode)")
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if alreadySelected {
                            Image(systemName: "checkmark")
                                .font(.caption.bold())
                                .foregroundStyle(.tint)
                        }
                    }
                }
                .disabled(alreadySelected)
            }
            .searchable(text: $searchText, prompt: "Suche…")
            .navigationTitle("Flugzeug wählen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    NavigationStack { CompareView() }
        .modelContainer(for: Aircraft.self, inMemory: true)
}
