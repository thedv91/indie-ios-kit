# Rating prompt

Apple says search results depend partly on ratings and reviews, and vendors observe that rating count and
recency weigh more after launch week (see `launch-week.md`). Without an automatic prompt, ratings come only
from people who go to the store on their own. The prompt has to come at a moment the user just got value,
because the system shows it rarely and the user can turn it off for every app.

## Find what the app does now

```bash
grep -rn "requestReview\|SKStoreReviewController\|AppStore.requestReview\|write-review" --include=*.swift .
```

For each call site, write what triggers it. Then check the rules below. No call site at all is a finding:
the app collects ratings only from people who go to the store on their own.

## Rules

Apple-documented:

- Use Apple's API only. App Review Guideline 5.6.1 says to use the provided API and that Apple will disallow
  custom review prompts. 5.6.3 forbids manipulating reviews.
  ([App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/))
- Use `@Environment(\.requestReview)` in SwiftUI or `AppStore.requestReview(in:)` with a window scene.
  `SKStoreReviewController` is deprecated since iOS 18 and its documentation points to `AppStore.requestReview(in:)`.
  ([RequestReviewAction](https://developer.apple.com/documentation/storekit/requestreviewaction),
  [AppStore.requestReview(in:)](https://developer.apple.com/documentation/storekit/appstore/requestreview(in:)-1q8qs),
  [SKStoreReviewController](https://developer.apple.com/documentation/storekit/skstorereviewcontroller))
- The system shows the prompt at most three times in 365 days for a person who has not rated the app, and it
  may show nothing. So never call it from a button: a "Rate" button that does nothing looks broken.
  ([RequestReviewAction](https://developer.apple.com/documentation/storekit/requestreviewaction))
- A persistent "Rate" row in Settings opens the product page with `action=write-review`:
  `https://apps.apple.com/app/id<APP_ID>?action=write-review`.
  ([RequestReviewAction](https://developer.apple.com/documentation/storekit/requestreviewaction))
- Ask after the person has shown engagement, never on first launch or during onboarding, and not in the
  middle of a task. Leave at least a week or two between requests.
  ([HIG: Ratings and reviews](https://developer.apple.com/design/human-interface-guidelines/ratings-and-reviews))
- Apple's sample asks only after a task has been completed several times, at most once per app version, and
  after a short pause on the completion screen.
  ([Requesting App Store reviews](https://developer.apple.com/documentation/storekit/requesting-app-store-reviews))
- In development builds the prompt always shows; in TestFlight it never does. Test the trigger logic, not
  the sheet. ([RequestReviewAction](https://developer.apple.com/documentation/storekit/requestreviewaction))
- Don't require a rating or review to use the app or any feature (Guideline 3.2.2(x)).

Not named by Apple, but follows from the rules above:

- A "Do you like the app?" question that sends only happy users to the prompt is a custom review prompt in
  front of the API and filters who gets to rate. Treat it as breaking 5.6.1 and 5.6.3.

Third-party, observed:

- RevenueCat reports apps rejected for asking for a rating during onboarding.
  ([RevenueCat](https://www.revenuecat.com/blog/engineering/dont-prompt-ratings-during-onboarding))

## The moment to ask

After a positive milestone: the core action has succeeded for the second time (or later), on the result
screen, after the result is visible. Never:

- on first launch, in onboarding, or after the very first core action;
- after an error, a failed save, a cancel or a discard;
- right after the paywall, a purchase failure or a restore;
- from a button tap.

The second success is the usual choice for a tracking or utility app, because it is the first time the app
can show something the first session could not (a change, a streak, a comparison). Choose the milestone from
the app's one job and say why in the audit.

## SwiftUI pattern

Keep the decision in the domain package, where it can have a test, and count successes from saved data
rather than a separate counter that can drift. Once per version keeps requests apart as long as versions ship
at least a week or two apart; if they ship faster, also store the date of the last request and wait.

```swift
import StoreKit
import SwiftUI

public struct ReviewPromptPolicy {
    /// The core action must have succeeded this many times before the first request.
    public static let completionsBeforeAsking = 2

    public static func shouldAsk(completedCount: Int, lastAskedVersion: String, currentVersion: String) -> Bool {
        completedCount >= completionsBeforeAsking && lastAskedVersion != currentVersion
    }
}

struct ResultView: View {
    /// Changes only when a new core action was saved, so the task runs once per success.
    let savedItemID: UUID
    /// Number of saved core actions, read from the store.
    let completedCount: Int

    @Environment(\.requestReview) private var requestReview
    @AppStorage("lastReviewRequestVersion") private var lastReviewRequestVersion = ""

    var body: some View {
        resultContent
            .task(id: savedItemID) {
                let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
                guard ReviewPromptPolicy.shouldAsk(completedCount: completedCount,
                                                   lastAskedVersion: lastReviewRequestVersion,
                                                   currentVersion: version) else { return }
                // Let the result land before the system sheet appears.
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                // Record first: the API has no callback and may show nothing, so "asked" is all the app can know.
                lastReviewRequestVersion = version
                requestReview()
            }
    }
}
```

The result view must not be the one shown after a cancel or an error, and must not open while a paywall is
on screen. If the app shows its paywall after a success, ask for the rating on a later success instead.
