---
name: ship-app
description: "End-to-end process for an indie iOS app, from idea to App Store to marketing: which phase the app is in, which skill to run next, and the gate that closes each phase. Use when the user asks what to do next, where the app stands, how to get it on the store or launch it, or wants to run the whole process; also at the start of any release, store listing, launch or marketing task, and before starting a roadmap item, mapping user journeys or writing acceptance criteria, before picking a narrower skill."
---

# Ship the app: idea → build → store → launch

Four phases, run in order. Each phase lists the skills to run, in order, and a gate. A phase is done only when
its gate holds; do not start the next phase's outward-facing steps before that.

This skill decides the order. The skills it names decide how each step is done, and `CLAUDE.md` overrides
both (see "Rules that win" below). This file is shared across every app in the portfolio, so it names no app:
everything app-specific comes from the repo.

## What to read from the repo first

Read these before Step 0 and use them wherever a step below says "the app's ...":

| Fact | Where |
| --- | --- |
| App name, store title, subtitle, target keyword, free tier, design language | `CLAUDE.md` → "Positioning" |
| Domain package that holds the logic and its tests | `CLAUDE.md` → "Repo layout" (the `Packages/*Kit` row) |
| Claims and data the app must never make or collect | `CLAUDE.md` → "Positioning" and "Hard rules" |
| Store languages | `docs/localization.md` |
| Screenshot spec | the screenshots doc linked from the README "Layout" block |
| Capabilities and entitlements (HealthKit, App Groups, ...) | `project.yml` |
| Placeholders still to replace | `CLAUDE.md` → "Placeholders the owner must replace" |

If a fact is missing, say which one and ask; do not guess a keyword, a language list or a banned claim.

## Step 0: find the current phase

Check these in order. The first one that fails is the current phase.

1. `.agents/product-marketing.md` exists and `CLAUDE.md` names the target keyword → phase 1 is done.
2. Every item under "Next" in `docs/ROADMAP.md` is ticked, apart from store items (TestFlight, screenshots), and
   `user-journey` (walk) and `first-impression` have run: their in-app items under "Journeys" and "First
   impression" are ticked or moved to a later version by the owner → phase 2 is done. An app already on the
   store that never ran one of them passes this part; offer to run it before the next release instead of
   sending the app back to phase 2.
3. `asc` reports the version as "Waiting for Review", "In Review" or later
   (`asc-submission-health` has the status commands) → phase 3 is done.
4. Otherwise the app is live: phase 4, which repeats with every release.

Tell the user the phase, the gate that failed, and the next skill you will run. If an earlier gate fails while
later work is clearly done (code exists but `.agents/product-marketing.md` does not), say so and offer to
backfill the missing artifact instead of restarting the phase.

## Phase 1: idea and validation

1. `brainstorming`: the problem, who has it, and the smallest app that solves it.
2. `customer-research`: mine Reddit, forums and competitors' App Store reviews for the words people use and the
   complaints they repeat. Store the quotes; phase 3 copy reuses them.
3. `jobs-to-be-done`: from those quotes, the job people hire an app like this for ("When …, I want to …, so I
   can …", naming no app), its functional, emotional and social sides, the four forces (push, pull, anxiety,
   habit), and what they use today, doing nothing included. Every line cites a quote; the rest is marked as an
   assumption. Phase 2 checks roadmap items against this job.
4. `aso` (competitor comparison only, there is no listing yet): fetch the top 5 apps for the target keyword and
   note their names, subtitles, prices and review counts.
5. `pricing`: free tier, Pro tiers and prices, checked against what those competitors charge.
6. `grilling`: stress-test the plan before writing code.
7. `product-marketing`: write `.agents/product-marketing.md`, with the step 3 job and forces in its "Jobs to be
   done" and "Switching Dynamics" sections. Every marketing skill reads this file first.
8. `user-journey` (map): the journeys the step 3 job implies, written to `docs/JOURNEYS.md`. With no code yet,
   each stage's code column says "not built". Order the v1.0 items in `docs/ROADMAP.md` so the main journey
   can be finished end to end as early as possible, and name the journey stage each item serves ("J1.2: …");
   stages v1.0 leaves out go under "v1.1+".

Gate: `.agents/product-marketing.md` exists and its "Jobs to be done" section holds a job statement that names
no app; `CLAUDE.md` has the product paragraph, target keyword and design language; `docs/JOURNEYS.md` exists;
`docs/ROADMAP.md` lists the v1.0 items, each naming a journey stage.

## Phase 2: build

Loop over `docs/ROADMAP.md`, one item per PR:

