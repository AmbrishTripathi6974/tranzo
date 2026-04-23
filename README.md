# Tranzo

Flutter-based cross-device file transfer app using Supabase + local persistence.

This README reflects the **current implementation** and directly covers Assessment Point 3.

---

## 1) How To Run Locally

### Prerequisites

- Flutter SDK with Dart `^3.11.0` (see `pubspec.yaml`)
- Android development setup (Android Studio/SDK + emulator or real device)
- Supabase project (hosted or local Supabase CLI stack)

### Environment setup

Create a `.env` file in project root:

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-public-anon-key
```

The app reads these keys at startup (`dotenv.load` + Supabase init), so run will fail fast if they are missing.

### Run commands

```bash
flutter pub get
flutter run
```

### Backend / relay note

- There is **no custom backend server** or separate relay process in this repo.
- Relay/control signaling is handled by **Supabase Realtime**.
- Data and metadata use Supabase Storage + Postgres.

If you use local Supabase, start it with Supabase CLI and apply migrations before running the app.

---

## 2) Devices And OS Tested

- 1 Android real device
- 2 Android emulators
- All three test targets were reported working in current testing

Exact Android OS version numbers were not recorded in this submission.

---

## 3) Architecture Overview (Client, Transport, Relay, Storage)

### Components

- **Client (Flutter):** UI, BLoCs, use cases, transfer orchestration, background runtime bootstrap
- **Transport (data plane):** chunk upload/download over Supabase APIs + HTTPS
- **Relay (control plane):** Supabase Realtime signals/postgres changes for transfer lifecycle updates
- **Storage:** Supabase Storage (chunks), Supabase Postgres (transfer metadata/state), Isar local DB (offline/persistence state)

### ASCII architecture diagram

```text
+-------------------------------+          +-----------------------------------+
| Flutter Client (Sender/Recv)  |          | Supabase                          |
| - UI/BLoC/UseCase/Repository  | <------> | - Postgres (transfer lifecycle)   |
| - Transfer orchestration       | Realtime | - Realtime (signal relay)         |
| - Isar local persistence       |          | - Storage bucket (chunk objects)  |
+---------------+---------------+          +----------------+------------------+
                |                                          ^
                | local durable state                      |
                v                                          |
        +--------------------+                             |
        | Isar (on-device)   |-----------------------------+
        | - transfer progress|
        | - queue metadata   |
        +--------------------+
```

---

## 4) Transport Choice And Rationale

### Current transport choice

- **Chunked transfer via Supabase Storage/API** for file bytes
- **Supabase Realtime** for transfer lifecycle/control events

### Why this split

- Chunking avoids loading full large files into memory
- Retries can target failed chunks instead of restarting full file
- Realtime is efficient for control events (new transfer, state/progress updates)
- Data-plane and control-plane stay separated, which simplifies reliability handling

---

## 5) Platform Channel Bonus (Attempted)

### What was attempted

- Android platform channel for received-file export:
  - channel: `tranzo/received_files`
- Android platform channel for transfer progress notification:
  - channel: `tranzo/transfer_progress_notification`
- Android background runtime scaffolding:
  - foreground task + WorkManager integration

### How far it is implemented

- Android native bridge integration is present and wired from Dart.
- Background scheduling exists, but fully automatic transfer continuation after process death is still partial.

### What is next

- Complete end-to-end resume continuation logic (not only state restore)
- Add iOS parity for native channel/background transfer behavior
- Add integration tests around kill/restart/background-recovery flows

---

## 6) Section 3 Edge Cases: Handled vs Not Fully Handled

### Handled (implemented or mostly implemented)

- Invalid/empty recipient code validation and self-send prevention
- Connectivity-aware pause/retry behavior with bounded retry queue
- Storage availability checks before receive/write
- SHA-256 verification and duplicate handling safeguards
- Auth/session recovery paths (including some refresh/reauth fallbacks)

### Not fully handled / partial

- Process-death background resume is partial in current implementation
- Some legacy remote methods remain unimplemented (`UnimplementedError`) and v2 flow is the active path
- Realtime reconnect/backfill guarantees are limited (best-effort + fallback behavior)
- Intent-priority policy is defined but not fully enforced end-to-end in all queue decisions
- iOS native/background channel parity is not implemented yet

---

## 7) Known Bugs And Limitations (Honest)

- Automatic resume after app/process kill is not fully complete for all transfer paths.
- Android background tooling exists, but long-running transfer continuity can still be interrupted by OS/device policies.
- iOS background-native transfer path is still pending.
- Realtime events are resilient but not guaranteed lossless in all reconnect windows.
- Legacy non-v2 transfer API paths are still stubbed; current production path is the chunked v2 flow.
- This project still has active development areas and is not yet a fully hardened production release.

---

## 8) AI Tool Usage And Overrides

- Tool used: Cursor AI assistant
- AI helped with: edge-case brainstorming and debugging assistance
- Final implementation decisions were manually reviewed and adjusted to match real code behavior
- I intentionally avoided overstating feature completeness when AI suggestions were broader than current implementation
