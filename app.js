'use strict';

// ── Aircraft data (aus aircraft_seed_v1.json) ──────────────────────────────────
const AIRCRAFT = [
  {
    manufacturer: "Airbus", family: "A220", variant: "A220-300",
    icaoCode: "BCS3", iataCode: "CS3", firstFlightYear: 2015, status: "inProduction",
    wingspan: 35.1, length: 38.71, height: 11.5,
    mtow: 70900, range: 6300, cruiseSpeed: 871, passengerCapacity: 130,
    engineType: "turbofan", engineCount: 2,
    visualFeatures: [
      "Breiter Rumpfquerschnitt für Schmalrumpf (2-3 Bestuhlung)",
      "Doppelt geschwungene Winglets (oben und unten)",
      "Sehr große Cockpitfenster",
      "Pratt & Whitney GTF-Triebwerke mit breitem Einlass",
      "Hochgelegte Flügel, leicht gepfeilt, keine sichtbare Wingbox-Verdickung"
    ],
    lookalikes: ["E295", "A20N"]
  },
  {
    manufacturer: "Airbus", family: "A320", variant: "A320neo",
    icaoCode: "A20N", iataCode: "32N", firstFlightYear: 2014, status: "inProduction",
    wingspan: 35.8, length: 37.57, height: 11.76,
    mtow: 79000, range: 6300, cruiseSpeed: 833, passengerCapacity: 165,
    engineType: "turbofan", engineCount: 2,
    visualFeatures: [
      "Sharklet-Winglets (breite gebogene Spitzen, Gegensatz zu Boeing-Winglets)",
      "CFM LEAP-1A oder PW1100G – beide breiter als CFM56 der ceo-Variante",
      "Klassische Airbus-Nase mit abgeflachter Unterseite",
      "Keine Triebwerksabflachung unten (Gegensatz zu B737 NG)"
    ],
    lookalikes: ["B738", "BCS3", "A20N"]
  },
  {
    manufacturer: "Airbus", family: "A350", variant: "A350-900",
    icaoCode: "A359", iataCode: "359", firstFlightYear: 2013, status: "inProduction",
    wingspan: 64.75, length: 66.8, height: 17.05,
    mtow: 280000, range: 15000, cruiseSpeed: 903, passengerCapacity: 440,
    engineType: "turbofan", engineCount: 2,
    visualFeatures: [
      "Schwarze 'Katzenaugen' – geschwungene dunkle Cockpitfensterrahmen",
      "Mattes Finish des Karbonfaser-Rumpfs (kein spiegelndes Aluminium)",
      "Gebogene Flügelspitzen ('curved wingtip fences')",
      "Rolls-Royce Trent XWB – charakteristische ovale Gondeln",
      "Schlanker Rumpf trotz Widebody-Kategorie"
    ],
    lookalikes: ["B789", "A330neo"]
  },
  {
    manufacturer: "Airbus", family: "A380", variant: "A380-800",
    icaoCode: "A388", iataCode: "380", firstFlightYear: 2005, status: "outOfProduction",
    wingspan: 79.75, length: 72.72, height: 24.09,
    mtow: 575000, range: 15200, cruiseSpeed: 903, passengerCapacity: 853,
    engineType: "turbofan", engineCount: 4,
    visualFeatures: [
      "Vollständig durchgängiges Oberdeck über die gesamte Rumpflänge",
      "Runder Oberdeck-Querschnitt – kein Buckel (Gegensatz zu B747)",
      "Extrem breites Fahrwerk – 6-Rad-Hauptfahrwerke je Seite",
      "4 Triebwerke: EA GP7200 oder Rolls-Royce Trent 970",
      "Spannweite knapp 80 m – deutlich breiter als alle anderen Passagierflugzeuge"
    ],
    lookalikes: ["B748"]
  },
  {
    manufacturer: "Boeing", family: "737", variant: "737-800",
    icaoCode: "B738", iataCode: "738", firstFlightYear: 1998, status: "inProduction",
    wingspan: 35.79, length: 39.47, height: 12.55,
    mtow: 79016, range: 5765, cruiseSpeed: 842, passengerCapacity: 162,
    engineType: "turbofan", engineCount: 2,
    visualFeatures: [
      "CFM56-Triebwerke: flache Unterseite (abgeflacht, nicht kreisrund)",
      "Triebwerke weit vor dem Flügel und tiefer als bei Airbus A320",
      "'Hamster-Backen' – ovaler Triebwerkseinlass charakteristisch",
      "Split-Scimitar-Winglets optional – kein Standard wie bei neo-Airbus",
      "Sehr niedrige Bodenfreiheit der Triebwerke"
    ],
    lookalikes: ["A20N", "B38M"]
  },
  {
    manufacturer: "Boeing", family: "777", variant: "777-300ER",
    icaoCode: "B77W", iataCode: "77W", firstFlightYear: 2003, status: "inProduction",
    wingspan: 64.8, length: 73.86, height: 18.55,
    mtow: 352441, range: 13649, cruiseSpeed: 905, passengerCapacity: 396,
    engineType: "turbofan", engineCount: 2,
    visualFeatures: [
      "GE90-115B – weltgrößter Turbofan (Einlass-Ø 3,25 m, größer als B737-Rumpf)",
      "Sechs-Rad-Hauptfahrwerk je Seite – einzigartig unter Zweistrahlern",
      "Abgeflachte Triebwerksunterseite knapp über dem Asphalt",
      "Raketenförmige, zylindrische Gondeln ohne sichtbare Nachlaufkante",
      "Breitester Rumpf aller noch produzierten Zweistrahler-Langstreckenflugzeuge"
    ],
    lookalikes: ["B77X", "B789"]
  },
  {
    manufacturer: "Boeing", family: "787", variant: "787-9",
    icaoCode: "B789", iataCode: "789", firstFlightYear: 2013, status: "inProduction",
    wingspan: 60.12, length: 62.81, height: 17.02,
    mtow: 254011, range: 14140, cruiseSpeed: 903, passengerCapacity: 296,
    engineType: "turbofan", engineCount: 2,
    visualFeatures: [
      "Wellenschnitt ('Sägezahn') an Triebwerkseinläufen – akustisches Design",
      "Stark geschwungene Flügeloberseite – markanter Knick zur Wingspitze",
      "Karbonfaser-Rumpf: leicht dunkles Finish, keine Nieten sichtbar",
      "Größere, ovale Kabinenfenster als bei Aluminium-Rümpfen",
      "GEnx oder Trent 1000 – sehr breite Gondeln mit 'Sägezahn'-Austritt"
    ],
    lookalikes: ["A359", "A330neo"]
  },
  {
    manufacturer: "Boeing", family: "747", variant: "747-8I",
    icaoCode: "B748", iataCode: "748", firstFlightYear: 2010, status: "outOfProduction",
    wingspan: 68.4, length: 76.25, height: 19.35,
    mtow: 447696, range: 14815, cruiseSpeed: 988, passengerCapacity: 467,
    engineType: "turbofan", engineCount: 4,
    visualFeatures: [
      "Charakteristischer Buckel (Oberdeck vorne) – Erkennungsmerkmal der 747-Familie",
      "4 Triebwerke (GEnx-2B67) – bei modernen Passagierfliegern nur 747 und A380",
      "Geschwungene Flügelspitzen der -8-Variante (anders als 747-400)",
      "Verlängerter Rumpf gegenüber 747-400 (sichtbar durch mehr Fenstergruppen)",
      "Knickflügel-Profil – äußeres Flügelpanel leicht nach unten geneigt"
    ],
    lookalikes: ["A388", "B744"]
  },
  {
    manufacturer: "Embraer", family: "E-Jet E2", variant: "E195-E2",
    icaoCode: "E295", iataCode: "295", firstFlightYear: 2019, status: "inProduction",
    wingspan: 31.04, length: 41.5, height: 10.68,
    mtow: 61000, range: 4800, cruiseSpeed: 870, passengerCapacity: 120,
    engineType: "turbofan", engineCount: 2,
    visualFeatures: [
      "Elegant schmale Nase mit feiner Cockpitfensterlinie",
      "Hochgelegte Flügel mit kurzem Rumpf-Überhang vorne",
      "Sehr enge Triebwerk-Flügel-Integration – fast anliegend am Flügel",
      "PW1900G GTF – identifizierbar durch breiteren Einlass als PW1500G",
      "Kleiner als A220-300, aber ähnliche Kabinenwirtschaftlichkeit"
    ],
    lookalikes: ["BCS3", "CRJ9"]
  },
  {
    manufacturer: "ATR", family: "ATR 72", variant: "ATR 72-600",
    icaoCode: "AT76", iataCode: "AT7", firstFlightYear: 2009, status: "inProduction",
    wingspan: 27.05, length: 27.17, height: 7.65,
    mtow: 23000, range: 1528, cruiseSpeed: 510, passengerCapacity: 78,
    engineType: "turboprop", engineCount: 2,
    visualFeatures: [
      "Hochdecker – Flügel oben am Rumpf (Gegensatz zu fast allen Jets)",
      "T-Leitwerk – Höhenleitwerk hoch oben am Seitenleitwerk",
      "6-Blatt-Propeller (PW127M) – sichtbar und unverkennbar",
      "Sehr kleiner, kurzer Rumpf mit niedrigem Boden (kein Airbridge nötig)",
      "Hecktreppe extern sichtbar – typisches Regional-Merkmal"
    ],
    lookalikes: ["DH8D", "AT42"]
  },
  {
    manufacturer: "Boeing", family: "737 MAX", variant: "737 MAX 8",
    icaoCode: "B38M", iataCode: "7M8", firstFlightYear: 2016, status: "inProduction",
    wingspan: 35.9, length: 39.52, height: 12.3,
    mtow: 82191, range: 6570, cruiseSpeed: 839, passengerCapacity: 178,
    engineType: "turbofan", engineCount: 2,
    visualFeatures: [
      "Markante AT-Winglets ('Advanced Technology') – gespalten, zeigen nach oben UND unten",
      "CFM LEAP-1B mit größerem Fan-Durchmesser als CFM56 der 737 NG – höher gesetzte Gondeln",
      "Triebwerksunterseite nur leicht abgeflacht (weniger als bei der NG-Generation)",
      "Verlängertes Bugfahrwerk – Rumpf wirkt im Stand minimal angehoben",
      "Neu geformter, verlängerter Heckkonus (aerodynamischer Tailcone)"
    ],
    lookalikes: ["B738", "A20N", "A21N"]
  },
  {
    manufacturer: "Airbus", family: "A320", variant: "A321neo",
    icaoCode: "A21N", iataCode: "32Q", firstFlightYear: 2016, status: "inProduction",
    wingspan: 35.8, length: 44.51, height: 11.76,
    mtow: 97000, range: 7400, cruiseSpeed: 833, passengerCapacity: 220,
    engineType: "turbofan", engineCount: 2,
    visualFeatures: [
      "Längster Rumpf der A320-Familie – sehr gestreckte Silhouette",
      "Sharklet-Winglets wie A320neo, aber an deutlich längerem Rumpf",
      "Vier Türpaare bzw. zusätzliche Over-Wing-Exits je nach Konfiguration",
      "CFM LEAP-1A oder PW1100G mit breitem Einlass (neo-Merkmal)",
      "Gegenüber der A320neo: gleicher Querschnitt, aber rund 7 m länger"
    ],
    lookalikes: ["A20N", "B38M", "B739"]
  },
  {
    manufacturer: "Airbus", family: "A330", variant: "A330-300",
    icaoCode: "A333", iataCode: "333", firstFlightYear: 1992, status: "outOfProduction",
    wingspan: 60.3, length: 63.69, height: 16.83,
    mtow: 242000, range: 11750, cruiseSpeed: 871, passengerCapacity: 290,
    engineType: "turbofan", engineCount: 2,
    visualFeatures: [
      "Großer Zweistrahl-Widebody mit kleiner, fast senkrechter Wingtip-Fence (kein geschwungenes Blended Winglet)",
      "Glänzender Aluminiumrumpf (kein mattes Karbon wie A350), eckigere Cockpitfenster",
      "Rumpf und Flügel nahezu identisch zur vierstrahligen A340 – aber nur 2 Triebwerke",
      "CF6-80E1, Trent 700 oder PW4000 – klassische runde Gondeln ohne Sägezahn",
      "Gegenüber der A330neo: kürzere Gondeln, alte Wingtip-Fence statt Sharklets"
    ],
    lookalikes: ["A359", "B763", "B789"]
  },
  {
    manufacturer: "Boeing", family: "767", variant: "767-300ER",
    icaoCode: "B763", iataCode: "763", firstFlightYear: 1988, status: "outOfProduction",
    wingspan: 47.57, length: 54.94, height: 15.85,
    mtow: 186880, range: 11070, cruiseSpeed: 851, passengerCapacity: 269,
    engineType: "turbofan", engineCount: 2,
    visualFeatures: [
      "Semi-Widebody: schmaler als 777/A330, 2-3-2-Bestuhlung (7 Sitze pro Reihe)",
      "Meist ohne Winglets – gerade Flügelspitzen (nur einige Nachrüstungen)",
      "Klassische Boeing-Nase und -Leitwerk, ähnlich 757, aber breiterer Rumpf",
      "Lange, schlanke Gondeln (CF6-80C2, PW4000 oder RB211)",
      "Hauptfahrwerk mit nur 4 Rädern je Bein – schlanker Eindruck am Boden"
    ],
    lookalikes: ["A333", "B788", "A332"]
  },
  {
    manufacturer: "Embraer", family: "E-Jet", variant: "E190 (E1)",
    icaoCode: "E190", iataCode: "E90", firstFlightYear: 2004, status: "outOfProduction",
    wingspan: 28.72, length: 36.24, height: 10.55,
    mtow: 51800, range: 4537, cruiseSpeed: 829, passengerCapacity: 114,
    engineType: "turbofan", engineCount: 2,
    visualFeatures: [
      "'Double-Bubble'-Rumpfquerschnitt – leicht versetzte obere und untere Rundung",
      "Klassische gebogene Winglets (im Gegensatz zur randlosen Flügelspitze der E2)",
      "Unterflügel-Triebwerke (GE CF34-10E) – schmalerer Einlass als die GTF der E2",
      "Vierfenster-Cockpit mit gerundeten Ecken, kurze spitze Nase",
      "Kompakterer Eindruck als die E195-E2 bei sehr ähnlicher Grundform"
    ],
    lookalikes: ["E295", "CRJ9", "BCS3"]
  },
  {
    manufacturer: "Bombardier", family: "CRJ", variant: "CRJ900",
    icaoCode: "CRJ9", iataCode: "CR9", firstFlightYear: 2001, status: "outOfProduction",
    wingspan: 24.85, length: 36.4, height: 7.51,
    mtow: 38330, range: 2876, cruiseSpeed: 829, passengerCapacity: 90,
    engineType: "turbofan", engineCount: 2, enginePosition: "rear",
    visualFeatures: [
      "Zwei Triebwerke am Heck montiert (aft-fuselage) statt unter den Flügeln",
      "T-Leitwerk – Höhenleitwerk hoch am Seitenleitwerk",
      "Sehr langer, schlanker, niedriger Rumpf mit tief angesetzten Flügeln",
      "Kleine ovale Kabinenfenster und geringe Bodenfreiheit",
      "GE CF34-8C5 – kompakte Gondeln seitlich am hinteren Rumpf"
    ],
    lookalikes: ["E190", "F100", "E295"]
  },
  {
    manufacturer: "De Havilland Canada", family: "Dash 8", variant: "Dash 8 Q400",
    icaoCode: "DH8D", iataCode: "DH4", firstFlightYear: 1998, status: "outOfProduction",
    wingspan: 28.42, length: 32.84, height: 8.34,
    mtow: 29574, range: 2040, cruiseSpeed: 667, passengerCapacity: 90,
    engineType: "turboprop", engineCount: 2,
    visualFeatures: [
      "Hochdecker mit T-Leitwerk und sehr langem, schlankem Rumpf",
      "Zwei große 6-Blatt-Propeller (PW150A) – schnellster Serien-Turboprop seiner Klasse",
      "Lange Hauptfahrwerksbeine, fahren nach hinten in die Triebwerksgondeln ein",
      "Spitzere Nase und höhere Reisegeschwindigkeit als die ATR-Familie",
      "Triebwerksgondeln ragen deutlich über die Flügelvorderkante hinaus"
    ],
    lookalikes: ["AT76", "AT42"]
  },
  {
    manufacturer: "Fokker", family: "Fokker 100", variant: "Fokker 100",
    icaoCode: "F100", iataCode: "100", firstFlightYear: 1986, status: "outOfProduction",
    wingspan: 28.08, length: 35.53, height: 8.5,
    mtow: 44450, range: 3170, cruiseSpeed: 845, passengerCapacity: 109,
    engineType: "turbofan", engineCount: 2, enginePosition: "rear",
    visualFeatures: [
      "Zwei Rolls-Royce Tay am Heck montiert – klassisches Jet-Layout der 1980er",
      "T-Leitwerk und langer, schlanker Rumpf ohne Winglets",
      "Lange, gerade Tragflächen mit geringer Pfeilung, tief angesetzt",
      "Spitze, schmale Nase mit schmalem Cockpitfenster-Band",
      "Sehr ähnlich der Fokker 70, aber mit längerem Rumpf (rund 5 m mehr)"
    ],
    lookalikes: ["CRJ9", "E190"]
  }
];

