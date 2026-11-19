# Antigravity Multi-Agent Orchestration Kit

Готовый шаблон и руководство по настройке **трёхуровневой оркестрации (Hub-and-Spoke)** для **Google Antigravity** (локально на Windows/macOS и на удалённом Linux-сервере по SSH).

---

## 1. Архитектура (3 уровня)

```text
Уровень 1 · Глобальный плагин (always_on во всех проектах)
~/.gemini/config/plugins/security-baseline/
├── plugin.json
└── rules/AGENTS.md          # Секреты, Docker, SQL, сеть, автообновление STATE.md

        │ (автонаследование)
        ▼

Уровень 2 · Центр управления (_control-plane / Hub)
projects/_control-plane/
├── GEMINI.md                # Роль оркестратора (не писать прикладной код, работать через manifests/)
├── PORTFOLIO.md             # Карта всех проектов, стеков, рисков и моделей
├── manifests/               # HardLink (Windows) / Symlink (Linux) на GEMINI.md и STATE.md проектов
├── generated-prompts/       # Самодостаточные ТЗ/промпты для изолированных чатов
└── .agents/skills/
    ├── security-sync/SKILL.md   # Команда /security-sync — аудит портфеля
    └── init-project/SKILL.md    # Команда /init-project — подключение нового проекта

        │ (промпты и ссылки)
        ▼

Уровень 3 · Изолированные проекты (Spokes)
projects/<project-name>/
├── GEMINI.md                # Компактный паспорт проекта (подгружается автоматически, до 1–3 КБ)
└── STATE.md                 # Текущий статус и открытые риски (читается по требованию)
```

### Зачем так устроено
1. **Чистый контекст и экономия токенов:** чат внутри `Films` видит только `security-baseline` и `Films/GEMINI.md`, не засоряя контекст кодом других проектов.
2. **Оркестратор без сканирования всего кода:** `_control-plane` читает только `PORTFOLIO.md` и `manifests/*`, быстро находит системные риски (например, `:latest` в Docker или отсутствие `USER`) и выдаёт готовые промпты.
3. **Актуальное состояние:** глобальное правило в `AGENTS.md` обязывает агента автоматически обновлять `STATE.md` после значимых изменений — и через ссылки в `manifests/` оркестратор сразу это видит.

---

## 2. Быстрый старт (применение на новой машине или сервере)

### Windows (PowerShell)
```powershell
git clone <URL_этого_репозитория> antigravity-orchestration
cd antigravity-orchestration
.\scripts\install.ps1
```

### Linux / macOS / Удалённый сервер
```bash
git clone <URL_этого_репозитория> antigravity-orchestration
cd antigravity-orchestration
chmod +x scripts/install.sh
./scripts/install.sh
```

Скрипт:
1. Устанавливает глобальный плагин `security-baseline` в `~/.gemini/config/plugins/security-baseline/`.
2. Настраивает глобальный `.gitignore` (`core.excludesfile`), чтобы `GEMINI.md` и `STATE.md` **не попадали в коммиты** чужих или публичных репозиториев (опционально отключается флагом).
3. Создаёт `~/projects/_control-plane` из шаблона (если его ещё нет).

---

## 3. Как использовать в работе

### А. Добавить существующий или новый проект
1. Создай/открой проект и привяжи его в левой панели Antigravity (**Projects**).
2. Открой чат в `_control-plane` и вызови:
   ```text
   /init-project <имя-проекта> <путь-к-папке>
   ```
   Либо скопируй `templates/project/GEMINI.md` и `STATE.md` в корень проекта, адаптируй под стек и создай ссылки в `_control-plane/manifests/`:
   - **Linux/macOS:**
     ```bash
     ln -sf ~/projects/<proj>/GEMINI.md ~/projects/_control-plane/manifests/<proj>-GEMINI.md
     ln -sf ~/projects/<proj>/STATE.md  ~/projects/_control-plane/manifests/<proj>-STATE.md
     ```
   - **Windows (без прав администратора — HardLink на одном диске):**
     ```powershell
     New-Item -ItemType HardLink -Path "$HOME\projects\_control-plane\manifests\<proj>-GEMINI.md" -Target "$HOME\projects\<proj>\GEMINI.md"
     New-Item -ItemType HardLink -Path "$HOME\projects\_control-plane\manifests\<proj>-STATE.md"  -Target "$HOME\projects\<proj>\STATE.md"
     ```

### Б. Выбор моделей под задачу
| Задача | Рекомендуемая модель | Почему |
| :--- | :--- | :--- |
| Оркестрация в `_control-plane`, `/security-sync`, сложный аудит | Сильная рассуждающая (**Opus / Pro / Orchestrator**) | Контекст маленький (`PORTFOLIO.md` + `manifests/`), важна глубина анализа |
| Фикс бага или фича в одном проекте | Сбалансированная кодерская (**Sonnet / Argon**) | Оптимальный баланс качества кода и расхода квот |
| Мелкие правки UI, доки, выполнение готового чёткого промпта | Быстрая (**Flash / Hydrogen**) | Максимальная скорость и экономия квот |
| Сложный/неясный баг в одном проекте | **Orchestrator** или `/plan` | Сначала планирование сильной моделью, затем исполнение |

### В. Аудит всего портфеля
Открой чат в `_control-plane` и напиши:
```text
/security-sync
```
Оркестратор сверит `PORTFOLIO.md` и `manifests/*` с `security-baseline` и создаст готовые промпты в `generated-prompts/<project>-security.md`. Затем открывай каждый проект в отдельном чате и передавай ему соответствующий промпт.

---

## 4. Защита от случайного коммита `GEMINI.md` и `STATE.md`

Чтобы локальные файлы оркестрации не улетали на GitHub вместе с кодом проекта:
- Используй глобальный `~/.gitignore_global` (настраивается скриптами `install.ps1` / `install.sh`), **или**
- Добавь `GEMINI.md` и `STATE.md` в `.git/info/exclude` конкретного репозитория (локально, не затрагивая общий `.gitignore`).
