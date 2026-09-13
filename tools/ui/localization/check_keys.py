#!/usr/bin/env python3
import json
import re
import sys

bundle_path = sys.argv[1] if len(sys.argv) > 1 else None

with open("localization/ru.json", encoding="utf-8") as f:
    ru = json.load(f)

with open(bundle_path, encoding="utf-8", errors="replace") as f:
    bundle = f.read()

found = []
template = []
not_found = []

for en in ru:
    # Прямой литерал
    if re.search(r'"' + re.escape(en) + r'"', bundle):
        found.append(en)
        continue
    # Шаблон с ${...}
    if re.search(r'`[^`]*\$\{[^}]*\}[^`]*' + re.escape(en), bundle):
        template.append(en)
        continue
    not_found.append(en)

print(f"Найдено в бандле: {len(found)}")
print(f"Шаблоны (не заменятся через ru.json): {len(template)}")
print(f"Уже переведено / не найдено: {len(not_found)}")
print()

if template:
    print("=== ШАБЛОНЫ (нужен патч src/) ===")
    for k in template:
        print(f"  {k!r}")
    print()
