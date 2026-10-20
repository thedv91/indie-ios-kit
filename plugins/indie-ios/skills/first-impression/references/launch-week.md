# Launch week on the App Store

What the store side of a 1.0 release looks like, and what is known about it. Each claim is labelled:

- **Apple-documented**: stated on an Apple page linked next to it.
- **Vendor-observed**: reported by an ASO vendor or developers. Apple does not confirm it; treat it as a likely
  pattern, not a rule, and never turn it into a number in the app's docs.

Links were checked on 2026-10-15. Apple changes these pages; re-open a link before quoting a number from it.

## What decides ranking

- **Apple-documented.** Search results depend on text relevance (title, subtitle, keywords, primary category)
  and user behaviour (downloads, ratings and reviews, and more).
  ([App Store search](https://developer.apple.com/app-store/search/))
- **Vendor-observed.** A new app gets a temporary search boost for about its first seven days, then settles
  where its own numbers put it. The best-known write-up is old (Sensor Tower, 2014) and Apple has never
  documented a launch boost; plan for the week anyway, because outside traffic is cheapest to concentrate there.
  ([Sensor Tower](https://sensortower.com/blog/why-app-store-keyword-rankings-drop-dramatically-seven-days-after-launch))
- **Vendor-observed.** After that, post-install signals weigh more than keywords: product-page conversion,
  day 1, 7 and 30 retention, rating count and recency, and crash rate.
  ([AppRadar, 2026](https://appradar.com/academy/app-store-ranking-factors))

What follows for the plan: put every outside push (posts, directories, press) into launch week, and make sure
the people who arrive that week finish the first session, come back, and are asked for a rating at a good
moment (`rating-prompt.md`).

## Before release

### Featuring nomination
- **Apple-documented.** App Store Connect › the app › Featuring › Nominations. "App Launch" is the type for the
  launch or pre-order of a new app. The help page recommends at least three weeks of lead time; the
  "Getting featured" page says at least two weeks and up to three months for wider consideration. Use three
  weeks or more.
  ([Nominate your app](https://developer.apple.com/help/app-store-connect/manage-featuring-nominations/nominate-your-app-for-featuring),
  [Getting featured](https://developer.apple.com/app-store/getting-featured/))
- What to name in it comes from the app's product doc: what the app does, what is new about it, languages,
  privacy stance, and any new Apple technology it uses. Don't invent selling points.

### Pre-order
- **Apple-documented.** A brand-new app's release day can be 2 to 180 days after the pre-order is published.
  On release day it downloads automatically to the devices of people who ordered it, and they get a
  notification. App Analytics shows the downloads that came from pre-orders.
  ([Pre-orders](https://developer.apple.com/app-store/pre-orders/),
  [App Analytics](https://developer.apple.com/app-store-connect/analytics/))
- **Apple-documented.** The pre-order is set up under Pricing and Availability with its release date, then the
  version is submitted for review. After approval, "Release This Version" publishes the pre-order, not the
  app; the app goes live on the pre-order's release date.
  ([Publish for pre-order](https://developer.apple.com/help/app-store-connect/manage-your-apps-availability/publish-for-pre-order/))
- Not documented: whether pre-order downloads count toward ranking on release day. A one to two week
  pre-order is a planning choice to give launch posts a store page to point at, not a ranking guarantee.

### Manual release
- **Apple-documented.** In the version's "App Store Version Release" section, choose "Manually release this
  version", then release it yourself after approval.
  ([Release options](https://developer.apple.com/help/app-store-connect/manage-your-apps-availability/select-an-app-store-version-release-option))
- Without a pre-order, release by hand on the planned day, so the featuring date, the posts and release day
  line up. With a pre-order, the manual release is the day the pre-order opens, and release day is the date set
  on the pre-order.
- **Apple-documented.** Phased release spreads an *update* over seven days; it is not used for a first
  release. ([Phased release](https://developer.apple.com/help/app-store-connect/update-your-app/release-a-version-update-in-phases))

### TestFlight with outside testers
- **Apple-documented.** External testers need a beta app description and beta review information, and the
  build goes through beta review before they get it.
  ([TestFlight](https://developer.apple.com/testflight/))
- Run about a week with people outside the team on several iPhone sizes, to catch crashes and confusing steps
  before they cost ratings. Ask them to walk the first session cold, with no explanation.
- The review prompt never shows in TestFlight builds, so it cannot be tested there
  ([RequestReviewAction](https://developer.apple.com/documentation/storekit/requestreviewaction)).
- After release, testers can be asked to rate the app if they want to. Don't require it or reward it:
  Guideline 3.2.2(x) forbids requiring a rating, and 5.6.3 forbids manipulating reviews.
  ([App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/))

### Conversion assets
- **Apple-documented.** If the app ships in several languages, localize the description, keywords, previews
  and screenshots for each market.
  ([Creating your product page](https://developer.apple.com/app-store/product-page/))
- Check that screenshot captions are localized, not only the listing text; a translated listing with English
  captions reads as unfinished.

## Reading the results without third-party SDKs

- **Apple-documented.** App Store Connect › Analytics reports impressions, conversion rate,
  sources, sessions, retention and crashes. Usage data (sessions, retention) covers only people who agreed to
  share diagnostics and usage with developers, so treat those numbers as a sample.
  ([App Analytics](https://developer.apple.com/app-store-connect/analytics/),
  [WWDC25: Optimize your monetization with App Analytics](https://developer.apple.com/videos/play/wwdc2025/252/))
- The `asc` CLI can pull the same reports; see the `asc-*` skills.
- Read in launch week: conversion rate by source (did the posts convert?), crashes, and day 1 retention once
  it fills in. After two weeks, run `aso` on the live listing.

## The plan in the audit

Write it for this app, with dates relative to the planned release day (R):

| When | Step |
| --- | --- |
| R − 4 weeks or earlier | TestFlight with outside testers |
| R − 3 weeks or earlier | Featuring nomination (App Launch) |
| R − 2 to R − 1 weeks | Version approved; "Release This Version" publishes the pre-order; launch posts point at the store page |
| R | The app goes live (on the pre-order date, or by manual release if there is no pre-order); outside push concentrated in this week |
| R + 1 to R + 14 days | Read Analytics; reply to early reviews; fix crashes first |
