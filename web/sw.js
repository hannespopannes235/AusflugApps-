'use strict';

const CACHE = 'spotterdex-v6';
const ASSETS = [
  './',
  './index.html',
  './style.css',
  './app.js',
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

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

// App-Shell: NETWORK-FIRST. Online bekommen Nutzer immer die aktuelle Version
// (kein manueller Cache-Bump mehr nötig, keine veralteten app.js-Stände);
// offline wird aus dem Cache bedient. Navigationen fallen offline auf
// index.html zurück, damit auch die Verzeichnis-URL ohne Dateinamen lädt.
self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;
  const url = new URL(e.request.url);
  if (url.origin !== location.origin) return;   // Fremd-Requests (z. B. Wikimedia) nicht anfassen

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
