# Frontend architecture audit

Audit date: 2026-08-11

Scope: every Dart source file under `lib/`. The audit is structural only; no UI,
state, routing, service, validation, or domain behavior was changed.

## Executive result

The frontend is consistently organized by feature at its top levels, but it is
not yet compliant with a strict one-widget-per-file policy. The main problem is
not the feature-first architecture itself; it is that some screens and widget
files still act as small UI modules containing several widget declarations or
private methods that manufacture widget subtrees.

Measured baseline:

- 1,435 Dart source files
- 1,049 `StatelessWidget`/`StatefulWidget` declarations
- 93 files declaring more than one widget class
- 68 private `_build...` methods returning `Widget`
- 51 files longer than 500 lines
- path depth reaches 11 segments; the recommended maximum is 8

The counts deliberately do not flag the required `StatefulWidget` + `State<T>`
pair as two widgets. Model, state, enum, extension, painter, and formatter
declarations are also not treated as widget violations merely because they share
a file. Those should be split only when they represent separate responsibilities.

## Highest-risk hotspots

1. `features/pharmaceutical/widgets/gln_pharmaceutical_extension_widget.dart`
   is 1,816 lines and contains 18 `_build...` widget factories. Split it into a
   feature-local form coordinator, independent section widgets, shared field
   widgets, and non-UI validation/serialization utilities.
2. `features/epcis/transformation_events/screens/transformation_event_form/`
   contains a 1,005-line screen with 9 widget factories. The screen should retain
   controllers, lifecycle, and submission orchestration only; fields and sections
   belong in sibling `widgets/` files.
3. `features/epcis/transaction_events/screens/transaction_document/` contains a
   724-line screen with 9 widget factories. Extract its sections, dropdowns,
   event list, status card, and related-documents card.
4. `features/barcode/screens/gs1_barcode_scanner/gs1_barcode_scanner_screen.dart`
   is 968 lines and declares 7 widgets. Move each widget to the existing feature
   boundary and leave the screen as composition/orchestration.
5. Skeleton, chart, operation-row, and automation-center files account for most
   of the remaining multi-widget declarations. Their private leaf widgets should
   become sibling files, while public entry widgets keep their current API.

## Folder architecture findings

The `lib/core` versus `lib/features` boundary is useful and should be retained:

- `core/widgets`: app-wide visual primitives with no feature dependency.
- `core/utils`: pure, non-UI, feature-agnostic functions only.
- `features/<feature>/widgets`: reusable within one feature.
- `features/<feature>/widgets/help_widgets`: help, guidance, examples, and
  explanatory UI for that feature. Screen-specific help components use the same
  `widgets/help_widgets` boundary beneath their owning screen.
- `features/<feature>/screens/<screen>`: route entry and screen-specific
  composition.
- `data`: transport, persistence, DTO/model, and service concerns; never widgets.

The deepest paths are mostly caused by repeating taxonomy in paths such as
`features/gs1/gtin/screens/gtin_detail/widgets/extensions/.../widgets`. Once a
directory is already a widget boundary, another `widgets` segment adds no useful
information. Prefer feature components such as
`features/gs1/gtin/detail/pharmaceutical/regulatory_authority/` and keep the
screen entry point in `detail/gtin_detail_screen.dart`.

Directory names must use lowercase `snake_case`. Existing `JourneyDashboard`,
`JourneyDetails`, and `Splash` directories are inconsistent with Dart package
conventions and can cause case-sensitive deployment failures. Rename them only
in an isolated, analyzer-clean change because import casing changes across many
files.

## Widget independence rules

1. One independently reusable widget class per Dart file.
2. A `StatefulWidget` and its private `State<T>` stay together; they are one
   lifecycle component, not two independent widgets.
3. A screen may own lifecycle, controllers, bloc wiring, navigation, and event
   handlers. It should compose named widgets instead of `_buildHeader`,
   `_buildCard`, `_buildList`, or `_buildSection` methods.
4. Tiny expressions that return a single icon, spacer, or text value do not need
   a new widget. Prefer a local variable or a pure value helper when there is no
   meaningful component boundary.
5. Painters, clippers, immutable view-data records, and tightly coupled private
   delegates may remain beside their sole owner unless they are reusable.
6. Extracted widgets receive the minimum immutable inputs and callbacks. They do
   not reach into a parent state object or duplicate business logic.

## Reuse policy

Promote a component to `core/widgets` only after it has at least two consumers in
different features and its API contains no feature model. Components reused by
screens inside one feature belong at `features/<feature>/widgets`. Pure format,
mapping, validation, and calculation code belongs in a feature `utils` folder,
or in `core/utils` only when it is genuinely feature-agnostic.

Before adding a component, check the existing app primitives, including loading,
empty/error states, buttons, GS1 fields, operation list/detail shells, and theme
tokens. Reuse by composition; do not create a generic widget with many booleans
that encodes unrelated feature variants.

## Safe remediation order

1. Add characterization/widget tests around each hotspot's visible states and
   callbacks.
2. Extract private leaf widget classes one at a time without changing constructor
   defaults, keys, layout widgets, padding, colors, or semantics.
3. Replace `_build...` methods with immutable widget classes, moving only UI code.
4. Deduplicate only after extraction exposes identical APIs; do not combine
   merely similar business behavior.
5. Flatten redundant directory segments and update imports in separate commits.
6. Run formatting, `flutter analyze`, targeted widget tests, the full test suite,
   and a web build after every batch.

## Repeatable check

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tool/frontend_architecture_audit.ps1
```

Use `-FailOnViolations` only after the baseline has been remediated. Enabling it
immediately would block unrelated work on known legacy findings.

## Verification note

The pre-change `flutter analyze --no-pub` baseline did not complete inside the
60-second audit window, so analyzer cleanliness cannot honestly be claimed from
this pass. The repository already contained an unrelated modification in
`lib/features/automation_center/screens/automation_center/utils/automation_center_sections.dart`;
it was not changed by this audit.