// ── State ──────────────────────────────────────────────────────────────────────
const state = {
  tab: 'database',
  search: '',
  mfr: '',
  compareList: JSON.parse(localStorage.getItem('sd_compare') || '[]'),
  detailStack: [],   // ICAO stack for back navigation
  quiz: null,        // {answer, options[], picked, score, total, streak, best}
};

// ── DOM refs ───────────────────────────────────────────────────────────────────
const appEl     = document.getElementById('app');
const detailEl  = document.getElementById('detail-overlay');
const pickerEl  = document.getElementById('picker-sheet');
const pickerIn  = document.getElementById('picker-input');
const pickerList = document.getElementById('picker-list');
const tabs      = document.querySelectorAll('.tab');

// ── Utils ──────────────────────────────────────────────────────────────────────
const find = icao => AIRCRAFT.find(a => a.icaoCode === icao);
const manufacturers = [...new Set(AIRCRAFT.map(a => a.manufacturer))].sort();

function mfrColor(m) {
  return { Airbus: '#0077CC', Boeing: '#CC2200', Embraer: '#12A642', ATR: '#E65100' }[m] || '#4D5259';
}

function statusBadge(s) {
  const map = {
    inProduction:    ['badge-green', 'Produktion'],
    outOfProduction: ['badge-amber', 'Außer Prod.'],
    retired:         ['badge-red',   'Ausgemustert'],
    prototype:       ['badge-gray',  'Prototyp'],
  };
  const [cls, lbl] = map[s] || ['badge-gray', s];
  return `<span class="badge ${cls}">${lbl}</span>`;
}

