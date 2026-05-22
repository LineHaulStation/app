# LineHaul Station — app

Static marketing/site assets for LineHaul Station: HTML landing pages,
calculators, lifestyle images, and JSON data (see `pages/`, `code/`, `JSONS/`,
`docs/`, root `*.html` and `*.png`).

## Saving work — read this first

Claude Code web sessions run in **ephemeral containers**. Anything not
committed **and pushed** is permanently lost when the container is reclaimed.

There is an auto-save hook at `.claude/hooks/auto-save.sh`, wired up in
`.claude/settings.json`. It runs on `Stop` (after every turn) and `SessionEnd`,
and it will:

1. `git add -A` (honoring `.gitignore`)
2. `git commit` with a timestamped auto-save message
3. `git push -u origin <branch>` with retries on transient network failures

Guardrails:
- Never auto-pushes `main` or `master` — those require a manual push.
- `.gitignore` keeps secrets (`.env`, keys, credential files) out of auto-commits.

Even with the hook, prefer to make **deliberate, descriptive commits** at
meaningful checkpoints. The hook is a safety net, not a substitute for good
commit hygiene.

## Branch convention

Do all session work on a `claude/*` branch (e.g. `claude/brave-heisenberg-Wn9my`).
The auto-save hook only auto-pushes non-shared branches, so `claude/*` branches
are the safe surface for in-session work.
