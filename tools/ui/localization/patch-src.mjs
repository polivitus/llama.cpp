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

// Карта маркеров: если патч УЖЕ применён (по этим строкам), пропускаем его.
// Нужно, когда последующие патчи меняют контекст и git apply --reverse не работает.
const APPLIED_MARKERS = {
  '44-svelte-all.patch':        ['Удалить ${messageActions', 'инструментов', 'Свои заголовки'],
  '45-server-error-mcp.patch':  ['Таймаут TCP', 'Рекомендуемые серверы', 'запросов на слияние'],
  '46-mcp-placeholder.patch':   ['Имя, сообщаемое сервером', 'необязательно'],
  '47-error-dialogs.patch':     ['Запрос не получил ответа', 'Доступ запрещён'],
  '48-model-info.patch':        ['Информация о модели', 'Копировать в буфер', 'Размер эмбеддинга'],
  '49-formatters-units.patch':  ['токенов', 'млрд', 'тыс.'],
  '50-vocab-type-boolean.patch': ["? 'Да' : 'Нет'"],
  '51-copy-tooltip-side.patch':  ['tooltipSide: TooltipSide = TooltipSide.LEFT'],
};

function isAlreadyApplied(patchName, gitRoot) {
  const markers = APPLIED_MARKERS[patchName];
  if (!markers) return false;
  // Ищем в tools/ui/src/ (cwd = gitRoot)
  const srcDir = path.join(gitRoot, 'tools', 'ui', 'src');
  try {
    for (const m of markers) {
      const out = execSync(`grep -rl -- "${m}" "${srcDir}" 2>/dev/null`, {
        encoding: 'utf-8',
      }).trim();
      if (out) return true;
    }
  } catch {
    // grep возвращает exit 1, если не нашёл
  }
  return false;
}

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
      // Последняя попытка: проверить по маркерам
      if (isAlreadyApplied(f, GIT_ROOT)) {
        log(`= уже применён (по маркеру): ${f}`);
        continue;
      }
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
