## Relevant Files

- `NutritionAIApp.swift` - App entry point that wires the root environment, onboarding gate, and main navigation.
- `App/RootTabView.swift` - Main tab shell for `Capture`, `Journal`, and `Goals`.
- `App/AppEnvironment.swift` - Shared dependency container for AI, nutrition lookup, history, and goals services.
- `Features/Onboarding/OnboardingView.swift` - Welcome and skippable body-metrics onboarding flow.
- `Features/Goals/BodyMetricsView.swift` - Body-metrics entry and calorie-goal setup UI.
- `Features/Goals/GoalsView.swift` - Goals dashboard for calorie/macro progress and small-chart trends.
- `Features/Goals/GoalsViewModel.swift` - Aggregates saved meals into Today / 7 Days / 30 Days progress and trend data.
- `Features/Capture/CaptureView.swift` - Entry screen for camera capture, photo picker, and routing into text entry.
- `Features/Capture/CaptureViewModel.swift` - State and routing logic for photo capture, optional hint entry, and draft creation.
- `Features/Capture/TextEntryView.swift` - Text-only meal input screen that feeds the same draft pipeline.
- `Features/ReviewIngredients/IngredientReviewView.swift` - Main review/edit screen for detected ingredient rows before calculation.
- `Features/ReviewIngredients/IngredientRowView.swift` - Reusable editable ingredient row with search, amount, unit, and delete controls.
- `Features/ReviewIngredients/IngredientReviewViewModel.swift` - Draft editing, validation, add/remove actions, and calculate trigger logic.
- `Features/Results/NutritionResultsView.swift` - Results screen showing totals and explicit `Save Meal`.
- `Features/Journal/JournalView.swift` - Saved-meal list screen.
- `Features/Journal/MealDetailView.swift` - Saved-meal detail screen showing totals, ingredients, and original input context.
- `Features/Journal/JournalViewModel.swift` - Local journal projection, delete actions, and duplicate-as-new entry point.
- `Domain/Models/MealDraft.swift` - Draft meal model for photo/text input plus editable ingredient rows.
- `Domain/Models/IngredientDraft.swift` - Editable ingredient name, amount, and unit model.
- `Domain/Models/NutritionTotals.swift` - Calories and macro totals for calculated meals.
- `Domain/Models/SavedMeal.swift` - Persisted meal record including retention-aware photo metadata.
- `Domain/Models/BodyMetrics.swift` - User body metrics and calorie-goal input model.
- `Domain/Models/TrendSnapshot.swift` - Aggregate progress and chart-ready trend snapshot model.
- `Services/AI/OpenRouterMealIdentificationService.swift` - OpenRouter-backed service that requests strict JSON ingredient extraction.
- `Services/AI/MealIdentificationParser.swift` - Parses and validates model JSON into editable ingredient draft rows.
- `Services/Search/IngredientNormalizationService.swift` - Normalizes ingredient text and applies synonym cleanup before USDA search.
- `Services/Nutrition/USDANutritionRepository.swift` - USDA FoodData Central lookup and nutrition aggregation service.
- `Services/History/MealHistoryStore.swift` - In-memory state store for saved meals and aggregates.
- `Services/History/MealHistoryRepository.swift` - Local persistence for 365-day text/history retention.
- `Services/Retention/MealRetentionService.swift` - Enforces 30-day photo retention and 365-day meal retention.
- `Services/Goals/CalorieGoalCalculator.swift` - Reused TDEE/body-metrics goal calculation logic derived from the inspiration app.
- `Services/Configuration/AppConfig.swift` - Developer-provided config values for OpenRouter and USDA integration.
- `NutritionAITests/MealIdentificationParserTests.swift` - Unit tests for JSON parsing and invalid/vague-response handling.
- `NutritionAITests/IngredientNormalizationServiceTests.swift` - Unit tests for synonym cleanup and normalized lookup input.
- `NutritionAITests/USDANutritionRepositoryTests.swift` - Unit tests for lookup aggregation, skipped ingredients, and warning generation.
- `NutritionAITests/MealHistoryStoreTests.swift` - Unit tests for save, delete, duplicate, aggregation, and retention behavior.
- `NutritionAITests/CalorieGoalCalculatorTests.swift` - Unit tests for body-metrics-based goal calculation.
- `NutritionAITests/GoalsViewModelTests.swift` - Unit tests for Today / 7 Days / 30 Days progress and small-chart data.
- `NutritionAIUITests/CaptureFlowUITests.swift` - UI tests for capture/text entry into the review flow.
- `NutritionAIUITests/ReviewAndSaveFlowUITests.swift` - UI tests for review, calculate, save, and duplicate-as-new flows.
- `NutritionAIUITests/GoalsFlowUITests.swift` - UI tests for onboarding skip, incomplete goals state, and body-metrics completion.

### Notes

- The current repo does not yet contain the iOS app target, so the paths above are proposed implementation paths rather than existing files.
- Prefer feature-based grouping so capture, review, results, journal, and goals can evolve independently.
- Unit tests can live in `NutritionAITests/` if the Xcode target uses a separate test bundle rather than colocated Swift files.
- Reuse logic patterns from the `Quick Meal Check` app at `/Users/paze/Documents/_Projects/Quick Meal Check/Quick Meal Check` for body metrics, history aggregation, and range-based goal summaries, but do not copy its auth flow or hidden save interactions.


## Tasks

- [ ] 1. Create the app shell and dependency architecture
  - [ ] 1.1 Initialize the iOS app target and establish a feature-based folder structure for onboarding, capture, review, results, journal, and goals.
  - [ ] 1.2 Add an app environment/dependency container for OpenRouter identification, USDA lookup, local history, retention, and calorie-goal calculation services.
  - [ ] 1.3 Create the root navigation shell with tabs for `Capture`, `Journal`, and `Goals`.
  - [ ] 1.4 Add configuration plumbing for developer-provided OpenRouter and USDA credentials without exposing user-managed key UI in MVP.