function engineBadge(type, count) {
  const lbl = type === 'turboprop' ? 'Prop' : 'Jet';
  return `<span class="badge badge-blue">${count}× ${lbl}</span>`;
}

function fmt(n, dec = 0) {
  if (!n) return '–';
  return n.toLocaleString('de-DE', { maximumFractionDigits: dec });
}

function saveCompare() {
  localStorage.setItem('sd_compare', JSON.stringify(state.compareList));
}

function filteredAircraft() {
  const q = state.search.toLowerCase();
  return AIRCRAFT.filter(a => {
    const matchQ = !q || [a.variant, a.manufacturer, a.family, a.icaoCode, a.iataCode]
      .some(s => s.toLowerCase().includes(q));
    const matchM = !state.mfr || a.manufacturer === state.mfr;
    return matchQ && matchM;
  });
}

// ── Fotos: Wikimedia Commons (Standard) + eigene Fotos (Override) ───────────────
// Hier stehen NUR die echten Commons-Dateinamen. Urheber & Lizenz werden zur
// Laufzeit LIVE aus der Commons-API geladen (fetchCommonsCredit) – so sind die
// Angaben immer korrekt und werden niemals im Code "geraten".
const WIKI_PHOTO = {
  BCS3: 'Swiss, HB-JCC, Airbus A220-300.jpg',
  A20N: 'Hannover Airport SKY express Airbus A320-251N SX-TEC (DSC00198).jpg',
  A359: 'Lufthansa, D-AIXO, Airbus A350-941 (49581146632).jpg',
  A388: 'Singapore Airlines Airbus A380-800 9V-SKN (7721163326).jpg',
  B738: 'WestJet Boeing 737-800 C-GXWJ (24734543535).jpg',
  B77W: 'Air Canada Boeing 777-300ER C-FITU (28483755286).jpg',
  B789: 'United Airlines, N17963, Boeing 787-9 Dreamliner (35595342772).jpg',
  B748: 'Lufthansa Boeing 747-8i.jpg',
  E295: 'Embraer E195-E2 (ERJ 190-400 STD) PS-AEF.jpg',
  AT76: 'Stobart Air ATR 72-600 (EI-FSL) at Manchester Airport.jpg',
  B38M: 'Norwegian Air Sweden SE-RTB Boeing 737-MAX 8 Amsterdam Airport Schiphol (AMS EHAM) (52724014741).jpg',
  A21N: 'Aegean Airlines, SX-NAA, Airbus A321-271NX (51007089432).jpg',
  A333: 'Lufthansa Airbus A330-300 D-AIKB (7721065166) (2).jpg',
  B763: 'KLM Boeing 767-300ER PH-BZM (2193203008).jpg',
  E190: 'Embraer ERJ-190-100LR 190LR (PH-EZH) 03.jpg',
  CRJ9: 'Eurowings (Lufthansa Regional) Bombardier CRJ900 at Berlin Tegel Airport.JPG',
  DH8D: 'Wideroe, LN-WDL, Bombardier Dash 8 Q400 (42435285354).jpg',
  F100: 'Helvetic Airways Fokker 100 (F-28-0100) HB-JVG (25446724953).jpg',
};

