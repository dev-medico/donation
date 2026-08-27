# Design QA — Find Blood and donation detail

Date: 2026-08-11
Preview: http://127.0.0.1:4173/

## Sources and comparison evidence

- Find Blood count reference: `/var/folders/p3/h6x_mg8j5_x21gz5mrvn1cfr0000gn/T/TemporaryItems/NSIRD_screencaptureui_OTDY1C/Screenshot 2569-08-11 at 21.23.22.png`
- Donation detail alignment reference: `/tmp/codex-remote-attachments/019ff0fe-26ce-7e01-80ad-f77c5cdfc83a/91210a25-3ea9-4d5b-917a-e8f18d044454/1-Photo-1.jpg`
- Find Blood comparison: `design-qa/find-blood-comparison.png`
- Donation detail comparison: `design-qa/donation-detail-comparison.png`
- Final mobile directory: `design-qa/find-blood-mobile.png`
- Final mobile detail: `design-qa/donation-detail-mobile.png`
- Final desktop directory: `design-qa/find-blood-desktop.png`
- Final desktop detail: `design-qa/donation-detail-desktop.png`

## Responsive visual checks

- 320 × 568: compact donor rows fit without RenderFlex overflow; four donors remain visible in the first viewport.
- 390 × 844: six full donors remain visible; status, phone, and edit actions retain 44 px targets.
- 1280 × 720: global analysis, filters, desktop headers, donor rows, and action columns align consistently.
- Donation detail: all six donor labels share one left edge and all six values share one left edge; the metadata is no longer centered as separate blocks.
- Long meaningful remarks are shown without truncation. Imported empty-note placeholders (`-`, `—`, `–`) remain visually empty.

## Interaction checks

- Initial directory response renders 50 of 4,528 preview members while the summary reports the complete global analysis.
- Scrolling appended the next page and updated the caption from 50 to 100 without duplicate rows.
- Yellow availability selection requested the complete yellow server set while preserving all/green/yellow/red global counters.
- Member-number search for `P-0050` reduced the scoped analysis and results to one matching member.
- Blood type, text search, availability, refresh, load-more, and clear-all controls remained usable on mobile and desktop.
- A status or remark edit invalidates the directory; donation create/update/delete actions also trigger a new first-page analysis.
- The active directory refreshes at Bangkok midnight so the four-month boundary advances without a manual edit.

## Backend and accessibility checks

- Backend smoke data: 4,329 total local members; 4,325 green, 2 yellow, 2 red; yellow selection returned 2 rows while preserving the same global analysis.
- Classification uses four calendar months, including exact-boundary eligibility and end-of-month clamping.
- Backend limits a response to at most 250 rows; the app requests 50.
- Invalid availability values return HTTP 400 rather than silently showing all members.
- Clean browser sessions reported no console errors for the final 320 px, 390 px, or 1280 px views.
- Summary filters, row actions, detail navigation, and edit controls have semantic labels/tooltips.

## Automated verification

- Targeted Flutter analysis: no issues.
- Find Blood, pagination, classification, four-month boundary, narrow layout, loading, and detail-alignment tests: 22 passed.
- PHP syntax and backend response smoke checks: passed.
- Git whitespace validation: passed.

final result: passed
