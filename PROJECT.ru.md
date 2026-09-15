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
- [ ] патчи
- [ ] npm install / npm run build
- [ ] cmake build llama-server

### Следующий шаг

## Список патчей (чек-лист)

| Имя | Файл | Статус |
|---|---|---|
| attachment-tooltip.patch | attachment-menu.constants.ts | DONE |
| cancel-save-buttons.patch | MCP/диалоги (много файлов) | DONE |
| chat-form-placeholder.patch | ChatForm.svelte (placeholder) | DONE |
| chat-greeting.patch | ChatScreenGreeting.svelte | DONE |
| chat-message-statistics.patch | ChatMessageStatistics.svelte (tokens, t/s) | DONE |
| chat-tabs-new-label.patch | chat-tabs.constants + ChatTabsNewChatButton | DONE |
| context-gauge.patch | ChatFormContextGauge/* (4 файла) | DONE |
| delete-search.patch | routes/search/+page.svelte | DONE |
| delete-sidebar.patch | SidebarNavigation.svelte | DONE |
| delete-toast-pluralize.patch | stores/conversations/index.svelte.ts | DONE |
| dialog-confirmation.patch | DialogConfirmation.svelte | DONE |
| fork-of-name.patch | ChatMessageActionIcons.svelte | DONE |
| mcp-save-label.patch | DialogMcpServerAddNew.svelte | DONE |
| message-actions.patch | ChatMessageActionIcons.svelte | DONE |
| processing-state.patch | use-processing-state + ChatMessageAssistantProcessingInfo | DONE |
| pwa-refresh-alert.patch | PwaRefreshAlert.svelte | DONE |
| rename-conversation.patch | DialogConversationRename.svelte | DONE |
| search-results-empty.patch | SidebarNavigationSearchResults.svelte | DONE |
| server-splash.patch | ServerErrorSplash + ServerLoadingSplash | DONE |
| server-http-gzip.patch | tools/server/server-http.cpp | DONE |
| settings-stats-help.patch | settings.constants.ts (help) | DONE |
| sidebar-conversation-list.patch | SidebarNavigationConversationList.svelte | DONE |
| sidebar-conversation-menu.patch | SidebarNavigationConversationItem.svelte | DONE |
| sidebar-selection.patch | SidebarNavigationSelectionBar.svelte | DONE |
| sidebar-toggle-tooltip.patch | SidebarNavigation.svelte | DONE |
| system-message-editor.patch | ChatMessageSystem.svelte | DONE |
| tool-sheet.patch | ChatFormActionAddSheet.svelte | DONE |
| tool-submenu.patch | ChatFormActionAddToolsSubmenu.svelte | DONE |
| ui-close-labels.patch | ui/sheet + ui/dialog (sr-only Close) | DONE |
| ui-constants.patch | ui.constants.ts | DONE |

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
