# Локализация WebUI llama.cpp — рабочий журнал

## Цель
Русификация WebUI llama.cpp с возможностью обновления из upstream
без потери переводов и конфликтов слияния.

## Расположение
- Репозиторий:      ~/llama.cpp/
- WebUI:            tools/ui/
- Локализация:      tools/ui/localization/
- Ветка git:        ru-localization (и master — синхронизированы)
- Форк:             git@github.com:polivitus/llama.cpp.git
- Модель:           /home/it/models/medgemma-4b-it-Q4_K_M.gguf

## Архитектура
1. `patches/*.patch` — правки src/ (Svelte-исходники), применяются `git apply`
2. `ru.json`        — словарь для dist/ (длинные фразы ≥ 2 слов)
3. `apply.mjs`      — русификация dist/ после `npm run build`
4. `patch-src.mjs`  — идемпотентное применение патчей к src/
5. `rebuild.sh`     — патчи → build → apply → llama-server
6. `update.sh`      — откат → git pull → патчи → build → apply

## Инварианты
- Локаль: LANG=C.UTF-8 (nano пишет UTF-8)
- Пути в патчах: `a/src/...` → `b/src/...` (cwd = tools/ui/)
- Все .patch — UTF-8. Проверка: `file *.patch` → "UTF-8 Unicode text"
- Короткие ключи (Edit, Pin, Save, Copy, Tools...) — ТОЛЬКО через патчи
- Длинные фразы (≥ 2 слов) — через `ru.json`
- apply.mjs использует UI_ATTRS (label/children/description/tooltip/triggerTooltip...)
  + HTML-атрибуты (attr="Text") + функции pr()/t()/_()
- patch-src.mjs падает (exit 1) при FAIL
- patch-src.mjs идемпотентен через APPLIED_MARKERS (карта маркеров)
- apply.mjs: UI_ATTRS +cancelText/confirmText/buttonText + TEMPLATES (12 шаблонов)

## Стратегия (важно!)
**ru.json-first:** длинные фразы (≥ 2 слов, заглавная + пробел) — в `ru.json`.
**Патчи** — только для:
- коротких строк (Edit, Pin, Save, Tools, System...)
- строк с интерполяцией (`{count} tokens`)
- строк в JS-объектах внутри HTML-атрибутов (если ru.json не ловит)
- "pr()/t()/_()" — apply.mjs уже умеет, ru.json работает

## Статус (на 2026-09-17)

### Сделано
- [x] Чистый клон upstream
- [x] Локаль UTF-8
- [x] Журналы (PROJECT, CHANGELOG, NOTES)
- [x] Скелет localization/ + скрипты
- [x] ru.json — 254 фразы
- [x] 47 патчей — все применены и закоммичены
- [x] npm install / npm run build
- [x] cmake build llama-server
- [x] server-http.cpp пропатчен (gzip Content-Encoding fix)
- [x] apply.mjs: +triggerTooltip, +HTML-атрибуты, +pr()/t()/_()
- [x] formatters.ts: s/min/h → с/мин/ч
- [x] Settings: все вкладки, заголовки, футер, табы
- [x] Import/Export: все фразы
- [x] Context gauge: попап, детали, загрузка модели
- [x] Sidebar: меню беседы, закреплённые, "No conversations yet"

### Следующий шаг
✅ Все 7 вкладок Settings проверены в браузере и русифицированы:
Общие, Отображение, Инструменты, Агентные, Импорт/Экспорт,
Сэмплирование и штрафы, Разработчик.
Осталось: обновление upstream + периодическая проверка после pull.

## Список патчей (47, все DONE)

