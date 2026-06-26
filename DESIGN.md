# Balam-Agent

> **Multi-agent coding assistant** built on hermes-agent. Named after *Balam* — jaguar in Maya — silent strength that executes with precision. Open-source under MIT license.

Balam is a single-process multi-agent system where one powerful super agent delegates to lightweight subagents via hermes-agent's native `delegate_task`. No subprocess orchestration. No ACP. No coordination databases. One Python process, thread‑pooled subagents, zero overhead.

---

## 1. Vision

Three pillars guide every design decision:

| Pillar | Goal |
|--------|------|
| **Optimize Costs** | One process, cheap subagent model (`deepseek-v4-flash`), token-efficient system prompts. No redundant infrastructure. |
| **Maximize Quality** | Specialized subagents with restricted toolsets — each agent does one thing well. Clean separation of read-only research from write‑capable implementation. |
| **Maximize Speed** | In-process delegation via `ThreadPoolExecutor` (milliseconds, not seconds). No subprocess startup, no IPC, no network round-trips between agents. |

Balam is **a super agent aided by agents** — not a "collaborative team" with bidirectional communication and shared state. It is a single powerful agent that delegates when it needs extra hands. The agent learns from the user: it detects workflow patterns (e.g., *idea → research → plan → implement*) and adapts its delegation strategy accordingly.

The entire system is built on hermes-agent's native `delegate_task`. No custom orchestration engine. No subprocesses. No ACP. No SQLite coordination databases.

---

## 2. Architecture

### Core Principle: One Process, Delegate Task

```
Balam (main agent, glm-5.2 via llmgateway)
  ├── delegate_task → Subagent (deepseek-v4-flash, specialized toolsets)
  ├── delegate_task → Subagent (deepseek-v4-flash, specialized toolsets)
  └── Memory tools (persistent across sessions)
```

- **Balam** runs as a single hermes-agent instance using `glm-5.2` for strong reasoning and orchestration.
- **Subagents** are `AIAgent` objects created via `delegate_task` — same process, `ThreadPoolExecutor` underneath.
- Each subagent receives: fresh context, a restricted toolset, an ephemeral system prompt, and depth = 1 (no recursion).
- **Zero** subprocess overhead. **Zero** IPC. **Zero** coordination databases.

### Subagent Types (v1)

Two specialized subagent types, named with the Maya theme:

| Type | Maya Name | Model | Toolsets | Purpose |
|------|-----------|-------|----------|---------|
| **Explorer** | *TBD* | `deepseek-v4-flash` | `["web", "file-read", "search_files"]` | Read-only: investigate codebase, research, find information |
| **Builder** | *TBD* | `deepseek-v4-flash` | `["terminal", "file", "patch", "search_files"]` | Full access: implement code, run commands, make changes |

**Key constraints on subagents:**
- Explorer cannot write files, execute arbitrary commands, or install packages — it observes and reports.
- Builder has full `terminal` and file-write access but is given a narrowly scoped goal and returns when done.
- Both are **depth-1** (leaf agents) — they cannot spawn their own subagents.
- Both use `deepseek-v4-flash`: fast inference, good code quality, low cost.

### Why Not More Agent Types?

| Considered | Decision | Rationale |
|-----------|----------|-----------|
| Audit / Review | **Postponed** | Adds architectural overhead without clear v1 value; Balam itself can review subagent output. |
| Consult | **Postponed** | The user can ask Balam directly — a dedicated consultant agent duplicates the main loop. |

**Critical rule:** Each subagent type = one `delegate_task` call. No nesting. No middlemen. Balam learns the user's preferred workflow and adapts its delegation strategy over time.

---

## 3. Identity

### Maya Theme

The project identity is rooted in Maya culture, not as decoration but as a coherent design language:

