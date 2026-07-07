import Foundation

/// Liefert Wikimedia-Commons-Fotos und Live-Bildnachweise für bekannte ICAO-Typen.
/// Keine Credits werden hartcodiert – Artist und Lizenz kommen immer live von der Commons-API.
struct WikimediaPhotoService {

    // MARK: – Mapping ICAO → verifizierter Commons-Dateiname

    private static let commonsFilenames: [String: String] = [
        "BCS3": "Swiss, HB-JCC, Airbus A220-300.jpg",
        "A20N": "Hannover Airport SKY express Airbus A320-251N SX-TEC (DSC00198).jpg",
        "A359": "Lufthansa, D-AIXO, Airbus A350-941 (49581146632).jpg",
        "A388": "Singapore Airlines Airbus A380-800 9V-SKN (7721163326).jpg",
        "B738": "WestJet Boeing 737-800 C-GXWJ (24734543535).jpg",
        "B77W": "Air Canada Boeing 777-300ER C-FITU (28483755286).jpg",
        "B789": "United Airlines, N17963, Boeing 787-9 Dreamliner (35595342772).jpg",
        "B748": "Lufthansa Boeing 747-8i.jpg",
        "E295": "Embraer E195-E2 (ERJ 190-400 STD) PS-AEF.jpg",
        "AT76": "Stobart Air ATR 72-600 (EI-FSL) at Manchester Airport.jpg",
        "B38M": "Norwegian Air Sweden SE-RTB Boeing 737-MAX 8 Amsterdam Airport Schiphol (AMS EHAM) (52724014741).jpg",
        "A21N": "Aegean Airlines, SX-NAA, Airbus A321-271NX (51007089432).jpg",
        "A333": "Lufthansa Airbus A330-300 D-AIKB (7721065166) (2).jpg",
        "B763": "KLM Boeing 767-300ER PH-BZM (2193203008).jpg",
        "E190": "Embraer ERJ-190-100LR 190LR (PH-EZH) 03.jpg",
        "CRJ9": "Eurowings (Lufthansa Regional) Bombardier CRJ900 at Berlin Tegel Airport.JPG",
        "DH8D": "Wideroe, LN-WDL, Bombardier Dash 8 Q400 (42435285354).jpg",
        "F100": "Helvetic Airways Fokker 100 (F-28-0100) HB-JVG (25446724953).jpg",
    ]

    // MARK: – Öffentliche Typen

    struct PhotoCredit {
        let artist: String
        let license: String
        let pageURL: URL
    }

    // MARK: – URL-Builder

    /// Bild-URL via Special:FilePath (750 px Breite genügt für Detailansicht).
    static func imageURL(for icaoCode: String) -> URL? {
        guard let filename = commonsFilenames[icaoCode] else { return nil }
        var comps = URLComponents(string: "https://commons.wikimedia.org/wiki/Special:FilePath/\(encode(filename))")
        comps?.queryItems = [URLQueryItem(name: "width", value: "900")]
        return comps?.url
    }

    /// Commons-Seite für den Link im Bildnachweis.
    static func pageURL(for icaoCode: String) -> URL? {
        guard let filename = commonsFilenames[icaoCode] else { return nil }
        return URL(string: "https://commons.wikimedia.org/wiki/File:\(encode(filename))")
    }

    // MARK: – Credit-Cache
    //
    // Credits kommen weiterhin IMMER original von der Commons-API (nie hartcodiert),
    // werden aber nach dem ersten Abruf persistiert: So steht der Bildnachweis auch
    // offline neben dem (disk-gecachten) Foto – rechtlich sauber in jedem Zustand.

    @MainActor private static var memoryCache: [String: PhotoCredit] = [:]
    private static let persistKey = "com.spotterdex.commonsCredits"

    @MainActor private static func cachedCredit(for icao: String) -> PhotoCredit? {
        if let hit = memoryCache[icao] { return hit }
        guard let stored = UserDefaults.standard.dictionary(forKey: persistKey),
              let entry  = stored[icao] as? [String: String],
              let artist = entry["artist"], let license = entry["license"],
              let page   = pageURL(for: icao)
        else { return nil }
        let credit = PhotoCredit(artist: artist, license: license, pageURL: page)
        memoryCache[icao] = credit
        return credit
    }

    @MainActor private static func storeCredit(_ credit: PhotoCredit, for icao: String) {
        memoryCache[icao] = credit
        var stored = UserDefaults.standard.dictionary(forKey: persistKey) ?? [:]
        stored[icao] = ["artist": credit.artist, "license": credit.license]
        UserDefaults.standard.set(stored, forKey: persistKey)
    }

    // MARK: – Live-Bildnachweis (async, keine Netz-Abhängigkeit beim Start)

    @MainActor
    static func fetchCredit(for icaoCode: String) async -> PhotoCredit? {
        if let cached = cachedCredit(for: icaoCode) { return cached }

        guard let filename = commonsFilenames[icaoCode],
              let page = pageURL(for: icaoCode) else { return nil }

        var comps = URLComponents(string: "https://commons.wikimedia.org/w/api.php")
        comps?.queryItems = [
            URLQueryItem(name: "action",                 value: "query"),
            URLQueryItem(name: "format",                 value: "json"),
            URLQueryItem(name: "prop",                   value: "imageinfo"),
            URLQueryItem(name: "iiprop",                 value: "extmetadata"),
            URLQueryItem(name: "iiextmetadatafilter",    value: "Artist|LicenseShortName"),
            URLQueryItem(name: "titles",                 value: "File:\(filename)"),
        ]
        guard let url = comps?.url,
              let (data, _) = try? await URLSession.shared.data(from: url),
              let json      = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let query     = json["query"]  as? [String: Any],
              let pages     = query["pages"] as? [String: Any],
              let firstPage = pages.values.first as? [String: Any],
              let infos     = firstPage["imageinfo"] as? [[String: Any]],
              let meta      = infos.first?["extmetadata"] as? [String: Any]
        else { return nil }

        let rawArtist = (meta["Artist"]          as? [String: Any])?["value"] as? String ?? "Unbekannt"
        let license   = (meta["LicenseShortName"] as? [String: Any])?["value"] as? String ?? ""

        // HTML-Tags entfernen (Commons liefert <a href=…> im Artist-Feld)
        let artist = rawArtist.replacingOccurrences(of: "<[^>]+>", with: "",
                                                    options: .regularExpression)
        let credit = PhotoCredit(artist: artist, license: license, pageURL: page)
        storeCredit(credit, for: icaoCode)
        return credit
    }

    // MARK: – Hilfsmethode

    private static func encode(_ filename: String) -> String {
        filename.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? filename
    }
}
