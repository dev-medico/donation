# Red Juniors 1.5.16 release verification

## What shipped

- Facebook post: a Rh-negative donation keeps its minus, `(O-)သွေး(၁)လုံး`, the way the group writes it; positive groups still print as the bare letter. The admin reported (O-) donations posted as (O) on 2026-09-26 and 2026-09-28 (donations 15701 and 15718, both from O (Rh -) donors). A negative donation for a patient who also got positive ones that day gets its own paragraph, so a positive donor listed first cannot hide the minus. Replacement donors of another ABO group still share the patient's paragraph: about 12% of donations since June 2026 come from a donor whose group differs from the patient's, and a paragraph per donor group would post that the patient "needed" the donor's group.
- Special Events (ထူးခြားဖြစ်စဉ်): a မှတ်တမ်းချုပ် tab beside the records with all-time, all-laboratory totals per test, as the admin asked (no monthly or yearly summary). The server computes the totals, so searching or paging the list never changes them. The add button shows only on the records tab. On 2026-09-28 production holds 225 findings in 200 records (Hb 9, HBs Ag 89, HCV Ab 26, MP ICT 0, Retro 16, VDRL 85).
- Everything from 1.5.15.

## Backend (live since 2026-09-27, reaches every app version)

- `8088ce7` `special-event/index` returns an all-time `summary` with page 0, independent of the search and pagination. Production served it with 200 on 2026-09-28.

## Checks

- The real ledger rows for 2026-09-26 and 2026-09-28, run through the new builder locally: both paragraphs for the O (Rh -) patient read `(O-)`, and the 2026-09-26 replacement-donation patient (AB+ and A+ donors) keeps one `(AB)သွေး(၂)လုံး` paragraph.
- `test/facebook_post_builder_test.dart`: negative labels in every spelling, the negative-beside-positive split, replacement donors in one paragraph. `test/blood_type_label_test.dart`: the phone badges keep the Rh sign for all eight stored types.
- `test/special_event_screen_test.dart`: the summary survives pagination and refreshes with the list; both tabs at 390×844 and 320×568 in the MyanUni font with no overflow; captures in `design-qa/special-event-{records,summary}-*.png` (sample data). All six test counts fit on a 320×568 screen without scrolling.
- Full suite: 144 tests pass.

## Production web

- Website: https://donation-coral-five.vercel.app
- Application-code revision: `8eb8006` (Release 1.5.16). Vercel reported the deployment as successful on September 28, 2026 at 15:53 (+07:00); the live bundle carries version `1.5.16`.

## Native release

- Marketing version: `1.5.16`; build number: `191`.
- iOS archive: `build/ios/archive/Runner.xcarchive` (217.5 MB, local, excluded from Git), built by `flutter build ipa --release` with automatic signing for team `V66GW9RJ44` and an upload-only export (`manageAppVersionAndBuildNumber` off, so the build keeps number 191).
- App Store Connect upload succeeded on September 28, 2026 at 16:00:12 (+07:00): Xcode's distribution log records `UPLOAD SUCCEEDED with no errors` and `Uploaded package is processing`, delivery UUID `c49a7dae-ddb0-4cf8-94f9-a82fde3a3f2d`. TestFlight distributes it to the internal group "Red Juniors" once processing completes. Flutter then exited with its usual `PathNotFoundException` for `build/ios/ipa/`, which an upload-only export never creates.
- Android bundle: `build/app/outputs/bundle/release/app-release.aab`, 67,833,466 bytes, signed by `CN=Medico`; manifest carries versionCode `191`, versionName `1.5.16`, package `com.red.juniors`. Copy at `~/Downloads/red-juniors-1.5.16-191.aab`.
- AAB SHA256: `60bbd18c4e82cf2b3aed32414fea3227101fd4b049aaf2e781e6d05e42835d74`.
- Play Console (September 28, 2026, driven through the Claude in Chrome extension in the "Medico" Chrome profile; the bundle went through the native Open dialog because the extension's file upload is capped at 10 MB): bundle `191 (1.5.16)` uploaded to Production release 46 with en-US release notes, 190 (1.5.15) not included, saved, and sent for review as a full rollout. Publishing overview shows **Changes in review** while the quick checks run (up to 14 minutes); managed publishing is off, so it goes live once approved. Supported devices are unchanged (12,334 phones, 6,747 tablets), and the only warning is the same non-blocking advertising-ID advisory as before.
- Build note: Gradle 8.14.2 was not cached again. The unused Gradle 9.3.1 caches (another project, 3.9 GB) were deleted first; the bundle then built in 267 s.

## Open for the group

- Card numbers B-0801 and D-0266 are each held by two donors. Until one of each pair is renumbered, `php yii migrate` stops at `m260920_000001` (the unique card-number index).
- The post names a paragraph after its first donor's group. Whether it should name the patient's needed group instead is undecided; `patient.blood_type` is filled for every donation since June 2026 but is not in the rows the post reads.
