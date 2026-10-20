# Walking the app in the simulator

How the walk mode builds the app, drives it, sets up each condition, and records each step. The step record is
adapted from the walkthrough in open-mercato/skills `om-synthetic-users` (MIT).

## Before the first tap

1. Read how the repo builds and tests: the build command in `CLAUDE.md`, `project.yml` or the scheme, and the
   UI tests (`UITests/` or similar). The UI tests show the launch arguments the app understands (skip splash,
   demo data, mock services, reset state) and the accessibility identifiers worth tapping. If `CLAUDE.md` names
   a device-automation tool, use that one.
2. Use a simulator of your own. `xcrun simctl clone` works only on a shut-down device, and the owner's
   simulators may be booted and must stay that way, so the usual route is
   `xcrun simctl create "Journey walk" <device-type> <runtime>`, then boot it. Note its UDID and pass it to
   every simulator command and every driver call: drivers default to the first booted simulator, which is
   the owner's. Never erase, reset, shut down or uninstall anything on a simulator you did not create, and
   delete only yours at the end.
3. Build for that simulator, install, and launch. Take a screenshot and confirm the first screen is what the
   journey expects before walking.
4. Save screenshots with `xcrun simctl io <udid> screenshot screenshots/journeys/<YYYY-MM-DD>/J<n>.<stage>-<condition>.png`;
   a driver's own screenshot is for looking, not for the record. If `.gitignore` does not cover `screenshots/`,
   ask before adding it; never commit screenshots in this run.

## Driving it

Use the first of these the session has, always with the walk simulator's UDID:

- `agent-device`: open the app, take an interactive snapshot, act on the refs or accessibility identifiers it
  returns, re-snapshot after each action. It reads the accessibility tree, so "noticed first" and missing
  labels can be judged from the snapshot too.
- An iOS Simulator tool (launch, screenshot, tap, swipe, type): it taps by coordinates in points, while
  `simctl io screenshot` saves pixels (3x on most iPhones), so divide pixel positions by the scale. Take a
  screenshot after every action and check the tap landed before recording the step.
- Neither: run the existing UI tests that cover a journey's stages and use their screenshots; every stage no
  test covers goes under "Not walked". Do not write new UI tests in this run.

`xcrun simctl` covers what the drivers do not: `openurl` for deep links, `push` for a remote notification's tap
handling, `terminate` and `launch`, `io screenshot`, `ui` for appearance and text size, `privacy` for
permissions, `status_bar` to pin the clock for clean screenshots.

## Picking the starting state

Launch arguments that seed demo data can put the app in a state the journey's user cannot reach: more items
than the free tier allows, Pro unlocked, dates that make no sense. Before using one, check the state against
the journey: who the user is (free or paid, first or tenth time) and what data they would really have. If the
seed does not fit, start from a reset store and build the state by walking the journey's earlier steps. Walking
through the first run to get there is fine; findings about the first run that `docs/LAUNCH-FIRST-IMPRESSION.md`
already lists are not repeated. Check whether seeded dates are relative to today: a journey about a date
(a departure, a deadline) can only be walked if the seed puts that date where the journey needs it.

## Choosing what to walk

Walking every stage of every journey under every condition is far too much for one run. Walk in this order and
stop when the run has used its budget (the owner's, or about an hour):

1. The main journey (J1) end to end, default condition.
2. J1 again under the conditions most likely to break its moment of truth (usually kill and reopen, largest
   text, and whichever of offline, denied permission or the free limit the journey depends on).
3. Every other journey's moment of truth, default condition.
4. The remaining conditions, most likely to break first.

Everything left out goes under "Not walked" with "not reached this run" so the next run starts there.

## Conditions

Walk each condition from a clean launch. How to set each one up:

| Condition | How |
|---|---|
| First run vs returning | a reset-store argument, then the journey's earlier steps (see "Picking the starting state") |
| User kills the app | press Home, then `xcrun simctl terminate`, then `launch`: the swipe-up kill, after the app was backgrounded |
| App dies in the foreground | `xcrun simctl terminate` while the app is in front, a few seconds after the last change, then `launch`: what a crash or the system's kill does to unsaved work |
| Background and come back | press Home, wait, reopen from the icon or the notification |
| Offline or a service error | the repo's mock or failure-mode argument if it has one; otherwise "Not walked" |
| Permission denied | deny the prompt when it appears, or `xcrun simctl privacy <udid> revoke <service> <bundle-id>` before launch |
| Largest text | `xcrun simctl ui <udid> content_size accessibility-extra-extra-extra-large` |
| Dark appearance | `xcrun simctl ui <udid> appearance dark` |
| Another language | the app's own language setting if `CLAUDE.md` describes one, else `-AppleLanguages "(xx)" -AppleLocale xx_XX` |
| Free vs paid | `simctl launch` does not attach the scheme's StoreKit configuration, so purchases fail there. Use a UI test run through `xcodebuild test` with the scheme, or the app's own debug unlock if `CLAUDE.md` names one; otherwise the purchase goes under "Not walked" and only the free side is walked |
| Notifications | for local notifications, read what the code schedules (content, time, the trip or item it opens) and walk the tap with `simctl push` using the same payload keys; the scheduling and timing themselves are "Not walked" unless the app has a date override |
| Widgets and Live Activities | open what the deep links or `openurl` reach; adding a widget or seeing the Lock Screen goes under "Not walked" if the driver cannot do it |
| Dates and time passing | the app's own date override if it has one, or a seed with dates relative to today; otherwise "Not walked" |

Do not add launch arguments, debug menus or test hooks to the app to make a condition reachable. If a
condition cannot be set up, report that too: "no way to test J2 offline".

## The step record

For each stage walked, keep these notes while walking. They are working notes, not part of the output; each
finding in `docs/JOURNEY-AUDIT.md` is built from them and cites the screenshot and code.

| Field | What goes in it |
|---|---|
| Expect | written before acting: what this user, in this situation, expects to see and do here |
| Got | what the screen shows after the action, in plain words |
| Noticed first | the first two or three things the eye goes to; a primary action not among them is a finding |
| Friction | where the user would hesitate, misread, or take the long way, and why |
| Missing case | a situation from the journey or the business rules the screen does not handle |
| Contradiction | where the app breaks the job, a hard rule in `CLAUDE.md`, the listing or onboarding's promise |
| Code | the file:line that produces what was seen |
| Screenshot | the saved path |

Judge the states each screen should have (default, empty, loading, error, denied) and record a missing state as a
missing case.

## Before recording a finding

Some of what the simulator shows comes from the test setup, not from the app: a mock service's data, a missing
StoreKit configuration, a seed no real user has. For each finding, say whether it would happen on a device for
a real user, and how you know (the shared code path, file:line). If it only happens because of the setup, it is
not a finding; if the setup hides whether it would happen, put it under "Not walked". When a finding depends on
timing (a save, a refresh), repeat it once and say how often it happened.

## What the walk must never do

- Run on a physical device, sign in with a real Apple ID, or make a real purchase.
- Type real personal data. Use sample data that is obviously invented.
- Send anything off the machine: no sharing to real contacts, no posting, no email.
- Edit the app's code or project to get past a step. A step the app blocks is a finding.
- Touch a simulator, an app or data it did not create.
