---
name: first-impression
description: "Audit what a brand-new user goes through in an indie iOS app before its first App Store release: does the first session deliver the app's value, will the user come back, is the rating prompt asked at the right moment, are permissions asked in context, and what the store-side launch week looks like. Traces the real code path from cold launch to the second session, cites file:line for every finding, and writes docs/LAUNCH-FIRST-IMPRESSION.md plus roadmap items; it does not fix anything. Use when the user asks for a first-run audit, an onboarding review, a first impression or activation check, why users don't come back, when to ask for a review or where the review prompt should go, what to check before submitting 1.0, or a launch week plan, and when ship-app reaches the end of the build phase."
---

# First impression: the first session and launch week

This skill audits an app before its 1.0 release from the point of view of someone who just installed it. It
answers three questions: does the first session deliver value, does the user come back, and is the rating
prompt shown at the right moment. It also plans the store side of launch week, because the people who arrive
that week are the ones the first session has to win.

The audit ends with a document and roadmap items. Fixes come later, one roadmap item per PR, so the owner can
decide which trade-offs to take before any code changes.

This file is shared by every app in the portfolio and names none of them. Everything app-specific comes from the
app's repo. Where this skill and the app's `CLAUDE.md` disagree, `CLAUDE.md` wins.

## 1. Read the app

- `CLAUDE.md` (or the product doc it links): the product paragraph, the free and Pro split, the design rules,
  and the hard rules. Note every rule that limits a fix ("no analytics SDKs", "no network", "one notification
  only", "no health claims"); a proposed fix must not break one.
- `docs/ROADMAP.md`: what is planned already, so a finding is not proposed twice.
- `docs/LAUNCH-FIRST-IMPRESSION.md`, if it exists: this is a re-run. Keep its structure, check each listed
  problem against the code again, move fixed ones into the "how the flow protects the job" part, and add new
  findings. Do not start the file over.
- The App Store listing text, if the repo keeps it (`metadata/`): promises the first session has to keep. A
  listing claim the code contradicts (a count, a feature, a price) is a finding too; report it, don't edit the
  listing in this run.

## 2. State the first session's one job

Write one sentence: the core action, plus the moment the user sees value from it. For example: "the user
records their first entry with real values and sees the summary change". Every finding is ranked by how much
it hurts this job, so get the owner's agreement if the product doc leaves it unclear.

## 3. Trace the real code path

Follow the code, not the docs, through these stops, and note file:line at each:

1. Cold launch: the `@main` App, any splash or launch animation and how long it runs, what decides whether
   onboarding shows.
2. Onboarding: pages, what each asks for, what can be skipped, what permissions it requests.
3. The empty state: what a new user sees before doing anything, including locked or Pro items.
4. The first core action: every tap from the empty state to a saved result, and what gets saved.
5. The result screen: what the user sees right after, what it offers next (reminder, rating, paywall).
6. The second session: what is different when the app opens again with one saved item.

For an app with more than a few dozen view files, hand the trace to an Explore subagent with these six stops
and ask for file:line per stop, then read the files it names yourself before judging them.

## 4. Run the checklist

Go through `references/checklist.md` (first run, permissions, retention) and `references/rating-prompt.md`.
Each check says why it matters and what code to look for. For each finding record:

- what happens, in the user's terms, with file:line;
- why it hurts the one job;
- the proposed fix, in one or two sentences, within the app's hard rules.

Rank findings by harm to the one job, most harmful first. A finding that loses or corrupts the user's data
comes before one that slows them down, which comes before one that only looks unfinished.

Some findings are trade-offs, not bugs: pricing, trials, a branded splash, a change to a promise the listing
makes, a fix that would break a hard rule in `CLAUDE.md`. Put those under "Decisions for the owner" with the
options, not in the fix list. Keep this list short: when a check in the checklist fails (a first screen that is
mostly locked, a listed feature a new user cannot find), it is a finding with a proposed fix, and the owner can
still decline it.

## 5. Plan the store side

Read `references/launch-week.md` and write the launch-week plan for this app: the featuring nomination and
what to name in it (taken from the product doc, not invented), pre-order, manual release, TestFlight, how to
read results in App Store Connect Analytics, and localized screenshot captions if the app ships more than one
language. Label each claim as Apple-documented or vendor-observed, as the reference does.

## 6. Write the output

`docs/LAUNCH-FIRST-IMPRESSION.md`, in English, describing the app as it is now:

```markdown
# Launch window and first impression

<one line: what this file is, and that the work is listed under "First impression" in docs/ROADMAP.md>

## What the launch window is
<what Apple documents, what vendors observe, which signals matter after the first week, and how this app
reads them without third-party SDKs>

## Before release (store side)
<featuring nomination, pre-order, manual release, TestFlight, conversion assets>

## First session (in-app)
<the one job, in one sentence>
<what already protects it, if anything, with the symbol names>
<numbered findings, most harmful first: bold one-line problem, what happens with file:line, the fix>

## Decisions for the owner
<one bullet per trade-off: the issue, the options>
```

`docs/ROADMAP.md`: a "First impression" section (create it before "v1.1+" or the equivalent later-work section
if it does not exist) with one unchecked item per fix, one item for the owner decisions, and one for the
store-side launch-week steps. Skip any item the roadmap already has.

`CLAUDE.md`: if it keeps a list of docs, add one line linking `docs/LAUNCH-FIRST-IMPRESSION.md`.

## 7. Stop and report

Do not implement fixes in the same run. Report the one job, the findings in order with one line each, the owner
decisions, and the files written. Then the owner picks the first roadmap item.

## Rules that win

- Hard rules in `CLAUDE.md` win. No analytics SDK, no account, no network call proposed unless it allows them.
- No made-up numbers. A duration, a count or a percentage in the doc comes from the code (a timer value, a
  number of pages) or from a cited source.
- No health, financial or other outcome claims the app's `CLAUDE.md` bans, including in proposed copy.
- Guideline 4.3: proposed fixes come from this app's design language, never from another portfolio app.