1. Take the first unchecked item.
2. Find the journey stage in `docs/JOURNEYS.md` the item serves. An item that serves none goes back to the
   owner before any code. When the item names a feature rather than what the user can do once it works, or
   touches stored data, purchases or a permission prompt, run `intent-driven-development`: acceptance criteria
   that start from that stage's goal and "what can go wrong", each with how it is checked (a test in the
   domain package, a UI test, or a simulator run). The owner's yes to the criteria is the approval before
   building. Skip the criteria when the item's outcome is already observable. An app that passed phase 1
   before `jobs-to-be-done` and `user-journey` joined the kit has neither the job nor `docs/JOURNEYS.md` yet:
   offer to backfill them first.
3. Write it. `swiftui-pro` and `apple-design` for SwiftUI views, `tdd` for logic in the app's domain package,
   `illustration-style` with `vectorcraft-illustration` for any artwork (if the repo has no `illustration-style`
   skill yet, create it with `illustration-setup` first), `paywalls` for paywall copy and layout.
4. Build and run locally, walk the item's journey stage in the simulator (on a Mac; a cloud session without
   Xcode leaves this to the owner) and check each acceptance criterion from step 2. Then review the diff with
   Claude Code's built-in `/code-review`: `high` for an item that has acceptance criteria from step 2, `medium`
   for the rest. Fix what it confirms, then run `verification-before-completion` before calling it done. The kit
   ships no review skill of its own: the criteria check above is the spec review, and `/code-review` looks for
   bugs. If the item changed how a journey goes, update that stage in `docs/JOURNEYS.md` in the same PR.
5. Push, wait for CI to go green, then tick the item.

When the last v1.0 item under "Next" is ticked, before the 1.0 submission:

6. `user-journey` (walk): build the app and walk every journey under its conditions. It writes
   `docs/JOURNEY-AUDIT.md` and a "Journeys" section in `docs/ROADMAP.md`; work through those items with the same
   loop, one per PR.
7. `first-impression`: audit the first session and plan launch week. It writes
   `docs/LAUNCH-FIRST-IMPRESSION.md` and a "First impression" section in `docs/ROADMAP.md`; work through those
   items with the same loop, one per PR. The launch-week steps in it are the owner's and wait for phase 3.

Gate: every v1.0 item under "Next" is ticked apart from store items, `user-journey` (walk) and
`first-impression` have run and each in-app item in their roadmap sections is ticked or moved to a later
version by the owner, CI is green on main, and the placeholders listed in `CLAUDE.md` are replaced.

## Phase 3: App Store

Listing and assets:

1. `aso` and `copywriting`: name (30 characters), subtitle (30), keywords (100), promotional text and description
   in English. Build them from the target keyword and the phase 1 quotes; keep the title and subtitle that
   `CLAUDE.md` fixes unless the owner agrees to change them.
2. `asc-metadata-sync`: write them to `metadata/` and run `asc metadata validate`.
3. `asc-localize-metadata`: translate into every language in `docs/localization.md`.
4. Screenshots: follow the app's screenshots doc. `asc-shots-pipeline` is for automating capture across
   locales once the manual set is approved.
5. `store-assets`: the product-page header and search-result image, and screenshots for a new device such as
   iPhone Duo.

Build and submit:

6. `asc-signing-setup`: bundle ID, the capabilities `project.yml` declares, certificates. The owner runs this on
   a Mac with the team account.
7. `asc-xcode-build`: archive and upload. `asc-testflight-orchestration`: internal testers first.
8. `app-store-preflight-skills` and `app-store-review`: fix every rejection finding before submitting.
9. `asc-release-flow`: stage the version and submit. For 1.0, follow the store-side plan in
   `docs/LAUNCH-FIRST-IMPRESSION.md` (featuring nomination, pre-order, manual release). If it stalls or is
   rejected, use `asc-submission-health`.

Gate: the version is "Waiting for Review" or later, and the metadata in `metadata/` matches App Store Connect.

## Phase 4: launch and marketing

At launch:

1. `launch`: run its readiness gate, then plan owned, rented and borrowed channels for the first two weeks.
2. `directory-submissions`: app directories and launch sites.
3. `public-relations`: press kit and a short pitch list.
4. `social`: short-form video scripts that show the app's one job from the "Positioning" section, start to finish.

With every release after launch:

5. `asc-whats-new-writer`: release notes from the git log since the last tag, in every store language.
6. Two weeks after a release, `aso` on the live listing URL, then back to phase 3 step 1 for whatever it flags.
7. Before each release, `user-journey` (walk) on the journeys the release touched; its items join the roadmap
   like any other.

Growth, once the first two weeks after launch are over:

8. `marketing-plan`: the 12-month plan, sized to a solo budget and to the rules below. `marketing-ideas` is for
   when the plan runs dry or the owner asks for ideas.
