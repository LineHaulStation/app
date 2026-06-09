# LineHaul Station — app

Static marketing/site assets for LineHaul Station: HTML landing pages,
calculators, lifestyle images, and JSON data (see `pages/`, `code/`, `JSONS/`,
`docs/`, root `*.html` and `*.png`).

## Who you are working with

- **JJ Swenson** — Membership Director at LineHaul Station.
- Father **Jeff Swenson** is Founder & CEO.
- JJ is a coding beginner with high ambition to become expert across
  claude.ai, Cowork, and Claude Code, to scale LineHaul Station
  efficiently.
- Email: `js@linehaulstation.com`.
- Active marketing project on claude.ai: **Marketing / Ad & Video Content**.

## Standing directives — these are NOT optional

1. **Never skip a directive JJ gives you.** "Reference these files" means
   **READ them in full**, not list them. "Reference" is not a synonym
   for "list" or "search."
2. **Do not assume.** Never invent facts you don't have (e.g. a name).
   If something is ambiguous, use `AskUserQuestion`. If you don't know,
   say so.
3. **At the start of every session, BEFORE doing anything else, read
   the memory files in this order:**
   1. This file (`CLAUDE.md`).
   2. The Master Claude Memory in Dropbox at
      `/LineHaul Station Team Folder/PROJECTS/Claude Projects/MASTER MEMORY/Master Claude Memory (Don't Delete!).md`
      (and any newer files added to that `MASTER MEMORY/` folder).
4. **Never push to `main` without explicit OK.** Work on the `claude/*`
   branch you're on. Open a PR when checkpointing.
5. **When something can't be done in this environment, say so out loud.**
   Don't paper over failures. If you previously told JJ something would
   work and it didn't, name it.
6. **Tell JJ what you're about to do BEFORE doing anything destructive**
   (delete, reset, force-push, drop, overwrite).
7. **Plain English. No jargon without defining it the first time.**
8. **Deliver documents as PDF — ALWAYS.** JJ cannot comfortably read
   raw text/markdown files; the structure is confusing to him. Any
   document, report, question set, copy deck, plan, or memo produced
   for JJ must be generated and delivered as a **PDF** (use reportlab
   in-session: `libreoffice --headless` conversion is broken in the web
   sandbox). A text/markdown copy may ALSO be saved to Dropbox for the
   record, but PDF is the deliverable. Default to PDF without being asked.

## Saving work — protected by hook

Web sessions run in **ephemeral containers**. The hook at
`.claude/hooks/auto-save.sh`, wired in `.claude/settings.json`, commits
and pushes after every turn (`Stop`) and at `SessionEnd`:

1. `git add -A` (honoring `.gitignore`)
2. `git commit` with a timestamped auto-save message
3. `git push -u origin <branch>` with retries on transient failure

Guardrails:
- Never auto-pushes `main`/`master`.
- `.gitignore` keeps secrets (`.env`, keys, credential files) out.

Even with the hook, prefer **deliberate, descriptive commits** at
meaningful checkpoints. The hook is a safety net, not a substitute for
good commit hygiene.

## Why this protection exists

- **2026-05-21 (Fri):** A web session lost all work. The container was
  reclaimed before anything pushed.
- **2026-05-22 (Sat):** Root cause found — the **Claude GitHub App** was
  installed read-only on `linehaulstation/app`, so `git push` returned
  403 from inside every web session. JJ granted `Contents: Read and
  write`. The auto-save hook was built and merged to `main` via PR #1.

If push starts failing again with 403, **check the GitHub App
permission first** at https://github.com/settings/installations.

## Repo & branch convention

- Default branch: `main`.
- Do all session work on a `claude/*` branch.
- PR back into `main` for permanent changes.
