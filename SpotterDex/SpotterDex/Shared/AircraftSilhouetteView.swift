import SwiftUI

/// Stilisierte Draufsicht-Silhouette (Top-View).
/// Frame von außen setzen – wingspan füllt die Breite, Länge die Höhe.
/// Beide Achsen verwenden denselben scale-Faktor → korrekte Proportionen.
struct AircraftSilhouetteView: View {
    let wingspan: Double   // m
    let length: Double     // m
    let color: Color

    var body: some View {
        Canvas { ctx, size in
            guard wingspan > 0, length > 0 else { return }

            // Einheitlicher Scale-Faktor für beide Achsen
            let scale = min(size.width / wingspan, size.height / length)
            let sw    = wingspan * scale                  // scaled wingspan (horizontal)
            let sl    = length  * scale                  // scaled length   (vertical)
            let ox    = (size.width  - sw) / 2            // x-Offset zum Zentrieren
            let oy    = (size.height - sl) / 2            // y-Offset zum Zentrieren
            let cx    = size.width / 2                    // Mittellinie
            let fw    = max(sw * 0.065, 3.0)             // Rumpfbreite

            // ── Rumpf ──────────────────────────────────────────────────────
            let fuseRect = CGRect(x: cx - fw/2, y: oy, width: fw, height: sl)
            ctx.fill(
                Path { p in
                    p.addRoundedRect(in: fuseRect,
                                     cornerSize: .init(width: fw/2, height: fw/2))
                },
                with: .color(color)
            )

            // ── Hauptflügel (Swept Leading Edge, 38 % ab Nase) ────────────
            let wRoot = oy + sl * 0.38
            ctx.fill(Path { p in
                p.move(to:    .init(x: ox,        y: wRoot + sl * 0.085))   // L Tip TE
                p.addLine(to: .init(x: ox,        y: wRoot + sl * 0.050))   // L Tip LE
                p.addLine(to: .init(x: cx - fw/2, y: wRoot))                 // Root LE L
                p.addLine(to: .init(x: cx + fw/2, y: wRoot))                 // Root LE R
                p.addLine(to: .init(x: ox + sw,   y: wRoot + sl * 0.050))   // R Tip LE
                p.addLine(to: .init(x: ox + sw,   y: wRoot + sl * 0.085))   // R Tip TE
                p.addLine(to: .init(x: cx + fw/2, y: wRoot + sl * 0.070))   // Root TE R
                p.addLine(to: .init(x: cx - fw/2, y: wRoot + sl * 0.070))   // Root TE L
                p.closeSubpath()
            }, with: .color(color))

            // ── Höhenleitwerk (28 % Spannweite, 87 % ab Nase) ─────────────
            let stabSpan = sw * 0.28
            let stabY    = oy + sl * 0.87
            ctx.fill(Path { p in
                p.move(to:    .init(x: cx - stabSpan/2, y: stabY + sl * 0.026))
                p.addLine(to: .init(x: cx - stabSpan/2, y: stabY + sl * 0.014))
                p.addLine(to: .init(x: cx - fw/2,       y: stabY))
                p.addLine(to: .init(x: cx + fw/2,       y: stabY))
                p.addLine(to: .init(x: cx + stabSpan/2, y: stabY + sl * 0.014))
                p.addLine(to: .init(x: cx + stabSpan/2, y: stabY + sl * 0.026))
                p.addLine(to: .init(x: cx + fw/2,       y: stabY + sl * 0.018))
                p.addLine(to: .init(x: cx - fw/2,       y: stabY + sl * 0.018))
                p.closeSubpath()
            }, with: .color(color))
        }
        .accessibilityHidden(true)  // Beschriftung obliegt dem Container
    }
}

#Preview {
    HStack(spacing: 16) {
        // A380 (79.75 × 72.72)
        AircraftSilhouetteView(wingspan: 79.75, length: 72.72, color: .blue)
            .frame(width: 100, height: 100)
        // A320neo (35.8 × 37.57)
        AircraftSilhouetteView(wingspan: 35.8, length: 37.57, color: .orange)
            .frame(width: 45, height: 47)
        // ATR 72 (27.05 × 27.17)
        AircraftSilhouetteView(wingspan: 27.05, length: 27.17, color: .green)
            .frame(width: 34, height: 34)
    }
    .padding()
}
