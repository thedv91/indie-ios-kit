# indie-ios-kit

A Claude Code [plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces) with one plugin,
`indie-ios`: the skill set and repo template for an indie iOS app portfolio, taken from Shrink Ray
(photo-compress) on 2026-10-14. It runs an app from idea to App Store to marketing, one phase at a time.

## Install

Once per Mac, register the marketplace from GitHub:

```bash
claude plugin marketplace add thedv91/indie-ios-kit
```

Then in each app repo:

```bash
claude plugin install indie-ios@indie-ios-kit --scope local
```

`--scope local` enables the plugin for that repo only (in `.claude/settings.local.json`), so the 42 iOS
skills stay out of non-iOS projects. Inside a session, `/plugin marketplace add thedv91/indie-ios-kit` and
`/plugin install indie-ios@indie-ios-kit` do the same. Skills are namespaced: `/indie-ios:ship-app`,
`/indie-ios:new-app`, `/indie-ios:store-assets`; Claude also finds them by name.

For a new app, create the folder, install the plugin there, start Claude Code and run `/indie-ios:new-app`.
It copies the template, asks for the facts the placeholders need, and hands over to `ship-app`.

To pick up a newer version of the kit:

```bash
claude plugin marketplace update indie-ios-kit
```

## What the plugin holds

| Skill | Source | License |
| --- | --- | --- |
| `ship-app` | this kit: which skill runs at each phase, idea → build → App Store → launch, and which skill owns a request several of them claim | |
| `new-app` | this kit: `template/` with `CLAUDE.md`, `docs/ROADMAP.md`, `docs/localization.md` | |
| `store-assets` | this kit: product-page header and search-result image, new-device screenshots, `scripts/check_asset.py` | |
| `first-impression` | this kit: first-session audit before 1.0 (data safety, empty states, permissions, rating prompt, reminder) and the launch-week plan; writes `docs/LAUNCH-FIRST-IMPRESSION.md` and roadmap items | |
| `user-journey` | this kit: journeys derived from the job and business rules (`docs/JOURNEYS.md`), traced through the code with options for each gap (map) or walked in a simulator under real conditions (walk); writes `docs/JOURNEY-AUDIT.md` and roadmap items | |
| `brainstorming`, `verification-before-completion` | [obra/superpowers](https://github.com/obra/superpowers) | MIT |
| `customer-research`, `pricing`, `product-marketing`, `competitors`, `paywalls`, `aso`, `copywriting`, `launch`, `directory-submissions`, `public-relations`, `marketing-plan`, `marketing-ideas`, `referrals`, `social`, `free-tools`, `ai-seo`, `marketing-psychology`, `community-marketing`, `influencer-marketing` | [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills) | MIT |
| `swiftui-pro` | [twostraws/swiftui-agent-skill](https://github.com/twostraws/swiftui-agent-skill) | MIT |
| `tdd` | [mattpocock/skills](https://github.com/mattpocock/skills) | MIT |
| `jobs-to-be-done` | [wondelai/skills](https://github.com/wondelai/skills) | MIT |
| `intent-driven-development` | [affaan-m/ecc](https://github.com/affaan-m/ecc) | MIT |
| `asc-*` (10 skills) | [rorkai/app-store-connect-cli-skills](https://github.com/rorkai/app-store-connect-cli-skills) | MIT |
| `app-store-preflight-skills` | [truongduy2611/app-store-preflight-skills](https://github.com/truongduy2611/app-store-preflight-skills) | MIT |
| `app-store-review` | [safaiyeh/app-store-review-skill](https://github.com/safaiyeh/app-store-review-skill) | MIT |

The third-party skills are copies, pinned by `skills-lock.json` to an upstream commit. A plugin loads skills
only from files inside it, so they cannot be fetched at install time. Each copy stays under its upstream
license and copyright; [THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md) holds the full text of each.

Phase 2 reviews each change with Claude Code's built-in `/code-review`, so the kit carries no review skill of
its own.

`ship-app` also names skills that are not in the plugin:

- `grilling`, installed with `npx skills add mattpocock/skills -g -s grilling`.
- `illustration-setup` and `vectorcraft-illustration`, the owner's own user-level skills, not published.
- `cro`, `emails`, `seo-audit`, `ad-creative` and `offers`, which the marketing skills point to.

When one of them is missing, `ship-app` tells Claude to say so and ask rather than improvise its steps.

## Update the vendored skills

Run these from a clone of this repo. Each lock entry pins an upstream commit in `ref`. To move every vendored
skill to its upstream HEAD, re-pin the lock to those commits and rewrite the hashes:

```bash
scripts/sync-skills.sh --update
```

Without `--update` it re-fetches the pinned commits, so the copies come back byte for byte. It refuses to run
while any entry lacks a commit SHA in `ref`, because the skills CLI would then fetch the default branch. An
entry added with `npx skills add` has no `ref` until `--update` pins it.

After either, or after editing `ship-app`, `new-app`, `store-assets`, `first-impression` or `user-journey`,
bump `version` in `plugins/indie-ios/.claude-plugin/plugin.json`, commit and push. Installed copies pick the
change up on their next `claude plugin marketplace update indie-ios-kit`.

Keep the kit's own skills and the template free of any one app's name; everything app-specific comes from
that app's `CLAUDE.md`.

## Layout

```
.claude-plugin/marketplace.json              marketplace catalog
plugins/indie-ios/.claude-plugin/plugin.json
plugins/indie-ios/skills/<name>/             the 42 skills (5 from this kit, 37 vendored)
plugins/indie-ios/skills/new-app/template/   files new-app copies into a repo
skills-lock.json                             source, pinned commit and hash of each vendored skill
scripts/sync-skills.sh                       rebuilds the vendored skills from the lock
THIRD_PARTY_LICENSES.md                      license text of each vendored source
```

## Validate

From the repo root:

```bash
claude plugin validate .
claude plugin validate plugins/indie-ios
```

## Portfolio rule

Only process and infrastructure travel through this kit. Never put one app's UI, icon, onboarding, screen
layout, screenshots or store copy here (App Review Guideline 4.3).