const commonsImg  = n => `https://commons.wikimedia.org/wiki/Special:FilePath/${encodeURIComponent(n)}?width=900`;
const commonsPage = n => `https://commons.wikimedia.org/wiki/File:${encodeURIComponent(n)}`;
const commonsApi  = n => `https://commons.wikimedia.org/w/api.php?action=query&format=json&origin=*` +
  `&prop=imageinfo&iiprop=extmetadata&iiextmetadatafilter=Artist|LicenseShortName|LicenseUrl&titles=File:${encodeURIComponent(n)}`;

// Urheber & Lizenz live aus Commons holen → {artist, license} oder null (offline).
async function fetchCommonsCredit(name) {
  try {
    const r = await fetch(commonsApi(name));
    const j = await r.json();
    const pages = j.query.pages;
    const page = pages[Object.keys(pages)[0]];
    const ext = page.imageinfo[0].extmetadata;
    const strip = h => (h || '').replace(/<[^>]*>/g, '').replace(/\s+/g, ' ').trim();
    const artist = strip(ext.Artist && ext.Artist.value) || 'Unbekannt';
    const license = strip(ext.LicenseShortName && ext.LicenseShortName.value) || '';
    return { artist, license };
  } catch (e) {
    return null;
  }
}

// ── Eigene Fotos: IndexedDB (Schlüssel = ICAO, Wert = data-URL) ──────────────────
const PHOTO_DB = 'spotterdex', PHOTO_STORE = 'photos';
function openPhotoDb() {
  return new Promise((res, rej) => {
    const rq = indexedDB.open(PHOTO_DB, 1);
    rq.onupgradeneeded = () => rq.result.createObjectStore(PHOTO_STORE);
    rq.onsuccess = () => res(rq.result);
    rq.onerror = () => rej(rq.error);
  });
}
async function getUserPhoto(icao) {
  try {
    const db = await openPhotoDb();
    return await new Promise(res => {
      const rq = db.transaction(PHOTO_STORE, 'readonly').objectStore(PHOTO_STORE).get(icao);
      rq.onsuccess = () => res(rq.result || null);
      rq.onerror = () => res(null);
    });
  } catch (e) { return null; }
}
async function setUserPhoto(icao, dataUrl) {
  const db = await openPhotoDb();
  return new Promise(res => {
    const rq = db.transaction(PHOTO_STORE, 'readwrite').objectStore(PHOTO_STORE).put(dataUrl, icao);
    rq.onsuccess = () => res(true); rq.onerror = () => res(false);
  });
}
async function delUserPhoto(icao) {
  const db = await openPhotoDb();
  return new Promise(res => {
    const rq = db.transaction(PHOTO_STORE, 'readwrite').objectStore(PHOTO_STORE).delete(icao);
    rq.onsuccess = () => res(true); rq.onerror = () => res(false);
  });
}

// Hochgeladenes Bild verkleinern (spart Speicher) → JPEG-data-URL
function fileToDataUrl(file, maxW = 1000) {
  return new Promise((res, rej) => {
    const img = new Image();
    const url = URL.createObjectURL(file);
    img.onload = () => {
      const scale = Math.min(1, maxW / img.width);
      const w = Math.round(img.width * scale), h = Math.round(img.height * scale);
      const c = document.createElement('canvas');
      c.width = w; c.height = h;
      c.getContext('2d').drawImage(img, 0, 0, w, h);
      URL.revokeObjectURL(url);
      res(c.toDataURL('image/jpeg', 0.82));
    };
    img.onerror = () => { URL.revokeObjectURL(url); rej(new Error('img')); };
    img.src = url;
  });
}

// Datei-Dialog öffnen → speichern → Fotobereich neu rendern
function pickPhoto(icao) {
  const input = document.createElement('input');
  input.type = 'file'; input.accept = 'image/*';
  input.onchange = async () => {
    const file = input.files && input.files[0];
    if (!file) return;
    try {
      const dataUrl = await fileToDataUrl(file);
      await setUserPhoto(icao, dataUrl);
      renderPhoto(icao);
    } catch (e) { /* ignorieren */ }
  };
  input.click();
}

// Fotobereich der Detailansicht asynchron füllen.
// Priorität: eigenes Foto > Wikimedia-Standard > nur "Hinzufügen"-Button.
async function renderPhoto(icao) {
  const wrap = document.getElementById('photo-wrap');
  if (!wrap) return;
  const userPhoto = await getUserPhoto(icao);
  const wiki = WIKI_PHOTO[icao];

  if (userPhoto) {
    wrap.innerHTML = `
      <div class="photo-card">
        <img class="ac-photo" src="${userPhoto}" alt="Eigenes Foto">
        <span class="photo-credit static"><b>Eigenes Foto</b></span>
      </div>
      <div class="photo-actions">
        <button class="photo-btn" data-photo-pick>Foto ändern</button>
        <button class="photo-btn danger" data-photo-del>Entfernen</button>
      </div>`;
  } else if (wiki) {
    wrap.innerHTML = `
      <div class="photo-card">
        <img class="ac-photo" src="${commonsImg(wiki)}" alt="Foto" loading="lazy"
             referrerpolicy="no-referrer"
             onerror="this.closest('.photo-card').classList.add('failed')">
        <a class="photo-credit" id="photo-credit" href="${commonsPage(wiki)}" target="_blank" rel="noopener">
          Foto: Wikimedia Commons ↗
        </a>
      </div>
      <div class="photo-actions">
        <button class="photo-btn" data-photo-pick>Eigenes Foto hinzufügen</button>
      </div>`;
    // Echte Attribution live nachladen (keine erfundenen Angaben)
    fetchCommonsCredit(wiki).then(c => {
      const el = document.getElementById('photo-credit');
      if (el && c) el.innerHTML = `Foto: ${c.artist}${c.license ? ' · ' + c.license : ''} · Wikimedia ↗`;
    });
  } else {
    wrap.innerHTML = `
      <div class="photo-actions">
        <button class="photo-btn" data-photo-pick>Eigenes Foto hinzufügen</button>
      </div>`;
  }

  const pick = wrap.querySelector('[data-photo-pick]');
  if (pick) pick.addEventListener('click', () => pickPhoto(icao));
  const del = wrap.querySelector('[data-photo-del]');
  if (del) del.addEventListener('click', async () => { await delUserPhoto(icao); renderPhoto(icao); });
}

