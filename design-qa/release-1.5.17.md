# Red Juniors 1.5.17 release verification

## What changed

From October 2026 onward, the daily worksheet counts donations automatically from blood donation records by donation date. Staff enter requests only. Donation counts open the corresponding day's records; refresh preserves unsaved requests and their original conflict revision. Donation changes refresh monthly reports and charts. Zero automatic donations do not mark a day's requests as entered.

Months before October retain their saved figures. The worksheet compares saved and actual donation totals and lists individual daily mismatches, including cases where errors cancel out in the monthly total. Historical summaries without daily request details stay read-only.

## Verification

- Full Flutter suite: 147 tests passed. After the day-level comparison addition, all 6 targeted worksheet and report refresh tests passed again.
- Backend suite: 68 tests, 393 assertions passed, including create/date-change/delete effects, donation-only months, old-client writes, request revision conflicts, historical month boundaries, and offsetting daily errors.
- Phone worksheet verified at 390x844 and 320x568 with the application font; fictional-data captures in `automatic-donations-*.png`.
- Targeted analyzer: no errors or warnings; four pre-existing deprecation infos in report UI/service files.

## Backend deployment

- Live revision: `9e7e3b54520d077947944d4c4f2bbeeea1995342`, October 2, 2026.
- Authenticated public HTTPS and localhost endpoints agree with PostgreSQL: October 7 donations (October 1: 6; October 2: 1), requests not entered. Worksheet, monthly/yearly report and chart counts agree.
- September remains 267 requests and 236 donations, revision 20. Comparison finds September 25: saved 7 / actual 8, and September 27: saved 7 / actual 6.
- No new migrations or production test writes. Backend rollback revision: `8088ce75cf373f54d71f582e8bb464ab1f49e40c`.

## Release packaging

Marketing version `1.5.17`, build `192`, package/bundle ID `com.red.juniors`. Store upload and web deployment results will be recorded after verification.
