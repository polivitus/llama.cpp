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

## Стратегия (важно!)
**ru.json-first:** длинные фразы (≥ 2 слов, заглавная + пробел) — в `ru.json`.
**Патчи** — только для:
- коротких строк (Edit, Pin, Save, Tools, System...)
- строк с интерполяцией (`{count} tokens`)
- строк в JS-объектах внутри HTML-атрибутов (если ru.json не ловит)
- "pr()/t()/_()" — apply.mjs уже умеет, ru.json работает

## Статус (на 2026-09-16)

### Сделано
- [x] Чистый клон upstream
- [x] Локаль UTF-8
- [x] Журналы (PROJECT, CHANGELOG, NOTES)
- [x] Скелет localization/ + скрипты
- [x] ru.json — 233 фразы
- [x] 34 патча — все применены и закоммичены
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
Проверить вкладки Display, Tools, Agentic, Developer после последней
пересборки — остались ли английские строки. Скинуть скриншоты.

## Список патчей (34, все DONE)

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
| 23 | settings-header.patch | DialogSettingsChat + SettingsChatImportExportTab |
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

## Известные проблемы (решены)
- ~~007/020 битые по кодировке~~ — пересозданы в UTF-8
- ~~apply.mjs с Worker~~ — убран
- ~~apply.mjs голые литералы~~ — заменено на UI_ATTRS
- ~~ru.json короткие ключи~~ — удалены
- ~~patch-src.mjs молча пропускал FAIL~~ — добавлен exit 1
- ~~apply.mjs не поддерживал triggerTooltip, HTML-атрибуты, pr()/t()~~ — добавлено
- ~~SidebarNavigationSelectionBar конфликт двух патчей~~ — объединён в sidebar-selection
- ~~processing-state + stats-tokens-count конфликт~~ — разделены, оба пересозданы

## Осталось проверить (на 2026-09-16)
- [ ] Display tab
- [ ] Tools tab
- [ ] Agentic tab
- [ ] Developer tab
- [ ] Sброс/сейв настройки

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