// ── Silhouette (Canvas) ────────────────────────────────────────────────────────
function drawSilhouette(canvas, ac, color) {
  const ctx = canvas.getContext('2d');
  const W = canvas.width, H = canvas.height;
  ctx.clearRect(0, 0, W, H);

  const sx = (W * 0.88) / ac.wingspan;
  const sy = (H * 0.86) / ac.length;
  const s  = Math.min(sx, sy);

  const cx = W / 2, cy = H / 2;
  const fw = Math.max(5, ac.wingspan * 0.042 * s);
  const fl = ac.length * s;

  // wing attachment point: ~28% from nose = -14% from center
  const wingY = cy - fl * 0.08;
  const ws    = ac.wingspan / 2 * s;
  const wc    = ac.length * 0.11 * s;  // root chord

  // tail
  const tailY = cy + fl * 0.40;
  const ts    = ac.wingspan * 0.24 * s;
  const tc    = ac.length * 0.055 * s;

  ctx.fillStyle = color;

  // fuselage
  ctx.beginPath();
  ctx.ellipse(cx, cy, fw, fl / 2, 0, 0, Math.PI * 2);
  ctx.fill();

  // wings (swept)
  for (const sign of [-1, 1]) {
    ctx.beginPath();
    ctx.moveTo(cx + sign * fw * 0.7, wingY - wc * 0.15);
    ctx.lineTo(cx + sign * ws,       wingY + wc * 0.65);
    ctx.lineTo(cx + sign * ws * 0.93, wingY + wc);
    ctx.lineTo(cx + sign * fw * 0.7, wingY + wc * 0.55);
    ctx.closePath();
    ctx.fill();
  }

  // horizontal tail
  for (const sign of [-1, 1]) {
    ctx.beginPath();
    ctx.moveTo(cx + sign * fw * 0.6, tailY);
    ctx.lineTo(cx + sign * ts,       tailY + tc * 0.7);
    ctx.lineTo(cx + sign * ts * 0.9, tailY + tc * 1.3);
    ctx.lineTo(cx + sign * fw * 0.6, tailY + tc);
    ctx.closePath();
    ctx.fill();
  }

  // engines
  if (ac.enginePosition === 'rear') {
    // Heck-montiert (z. B. CRJ900, Fokker 100): dicht am Rumpf, weit hinten
    const ex = fw * 1.75;
    const eyR = cy + fl * 0.20;
    const ewR = fw * 0.6;
    const ehR = ac.length * 0.075 * s;
    for (const sign of [-1, 1]) {
      ctx.beginPath();
      ctx.ellipse(cx + sign * ex, eyR, ewR, ehR, 0, 0, Math.PI * 2);
      ctx.fill();
    }
  } else {
    // Flügel-montiert (Standard): 2 Triebwerke, oder 4 weiter außen verteilt
    const engSpans = ac.engineCount >= 4
      ? [ws * 0.32, ws * 0.62]
      : [ws * 0.48];
    const ew = fw * 0.52;
    const eh = ac.length * 0.065 * s;
    const ey = wingY + wc * 0.22;

    for (const ex of engSpans) {
      for (const sign of [-1, 1]) {
        ctx.beginPath();
        ctx.ellipse(cx + sign * ex, ey, ew, eh, 0, 0, Math.PI * 2);
        ctx.fill();
      }
    }
  }
}

// ── Database view ──────────────────────────────────────────────────────────────
function renderDatabase() {
  const list = filteredAircraft();

  const chipsHtml = ['', ...manufacturers].map(m =>
    `<button class="chip${state.mfr === m ? ' active' : ''}" data-mfr="${m}">
      ${m || 'Alle'}
    </button>`
  ).join('');

  const cardsHtml = list.length
    ? list.map(a => {
        const inCmp = state.compareList.includes(a.icaoCode);
        return `
          <div class="aircraft-card" data-icao="${a.icaoCode}" role="button" tabindex="0" aria-label="${a.variant}">
            <div class="card-accent" style="background:${mfrColor(a.manufacturer)}"></div>
            <div class="card-body">
              <div class="card-variant">${a.variant}</div>
              <div class="card-meta">
                <span>${a.manufacturer}</span>
                ${statusBadge(a.status)}
                ${engineBadge(a.engineType, a.engineCount)}
              </div>
            </div>
            <button class="card-add${inCmp ? ' in-compare' : ''}" data-add="${a.icaoCode}"
              aria-label="${inCmp ? 'Aus Vergleich entfernen' : 'Zum Vergleich hinzufügen'}"
              title="${inCmp ? 'Aus Vergleich entfernen' : 'Zum Vergleich hinzufügen'}">
              <svg viewBox="0 0 24 24">
                ${inCmp
                  ? '<polyline points="20 6 9 17 4 12"/>'
                  : '<line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>'}
              </svg>
            </button>
            <span class="card-chevron">
              <svg viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"/></svg>
            </span>
          </div>`;
      }).join('')
    : `<div class="empty">
        <div class="empty-icon">✈️</div>
        <div class="empty-title">Keine Treffer</div>
        <p>Versuche einen anderen Suchbegriff oder filter.</p>
      </div>`;

  appEl.innerHTML = `
    <div id="view-database" class="view active">
      <div class="view-header">
        <h1 class="view-title">Datenbank</h1>
        <div class="search-bar">
          <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>
          <input type="search" id="search-input" placeholder="Typ, Hersteller, ICAO …"
            value="${state.search}" autocomplete="off" autocorrect="off">
        </div>
        <div class="filter-chips">${chipsHtml}</div>
      </div>
      <div class="aircraft-list">${cardsHtml}</div>
    </div>`;

  // bind search
  document.getElementById('search-input').addEventListener('input', e => {
    state.search = e.target.value;
    renderDatabase();
    document.getElementById('search-input').focus();
  });
}

