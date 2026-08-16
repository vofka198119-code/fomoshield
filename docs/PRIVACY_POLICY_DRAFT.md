# Privacy Policy — DRAFT, NOT YET REVIEWED

> ⚠️ **This is a first-pass draft, not final legal text.** It is written to be
> accurate to what the app actually does (verified against the current
> codebase), but it is not a substitute for review by a lawyer, especially
> for GDPR compliance before EU users can sign up. Placeholders in
> `[BRACKETS]` need real values before this goes live. Once you've read
> through and marked up changes, tell me and I'll fold them in — this file
> is not linked from the app or the server yet.

**Last updated:** [DATE — fill in when published]
**Effective for app version:** 1.0.0 (confirm this still matches
`pubspec.yaml` at the time you actually publish)

---

## 1. Who We Are

F.O.M.O. Shield ("the App", "we", "us") is an educational investing-simulation
app. This policy explains what data we collect, why, and what rights you have
over it.

**Data controller:** Volodymyr Oleksiienko (individual developer, not a
registered company)
**Contact for privacy questions:** fomoshield@gmail.com
**Business address:** not applicable — operated by an individual, not a
registered legal entity.

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
| Your own data | Watchlist symbols, portfolio/stress-test simulation state, goals you set | Core app functionality — this is the product |

We do **not** collect: real payment/card details (Premium, if purchased, is
billed entirely by Apple/Google — we never see your card), real brokerage
credentials, precise GPS location, or contacts/photos/microphone access.

## 4. Legal Basis for Processing (GDPR, EU/UK users)

- **Consent** — you actively accept this policy and the Disclaimer at sign-up,
  and can withdraw consent by deleting your account.
- **Legitimate interest** — securing our backend and preventing abuse (e.g.
  rate-limiting, API authentication), where this doesn't override your own
  privacy rights.
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
- **Our own backend server** (proxies market-data requests and stores app
  configuration), hosted by Hetzner Online GmbH in Nuremberg, Germany.
- **Email delivery** (Gmail SMTP) — sends account-related emails
  (verification, password reset).
- **Firebase Crashlytics** (Google) — if the App crashes or hits an
  unhandled error, automatically sends a crash report with basic device
  diagnostics (device model, OS version, app version, the crash's stack
  trace) so we can find and fix the bug. This is not tied to your account,
  email, or identity.

We do not sell your data to advertisers or data brokers, and no ad network
or behavioral-analytics SDK is integrated into the App. The "Sponsored
Content" box shown to free-tier users is a static placeholder with no data
collection behind it. If a real ad network is added later, this section
will be updated with a new processor entry before that ships.

## 6. Data Retention

We keep your account data for as long as your account is active. You can
delete your account at any time from Profile → Delete Account — this
permanently and immediately removes your account and all associated data
(portfolios, watchlist, stress-test history), except where we're legally
required to keep records longer.

## 7. Your Rights

If you're in the EU/UK/or a jurisdiction with similar protections, you have
the right to:

- **Access** the personal data we hold about you.
- **Correct** inaccurate data.
- **Delete** your data ("right to be forgotten") — self-service, instant,
  via Profile → Delete Account in the App.
- **Export** your data in a portable format.
- **Object to or restrict** certain processing.
- **Withdraw consent** at any time (this doesn't affect processing already
  done before withdrawal).

To exercise any of these, contact us at fomoshield@gmail.com. We'll
respond within 30 days (GDPR's standard timeline).

## 8. International Data Transfers

Our backend server is located in Germany (Nuremberg, hosted by Hetzner
Online GmbH — confirmed 2026-08-15 via IP lookup). Because this is within
the EU/EEA, no additional international-transfer safeguard (e.g. Standard
Contractual Clauses) is required for EU/UK users' data.

## 9. Children's Privacy

This app is not directed at, and should not be used by, anyone under 18 —
you confirm this when accepting the Disclaimer at sign-up. We don't knowingly
collect data from minors.

## 10. Cookies & Local Storage

The app stores some data locally on your device (e.g. your accepted policy
version, cached preferences) using standard mobile storage — this is not a
tracking cookie and isn't shared with third parties.

## 11. Security

We use industry-standard measures to protect your data: all traffic between
the App and our servers is encrypted in transit (HTTPS/TLS), and our
database enforces row-level security so each account can only ever read or
write its own data, even at the database layer. No system is 100% secure,
and we can't guarantee absolute security.

## 12. Changes to This Policy

If we make material changes, we'll update the version number and prompt you
to re-accept the policy the next time you open the app before you can
continue.

## 13. Contact

Questions about this policy: fomoshield@gmail.com
