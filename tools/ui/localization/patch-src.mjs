#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import { execSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const GIT_ROOT = execSync('git rev-parse --show-toplevel', {
  cwd: ROOT, encoding: 'utf-8',
}).trim();
const PATCHES = path.join(__dirname, 'patches');
const REVERT = process.argv.includes('--revert');

const log = (m) => console.log(`[patch-src] ${m}`);

if (!fs.existsSync(PATCHES)) { log('Нет patches/'); process.exit(0); }
const files = fs.readdirSync(PATCHES).filter(f => f.endsWith('.patch')).sort();
if (!files.length) { log('Нет .patch'); process.exit(0); }

let failed = 0;

for (const f of files) {
  const patchPath = path.join(PATCHES, f);

  // UTF-8 guard
  try {
    execSync(`iconv -f UTF-8 -t UTF-8 "${patchPath}" >/dev/null 2>&1`);
  } catch {
    log(`✗ НЕ UTF-8: ${f}`);
    failed++;
    continue;
  }

  const applyFlag = REVERT ? '--reverse ' : '';
  try {
    execSync(`git apply --check ${applyFlag}"${patchPath}"`, { cwd: GIT_ROOT, stdio: 'pipe' });
  } catch {
    try {
      execSync(`git apply --check --reverse "${patchPath}"`, { cwd: GIT_ROOT, stdio: 'pipe' });
      log(`= уже применён: ${f}`);
      continue;
    } catch {
      log(`⚠ НЕ СОВПАДАЕТ: ${f}`);
      failed++;
      continue;
    }
  }

  try {
    execSync(`git apply ${applyFlag}"${patchPath}"`, { cwd: GIT_ROOT, stdio: 'pipe' });
    log(`${REVERT ? '↩ откачен' : '✓ применён'}: ${f}`);
  } catch (e) {
    log(`✗ ошибка: ${f}`);
    log(String(e.stderr ?? e));
    failed++;
  }
}

if (failed) {
  log(`❌ Провалено патчей: ${failed}`);
  process.exit(1);
}