// ── Detail view ────────────────────────────────────────────────────────────────
function openDetail(icao) {
  const a = find(icao);
  if (!a) return;
  state.detailStack.push(icao);

  const inCmp = state.compareList.includes(icao);
  const color = mfrColor(a.manufacturer);

  const lookalikesHtml = (a.lookalikes || [])
    .filter(code => find(code))
    .map(code => `<button class="lookalike-chip" data-icao="${code}">${find(code).variant}</button>`)
    .join('') || '<span style="color:var(--text2);font-size:14px">Keine Einträge in der Datenbank</span>';

  detailEl.innerHTML = `
    <div class="detail-nav">
      <button class="back-btn" id="detail-back">
        <svg viewBox="0 0 24 24"><polyline points="15 18 9 12 15 6"/></svg>
        Zurück
      </button>
    </div>

    <div class="detail-header">
      <div class="detail-mfr">${a.manufacturer} · ${a.family}</div>
      <div class="detail-name">${a.variant}</div>
      <div class="detail-codes">
        <span class="badge badge-blue">ICAO: ${a.icaoCode}</span>
        <span class="badge badge-gray">IATA: ${a.iataCode || '–'}</span>
        ${statusBadge(a.status)}
        ${a.firstFlightYear ? `<span class="badge badge-gray">Erstflug ${a.firstFlightYear}</span>` : ''}
      </div>
    </div>

    <div class="photo-wrap" id="photo-wrap"></div>

    <a class="detail-live" href="https://www.flightaware.com/live/aircrafttype/${encodeURIComponent(a.icaoCode)}" target="_blank" rel="noopener">
      <svg viewBox="0 0 24 24" width="18" height="18"><path d="M2 12h4l3-9 4 18 3-9h6"/></svg>
      <span>${a.variant} jetzt live verfolgen</span>
      <span class="live-ext">↗</span>
    </a>

    <div class="silhouette-label">Silhouette · Draufsicht</div>
    <div class="silhouette-wrap">
      <canvas id="silhouette-canvas" width="220" height="280"></canvas>
    </div>

    <div class="section">
      <div class="section-title">Technische Daten</div>
      <div class="specs-grid">
        <div class="spec-row"><span class="spec-label">Spannweite</span>
          <span class="spec-val">${fmt(a.wingspan, 1)}</span><span class="spec-unit">m</span></div>
        <div class="spec-row"><span class="spec-label">Länge</span>
          <span class="spec-val">${fmt(a.length, 1)}</span><span class="spec-unit">m</span></div>
        <div class="spec-row"><span class="spec-label">Höhe</span>
          <span class="spec-val">${fmt(a.height, 1)}</span><span class="spec-unit">m</span></div>
        <div class="spec-row"><span class="spec-label">MTOW</span>
          <span class="spec-val">${fmt(a.mtow / 1000, 1)}</span><span class="spec-unit">t</span></div>
        <div class="spec-row"><span class="spec-label">Reichweite</span>
          <span class="spec-val">${fmt(a.range)}</span><span class="spec-unit">km</span></div>
        <div class="spec-row"><span class="spec-label">Reisegeschw.</span>
          <span class="spec-val">${fmt(a.cruiseSpeed)}</span><span class="spec-unit">km/h</span></div>
        <div class="spec-row"><span class="spec-label">Passagiere</span>
          <span class="spec-val">${fmt(a.passengerCapacity)}</span></div>
        <div class="spec-row"><span class="spec-label">Triebwerke</span>
          <span class="spec-val">${a.engineCount}×</span>
          <span class="spec-unit">${a.engineType}</span></div>
      </div>
    </div>

    <div class="section">
      <div class="section-title">Erkennungsmerkmale</div>
      <div class="feature-list">
        ${(a.visualFeatures || []).map(f =>
          `<div class="feature-item"><span class="feature-dot">•</span>${f}</div>`
        ).join('')}
      </div>
    </div>

    <div class="section">
      <div class="section-title">Verwechslungspartner</div>
      <div class="lookalike-chips">${lookalikesHtml}</div>
    </div>

    <button class="detail-cta${inCmp ? ' added' : ''}" id="detail-cta-btn">
      <svg viewBox="0 0 24 24" width="18" height="18">
        ${inCmp
          ? '<polyline points="20 6 9 17 4 12"/>'
          : '<line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>'}
      </svg>
      ${inCmp ? 'Im Vergleich' : 'Zum Vergleich hinzufügen'}
    </button>`;

  // Draw silhouette
  requestAnimationFrame(() => {
    const canvas = document.getElementById('silhouette-canvas');
    if (canvas) drawSilhouette(canvas, a, color + 'CC');
  });

  // Foto laden (eigenes Foto > Wikimedia > nur Button)
  renderPhoto(icao);

  // Events
  document.getElementById('detail-back').addEventListener('click', closeDetail);
  document.getElementById('detail-cta-btn').addEventListener('click', () => {
    toggleCompare(icao);
    openDetail(icao);   // re-render to update button
    state.detailStack.pop(); // openDetail pushed again, remove duplicate
  });
  detailEl.querySelectorAll('.lookalike-chip').forEach(btn => {
    btn.addEventListener('click', () => openDetail(btn.dataset.icao));
  });

  detailEl.classList.add('open');
}

function closeDetail() {
  state.detailStack.pop();
  if (state.detailStack.length > 0) {
    // go back to previous
    const prev = state.detailStack.pop();
    openDetail(prev);
  } else {
    detailEl.classList.remove('open');
    setTimeout(() => { detailEl.innerHTML = ''; }, 300);
  }
}

