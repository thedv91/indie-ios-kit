---
name: user-journey
description: "Work out the journeys an indie iOS app's users go through from its business rules and the job they hire it for, then check the app against them: trace each journey through the code and propose options for the gaps (map), or build the app, walk each journey in the iOS Simulator under real conditions and record where it breaks (walk). Writes docs/JOURNEYS.md, the journeys every later feature is checked against, and docs/JOURNEY-AUDIT.md plus roadmap items; it does not fix anything. Use when the user asks for a user journey, journey map, customer journey, end-to-end walkthrough, UX audit, to explore the app as a user, to find what to improve, why a flow feels wrong, or to propose options for a feature from the user's point of view; and when ship-app reaches the end of phase 1 (map) or the end of the build phase or a release (walk)."
---

# User journey: what users go through, and where the app lets them down

A journey is what one user in one situation does from the moment they need the app until the job is done,
including what happens outside the app (a notification, a widget, the Lock Screen, the App Store page). This
skill derives the journeys from the app's business rules, writes them down where every later change can be
checked against them, and then tests the app against them: on paper through the code, or for real in the
simulator.

The run ends with documents and roadmap items. Fixes come later, one roadmap item per PR, so the owner decides
which trade-offs to take before any code changes.

This file is shared by every app in the portfolio and names none of them. Everything app-specific comes from
the app's repo. Where this skill and the app's `CLAUDE.md` disagree, `CLAUDE.md` wins.

## Pick the mode

- **map**: derive or refresh the journeys and trace them through the code. Runs anywhere, no simulator needed.
  Use it before building (phase 1), when planning a feature, or when asked to propose options.
- **walk**: build the app and walk the journeys in the simulator. Needs a Mac with Xcode. Use it once the
  journeys' screens exist, before a release, or when asked to explore the app or find what to improve.

If the user names neither, run map, then walk if `docs/JOURNEYS.md` already existed and the app builds. A walk
always starts from `docs/JOURNEYS.md`; with no such file, run map first.

## 1. Read the business

- `CLAUDE.md`: the product paragraph, the free and Pro split, the platforms and extensions (widget, Live
  Activity, notifications, Share extension), and the hard rules. Note each rule that limits a fix ("no
  network", "no analytics", "one notification only"); a proposed fix must not break one.
- `.agents/product-marketing.md`: the job ("When …, I want to …, so I can …"), its forces (push, pull,
  anxiety, habit), what users hire today, and the customer quotes. Journeys are built from these. If the file
  has no job, say so and ask whether to backfill it with `jobs-to-be-done` first; do not invent one. If the
  owner says to go on without it, use the product paragraph in `CLAUDE.md` as the job for this run, tag what
  comes from it `[CLAUDE.md]`, and say in the audit that no customer quotes backed the journeys.
- `docs/ROADMAP.md`, `docs/LAUNCH-FIRST-IMPRESSION.md`, and `docs/JOURNEY-AUDIT.md` if they exist: what is
  planned or already found, so nothing is proposed twice. The first session belongs to `first-impression`;
  this skill links to its findings rather than repeating them.
- The domain logic and its tests (the `Packages/*Kit` package `CLAUDE.md` names): the business rules in code.
  A rule the code enforces that no journey exercises is a missing case to look at.

## 2. Map: derive the journeys

Write 3 to 5 journeys. Fewer means the app has one job and one situation; more means some are steps of
another. Each journey is one situation from the job, in the user's words, never a demographic persona: "the
night before an early flight", not "Sarah, 35". Cover, across the set:

- the main job, start to finish, as a returning user (the first run is `first-impression`'s);
- the job under the pressure the forces name (the anxiety, the time limit, the habit it competes with);
- the moments the app reaches the user without being opened (reminders, widgets, Live Activities, background
  updates), if the app has any;
- what happens when something goes wrong: no network, a denied permission, data changed elsewhere, the free
  limit reached.

For each journey, write the stages and, per stage: the user's goal, the touchpoint (screen, notification,
widget, system sheet), the code entry point (file:line), what can go wrong, and how the user feels there,
taken from the forces or a quote. Tag each cell that makes a claim with its source: `[quote]`, `[code]`,
`[CLAUDE.md]`, or `[assumption]`. With no forces or quotes to draw on, leave the Feeling column out rather
than fill it with assumptions. Name the moment of truth: the step where the user decides the app did its job, or gives up.
List the conditions the journey must survive (see `references/walking-the-app.md`, "Conditions").

Then trace each journey through the code and record every gap: a stage with no screen, a dead end, a state
with no UI (empty, loading, error, offline, denied), a business rule the journey breaks, a promise from the
listing or onboarding the journey does not keep. For each gap give two or three options with their cost, and
mark the one you recommend. Gaps that are choices for the owner (pricing, scope, a hard rule) go under
"Decisions for the owner".

Before any code exists (phase 1 of `ship-app`), the Code column says "not built" and there is nothing to
trace: write `docs/JOURNEYS.md` only, skip the audit and the "Journeys" roadmap section, and let `ship-app`
order the v1.0 items by journey stage.

If `docs/JOURNEYS.md` exists, this is a refresh: keep the journey ids, update stages that changed in code, add
journeys for new features, and never renumber.

## 3. Walk: test the journeys in the app

Follow `references/walking-the-app.md`: how to build and drive the simulator with whatever tool the session
has, how to set up each condition, what to record at every step, and what the walk must never do. In short:

1. Build the app with the command in `CLAUDE.md` on a simulator created for the walk, and pick a starting
   state the journey's user could really be in (a demo-data seed may not be one).
2. Walk in the reference's order (the main journey first, then the conditions most likely to break its moment
   of truth) until the run's budget is used. At each step, before acting, write what the user in this
   situation expects to see; then act, save a screenshot, and note what happened.
