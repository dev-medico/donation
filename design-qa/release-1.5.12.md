# Red Juniors 1.5.12 release verification

## Production web and API

- Website: https://donation-coral-five.vercel.app
- Application-code revision: `44e8d004e48026768e0d12f8523836d83b652d4d` (subsequent commits contain QA artifacts and this report); production `version.json` confirms `1.5.12`, build `187`.
- Backend revision: `475e034ce6e158c26c420eb96b7451e514f47941`.
- Database backup created before the daily-worksheet migration; migration completed with no pending migrations.
- Authenticated September 2026 worksheet returned HTTP 200 with 30 days, server date, editable state, and numeric revision.
- Dashboard Special Events count matched the paginated list (200 records at verification).
- Unauthenticated worksheet access correctly returned 401.
- Kawkareik wards 1–7 and Hpa-An wards 1–9 are present in the deployed asset.
- On the deployed website, entering a Myanmar digit and navigating back displayed the unsaved-change confirmation. The test entry was discarded; no application records were created or updated.
- Mobile Special Events listing and full-screen entry form were visually verified. The empty form was canceled.

## Deployed viewport screenshots

These are local-only production-browser captures at 2x device pixel ratio. They are excluded from Git because live application data may be visible:

- `live-worksheet-320x568.png` — 320 × 568 CSS pixels.
- `live-special-events-390x844.png` — 390 × 844 CSS pixels.
- `live-special-event-form-320x568.png` — 320 × 568 CSS pixels.

The similarly named files without the `live-` prefix are controlled Flutter widget captures, not production screenshots.

## Native release

- Marketing version: `1.5.12`.
- Release build number: `187`.
- Build 186 was signed, validated and uploaded, but was not submitted for review.
- Play pre-review flagged a critical advisory in the unused native Firebase Auth dependency's transitive reCAPTCHA 18.1.2 SDK. The warning was not ignored.
- Build 187 removes the unused Firebase BoM/Auth declarations. Active login uses the existing backend API; all Firebase initialization/OTP code is inactive.
- Android build 187 completed successfully; package, signature and SDK validation passed.
- Android package: `com.red.juniors`; target SDK 36; bundle size 67,201,468 bytes.
- AAB SHA256: `ae304b01f9fc7a54cb6614a618fc9b24c71bed54c6014557479560296e4c3d64`.
- Firebase Auth and reCAPTCHA are absent from the AAB, its resolved dependency metadata, and `releaseRuntimeClasspath`.
- The unsubmitted Play release 186 was discarded; its bundle remains in the artifact library.
- Play production release `187 (1.5.12)` was submitted for a full rollout in the existing targeted countries. Automated quick checks completed, and Publishing overview confirms **Changes in review** with “Your changes are now in review.” The critical SDK issue did not recur. This is not a claim that the release is publicly available yet.
- The signed iOS archive completed successfully. Its application reports bundle ID `com.red.juniors`, marketing version `1.5.12`, and build `187`; deep, strict code-signature verification passed.
- Archive: `build/ios/archive/Runner-1.5.12-187.xcarchive` (local, excluded from Git).
- App Store Connect upload succeeded on September 6, 2026. Xcode reported `Uploaded package is processing`, `Upload succeeded`, `Uploaded Runner`, and `EXPORT SUCCEEDED`; the upload command exited 0. This upload does not submit an App Store version for review.
- App Store Connect's Red Juniors Build Uploads table independently shows version `1.5.12`, build `187`, with status **Processing**. App ID: `6469943412`.

## Tests

- Focused worksheet, Special Events and township tests passed.
- Backend worksheet and Special Events controller tests passed.
- Four viewport fixture tests and the package-versus-visible-version test passed.
- Web release build and Vercel deployment succeeded.

## Follow-up advisory

Play also reported an existing advertising-ID declaration/manifest mismatch. The advertising declaration was not changed by this release.
