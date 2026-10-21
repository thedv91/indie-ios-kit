# indie-ios-kit

A local Claude Code [plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces) with one
plugin, `indie-ios`: the skill set and repo template for the indie iOS app portfolio, taken from Shrink Ray
(photo-compress) on 2026-10-14.

## Install

Once per Mac, register the marketplace:

```bash
claude plugin marketplace add ~/data/startups/indie-ios-kit
```

Then in each app repo:

```bash
claude plugin install indie-ios@indie-ios-kit --scope local
```

`--scope local` enables the plugin for that repo only (in `.claude/settings.local.json`), so the 44 iOS
skills stay out of non-iOS projects. Inside a session, `/plugin install indie-ios@indie-ios-kit` does the
same. Skills are namespaced: `/indie-ios:ship-app`, `/indie-ios:new-app`, `/indie-ios:store-assets`; Claude also finds them by name.

For a new app, create the folder, install the plugin there, start Claude Code and run `/indie-ios:new-app`.
It copies the template, asks for the facts the placeholders need, and hands over to `ship-app`.

## What the plugin holds

| Skill | Source |
| --- | --- |
| `ship-app` | this kit: which skill runs at each phase, idea → build → App Store → launch |
| `new-app` | this kit: `template/` with `CLAUDE.md`, `docs/ROADMAP.md`, `docs/localization.md` |
| `store-assets` | this kit: product-page header and search-result image, new-device screenshots, `scripts/check_asset.py` |
| `first-impression` | this kit: first-session audit before 1.0 (data safety, empty states, permissions, rating prompt, reminder) and the launch-week plan; writes `docs/LAUNCH-FIRST-IMPRESSION.md` and roadmap items |
| `user-journey` | this kit: journeys derived from the job and business rules (`docs/JOURNEYS.md`), traced through the code with options for each gap (map) or walked in a simulator under real conditions (walk); writes `docs/JOURNEY-AUDIT.md` and roadmap items |
| `brainstorming`, `verification-before-completion` | obra/superpowers |
| `customer-research`, `pricing`, `product-marketing`, `competitors`, `paywalls`, `aso`, `copywriting`, `launch`, `directory-submissions`, `public-relations`, `marketing-plan`, `marketing-ideas`, `referrals`, `social`, `free-tools`, `ai-seo`, `marketing-psychology`, `community-marketing`, `influencer-marketing` | coreyhaines31/marketingskills |
| `swiftui-pro` | twostraws/swiftui-agent-skill |
| `apple-design` | dickwu/apple-design-skill |
| `tdd`, `code-review` | mattpocock/skills |
| `jobs-to-be-done` | wondelai/skills |
| `intent-driven-development` | affaan-m/ecc |
| `asc-*` (9 skills) | rorkai/app-store-connect-cli-skills |
| `app-store-preflight-skills` | truongduy2611/app-store-preflight-skills |
| `app-store-review` | safaiyeh/app-store-review-skill |

The third-party skills are copies, pinned by `skills-lock.json`. A plugin loads skills only from files
inside it, so they cannot be fetched at install time. Keep this repo private: the copies carry their
upstream licenses, and redistributing them publicly needs a license check first.

`ship-app` also uses three user-level skills that are not in the plugin: `grilling`
(`npx skills add mattpocock/skills -g -s grilling`), and the owner's own `illustration-setup` and
`vectorcraft-illustration` in `~/.claude/skills`. It mentions `cro` and `emails` too; neither is
installed, and it tells Claude to ask before improvising them.

## Update

Each lock entry pins an upstream commit in `ref`. Move every vendored skill to its upstream HEAD, re-pin
the lock to those commits and rewrite the hashes:

```bash
~/data/startups/indie-ios-kit/scripts/sync-skills.sh --update
```

Without `--update` it re-fetches the pinned commits, so the copies come back byte for byte; it refuses to
run while any entry lacks a commit SHA in `ref`, because the skills CLI would then fetch the default branch.
An entry added with `npx skills add` has no `ref` until `--update` pins it. After either, or after editing `ship-app`,
`new-app`, `store-assets`, `first-impression` or `user-journey`, bump `version` in `plugins/indie-ios/.claude-plugin/plugin.json`, commit, and refresh the
installed copy:

```bash
claude plugin marketplace update indie-ios-kit
```

Keep the kit's own skills (`ship-app`, `new-app`, `store-assets`, `first-impression`, `user-journey`) and the template free of any
one app's name; everything app-specific comes from that app's `CLAUDE.md`.

## Layout

```
.claude-plugin/marketplace.json          marketplace catalog
plugins/indie-ios/.claude-plugin/plugin.json
plugins/indie-ios/skills/<name>/         the 44 skills (ship-app, new-app, store-assets, first-impression, user-journey + 39 vendored)
plugins/indie-ios/skills/new-app/template/   files new-app copies into a repo
skills-lock.json                         source and hash of each vendored skill
scripts/sync-skills.sh                   rebuilds the vendored skills from the lock
```

## Validate

```bash
claude plugin validate ~/data/startups/indie-ios-kit
claude plugin validate ~/data/startups/indie-ios-kit/plugins/indie-ios
```

## Portfolio rule

Only process and infrastructure travel through this kit. Never put one app's UI, icon, onboarding, screen
layout, screenshots or store copy here (App Review Guideline 4.3).
