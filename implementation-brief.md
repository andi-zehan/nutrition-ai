# Implementation Brief – NutritionAI MVP

## Build Strategy
- Build a new iOS app in this repo from scratch.
- Use `/Users/paze/Documents/_Projects/Quick Meal Check/Quick Meal Check` as an inspiration repo and selective source of reusable logic.
- Do not fork or clone the full `Quick Meal Check` app structure into this repo.

## Why This Approach
- The NutritionAI MVP has a different primary flow:
  - `capture/text -> ingredient review -> USDA calculate -> explicit save`
- The inspiration app is built around different assumptions:
  - auth-gated entry
  - Firebase-backed image analysis
  - AI-produced final nutrition
  - implicit/overlay-oriented save flow
- Starting fresh avoids spending implementation time removing architecture that the MVP does not want.

## Reuse From The Inspiration Repo
Reuse these areas intentionally, adapting them to the new app rather than copying entire features wholesale.

### High-value logic to reuse
- Body metrics and calorie-goal calculation patterns from:
  - `/Users/paze/Documents/_Projects/Quick Meal Check/Quick Meal Check/Quick Meal Check/Settings/BodyMetricsViewModel.swift`
- Meal history aggregation and range snapshot patterns from:
  - `/Users/paze/Documents/_Projects/Quick Meal Check/Quick Meal Check/Quick Meal Check/Stores/MealHistoryStore.swift`
  - `/Users/paze/Documents/_Projects/Quick Meal Check/Quick Meal Check/Quick Meal Check/Models/MealEntry.swift`
  - `/Users/paze/Documents/_Projects/Quick Meal Check/Quick Meal Check/Quick Meal Check/Services/MealHistoryRepository.swift`
- Camera/photo acquisition helpers if useful:
  - `/Users/paze/Documents/_Projects/Quick Meal Check/Quick Meal Check/Quick Meal Check/CameraService.swift`
  - `/Users/paze/Documents/_Projects/Quick Meal Check/Quick Meal Check/Quick Meal Check/PhotoLibraryPicker.swift`
  - `/Users/paze/Documents/_Projects/Quick Meal Check/Quick Meal Check/Quick Meal Check/Utilities/ImageResizer.swift`
- Goals aggregation and time-range presentation patterns from:
  - `/Users/paze/Documents/_Projects/Quick Meal Check/Quick Meal Check/Quick Meal Check/Views/NutritionIndicatorsView.swift`
- Useful test patterns from:
  - `/Users/paze/Documents/_Projects/Quick Meal Check/Quick Meal Check/Quick Meal CheckTests/BodyMetricsViewModelTests.swift`
  - `/Users/paze/Documents/_Projects/Quick Meal Check/Quick Meal Check/Quick Meal CheckTests/MealHistoryStoreTests.swift`
  - `/Users/paze/Documents/_Projects/Quick Meal Check/Quick Meal Check/Quick Meal CheckTests/CalorieGaugeCalculatorTests.swift`

### Reuse style
- Reuse logic and data-shaping patterns.
- Rename types freely to fit the new architecture.
- Prefer extracting algorithms and persistence patterns over copying whole views.
- Keep one primary type per file in the new codebase.

## Do Not Reuse As-Is
Do not bring these parts over unchanged:

- Auth and session gating:
  - `/Users/paze/Documents/_Projects/Quick Meal Check/Quick Meal Check/Quick Meal Check/Views/RootContentView.swift`
  - `/Users/paze/Documents/_Projects/Quick Meal Check/Quick Meal Check/Quick Meal Check/Stores/AuthSessionStore.swift`
  - `/Users/paze/Documents/_Projects/Quick Meal Check/Quick Meal Check/Quick Meal Check/Views/AuthenticationView.swift`
- Firebase analysis pipeline:
  - `/Users/paze/Documents/_Projects/Quick Meal Check/Quick Meal Check/Quick Meal Check/Services/FirebaseMealAnalysisService.swift`
  - `/Users/paze/Documents/_Projects/Quick Meal Check/Quick Meal Check/Quick Meal Check/Services/MealAnalysisFunctionResponseParser.swift`
  - `/Users/paze/Documents/_Projects/Quick Meal Check/Quick Meal Check/Quick Meal Check/Support/FirebaseConfigurator.swift`
