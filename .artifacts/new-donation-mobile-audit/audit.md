# New blood donation — mobile audit

## Audit scope

- Surface: `NewBloodDonationScreen`
- User goal: record a new blood donation quickly and confidently on a phone.
- Accessibility target: readable Burmese text, predictable reading order, visible state changes, and at least 44px interaction targets.

## Step 1 — page entry/loading

- Evidence: `/tmp/codex-remote-attachments/019fe544-3c66-74b2-a552-4a9369f27b92/124d03e4-732b-435d-bada-aaa83053f21e/1-Photo-1.jpg`
- Health: poor.
- Strength: the app bar confirms the destination and retains a back action.
- UX risk: the entire task is replaced by an unexplained spinner while donor data loads, leaving no usable form or recovery action.
- Accessibility risk: the loading state has no visible status copy, progress meaning, timeout, or retry path.
- Recommendation: render the form immediately and fetch donor matches only after the user types; keep submission progress local to the primary action.

## Step 2 — initial form

- Evidence: `/tmp/codex-remote-attachments/019fe544-3c66-74b2-a552-4a9369f27b92/124d03e4-732b-435d-bada-aaa83053f21e/2-Photo-2.jpg`
- Health: needs structural improvement.
- Strengths: the form is grouped into donor, patient, and date sections; search and calendar affordances are recognizable.
- UX risks: the content uses roughly half the phone width, Burmese labels and values truncate, dense outlined fields create visual noise, and the submit action is far below the first viewport.
- Accessibility risks: low-contrast placeholder text and clipped labels reduce readability; the icon-only form-mode control is ambiguous without its tooltip.
- Recommendation: use full-width mobile sections with 12–16px insets, lighter section containers, flexible labels, clear helper copy, keyboard-safe scrolling, and a persistent full-width primary action.

## Evidence limits

Screenshots confirm visual hierarchy and visible states only. Screen-reader semantics, focus order, keyboard navigation, text scaling, and real-device touch targets require implementation-level and device testing.

## Implemented result

- Evidence: `03-after-mobile.png` at a 390×844 phone viewport.
- Health: good.
- The form is visible within the first 120 ms after navigation and makes no donor request until two characters are entered.
- Donor lookup is debounced, server-filtered, limited to 25 matches, and bounded by a 12-second timeout.
- Mobile content now fills the available width inside 16px gutters, with readable section cards and flexible Burmese labels.
- The primary submit action remains visible at the bottom and yields space while the keyboard is open.
- A live two-character donor search returned suggestions successfully during browser QA.
- The 600px-wide mobile layout remains full-width; the 1000px desktop layout retains the original half-width form.
