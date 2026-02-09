# Internal Architecture Documentation (Zipp&Go)

## 🏗️ Firestore Schema
### Collection: `deliveries`
| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | Document ID |
| `customerId` | `String` | User UID of the sender |
| `riderId` | `String?` | User UID of the rider (assigned on acceptance) |
| `status` | `String` | Enum: `pending`, `accepted`, `picked`, `completed` |
| `price` | `double` | Estimated delivery cost |
| `pickupZoneName`| `String` | Denormalized zone name for fast display |
| `pickupAddress` | `String` | Detailed address for pickup |
| `events` | `Array<Map>` | Audit trail of status changes with timestamps |
| `pickupPhotoUrl`| `String?` | Proof of pickup |
| `dropoffPhotoUrl`| `String?` | Proof of delivery |

---

## 🔄 Professional Status Flow
1. **PENDING**: Delivery created by customer. Visible in "Available Jobs" for riders.
2. **ACCEPTED**: Rider accepts via transaction (concurrency protection). Audit event logged.
3. **PICKED**: Rider confirms pickup with photo proof. Audit event logged.
4. **COMPLETED**: Rider confirms drop-off with photo proof. Final audit event logged.

---

## 🎨 Design Tokens & UX
- **Colors**: Centralized in `lib/core/theme/app_colors.dart`.
- **UI Consistency**: Every button uses `CustomButton`, and images use `SafeNetworkImage` for fail-safe rendering.
- **Error Handling**: Standardized via SnackBars and loading state management in Bloc/Stateful components.

---

## ⚡ Performance Optimization
- **Denormalization**: Phone numbers and Zone names are stored directly on the delivery to avoid nested fetches.
- **Caching**: Zone prices are centralized in `AppConstants` to avoid repeated logic or network calls.
- **Real-time**: High-performance `StreamBuilder` used for live status tracking.

---

## ⚠️ Known Limitations
- Payment is currently an instruction-based flow (no API integration yet).
- Rider location tracking is not yet real-time (requires background location service).
- Media storage uses simulated upload delays for demo stability.
