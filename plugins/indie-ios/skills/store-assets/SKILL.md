---
name: store-assets
description: "Make and upload the App Store product-page creative assets for an indie iOS app: the header image, the search-result image, and screenshots for a new device such as iPhone Duo. Covers the specs, the safe area both crops share, checking the image, uploading to the Asset Library with asc, assigning it to a localization, and the review path. Use when the user asks for a product-page header, a search-result image, creative assets, the Asset Library, iPhone Duo screenshots, or when ship-app reaches the listing assets step."
---

# Store creative assets

This skill covers the images around the listing that `asc metadata` does not: the product-page header, the
App Store search-result image, and screenshots for a device the set does not cover yet. The look of every image
comes from the app's own `CLAUDE.md` (palette, type, motif). Nothing in this skill draws an app's look, and no
image or script from another portfolio app may be copied in (Guideline 4.3).

Header and search-result images show on iOS 27 and later only. Older systems keep showing the screenshots.

## 1. Read the facts

- The app ID and the version in App Store Connect: `asc apps list`, `asc versions list --app "APP_ID"`.
- The design language and the claims the app must never make: the app's `CLAUDE.md`.
- The screenshots doc linked from the README, if there is one, for sizes the app already uses.
- The current sizes: `asc asset-library specs --output json --pretty`. Apple changes these, so read them every
  time; `scripts/check_asset.py` carries a copy that can be out of date.

## 2. Design the image

One 16:9 PNG at 5244 x 2950 fills both slots, which is the simplest choice. The store crops it, so the content
has to survive both crops:

| Slot | Shown as | Crop of the 16:9 image |
| --- | --- | --- |
| Product-page header | 21:9 (3840 x 1646 when uploaded alone) | the middle 5244 x 2247 |
| Search result | 3:2 (1920 x 1280 to 3840 x 2560 when uploaded alone) | the middle 4425 x 2950 |

Keep the name, the tagline and the subject inside the middle 4425 x 2247 px (x 409 to 4835, y 351 to 2599).
Edge-to-edge decoration may run outside it. Rules for the image:

- No alpha channel, PNG or JPEG. Flatten onto a solid background.
- Big type and few words: the search result shows it small. One name, one line of tagline.
- Make it match the screenshots and the icon, so the page reads as one set.
- No claim the app's `CLAUDE.md` bans, and no invented ratings, awards or user counts.
- English text only gets assigned to the English localization (step 5).

A video (5 to 30 seconds, 30 or 60 fps, looping) is also accepted, in 21:9 for the header and 3:2 for search.
Check `asc asset-library specs` before making one; video upload needs `ffprobe`.

Write the drawing as a script in the app repo (`Tools/render_header.py`, say), so a palette change re-renders it,
and never edit the PNG by hand.

## 3. Check it

```bash
python3 <skill dir>/scripts/check_asset.py path/to/header.png --out "$TMPDIR/header-check"
```

It fails on a wrong size, an alpha channel or an unsupported format, and writes a preview of each crop. Open
both previews with the Read tool and check that nothing important is cut. Send the full image to the owner
with SendUserFile and wait for a verdict before uploading.

## 4. Upload (ask first)

Uploading changes the listing draft in App Store Connect. Name the app, the version and the locale and get a
yes. The Asset Library ID is the app ID.

```bash
asc asset-library images list --library-id "APP_ID" --output table
asc asset-library images upload --library-id "APP_ID" --file path/to/header.png --output json
```

Read the list first so an existing image is not uploaded twice. Keep the `imageId` from the result; if the upload
times out, `asc asset-library images view --id "IMAGE_ID"` tells whether processing still goes on.

## 5. Assign it to a localization

Use the version localization ID, not the version ID. List them with `asc localizations list --version "VERSION_ID"`.
List its placements first: a create does not remove an existing one.

```bash
asc localizations placements list --localization-id "LOC_ID" --include image --paginate --output table
asc localizations placements create --localization-id "LOC_ID" --image-id "IMAGE_ID" \
  --placement-type PRODUCT_PAGE_HEADER_ASSET --placement-group DEFAULT_PROFILE
asc localizations placements create --localization-id "LOC_ID" --image-id "IMAGE_ID" \
  --placement-type APP_STORE_SEARCH_RESULTS_ASSET --placement-group DEFAULT_PROFILE
```

Then read the placements back and check that both rows show `ACTIVE`. Each slot holds one asset per
localization. An image with text in one language goes to that language's localization only.

## 6. Review and publish

An upload and an `ACTIVE` placement are not App Review approval. For the first version, the assets go with that
version's submission (`asc-release-flow`, multi-item submissions). Later, an asset can be reviewed on its own once
an approved version exists (`asc-metadata-sync`, Asset Library workflows). Never attach an asset that is already in
an active submission to a second one.

## New device screenshots (iPhone Duo and later)

When Apple adds a device, App Store Connect asks for screenshots in its size from a cut-off month. Take the
size and the placement group from `asc asset-library specs` (iPhone Duo uses `IPHONE_DUO_PROFILE`), not from a
blog. Capture on the simulator for that device, do not scale an existing set, and follow
`references/screenshot-panorama.md` for how to compose and upload. Whether an update to an app that is already live
needs the new set is unclear in Apple's notice; say so to the owner instead of assuming.

## Ask before

Uploading to the Asset Library, creating or swapping placements, and submitting for review each change the
listing. Dry runs and reads are free.
