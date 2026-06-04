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
  }
];

// ── State ──────────────────────────────────────────────────────────────────────
const state = {
  tab: 'database',
  search: '',
  mfr: '',
  compareList: JSON.parse(localStorage.getItem('sd_compare') || '[]'),
  detailStack: [],   // ICAO stack for back navigation
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
          <p>Dein digitales Handbuch für Planespotter. Flugzeuge erkennen, vergleichen und meistern — vollständig offline.</p>
        </div>
        <div class="info-card">
          <div class="info-card-title">Daten & Quellen</div>
          <p>Die Flugzeugdaten wurden aus öffentlichen Quellen zusammengestellt:</p>
          <ul>
            <li>Wikidata (CC0)</li>
            <li>Jane's All the World's Aircraft</li>
            <li>Herstellerdatenblätter (öffentlich)</li>
          </ul>
          <p style="margin-top:8px">Maße in SI (m / kg / km / km·h⁻¹). Bildrechte: Je Foto Einzelnachweis erforderlich.</p>
        </div>
        <div class="info-card">
          <div class="info-card-title">Datenschutz</div>
          <p>SpotterDex sammelt keine Nutzerdaten. Die App läuft vollständig offline, on-device. Es gibt keine Tracker, keine Analysen, keine Cloud-Verbindung.</p>
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
        <p class="info-version">SpotterDex Web v1.0 · ${new Date().getFullYear()}</p>
      </div>
    </div>`;
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
  else renderInfo();
}

// ── Event delegation ───────────────────────────────────────────────────────────
document.getElementById('tab-bar').addEventListener('click', e => {
  const tab = e.target.closest('.tab');
  if (tab) switchTab(tab.dataset.tab);
});

appEl.addEventListener('click', e => {
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
