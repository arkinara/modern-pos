# Offline session allowance and reconnect policy (#68)

This document defines the supported Android cashier offline session, the
authorization that survives a restart, the reconnect behaviour and the limits
that the UI must show. It is source-verified on the VPS; physical Android
restart/disconnect evidence remains `PENDING — requires Android device`.

## Policy summary

| Situation | Behaviour |
| --- | --- |
| Last online authorization within 12 hours, app restarts offline | Restore a read/write **offline session** from the encrypted-secure-storage profile. Show the cashier shell, saved catalog snapshot and local queue. No valid server access token exists; API calls that need one are blocked. |
| Last online authorization older than 12 hours, or no persisted profile | Require sign-in. No offline sales are possible. |
| New install with no refresh token | Require sign-in. An unauthenticated install cannot sell offline. |
| Refresh returns `401` (revoked/expired session) | Clear the refresh token, profile and catalog cache; require sign-in. Never extend authorization silently. |
| Refresh fails with a transient network/5xx error | Schedule bounded automatic retries with exponential backoff (2 s, 4 s, 8 s, 16 s, 32 s, 64 s; six attempts, 5-minute cap). On success the session becomes online again; a `401` during retries follows the revocation rule. |
| Offline allowance elapses while retrying | Require sign-in; the queue stays encrypted on the device. |
| Sign-out | Clear the refresh token, profile and catalog cache. Keep the encrypted queue and its owner scope so the same user can sign back in; a different user clears the queue, cart and cache. |

### Why 12 hours

A 12-hour allowance covers one long cashier shift plus handover without asking
the server. It is deliberately shorter than the server refresh-token TTL (7
days), so the offline window is the stricter bound. A longer window would let a
device that the server has revoked keep capturing sales for days; a much shorter
window would force sign-in during a normal outage.

Revocation cannot be observed while the device has no network. The policy
therefore bounds the risk instead of pretending to detect revocation:

- Local offline data is scoped to the last authorized user and outlet.
- Queue replay requires a fresh server access token. The server remains the
  authority for every sale; a revoked session cannot replay its queue.
- On reconnect, the first authenticated request returns `401`; the app clears
  the session and returns to sign-in without replaying the queue.

## What is persisted

| Data | Storage | Encryption | Scope |
| --- | --- | --- | --- |
| Refresh token | `flutter_secure_storage` (`pos_refresh_token`) | Android Keystore-backed secure storage | Device |
| Offline profile (user id, email, role, outlet ids, authorized-at) | `flutter_secure_storage` (`pos_offline_session_v1`) | Android Keystore-backed secure storage | Device; only written after a successful login/refresh |
| Queue owner | `flutter_secure_storage` (`pos_offline_queue_scope_v1`) | Android Keystore-backed secure storage | `userId + outletId` |
| Catalog and outlet settings snapshot | Drift `catalog_snapshots` table | AES-256-GCM (same `pos_offline_queue_key_v1` key, fresh nonce per write) | `userId + outletId` primary key |
| Offline sale queue | Drift `checkout_intents` table (existing #19) | AES-256-GCM | Payload carries `outletId`/`deviceId`; the owner scope gates access |

No access token is written to persisted storage. An offline session has an empty
access token by design, so it cannot call protected API endpoints even if code
forgets to check the `offline` flag.

## Scoped catalog and settings snapshot

`CatalogController` writes the categories, complete menu (including variants)
and the outlet currency/exponent after every successful online read. The
snapshot is stored under the current `userId` and outlet. When the API is
unreachable, or when an offline session starts, the controller reads the
snapshot for that same user and outlet.

The cashier sees:

- An **Offline mode** banner in the shell with the last authorization time and a
  Reconnect action.
- An **Offline menu snapshot** card on the catalog screen with the snapshot age
  and the limits: prices, availability and stock may be stale; the server
  confirms the total at sync; stock is not reserved offline.
- The queued-sale screen keeps the Sync now and Reconcile actions disabled until
  the session is online again, with the reason shown.

There is no separate catalog TTL. The snapshot is shown only while the session
itself is authorized (offline allowance or a live session). An older snapshot is
labelled with its age rather than presented as current.

## Cashier offline scope

Allowed while the offline session is within its allowance:

- Browse the saved catalog snapshot and add lines to the durable Drift cart.
- Record an offline capture (`Record offline sale`) from checkout. It is an
  offline capture, not a promise of server acceptance.
- View the encrypted queue, retry/discard decisions already defined by #19.

Not allowed while offline:

- Creating a draft order, quote or finalize request.
- Replaying the encrypted queue or reconciling it with the server.
- Creating a new account or obtaining a new access token.
- Any claim that stock is reserved or that the sale is accepted. The server
  still allocates stock at finalize and can reject the sale as a conflict.

## Cross-user and cross-outlet isolation

- Every successful login/refresh compares the queue owner scope with the new
  `userId + outletId`.
- A different owner clears the encrypted queue, the durable cart and the catalog
  snapshots before the new scope is written.
- A queue with no owner marker fails closed: if any rows exist, they are cleared
  rather than exposed to the first account that signs in.
- Sign-out clears the profile, refresh token and catalog cache but intentionally
  keeps the encrypted queue and owner scope. The same user can recover after
  signing back in; a different user triggers the clearing rule above.
- `OfflineSyncController` and reconciliation refuse to replay unless the current
  session is online-authorized (`canSyncOnline`). Merely restoring an offline
  profile is not authorization to submit sales.

## Verification

| Test | Acceptance criterion |
| --- | --- |
| `offline_session_test.dart` — restart while offline within allowance | AC1: previously authorized restart reaches the scoped cashier UI, queue preserved. |
| `offline_session_test.dart` — expired authorization and new install | AC3: expired/missing authorization requires sign-in; a new install cannot sell offline. |
| `offline_session_test.dart` — transient refresh outage retries and recovers online | AC4: bounded retries and reconnect recovery. |
| `offline_session_test.dart` — `401` refresh | AC4: revocation follows the sign-in policy, no silent extension. |
| `offline_session_test.dart` — different account | AC5: no cross-user/outlet queue, cart or snapshot leakage. |
| `offline_session_test.dart` — offline sync refused | AC5: queue is never replayed without a server token. |
| `offline_session_test.dart` — widget restart | AC1/AC2: cashier shell, cached catalog and snapshot age render instead of `SignInScreen`. |
| `catalog_snapshot_test.dart` | AC2/AC5: encrypted, scoped snapshot survives restart, has no plaintext, and is unreadable by another user/outlet. |
| `offline_sale_repository_test.dart` (existing) | AC6: encrypted durable queue survives a database restart. |

Commands:

```bash
cd apps/mobile
flutter test test/offline_session_test.dart test/catalog_snapshot_test.dart
flutter test test/offline_sale_repository_test.dart test/offline_sync_controller_test.dart
```

## Limits and pending evidence

- Physical Android restart/disconnect, process kill and paper evidence are
  `PENDING — requires Android device`. The tests run on the VPS and prove source
  behaviour, not device power loss or OEM secure-storage behaviour.
- The API contract is unchanged. No new endpoint or OpenAPI operation was added.
- Offline capture can be rejected at sync because of a changed total, tax,
  service, rounding or stock. That conflict is cashier-visible and never
  silently retried with a new key.
- Losing the secure-storage key makes the encrypted queue and catalog snapshot
  unreadable. The app reports the failure and never falls back to plaintext.