| # | Имя | Файл |
|---|---|---|
| 1 | attachment-tooltip.patch | attachment-menu.constants.ts |
| 2 | cancel-save-buttons.patch | MCP/диалоги (9 файлов) |
| 3 | chat-form-placeholder.patch | ChatForm.svelte |
| 4 | chat-greeting.patch | ChatScreenGreeting.svelte |
| 5 | chat-message-statistics.patch | ChatMessageStatistics.svelte (tokens, t/s) |
| 6 | chat-tabs-new-label.patch | chat-tabs.constants + ChatTabsNewChatButton |
| 7 | context-gauge.patch | ChatFormContextGauge/* (4 файла) |
| 8 | delete-search.patch | routes/search/+page.svelte |
| 9 | delete-sidebar.patch | SidebarNavigation.svelte |
| 10 | delete-toast-pluralize.patch | stores/conversations/index.svelte.ts |
| 11 | dialog-confirmation.patch | DialogConfirmation.svelte |
| 12 | fork-of-name.patch | ChatMessageActionIcons.svelte |
| 13 | formatters-time-unit.patch | utils/formatters.ts |
| 14 | mcp-save-label.patch | DialogMcpServerAddNew.svelte |
| 15 | message-actions.patch | ChatMessageActionIcons.svelte |
| 16 | processing-state.patch | use-processing-state + ChatMessageAssistantProcessingInfo |
| 17 | pwa-refresh-alert.patch | PwaRefreshAlert.svelte |
| 18 | rename-conversation.patch | DialogConversationRename.svelte |
| 19 | search-results-empty.patch | SidebarNavigationSearchResults.svelte |
| 20 | server-http-gzip.patch | tools/server/server-http.cpp |
| 21 | server-splash.patch | ServerErrorSplash + ServerLoadingSplash |
| 22 | settings-footer.patch | SettingsFooter + SettingsChat + SettingsChatFields |
| 24 | settings-stats-help.patch | settings.constants.ts (help) |
| 25 | settings-tabs.patch | settings.constants.ts (табы, тема, API Key help) |
| 26 | sidebar-conversation-list.patch | SidebarNavigationConversationList.svelte |
| 27 | sidebar-conversation-menu.patch | SidebarNavigationConversationItem.svelte |
| 28 | sidebar-more-actions.patch | SidebarNavigationConversationItem.svelte |
| 29 | sidebar-selection.patch | SidebarNavigationSelectionBar.svelte |
| 30 | sidebar-toggle-tooltip.patch | SidebarNavigation.svelte |
| 31 | system-message-editor.patch | ChatMessageSystem.svelte |
| 32 | tool-sheet.patch | ChatFormActionAddSheet.svelte |
| 33 | tool-submenu.patch | ChatFormActionAddToolsSubmenu.svelte |
| 34 | ui-close-labels.patch | ui/sheet + ui/dialog (sr-only Close) |
| 35 | ui-constants.patch | ui.constants.ts |
| 36 | settings-default-label.patch | SettingsChatFields.svelte (`Default:` → `По умолчанию:`) |
| 37 | settings-custom-json-css.patch | settings.constants.ts (Custom JSON/CSS) |
| 38 | settings-samplers-title.patch | settings.constants.ts (Samplers) |
| 39 | import-export-buttons.patch | SettingsChatImportExportTab.svelte (5 кнопок) |
| 40 | tools-table-headers.patch | SettingsChatToolsTab.svelte (Tool/Enabled/Always allow + No tools) |
| 41 | tools-count-pluralize.patch | SettingsChatToolsTab.svelte (N tools → N инструментов) |
| 42 | tool-ui-labels.patch | tool-ui.constants.ts (10 label тулов) |
| 44 | svelte-all.patch | 10 файлов: Cancel/Delete/Clipboard/MCP-форма/Tools |
| 45 | server-error-mcp.patch | DialogChatError + DialogMcpServerAddNew + recommended-mcp |
| 46 | mcp-placeholder.patch | McpServerForm + KeyValuePairs ((optional)) |
| 47 | error-dialogs.patch | DialogChatError + error.constants.ts |
| 48 | model-info.patch | DialogModelInformation + Copy buttons (4 файла) |
| 49 | formatters-units.patch | formatters.ts (единицы) + tokens → токенов |
| 50 | vocab-type-boolean.patch | DialogModelInformation (vocab_type ? Да : Нет) |
| 51 | copy-tooltip-side.patch | ActionIconCopyToClipboard (tooltipSide=LEFT) |

## Известные проблемы (решены)
- ~~007/020 битые по кодировке~~ — пересозданы в UTF-8
- ~~apply.mjs с Worker~~ — убран
- ~~apply.mjs голые литералы~~ — заменено на UI_ATTRS
- ~~ru.json короткие ключи~~ — удалены
- ~~patch-src.mjs молча пропускал FAIL~~ — добавлен exit 1
- ~~apply.mjs не поддерживал triggerTooltip, HTML-атрибуты, pr()/t()~~ — добавлено
- ~~SidebarNavigationSelectionBar конфликт двух патчей~~ — объединён в sidebar-selection
- ~~processing-state + stats-tokens-count конфликт~~ — разделены, оба пересозданы
- ~~settings-header.patch устарел~~ — удалён
- ~~message-actions.patch устарел~~ — удалён (покрыт #44)
- ~~pull-request'ов апостроф ломал TS~~ — заменено на "запросов на слияние"
- ~~patch-src.mjs не находил файлы в tools/ui/src/~~ — fix isAlreadyApplied
- ~~#44/#47 конфликт контекста~~ — APPLIED_MARKERS
- ~~#48/#49 конфликт контекста~~ — APPLIED_MARKERS
- ~~tooltip Copy обрезался~~ — tooltipSide=LEFT

## Осталось проверить (на 2026-09-17)
- [x] Display tab (Отображение) — ✅ проверено
- [x] Tools tab (Инструменты) — ✅ проверено, плюрализация работает
- [x] Agentic tab (Агентные) — ✅ проверено
- [x] Developer tab (Разработчик) — ✅ проверено
- [x] Сброс/сейв настройки — ✅ проверено
- [x] Import/Export — ✅ проверено
- [x] Сэмплирование и штрафы — ✅ проверено (Температура, Макс. токенов)
- [x] Model Information — ✅ проверено (Информация о модели, Гб, млрд, Да/Нет)
- [x] MCP-форма — ✅ проверено (URL сервера, Отображаемое имя, Свои заголовки)
- [x] Server Error / TCP Timeout — ✅ проверено
- [x] Copy buttons — ✅ tooltipSide=LEFT (не обрезается)

## Команды

```bash
# Полный rebuild
cd ~/llama.cpp/tools/ui
bash localization/rebuild.sh

# Обновление upstream
bash localization/update.sh

# Запуск сервера
LD_LIBRARY_PATH=~/llama.cpp/build/bin \
~/llama.cpp/build/bin/llama-server \
  -m /home/it/models/medgemma-4b-it-Q4_K_M.gguf \
  --host 0.0.0.0 --port 8081

# Синхронизация веток + push
cd ~/llama.cpp
git checkout ru-localization
git merge master --ff-only
git checkout master
git push origin master
git push origin ru-localization