// ── Compare view ───────────────────────────────────────────────────────────────
function renderCompare() {
  const list = state.compareList.map(find).filter(Boolean);
  const count = list.length;

  // Slots (up to 3)
  const slots = [0, 1, 2].map(i => {
    const a = list[i];
    if (a) {
      return `<div class="compare-slot filled">
        <div>
          <div class="slot-name">${a.variant}</div>
          <div class="slot-icao">${a.icaoCode}</div>
        </div>
        <button class="slot-rm" data-rm="${a.icaoCode}" aria-label="${a.variant} entfernen">×</button>
      </div>`;
    }
    return `<div class="compare-slot" data-pick="${i}">
      <span class="slot-add-icon">＋</span>
      <span class="slot-empty-text">Hinzufügen</span>
    </div>`;
  }).join('');

  // Wingspan visual
  let wingspanViz = '';
  if (count > 0) {
    const maxWs = Math.max(...list.map(a => a.wingspan));
    const rows = list.map((a, i) => {
      const colors = ['var(--blue)', 'var(--green)', 'var(--amber)'];
      const pct = (a.wingspan / maxWs * 100).toFixed(1);
      return `<div class="ws-row">
        <span class="ws-label">${a.variant}</span>
        <div class="ws-bar-bg"><div class="ws-bar" style="width:${pct}%;background:${colors[i]}"></div></div>
        <span class="ws-val">${fmt(a.wingspan, 1)} m</span>
      </div>`;
    }).join('');
    wingspanViz = `<div class="wingspan-viz">
      <div class="wingspan-viz-title">Spannweite im Verhältnis</div>
      ${rows}
    </div>`;
  }

  // Comparison table
  let tableHtml = '';
  if (count > 1) {
    const specs = [
      { label: 'Spannweite', key: 'wingspan',         unit: 'm',    dec: 1, higher: true },
      { label: 'Länge',      key: 'length',           unit: 'm',    dec: 1, higher: false },
      { label: 'MTOW',       key: 'mtow',             unit: 'kg',   dec: 0, higher: true,
        fmt: v => fmt(v / 1000, 1) + ' t' },
      { label: 'Reichweite', key: 'range',            unit: 'km',   dec: 0, higher: true },
      { label: 'Reisegeschw.',key: 'cruiseSpeed',     unit: 'km/h', dec: 0, higher: true },
      { label: 'Passagiere', key: 'passengerCapacity', unit: '',    dec: 0, higher: true },
    ];

    const headerCells = ['<th></th>', ...list.map(a =>
      `<th>${a.icaoCode}</th>`)].join('');

    const dataRows = specs.map(spec => {
      const vals = list.map(a => a[spec.key]);
      const maxV = Math.max(...vals);
      const minV = Math.min(...vals);
      const allSame = vals.every(v => v === vals[0]);

      const cells = list.map((a, i) => {
        const v = a[spec.key];
        const display = spec.fmt ? spec.fmt(v) : fmt(v, spec.dec) + (spec.unit ? ` ${spec.unit}` : '');
        let cls = '';
        if (!allSame) {
          cls = (spec.higher ? v === maxV : v === minV) ? ' class="val-best"'
              : (spec.higher ? v === minV : v === maxV) ? ' class="val-worst"' : '';
        }
        return `<td${cls}>${display}</td>`;
      }).join('');

      return `<tr><td>${spec.label}</td>${cells}</tr>`;
    }).join('');

    tableHtml = `
      <p class="section-title" style="padding: 0 var(--sp-m); margin-bottom:var(--sp-s)">
        Vergleich — <span style="color:var(--green)">Grün</span> = Bestwert
      </p>
      <div class="compare-table-wrap">
        <table class="compare-table">
          <thead><tr>${headerCells}</tr></thead>
          <tbody>${dataRows}</tbody>
        </table>
      </div>`;
  }

  const emptyHint = count === 0
    ? `<div class="empty">
        <div class="empty-icon">⚖️</div>
        <div class="empty-title">Noch keine Auswahl</div>
        <p>Füge bis zu 3 Flugzeuge über die Datenbank oder die Slots oben hinzu.</p>
      </div>` : '';

  appEl.innerHTML = `
    <div id="view-compare" class="view active">
      <div class="compare-header" style="padding-top:calc(var(--sp-m) + env(safe-area-inset-top))">
        <h1 class="view-title">
          Vergleich
          ${count > 0 ? `<span class="compare-badge">${count}</span>` : ''}
        </h1>
      </div>
      <div class="compare-slots">${slots}</div>
      ${wingspanViz}
      ${tableHtml}
      ${emptyHint}
    </div>`;

  document.querySelectorAll('.slot-rm').forEach(btn => {
    btn.addEventListener('click', e => {
      e.stopPropagation();
      toggleCompare(btn.dataset.rm);
      renderCompare();
    });
  });
  document.querySelectorAll('[data-pick]').forEach(slot => {
    slot.addEventListener('click', () => openPicker());
  });
}

// ── Info view ──────────────────────────────────────────────────────────────────
function renderInfo() {
  appEl.innerHTML = `
    <div id="view-info" class="view active">
      <div class="view-header">
        <h1 class="view-title">Info</h1>
      </div>
      <div class="info-body">
        <div class="info-card">
          <div class="info-card-title">✈️ SpotterDex</div>
          <p>Dein digitales Handbuch für Planespotter. 18 Flugzeugtypen erkennen, vergleichen und im Quiz meistern — vollständig offline.</p>
        </div>
        <div class="info-card">
          <div class="info-card-title">Daten & Quellen</div>
          <p>Die Flugzeugdaten wurden aus öffentlichen Quellen zusammengestellt:</p>
          <ul>
            <li>Wikidata (CC0)</li>
            <li>Jane's All the World's Aircraft</li>
            <li>Herstellerdatenblätter (öffentlich)</li>
          </ul>
          <p style="margin-top:8px">Maße in SI (m / kg / km / km·h⁻¹). Fotos: Wikimedia Commons – Urheber und Lizenz werden je Bild live aus der Quelle geladen und unter dem Foto angezeigt. Eigene Fotos kannst du in der Detailansicht hinzufügen.</p>
        </div>
        <div class="info-card">
          <div class="info-card-title">Datenschutz</div>
          <p>SpotterDex sammelt keine Nutzerdaten und enthält keine Tracker oder Analyse-Tools. Datenbank, Suche, Vergleich und Quiz funktionieren vollständig offline und on-device. Eigene Fotos bleiben ausschließlich lokal auf deinem Gerät.</p>
          <p style="margin-top:8px">Optional &amp; nur bei Bedarf: Referenzfotos werden online von Wikimedia Commons geladen, und „Live verfolgen" öffnet FlightAware in einem neuen Tab. Beim Aufruf dieser externen Dienste gelten deren Datenschutzbestimmungen.</p>
        </div>
        <div class="info-card">
          <div class="info-card-title">Technologie</div>
          <ul>
            <li>Vanilla HTML / CSS / JavaScript</li>
            <li>Progressive Web App (PWA)</li>
            <li>Offline via Service Worker</li>
            <li>Installierbar auf iOS & Android</li>
          </ul>
        </div>
        <div class="info-card">
          <div class="info-card-title">iOS-App</div>
          <p>SpotterDex ist auch als native iOS-App (SwiftUI, iOS 17+) verfügbar – mit on-device ML-Erkennung per Foto und Spaced-Repetition-Lernmodi.</p>
        </div>
        <p class="info-version">SpotterDex Web v1.2 · ${new Date().getFullYear()}</p>
      </div>
    </div>`;
}

// ── Quiz view ──────────────────────────────────────────────────────────────────
const QUIZ_BEST_KEY = 'sd_quiz_best';

