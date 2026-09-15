#!/usr/bin/env node
import fs from 'node:fs';
import fsp from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const DIST = path.join(ROOT, 'dist');

const DRY = process.argv.includes('--dry');
const REVERT = process.argv.includes('--revert');
const log = (m) => console.log(`[localize] ${m}`);

const UI_ATTRS = ['label','title','help','placeholder','children','description','aria-label','tooltip','triggerTooltip','text','alt','content'];
const TEMPLATES = [
  [/`Chat \$\{/g, '`Беседа ${'],
  [/`Delete \$\{/g, '`Удалить ${'],
  [/`Fork of \$\{/g, '`Ответвление от ${'],
];

function replaceAll(text, dict) {
  let n = 0;
  for (const [re, rep] of TEMPLATES) text = text.replace(re, () => { n++; return rep; });

   const attrAlt = UI_ATTRS.map(a => a.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')).join('|');
  for (const [en, ru] of Object.entries(dict)) {
    const esc = en.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    // JS-объект: label:"Text", children:'Text'
    const reAttr = new RegExp(`(\\b(?:${attrAlt})\\s*:\\s*)(["'\`])${esc}\\2`, 'g');
    text = text.replace(reAttr, (_, p, q) => { n++; return `${p}${q}${ru}${q}`; });
    // HTML-атрибут: placeholder="Text", aria-label='Text'
    const reHtmlAttr = new RegExp(`(\\b(?:${attrAlt})\\s*=\\s*)(["'])${esc}\\2`, 'g');
    text = text.replace(reHtmlAttr, (_, p, q) => { n++; return `${p}${q}${ru}${q}`; });
    // HTML-текст: >Text<
    const reHtml = new RegExp(`>${esc}<`, 'g');
    text = text.replace(reHtml, () => { n++; return `>${ru}<`; });
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
      else if (/\.(js|css|html)$/.test(e.name) && !e.name.endsWith('.bak') && !/vendor|svelte|runtime/i.test(e.name))
        out.push(p);
    }
  };
  await walk(DIST);
  return out;
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
  let total = 0;
  for (const f of files) {
    const orig = await fsp.readFile(f, 'utf-8');
    const [updated, n] = replaceAll(orig, dict);
    if (n === 0) continue;
    if (!DRY) {
      const bak = f + '.bak';
      if (!fs.existsSync(bak)) await fsp.copyFile(f, bak);
      await fsp.writeFile(f, updated, 'utf-8');
    }
    log(`✓ ${path.relative(ROOT, f)}: ${n}`);
    total += n;
  }
  log(`Итого: ${total} замен | ${(performance.now() - t0).toFixed(0)} мс`);
}

if (REVERT) await revert();
else await apply();
