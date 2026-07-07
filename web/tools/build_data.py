#!/usr/bin/env python3
"""Erzeugt web/data.js aus dem iOS-Seed (Single Source of Truth).

Die Flugzeugdaten waren zuvor doppelt gepflegt (iOS-Seed-JSON + hart
einkodiertes Array in app.js) und sind auseinandergedriftet (veraltete
Status/Lookalikes im Web). Jetzt gilt:

    SpotterDex/SpotterDex/Resources/aircraft_seed_v1.json  →  web/data.js

Nach JEDER Seed-Änderung ausführen:
    python3 web/tools/build_data.py
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SEED = ROOT / "SpotterDex/SpotterDex/Resources/aircraft_seed_v1.json"
OUT  = ROOT / "web/data.js"

# Felder in stabiler Reihenfolge; imageCredits ist iOS-intern (Web lädt
# Credits live von der Commons-API) und wird bewusst weggelassen.
FIELDS = [
    "manufacturer", "family", "variant", "icaoCode", "iataCode",
    "firstFlightYear", "status", "enginePosition",
    "wingspan", "length", "height", "mtow", "range", "cruiseSpeed",
    "passengerCapacity", "engineType", "engineCount",
    "visualFeatures", "lookalikes",
]

seed = json.loads(SEED.read_text())
aircraft = [
    {f: a[f] for f in FIELDS if f in a}
    for a in seed["aircraft"]
]

js = (
    "'use strict';\n\n"
    "// AUTOGENERIERT aus SpotterDex/SpotterDex/Resources/aircraft_seed_v1.json\n"
    f"// (Seed-Version {seed['version']}) – NICHT von Hand editieren.\n"
    "// Neu erzeugen mit:  python3 web/tools/build_data.py\n"
    "const AIRCRAFT = "
    + json.dumps(aircraft, ensure_ascii=False, indent=2)
    + ";\n"
)
OUT.write_text(js)
print(f"{OUT.name}: {len(aircraft)} Typen (Seed-Version {seed['version']})")
