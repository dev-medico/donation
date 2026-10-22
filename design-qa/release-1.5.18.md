# Red Juniors 1.5.18 release verification

## What changed

- Facebook post: donor names go into the post exactly as entered, including the alias after `(ခ)`. The generator used to keep only the part before `(ခ)`, so a donor recorded as `Name(ခ)Nickname` appeared as `Name`, and donors who share a primary name (three ledger members share one) read identically.
- Find blood donors (`သွေးလှူရှင်ရှာမည်`): `search-member/index` orders by the effective last donation date, newest first (later entries first within a day), then member ID; members who never donated come last. The order is decided by the server, so every installed app version shows it already.
- Build: Android pins the shared NDK `30.0.16248370` for the app and every plugin subproject; AGP `8.9.1` → `8.11.1` and Kotlin `2.1.0` → `2.2.20`, the minimums of Flutter 3.47.6. iOS `Info.plist` declares `ITSAppUsesNonExemptEncryption = false`. Flutter 3.47.6 `pub get` updated the lockfile's SDK-pinned test packages and added analyzer excludes.

## Verification

- Full Flutter suite: 148 tests passed. The old `drops the (ခ) alias` test was replaced by `keeps the (ခ) alias of every donor` (the ledger fixture plus two fictional alias donors joined as `A နဲ့ B တို့က`). Targeted analyzer on the changed files: no issues.
- Backend suite: 81 tests, 516 assertions passed, including five new `SearchMemberControllerTest` cases: newest first, same-day entry order, member-ID ties, never-donated last, and paging under an availability filter.
- Production order check after deployment (read-only; the deployed controller run as `www-data`): all 4,591 members across 19 pages of 250, 4,591 unique, zero out-of-order dates, never-donated members at the end. The first rows were the donations entered on October 21, 2026 (20:47, 20:47, 19:44, …); with the green filter the list starts at donors last seen on June 22, 2026, just past the four-month wait. The public endpoint still answers 401 without a token.

## Backend deployment

- Live revision: `069fd0c7b3e88945a65ecd4c8c4bbd9a3b64903d`, October 22, 2026, by `git pull --ff-only`. No migrations or Composer changes. Backend rollback revision: `40a7eb3b458bd622bace930e03acdb1572989d4e`.
- The same morning the server's PHP was upgraded from 8.3.29 to 8.3.36 for CVE-2026-109618/109619 (PHP2Shell); this backend and the other PHP apps on the VPS answered as before.

## Web deployment

- Source revisions `0ed017f` (release) and `18a3dba` (Android build settings, same web code). Vercel deployments `8Y3uxbHttfQcPdWGkUnzHqhXG9cC` and `5mkzWMwEuswFFUhJAhVnnCV24qhj` succeeded.
- Public `https://donation-coral-five.vercel.app/version.json` reports `1.5.18` / `193`.

## Release packaging

Marketing version `1.5.18`, build `193`, package/bundle ID `com.red.juniors`, built with Flutter 3.47.6 from `18a3dba`. Upload records: `outputs/play-upload-2026-10-22-1.5.18/`.

### Android

- Bundle: `/Users/sithuaung/Downloads/red-juniors-1.5.18-193.aab`, 68,415,536 bytes; SHA-256 `bc9df2dc962fd5f9483de70e74fde1a6eaa9998559c771fb35b57c950cb19499`.
- Bundletool validation passed: version name `1.5.18`, version code `193`, min SDK 24, target SDK 36, all three ABIs, native debug symbols and R8 mapping. JAR signature verified; signer SHA-256 `E5:51:83:B0:7F:63:4D:24:A1:3A:09:72:20:7C:6C:0B:01:E8:28:CD:DC:C9:0C:5C:95:02:F2:AF:31:A5:0D:5D` matches the prior release. NDK `30.0.16248370` is still the only NDK installed after the build.
- The first two attempts stopped at Flutter's dependency check (AGP 8.9.1, then Kotlin 2.1.0, both below Flutter 3.47.6's minimums); the third succeeded.
- Google Play Developer API (service account, no console): Google read version code 193 with the same SHA-256; the production release was committed at 100% rollout with en-US notes and sent for Google review. `play tracks` shows production `193 "1.5.18"`. Submitted, not yet confirmed live.

### iOS

- IPA: `/Users/sithuaung/Downloads/red-juniors-1.5.18-193.ipa`, 28,026,339 bytes; SHA-256 `0454148aad0fe3de44acd66d1015edd6b37a9b04d1d68ddd5fbb49e1c48a9f60`. Bundle `com.red.juniors`, version `1.5.18` (193), display name Red Juniors, `ITSAppUsesNonExemptEncryption` false. Deep strict code-signature check passed; signed by `Apple Distribution: Sithu Aung (V66GW9RJ44)`, `get-task-allow` false.
- `xcrun altool` upload with the App Store Connect API key: UPLOAD SUCCEEDED, delivery UUID `f43f1dc6-bd52-4fe3-a1e3-58e4366e2414`.
- Processing: build `193` (`f43f1dc6-bd52-4fe3-a1e3-58e4366e2414`) is `VALID`; `usesNonExemptEncryption` came through as false from `Info.plist`, so no manual export-compliance answer was needed. Internal state `IN_BETA_TESTING`; the internal group "Red Juniors" (access to all builds) lists 193. What to Test was set in English only: App Store Connect rejects Myanmar script in that field, unlike the Play release notes.
- App Review: not submitted. The only store version (1.5.13) is still Rejected, with an `UNRESOLVED_ISSUES` submission from September 11, 2026; guideline 5.1.1(ix) requires an organization developer account (see `release-1.5.13.md`). Builds stay in TestFlight until that changes.
