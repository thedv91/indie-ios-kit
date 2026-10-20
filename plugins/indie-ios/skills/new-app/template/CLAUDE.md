# CLAUDE.md — <App Name>

iOS app that <one sentence: what it does, on-device or not>. App #<n> of a 5-app indie portfolio.
The working task list is `docs/ROADMAP.md`: pick the first unchecked item unless told otherwise, and tick it when CI is green.
Process from idea to App Store to marketing, and which skill runs at each step: the `ship-app` skill.

## Positioning (do not drift from this)
- Name: **<App Name>**. Store title `<Name: Keyword>` (30 chars), subtitle `<benefit>` (30 chars).
  No "free" in store metadata (Guideline 2.3.7). Before settling a name, search the US App Store for it;
  record a dropped name here with the date and the reason.
- Target keyword: `<keyword>`. Top competitor and its weakness: <who, what they limit or charge>.
- Free tier: <limits>, more generous than <competitor>.
- No ads, no tracking, no third-party SDKs<, no network calls>. <Everything on-device.>
- v1.0 does one job: <step → step → step>. Anything else goes to v1.1+.
- Design language: <palette, type, iconography>. No third-party characters or brand art in the icon or marketing.

## Repo layout
| Path | What |
| --- | --- |
| `project.yml` | XcodeGen spec, the source of truth. The `.xcodeproj` is generated and git-ignored. |
| `Packages/<Core>Kit` | All domain logic, shared by the app and any extension. Has unit tests. |
| `App/` | SwiftUI app (iOS 17+). Views, view models, services. |
| `<Extension>/` | <Widget / Share Extension / App Intents, if any> |
| `Scripts/` | `check-strings.py` checks translations (CI runs it). |
| `Marketing/Screenshots/` | App Store screenshots, 6.9". |
| `.github/workflows/ci.yml` | macOS / Xcode build + tests. |

## How to verify your work
On a Mac with Xcode, build and run locally (simulator), then let CI confirm. Cloud sessions run on Linux with no
Xcode or simulator: there the loop is CI only.

1. Commit on a branch and push.
2. Wait for the `CI` workflow (package tests + app build).
3. Read the result with `gh run list --branch <branch>` / `gh run view <id> --log-failed`.
4. Fix and push again until every job is green. Do not tick a ROADMAP item while CI is red.

Without local compilation, keep changes small per push and double-check API signatures. Prefer APIs available on
iOS 17. Swift language mode is 5 (`SWIFT_VERSION 5.0`, tools 5.10) unless this repo says otherwise.

## Keep the docs in sync (same commit as the code)
Every change that makes a doc wrong or incomplete updates that doc in the same commit. Docs are `docs/*`,
`README.md` and this file. Before committing, check the diff against this list:
- **`docs/ROADMAP.md`:** tick the item once CI is green. New or split tasks go under "Next" in the right order.
  Anything cut from v1.0 moves to "v1.1+" instead of being deleted.
- **New `docs/*.md` file:** link it from the README "Layout" block.
- **`README.md`:** update when setup steps, commands, tooling versions or the folder layout change.
- **`CLAUDE.md`:** update "Repo layout" when a top-level folder or target is added, "Placeholders" when one is
  replaced or a new one appears, and "Monetization" when product IDs or prices change.
- **Numbers and decisions:** a measured number goes into the matching `docs/` file with the date and the sample
  it came from, not only into the commit message.

Do not edit docs for changes that leave them accurate. Doc text is English.

## Hard rules
- **Domain logic lives only in `<Core>Kit`** and every rule there has a test in `Packages/<Core>Kit/Tests`.
- **Never delete or overwrite user data automatically.** Destructive actions go through the system API that shows
  its own confirmation, and only after the replacement is safely saved.
- **No private APIs or undocumented KVC.** If the only way to get a value is private, change the feature.
- **Privacy manifest:** adding a "required reason" API (file timestamps, disk space, system boot time,
  UserDefaults...) means updating every `PrivacyInfo.xcprivacy` in the repo. Prefer `URLResourceValues`
  over `FileManager.attributesOfItem`.
- **Strings:** English text is the key. In the same commit, add the translation to every `.lproj`
  (list in `docs/localization.md`) and run `python3 Scripts/check-strings.py`.
- **Numbers we advertise** (sizes, speed, savings) must be measured on a real sample set first.
- **Extensions have tight memory limits** (Share Extension ~120 MB, widgets ~30 MB). Stream from file URLs,
  never load whole media into memory.
- <App-specific rules: metadata to preserve, health or financial claims to avoid, data that must stay on-device.>

## Monetization (StoreKit 2, no RevenueCat)
- Product IDs in `App/Services/StoreService.swift`: `...pro.yearly` ($<price>/yr), `...pro.lifetime` ($<price>).
- Paywall shows price, period, Terms + Privacy links and Restore (App Review 3.1.2).
- `StoreService` writes the Pro flag to the App Group so extensions can read it.

## Portfolio note (Guideline 4.3 spam)
This account ships 5 different apps. Share only infrastructure code between them (StoreKit logic, build scripts).
Never reuse another app's UI, icon, onboarding, screen layout, screenshots or store copy.

## Skills
From the `indie-ios` plugin (marketplace `indie-ios-kit`), installed for this repo with
`claude plugin install indie-ios@indie-ios-kit --scope local`. Do not copy its skills into `.claude/skills/`.
`ship-app` decides which one runs when; where any skill conflicts with this file, this file wins.

| Phase | Skills | Source |
| --- | --- | --- |
| Idea | `brainstorming`, `customer-research`, `pricing`, `product-marketing`, `competitors`, `grilling` (global) | obra/superpowers, coreyhaines31/marketingskills |
| Build | `swiftui-pro`, `apple-design`, `tdd`, `code-review`, `verification-before-completion`, `paywalls` | twostraws/swiftui-agent-skill, dickwu/apple-design-skill, mattpocock/skills, obra/superpowers |
| Store | `aso`, `copywriting`, `asc-*` (cli-usage, metadata-sync, localize-metadata, shots-pipeline, signing-setup, xcode-build, testflight-orchestration, release-flow, submission-health), `app-store-preflight-skills`, `app-store-review` | rorkai/app-store-connect-cli-skills, truongduy2611/app-store-preflight-skills, safaiyeh/app-store-review-skill |
| Launch | `launch`, `directory-submissions`, `public-relations`, `asc-whats-new-writer` | coreyhaines31/marketingskills, rorkai/app-store-connect-cli-skills |
| Orchestration | `ship-app`, `new-app` | indie-ios-kit, shared across apps; reads app facts from this file |

## Placeholders the owner must replace
- `com.yourcompany` bundle prefix and `group.com.yourcompany.<app>` (project.yml)
- `DEVELOPMENT_TEAM` (project.yml)
- Privacy policy URL and support email in `App/Theme/AppLinks.swift` (policy text to host: `docs/privacy-policy.md`)
- App icon
