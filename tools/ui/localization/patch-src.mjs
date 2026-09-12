#!/usr/bin/env node
/**
 * Применяет патчи из localization/patches/ к src/.
 * Идемпотентен: если патч уже применён — пропускает.
 * Использование: node localization/patch-src.mjs [--revert]
 */

import fs from 'node:fs';
import path from 'node:path';
import { execSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const PATCHES = path.join(__dirname, 'patches');
const REVERT = process.argv.includes('--revert');

const log = (m) => console.log(`[patch-src] ${m}`);

if (!fs.existsSync(PATCHES)) {
  log('Нет папки patches/ — выходим');
  process.exit(0);
}

const files = fs.readdirSync(PATCHES).filter((f) => f.endsWith('.patch')).sort();
if (files.length === 0) {
  log('Нет .patch файлов — выходим');
  process.exit(0);
}

for (const f of files) {
  const patchPath = path.join(PATCHES, f);

  let canApply = false;
  try {
    execSync(`git apply --check ${REVERT ? '--reverse ' : ''}"${patchPath}"`, {
      cwd: ROOT, stdio: 'pipe',
    });
    canApply = true;
  } catch { canApply = false; }

  if (canApply) {
    try {
      execSync(`git apply ${REVERT ? '--reverse ' : ''}"${patchPath}"`, {
        cwd: ROOT, stdio: 'pipe',
      });
      log(`${REVERT ? '↩ откачен' : '✓ применён'}: ${f}`);
    } catch (e) {
      log(`✗ ошибка: ${f}`);
      log(String(e.stderr ?? e));
      process.exit(1);
    }
  } else {
    let alreadyApplied = false;
    try {
      execSync(`git apply --check --reverse "${patchPath}"`, { cwd: ROOT, stdio: 'pipe' });
      alreadyApplied = true;
    } catch { alreadyApplied = false; }

    if (alreadyApplied) {
      log(`= уже применён: ${f}`);
    } else {
      log(`⚠ НЕ СОВПАДАЕТ с текущим src/: ${f}`);
      log(`  → upstream изменил файл. Проверьте вручную.`);
    }
  }
}
