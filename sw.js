'use strict';

const CACHE = 'spotterdex-v7';
const ASSETS = [
  './',
  './index.html',
  './style.css',
  './app.js',
  './data.js',
  './manifest.json',
  './icon.svg',
  './apple-touch-icon.png',
  './icon-192.png',
  './icon-512.png',
  './icon-maskable-512.png',
];

self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE).then(c => c.addAll(ASSETS)).then(() => self.skipWaiting())
  );
});

// Runtime-Cache für Wikimedia-Inhalte (Fotos + Credit-API) – getrennt vom
// App-Shell-Cache, damit er Versions-Bumps überlebt.
const WIKI_CACHE = 'spotterdex-wiki-v1';
const WIKI_MAX_ENTRIES = 60;

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys
        .filter(k => k !== CACHE && k !== WIKI_CACHE)
        .map(k => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

// Älteste Einträge verwerfen, wenn das Limit überschritten ist (einfaches FIFO).
async function trimWikiCache(cache) {
  const keys = await cache.keys();
  if (keys.length > WIKI_MAX_ENTRIES) {
    await Promise.all(keys.slice(0, keys.length - WIKI_MAX_ENTRIES).map(k => cache.delete(k)));
  }
}

// App-Shell: NETWORK-FIRST. Online bekommen Nutzer immer die aktuelle Version
// (kein manueller Cache-Bump mehr nötig, keine veralteten app.js-Stände);
// offline wird aus dem Cache bedient. Navigationen fallen offline auf
// index.html zurück, damit auch die Verzeichnis-URL ohne Dateinamen lädt.
self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;
  const url = new URL(e.request.url);

  // Wikimedia: Fotos cache-first (ändern sich nie – einmal gesehen = offline
  // verfügbar, auch im Quiz), Credit-API network-first (immer aktuelle
  // Attribution, offline aus dem Cache).
  if (url.hostname === 'commons.wikimedia.org') {
    if (url.pathname.startsWith('/wiki/Special:FilePath/')) {
      e.respondWith(
        caches.open(WIKI_CACHE).then(async c => {
          const hit = await c.match(e.request);
          if (hit) return hit;
          const resp = await fetch(e.request);
          if (resp.ok || resp.type === 'opaque') {   // opaque = no-cors <img>
            await c.put(e.request, resp.clone());
            trimWikiCache(c);
          }
          return resp;
        })
      );
    } else if (url.pathname.startsWith('/w/api.php')) {
      e.respondWith(
        caches.open(WIKI_CACHE).then(async c => {
          try {
            const resp = await fetch(e.request);
            if (resp.ok) c.put(e.request, resp.clone());
            return resp;
          } catch (err) {
            const hit = await c.match(e.request);
            if (hit) return hit;
            throw err;
          }
        })
      );
    }
    return;
  }

  if (url.origin !== location.origin) return;   // sonstige Fremd-Requests nicht anfassen

  e.respondWith(
    fetch(e.request)
      .then(resp => {
        const copy = resp.clone();
        caches.open(CACHE).then(c => c.put(e.request, copy));
        return resp;
      })
      .catch(() =>
        caches.match(e.request).then(cached =>
          cached || (e.request.mode === 'navigate'
            ? caches.match('./index.html')
            : Response.error())
        )
      )
  );
});
