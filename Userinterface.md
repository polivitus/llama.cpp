# User-friendly UI (USER_MODE) — рабочая тетрадь

## [ДЛЯ АГЕНТА] Как восстановить контекст в новом чате
1. Прочитать этот файл целиком.
2. `git log --oneline -3` — увидеть актуальный HEAD.
3. `git status --short` — убедиться, что рабочее дерево чистое.
4. Если в конце файла есть блок «ПРОДОЛЖИТЬ С ШАГА N» — начать оттуда.

## [ДЛЯ АГЕНТА] Ключевые факты
- Проект: llama.cpp, UI в `tools/ui/` (SvelteKit + Svelte 5, `$derived`, `$state`).
- Ветка: `ru_userinterface`.
- Константа режима: `tools/ui/src/lib/constants/user-mode.ts` → `USER_MODE = true`.
  Реэкспорт: `tools/ui/src/lib/constants/index.ts` (строка 66).
- Патчи лежат в `patches/02..13-*.patch`, все 12 проходят `git apply --check`.
- Изменения закоммичены: `06dca8b08`.
- Проверки: `npm run check` — 0 ошибок; `npm run build` — OK (27.59s).

## [ДЛЯ АГЕНТА] Особые замечания
- Патчи 04 и 06 были повреждены при копипасте — пересозданы вручную
  (04 — через `printf '%s\n'` c tab-escape, 06 — правки `perl`/`python3`).
  Их `.patch`-версии в репозитории **корректны** только в части применения;
  если понадобится править заново — сверяйся с фактическим содержимым файлов.
- Патч 12 не добавляет `import { USER_MODE }` в `ChatMessageActionIcons.svelte`
  — импорт добавлен отдельной правкой. Если будет регенерация патча 12 — учесть это.
- В bash включён `histexpand` (`!` в строках ломает команды) — использовать `set +H`
  либо избегать `!` в кавычках.
- Пользователь требует фиолетовые разделители `echo -e "\033[35m...\033[0m"`
  в начале и конце каждого блока команд.
- Пользователь требует сохранять историю каждые 20 блоков команд в этот файл.


---

# User-friendly UI (USER_MODE) — история работ

## Ветка
- `ru_userinterface`

## Что сделано
Применён набор из 12 патчей (02–13), включающих USER_MODE-режим для минималистичного UI.

### Скрыто/изменено
- **02** — скрыты Tools / MCP / System message в attachment sheet.
- **03** — отключён model selector по умолчанию.
- **04** — отключён polling обновлений SW в PWA.
- **05** — скрыты reasoning-блоки в agentic content.
- **06** — скрыт context gauge (hasProcessedTokens + !USER_MODE).
- **07** — скрыта live-статистика у assistant-сообщения.
- **08** — название модели заменено на «ИИ ассистент».
- **09** — «+» заменён на «скрепку» с tooltip и прямым аплоадом.
- **10** — скрыта статистика сообщений ассистента.
- **11** — скрыта статистика сообщений пользователя.
- **12** — упрощены действия сообщений (Copy/Edit/Regenerate/Download).
- **13** — скрыт model selector в форме редактирования.

## Ключевые файлы
- tools/ui/src/lib/constants/user-mode.ts (USER_MODE = true)
- tools/ui/src/lib/constants/index.ts (реэкспорт)
- patches/02..13-*.patch — сами патчи зафиксированы в репозитории

## Проблемы и решения
- Патчи 04 и 06 изначально не применялись: `corrupt patch` из-за неверного количества табов.
  Пересозданы вручную (04 — через printf с tab-escape, 06 — через perl/python правки).
- Патч 12 не добавлял импорт `USER_MODE` в ChatMessageActionIcons.svelte.
  Импорт добавлен отдельно (python3, вставка после `import type { DatabaseMessage }`).

## Проверки
- `git apply --check` — все 12 патчей OK.
- `npm run check` (svelte-check) — 0 ошибок, 0 предупреждений.
- Коммит: `06dca8b08` — "ui: user-friendly режим (USER_MODE) — минималистичный интерфейс".
- Рабочее дерево чистое, HEAD на ветке `ru_userinterface`.

## Дальнейшие шаги (опционально)
- `npm run build` — прод-сборка.
- `git push` в origin.
- Ручное тестирование UI в браузере.