- Old AI-final-nutrition flow and save behavior:
  - `/Users/paze/Documents/_Projects/Quick Meal Check/Quick Meal Check/Quick Meal Check/ImagePresentationView.swift`
  - `/Users/paze/Documents/_Projects/Quick Meal Check/Quick Meal Check/Quick Meal Check/TextMealAnalysisView.swift`
  - `/Users/paze/Documents/_Projects/Quick Meal Check/Quick Meal Check/Quick Meal Check/Views/MealAnalysisOverlayView.swift`
- Current capture-screen interaction density and shortcut-heavy navigation:
  - `/Users/paze/Documents/_Projects/Quick Meal Check/Quick Meal Check/Quick Meal Check/ImageAcquisitionView.swift`

## Target Architecture
Build the new app around these primary modules:

- `App`
  - app entry
  - dependency container
  - root tab navigation
- `Features/Onboarding`
  - welcome
  - optional body metrics
- `Features/Capture`
  - camera/photo entry
  - text entry
  - optional photo hint
- `Features/ReviewIngredients`
  - editable ingredient rows
  - add/remove/search
  - calculate trigger
- `Features/Results`
  - final calories/macros
  - explicit `Save Meal`
- `Features/Journal`
  - meal list
  - meal detail
  - duplicate-as-new
- `Features/Goals`
  - body metrics
  - calorie progress
  - macro progress
  - Today / 7 / 30 trends
- `Services`
  - OpenRouter ingredient identification
  - USDA nutrition lookup
  - local history persistence
  - retention cleanup

## Build Order
Implement in this order:

1. Foundation
- Create the new app target and root tab structure.
- Add domain models and service protocols.
- Add app configuration for developer-provided OpenRouter and USDA credentials.

2. Goals foundation
- Port/adapt body-metrics and calorie-goal calculation logic.
- Build onboarding with skippable body metrics.
- Build incomplete Goals state.

3. History foundation
- Build local meal persistence.
- Build history retention rules:
  - meal text/data for 365 days
  - photos for 30 days
- Build journal list from local data.

4. Capture foundation
- Build photo input and text-only input.
- Add optional text hint after photo capture.
- Normalize both flows into a single draft model.

5. AI identification
- Build OpenRouter identification service.
- Define and parse strict JSON ingredient output:
  - ingredient name
  - amount
  - unit
- Surface malformed output as actionable failure.

6. Ingredient review
- Build searchable ingredient editing.
- Add structured amount/unit editing.
- Add add/remove ingredient actions.

7. USDA calculation
- Normalize ingredient names.
- Perform USDA lookup through a repository abstraction.
- Calculate total calories and macros.
- Warn on skipped unmatched ingredients.

8. Results and save
- Build explicit results screen.
- Add explicit `Save Meal`.
- Save final edited ingredients and original input context.

9. Journal detail and duplicate flow
- Build meal detail.
- Add delete.
- Add duplicate-as-new into the draft/review flow.

10. Goals polish
- Connect saved meals into Today / 7 / 30 goal summaries.
- Add small charts for calories and macros.

11. Testing
- Add unit tests for:
  - goal calculation
  - history retention
  - ingredient parsing
  - USDA aggregation
  - journal duplication
- Add UI tests for:
  - onboarding skip
  - capture/text entry
  - ingredient review
  - calculate/save
  - duplicate-as-new

## Non-Negotiable Product Rules
- Do not require login in MVP.
- Do not expose user-managed OpenRouter key entry in MVP.
- Do not trust the model for final nutrition totals.
- Always route model output through the ingredient review step before calculation.
- Use explicit buttons for `Analyze`, `Calculate`, and `Save Meal`.
- Keep Journal and Goals as stable tabs, not hidden shortcuts from analysis screens.

## Key Technical Rules
- Keep OpenRouter integration behind a dedicated service interface.
- Keep USDA integration behind a dedicated repository/service interface.
- Keep local persistence separate from view models.
- Make future Firebase migration possible without rewriting feature screens.
- Prefer SwiftUI-native patterns and avoid carrying UIKit-heavy architecture unless required by camera/photo APIs.

## First Milestone Definition
The first meaningful milestone should include:
- New app target booting successfully.
- Root tabs in place.
- Onboarding implemented.
- Body metrics and calorie goal logic working.
- Local history model/repository created.

Do not start with camera polish, overlays, or visual refinement before this milestone is complete.

