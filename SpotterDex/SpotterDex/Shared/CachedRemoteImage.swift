import SwiftUI
import UIKit

// MARK: – Disk-Cache

/// Persistenter Bild-Cache im Caches-Verzeichnis (offline-first).
///
/// `AsyncImage` cached nur flüchtig über den Standard-URLCache – nach App-Neustart
/// oder Cache-Eviction ist ohne Netz nichts mehr da. Für den Offline-Anspruch der
/// App werden Wikimedia-Fotos hier nach dem ersten Laden dauerhaft abgelegt und
/// bei jedem weiteren Aufruf zuerst von Disk geladen (kein Netz-Roundtrip).
/// Das System darf das Caches-Verzeichnis bei Speicherdruck leeren → beim
/// nächsten Online-Aufruf wird das Bild einfach neu geladen.
enum ImageDiskCache {
    private static let directory: URL = {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let dir  = base.appendingPathComponent("RemoteImages", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    /// Stabiler, dateisystem-sicherer Name aus der URL (URL-safe Base64).
    private static func fileURL(for url: URL) -> URL {
        let name = Data(url.absoluteString.utf8).base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
        return directory.appendingPathComponent(name)
    }

    static func image(for url: URL) -> UIImage? {
        guard let data = try? Data(contentsOf: fileURL(for: url)) else { return nil }
        return UIImage(data: data)
    }

    static func store(_ data: Data, for url: URL) {
        try? data.write(to: fileURL(for: url), options: .atomic)
    }
}

// MARK: – View

/// Drop-in-Ersatz für `AsyncImage` mit Disk-Cache und explizitem Fallback:
/// 1. Disk-Cache (sofort, offline) → 2. Netz (dann cachen) → 3. `fallback`.
struct CachedRemoteImage<Content: View, Placeholder: View, Fallback: View>: View {
    let url: URL?
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder
    @ViewBuilder let fallback: () -> Fallback

    @State private var loaded: UIImage?
    @State private var failed = false

    var body: some View {
        Group {
            if let loaded {
                content(Image(uiImage: loaded))
            } else if failed || url == nil {
                fallback()
            } else {
                placeholder()
            }
        }
        .task(id: url) {
            loaded = nil
            failed = false
            guard let url else { failed = true; return }

            if let cached = ImageDiskCache.image(for: url) {
                loaded = cached
                return
            }
            guard let (data, _) = try? await URLSession.shared.data(from: url),
                  let image = UIImage(data: data)
            else {
                if !Task.isCancelled { failed = true }
                return
            }
            ImageDiskCache.store(data, for: url)
            if !Task.isCancelled { loaded = image }
        }
    }
}
