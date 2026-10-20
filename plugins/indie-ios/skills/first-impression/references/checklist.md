# First-session checklist

Each check has the reason it matters and where to look. The grep patterns are starting points for SwiftUI and
SwiftData apps; read the code they lead to before calling anything a finding, because a pattern match proves
nothing on its own. Rating prompt checks are in `rating-prompt.md`.

Sources for the "why" lines: Apple's HIG on
[onboarding](https://developer.apple.com/design/human-interface-guidelines/onboarding),
[launching](https://developer.apple.com/design/human-interface-guidelines/launching) and
[privacy](https://developer.apple.com/design/human-interface-guidelines/privacy); the WWDC17 session
[Love at First Launch](https://developer.apple.com/videos/play/wwdc2017/816/); NN/g on
[onboarding](https://www.nngroup.com/articles/mobile-app-onboarding/) and
[permission requests](https://www.nngroup.com/articles/permission-requests/).

## First run

### Taps to first value
Why: every tap between install and the moment the app shows its value is a place to quit. Apple's onboarding
guidance is to let people reach the content quickly and teach in context.
Look for: the `@main` App and its root view; the flag that gates onboarding (`grep -rn "@AppStorage" | grep -i onboard`);
the button that starts the core action and the save call at its end (`modelContext.insert`, `.save()`).
Count the taps on the shortest path a new user can take. Report the count and the steps that could go.

### Onboarding length and skip
Why: HIG asks for onboarding that is fast and optional; NN/g found tutorials did not improve task performance,
and justifies onboarding mainly for information the app needs or for personalising it.
Look for: `TabView` with `.tabViewStyle(.page)`, page arrays, a "Skip" or "Not now" button, and what each page
asks. A page that only tells (no choice, no setup) is a candidate to cut. A skipped tutorial must not come back
on the next launch.

### Default or placeholder values saved as real data
Why: a value the user never touched, saved as theirs, corrupts the history, the charts and any export or
Apple Health write. The user never finds out why their numbers look wrong.
Look for: initial values on inputs (`@State private var value = 70`, `defaultValue`, `initialValue`, pickers
and steppers with a preselected value) and the save path behind "Next", "Done" or "Save". Pass when an
untouched input is either not saved or saved only after an explicit confirmation; fail when tapping through
saves the start values.

### Data loss on Cancel or swipe-to-dismiss
Why: losing typed or measured values to a swipe teaches the user the app is not safe to use.
Look for: `.sheet(`, `.fullScreenCover(`, `interactiveDismissDisabled`, `confirmationDialog`, and Cancel
buttons that call `dismiss()`. Pass when a sheet that holds unsaved input blocks the swipe and asks before
discarding; fail when either path drops the input without a question.

### Empty states
Why: the first screen a new user sees is usually the empty one. It has to say what to do next and show one
clear action, not a blank list or an error-looking view.
Look for: `ContentUnavailableView`, `.isEmpty` branches, `@Query` results rendered with no empty branch, and
what the empty Home shows. Note any placeholder text or developer copy.

### Screens that look broken with one data point
Why: after the first core action the user has exactly one item. Charts with one point, "change 0", or lowest
equal to highest look like bugs at the exact moment the user checks whether the app worked.
Look for: `Chart {`, `LineMark`, `.first`/`.last` differences, `min()`/`max()`, streaks and averages, and
whether any of them is guarded by `count >= 2`. Propose hiding or replacing each with a line that says what the
second entry will show.

### Locked or Pro items a new user sees
Why: a new user who sees mostly locks before getting any value reads the app as a paywall. Apple's onboarding
guidance is to let people experience the app before asking them to buy.
Look for: Pro gates (`isPro`, `isUnlocked`, `Image(systemName: "lock`), paywall presentations, and the free
and Pro split in `CLAUDE.md`. Count locked items visible on the empty state and before the first core action.
Report "n of m visible items are locked" and where.
Fail when locked items outnumber the free ones a new user can act on. That is a finding, not an owner
decision: propose showing Pro items more quietly until the first success (one "+n with Pro" row per group, say)
while keeping them discoverable. Whether to show Pro items at all is the owner's call.

### Promises the listing makes are reachable in the first session
Why: a feature the store listing names (an integration, an export, a mode) that a new user cannot find without
digging through Settings is a promise the first session breaks, and it is often what made them download.
Look for: features named in the listing text (`metadata/`, or the description in `CLAUDE.md`) and how a new user
reaches each one: onboarding, the empty state, the result screen, or only a default-off toggle in Settings.
Propose surfacing a buried one where it is first useful, without adding an onboarding page for it.

### Splash and launch duration
Why: HIG says to launch instantly and keep any splash brief; a splash that runs on every cold launch costs a
daily-use app that time every day.
Look for: `SplashView` or a launch overlay, `Task.sleep`, `asyncAfter`, animation durations that gate the first
screen, and whether it is skippable or shown only once. Report the measured duration from the code. Whether
to keep a branded splash is usually an owner decision, not a bug.

## Permissions

### Asked in context, not at launch
Why: Apple asks apps to request access only when a feature needs it and to explain the benefit first. The
system prompt is shown only once, so a denial given at launch, before the user knows why, is hard to undo;
NN/g found that giving a reason raises the grant rate.
Look for each kind the app uses:

| Permission | Call sites |
| --- | --- |
| Notifications | `UNUserNotificationCenter.current().requestAuthorization` |
| HealthKit | `requestAuthorization(toShare:read:)`, `.healthDataAccessRequest(` |
| Camera, microphone | `AVCaptureDevice.requestAccess` |
| Location | `requestWhenInUseAuthorization`, `requestAlwaysAuthorization`, `CLServiceSession` |
| Photos | `PHPhotoLibrary.requestAuthorization`, `PhotosPicker` (needs no permission) |
| Tracking | `ATTrackingManager.requestTrackingAuthorization` |

Then the purpose strings: `NS*UsageDescription` in `Info.plist`, `project.yml` or `InfoPlist.strings`. Each should say
specifically what the data is used for. For each call site, write what triggers it. Pass when the trigger is
the user reaching the feature; fail when it runs at launch or in onboarding for a feature that is optional.

### A priming screen, if there is one, follows the HIG
Why: the HIG allows a screen before the system alert but asks for a single "Continue" or "Next" button, no
"Allow" wording, no cancel, and no picture of the system alert.
Look for: custom views shown right before a `requestAuthorization` call.

### A dismissed offer comes back
Why: an in-app offer ("Turn on reminders?") that disappears for good when the user swipes it away loses the
feature for that user. Only an explicit answer should end it.
Look for: flags like `promptShown`, `didOffer`, `hasAsked` (`grep -rn "Shown\|didOffer\|hasAsked\|Prompted"`). Find
where each is set. Fail when it is set on display or on first save instead of on the user's answer, or when
the offer is tied to "the first" event that can pass without the user answering.

### A way back after a denial
Why: after the system prompt has been answered, the app cannot ask again; it can only send the user to
Settings.
Look for: `UIApplication.openSettingsURLString`, `openNotificationSettingsURLString`, and how the feature looks
when access is denied. HealthKit cannot tell an app whether read access was denied, so the feature should
explain where to change it instead of guessing.

## Retention

### An opt-in reminder after the first success
Why: offered after the user got value, a reminder comes with a reason the user has just seen, and it gives the
second session a date.
Look for: the notification scheduling code (`UNCalendarNotificationTrigger`, `UNTimeIntervalNotificationTrigger`)
and where the offer appears. Pass when it is offered after the first core action, opt-in, and the user can change it
later in the app.

### The result screen says what the next session will show
Why: the user decides on the result screen whether there is a reason to come back. One line that says what the
next session adds ("your next entry shows the first change") gives that reason.
Look for: the view presented after the save call (the `.sheet`, `.navigationDestination` or state switch that
follows `modelContext.insert` / `.save()`) and its strings. Fail when it only says "Saved" or closes at once.

### The second session is different from the first
Why: if the app looks the same with one item as with none, there is little to come back for.
Look for: branches on the item count (`.count`, `.isEmpty`, `count >= 2`) in the home and detail views, and
what each renders with exactly one saved item.
