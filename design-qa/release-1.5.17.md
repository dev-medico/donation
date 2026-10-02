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

## Release packaging

Marketing version `1.5.17`, build `192`, package/bundle ID `com.red.juniors`. Store upload and web deployment results will be recorded after verification.
