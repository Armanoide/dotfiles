#!/usr/bin/env node
'use strict';
/* rsync_web.js — serveur web natif (zero-dep) pour le dashboard rsync.
   API JSON + SPA a onglets (Dashboard / Logs / Parametres). */
const http = require('http');
const fs = require('fs');
const path = require('path');

const STATE_PATH = process.env.RSYNC_STATE || '/dashboard/state.json';
const BLACKLIST_FILE = process.env.RSYNC_BLACKLIST || '/source/docker/.blacklist';
const ARCHIVED_FILE = process.env.RSYNC_ARCHIVED || '/dashboard/archived.txt';
const LOG_DIR = process.env.RSYNC_LOG_DIR || '/source/docker/rsync_pull_node/logs';
const PORT = parseInt(process.env.PORT || '8090', 10);
const STALE_HOURS = parseInt(process.env.RSYNC_STALE_HOURS || '26', 10);

const NODE_LABELS = { '10.0.10.5': 'node1', '10.0.10.6': 'node2' };

function parseLocalTs(ts) {
  if (!ts) return null;
  const [d, t] = ts.split(' ');
  if (!d || !t) return null;
  const [Y, M, D] = d.split('-').map(Number);
  const [h, m, s] = t.split(':').map(Number);
  return new Date(Y, M - 1, D, h, m, s);
}
function humanBytes(n) {
  n = Number(n); if (!isFinite(n)) return '?';
  const u = ['B', 'K', 'M', 'G', 'T']; let i = 0;
  while (n >= 1024 && i < u.length - 1) { n /= 1024; i++; }
  return (i === 0 ? n.toFixed(0) : n.toFixed(1)) + u[i];
}
function ageStr(ts, now) {
  const d = parseLocalTs(ts); if (!d) return '—';
  const ms = now - d; const h = Math.floor(ms / 3600000);
  if (h < 1) return `${Math.floor(ms / 60000)}m`;
  if (h < 48) return `${h}h`;
  return `${Math.floor(h / 24)}j`;
}
function statusFor(ts, now) {
  const d = parseLocalTs(ts); if (!d) return 'never';
  const h = (now - d) / 3600000;
  if (h <= STALE_HOURS) return 'ok';
  if (h <= 72) return 'stale';
  return 'dead';
}

function loadJSON(f, def) { try { return JSON.parse(fs.readFileSync(f, 'utf8')); } catch (e) { return def; } }
function loadLines(f) { try { return fs.readFileSync(f, 'utf8').split('\n').map(s => s.trim()).filter(Boolean); } catch (e) { return []; } }

function buildState() {
  const s = loadJSON(STATE_PATH, { runs: [], projects: {} });
  const bl = new Set(loadLines(BLACKLIST_FILE));
  const arch = loadLines(ARCHIVED_FILE);
  const now = new Date();
  const isArch = (p) => arch.includes(p.project) || arch.includes(`${p.project}@${p.node}`);
  const cutoff7 = new Date(now - 7 * 86400000);

  const active = [];
  let ok = 0, stale = 0;
  for (const p of Object.values(s.projects)) {
    if (bl.has(p.project) || isArch(p)) continue;
    const last = p.last_sync_ts ? parseLocalTs(p.last_sync_ts) : null;
    if (!last || last < cutoff7) continue;
    const st = statusFor(p.last_sync_ts, now);
    if (st === 'ok') ok++; else if (st === 'stale') stale++;
    active.push({ ...p, label: NODE_LABELS[p.node] || p.node, status: st, age: ageStr(p.last_sync_ts, now), size_h: humanBytes(p.last_size_bytes) });
  }

  // activite par jour (runs OK)
  const days = {};
  for (const r of s.runs) { if (r.status === 'OK') days[r.ts.slice(0, 10)] = (days[r.ts.slice(0, 10)] || 0) + (r.cnt || 0); }
  const activity = [];
  for (let i = 13; i >= 0; i--) { const d = new Date(now - i * 86400000).toISOString().slice(0, 10); activity.push({ day: d, cnt: days[d] || 0 }); }

  // derniers runs pivot
  const seen = {};
  for (const r of s.runs) { const h = r.ts.slice(0, 13); (seen[h] = seen[h] || {})[r.node] = r; }
  const recent = Object.keys(seen).sort().reverse().slice(0, 24).map(h => ({
    hour: h.slice(11), n1: seen[h]['10.0.10.5'] || null, n2: seen[h]['10.0.10.6'] || null
  }));

  return {
    ok, stale, total: active.length, banner: (stale === 0 ? 'ok' : 'warn'),
    lastRun: (s.runs.filter(r => r.status === 'OK' && r.cnt > 0).reduce((a, b) => (!a || a.ts < b.ts ? b : a), null) || { ts: '—' }).ts,
    updated: now.toISOString().slice(0, 16).replace('T', ' '),
    projects: active.sort((a, b) => (a.label + a.project).localeCompare(b.label + b.project)),
    activity, recent, blacklist: [...bl].sort(), archived: arch.sort(),
    params: { staleHours: STALE_HOURS, freq: '0 * * * *', parser: '5 * * * *' }
  };
}