- [ ] 2. Define the core domain models and service contracts
  - [ ] 2.1 Create models for meal drafts, editable ingredient rows, nutrition totals, saved meals, body metrics, and trend snapshots.
  - [ ] 2.2 Define protocols/interfaces for AI identification, nutrition lookup, history persistence, retention cleanup, and calorie-goal calculation.
  - [ ] 2.3 Define how photo-based meals store expirable image metadata separately from longer-lived meal text and nutrition data.

- [ ] 3. Implement onboarding and calorie-goal setup
  - [ ] 3.1 Build a first-launch onboarding flow that introduces the app and offers skippable body-metrics setup.
  - [ ] 3.2 Reuse the body-metrics and TDEE-style goal calculation logic from `/Users/paze/Documents/_Projects/Quick Meal Check/Quick Meal Check` for calorie targets.
  - [ ] 3.3 Persist body metrics locally and expose an incomplete Goals state when onboarding is skipped.
  - [ ] 3.4 Add entry points from the Goals tab to complete or update body metrics later.

- [ ] 4. Build the meal input flows
  - [ ] 4.1 Implement the main capture screen with camera/photo input and entry into the text-only flow.
  - [ ] 4.2 Add the optional text hint step after photo capture and before AI identification.
  - [ ] 4.3 Implement the text-only input screen for free-form meal descriptions.
  - [ ] 4.4 Normalize both input modes into a shared meal-draft pipeline so both routes feed the same review screen.

- [ ] 5. Implement the OpenRouter ingredient-identification pipeline
  - [ ] 5.1 Build an OpenRouter-backed service that sends photo+hint or text-only input and requests strict JSON output.
  - [ ] 5.2 Parse model responses into ingredient rows with name, amount, and unit fields.
  - [ ] 5.3 Validate malformed responses and surface incomplete drafts or actionable errors instead of silently accepting bad output.
  - [ ] 5.4 Treat vague quantities as user-correctable review data in MVP rather than performing automatic retry loops.

- [ ] 6. Build the ingredient review and editing experience
  - [ ] 6.1 Create the Review Ingredients screen that lists editable ingredient rows before any final nutrition totals are shown.
  - [ ] 6.2 Implement searchable ingredient-name editing over normalized ingredient names.
  - [ ] 6.3 Implement structured quantity editing with unit-specific controls for grams, ml, servings, cups, tbsp, tsp, slices, and pieces.
  - [ ] 6.4 Add support for adding and removing ingredient rows, including search-first add flow.
  - [ ] 6.5 Add validation rules that prevent obviously incomplete rows from proceeding to calculation.

- [ ] 7. Implement USDA-backed nutrition lookup and total calculation
  - [ ] 7.1 Create an ingredient-normalization service that cleans up ingredient names and applies synonym mapping before lookup.
  - [ ] 7.2 Implement USDA FoodData Central search and nutrition retrieval behind a repository/service abstraction.
  - [ ] 7.3 Calculate total calories, protein, carbs, and fat from the final edited ingredient list when the user taps `Calculate`.
  - [ ] 7.4 Skip unmatched ingredients and generate user-facing warnings while still returning totals for matched ingredients.

- [ ] 8. Build the results and save flow
  - [ ] 8.1 Create the results screen showing only final calories and macro totals for MVP.
  - [ ] 8.2 Replace hidden save interactions with an explicit `Save Meal` action.
  - [ ] 8.3 Save the final edited ingredient list, original input context, calculated totals, and optional photo data into local history.
  - [ ] 8.4 Route saved results back into Journal and Goals so both update immediately after save.

- [ ] 9. Implement local persistence and retention policies
  - [ ] 9.1 Build a local meal-history repository that retains meal text and nutrition data for 365 days.
  - [ ] 9.2 Build retention cleanup that deletes stored photo data after 30 days while preserving the meal record.
  - [ ] 9.3 Prune entire meal records that exceed the 365-day retention window.
  - [ ] 9.4 Run retention cleanup on app launch and after relevant save operations.

- [ ] 10. Build the Journal and meal-detail flows
  - [ ] 10.1 Implement the Journal list for saved meals with clear date grouping and summary information.
  - [ ] 10.2 Implement the meal-detail screen showing nutrition totals, final ingredient list, and original photo or text input when available.
  - [ ] 10.3 Add delete actions from journal/detail flows.
  - [ ] 10.4 Add `Duplicate` from meal detail that opens a new editable draft with ingredients prefilled.

- [ ] 11. Build the Goals experience and trend views
  - [ ] 11.1 Aggregate saved meals into Today / 7 Days / 30 Days calorie and macro summaries.
  - [ ] 11.2 Build progress UI for current calories versus the user’s calorie goal.
  - [ ] 11.3 Add small charts for calorie and macro trends in the Goals tab.
  - [ ] 11.4 Show an incomplete-state UI when body metrics have not been provided yet.

- [ ] 12. Add automated tests and implementation verification
  - [ ] 12.1 Add unit tests for AI response parsing, ingredient normalization, USDA calculation, retention rules, and goal calculation.
  - [ ] 12.2 Add unit tests for journal save/delete/duplicate behavior and Today / 7 Days / 30 Days aggregation.
  - [ ] 12.3 Add UI tests covering onboarding skip, capture/text entry, review/edit, calculate, save, journal detail, and duplicate-as-new flows.
  - [ ] 12.4 Verify the final implementation against the PRD acceptance criteria and update the repo file maps as files are added.
