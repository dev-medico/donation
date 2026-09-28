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
