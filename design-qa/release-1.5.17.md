# Red Juniors 1.5.17 release verification

## What changed

The daily worksheet counts donations directly from blood donation records by donation date for every month, including historical months. Staff enter requests only. Saved manual donation figures are never used as a fallback, including when the actual count is zero. Donation counts open the corresponding day's records; refresh preserves unsaved requests and their original conflict revision. Donation changes refresh monthly reports and charts. Zero automatic donations do not mark a day's requests as entered.

Historical manual request totals remain intact. Months with only a monthly request summary show actual daily donations while keeping the unknown daily request breakdown blank and read-only.

## Verification

- Full Flutter suite: 147 tests passed. After the all-month change, all 8 targeted worksheet, report refresh and version tests passed.
- Backend suite: 69 tests, 499 assertions passed, including historical zero counts, live backdated additions/deletions, request preservation, reader agreement, month boundaries and request revision conflicts.
- Phone worksheet verified at 390x844 and 320x568 with the application font; fictional-data captures in `automatic-donations-*.png`.
- Targeted analyzer: no errors or warnings; four pre-existing deprecation infos in report UI/service files.

## Backend deployment

- Live revision: `49b22fb179ae5683cd7ba48b21406e639e167992`, October 2, 2026.
- Authenticated public HTTPS and localhost endpoints agree with PostgreSQL across 58 months: actual donations 15,681 and preserved requests 8,177 at verification time. Worksheet, monthly/yearly report, chart, index and legacy reads agree.
- September: 236 donations, September 25: 8 and September 27: 6. Historical August 2023: 209 actual donations, with 408 requests preserved. Donation-only January 2025: 344; empty January 2021: zero.
- No new migrations or production test writes. Backend rollback revision: `9e7e3b54520d077947944d4c4f2bbeeea1995342`.

## Web deployment

- Source revision: `937b879a83b50a5cc51911d02523e6507d888ec5`.
- Vercel deployment `9ozSxvLdqYVf415HPnEKYqjquVpG` succeeded at 2026-10-02 08:20:20 UTC.
- Public `https://donation-coral-five.vercel.app/version.json` reports `1.5.17` / `192`.
- Served `main.dart.js` includes the new historical-month banner and omits the old reconciliation component. Normal and cache-busted URLs match: 5,542,032 bytes, SHA-256 `f2f4d1398ad87cd2930fa134a9022c4aa38ac9fa8b29e513e57a7cdcae89ee87`.

## Release packaging

Marketing version `1.5.17`, build `192`, package/bundle ID `com.red.juniors`.

### iOS

- Xcode archive succeeded; archive metadata and code signature verified. Saved to `/Users/sithuaung/Library/Developer/Xcode/Archives/2026-10-02/Red Juniors 1.5.17 (192).xcarchive`.
- App Store Connect upload succeeded with no errors at 15:36:16 Bangkok time. Delivery UUID: `301d1561-bc2a-4d72-b562-dc005aa07651`. Browser confirms version 1.5.17 build 192 processing.
- IPA: `/Users/sithuaung/Downloads/red-juniors-1.5.17-192.ipa`, 27,999,762 bytes; SHA-256 `bdbaadc8001df5dcf4b79a6220894c8ba6e96731a811d5fc7ef82d8e36a9a582`.
- Flutter reported a post-upload local directory-listing exception because upload-only export creates no `build/ios/ipa` directory. Xcode delivery logs and App Store Connect independently confirm successful upload; no duplicate upload was attempted.
- Encryption declaration completed after reviewing app dependencies/source (no custom encryption implementations). Build status: Ready to Submit. Build details confirm Group (1): Red Juniors, Internal, 5 testers. What to Test notes cover historical/current actual counts, preserved requests, day drill-down, donation mutations and unsaved request drafts.

### Android

- Bundle: `/Users/sithuaung/Downloads/red-juniors-1.5.17-192.aab`, 67,859,397 bytes; SHA-256 `d0ed0fd252d29038f44b486a08a9ea9e86cc480f46c0c3815a067db13b06fbbc`.
- Bundletool validation passed. Package `com.red.juniors`, version name `1.5.17`, version code `192`; JAR signature verified and certificate matches the prior release.
- Signer SHA-256: `E5:51:83:B0:7F:63:4D:24:A1:3A:09:72:20:7C:6C:0B:01:E8:28:CD:DC:C9:0C:5C:95:02:F2:AF:31:A5:0D:5D`.
- First build completed compilation/optimization but failed at bundle packaging under disk pressure. Removed only generated task intermediates and unused task-downloaded Gradle files; cached retry succeeded in 57 seconds. Original and retry logs are preserved in `/tmp/red-juniors-android-192-first-attempt.log` and `/tmp/red-juniors-android-192.log`.
- Google Play accepted version 192 (1.5.17), API 24+, target SDK 36, all three ABIs, with ReTrace mapping and native debug symbols. Supported-device counts are unchanged. Production rollout is 100% in all currently targeted countries.
- Corrected the pre-existing Advertising ID declaration from Yes to No after inspecting the actual bundle manifest, both DEX files, R8 output and declared dependencies: no AD_ID permission or advertising/analytics SDK is present. This resolves the release's sole validation warning without adding an unused permission.
- Submission confirmed in Play Console: **Changes in review**, Production `192 (1.5.17)`, **Start full rollout**. Automated quick checks are still running; Google will send it for review after they pass. Managed publishing remains off, so publication follows approval. This is submitted, not yet confirmed live on Google Play.
- Local console evidence: `/Users/sithuaung/Downloads/red-juniors-play-1.5.17-192.png` and `/Users/sithuaung/Downloads/red-juniors-testflight-1.5.17-192.png`.
