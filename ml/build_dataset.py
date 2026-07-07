#!/usr/bin/env python3
"""
SpotterDex – Trainingsdatensatz-Builder (rechtlich sauber)
==========================================================

Lädt pro Flugzeugtyp (ICAO-Code) Fotos aus der zugehörigen Wikimedia-Commons-
Kategorie herunter und legt sie in nach ICAO-Code benannte Unterordner ab –
genau das Layout, das Create ML als "Image Classifier"-Eingabe erwartet:

    dataset/
        A20N/  img_0001.jpg ...
        B738/  img_0001.jpg ...
        ...

RECHTLICHE SAUBERKEIT (Kernanforderung des Projekts):
  - Es werden NUR Bilder mit freier Lizenz übernommen
    (CC0, CC BY, CC BY-SA, Public Domain). Alle anderen werden übersprungen.
  - Für JEDES heruntergeladene Bild werden Urheber, Lizenz, Lizenz-URL und die
    Commons-Quellseite in credits.csv + credits.json protokolliert.
    → Damit ist die Attribution jederzeit belegbar; nichts wird "geraten".

Voraussetzungen:  Python 3.9+, `requests`  (pip install requests)
Nutzung:          python3 build_dataset.py --per-class 150 --out dataset

Hinweis: Läuft NICHT in der Claude-Sandbox (Wikimedia ist dort geblockt).
Auf einem normalen Rechner mit Internetzugang ausführen.
"""

from __future__ import annotations
import argparse
import csv
import json
import os
import re
import sys
import time
from pathlib import Path
from urllib.parse import quote

try:
    import requests
except ImportError:
    sys.exit("Bitte zuerst 'pip install requests' ausführen.")

API = "https://commons.wikimedia.org/w/api.php"
# Eindeutiger User-Agent ist Wikimedia-Policy-Pflicht für API-Zugriffe.
HEADERS = {"User-Agent": "SpotterDex-DatasetBuilder/1.0 (educational; contact: spotterdex@example.com)"}

# Akzeptierte Lizenzen (Substring-Match, case-insensitive) – nur freie Lizenzen.
ALLOWED_LICENSES = ("cc0", "cc by", "cc-by", "public domain", "pd-", "no restrictions")
# Diese werden explizit ausgeschlossen, auch wenn ein erlaubter Substring vorkommt.
BLOCKED_LICENSES = ("nc", "nd", "non-commercial", "noderivs")


def session() -> requests.Session:
    s = requests.Session()
    s.headers.update(HEADERS)
    return s


def list_category_files(s: requests.Session, category: str, limit: int) -> list[str]:
    """Sammelt bis zu `limit` Datei-Titel aus einer Commons-Kategorie (paginiert)."""
    files: list[str] = []
    cont: dict = {}
    while len(files) < limit:
        params = {
            "action": "query", "format": "json",
            "list": "categorymembers",
            "cmtitle": f"Category:{category}",
            "cmtype": "file",
            "cmlimit": "100",
            **cont,
        }
        r = s.get(API, params=params, timeout=30)
        r.raise_for_status()
        data = r.json()
        members = data.get("query", {}).get("categorymembers", [])
        files.extend(m["title"] for m in members)
        if "continue" in data:
            cont = data["continue"]
        else:
            break
    return files[:limit]


def strip_html(text: str) -> str:
    return re.sub(r"<[^>]+>", "", text or "").strip()


