# Red Juniors 1.5.15 release verification

## What shipped

- Honour roll in bands, as the group asked: 10–19, 20–29, 30–39 and 40–49 donations, plus 50+ once anyone reaches it (6 donors on 2026-09-26, the highest at 57). One request loads every band; each tab shows how many donors it holds. Donors rank within their band, ties sharing a place, and every row shows how the total is made up (ယခင် previous + အဖွဲ့နှင့် with the group).
- Everything from 1.5.14.

## Backend (live since 2026-09-26, reaches every app version)

- `8a67020` A donation recorded today counts as the donor's last donation today. Since 2026-09-20 the find-donor search and smart search had treated every same-day donation as a future one until midnight, so a donor who had just given still showed as able to donate (A-0221, entered 10:49, still listed at 13:48).
- `0831c6a` The lifetime total is previous donations plus recorded ones again on every endpoint (member list, member detail, find donor, smart search, honour roll). Since 2026-09-20 it had been the recorded donations alone, so E-0564 (3 previous + 1) showed 1. `member/honorable-donors` now takes `min` as inclusive, returns the breakdown, and sends only the fields the honour roll shows (211 kB instead of 1.2 MB for 858 donors).
- `abc70a7` + `php yii member-count/restore-previous --apply=1`: 2,836 donors imported from the old app in November 2024 still held the old app's in-app donation count in the "previous donations" field, which doubled their totals. It now holds the old app's own previous count (its total minus its in-app count). Staff-edited donors (317), donors registered since the import (1,111) and eight reissued card numbers were left alone. Old values are in the `member_count_fix_20260926` table; `php yii member-count/revert-previous` undoes it, and `/root/backups-donation/member_before_count_fix_20260926.sql` is a copy of the member table from just before.

## Checks

- Production, 2026-09-26 after the deploy: E-0564 total 4, A-0221 total 15 with last donation 2026-09-26 (waiting until 2027-01-26), O+ 2026 counts 134 able / 359 to check (135 / 358 before), honour roll 628 / 167 / 47 / 10 / 6.
- `test/honour_roll_test.dart`: bands, tie ranks, breakdown parsing, and the screen at 390×844 and 320×568 with no overflow; captures in `design-qa/honour-roll-*.png` (made-up donors).
- Backend `tests/unit/models/MemberTest.php` covers reading the previous count (Burmese digits, junk). The 10 `RequestGiveControllerTest` errors predate this release.

## Production web

- Website: https://donation-coral-five.vercel.app
- Application-code revision: `2a2368e` (Release 1.5.15). Vercel reported the deployment as successful on September 26, 2026; the live bundle carries version `1.5.15` and the banded honour roll.

## Native release

- Marketing version: `1.5.15`; build number: `190`.
- iOS archive: `build/ios/archive/Runner.xcarchive` (local, excluded from Git), built by `flutter build ipa --release` with automatic signing for team `V66GW9RJ44` and an upload-only export (`manageAppVersionAndBuildNumber` off, so the build keeps number 190).
- App Store Connect upload succeeded on September 26, 2026 at 16:08:59 (+07:00): Xcode's distribution log records `UPLOAD SUCCEEDED with no errors` and `Uploaded package is processing`, delivery UUID `209c8f24-f29d-4fa5-91f3-6373335af8e7`. TestFlight distributes it to the internal group "Red Juniors" once processing completes. Flutter then exited with its usual `PathNotFoundException` for `build/ios/ipa/`, which an upload-only export never creates.
- Android bundle: `build/app/outputs/bundle/release/app-release.aab`, 67,814,299 bytes, signed by `CN=Medico`; manifest carries versionCode `190`, versionName `1.5.15`, package `com.red.juniors`. Copy at `~/Downloads/red-juniors-1.5.15-190.aab`.
- AAB SHA256: `a9528d4401bddec6cb15e4bd044b41752928b2fe8c15333d536a9466fe2ec9b6`.
- Play Console (September 26, 2026, driven through the signed-in Chrome session of the "Sithu (STA 01)" profile, whose account has release access to the Medico developer account): bundle `190 (1.5.15)` uploaded to Production release 45 with en-US release notes, saved, and sent for review as a full rollout. Publishing overview shows **Changes in review** while the quick checks run (up to 14 minutes); managed publishing is off, so it goes live once approved. Same non-blocking advertising-ID advisory as before.
- Build note: the project's Gradle 8.14.2 was not cached, so the bundle build downloaded it and filled the disk to 747 MB free; the unused 8.11.1 and 8.12 Gradle caches (other projects) were deleted mid-build to finish it.

## Open for the group

- Card numbers B-0801 and D-0266 are each held by two donors. Until one of each pair is renumbered, `php yii migrate` stops at `m260920_000001` (the unique card-number index).
