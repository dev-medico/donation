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
- Play Console (September 11, 2026, driven through the signed-in Chrome session): bundle `188 (1.5.13)` uploaded to a new Production release with en-US release notes, saved, and submitted for review as a full rollout to the existing 177 countries/regions. Publishing overview shows **Changes in review** while Google's quick checks run (the changes are sent for review automatically when the checks pass). The only warning was the pre-existing advertising-ID declaration advisory, which is not release-blocking.
- TestFlight: build `1.5.13 (188)` is in the internal group "Red Juniors" (5 testers) with status Testing, expiring in 90 days.
- App Store review: the store version `1.3.8` (build 168, submitted March 14, 2026) remains **Rejected** as of the March 16, 2026 review: 2.1(a) login returned to the login page on iPad Pro 11-inch (iPadOS 26.3.1); 2.3.8 marketplace name "Red Juniors" vs device name "Safe Blood"; 5.1.1(ix) the app handles health data and must be submitted from an Apple Developer Program account enrolled as an organization, not an individual. Build 188 already shows the display name "Red Juniors" and carries the post-login 401 race fix, but 5.1.1(ix) can only be resolved by enrolling/converting the developer account as an organization (or transferring the app to one).
- September 11, 2026: the store version was edited to `1.5.13`, build `168` was replaced with `188`, the App Review sign-in information was switched from the old phone-number login to the staff reviewer account (email login; credentials live only in App Store Connect), and the review notes were rewritten to describe the app and the login fix. The version now sits in **Prepare for Submission**. It was NOT resubmitted ("Update Review" not pressed) because the individual developer account still fails 5.1.1(ix).
- The 2.1(a) report was re-tested with the reviewer account on a freshly created iPad Pro 11-inch (M4) simulator running iPadOS 26.2 with the 1.5.13 simulator build (Maestro flow: launch with cleared state, sign in, watch 15 s): the dashboard stayed up and loaded live data; the login screen never returned.
- iOS archive: `build/ios/archive/Runner-1.5.13-188.xcarchive` (local, excluded from Git), built by `flutter build ipa --release` with automatic signing for team `V66GW9RJ44`; its Info.plist reports bundle ID `com.red.juniors`, marketing version `1.5.13`, build `188`; deep, strict code-signature verification passed.
- App Store Connect upload succeeded on September 10, 2026 (export options: method `app-store-connect`, destination `upload`). The export re-signed the app with the cloud-managed `Apple Distribution: Sithu Aung (V66GW9RJ44)` certificate; Xcode's distribution log records `UPLOAD SUCCEEDED with no errors`, `Uploaded package is processing`, and App Store Connect returned build `1.5.13 (188)` in `PROCESSING` state. This upload does not submit an App Store version for review.
- Known tool quirk: after a successful upload-only export, `flutter build ipa` crashes with `PathNotFoundException ... build/ios/ipa/` because no IPA folder is written for `destination upload`; the archive and upload had already completed (verified in `~/Library/../T/Runner_*.xcdistributionlogs`).

## Machine note

- The first bundle build failed because the disk filled up. Removed Xcode DerivedData (1.3 GB), the Gradle caches (11 GB) and daemon logs, and the project build directories before rebuilding.
