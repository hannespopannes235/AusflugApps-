'use strict';

// AUTOGENERIERT aus SpotterDex/SpotterDex/Resources/aircraft_seed_v1.json
// (Seed-Version 3) – NICHT von Hand editieren.
// Neu erzeugen mit:  python3 web/tools/build_data.py
const AIRCRAFT = [
  {
    "manufacturer": "Airbus",
    "family": "A220",
    "variant": "A220-300",
    "icaoCode": "BCS3",
    "iataCode": "CS3",
    "firstFlightYear": 2015,
    "status": "inProduction",
    "wingspan": 35.1,
    "length": 38.71,
    "height": 11.5,
    "mtow": 70900,
    "range": 6300,
    "cruiseSpeed": 871,
    "passengerCapacity": 130,
    "engineType": "turbofan",
    "engineCount": 2,
    "visualFeatures": [
      "Breiter Rumpfquerschnitt für Schmalrumpf (2-3 Bestuhlung)",
      "Doppelt geschwungene Winglets (oben und unten)",
      "Sehr große Cockpitfenster",
      "Pratt & Whitney GTF-Triebwerke mit breitem Einlass",
      "Hochgelegte Flügel, leicht gepfeilt, keine sichtbare Wingbox-Verdickung"
    ],
    "lookalikes": [
      "E295",
      "A19N",
      "E190"
    ]
  },
  {
    "manufacturer": "Airbus",
    "family": "A320",
    "variant": "A320neo",
    "icaoCode": "A20N",
    "iataCode": "32N",
    "firstFlightYear": 2014,
    "status": "inProduction",
    "wingspan": 35.8,
    "length": 37.57,
    "height": 11.76,
    "mtow": 79000,
    "range": 6300,
    "cruiseSpeed": 833,
    "passengerCapacity": 165,
    "engineType": "turbofan",
    "engineCount": 2,
    "visualFeatures": [
      "Sharklet-Winglets (breite gebogene Spitzen, Gegensatz zu Boeing-Winglets)",
      "CFM LEAP-1A oder PW1100G – beide breiter als CFM56 der ceo-Variante",
      "Klassische Airbus-Nase mit abgeflachter Unterseite",
      "Keine Triebwerksabflachung unten (Gegensatz zu B737 NG)"
    ],
    "lookalikes": [
      "B738",
      "A19N",
      "A21N"
    ]
  },
  {
    "manufacturer": "Airbus",
    "family": "A350",
    "variant": "A350-900",
    "icaoCode": "A359",
    "iataCode": "359",
    "firstFlightYear": 2013,
    "status": "inProduction",
    "wingspan": 64.75,
    "length": 66.8,
    "height": 17.05,
    "mtow": 280000,
    "range": 15000,
    "cruiseSpeed": 903,
    "passengerCapacity": 440,
    "engineType": "turbofan",
    "engineCount": 2,
    "visualFeatures": [
      "Schwarze 'Katzenaugen' – geschwungene dunkle Cockpitfensterrahmen",
      "Mattes Finish des Karbonfaser-Rumpfs (kein spiegelndes Aluminium)",
      "Gebogene Flügelspitzen ('curved wingtip fences')",
      "Rolls-Royce Trent XWB – charakteristische ovale Gondeln",
      "Schlanker Rumpf trotz Widebody-Kategorie"
    ],
    "lookalikes": [
      "B789",
      "A339"
    ]
  },
  {
    "manufacturer": "Airbus",
    "family": "A380",
    "variant": "A380-800",
    "icaoCode": "A388",
    "iataCode": "380",
    "firstFlightYear": 2005,
    "status": "outOfProduction",
    "wingspan": 79.75,
    "length": 72.72,
    "height": 24.09,
    "mtow": 575000,
    "range": 15200,
    "cruiseSpeed": 903,
    "passengerCapacity": 853,
    "engineType": "turbofan",
    "engineCount": 4,
    "visualFeatures": [
      "Vollständig durchgängiges Oberdeck über die gesamte Rumpflänge",
      "Runder Oberdeck-Querschnitt – kein Buckel (Gegensatz zu B747)",
      "Extrem breites Fahrwerk – 6-Rad-Hauptfahrwerke je Seite",
      "4 Triebwerke: EA GP7200 oder Rolls-Royce Trent 970",
      "Spannweite knapp 80 m – deutlich breiter als alle anderen Passagierflugzeuge"
    ],
    "lookalikes": [
      "B748"
    ]
  },
  {
    "manufacturer": "Boeing",
    "family": "737",
    "variant": "737-800",
    "icaoCode": "B738",
    "iataCode": "738",
    "firstFlightYear": 1998,
    "status": "outOfProduction",
    "wingspan": 35.79,
    "length": 39.47,
    "height": 12.55,
    "mtow": 79016,
    "range": 5765,
    "cruiseSpeed": 842,
    "passengerCapacity": 162,
    "engineType": "turbofan",
    "engineCount": 2,
    "visualFeatures": [
      "CFM56-Triebwerke: flache Unterseite (abgeflacht, nicht kreisrund)",
      "Triebwerke weit vor dem Flügel und tiefer als bei Airbus A320",
      "'Hamster-Backen' – ovaler Triebwerkseinlass charakteristisch",
      "Split-Scimitar-Winglets optional – kein Standard wie bei neo-Airbus",
      "Sehr niedrige Bodenfreiheit der Triebwerke"
    ],
    "lookalikes": [
      "A20N",
      "B38M"
    ]
  },
  {
    "manufacturer": "Boeing",
    "family": "777",
    "variant": "777-300ER",
    "icaoCode": "B77W",
    "iataCode": "77W",
    "firstFlightYear": 2003,
    "status": "inProduction",
    "wingspan": 64.8,
    "length": 73.86,
    "height": 18.55,
    "mtow": 352441,
    "range": 13649,
    "cruiseSpeed": 905,
    "passengerCapacity": 396,
    "engineType": "turbofan",
    "engineCount": 2,
    "visualFeatures": [
      "GE90-115B – weltgrößter Turbofan (Einlass-Ø 3,25 m, größer als B737-Rumpf)",
      "Sechs-Rad-Hauptfahrwerk je Seite – einzigartig unter Zweistrahlern",
      "Abgeflachte Triebwerksunterseite knapp über dem Asphalt",
      "Raketenförmige, zylindrische Gondeln ohne sichtbare Nachlaufkante",
      "Breitester Rumpf aller noch produzierten Zweistrahler-Langstreckenflugzeuge"
    ],
    "lookalikes": [
      "B779",
      "B789"
    ]
  },
  {
    "manufacturer": "Boeing",
    "family": "787",
    "variant": "787-9",
    "icaoCode": "B789",
    "iataCode": "789",
    "firstFlightYear": 2013,
    "status": "inProduction",
    "wingspan": 60.12,
    "length": 62.81,
    "height": 17.02,
    "mtow": 254011,
    "range": 14140,
    "cruiseSpeed": 903,
    "passengerCapacity": 296,
    "engineType": "turbofan",
    "engineCount": 2,
    "visualFeatures": [
      "Wellenschnitt ('Sägezahn') an Triebwerkseinläufen – akustisches Design",
      "Stark geschwungene Flügeloberseite – markanter Knick zur Wingspitze",
      "Karbonfaser-Rumpf: leicht dunkles Finish, keine Nieten sichtbar",
      "Größere, ovale Kabinenfenster als bei Aluminium-Rümpfen",
      "GEnx oder Trent 1000 – sehr breite Gondeln mit 'Sägezahn'-Austritt"
    ],
    "lookalikes": [
      "A359",
      "A339"
    ]
  },
  {
    "manufacturer": "Boeing",
    "family": "747",
    "variant": "747-8I",
    "icaoCode": "B748",
    "iataCode": "748",
    "firstFlightYear": 2010,
    "status": "outOfProduction",
    "wingspan": 68.4,
    "length": 76.25,
    "height": 19.35,
    "mtow": 447696,
    "range": 14815,
    "cruiseSpeed": 908,
    "passengerCapacity": 467,
    "engineType": "turbofan",
    "engineCount": 4,
    "visualFeatures": [
      "Charakteristischer Buckel (Oberdeck vorne) – Erkennungsmerkmal der 747-Familie",
      "4 Triebwerke (GEnx-2B67) – bei modernen Passagierfliegern nur 747 und A380",
      "Geschwungene Flügelspitzen der -8-Variante (anders als 747-400)",
      "Verlängerter Rumpf gegenüber 747-400 (sichtbar durch mehr Fenstergrup­pen)",
      "Knickflügel-Profil – äußeres Flügelpanel leicht nach unten geneigt"
    ],
    "lookalikes": [
      "A388",
      "B744"
    ]
  },
  {
    "manufacturer": "Embraer",
    "family": "E-Jet E2",
    "variant": "E195-E2",
    "icaoCode": "E295",
    "iataCode": "295",
    "firstFlightYear": 2019,
    "status": "inProduction",
    "wingspan": 31.04,
    "length": 41.5,
    "height": 10.68,
    "mtow": 61000,
    "range": 4800,
    "cruiseSpeed": 870,
    "passengerCapacity": 120,
    "engineType": "turbofan",
    "engineCount": 2,
    "visualFeatures": [
      "Elegant schmale Nase mit feiner Cockpitfensterlinie",
      "Hochgelegte Flügel mit kurzem Rumpf-Überhang vorne",
      "Sehr enge Triebwerk-Flügel-Integration – fast anliegend am Flügel",
      "PW1900G GTF – identifizierbar durch breiteren Einlass als PW1500G",
      "Kleiner als A220-300, aber ähnliche Kabinenwirtschaftlichkeit"
    ],
    "lookalikes": [
      "BCS3",
      "CRJ9"
    ]
  },
  {
    "manufacturer": "ATR",
    "family": "ATR 72",
    "variant": "ATR 72-600",
    "icaoCode": "AT76",
    "iataCode": "AT7",
    "firstFlightYear": 2009,
    "status": "inProduction",
    "wingspan": 27.05,
    "length": 27.17,
    "height": 7.65,
    "mtow": 23000,
    "range": 1528,
    "cruiseSpeed": 510,
    "passengerCapacity": 78,
    "engineType": "turboprop",
    "engineCount": 2,
    "visualFeatures": [
      "Hochdecker – Flügel oben am Rumpf (Gegensatz zu fast allen Jets)",
      "T-Leitwerk – Höhenleitwerk hoch oben am Seitenleitwerk",
      "6-Blatt-Propeller (PW127M) – sichtbar und unverkennbar",
      "Sehr kleiner, kurzer Rumpf mit niedrigem Boden (kein Airbridge nötig)",
      "Hecktreppe extern sichtbar – typisches Regional-Merkmal"
    ],
    "lookalikes": [
      "DH8D",
      "AT45"
    ]
  },
  {
    "manufacturer": "Boeing",
    "family": "737 MAX",
    "variant": "737 MAX 8",
    "icaoCode": "B38M",
    "iataCode": "7M8",
    "firstFlightYear": 2016,
    "status": "inProduction",
    "wingspan": 35.9,
    "length": 39.52,
    "height": 12.3,
    "mtow": 82191,
    "range": 6570,
    "cruiseSpeed": 839,
    "passengerCapacity": 178,
    "engineType": "turbofan",
    "engineCount": 2,
    "visualFeatures": [
      "Markante AT-Winglets ('Advanced Technology') – gespalten, zeigen nach oben UND unten",
      "CFM LEAP-1B mit größerem Fan-Durchmesser als CFM56 der 737 NG – höher gesetzte Gondeln",
      "Triebwerksunterseite nur leicht abgeflacht (weniger als bei der NG-Generation)",
      "Verlängertes Bugfahrwerk – Rumpf wirkt im Stand minimal angehoben",
      "Neu geformter, verlängerter Heckkonus (aerodynamischer Tailcone)"
    ],
    "lookalikes": [
      "B738",
      "A20N",
      "A21N"
    ]
  },
  {
    "manufacturer": "Airbus",
    "family": "A320",
    "variant": "A321neo",
    "icaoCode": "A21N",
    "iataCode": "32Q",
    "firstFlightYear": 2016,
    "status": "inProduction",
    "wingspan": 35.8,
    "length": 44.51,
    "height": 11.76,
    "mtow": 97000,
    "range": 7400,
    "cruiseSpeed": 833,
    "passengerCapacity": 220,
    "engineType": "turbofan",
    "engineCount": 2,
    "visualFeatures": [
      "Längster Rumpf der A320-Familie – sehr gestreckte Silhouette",
      "Sharklet-Winglets wie A320neo, aber an deutlich längerem Rumpf",
      "Vier Türpaare bzw. zusätzliche Over-Wing-Exits je nach Konfiguration",
      "CFM LEAP-1A oder PW1100G mit breitem Einlass (neo-Merkmal)",
      "Gegenüber der A320neo: gleicher Querschnitt, aber rund 7 m länger"
    ],
    "lookalikes": [
      "A20N",
      "B38M",
      "B738"
    ]
  },
  {
    "manufacturer": "Airbus",
    "family": "A330",
    "variant": "A330-300",
    "icaoCode": "A333",
    "iataCode": "333",
    "firstFlightYear": 1992,
    "status": "outOfProduction",
    "wingspan": 60.3,
    "length": 63.69,
    "height": 16.83,
    "mtow": 242000,
    "range": 11750,
    "cruiseSpeed": 871,
    "passengerCapacity": 290,
    "engineType": "turbofan",
    "engineCount": 2,
    "visualFeatures": [
      "Großer Zweistrahl-Widebody mit kleiner, fast senkrechter Wingtip-Fence (kein geschwungenes Blended Winglet)",
      "Glänzender Aluminiumrumpf (kein mattes Karbon wie A350), eckigere Cockpitfenster",
      "Rumpf und Flügel nahezu identisch zur vierstrahligen A340 – aber nur 2 Triebwerke",
      "CF6-80E1, Trent 700 oder PW4000 – klassische runde Gondeln ohne Sägezahn",
      "Gegenüber der A330neo: kürzere Gondeln, alte Wingtip-Fence statt Sharklets"
    ],
    "lookalikes": [
      "A359",
      "B763",
      "B789"
    ]
  },
  {
    "manufacturer": "Boeing",
    "family": "767",
    "variant": "767-300ER",
    "icaoCode": "B763",
    "iataCode": "763",
    "firstFlightYear": 1988,
    "status": "outOfProduction",
    "wingspan": 47.57,
    "length": 54.94,
    "height": 15.85,
    "mtow": 186880,
    "range": 11070,
    "cruiseSpeed": 851,
    "passengerCapacity": 269,
    "engineType": "turbofan",
    "engineCount": 2,
    "visualFeatures": [
      "Semi-Widebody: schmaler als 777/A330, 2-3-2-Bestuhlung (7 Sitze pro Reihe)",
      "Meist ohne Winglets – gerade Flügelspitzen (nur einige Nachrüstungen)",
      "Klassische Boeing-Nase und -Leitwerk, ähnlich 757, aber breiterer Rumpf",
      "Lange, schlanke Gondeln (CF6-80C2, PW4000 oder RB211)",
      "Hauptfahrwerk mit nur 4 Rädern je Bein – schlanker Eindruck am Boden"
    ],
    "lookalikes": [
      "A333",
      "B789",
      "A359"
    ]
  },
  {
    "manufacturer": "Embraer",
    "family": "E-Jet",
    "variant": "E190 (E1)",
    "icaoCode": "E190",
    "iataCode": "E90",
    "firstFlightYear": 2004,
    "status": "outOfProduction",
    "wingspan": 28.72,
    "length": 36.24,
    "height": 10.55,
    "mtow": 51800,
    "range": 4537,
    "cruiseSpeed": 829,
    "passengerCapacity": 114,
    "engineType": "turbofan",
    "engineCount": 2,
    "visualFeatures": [
      "'Double-Bubble'-Rumpfquerschnitt – leicht versetzte obere und untere Rundung",
      "Klassische gebogene Winglets (im Gegensatz zur randlosen Flügelspitze der E2)",
      "Unterflügel-Triebwerke (GE CF34-10E) – schmalerer Einlass als die GTF der E2",
      "Vierfenster-Cockpit mit gerundeten Ecken, kurze spitze Nase",
      "Kompakterer Eindruck als die E195-E2 bei sehr ähnlicher Grundform"
    ],
    "lookalikes": [
      "E295",
      "CRJ9",
      "BCS3"
    ]
  },
  {
    "manufacturer": "Bombardier",
    "family": "CRJ",
    "variant": "CRJ900",
    "icaoCode": "CRJ9",
    "iataCode": "CR9",
    "firstFlightYear": 2001,
    "status": "outOfProduction",
    "enginePosition": "rear",
    "wingspan": 24.85,
    "length": 36.4,
    "height": 7.51,
    "mtow": 38330,
    "range": 2876,
    "cruiseSpeed": 829,
    "passengerCapacity": 90,
    "engineType": "turbofan",
    "engineCount": 2,
    "visualFeatures": [
      "Zwei Triebwerke am Heck montiert (aft-fuselage) statt unter den Flügeln",
      "T-Leitwerk – Höhenleitwerk hoch am Seitenleitwerk",
      "Sehr langer, schlanker, niedriger Rumpf mit tief angesetzten Flügeln",
      "Kleine ovale Kabinenfenster und geringe Bodenfreiheit",
      "GE CF34-8C5 – kompakte Gondeln seitlich am hinteren Rumpf"
    ],
    "lookalikes": [
      "E190",
      "F100",
      "E295"
    ]
  },
  {
    "manufacturer": "De Havilland Canada",
    "family": "Dash 8",
    "variant": "Dash 8 Q400",
    "icaoCode": "DH8D",
    "iataCode": "DH4",
    "firstFlightYear": 1998,
    "status": "outOfProduction",
    "wingspan": 28.42,
    "length": 32.84,
    "height": 8.34,
    "mtow": 29574,
    "range": 2040,
    "cruiseSpeed": 667,
    "passengerCapacity": 90,
    "engineType": "turboprop",
    "engineCount": 2,
    "visualFeatures": [
      "Hochdecker mit T-Leitwerk und sehr langem, schlankem Rumpf",
      "Zwei große 6-Blatt-Propeller (PW150A) – schnellster Serien-Turboprop seiner Klasse",
      "Lange Hauptfahrwerksbeine, fahren nach hinten in die Triebwerksgondeln ein",
      "Spitzere Nase und höhere Reisegeschwindigkeit als die ATR-Familie",
      "Triebwerksgondeln ragen deutlich über die Flügelvorderkante hinaus"
    ],
    "lookalikes": [
      "AT76"
    ]
  },
  {
    "manufacturer": "Fokker",
    "family": "Fokker 100",
    "variant": "Fokker 100",
    "icaoCode": "F100",
    "iataCode": "100",
    "firstFlightYear": 1986,
    "status": "outOfProduction",
    "enginePosition": "rear",
    "wingspan": 28.08,
    "length": 35.53,
    "height": 8.5,
    "mtow": 44450,
    "range": 3170,
    "cruiseSpeed": 845,
    "passengerCapacity": 109,
    "engineType": "turbofan",
    "engineCount": 2,
    "visualFeatures": [
      "Zwei Rolls-Royce Tay am Heck montiert – klassisches Jet-Layout der 1980er",
      "T-Leitwerk und langer, schlanker Rumpf ohne Winglets",
      "Lange, gerade Tragflächen mit geringer Pfeilung, tief angesetzt",
      "Spitze, schmale Nase mit schmalem Cockpitfenster-Band",
      "Sehr ähnlich der Fokker 70, aber mit längerem Rumpf (rund 5 m mehr)"
    ],
    "lookalikes": [
      "CRJ9",
      "E190"
    ]
  }
];