// Fisher-Yates Shuffle (nicht-mutierend)
function shuffle(arr) {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

// 4 Antwortoptionen: richtige Antwort + bis zu 3 Distraktoren.
// Bevorzugt die Verwechslungspartner (lookalikes) → didaktisch wertvoller,
// danach mit zufälligen weiteren Typen aufgefüllt.
function buildQuizOptions(answer) {
  const distractors = [];
  const looks = (answer.lookalikes || [])
    .map(find).filter(Boolean)
    .filter(a => a.icaoCode !== answer.icaoCode);

  for (const a of shuffle(looks)) {
    if (distractors.length < 3 && !distractors.some(d => d.icaoCode === a.icaoCode)) {
      distractors.push(a);
    }
  }
  if (distractors.length < 3) {
    const rest = shuffle(AIRCRAFT.filter(a =>
      a.icaoCode !== answer.icaoCode &&
      !distractors.some(d => d.icaoCode === a.icaoCode)));
    for (const a of rest) {
      if (distractors.length < 3) distractors.push(a);
    }
  }
  return shuffle([answer, ...distractors.slice(0, 3)]);
}

// Neue Frage – Score/Serie/Bestwert bleiben über die Session erhalten.
function newQuizRound() {
  const answer = AIRCRAFT[Math.floor(Math.random() * AIRCRAFT.length)];
  const prev = state.quiz || {
    score: 0, total: 0, streak: 0,
    best: parseInt(localStorage.getItem(QUIZ_BEST_KEY) || '0', 10),
  };
  state.quiz = {
    answer: answer.icaoCode,
    options: buildQuizOptions(answer).map(a => a.icaoCode),
    picked: null,
    score: prev.score,
    total: prev.total,
    streak: prev.streak,
    best: prev.best,
  };
  renderQuiz();
}

function answerQuiz(icao) {
  const q = state.quiz;
  if (!q || q.picked) return;          // Doppel-Taps ignorieren
  q.picked = icao;
  q.total += 1;
  if (icao === q.answer) {
    q.score += 1;
    q.streak += 1;
    if (q.streak > q.best) {
      q.best = q.streak;
      localStorage.setItem(QUIZ_BEST_KEY, String(q.best));
    }
  } else {
    q.streak = 0;
  }
  renderQuiz();
}

function renderQuiz() {
  if (!state.quiz) { newQuizRound(); return; }   // erste Frage erzeugen
  const q = state.quiz;
  const answer = find(q.answer);
  const answered = q.picked !== null;
  const correct = answered && q.picked === q.answer;
  const acc = q.total ? Math.round(q.score / q.total * 100) : 0;

  const optionsHtml = q.options.map(code => {
    const a = find(code);
    let cls = 'quiz-option';
    if (answered) {
      if (code === q.answer) cls += ' correct';
      else if (code === q.picked) cls += ' wrong';
      else cls += ' dim';
    }
    return `<button class="${cls}" data-quiz-pick="${code}"${answered ? ' disabled' : ''}>
      <span class="qo-name">${a.variant}</span>
      <span class="qo-mfr">${a.manufacturer}</span>
    </button>`;
  }).join('');

  const feedbackText = answered
    ? `<div class="quiz-feedback ${correct ? 'ok' : 'no'}">
        ${correct ? '✓ Richtig!' : `✗ Es ist die <b>${answer.variant}</b>`}
       </div>`
    : `<p class="quiz-hint">Welcher Flugzeugtyp zeigt diese Silhouette?</p>`;

  const nextBtn = answered
    ? `<button class="quiz-next" id="quiz-next">Nächste Frage →</button>` : '';

  appEl.innerHTML = `
    <div id="view-quiz" class="view active">
      <div class="view-header">
        <h1 class="view-title">Quiz</h1>
        <div class="quiz-stats">
          <div class="qstat"><span class="qstat-val">${q.score}/${q.total}</span><span class="qstat-lbl">Richtig · ${acc}%</span></div>
          <div class="qstat"><span class="qstat-val">${q.streak}</span><span class="qstat-lbl">Serie</span></div>
          <div class="qstat"><span class="qstat-val">${q.best}</span><span class="qstat-lbl">Bestserie</span></div>
        </div>
      </div>
      <div class="quiz-body">
        <div class="silhouette-wrap quiz-silhouette">
          <canvas id="quiz-canvas" width="240" height="240"></canvas>
        </div>
        ${feedbackText}
        <div class="quiz-options">${optionsHtml}</div>
        ${nextBtn}
      </div>
    </div>`;

  // Silhouette neutral zeichnen (Herstellerfarbe würde die Antwort verraten)
  requestAnimationFrame(() => {
    const canvas = document.getElementById('quiz-canvas');
    if (canvas) drawSilhouette(canvas, answer, '#6E7681');
  });

  if (answered) {
    const next = document.getElementById('quiz-next');
    if (next) next.addEventListener('click', newQuizRound);
  }
}

// ── Compare helpers ────────────────────────────────────────────────────────────
function toggleCompare(icao) {
  const idx = state.compareList.indexOf(icao);
  if (idx >= 0) {
    state.compareList.splice(idx, 1);
  } else if (state.compareList.length < 3) {
    state.compareList.push(icao);
  }
  saveCompare();
}

// ── Picker sheet ───────────────────────────────────────────────────────────────
function openPicker() {
  pickerIn.value = '';
  renderPickerList('');
  pickerEl.classList.add('open');
  requestAnimationFrame(() => pickerIn.focus());
}

function closePicker() {
  pickerEl.classList.remove('open');
}

function renderPickerList(q) {
  const items = AIRCRAFT.filter(a => {
    const lq = q.toLowerCase();
    return !lq || a.variant.toLowerCase().includes(lq) || a.icaoCode.toLowerCase().includes(lq) || a.manufacturer.toLowerCase().includes(lq);
  });
  pickerList.innerHTML = items.map(a => {
    const inCmp = state.compareList.includes(a.icaoCode);
    const canAdd = !inCmp && state.compareList.length < 3;
    return `<div class="picker-item${(!canAdd && !inCmp) ? ' disabled' : ''}"
              data-pickadd="${a.icaoCode}" style="opacity:${!canAdd && !inCmp ? '.4' : '1'}">
      <div class="picker-item-dot" style="background:${mfrColor(a.manufacturer)}"></div>
      <div class="picker-item-text">
        <div class="pname">${a.variant}${inCmp ? ' ✓' : ''}</div>
        <div class="picao">${a.manufacturer} · ${a.icaoCode}</div>
      </div>
    </div>`;
  }).join('') || '<div style="padding:var(--sp-m);color:var(--text2)">Keine Ergebnisse</div>';
}

// ── Routing / tab switch ───────────────────────────────────────────────────────
function switchTab(tab) {
  state.tab = tab;
  tabs.forEach(t => t.classList.toggle('active', t.dataset.tab === tab));
  if (tab === 'database') renderDatabase();
  else if (tab === 'compare') renderCompare();
  else if (tab === 'quiz') renderQuiz();
  else renderInfo();
}

// ── Event delegation ───────────────────────────────────────────────────────────
document.getElementById('tab-bar').addEventListener('click', e => {
  const tab = e.target.closest('.tab');
  if (tab) switchTab(tab.dataset.tab);
});

appEl.addEventListener('click', e => {
  // Quiz answer pick
  const quizPick = e.target.closest('[data-quiz-pick]');
  if (quizPick) {
    answerQuiz(quizPick.dataset.quizPick);
    return;
  }

  // Manufacturer filter chip
  const chip = e.target.closest('.chip');
  if (chip) {
    state.mfr = chip.dataset.mfr;
    renderDatabase();
    return;
  }

  // Add-to-compare button (stop propagation to card)
  const addBtn = e.target.closest('[data-add]');
  if (addBtn) {
    e.stopPropagation();
    toggleCompare(addBtn.dataset.add);
    renderDatabase();
    return;
  }

  // Aircraft card tap → detail
  const card = e.target.closest('.aircraft-card');
  if (card) {
    openDetail(card.dataset.icao);
    return;
  }
});

// Picker events
document.getElementById('picker-backdrop').addEventListener('click', closePicker);
pickerIn.addEventListener('input', () => renderPickerList(pickerIn.value));
pickerList.addEventListener('click', e => {
  const item = e.target.closest('[data-pickadd]');
  if (!item) return;
  const icao = item.dataset.pickadd;
  if (!state.compareList.includes(icao) && state.compareList.length < 3) {
    toggleCompare(icao);
    if (state.compareList.length >= 3) closePicker();
    else renderPickerList(pickerIn.value);
    if (state.tab === 'compare') renderCompare();
  }
});

// Service Worker registration
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('./sw.js').catch(() => {});
}

// ── Boot ───────────────────────────────────────────────────────────────────────
switchTab('database');
