import SwiftUI
import SwiftData

struct LearnView: View {
    @State private var viewModel = LearnViewModel()

    @Query private var allAircraft: [Aircraft]
    @Query private var allRecords: [LearningRecord]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                statsBanner
                modeList
                progressSection
            }
            .padding()
        }
        .navigationTitle("Lernen")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: – Stats Banner

    private var statsBanner: some View {
        let maxStreak    = allRecords.map(\.streak).max() ?? 0
        let learnedCount = Set(allRecords.filter { $0.totalAttempts > 0 }.map(\.aircraftICAO)).count

        return HStack(spacing: 0) {
            statCell(value: "\(maxStreak)",       label: "Streak",       icon: "flame.fill",          color: .orange)
            Divider().frame(height: 36)
            statCell(value: "\(learnedCount)",    label: "Typen gelernt", icon: "checkmark.circle.fill", color: .green)
            Divider().frame(height: 36)
            statCell(value: "\(allAircraft.count)", label: "im Archiv",  icon: "airplane",             color: .blue)
        }
        .padding(.vertical, 12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Bester Streak \(maxStreak). " +
            "\(learnedCount) von \(allAircraft.count) Typen gelernt."
        )
    }

    private func statCell(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Label(value, systemImage: icon)
                .font(.headline.monospacedDigit())
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: – Modus-Liste

    private var modeList: some View {
        VStack(spacing: 10) {
            ForEach(LearnMode.allCases) { mode in
                NavigationLink {
                    quizDestination(mode)
                } label: {
                    ModeCard(mode: mode, records: allRecords, totalAircraft: allAircraft.count)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func quizDestination(_ mode: LearnMode) -> some View {
        switch mode {
        case .photo:      PhotoQuizView(aircraft: allAircraft,      viewModel: viewModel)
        case .silhouette: SilhouetteQuizView(aircraft: allAircraft, viewModel: viewModel)
        case .specs:      SpecsQuizView(aircraft: allAircraft,      viewModel: viewModel)
        case .spotDiff:   SpotDiffView(aircraft: allAircraft,       viewModel: viewModel)
        }
    }

    // MARK: – Fortschrittsübersicht

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Fortschritt", systemImage: "chart.bar.fill")
            if progressItems.isEmpty {
                Text("Noch keine Lerneinheiten abgeschlossen.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
            } else {
                ForEach(progressItems, id: \.icao) { item in
                    ProgressRow(item: item)
                    Divider().padding(.leading)
                }
            }
            Divider()
        }
    }

    private var progressItems: [ProgressItem] {
        let grouped = Dictionary(grouping: allRecords.filter { $0.totalAttempts > 0 },
                                 by: \.aircraftICAO)
        return grouped.compactMap { icao, recs in
            guard let aircraft = allAircraft.first(where: { $0.icaoCode == icao }) else { return nil }
            let attempts = recs.map(\.totalAttempts).reduce(0, +)
            let correct  = recs.map(\.totalCorrect).reduce(0, +)
            let accuracy = attempts > 0 ? Double(correct) / Double(attempts) : 0
            let due      = recs.contains { $0.isDue }
            return ProgressItem(icao: icao, variant: aircraft.variant,
                                accuracy: accuracy, attempts: attempts, isDue: due)
        }
        .sorted { $0.accuracy < $1.accuracy }
    }
}

// MARK: – Hilfstrukturen (fileprivate)

fileprivate struct ProgressItem {
    let icao: String
    let variant: String
    let accuracy: Double
    let attempts: Int
    let isDue: Bool
}

private struct ModeCard: View {
    let mode: LearnMode
    let records: [LearningRecord]
    let totalAircraft: Int

    private var dueCount: Int {
        let modeRecs   = records.filter { $0.mode == mode.rawValue }
        let seenICAOs  = Set(modeRecs.map(\.aircraftICAO))
        let newCount   = max(0, totalAircraft - seenICAOs.count)
        return modeRecs.filter(\.isDue).count + newCount
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: mode.systemImage)
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(mode.rawValue)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(mode.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if dueCount > 0 {
                Text("\(dueCount)")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.tint, in: Capsule())
            }
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(mode.rawValue): \(mode.description). \(dueCount) fällig.")
    }
}

private struct ProgressRow: View {
    let item: ProgressItem

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.variant)
                    .font(.subheadline)
                Text("\(item.attempts) Versuche")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if item.isDue {
                Image(systemName: "clock.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .accessibilityLabel("Wiederholung fällig")
            }
            AccuracyBadge(accuracy: item.accuracy)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(item.variant): \(Int(item.accuracy * 100)) % korrekt, " +
            "\(item.attempts) Versuche\(item.isDue ? ", Wiederholung fällig" : "")"
        )
    }
}

// MARK: – AccuracyBadge (intern nutzbar)

struct AccuracyBadge: View {
    let accuracy: Double

    private var color: Color {
        accuracy >= 0.8 ? .green : accuracy >= 0.5 ? .orange : .red
    }

    var body: some View {
        Text("\(Int(accuracy * 100)) %")
            .font(.caption.bold())
            .foregroundStyle(color)
            .accessibilityHidden(true)
    }
}

#Preview {
    NavigationStack { LearnView() }
        .modelContainer(for: [Aircraft.self, LearningRecord.self], inMemory: true)
}
