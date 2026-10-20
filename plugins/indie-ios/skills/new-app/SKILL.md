---
name: new-app
description: "Set up a new indie iOS app repo from the portfolio template: CLAUDE.md with placeholders, docs/ROADMAP.md and docs/localization.md, then hand over to ship-app. Use when the user starts a new app, says \"new app\", \"set up this repo\" or \"start app #n\", or when ship-app finds no CLAUDE.md with a Positioning section."
---

# New app from the portfolio template

The template is in `template/` next to this file. It holds the files `ship-app` reads the app's facts from.

1. Confirm the current directory is the new app's repo root. Run `git init` if it is not a repo yet.
2. Copy every file under `template/` to the same relative path in the repo, skipping any file that already
   exists. Never overwrite: an existing `CLAUDE.md` or `docs/` file holds this app's decisions. List what was
   created and what was skipped.
3. Ask the owner for the facts the placeholders need, in one message: app name, one-sentence product, target
   keyword, top competitor and its weakness, free tier, v1.0 job, design language, extensions (if any), and
   store languages. Fill `CLAUDE.md` and the language table in `docs/localization.md` from the answers.
   Delete a template section that does not apply instead of leaving it generic. If the owner has no answers
   yet, leave the placeholders and say phase 1 of `ship-app` produces them.
4. Copy `Scripts/check-strings.py` from an earlier portfolio app only when this app has `.lproj` files, and
   adjust its `REFERENCES` list to this app's targets.
5. Run `ship-app`: it finds the current phase (phase 1 for a new repo) and names the next skill.

Rules:

- Guideline 4.3: copy process and infrastructure only. Never copy another app's UI, icon, onboarding, screen
  layout, screenshots or store copy into this repo.
- The skills come from the `indie-ios` plugin. Do not copy skill folders into `.claude/skills/`; a second copy
  shadows the plugin's and drifts from it.
