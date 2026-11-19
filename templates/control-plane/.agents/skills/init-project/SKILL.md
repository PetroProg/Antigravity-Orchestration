---
name: init-project
description: >-
  Подключает новый или существующий проект к оркестрации _control-plane: создаёт GEMINI.md и STATE.md, настраивает Git-исключения, добавляет ссылки в manifests/ и строку в PORTFOLIO.md. Используй по команде /init-project.
---

# Skill: /init-project

Когда пользователь просит подключить проект `<project>` (и опционально указывает путь):

1. Определи путь к проекту и бегло изучи его стек (по `README.md`, `Dockerfile`, `compose.yaml`, `package.json`, `go.mod`, `requirements.txt` — без глубокого чтения исходников).
2. Создай в корне проекта:
   - `GEMINI.md` (стек, критичные зоны безопасности, команды проверки, рекомендуемые модели, раздел `Git и GitHub` с проверкой `.git` и `git status`/`git diff` перед коммитом и пушем).
   - `STATE.md` (текущая дата, статус, 2–4 открытых задачи/риска).
3. Если в проекте есть `.git`, убедись, что `GEMINI.md` и `STATE.md` не попадают в коммиты (добавь в `.git/info/exclude`, если нет глобального `core.excludesfile`).
4. Создай ссылки в `manifests/<project>-GEMINI.md` и `manifests/<project>-STATE.md` (SymbolicLink/HardLink на Windows, `ln -sf` на Linux/macOS).
5. Добавь строку проекта в `PORTFOLIO.md`.
6. Кратко отчитайся о созданных файлах и следующем шаге (добавить проект в UI Antigravity).
