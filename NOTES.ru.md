# Особенности WebUI llama.cpp

## Структура
- WebUI переехал из tools/server/webui/ в tools/ui/ (upstream PR #...)
- Сборка: npm run build → dist/index.html.gz
- Сервер встраивает gz в бинарник при cmake --build

## Svelte-специфика
- Тексты в UI сидят либо в разметке (`<span>Text</span>`),
  либо в атрибутах (`children: "Text"`, `label: "Text"`)
- Динамические строки: `` `${n} messages` `` — через патч в .ts
- Модалки рендерятся в портал — apply.mjs ловит через >Text<

## Плюрализация
Русская: 1 → one, 2-4 → few, 5+ → many, 11-14 → many
Функция:
  n%10===1 && n%100!==11 → one
  n%10 in 2..4 && n%100 not in 12..14 → few
  иначе → many
