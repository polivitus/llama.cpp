# Локализация WebUI llama.cpp — рабочий журнал

## Цель
Русификация WebUI llama.cpp с возможностью обновления из upstream
без потери переводов и конфликтов слияния.

## Расположение
- Репозиторий:      ~/llama.cpp/
- WebUI:            tools/ui/
- Локализация:      tools/ui/localization/
- Ветка git:        ru-localization
- Модель:           /home/it/models/medgemma-4b-it-Q4_K_M.gguf

## Архитектура
1. `patches/*.patch` — правки src/ (Svelte-исходники), применяются `git apply`
2. `ru.json`        — словарь для dist/ (только длинные фразы ≥ 2 слов)
3. `apply.mjs`      — русификация dist/ после `npm run build`
4. `patch-src.mjs`  — идемпотентное применение патчей к src/
5. `rebuild.sh`     — патчи → build → apply → llama-server
6. `update.sh`      — откат → git pull → патчи → build → apply

## Инварианты
- Локаль: LANG=C.UTF-8 (проверено, nano пишет UTF-8)
- Пути в патчах: `a/src/...` → `b/src/...` (cwd = tools/ui/)
- Все .patch — UTF-8. Проверка: `file *.patch` → "UTF-8 Unicode text"
- Никаких коротких ключей в ru.json (tokens, used, Edit, Cancel...) —
  они переводятся ТОЛЬКО через патчи
- apply.mjs использует UI_ATTRS (label/children/description/...),
  НЕ голые литералы
- patch-src.mjs падает (exit 1) при FAIL — rebuild.sh останавливается

## Статус (обновляется по ходу)

### Сделано
- [x] Чистый клон upstream
- [x] Локаль UTF-8
- [x] Журналы (PROJECT, CHANGELOG, NOTES)
- [x] Скелет localization/ + скрипты
- [x] ru.json — черновик (~120 фраз)
- [x] Патч 001-greeting
- [x] Патч 005-translate-browser
- [x] Патч 006-translate-tools-submenu
- [ ] npm install / npm run build
- [ ] cmake build llama-server

### Следующий шаг
Патч 005: ui.constants.ts — TOOL_GROUP_LABELS.BROWSER 'Browser' → 'Браузер'

## Список патчей (чек-лист)

| # | Файл | Статус |
|---|---|---|
| 001 | ChatScreenGreeting.svelte | DONE |
| 005 | ui.constants.ts (TOOL_GROUP_LABELS) | DONE |
| 006 | ChatFormActionAddToolsSubmenu.svelte | DONE |
| 007 | ChatFormActionAddSheet.svelte | TODO |
| 011 | DialogConfirmation.svelte | TODO |
| 013 | ChatMessageActionIcons.svelte | TODO |
| ... | ... | ... |

## Известные проблемы (из прошлой сессии)
- 007 и 020 были битые по кодировке (cp1251 / тайский) — пересоздать в UTF-8
- apply.mjs использовал Worker (оверхед) — убрать
- apply.mjs искал голые литералы — заменить на UI_ATTRS
- ru.json содержал tokens/used/remaining/Edit/Pin — удалить
- patch-src.mjs молча пропускал FAIL — добавить exit 1

## Команды

```bash
# Полный rebuild
cd ~/llama.cpp/tools/ui
bash localization/rebuild.sh

# Обновление upstream
bash localization/update.sh

# Диагностика патчей
bash localization/verify.sh

# Запуск сервера
bash localization/start.sh