9. The channels the plan picks, each started only with the owner's yes: `community-marketing` (the subreddit,
   Discord or forum where people with the job already gather), `influencer-marketing` (creators and newsletter
   sponsorships), `referrals` (share and refer-a-friend loops, replies to App Store reviews), `free-tools` (a
   small free web tool that leads to the app), `ai-seo` (the app's website, so AI assistants cite it).

## How the product skills fit together

`jobs-to-be-done`, `user-journey`, `intent-driven-development` and `brainstorming` come from different authors.
In this kit they form one chain (job → journeys → acceptance criteria → code → walk), and these rules settle
where they disagree:

- One job, one place. The job lives in `.agents/product-marketing.md`; `docs/JOURNEYS.md` quotes it and never
  restates it in new words. A journey is a situation from that job, never a demographic persona.
- `docs/JOURNEYS.md` is the product artifact `intent-driven-development` asks for: business rules and target
  users come from it and from `.agents/product-marketing.md`, not from the code.
- `brainstorming` is for phase 1 and for an idea outside the roadmap. A roadmap item in phase 2 goes through
  step 2 instead, and the owner's yes there is the approval its gate asks for. It hands over to
  `writing-plans`, which is not in this kit: after its design is approved, come back here instead.
- `user-journey` owns the "Journeys" section of `docs/ROADMAP.md` and `first-impression` owns "First
  impression"; neither edits the other's, and the first session is `first-impression`'s.
- Once phase 1 is done, change `docs/JOURNEYS.md` or the "Next" list only with the owner's yes, apart from a
  PR updating the stage it just changed (phase 2 step 4).

## Which skill owns a request several of them claim

The vendored skills' descriptions overlap, and several were written for web products. When a request matches
more than one, this table decides:

| Request | Owner | The other skill's part |
| --- | --- | --- |
| Release notes, What's New, changelog | `asc-whats-new-writer` | `launch` only announces the release on owned channels |
| Launch checklist, pre-launch QA, "we're about to ship" | the phase 3 gate, then the launch-week plan from `first-impression` | `launch` runs its readiness gate at phase 4 step 1 |
| GTM plan | `launch` for the first two weeks | `marketing-plan` for anything longer |
| Product Hunt | `launch` plans the day | `directory-submissions` writes and tracks the listing |
| Job to be done, JTBD | `jobs-to-be-done` writes the job | `customer-research` collects the quotes it cites |
| Compare with competitors | `aso` for App Store competitors | `competitors` only for vs and alternative pages on the app's website |
| Onboarding, first run, rating prompt | `first-impression` | `apple-design` reviews how a screen looks; `referrals` only replies to App Store reviews |
| UX audit, walk the app as a user | `user-journey` | `apple-design` for a HIG review of given screens |
| Ambassador program | `community-marketing` for unpaid advocates | `influencer-marketing` for paid creators, `referrals` for a reward per referral |
| Screenshots and store images | the app's screenshots doc, automated by `asc-shots-pipeline` | `store-assets` for the header, search-result image and new devices; `asc-metadata-sync` for text |
| Marketing ideas, "brainstorm marketing" | `marketing-ideas` | `brainstorming` is for the product, as above |
| Persuasion, anchoring, social proof | `marketing-psychology`, applied inside `copywriting`, `paywalls` or `pricing` | |
| Rejection check before submitting | `app-store-preflight-skills` and `app-store-review`, both | |
| Submission stuck or rejected | `asc-submission-health` | `asc-release-flow` stages and submits |

## Rules that win over any skill above

The installed marketing and store skills are generic. Where they conflict with `CLAUDE.md`, `CLAUDE.md` wins.
These hold for every app in the portfolio:

- No analytics, attribution SDKs, accounts, email capture or network calls unless `CLAUDE.md` allows them.
  Skip any step that needs them. This covers referral and affiliate tracking, and a waitlist or free tool that
  collects email addresses.
- No claim the app's `CLAUDE.md` bans (health outcomes, unmeasured savings, "free" in store metadata), in any
  copy, listing, screenshot caption or post.
- Numbers in copy (sizes, savings, speed) come from a measured result recorded in `docs/`, never from an estimate.
- No invented reviews, ratings, user counts or testimonials. Proof points come from real reviews only.
- No invented scarcity or urgency (countdowns, "only N left"), whatever `marketing-psychology` or `paywalls`
  suggests.
- Nothing is offered in exchange for an App Store rating or review. A referral reward or creator offer that
  unlocks anything in the app goes through `app-store-review` before it is built.
- Guideline 4.3: listing visuals, icon and copy belong to this app; never reuse them for another app in the
  portfolio, and never copy another portfolio app's listing into this one.

## Ask before anything that leaves the machine

Run dry runs freely. Get the owner's yes, per action, before:

- `asc metadata push` or `apply` without `--dry-run`, screenshot uploads, price or availability changes
- adding external TestFlight testers or opening a public link
- submitting for review, releasing a version, or cancelling a submission
- posting to social or in a community, emailing a journalist, messaging a creator, or submitting to a directory

If a skill points to another skill that is not installed (for example `cro`, `emails`, `seo-audit`,
`ad-creative` or `offers`), say so and ask, rather than improvising its steps.
