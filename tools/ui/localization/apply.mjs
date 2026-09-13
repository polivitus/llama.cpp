#!/usr/bin/env node
/**
 * Русификация WebUI llama.cpp.
 * Переводит ТОЛЬКО UI-строки — значения label:, title:, help:, placeholder:,
 * children:, description:, aria-label:, tooltip:, text: в JS/HTML/CSS.
 * Не трогает код, классы, идентификаторы, пути.
 */

import fs from 'node:fs';
import fsp from 'node:fs/promises';
import path from 'node:path';
import os from 'node:os';
import { fileURLToPath } from 'node:url';
import { Worker, isMainThread, parentPort, workerData } from 'node:worker_threads';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const DIST = path.join(ROOT, 'dist');

const DRY = process.argv.includes('--dry');
const REVERT = process.argv.includes('--revert');

const log = (m) => console.log(`[localize] ${m}`);

// Только UI-контексты. Каждый regex захватывает ПРЕФИКС и ЗНАЧЕНИЕ.
// Префикс сохраняется, значение заменяется.
const UI_ATTRS = [
  'label', 'title', 'help', 'placeholder', 'children', 'description',
  'aria-label', 'tooltip', 'text', 'alt', 'content',
];

// Строим один regex на атрибут. Значение — двойные/одинарные/бэктик-кавычки.
function buildAttrRegex(attr) {
  // label:"..."  label:'...'  label:`...`
  return new RegExp(
    `\\b${attr}\\s*:\\s*("([^"\\\\]*(?:\\\\.[^"\\\\]*)*)"|'([^'\\\\]*(?:\\\\.[^'\\\\]*)*)'|\`([^\`\\\\]*(?:\\\\.[^\`\\\\]*)*)\`)`,
    'g'
  );
}

function buildMatcher(dict) {
  return { dict };
}

function escapeHtml(s) {
  return s; // значения уже plain text
}

function replaceAll(text, { dict }) {
  let n = 0;
   // Специальные случаи: шаблонные строки с ${...}
      text = text.replace(/`Chat \$\{/g, () => { n++; return '`Беседа ${'; });

  for (const [en, ru] of Object.entries(dict)) {
    const escaped = en.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    const patterns = [
      new RegExp('"' + escaped + '"', 'g'),
      new RegExp("'" + escaped + "'", 'g'),
      new RegExp('`' + escaped + '`', 'g'),
      new RegExp('>' + escaped + '<', 'g'),
    ];
    for (const re of patterns) {
      text = text.replace(re, (m) => {
        n++;
        const q = m[0];
        if (q === '>') return '>' + ru + '<';
        return q + ru + q;
      });
    }
  }

  return [text, n];
}

async function findAssets() {
  const out = [];
  const idx = path.join(DIST, 'index.html');
  if (fs.existsSync(idx)) out.push(idx);
  const walk = async (d) => {
    let es; try { es = await fsp.readdir(d, { withFileTypes: true }); } catch { return; }
    for (const e of es) {
      const p = path.join(d, e.name);
      if (e.isDirectory()) await walk(p);
      else if (/\.(js|css|html)$/.test(e.name) && !e.name.endsWith('.bak')) out.push(p);
    }
  };
  await walk(DIST);
  return out;
}

if (!isMainThread) {
  const { file, dict, dry } = workerData;
  try {
    const matcher = buildMatcher(dict);
    const orig = await fsp.readFile(file, 'utf-8');
    const [updated, n] = replaceAll(orig, matcher);
    if (n === 0) { parentPort.postMessage({ file, n: 0 }); process.exit(0); }
    if (!dry) {
      const bak = file + '.bak';
      if (!fs.existsSync(bak)) await fsp.copyFile(file, bak);
      await fsp.writeFile(file, updated, 'utf-8');
    }
    parentPort.postMessage({ file, n });
  } catch (e) { parentPort.postMessage({ file, error: String(e) }); }
  process.exit(0);
}

async function revert() {
  const files = await findAssets();
  let n = 0;
  await Promise.all(files.map(async (f) => {
    if (fs.existsSync(f + '.bak')) {
      await fsp.copyFile(f + '.bak', f);
      await fsp.unlink(f + '.bak');
      n++;
    }
  }));
  log(`Откатано: ${n}`);
}

async function apply() {
  if (!fs.existsSync(DIST)) { log('ОШИБКА: dist/ не найден'); process.exit(1); }
  const dict = JSON.parse(await fsp.readFile(path.join(__dirname, 'ru.json'), 'utf-8'));
  log(`Фраз: ${Object.keys(dict).length} | ${DRY ? 'DRY' : 'APPLY'}`);
  const files = await findAssets();
  const t0 = performance.now();
  const concurrency = Math.max(1, os.cpus().length - 1);
  const queue = [...files];
  const results = [];
  async function worker() {
    while (queue.length) {
      const f = queue.shift();
      try {
        const r = await new Promise((res, rej) => {
          const w = new Worker(fileURLToPath(import.meta.url), { workerData: { file: f, dict, dry: DRY } });
          w.once('message', res);
          w.once('error', rej);
        });
        results.push(r);
      } catch (e) { results.push({ file: f, error: String(e) }); }
    }
  }
  await Promise.all(Array.from({ length: concurrency }, worker));
  let total = 0;
  for (const r of results) {
    if (r.error) log(`✗ ${path.relative(ROOT, r.file)}: ${r.error}`);
    else if (r.n > 0) { log(`✓ ${path.relative(ROOT, r.file)}: ${r.n}`); total += r.n; }
  }
  log(`Итого: ${total} замен | ${(performance.now() - t0).toFixed(0)} мс`);
}

if (REVERT) await revert();
else await apply();
