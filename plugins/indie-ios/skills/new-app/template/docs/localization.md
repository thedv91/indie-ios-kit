# Localization

## Languages

<App Name> ships in English (development language) plus:

| Code | Language |
| --- | --- |
| `vi` | Vietnamese |

The same codes are listed under `CFBundleLocalizations` in `project.yml`; keep the two in sync.
`ship-app` and `asc-localize-metadata` read the store languages from this table.

## Plurals

A string with a count (`%lld items`) needs English plural forms in `en.lproj/Localizable.stringsdict`.