function readLog(day) {
  const f = path.join(LOG_DIR, `${day}.log`);
  try { return fs.readFileSync(f, 'utf8').split('\n').slice(-400); } catch (e) { return []; }
}

const server = http.createServer((req, res) => {
  const url = new URL(req.url, `http://${req.headers.host}`);
  if (url.pathname === '/api/state') { res.writeHead(200, { 'Content-Type': 'application/json' }); return res.end(JSON.stringify(buildState())); }
  if (url.pathname === '/api/logs') { const day = url.searchParams.get('day') || new Date().toISOString().slice(0, 10); res.writeHead(200, { 'Content-Type': 'application/json' }); return res.end(JSON.stringify({ day, lines: readLog(day) })); }
  if (url.pathname === '/api/logs/days') { try { const files = fs.readdirSync(LOG_DIR).filter(f => f.endsWith('.log')).map(f => f.replace('.log', '')).sort().reverse(); res.writeHead(200, { 'Content-Type': 'application/json' }); return res.end(JSON.stringify(files)); } catch (e) { return res.end('[]'); } }
  if (url.pathname === '/health') { res.writeHead(200); return res.end('ok'); }
  // SPA
  res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
  res.end(HTML);
});

const HTML = `<!DOCTYPE html>
<html lang="fr"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Rsync Dashboard</title>
<style>
:root{--bg:#0f1419;--card:#1a2027;--card2:#222b35;--txt:#e6edf3;--mut:#8b98a5;--ok:#3fb950;--warn:#d29922;--dead:#f85149;--acc:#58a6ff;--line:#30363d}
*{box-sizing:border-box;margin:0;padding:0}
body{background:var(--bg);color:var(--txt);font:14px/1.5 -apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif}
header{padding:16px 24px;border-bottom:1px solid var(--line);display:flex;align-items:center;gap:12px;flex-wrap:wrap}
header h1{font-size:18px;font-weight:600}
.banner{padding:4px 12px;border-radius:20px;font-size:13px;font-weight:600}
.banner.ok{background:rgba(63,185,80,.15);color:var(--ok)}
.banner.warn{background:rgba(210,153,34,.15);color:var(--warn)}
.tabs{display:flex;gap:4px;padding:0 24px;border-bottom:1px solid var(--line)}
.tab{padding:12px 18px;cursor:pointer;color:var(--mut);border-bottom:2px solid transparent;font-weight:500}
.tab.active{color:var(--acc);border-color:var(--acc)}
main{padding:24px;max-width:1100px;margin:0 auto}
.grid{display:grid;gap:12px}
.cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:12px;margin-bottom:24px}
.card{background:var(--card);border:1px solid var(--line);border-radius:10px;padding:16px}
.card .n{font-size:28px;font-weight:700}
.card .l{color:var(--mut);font-size:12px;text-transform:uppercase;letter-spacing:.5px}
table{width:100%;border-collapse:collapse;background:var(--card);border-radius:10px;overflow:hidden;border:1px solid var(--line)}
th,td{padding:10px 12px;text-align:left;border-bottom:1px solid var(--line);font-size:13px}
th{color:var(--mut);font-weight:600;background:var(--card2)}
tr:last-child td{border-bottom:none}
.node-h{margin:20px 0 8px;font-size:15px;font-weight:600;color:var(--acc)}
.badge{padding:2px 8px;border-radius:12px;font-size:12px;font-weight:600}
.badge.ok{background:rgba(63,185,80,.15);color:var(--ok)}
.badge.stale{background:rgba(210,153,34,.15);color:var(--warn)}
.badge.dead{background:rgba(248,81,73,.15);color:var(--dead)}
.badge.never{background:rgba(248,81,73,.2);color:var(--dead)}
.badge.no{background:rgba(139,152,165,.15);color:var(--mut)}
.bar{display:flex;align-items:center;gap:8px;margin:4px 0}
.bar .d{width:70px;color:var(--mut);font-size:12px}
.bar .t{height:14px;border-radius:3px;background:var(--acc);min-width:2px}
.bar .v{color:var(--mut);font-size:12px}
.chips{display:flex;flex-wrap:wrap;gap:6px;margin:8px 0}
.chip{background:var(--card2);border:1px solid var(--line);padding:3px 10px;border-radius:14px;font-size:12px;color:var(--mut)}
.mut{color:var(--mut)}
select,input{background:var(--card2);color:var(--txt);border:1px solid var(--line);border-radius:6px;padding:6px 10px;font-size:13px}
pre{background:#0d1117;border:1px solid var(--line);border-radius:8px;padding:14px;overflow:auto;font-size:12px;line-height:1.6;max-height:520px}
.hidden{display:none}
.row{display:flex;gap:12px;align-items:center;margin-bottom:16px;flex-wrap:wrap}
</style></head><body>
<header><h1>📊 Rsync Dashboard</h1><span id="banner" class="banner ok">…</span><span class="mut" id="upd"></span></header>
<div class="tabs"><div class="tab active" data-t="dash">📊 Dashboard</div><div class="tab" data-t="logs">🧾 Logs</div><div class="tab" data-t="cfg">⚙️ Paramètres</div></div>
<main>
<section id="dash">
  <div class="cards" id="cards"></div>
  <h3 class="node-h">📈 Activité (14 jours)</h3><div id="act"></div>
  <div id="tables"></div>
  <h3 class="node-h">⚫ Blacklistés</h3><div class="chips" id="bl"></div>
  <h3 class="node-h">📦 Archivés</h3><div class="chips" id="arch"></div>
</section>
<section id="logs" class="hidden">
  <div class="row"><label>Jour : </label><select id="daySel"></select><button onclick="loadLogs()" style="background:var(--acc);color:#0d1117;border:none;padding:6px 14px;border-radius:6px;cursor:pointer;font-weight:600">Rafraîchir</button></div>
  <pre id="logBox">chargement…</pre>
</section>
<section id="cfg" class="hidden"><div class="cards" id="cfgCards"></div>
  <h3 class="node-h">Projets archivés (archived.txt)</h3><pre id="cfgArch"></pre>
  <p class="mut">Ajouter une ligne <code>projet@node</code> (ex n8n@10.0.10.6) puis <code>docker compose restart rsync_dashboard</code>.</p>
</section>
</main>
<script>
let DATA=null;
async function load(){const r=await fetch('/api/state');DATA=await r.json();render();}
function render(){
 document.getElementById('banner').className='banner '+(DATA.banner==='ok'?'ok':'warn');
 document.getElementById('banner').textContent=DATA.banner==='ok'?'✅ Tout frais':'⚠️ Attention';
 document.getElementById('upd').textContent=' Màj '+DATA.updated+' · run '+((DATA.lastRun||'—').slice(11,16));
 document.getElementById('cards').innerHTML=[
  ['Frais',DATA.ok,'var(--ok)'],['Total actifs',DATA.total,'var(--txt)'],['Stale',DATA.stale,DATA.stale?'var(--warn)':'var(--mut)'],['Dernier run',(DATA.lastRun||'—').slice(11,16),'var(--acc)']
 ].map(([l,n,c])=>'<div class="card"><div class="n" style="color:'+c+'">'+n+'</div><div class="l">'+l+'</div></div>').join('');
 const mx=Math.max(1,...DATA.activity.map(a=>a.cnt));
 document.getElementById('act').innerHTML=DATA.activity.map(a=>'<div class="bar"><span class="d">'+a.day.slice(8)+'/'+a.day.slice(5,7)+'</span><div class="t" style="width:'+(a.cnt/mx*70)+'%"></div><span class="v">'+a.cnt+'</span></div>').join('');
 const byNode={};DATA.projects.forEach(p=>{(byNode[p.label]=byNode[p.label]||[]).push(p)});
 document.getElementById('tables').innerHTML=Object.keys(byNode).sort().map(n=>'<h3 class="node-h">🗂️ '+n+'</h3><table><tr><th>Projet</th><th>Dernière sync</th><th>Âge</th><th>Fichiers</th><th>Taille</th><th>Statut</th></tr>'+byNode[n].map(p=>'<tr><td>'+p.project+'</td><td>'+(p.last_sync_ts||'').slice(5,16)+'</td><td>'+p.age+'</td><td>'+(p.last_files||0)+'</td><td>'+p.size_h+'</td><td><span class="badge '+p.status+'">'+p.status.toUpperCase()+'</span></td></tr>').join('')+'</table>').join('');
 document.getElementById('bl').innerHTML=DATA.blacklist.map(b=>'<span class="chip">'+b+'</span>').join('');
 document.getElementById('arch').innerHTML=DATA.archived.map(b=>'<span class="chip">📦 '+b+'</span>').join('');
}
async function loadLogs(){const day=document.getElementById('daySel').value;const r=await fetch('/api/logs?day='+day);const d=await r.json();document.getElementById('logBox').textContent=d.lines.join('\\n')||'(vide)';}
async function initCfg(){const r=await fetch('/api/state');const d=await r.json();document.getElementById('cfgCards').innerHTML=[['Seuil STALE',d.params.staleHours+'h'],['Fréquence rsync','0 * * * *'],['Parser cron','5 * * * *']].map(([l,v])=>'<div class="card"><div class="n" style="font-size:18px;color:var(--acc)">'+v+'</div><div class="l">'+l+'</div></div>').join('');document.getElementById('cfgArch').textContent=d.archived.join('\\n')||'(aucun)';}
document.querySelectorAll('.tab').forEach(t=>t.onclick=()=>{document.querySelectorAll('.tab').forEach(x=>x.classList.remove('active'));t.classList.add('active');['dash','logs','cfg'].forEach(s=>document.getElementById(s).classList.add('hidden'));document.getElementById(t.dataset.t).classList.remove('hidden');if(t.dataset.t==='cfg')initCfg();});
async function initDays(){const r=await fetch('/api/logs/days');const d=await r.json();document.getElementById('daySel').innerHTML=d.map(x=>'<option>'+x+'</option>').join('');loadLogs();}
load();initDays();setInterval(load,60000);
</script></body></html>`;

server.listen(PORT, () => console.log(`rsync_web listening on :${PORT}`));
