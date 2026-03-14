# ShiftProof Swagger v2 Fixes

This file lists the exact changes to apply to your Swagger 2.0 spec to resolve the issues found in review.

## 1) Host / deployment target

- Replace `host: "localhost:8080"` with your real gateway host in deployed environments.
- Keep `localhost:8080` only for local development.

## 2) Path params + API Gateway routing

For operations that contain path parameters, do not use a full path in `x-google-backend.address` with `CONSTANT_ADDRESS`.

Use this pattern instead:

```json
"x-google-backend": {
  "address": "${CLOUD_RUN_URL}",
  "path_translation": "APPEND_PATH_TO_ADDRESS"
}
```

Apply to:

- `PATCH /api/v1/notifications/{id}/read`
- `GET /api/v1/properties/{id}`
- `PUT /api/v1/properties/{id}`
- `DELETE /api/v1/properties/{id}`

## 3) Strong request schema for device token

Add definition:

```json
"service.RegisterDeviceTokenRequest": {
  "type": "object",
  "required": ["token"],
  "properties": {
    "token": {
      "type": "string",
      "minLength": 1
    }
  }
}
```

Then update `POST /api/v1/auth/device-token` body schema reference to:

```json
"schema": {
  "$ref": "#/definitions/service.RegisterDeviceTokenRequest"
}
```

## 4) Idempotency field duplication

`POST /api/v1/payments` already has header `X-Idempotency-Key`.

- Remove `idempotencyKey` from `service.CreatePaymentRequest` body schema.

## 5) Missing auth error responses

For secured endpoints, add:

- `401` Unauthorized
- `403` Forbidden (for role-restricted endpoints)

At minimum, add to:

- `GET /api/v1/properties`
- `POST /api/v1/properties`
- `POST /api/v1/payments`
- `GET /api/v1/payments`
- `GET /api/v1/payments/collections`
- `GET /api/v1/payments/summary`
- `GET /api/v1/payouts`
- `GET /api/v1/plans`
- Notifications endpoints

Use `#/definitions/model.ErrorResponse`.

## 6) Replace description-only constraints with schema constraints

Add explicit `enum` and `format` where values are constrained:

- `model.AppUser.role`: enum `["owner", "tenant"]`
- `model.Notification.type`: enum `["rentDue", "message", "maintenance", "leaseRenewal", "general"]`
- `model.Payment.status`: enum `["paid", "pending", "overdue"]`
- `model.Payment.type`: enum `["rent", "deposit", "electricity", "maintenance"]`
- `model.Payout.status`: enum `["completed", "processing", "failed"]`
- `model.Property.type`: enum `["PG", "Flat", "House"]`

Date/time formats:

- Use `format: "date"` for `joinDate`, `dueDate`, `leaseStart`, `leaseEnd`, `date`
- Use `format: "date-time"` for notification `timestamp`

Numeric formats:

- Use `format: "int64"` for monetary amounts and large counters where applicable.
- Use `format: "float"` for `model.Property.rating`.

## 7) Pagination parameter constraints

For all `page` and `limit` query params:

- `page`: `minimum: 1`, `default: 1`
- `limit`: `minimum: 1`, `maximum: 100`, `default: 20`

## 8) Cleanup

- Remove `consumes` from `GET /api/v1/properties`.
- Retag `GET /api/v1/payouts` from `Plans` to `Payouts` (or `Payments`) for clarity.
- If using `Payouts`, add a `Payouts` tag object in top-level `tags`.

## 9) Firebase security definition (Gateway compatibility)

Prefer:

```json
"firebase": {
  "type": "oauth2",
  "flow": "implicit",
  "authorizationUrl": "",
  "x-google-issuer": "https://securetoken.google.com/${FIREBASE_PROJECT_ID}",
  "x-google-jwks_uri": "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com",
  "x-google-audiences": "${FIREBASE_PROJECT_ID}",
  "scopes": {}
}
```

## Validation result after these updates

- No critical contract blockers remain.
- Remaining items are optional hardening:
  - add operation-level examples for request/response payloads
  - add global `security` and override only public routes (like `/health`)
  - consider OpenAPI 3.0 migration for better tooling
