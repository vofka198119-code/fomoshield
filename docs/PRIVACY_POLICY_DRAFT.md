# Privacy Policy — DRAFT, NOT YET REVIEWED

> ⚠️ **This is a first-pass draft, not final legal text.** It is written to be
> accurate to what the app actually does (verified against the current
> codebase), but it is not a substitute for review by a lawyer, especially
> for GDPR compliance before EU users can sign up. Placeholders in
> `[BRACKETS]` need real values before this goes live. Once you've read
> through and marked up changes, tell me and I'll fold them in — this file
> is not linked from the app or the server yet.

**Last updated:** [DATE — fill in when published]
**Effective for app version:** [VERSION]

---

## 1. Who We Are

F.O.M.O. Shield ("the App", "we", "us") is an educational investing-simulation
app. This policy explains what data we collect, why, and what rights you have
over it.

**Data controller:** [LEGAL ENTITY NAME OR YOUR FULL NAME]
**Contact for privacy questions:** [privacy@fomoshield.app — needs to actually
be set up as a working inbox, e.g. via Namecheap email forwarding to your
real address]
**Business address (required for some stores/regulators):** [ADDRESS]

## 2. What This App Is (and Isn't)

F.O.M.O. Shield is an educational tool for practicing investing decisions
using simulated ("paper") money. It is **not** a registered broker-dealer,
investment advisor, or financial institution. No real money, securities, or
brokerage accounts are ever involved — see the in-app Disclaimer for full
detail. This matters for privacy too: we never collect brokerage account
numbers, bank details, or real trading credentials, because the app has none.

## 3. Data We Collect

| Category | What | Why |
|---|---|---|
| Account | Email address (via Supabase Auth, or via Google Sign-In if you use that option) | Create and secure your account, password-reset/login |
| Usage | Anonymized in-app usage statistics (which features are used, not tied to your identity beyond your account) | Understand what's useful, fix bugs |
| Device | Device language/locale setting | Show the app in the right language |
| Your own data | Watchlist symbols, portfolio/stress-test simulation state, goals you set | Core app functionality — this is the product |

We do **not** collect: real payment/card details (Premium, if purchased, is
billed entirely by Apple/Google — we never see your card), real brokerage
credentials, precise GPS location, or contacts/photos/microphone access.

## 4. Legal Basis for Processing (GDPR, EU/UK users)

- **Consent** — you actively accept this policy and the Disclaimer at sign-up,
  and can withdraw consent by deleting your account.
- **Legitimate interest** — anonymized usage analytics to keep the app
  working and improve it, where this doesn't override your own privacy
  rights.
- **Contract necessity** — your email is required to create and operate your
  account; without it we can't provide the service.

## 5. Who We Share Data With (Processors)

We use the following third-party services to run the app. Each only receives
the minimum data needed for its function:

- **Supabase** — authentication and database hosting (your account, app data).
- **Google Sign-In** (if you choose that login method) — authenticates you;
  we receive your email and name from Google, nothing else.
- **Finnhub** and **Wikipedia APIs** — provide market data and company
  information; we query them on your behalf via our own backend, they don't
  receive your personal data.
- **Our own backend server** ([scanco-backend], hosted at [HOST/REGION —
  fill in, e.g. Hetzner/Germany]) — proxies market-data requests and stores
  app configuration.
- **Email delivery** (Gmail SMTP) — sends account-related emails
  (verification, password reset).

We do not sell your data to advertisers or data brokers.

## 6. Data Retention

We keep your account data for as long as your account is active. If you
delete your account, we delete your personal data within [X days — fill in,
e.g. 30] except where we're legally required to keep records longer.

## 7. Your Rights

If you're in the EU/UK/or a jurisdiction with similar protections, you have
the right to:

- **Access** the personal data we hold about you.
- **Correct** inaccurate data.
- **Delete** your data ("right to be forgotten").
- **Export** your data in a portable format.
- **Object to or restrict** certain processing.
- **Withdraw consent** at any time (this doesn't affect processing already
  done before withdrawal).

To exercise any of these, contact us at [privacy@fomoshield.app]. We'll
respond within [30 days, per GDPR's standard timeline].

## 8. International Data Transfers

Our backend server is located in [COUNTRY — confirm from hosting provider].
[If this is inside the EU/EEA: "Because this is within the EU/EEA, no
additional transfer safeguard is required." If outside: needs Standard
Contractual Clauses or another GDPR transfer mechanism — flag this to a
lawyer if the server isn't EU-based.]

## 9. Children's Privacy

This app is not directed at, and should not be used by, anyone under 18 —
you confirm this when accepting the Disclaimer at sign-up. We don't knowingly
collect data from minors.

## 10. Cookies & Local Storage

The app stores some data locally on your device (e.g. your accepted policy
version, cached preferences) using standard mobile storage — this is not a
tracking cookie and isn't shared with third parties.

## 11. Security

We use industry-standard measures (HTTPS/TLS encryption in transit, access
controls on our database) to protect your data. No system is 100% secure,
and we can't guarantee absolute security.

## 12. Changes to This Policy

If we make material changes, we'll update the version number and prompt you
to re-accept the policy the next time you open the app before you can
continue.

## 13. Contact

Questions about this policy: [privacy@fomoshield.app]
