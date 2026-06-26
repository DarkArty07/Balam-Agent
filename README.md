# Balam — Jaguar Agent

> *Silent. Precise. Delegates with purpose.*

Balam is a multi-agent coding assistant built on **hermes-agent v0.17.0**. Named after the Maya jaguar deity, Balam embodies the jungle's apex predator: it watches, decides, and dispatches.

## How It Works

Balam does **not** touch files or run commands directly. It is a pure delegator:

1. **You speak naturally** — Balam detects intent and workflow
2. **Balam plans** — uses tools you gave it: web_search, skills, memory, session_search, todo, vision
3. **Balam delegates** — spawns subagents for file/system work
4. **You get results** — concise, actionable, no noise

## Subagent Types

| Subagent | Tools | Purpose |
|----------|-------|---------|
| **Explorer** | web, search, read | Investigate APIs, docs, codebases |
| **Builder** | terminal, file, patch | Implement, test, deploy |

## Tech Stack

| Component | Choice |
|-----------|--------|
| Framework | hermes-agent v0.17.0 |
| Main model | deepseek-v4-pro (OpenCode Go) |
| Subagent model | deepseek-v4-flash (OpenCode Go) |
| Graph DB | Graphify MCP |
| Provider protocol | chat_completions |

## Installation

```bash
git clone https://github.com/DarkArty07/Balam-Agent.git
cd Balam-Agent
chmod +x scripts/setup.sh
./scripts/setup.sh
# Edit .env → add your API keys
hermes start --profile balam
```

## Architecture

```
┌──────────────────────────────┐
│           YOU                │
│  (natural language intent)   │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│        BALAM (Jaguar)        │
│  ┌────────────────────────┐  │
│  │ delegate_task          │  │
│  │ web_search             │  │
│  │ skills / memory        │  │
│  │ session_search / todo  │  │
│  │ vision                 │  │
│  └─────────┬──────────────┘  │
└────────────┼─────────────────┘
             │ delegations
      ┌──────┴──────┐
      ▼              ▼
┌──────────┐  ┌──────────┐
│ Explorer │  │  Builder │
│ (read)   │  │ (write)  │
│ web/read │  │ file/term│
│ search   │  │ patch    │
└──────────┘  └──────────┘
```

## Philosophy

- **Vibecoding** — speak naturally, Balam understands
- **Silent precision** — the jaguar does not chatter
- **Proactive learning** — Balam remembers your workflow patterns
- **Language-aware** — responds in your language

---

*Built with ☕ and Maya spirit.*