- **Balam** = Jaguar — the principal agent. Silent, powerful, precise. It does not chatter; it executes.
- **Subagent names** — TBD. Maya-themed names to be defined before v0.1.0 launch.
- **Vibecoding** — the system prompt (`SOUL.md`) must make interaction feel natural, not robotic. The user speaks naturally; Balam understands intent.
- **Token efficiency** — the SOUL must be concise. A key lesson from Requiem (Raven's SOUL was heavily optimized to use very few tokens) carries directly into Balam.

### SOUL.md Design Principles

1. **Concise** — every word earns its place. Learned from Requiem's Raven SOUL.
2. **Vibecoding-first** — the user speaks naturally; Balam understands intent and acts.
3. **Learns from user** — detects workflow patterns (research-first, test-first, direct implement) and adapts.
4. **Proactive memory** — saves learnings, preferences, and corrections as skills and memory facts without being asked.
5. **Maya personality** — grounded in the identity, not gimmicky. The jaguar is silent until it acts, then precise.

---

## 4. Memory & Continuity

### v1: Session Memory + User Preferences

- **Persistent memory** across sessions: hermes-agent native `MEMORY.md` and `USER.md`.
- Balam learns the user's workflow style — whether they prefer *idea → research → plan → implement*, test-first, or direct implementation — and adapts its delegation strategy.
- User preferences are saved as **memory facts** AND **embedded in skills** so they survive across sessions and guide subagent prompts.
- **Delegation metadata** is tracked: what was delegated, to which subagent type, and the result.

### v2: .aether Project Continuity

- `.aether` is planned for v2 — a *capture → curate → inject* cycle.
- Same concept as Aether Agents: tell Balam what project you're on and it remembers exactly what was done in previous sessions, what state the project is in, and what decisions were made.
- `.aether` was described as *"one of the best things I could think of"* — it enters the roadmap after v1 is stable and proven.

---

## 5. Technology Stack

| Component | Technology | Why |
|-----------|-----------|-----|
| Framework | hermes-agent | `delegate_task`, tools, skills, gateway — all native, no reinvention |
| Main Model | `glm-5.2` | Strong reasoning for orchestration and complex decisions |
| Subagent Model | `deepseek-v4-flash` | Fast inference, good code quality, low cost per token |
| Provider | llmgateway | Same as Requiem — proven, reliable, already configured |
| Memory | hermes-agent native | `MEMORY.md`, `USER.md`, `session_search` — no external DB |
| Skills | `SKILL.md` format | Standard hermes-agent skill format — reusable workflows |
| Distribution | `git clone` + `setup.sh` | Hidden personal profile (`~/.hermes/profiles/balam/`) and API keys |
| License | MIT | Open source from day one |

---

## 6. Installation

```bash
git clone https://github.com/DarkArty07/Balam-Agent.git
cd Balam-Agent
bash scripts/setup.sh
```

**What setup.sh does:**
1. Creates a Python virtual environment in the project directory.
2. Installs hermes-agent and its dependencies.
3. Generates `config.yaml` from a template (user-editable).
4. Copies the personal SOUL.md and profile config to `~/.hermes/profiles/balam/`.

**Post-install:**
- The user edits `.env` with their API keys (never committed — `.env` is in `.gitignore`).
- The personal profile directory (`~/.hermes/profiles/balam/`) is also gitignored.
- No pip package is published — `git clone` is the sole distribution method.

---

## 7. What Balam Does NOT Have (vs Aether / Requiem)

| Removed | Why |
|---------|-----|
| Olympus v3 MCP server | No subprocess orchestration needed — `delegate_task` is in-process |
| ACP protocol | `delegate_task` uses `ThreadPoolExecutor` — no separate protocol |
| 6 separate hermes processes | One process; subagents are threads, not processes |
| 5-phase pipeline | User workflow is detected, not imposed — Balam adapts |
| Consult workflow | Adds overhead without clear v1 value; user can ask Balam directly |
| PID files / SQLite coordination | No multi-process state to coordinate |
| Necromancer / Shade / Revenant hierarchy | Flat: Balam → subagent (one hop, no nesting) |

---

## 8. Differentiators

1. **Cost** — One process, a cheap subagent model (`deepseek-v4-flash`), and a token-efficient SOUL. No redundant infrastructure spend.
2. **Speed** — In-process delegation completes in milliseconds, not seconds. No subprocess startup latency. No IPC serialization overhead.
3. **Quality** — Specialized subagents with narrow toolsets produce focused, high-quality output. Emerging tools like *Graphify* (code graph analysis) can be plugged in without changing the architecture.
4. **Identity** — Maya theme from day one, not bolted on. The jaguar identity guides naming, system prompt tone, and user interaction patterns consistently.
5. **Learning** — Balam detects the user's workflow patterns and adapts its delegation strategy. It does not force a pipeline; it conforms to how the user naturally works.
6. **Vibecoding** — Natural, proactive, autonomous interaction. The user speaks naturally; Balam understands intent, plans, delegates, and reports back in a tight loop.

---

## 9. Roadmap

### v0.1.0 — MVP

- **SOUL.md** with Maya identity (token-efficient, vibecoding-first).
- **config.yaml** configured with `glm-5.2` main model, `deepseek-v4-flash` subagent model, and delegation config.
- **2 subagent types**: Explorer (read-only) + Builder (full access).
- **Memory + user preference learning**: Balam saves what it learns about the user's workflow.
- **setup.sh** install script (venv, hermes-agent, profile setup).
- **README.md** with project overview, installation steps, and quickstart.

### v0.2.0 — .aether Continuity

- `.aether` capture hooks — Balam writes project state to `.aether/` at key points.
- Project context injection — Balam reads `.aether/` state when resuming a project.
- Session continuity — Balam can answer *"what were we doing?"* without the user repeating context.

### v0.3.0 — Telemetry & Dashboard

- Delegation metrics — what was delegated, to whom, success rate.
- Token / cost tracking — per-session and per-delegation cost breakdown.
- UI for monitoring — a simple dashboard (CLI or web) to review delegation history and costs.

### Future

- **Graphify integration** — code graph analysis as a subagent tool for deeper codebase understanding.
- **Custom tools** — Maya-themed tool names and personalities for the subagents.
- **Web interface** — a lightweight web UI for interacting with Balam outside the terminal.

---

*Balam moves in silence. When it strikes, it is precise.*
