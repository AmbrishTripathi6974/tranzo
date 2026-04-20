# Tranzo

Flutter-based real-time cross-device file sharing app (assessment submission draft).

This README intentionally separates **target architecture/design** from **current implementation status** so claims stay verifiable.

---

## 1) Overview

Tranzo is intended to let one device send files to another device over the internet using a short recipient code, with resumable chunk-based transfer for large files.

### Key capabilities (target)

- Real-time transfer coordination between sender and recipient.
- Anonymous/low-friction identity via short code exchange.
- Resumable transfers for unstable mobile networks.
- Support for large files (up to ~1 GB) through chunking and streaming.

### Current status

- `✅ Implemented`: basic Flutter app scaffold only.
- `❌ Not implemented yet`: transfer engine, backend integration, realtime messaging, resumability, background execution.

---

## 2) How to Run

### Prerequisites

- Flutter SDK compatible with Dart `^3.11.0` (see `pubspec.yaml`).
- Android toolchain (tested on Android real device and Android emulator).
- (Planned) Supabase project for DB, Realtime, and Storage.

### Local run (current codebase)

```bash
flutter pub get
flutter run
```

### Planned environment contract (`.env.example`)

No runtime env loading is implemented yet, but the intended contract is:

```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key
TRANSFER_CHUNK_SIZE_BYTES=4194304
TRANSFER_MAX_RETRIES=5
TRANSFER_RETRY_BASE_MS=800
```

---

## 3) Architecture Overview

### Target architecture

- **Client (Flutter)**
  - UI for sender/recipient flow.
  - Local transfer state machine and queue.
  - Background-aware execution hooks per platform.
- **Transfer Engine**
  - Chunk split/read/upload.
  - Retry with bounded exponential backoff.
  - Resume from persisted progress markers.
- **Backend (Supabase)**
  - Postgres: transfer/session/chunk metadata.
  - Realtime: transfer state events and recipient presence.
  - Storage: binary chunk/object persistence.

### ASCII diagram

```text
+---------------------+         HTTPS          +-------------------------+
| Sender Flutter App  |  ------------------->  | Supabase Storage (objs) |
| - file picker       |                        +-------------------------+
| - chunk uploader    |                                   ^
| - retry queue       |                                   |
+----------+----------+                                   |
           |                     Realtime                 |
           +---------------------------------------------+
           |                                             |
           v                                             |
+---------------------+         PostgREST/SQL           |
| Supabase Realtime   | <----------------------------+   |
| + Postgres metadata |                              |   |
+----------+----------+                              |   |
           |                                         |   |
           v                                         |   |
+---------------------+         HTTPS                |   |
| Recipient Flutter   |  <---------------------------+---+
| App                 |
| - session listener  |
| - chunk downloader  |
| - file reassembler  |
+---------------------+
```

### Current status

- `❌ Not implemented`: none of the above architecture components exist in code yet.
- `⚠️ Partially handled`: architecture and failure model documented in this README.

---

## 4) Transport Design

### Why chunking

- Mobile memory constraints: avoids loading full large files in RAM.
- Resume support: retry only failed chunks, not full file.
- Better failure isolation: per-chunk checksum + retry.
- Progress visibility: deterministic completion percentages.

### Why HTTP + Realtime

- **HTTP** is reliable for binary chunk upload/download and works with existing storage/CDN semantics.
- **Realtime channel** (Supabase Realtime) is efficient for control-plane events:
  - recipient online/offline,
  - transfer accepted/rejected,
  - progress updates,
  - completion/failure signals.
- This separation keeps data-plane and control-plane responsibilities explicit.

### Optional WebRTC

- WebRTC is considered optional for direct P2P optimization.
- It increases implementation complexity (NAT traversal, relay fallback, mobile lifecycle interactions).
- For assessment scope, HTTP + Realtime is the baseline transport.

### Current status

- `❌ Not implemented`: transport stack is design-only at this point.

---

## 5) Background Execution Strategy

### Android (target)

- **Primary:** Foreground Service for active transfer continuity and user-visible long-running task compliance.
- **Recovery only:** WorkManager to resume incomplete transfers after process death/reboot/network restore.
- Rationale: long transfers need deterministic execution while respecting modern Android background limits.

### iOS (target)

- **Primary:** Background `URLSession` for system-managed transfer continuation.
- Rationale: iOS heavily constrains arbitrary background execution; `URLSession` is the system-supported path for transfer reliability.

### Current status

- `❌ Not implemented`: no background transfer integration in native layers yet.

---

## 6) Edge Cases Handling

Status legend:
- `✅ Implemented`
- `⚠️ Partially handled`
- `❌ Not implemented`

