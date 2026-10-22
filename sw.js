const CACHE = "evolution-v27";
const FILES = ["./", "./index.html", "./app.js?v=24", "./exercises.js?v=24", "./manifest.json", "./icon-192.png", "./icon-512.png", "./apple-touch-icon.png"];
self.addEventListener("install", e => { e.waitUntil(caches.open(CACHE).then(c => c.addAll(FILES)).catch(() => {})); self.skipWaiting(); });
self.addEventListener("activate", e => { e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim())); });
self.addEventListener("fetch", e => {
  const url = new URL(e.request.url);
  if (e.request.method !== "GET" || url.origin !== self.location.origin) return;
  // Bust the GitHub Pages edge cache (10 min) for the app shell: a per-minute query string makes every load a fresh URL at the CDN.
  const shell = /(\/|index\.html|app\.js|exercises\.js|manifest\.json)$/.test(url.pathname);
  const u = new URL(e.request.url); if (shell) u.searchParams.set("_", String(Math.floor(Date.now() / 60000)));
  const fresh = new Request(u.toString(), { cache: "no-store", credentials: "same-origin" });
  e.respondWith(fetch(fresh).then(r => { if (r && r.ok) { const copy = r.clone(); caches.open(CACHE).then(c => c.put(e.request, copy)).catch(() => {}); } return r; }).catch(() => caches.match(e.request).then(m => m || caches.match("./index.html"))));
});
