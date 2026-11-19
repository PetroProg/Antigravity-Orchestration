# Antigravity Multi-Agent Orchestration Kit

A ready-to-use template and guide for setting up **three-tier Hub-and-Spoke orchestration** for **Google Antigravity** (locally on Windows/macOS and on remote Linux servers over SSH).

---

## 1. Architecture (3 Tiers)

```text
Tier 1 · Global Plugin (always_on across all projects)
~/.gemini/config/plugins/security-baseline/
├── plugin.json
└── rules/AGENTS.md          # Secrets, Docker, SQL, networking, auto-updating STATE.md

        │ (auto-inherited)
        ▼

Tier 2 · Control Plane (_control-plane / Hub)
projects/_control-plane/
├── GEMINI.md                # Orchestrator role (no app code, works via manifests/)
├── PORTFOLIO.md             # Map of all projects, stacks, risks, and models
├── manifests/               # HardLinks (Windows) / Symlinks (Linux) to project GEMINI.md & STATE.md
├── generated-prompts/       # Self-contained prompts/specs for isolated worker chats
└── .agents/skills/
    ├── security-sync/SKILL.md   # /security-sync — portfolio-wide security audit
    └── init-project/SKILL.md    # /init-project — onboard a new project

        │ (prompts & links)
        ▼

Tier 3 · Isolated Projects (Spokes)
projects/<project-name>/
├── GEMINI.md                # Compact project passport (auto-loaded, 1–3 KB)
└── STATE.md                 # Current status and open risks (read on demand)
```

### Why This Structure Works
1. **Clean Context & Token Savings:** A chat inside `Films` only sees `security-baseline` and `Films/GEMINI.md`, without polluting its context with code from other projects.
2. **Orchestrator Without Full-Codebase Scans:** `_control-plane` reads only `PORTFOLIO.md` and `manifests/*`, quickly spots systemic risks (e.g., `:latest` Docker tags or missing non-root `USER`), and generates focused prompts.
3. **Always Up-to-Date State:** The global rule in `AGENTS.md` instructs agents to automatically update `STATE.md` after significant changes — and `_control-plane` sees updates immediately via `manifests/`.

---

## 2. Quick Start (New Machine or Server)

### Windows (PowerShell)
```powershell
git clone <this-repo-url> antigravity-orchestration
cd antigravity-orchestration
.\scripts\install.ps1
```

### Linux / macOS / Remote Server
```bash
git clone <this-repo-url> antigravity-orchestration
cd antigravity-orchestration
chmod +x scripts/install.sh
./scripts/install.sh
```

What the installer does:
1. Installs the global `security-baseline` plugin into `~/.gemini/config/plugins/security-baseline/`.
2. Configures a global `.gitignore` (`core.excludesfile`) so `GEMINI.md` and `STATE.md` are **never accidentally committed** to public or project repositories (can be skipped on Windows with `-SkipGlobalGitIgnore`).
3. Initializes `~/projects/_control-plane` from the template if it does not exist yet.

---

## 3. Daily Workflow

### A. Onboard a New or Existing Project
1. Create or open the project folder and add it in the Antigravity **Projects** sidebar.
2. Open a chat in `_control-plane` and run:
   ```text
   /init-project <project-name> <path-to-folder>
   ```
   Or manually copy `templates/project/GEMINI.md` and `STATE.md` into the project root, adapt them to the stack, and link them into `_control-plane/manifests/`:
   - **Linux/macOS:**
     ```bash
     ln -sf ~/projects/<proj>/GEMINI.md ~/projects/_control-plane/manifests/<proj>-GEMINI.md
     ln -sf ~/projects/<proj>/STATE.md  ~/projects/_control-plane/manifests/<proj>-STATE.md
     ```
   - **Windows (no admin rights required — HardLink on the same drive):**
     ```powershell
     New-Item -ItemType HardLink -Path "$HOME\projects\_control-plane\manifests\<proj>-GEMINI.md" -Target "$HOME\projects\<proj>\GEMINI.md"
     New-Item -ItemType HardLink -Path "$HOME\projects\_control-plane\manifests\<proj>-STATE.md"  -Target "$HOME\projects\<proj>\STATE.md"
     ```

### B. Choosing the Right Model
| Task | Recommended Model | Why |
| :--- | :--- | :--- |
| `_control-plane` orchestration, `/security-sync`, deep audits | Strong reasoning (**Opus / Pro / Orchestrator**) | Small context (`PORTFOLIO.md` + `manifests/`), high-leverage planning |
| Bug fix or feature inside a single project | Balanced coding (**Sonnet / Argon**) | Best balance of code quality, speed, and quota usage |
| Minor UI tweaks, docs, executing a clear generated prompt | Fast (**Flash / Hydrogen**) | Maximum speed and minimal quota cost |
| Complex or unclear multi-file bug | **Orchestrator** or `/plan` | Strong model plans first, lighter steps execute efficiently |

### C. Portfolio-Wide Security Audit
Open a chat in `_control-plane` and run:
```text
/security-sync
```
The orchestrator compares `PORTFOLIO.md` and `manifests/*` against `security-baseline` and writes self-contained prompts to `generated-prompts/<project>-security.md`. Then open each target project in its own clean chat and pass it the generated prompt.

---

## 4. Preventing Accidental Commits of `GEMINI.md` & `STATE.md`

To keep local orchestration files out of GitHub repositories:
- Use a global `~/.gitignore_global` (configured automatically by `install.ps1` / `install.sh`), **or**
- Add `GEMINI.md` and `STATE.md` to a repository's local `.git/info/exclude` without modifying the shared `.gitignore`.
