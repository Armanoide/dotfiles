#!/usr/bin/env node
'use strict';
/*
 * rsync_dashboard.js — parse les logs rsync_pull -> etat JSON + note Obsidian.
 * Node 18 natif, aucune dependance npm.
 *
 * Modes:
 *   --backfill   : parse tous les logs/*.log (historique complet)
 *   --incremental: ne parse que le log du jour (cron)
 *   --render     : regenere la note Markdown depuis l'etat
 */
const fs = require('fs');
const path = require('path');

const LOG_DIR = process.env.RSYNC_LOG_DIR || '/source/docker/rsync_pull_node/logs';
const STATE_PATH = process.env.RSYNC_STATE || '/dashboard/state.json';
const NOTE_PATH = process.env.RSYNC_NOTE || '/dashboard/Rsync-Dashboard.md';
const BLACKLIST_FILE = process.env.RSYNC_BLACKLIST || '/source/docker/.blacklist';
const STALE_HOURS = parseInt(process.env.RSYNC_STALE_HOURS || '26', 10);

const NODE_LABELS = { '10.0.10.5': 'node1', '10.0.10.6': 'node2' };

const RE_TS = /^\[(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\]/;
const RE_SYNCING = /=== Syncing ([\d.]+) ===/;
const RE_DONE = /✓ ([\d.]+) done/;
const RE_NO_PATHS = /No paths to sync for ([\d.]+)/;
const RE_SYNC = /SYNC: (\S+) → (\S+)/;
const RE_STATS = /STATS: ([\d.]+)\|([^|]+)\|rc=(\d+)\|files=(\d+)\|size=(\S+?) bytes\|speedup=(\S+)/;
const RE_ERROR = /ERROR: ([\d.]+)\/(\S+) rsync rc=(\d+)/;

function humanToBytes(s) {
  if (s == null) return 0;
  s = String(s).trim().toUpperCase().replace(/B$/, '');
  const mult = { K: 1024, M: 1024 ** 2, G: 1024 ** 3, T: 1024 ** 4 };
  const last = s.slice(-1);
  if (mult[last]) return Math.round(parseFloat(s.slice(0, -1)) * mult[last]) || 0;
  return parseInt(s, 10) || 0;
}

function parseLocalTs(ts) {
  // "2026-09-17 01:36:52" -> Date en heure locale du conteneur (TZ=Europe/Paris)
  if (!ts) return null;
  const [d, t] = ts.split(' ');
  const [Y, M, D] = d.split('-').map(Number);
  const [h, m, s] = t.split(':').map(Number);
  return new Date(Y, M - 1, D, h, m, s);
}

function humanBytes(n) {
  n = Number(n);
  if (!isFinite(n)) return '?';
  const units = ['B', 'K', 'M', 'G', 'T'];
  let i = 0;
  while (n >= 1024 && i < units.length - 1) { n /= 1024; i++; }
  return (i === 0 ? n.toFixed(0) : n.toFixed(1)) + units[i];
}

function loadState() {
  try {
    return JSON.parse(fs.readFileSync(STATE_PATH, 'utf8'));
  } catch (e) {
    return { runs: [], projects: {} };
  }
}

function saveState(state) {
  fs.writeFileSync(STATE_PATH, JSON.stringify(state, null, 2));
}

function parseLogFile(file, state) {
  const content = fs.readFileSync(file, 'utf8');
  let currentNode = null;
  let runStartTs = null;
  let nodeSyncCount = 0;

  for (const line of content.split('\n')) {
    const mts = line.match(RE_TS);
    const ts = mts ? mts[1] : null;

    let m = line.match(RE_SYNCING);
    if (m) { currentNode = m[1]; runStartTs = ts; nodeSyncCount = 0; continue; }

    m = line.match(RE_DONE);
    if (m && currentNode) {
      addRun(state, runStartTs || '', currentNode, 'OK', nodeSyncCount);
      continue;
    }

    m = line.match(RE_NO_PATHS);
    if (m) { addRun(state, ts || '', m[1], 'NO_PATHS', 0); continue; }

    m = line.match(RE_STATS);
    if (m) {
      const [, node, proj, rc, files, sizeH] = m;
      addRun(state, ts || '', node, 'OK', 1); // increment count below
      upsertProject(state, node, proj, ts, parseInt(files, 10), humanToBytes(sizeH));
      nodeSyncCount++;
      continue;
    }

    m = line.match(RE_SYNC);
    if (m) {
      const [, src, proj] = m;
      upsertProject(state, currentNode || '', proj, ts, null, null, src);
      nodeSyncCount++;
      continue;
    }

    m = line.match(RE_ERROR);
    if (m) { addRun(state, ts || '', m[1], 'ERROR', 0); }
  }
}

function addRun(state, ts, node, status, cnt) {
  const key = `${ts}|${node}`;
  if (state._seen && state._seen.has(key)) return;
  if (!state._seen) state._seen = new Set();
  state._seen.add(key);
  state.runs.push({ ts, node, status, cnt });
}

function upsertProject(state, node, proj, ts, files, sizeB, src) {
  if (!node) return;
  const k = `${node}|${proj}`;
  const p = state.projects[k] || { node, project: proj, src_dir: src || '', last_sync_ts: null, last_files: 0, last_size_bytes: 0, sync_count: 0 };
  if (ts) p.last_sync_ts = ts;
  if (files != null) p.last_files = files;
  if (sizeB != null) p.last_size_bytes = sizeB;
  if (src) p.src_dir = src;
  p.sync_count += 1;
  state.projects[k] = p;
}

function loadBlacklist() {
  try {
    return fs.readFileSync(BLACKLIST_FILE, 'utf8').split('\n').map(s => s.trim()).filter(Boolean);
  } catch (e) { return []; }
}

// Projets archivés/remplacés : présents dans l'historique mais volontairement retirés.
// Format par ligne: "project" (tous nodes) OU "project@node" (node précis, ex: n8n@10.0.10.6)
const ARCHIVED_FILE = process.env.RSYNC_ARCHIVED || '';
function loadArchived() {
  try {
    return fs.readFileSync(ARCHIVED_FILE, 'utf8').split('\n').map(s => s.trim()).filter(Boolean);
  } catch (e) { return []; }
}

function isArchived(p, archSet) {
  if (archSet.has(p.project)) return true;
  if (archSet.has(`${p.project}@${p.node}`)) return true;
  return false;
}

function statusFor(lastTs, now) {
  if (!lastTs) return '🔴 NEVER';
  const last = parseLocalTs(lastTs);
  if (!last) return '🔴 NEVER';
  const ageH = (now - last) / 3600000;
  if (ageH <= STALE_HOURS) return '🟢 OK';
  if (ageH <= 72) return '🟡 STALE';
  return '🔴 STALE';
}

function ageStr(lastTs, now) {
  if (!lastTs) return '—';
  const last = parseLocalTs(lastTs);
  if (!last) return '—';
  const d = now - last;
  const h = Math.floor(d / 3600000);
  if (h < 1) return `${Math.floor(d / 60000)}m`;
  if (h < 48) return `${h}h`;
  return `${Math.floor(h / 24)}j`;
}

function fmtTs(ts) { return ts ? ts.slice(5, 16) : '—'; }

function render(state, now) {
  const bl = new Set(loadBlacklist());
  const arch = new Set(loadArchived());
  const L = [];
  L.push('# 📊 Rsync Dashboard — NAS ← node1 · node2');
  L.push(`> Plan: horaire \`0 * * * *\` · Màj auto: ${now.toISOString().slice(0, 16).replace('T', ' ')} · moteur Node/JSON · seuil STALE: ${STALE_HOURS}h`);
  L.push('');

  // projets actifs (hors blacklist et archivés) — uniquement vus dans les 7 derniers jours
  const byNode = {};
  let ok = 0, stale = 0, never = 0;
  const cutoff7 = new Date(now - 7 * 86400000);
  for (const p of Object.values(state.projects)) {
    if (bl.has(p.project) || isArchived(p, arch)) continue;
    // projet retire/disparu: pas vu depuis 7j -> ignore (ni actif ni alerte)
    const last = p.last_sync_ts ? parseLocalTs(p.last_sync_ts) : null;
    if (!last || last < cutoff7) continue;
    (byNode[p.node] = byNode[p.node] || []).push(p);
    const st = statusFor(p.last_sync_ts, now);
    if (st.startsWith('🟢')) ok++; else if (st.startsWith('🟡')) stale++; else never++;
  }
  const total = ok + stale + never;
  const banner = (stale === 0 && never === 0) ? '🟢' : (never === 0 ? '🟡' : '🔴');

  L.push(`## ${banner} État global`);
  L.push(`**${ok}/${total} projets frais** · 🟡 ${stale} stale · 🔴 ${never} never · dernier run: ${lastRun(state)}`);
  L.push('');

  // activité 7j (runs OK par jour)
  L.push('## 📈 Activité (7 derniers jours)');
  for (let i = 6; i >= 0; i--) {
    const day = new Date(now - i * 86400000).toISOString().slice(0, 10);
    const cnt = state.runs.filter(r => r.status === 'OK' && r.ts.slice(0, 10) === day).reduce((a, r) => a + (r.cnt || 0), 0);
    const bar = cnt ? '█'.repeat(Math.min(cnt, 20)) : '░';
    const d = new Date(now - i * 86400000);
    L.push(`\`${d.toLocaleDateString('fr-FR', { weekday: 'short' })} ${day.slice(8)}/${day.slice(5, 7)}  ${bar} ${cnt}\``);
  }
  L.push('');

  // tables par node
  for (const node of Object.keys(byNode).sort((a, b) => (NODE_LABELS[a] || a).localeCompare(NODE_LABELS[b] || b))) {
    L.push(`## 🗂️ ${NODE_LABELS[node] || node} — ${node}`);
    L.push('| Projet | Dernière sync | Âge | Fichiers | Taille | Runs 7j | Statut |');
    L.push('|---|---|---|---|---|---|---|');
    for (const p of byNode[node].sort((a, b) => a.project.localeCompare(b.project))) {
      const st = statusFor(p.last_sync_ts, now);
      const runs7 = state.runs.filter(r => r.node === node && r.status === 'OK' && parseLocalTs(r.ts) >= new Date(now - 7 * 86400000)).length;
      L.push(`| ${p.project} | ${fmtTs(p.last_sync_ts)} | ${ageStr(p.last_sync_ts, now)} | ${p.last_files || 0} | ${humanBytes(p.last_size_bytes)} | ${runs7}/168 | ${st} |`);
    }
    L.push('');
  }

  // blacklist
  if (bl.size) {
    L.push('## ⚫ Blacklistés (volontairement exclus)');
    L.push('`' + [...bl].sort().join('` · `') + '`');
    L.push('');
  }

  // archivés (remplacés/retirés, présents dans l'historique)
  if (arch.size) {
    L.push('## 📦 Archivés (remplacés / retirés)');
    for (const entry of [...arch].sort()) {
      const [name, node] = entry.includes('@') ? entry.split('@') : [entry, null];
      const seen = Object.values(state.projects).filter(p => p.project === name && (!node || p.node === node));
      const last = seen.length ? seen.map(p => p.last_sync_ts).filter(Boolean).sort().pop() : null;
      const nodeLabel = node ? ` (${NODE_LABELS[node] || node})` : '';
      L.push(`- \`${name}\`${nodeLabel} — retiré le ${fmtTs(last)} · remplacé par obsidian`);
    }
    L.push('');
  }

  // derniers runs (pivot par heure)
  L.push('## 🧾 Derniers runs');
  L.push('| Heure | node1 | node2 | Total | Note |');
  L.push('|---|---|---|---|---|');
  const seen = {};
  for (const r of state.runs) {
    const hour = r.ts.slice(0, 13);
    (seen[hour] = seen[hour] || {})[r.node] = r;
  }
  for (const hour of Object.keys(seen).sort().reverse().slice(0, 10)) {
    const d = seen[hour];
    const cell = (e) => !e ? '—' : (e.status === 'OK' && e.cnt > 0 ? `✅ ${e.cnt}` : (e.status === 'OK' ? '⚪ 0' : `🔴 ${e.status}`));
    const c1 = cell(d['10.0.10.5']), c2 = cell(d['10.0.10.6']);
    const total = [d['10.0.10.5'], d['10.0.10.6']].reduce((a, e) => a + ((e && e.status === 'OK') ? (e.cnt || 0) : 0), 0);
    const note = total === 0 ? 'aucun transfert' : '';
    L.push(`| ${hour.slice(11) || hour}:00 | ${c1} | ${c2} | ${total} | ${note} |`);
  }
  L.push('');

  // paramètres
  L.push('## ⚙️ Paramètres');
  L.push(`- Seuil STALE: **${STALE_HOURS}h** · Fréquence: horaire \`0 * * * *\``);
  L.push(`- Parser cron (sidecar): \`5 * * * *\` · Rétention logs: 72j`);
  L.push(`- Sources: \`${LOG_DIR}/*.log\` → \`${STATE_PATH}\``);
  L.push(`- Généré par \`rsync_dashboard.js\` le ${now.toISOString().slice(0, 16).replace('T', ' ')}`);
  L.push('');
  return L.join('\n');
}

function lastRun(state) {
  const okRuns = state.runs.filter(r => r.status === 'OK' && r.cnt > 0);
  if (!okRuns.length) return '—';
  const last = okRuns.reduce((a, b) => (a.ts > b.ts ? a : b));
  return last.ts.slice(11, 16);
}

function main() {
  const args = process.argv.slice(2);
  fs.mkdirSync(path.dirname(STATE_PATH), { recursive: true });
  const state = loadState();

  if (args.includes('--backfill')) {
    const files = fs.readdirSync(LOG_DIR).filter(f => f.endsWith('.log')).sort();
    for (const f of files) parseLogFile(path.join(LOG_DIR, f), state);
    console.log(`[backfill] ${files.length} fichiers parsés`);
  }
  if (args.includes('--incremental')) {
    const today = new Date().toISOString().slice(0, 10);
    const f = path.join(LOG_DIR, `${today}.log`);
    if (fs.existsSync(f)) { parseLogFile(f, state); console.log(`[incremental] ${today}.log parsé`); }
  }

  // dedup runs pour le rendu (state.runs peut contenir des doublons entre runs)
  if (args.includes('--render') || args.includes('--backfill') || args.includes('--incremental')) {
    const note = render(state, new Date());
    fs.mkdirSync(path.dirname(NOTE_PATH), { recursive: true });
    fs.writeFileSync(NOTE_PATH, note);
    console.log(`[render] note: ${NOTE_PATH}`);
  }

  // sauvegarder l'etat (sans le _seen interne)
  const out = { runs: state.runs, projects: state.projects };
  saveState(out);
}

main();