| Edge case | Status | Notes |
|---|---|---|
| Short-code collision | ❌ | Target approach: DB unique constraint + regenerate code on conflict. |
| Invalid recipient code | ❌ | Target approach: lookup validation + immediate user error state. |
| Recipient offline | ❌ | Target approach: realtime presence + queued pending transfer state. |
| Network drop mid-transfer | ❌ | Target approach: per-chunk retry and resume cursor. |
| App killed during transfer | ❌ | Target approach: persist transfer cursor and recover on relaunch/background worker. |
| Large files (~1 GB) | ❌ | Target approach: stream file IO and bounded chunk buffers to avoid OOM. |
| Multiple files at once | ❌ | Target approach: transfer queue with bounded concurrency. |
| Zero-byte files | ❌ | Target approach: metadata-only transfer completion path. |
| Permission denial | ❌ | Target approach: explicit permission error handling and retry action. |
| Low storage | ❌ | Target approach: preflight free-space checks + graceful abort. |
| Duplicate delivery | ❌ | Target approach: idempotency keys and content-hash verification before finalize. |
| Incoming transfer when app is closed | ❌ | Target approach: platform notification/wake strategy + recoverable session pickup. |

Current repo contains only starter Flutter UI, so none of these behaviors are implemented yet.

---

## 7) Storage & Data Flow

### Target data flow

1. Sender computes file metadata (`size`, `mime`, `sha256`, `chunkCount`).
2. File is read as a stream and split into fixed-size chunks.
3. Each chunk is uploaded to storage under transfer-scoped keys.
4. Chunk metadata/state is recorded in Postgres.
5. Recipient receives transfer event via Realtime and downloads chunks.
6. Recipient reassembles chunks in order into target file path.
7. Recipient recomputes SHA-256 and compares with sender hash.
8. Transfer marked complete only after hash match.

### Chunk persistence (target)

- Binary chunks: Supabase Storage objects.
- Transfer/session/chunk state: Supabase Postgres tables.
- Local progress cursor: client-side durable storage (e.g., SQLite/shared prefs equivalent), exact mechanism TBD.

### Current status

- `❌ Not implemented`: no chunk split/upload/reassembly/hash flow in code yet.

---

## 8) Security Considerations

- **Transport security:** HTTPS/TLS for all client-backend traffic (target).
- **Integrity:** end-to-end file SHA-256 verification at recipient before completion (target).
- **Short-code design:** code should not be treated as authentication; it is a routing/discovery token only.
- **Abuse controls (target):** rate limiting and transfer expiration windows should be added server-side.

Current codebase does not yet implement these controls.

---

## 9) Platform Channel Work

### Current status

- `❌ Not implemented`: no platform channel/native transfer service integration has been added yet.

### Planned native work

- Android:
  - Foreground Service lifecycle bridge.
  - Notification progress updates.
  - WorkManager enqueue/recover hooks.
- iOS:
  - Background `URLSession` delegate bridge.
  - Relaunch callback handling for completed background transfers.

---

## 10) Known Limitations

This section is intentionally direct:

- Current repository is still a Flutter starter app, not a transfer-capable build.
- No Supabase integration exists yet (DB/Realtime/Storage).
- No resumable transfer engine or chunk queue is implemented.
- No background transfer infrastructure exists on Android/iOS.
- iOS background behavior remains a high-risk area even after implementation due to OS scheduling constraints.
- Android OEM battery policies can still interrupt long transfers even with recommended patterns.
- WebRTC path is intentionally not implemented in current scope.

---

## 11) Devices Tested

- Android real device(s)
- Android emulator

No iOS device/simulator verification has been performed for this repository yet.

---

## 12) Walkthrough Summary

### Target demo flow

1. Launch app on Device A and Device B.
2. Device B exposes a short recipient code.
3. Device A enters code, selects file, and starts transfer.
4. Recipient sees incoming transfer and accepts.
5. Transfer progresses chunk-by-chunk with realtime status.
6. Simulate network drop / app background / process kill.
7. Resume transfer and verify final SHA-256 match.

### Current walkthrough reality

- Only basic Flutter counter app flow is available in current codebase.
- Full transfer walkthrough cannot be demonstrated until transfer and backend components are implemented.

---

## 13) AI Tool Usage

- **Tool used:** Cursor (AI-assisted IDE workflow).
- **AI-assisted work:** README structuring, checklist coverage against assessment requirements, wording cleanup.
- **Manual engineering decisions:** architecture choices, transport trade-offs, failure model framing, and explicit implementation-status honesty.
- **Policy followed:** avoided claims that are not backed by current repository code.

---

## Repository Status Snapshot

- App code currently matches Flutter starter template in `lib/main.dart`.
- This README documents the intended high-bar system design and a transparent implementation gap analysis.
