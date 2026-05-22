#!/usr/bin/env bash
# Auto-save hook for Claude Code web sessions.
#
# Web sessions run in ephemeral containers — uncommitted/unpushed work is lost
# when the container is reclaimed. This hook commits and pushes after every
# turn (Stop) and at session end (SessionEnd) so work always survives.
#
# Safety guards:
#   - Recursion guard via stop_hook_active
#   - Never auto-pushes main/master (commits locally + warns)
#   - .gitignore keeps secrets out of `git add -A`
#   - Network retries with exponential backoff
set -uo pipefail

input=$(cat 2>/dev/null || true)

if [[ "$(printf '%s' "$input" | jq -r '.stop_hook_active // false' 2>/dev/null)" == "true" ]]; then
  exit 0
fi

git rev-parse --git-dir >/dev/null 2>&1 || exit 0
[[ -n "$(git remote)" ]] || exit 0

branch=$(git branch --show-current 2>/dev/null)
[[ -n "$branch" ]] || exit 0

if ! git diff --quiet 2>/dev/null \
   || ! git diff --cached --quiet 2>/dev/null \
   || [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
  git add -A
  git commit -m "Auto-save session work ($(date '+%Y-%m-%d %H:%M:%S'))" >/dev/null 2>&1 || true
fi

need_push=0
if git rev-parse --verify "origin/$branch" >/dev/null 2>&1; then
  [[ "$(git rev-list --count "origin/$branch..HEAD" 2>/dev/null || echo 0)" -gt 0 ]] && need_push=1
else
  [[ -n "$(git rev-list -n1 HEAD 2>/dev/null)" ]] && need_push=1
fi
[[ "$need_push" -eq 0 ]] && exit 0

if [[ "$branch" == "main" || "$branch" == "master" ]]; then
  printf '%s\n' "{\"systemMessage\": \"Auto-save committed work locally on '$branch' but will NOT auto-push a shared branch. Push manually if intended.\"}"
  exit 0
fi

for delay in 0 2 4 8; do
  [[ "$delay" -gt 0 ]] && sleep "$delay"
  if git push -u origin "$branch" >/dev/null 2>&1; then
    printf '%s\n' "{\"systemMessage\": \"Session work auto-saved -> origin/$branch\", \"suppressOutput\": true}"
    exit 0
  fi
done

printf '%s\n' "{\"systemMessage\": \"WARNING: auto-save could not push to origin/$branch (network?). Work is committed locally; run: git push -u origin $branch\"}"
exit 0
