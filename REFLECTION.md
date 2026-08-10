# REFLECTION.md

## AI tool usage

Which tools, and for what:
- Used ChatGPT/Copilot to speed up first-pass scaffolding for Codable models, architecture notes, and a structured day-by-day implementation plan.
- Used AI suggestions as drafts, then validated against `README.md`, `server/swagger.yaml`, and live API payloads.

At least one concrete suggestion I rejected, corrected, or rewrote:
- An early suggestion treated `images_url.small` and `images_url.thumb` as always non-null and encouraged direct URL rendering. I rejected that because real payloads include empty `images_url` objects and nullable image paths. I modeled `images_url` and nested fields as optional and planned one shared placeholder path in UI.

## Architectural decisions I owned

- Chose `View -> ViewModel -> Repository -> APIClient -> URLSession` (MVVM + thin repository) so ViewModels remain unit-testable without server runtime.
- Chose protocol seams (`APIClientProtocol`, `ListingsRepositoryProtocol`) for deterministic mocks and stable tests.
- Chose explicit state modeling (`ViewState<Value>`) so loading/error/empty are mutually exclusive and retry behavior is explicit.

## Ambiguity in the prompt or API, and how I handled it

- `images_url` contract is nullable in Swagger but often appears as `{}` in real data. I treated `images_url` as optional and nested properties as optional.
- `price` is declared as `number` in Swagger while many payload values are integer-like. I chose `Double` to stay contract-correct.
- A subset of rows contains broken image filenames (for example `poisoned-image.jpg`). I treated this as expected runtime failure and planned one reusable placeholder behavior for both missing and failed image loads.

### Swagger vs current API response differences observed

- `images_url` in Swagger is marked `nullable: true` with `small` and `thumb` required keys (but nullable values), while current JSON sometimes returns an empty object `{}` with no `small`/`thumb` keys.
- Swagger examples show valid image filenames, while current JSON includes intentionally broken paths (`poisoned-image.jpg`) that still match the string type but fail at runtime image loading.
- Swagger models `price` as `number`; current JSON frequently sends whole-number values. This is compatible but easy to model incorrectly as `Int`.