3. Record a finding only with evidence (the screenshot or the observed text, and the code location) and only if
   it would happen on a device, not just because of a mock or the test setup. A step the walk could not reach
   (a real purchase, a real date passing, a device feature the simulator lacks, or out of budget) is listed
   under "Not walked" with the reason, never assumed to work.

## 4. Write the output

`docs/JOURNEYS.md` (map writes it, walk only reads it), in English, describing the app as it is now:

```markdown
# User journeys

<one line: these are the journeys every change is checked against; the job they come from is in
.agents/product-marketing.md; findings live in docs/JOURNEY-AUDIT.md>

## J1: <the situation, in the user's words>
Starts when <trigger>. Done when <the job is done, as the user would say it>.
Moment of truth: <the step where the user decides>.
Conditions: <the conditions from the reference that apply>

| Stage | User's goal | Touchpoint | Code | What can go wrong | Feeling |
|---|---|---|---|---|---|
| <stage> | <goal> | <screen / notification / widget> | <file:line> | <risk> | <feeling> [source] |
```

`docs/JOURNEY-AUDIT.md`, rewritten on each run and dated. A run that maps and walks writes one audit with both
the code-traced gaps and the walk findings:

```markdown
# Journey audit, <date>, <map | walk | map and walk>

<one line: what was checked, on which commit and simulator, and that the work is listed under "Journeys" in
docs/ROADMAP.md>

## Findings
<numbered, most harmful to the job first: bold one-line problem; journey and stage (J1.3); what happens, with
file:line and, for a walk, the screenshot path and the condition; why it hurts the job; the options with cost,
the recommended one marked>

## Decisions for the owner
<one bullet per trade-off: the issue, the options>

## Not walked
<stage, condition, why>

## What already works
<one line per journey stage the run confirmed, so the next run knows what to recheck>
```

Rank findings by harm to the job: lost or wrong data first, then a journey that cannot be finished, then one
that is slow or confusing, then one that only looks unfinished.

`docs/ROADMAP.md`: a "Journeys" section with one unchecked item per recommended fix, named after the journey
stage ("J2.3: …"), and one item for the owner decisions. Put it just before the first section of later work
("v1.1+", a later phase, "Backlog"). Before adding an item, search the roadmap and the audit docs for the
stage's key words and the code symbol it touches; skip it if any section already has it, and mention the match
in the finding instead.

`CLAUDE.md`: where it mentions other files in `docs/`, add a short mention of `docs/JOURNEYS.md` and
`docs/JOURNEY-AUDIT.md` next to them.

## 5. Stop and report

Do not implement fixes in the same run. Report the journeys (one line each), the findings in order with one line
each, the owner decisions, what was not walked, and the files written. Then the owner picks the first roadmap
item.

## Rules that win

- Hard rules in `CLAUDE.md` win. No analytics SDK, account, tracking or network call is proposed unless it
  allows them; walking the app never needs one.
- Journeys come from the business, not from the screens. A screen no journey needs is a finding ("what is this
  for?"), not a reason to invent a journey.
- No made-up users, quotes, numbers or feelings. A feeling comes from a force or a quote and says which; one
  that comes from neither is marked `[assumption]`.
- A walk is evidence about the simulator build on that commit, not about real users. Findings say "the
  journey breaks at …", never "users hate …".
- Guideline 4.3: proposed fixes come from this app's design language, never from another portfolio app.