def file_metadata(s: requests.Session, title: str) -> dict | None:
    """Holt URL + Lizenz/Urheber für eine Datei. None, wenn Lizenz nicht frei ist."""
    params = {
        "action": "query", "format": "json",
        "prop": "imageinfo",
        "iiprop": "url|extmetadata|mime",
        "iiurlwidth": "1024",
        "titles": title,
    }
    r = s.get(API, params=params, timeout=30)
    r.raise_for_status()
    pages = r.json().get("query", {}).get("pages", {})
    page = next(iter(pages.values()), {})
    infos = page.get("imageinfo")
    if not infos:
        return None
    info = infos[0]

    mime = info.get("mime", "")
    if not mime.startswith("image/"):
        return None  # PDFs, SVGs etc. ignorieren

    meta = info.get("extmetadata", {})
    license_short = strip_html(meta.get("LicenseShortName", {}).get("value", "")).lower()

    # Lizenzfilter – nur freie Lizenzen, kein NC/ND.
    if any(b in license_short for b in BLOCKED_LICENSES):
        return None
    if not any(a in license_short for a in ALLOWED_LICENSES):
        return None

    return {
        "title": title,
        "url": info.get("thumburl") or info.get("url"),
        "artist": strip_html(meta.get("Artist", {}).get("value", "")) or "Unbekannt",
        "license": strip_html(meta.get("LicenseShortName", {}).get("value", "")),
        "license_url": strip_html(meta.get("LicenseUrl", {}).get("value", "")),
        "page": f"https://commons.wikimedia.org/wiki/{quote(title.replace(' ', '_'))}",
    }


def main() -> None:
    ap = argparse.ArgumentParser(description="SpotterDex Trainingsdatensatz-Builder")
    ap.add_argument("--per-class", type=int, default=150,
                    help="Zielanzahl Bilder pro Flugzeugtyp (Default 150)")
    ap.add_argument("--scan", type=int, default=400,
                    help="Wie viele Kategorie-Dateien pro Typ maximal geprüft werden (Default 400)")
    ap.add_argument("--out", default="dataset", help="Zielordner (Default 'dataset')")
    ap.add_argument("--classes", default="aircraft_classes.json",
                    help="Pfad zur Klassen-Definition")
    args = ap.parse_args()

    here = Path(__file__).resolve().parent
    classes = json.loads((here / args.classes).read_text())["classes"]
    out = (here / args.out)
    out.mkdir(parents=True, exist_ok=True)

    s = session()
    credits: list[dict] = []
    summary: dict[str, int] = {}

    for icao, meta in classes.items():
        category = meta["category"]
        target = out / icao
        target.mkdir(exist_ok=True)
        print(f"\n=== {icao}  ({meta['name']})  —  Category:{category} ===")

        titles = list_category_files(s, category, args.scan)
        print(f"  {len(titles)} Dateien in Kategorie gefunden, filtere auf freie Lizenzen…")

        saved = 0
        for title in titles:
            if saved >= args.per_class:
                break
            try:
                md = file_metadata(s, title)
            except Exception as e:
                print(f"    ! Metadaten-Fehler {title}: {e}")
                continue
            if not md or not md["url"]:
                continue
            try:
                img = s.get(md["url"], timeout=60)
                img.raise_for_status()
            except Exception as e:
                print(f"    ! Download-Fehler {title}: {e}")
                continue

            fname = f"{icao}_{saved:04d}.jpg"
            (target / fname).write_bytes(img.content)
            credits.append({"file": f"{icao}/{fname}", "icao": icao, **md})
            saved += 1
            if saved % 25 == 0:
                print(f"    … {saved} Bilder gespeichert")
            time.sleep(0.1)  # höflich gegenüber der API

        summary[icao] = saved
        print(f"  → {saved} Bilder gespeichert (freie Lizenz).")

    # Attribution-Belege schreiben (CSV + JSON)
    with (out / "credits.csv").open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=["file", "icao", "title", "artist",
                                          "license", "license_url", "page", "url"])
        w.writeheader()
        w.writerows(credits)
    (out / "credits.json").write_text(json.dumps(credits, ensure_ascii=False, indent=2))

    print("\n========== ZUSAMMENFASSUNG ==========")
    for icao, n in summary.items():
        flag = "" if n >= 50 else "  ⚠️  wenig Daten – Kategorie prüfen"
        print(f"  {icao}: {n} Bilder{flag}")
    print(f"\nGesamt: {sum(summary.values())} Bilder")
    print(f"Attribution-Belege: {out/'credits.csv'} und credits.json")
    print("Nächster Schritt:  swift train_classifier.swift")


if __name__ == "__main__":
    main()