## Сборка (прод)
- `npm run build` — OK (`✓ built in 27.59s`).
- PWA precache: 67 entries (9597.68 KiB).
- Вывод: `./dist` (adapter-static), build.json version: b0000.

## [ДЛЯ АГЕНТА] ПРОДОЛЖИТЬ С ШАГА 44
Текущее состояние:
- Все патчи применены и закоммичены (`06dca8b08`).
- `npm run check` — OK, `npm run build` — OK.
- Рабочее дерево чистое.

Незавершённые опциональные задачи:
- [ ] `git push` ветки `ru_userinterface` в origin.
- [ ] Ручное тестирование UI через `npm run preview` (порт по умолчанию 4173).
- [ ] Проверка PWA: обновления SW не поллятся (патч 04).
- [ ] Визуальная проверка: скрытые элементы (статистика, reasoning, gauge, model selector).
- [ ] Проверка кнопки «скрепка» (прямой аплоад файлов).
- [ ] Проверка Download-кнопки у assistant-сообщений.

## [ЖУРНАЛ] Шаги 41–45
- 41: Создан `Userinterface.md` (первая версия).
- 42: В файл добавлена запись об успешной прод-сборке (`npm run build`, 27.59s).
- 43: В начало файла добавлена шапка «[ДЛЯ АГЕНТА] Как восстановить контекст».
- 44: В конец файла добавлен блок «ПРОДОЛЖИТЬ С ШАГА 44» + коммит `ca57f8643`.
- 45: `git push origin ru_userinterface` → OK (`8007e0453..ca57f8643`).

Статус: HEAD = `ca57f8643` на `origin/ru_userinterface`. Рабочее дерево чистое.

## [ЖУРНАЛ] Шаг 82 — найдена причина пустого/английского UI
Симптомы: браузер отдаёт старый/англ. UI; на `:8081` никто не слушает.
Причина: `~/.bashrc:130` экспортирует
  `LD_LIBRARY_PATH=/home/it/llama.cpp/build/bin:$LD_LIBRARY_PATH`
что указывает на **другой** чекаут (`/home/it/llama.cpp/`, HEAD a61f59e53, 16 сен)
и перебивает RUNPATH нашего `build-user/bin/llama-server-user`.
Плюс `start_server_user.sh` (строки 59, 78) сам указывает `$ROOT/build/bin`.
Итог: подгружается чужой `libllama-server-impl.so` с обычным UI (без USER_MODE).

План фикса (отдельным коммитом):
- в start_server_user.sh заменить `$ROOT/build/bin` → `$ROOT/build-user/bin` (строки 59, 78).

## [ЖУРНАЛ] Этап 1 завершён — USER_MODE работает
Коммиты в `ru_userinterface`:
- `1431a0e1a` — скрыта иконка Настройки в USER_MODE (visibleSidebarActions),
  + проброс `message={message}` в ChatMessageActionIcons (Download-кнопка заработала).
- `ed9d2bf00` — `start_server_user.sh`: LD_LIBRARY_PATH на `build-user/bin`
  (был на чужой чекаут `/home/it/llama.cpp/build/bin`).
- Проверено в браузере: Download, скрытие Настроек, отсутствие статистики и т.д.

## [ЖУРНАЛ] Этап 2 завершён — локализация
Коммит `98cf60c64` в `ru_userinterface`:
- `apply.mjs`: `reFn` расширен до `\w{1,3}\(...\)` — ловит `gr("...")` и обёртки Svelte.
- `ru.json`: +2 фразы — `Previous version`, `Next version` (всего 256).
- Переведены: `Show system message in conversations`, `Save settings`,
  `Previous version`, `Next version`.
- Проверено: 181 замена (было 172).

## [ДЛЯ АГЕНТА] ПРОДОЛЖИТЬ С ЭТАПА 3
Цель: распространить правки локализации (коммит `98cf60c64`) на:
- `origin/master` (= `origin/ru-localization`) — основной релиз,
- `origin/ru_autolocale` — через merge `origin/master`.

План:
1. `git fetch origin`
2. `git checkout -b l10n-fixes origin/master`
3. Cherry-pick `98cf60c64` (только `apply.mjs` + `ru.json`).
4. Push в `origin/master` (или `origin/ru-localization`).
5. `git checkout ru_autolocale && git merge origin/master && git push`.
6. В `ru_userinterface`: `git merge origin/master` (на случай конфликтов) + push.

После — Этап 4: финальная проверка и обновление документации.
