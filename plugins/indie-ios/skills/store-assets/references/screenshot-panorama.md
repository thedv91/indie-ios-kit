# Screenshot set as a panorama

A way to make a store screenshot set that reads as one picture. The idea is optional; the capture and upload
rules below apply to any set. The look is the app's own: colours, type and background come from its `CLAUDE.md`.

## Capture

- Capture on the simulator at the device's own pixel size, so nothing is rescaled. The 6.9-inch iPhone is
  1320 x 2868; App Store Connect scales that set down for smaller iPhones. Check each file's size and stop on a
  mismatch.
- Freeze the status bar at 9:41 with `xcrun simctl status_bar booted override --time 9:41` and clear it afterwards.
- Seed demo data from a Debug-only launch argument that is compiled out of Release, and open each screen from
  another Debug-only argument. A fresh install per run keeps a "back to previous app" button out of the first shot.
- Wait about three seconds after launch for entrance animations and sheets to settle.
- Dark screenshots come from an in-app appearance override, not from the simulator's setting.

## Compose

- Paint one wide strip, `slice width x number of slices`, then crop it into slices. Backgrounds, a ruler or a
  line running across the seams make the slices read as one picture when the store shows them side by side.
- The store leaves a gap between slices. Keep phones, captions and anything a viewer must read inside one slice;
  only decoration may cross a seam. A flip such as light to dark mode belongs exactly on a seam.
- One headline per slice, two balanced lines, and a width check that stops the script when a translation is too
  wide, rather than shrinking the type silently.
- Captions follow the app's banned-claims list. Do not state counts the free plan does not meet.
- File names sort in store order (`01-name.png`, `02-name.png`), because `asc` uploads in name order.
- Put a review preview (the strip at quarter size) outside the upload folder. `asc screenshots upload` uploads
  every image in the folder it is given.

## Validate and upload

```bash
asc screenshots validate --path path/to/en-US --device-type IPHONE_69
asc screenshots upload --app "APP_ID" --version "VERSION" --locale "en-US" --path path/to/en-US \
  --device-type IPHONE_69 --replace --dry-run
```

`--replace` deletes the existing set first, so show the owner the dry-run output and get a yes before the
`--confirm` run. For a new device, list the valid device types with `asc screenshots sizes --all`.

## Locales

Each store language needs its own captions and its own folder (`store/<locale>/`). Render them from the same
script with a caption table per locale, and check the longest languages (German, Russian) and the ones without
spaces (Japanese, Chinese) before uploading.
