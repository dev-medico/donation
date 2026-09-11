# Red Juniors 1.5.14 release verification

## What shipped

- Phone home dashboard now shows the report sections that only the desktop home had: members by age (chart + legend), donations by blood group, and donations by hospital, below the request/give chart and the disease pie (commit `ae941c7`).
- Everything from 1.5.13 (aligned report tables on phones, availability wording).

## Production web

- Website: https://donation-coral-five.vercel.app
- Application-code revision: `75d04c5` (Release 1.5.14). Vercel reported the deployment as successful on September 11, 2026; the phone-width web app now shows the report sections on its home dashboard.
- No backend changes in this release.

## Tests

- `report_mobile_viewport_test.dart` now also renders the phone dashboard at 390×844 with fixture data and checks that all three sections are present, aligned, and free of overflow; `design-qa/dashboard-390x844.png` is the controlled capture.
- Known failing test unrelated to this release: `facebook_post_screen_mobile_test.dart` "refresh cannot overwrite a save that is still in flight" fails since the morning of September 11 (tap lands off-screen) although it passed on September 10 evening with the same screen code; it needs its own investigation.

## Native release

- Marketing version: `1.5.14`.
- Release build number: `189`.
- Play release `188 (1.5.13)` had already passed review and was live on the Production track (7 installs) before this release was created.
- Android bundle: `build/app/outputs/bundle/release/app-release.aab`, 67,230,056 bytes, signed by `CN=Medico`; manifest carries version name `1.5.14`. Copy at `~/Downloads/red-juniors-1.5.14-189.aab`.
- AAB SHA256: `7f214cd965d050f1e055e5aa269408967b79217876e67065534a739454551dbb`.
- Play Console (September 11, 2026, driven through the signed-in Chrome session): bundle `189 (1.5.14)` uploaded to Production release 44 with en-US release notes, saved, and submitted for review as a full rollout to the existing 177 countries/regions. Publishing overview shows **Changes in review** while the quick checks run; the changes are sent for review automatically when they pass. Same non-blocking advertising-ID advisory as before.
- iOS archive: `build/ios/archive/Runner-1.5.14-189.xcarchive` (local, excluded from Git), built by `flutter build ipa --release` with automatic signing for team `V66GW9RJ44`; Info.plist reports marketing version `1.5.14`, build `189`.
- App Store Connect upload succeeded on September 11, 2026 at 10:11 (+07:00): Xcode's distribution log records `UPLOAD SUCCEEDED with no errors` and `Uploaded package is processing`; App Store Connect registered build `1.5.14 (189)` in `PROCESSING` state. TestFlight auto-distributes it to the internal group "Red Juniors" once processing completes. The App Store version (in Prepare for Submission with build 188) still needs its build switched to 189 and its version set to 1.5.14; that requires an App Store Connect sign-in and the processed build.

## Machine note

- This Mac has 8 GB of RAM. The first 189 bundle build was killed by the tool session's low-memory guard. Gradle is now capped through `~/.gradle/gradle.properties` (`-Xmx2560m`, Kotlin daemon 1 GB, no parallel builds, 2 workers, with the same JDK module flags as `android/gradle.properties`, which the user-level file overrides), and long builds are run detached with `nohup` and polled from a log.
