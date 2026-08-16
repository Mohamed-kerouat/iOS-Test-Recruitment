# REFLECTION.md

## Project Overview

This is a small SwiftUI classifieds app backed by the local API server. It provides a listing feed with category filtering, search, loading/error/empty states, and a detail view for each listing.

I treated it as a production slice rather than a UI-only exercise, focusing on the areas the README explicitly evaluates: product judgment, clean and testable architecture, accessibility, and explicit handling of ambiguity.

---

## AI Usage

### Tools Used

I used AI assistants (GitHub Copilot) throughout the project as development aids, not as decision-makers:

1. **Planning** — drafting user stories, an architecture doc, and a task roadmap before writing any code, so implementation followed a plan rather than accreting decisions ad hoc.
2. **Boilerplate and model generation** — an initial pass at `Codable` model structures after I mapped the Swagger contract and the live server responses by hand.
3. **Implementation support** — in-editor suggestions while building the ViewModel, repository, and views.
4. **French localization** — drafting the French strings, then reviewing tone and correcting anything that read too literally translated.

Every suggestion was reviewed against the actual requirements, the real server behavior, or a concrete tradeoff before I accepted it. The examples below are less about "AI got something wrong" and more about where my judgment had to override or refine a plausible-sounding suggestion.

---

## AI Suggestions I Rejected or Reworked

### 1. Additional abstraction layers

One suggestion was to introduce a Coordinator pattern and a dedicated use-case/interactor layer on top of the existing Repository, anticipating that the app might grow. I decided against it:

- the app has two screens and one data source — there's nothing for those layers to actually separate yet
- it would add indirection a reviewer has to trace through, with no corresponding gain in clarity or testability
- the existing seam (`View → ViewModel → Repository → APIClient`) already gives full mockability and testability without it

I kept the structure flat and explicit instead. Over-architecting a small app is its own kind of poor judgment, and the README explicitly rewards depth over unnecessary breadth.

### 2. Combine for the search feature

The case for a Combine `.debounce()` / `.removeDuplicates()` chain was legitimate — it's the standard pattern for exactly this kind of input handling and would have been a few lines more concise than what I built. I chose `Task` + `Task.sleep` instead:

- cancelling the task cancels whatever it's currently awaiting — the debounce wait or the network call — without composing operators to get that behavior
- I could inject the debounce duration directly into the ViewModel, so tests don't need a scheduler or virtual clock, just a short duration
- the rest of the app is already async/await, so this keeps one concurrency model in the file instead of two

This wasn't a case of the suggestion being wrong — it was a real tradeoff, and I gave up some conciseness in exchange for simpler cancellation semantics and consistency with the rest of the codebase.

### 3. Trusting the swagger's nullability over the live server

The image fields (`images_url.small` / `.thumb`) are documented in `swagger.yaml` as required, non-nullable strings. When I checked actual responses from the running server, listings without an image return an empty object (`{}`) — not what the spec describes, and not null either, just absent keys. I modeled both fields as optional, so a missing key decodes to `nil` automatically, rather than trusting the documented contract over what the server actually sends. A small fix, but one that only surfaces if you check real data instead of coding straight from the spec.

---

## Architectural Decisions I Owned

### MVVM with a thin Repository layer

`View → ViewModel → Repository → APIClient → URLSession`. Views stay declarative; ViewModels hold screen state and coordinate; the Repository isolates URL and query construction and gives the ViewModel a stable, mockable boundary. I kept the Repository deliberately small — its only job is separating screen logic from networking details, not becoming a second business-logic layer.

### Explicit state with `ViewState<Value>`

Instead of independent `isLoading`, `error`, and `items` properties, I modeled each screen with a single enum: loading, loaded, empty, error. This makes the possible UI states mutually exclusive by construction, rather than relying on discipline to avoid contradictory combinations like "loading" and "error" being true at once.

### Protocol seams, kept narrow

`APIClientProtocol` and `ListingsRepositoryProtocol` exist so real network calls can be swapped for test doubles. I kept both protocols intentionally small rather than exposing every conceivable method, to avoid a fragile "everything everywhere" interface that's harder to reason about and to test against.

### `@MainActor` on the ViewModel

Marking the ViewModel `@MainActor` means published state updates land on the main actor automatically, which is cleaner than manually dispatching and removes a class of threading mistakes before they can happen.

### Search with structured concurrency

Search was the one bonus feature I implemented, built with `Task` + `Task.sleep` for the reasons covered above. The ViewModel keeps two buffers — the full feed from the initial load, and the latest search results — so clearing the search text restores the feed without an unnecessary refetch.

### Environment injection for app configuration

Views read the API base URL via `@Environment(\.apiBaseURL)` rather than reaching for a global directly. `AppConfig` resolves the actual value once at the app's entry point — checking for an Xcode-scheme environment-variable override, useful for testing against a physical device, before falling back to `localhost:8080` — and SwiftUI's environment distributes it down the view tree. This is a different injection style than the protocol-based injection used across the ViewModel/Repository boundary, and deliberately so: it's only ever consumed inside View bodies, not something a unit test needs to substitute.

---

## Product and UX Decisions

The listing screen provides: image, category, title, price, urgent indicator, category filtering, search, a visible loading state, a recoverable error state, and an intentional empty state — distinguished both from "still loading" and from "something broke."

The detail screen presents the fields the API actually returns, in a clear hierarchy: image, title, price, urgency, category, date, description. I deliberately didn't invent information the API doesn't provide, since the README's "feel complete and readable" requirement is intentionally open-ended rather than a fixed spec.

Both missing and failed images resolve to the same placeholder, so a listing without a photo — or with a photo that fails to load — never looks like a bug.

---

## Accessibility

Interactive elements — category filter, retry action, row navigation, back navigation — have meaningful accessibility labels. Listing images carry descriptive labels where they convey information, and decorative elements are hidden from VoiceOver rather than read aloud redundantly. Text uses Dynamic Type-compatible system fonts rather than fixed sizes, so it responds to the user's accessibility settings instead of clipping or truncating at larger sizes.

---

## Testing

I included a small set of automated tests covering distinct behaviors rather than maximizing coverage: decoding (including the server's empty-object case for missing images), category filtering preserving API order, and ViewModel state transitions. They're deterministic and don't require the local server running. Beyond that, correctness for the rest of the app came from manually exercising the flows end-to-end — including a full VoiceOver pass and testing at larger Dynamic Type sizes — rather than from writing additional automated coverage for its own sake.

---

## Ambiguity in the Prompt/API, and How I Handled It

### 1. `price` is typed as a number, not an integer

Every sample value in the fixture data happens to be a whole number, but the swagger types `price` as `number`. I modeled it as `Double` to match the documented type rather than the shape of the sample data, to avoid silent truncation if the payload ever includes decimals.

### 2. Display order is server-authoritative

The README states the feed is already returned in the correct order (urgent-first, then by descending date). I deliberately never re-sort on the client — category filtering and search both preserve the original array order by filtering, not by re-sorting.

### 3. Detail screen completeness is subjective

There's no explicit field list for the detail screen. I chose to present exactly what the API provides, in a deliberate hierarchy, rather than guess at additional information that isn't there.

---

## Scope and Tradeoffs

I prioritized the core listing and detail experience, plus one bonus feature done properly, over spreading effort across multiple partially-finished extras. Search was that one bonus — chosen because it exercises debounce, cancellation, and state replacement.

The same principle applied to architecture: MVVM with a thin Repository layer, no Coordinator, no additional abstraction layers beyond what this app's size actually needs. The goal throughout was judgment over volume — a smaller, well-reasoned submission over a larger one with undocumented tradeoffs.
