# Red Juniors 1.5.13 release verification

## What shipped

- Report page on phones: the blood-group and hospital tables share one aligned label / count / % card that sizes to its rows (nothing cut off, 20px gap between cards); the age chart header wraps, its legend sits under the donut, slice labels show %.
- Donor availability dialog: the switch-off label reads "မလှူဒါန်းနိုင်ပါ".
- Design reference: https://claude.ai/code/artifact/61255510-b61a-4564-ab6a-63b628f9c87c

## Production web

- Website: https://donation-coral-five.vercel.app
- Application-code revision: `760b251` (Release 1.5.13). Vercel deployment `8DqpXpQZWaavVB56FKLHm69nzgdp` completed; production `version.json` confirms `1.5.13`, build `188`.
- No backend changes in this release.

## Tests

- Full suite: 106 tests passed before the release commit, including the new `report_mobile_viewport_test.dart` (320×568 and 390×844 fixtures: no overflow, every hospital row present, counts aligned under their header, all legend entries on screen) and the package-versus-visible-version test.
- `report-320x568-before.png` / `report-390x844-before.png` and the same names without `-before` are controlled Flutter widget captures (fixture data, MyanUni font), not production screenshots.

## Native release

- Marketing version: `1.5.13`.
- Release build number: `188`.
- Android bundle: `build/app/outputs/bundle/release/app-release.aab`, 67,230,089 bytes, signed by `CN=Medico` (the upload key); manifest carries `com.red.juniors` and version name `1.5.13`.
- AAB SHA256: `20172e8d414ac3963a4827e55ef90f8a8c196aec64c86dd46c6c03dd4bafd8a8`.
- A copy was placed at `~/Downloads/red-juniors-1.5.13-188.aab` for the Play Console upload.
- Play Console: NOT uploaded by automation — no Play Developer API credentials or browser session exist on this machine. Upload the bundle to the production track manually and submit for review.
- iOS archive: `build/ios/archive/Runner-1.5.13-188.xcarchive` (local, excluded from Git), built by `flutter build ipa --release` with automatic signing for team `V66GW9RJ44`; its Info.plist reports bundle ID `com.red.juniors`, marketing version `1.5.13`, build `188`; deep, strict code-signature verification passed.
- App Store Connect upload succeeded on September 10, 2026 (export options: method `app-store-connect`, destination `upload`). The export re-signed the app with the cloud-managed `Apple Distribution: Sithu Aung (V66GW9RJ44)` certificate; Xcode's distribution log records `UPLOAD SUCCEEDED with no errors`, `Uploaded package is processing`, and App Store Connect returned build `1.5.13 (188)` in `PROCESSING` state. This upload does not submit an App Store version for review.
- Known tool quirk: after a successful upload-only export, `flutter build ipa` crashes with `PathNotFoundException ... build/ios/ipa/` because no IPA folder is written for `destination upload`; the archive and upload had already completed (verified in `~/Library/../T/Runner_*.xcdistributionlogs`).

## Machine note

- The first bundle build failed because the disk filled up. Removed Xcode DerivedData (1.3 GB), the Gradle caches (11 GB) and daemon logs, and the project build directories before rebuilding.
