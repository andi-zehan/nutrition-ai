# Product Requirements Document (PRD) – NutritionAI MVP

## 1. Introduction / Overview
NutritionAI is an iPhone-first meal logging app that helps users estimate calories and macronutrients from either a meal photo or a text description. The app uses an OpenRouter-backed model to identify ingredients, quantities, and units, then gives the user a structured review step to edit ingredients before calculating nutrition from a caloric database source.

The core problem this app solves is that quick meal logging is currently either too manual or too unreliable. Users should be able to start with a photo or description, correct the detected ingredients, then save a meal entry with clearer and more trustworthy nutrition totals.

This MVP is inspired by the existing `Quick Meal Check` app located at `/Users/paze/Documents/_Projects/Quick Meal Check/Quick Meal Check`, but changes the core analysis flow from “AI returns final nutrition” to “AI identifies ingredients -> user reviews/edits -> app calculates from database -> user saves”.

## 2. Goals
- Let a user create a meal entry from either a photo or text input in under 60 seconds for common meals.
- Provide a structured ingredient review step before nutrition totals are finalized.
- Calculate final calories and macros from a caloric database rather than directly trusting the model output.
- Allow users to save meals into history and review calorie/macro progress against a personal calorie goal.
- Reuse the proven body-metrics / daily-calorie-goal logic from the existing app, while simplifying navigation and save behavior.

## 3. Product Scope Summary
### MVP
- iPhone-only app.
- Input via:
  - Photo with optional text hint.
  - Text-only meal description.
- OpenRouter-backed ingredient extraction.
- Structured JSON output from the model with ingredient names, quantities, and units.
- Ingredient review/edit screen where users can:
  - Edit ingredient names.
  - Edit quantities.
  - Edit units.
  - Add ingredients.
  - Remove ingredients.
- Nutrition calculation using USDA FoodData Central.
- Save meals to local history.
- Retain text/history data for 365 days.
- Retain photos for 30 days only.
- Goals screen with calorie and macro progress plus trends for Today / 7 Days / 30 Days.
- Onboarding that introduces body metrics, but allows the user to skip and complete them later.

### Post-MVP / Later Phase
- User login.
- Firebase-backed OpenRouter key management.
- Firebase-backed meal history sync.
- Firebase-backed caloric database / nutrition services.

## 4. Target User
- Primary target: consumer-facing MVP prototype intended for internal/dev/TestFlight use first.
- Users want a faster alternative to fully manual calorie tracking, while still being able to correct AI mistakes before saving.
- Users care most about calorie and macro tracking, not detailed micronutrient analysis in MVP.

## 5. User Stories
1. As a user, I want to take a photo of a meal and optionally add a short hint so that the app can infer the meal contents quickly.
2. As a user, I want to describe a meal in text when I do not have a photo so that I can still log it.
3. As a user, I want the app to return a clear ingredient list with quantities and units so that I can verify what it thinks I ate.
4. As a user, I want to edit ingredient rows before calculation so that I can correct wrong ingredients, amounts, or units.
5. As a user, I want to add or remove ingredients so that the final meal matches reality.
6. As a user, I want calories and macros to be calculated from a food database so that the result feels more trustworthy than a raw model guess.
7. As a user, I want to save meals and review history so that I can track what I have eaten over time.
8. As a user, I want to compare my current calorie intake against a daily target so that I can manage my diet.
9. As a user, I want to duplicate a saved meal into a new draft so that I can quickly log similar meals again without editing the original.

## 6. Primary User Flows
### Flow A: Photo Entry
1. User opens the app on the capture screen.
2. User takes a meal photo.
3. App offers an optional text hint before identification.
4. App sends the image plus optional hint to the OpenRouter-backed model.
5. Model returns structured JSON with ingredients, quantities, and units.
6. App shows the Review Ingredients screen.
7. User edits rows as needed.
8. User taps `Calculate`.
9. App calculates total calories and macros from USDA lookups.
10. App shows the results screen.
11. User taps `Save Meal`.
12. App writes the meal to local history and makes it available in Journal and Goals.

### Flow B: Text-Only Entry
1. User chooses text entry from the capture screen.
2. User enters a free-form meal description.
3. App sends the description to the OpenRouter-backed model.
4. Model returns structured JSON with ingredients, quantities, and units.
5. App shows the Review Ingredients screen.
6. User edits rows as needed.
7. User taps `Calculate`.
8. App shows the results screen.
9. User taps `Save Meal`.

### Flow C: Duplicate Saved Meal
1. User opens Journal.
2. User opens a saved meal detail screen.
3. User taps `Duplicate`.
4. App opens the capture/review flow with ingredients prefilled as a new draft.
5. User edits and saves as a new meal entry.

## 7. Functional Requirements
1. The system must support two meal-entry modes in MVP:
   - Photo with optional text hint.
   - Text-only description.
2. The system must send meal input to an OpenRouter-backed model for ingredient identification.
3. The model integration must request structured JSON output containing ingredient names, quantities, and units.
4. The system must reject or treat as incomplete any model response that does not provide structured JSON in the required shape.
5. The system must present a dedicated Review Ingredients screen before final nutrition totals are shown.
6. The Review Ingredients screen must display one editable row per ingredient.
7. Each ingredient row must allow editing of:
   - Ingredient name.
   - Quantity value.
   - Quantity unit.
8. Ingredient editing must support structured units rather than free-text-only quantities.
9. The app must support these units in MVP:
   - grams
   - ml
   - servings
   - cups
   - tbsp
   - tsp
   - slices
   - pieces
10. Quantity editing controls should match the selected unit type. Sliders may be used where appropriate, but the PRD does not require sliders for all units.
11. The Review Ingredients screen must allow the user to remove any ingredient row.
12. The Review Ingredients screen must allow the user to add a new ingredient.
13. Adding an ingredient must use a search-first experience over ingredient names.
14. Editing an ingredient name must support search/select behavior over normalized ingredient names rather than plain free-text only.
15. The app must not expose USDA match details in the MVP review UI.
16. The app must perform nutrition lookup through a local service/repository abstraction so that Firebase-backed services can replace it later without rewriting the UI flow.
17. The initial caloric database source for MVP must be USDA FoodData Central.
18. USDA lookup must normalize ingredient names and apply internal synonym cleanup before searching.
19. When the user taps `Calculate`, the app must recompute totals and replace previous totals.
20. The results screen must show final total:
   - Calories
   - Protein
   - Carbohydrates
   - Fat
21. The results screen must not require hidden gestures or card taps to save.
22. The results screen must provide an explicit `Save Meal` action.
23. The system must save the final edited ingredient list together with the meal entry.
24. The system must save photo-based entries with photos retained for 30 days.
25. The system must retain text/history data for 365 days.
26. When photo retention expires, the app must keep the meal entry and its nutrition data while removing the stored photo data.
27. If USDA lookup fails for an ingredient, the app must skip that ingredient and warn the user before or during result presentation.
28. For drinks and snacks, the app must support the same ingestible flow as meals in MVP.
29. If the model returns vague or unusable ingredient quantities, the app should show the result to the user for manual correction rather than silently retrying in MVP.
30. The app must support duplicate-as-new from saved meal detail screens.
31. Duplicating a meal must route the user back into the editable draft/review flow with prefilled ingredients.
32. The app must provide a Journal screen listing saved meals.
33. The Journal must provide a detail screen for each saved meal.
34. Journal detail must show:
   - Final nutrition totals
   - Final ingredient list
   - Original photo or original text input when available
35. The app must allow deletion of saved meals from Journal/detail flows.
36. The app must provide a Goals screen separate from Journal.
37. The Goals screen must show calorie progress against the user’s goal.
38. The Goals screen must show macro progress.
39. The Goals screen must show trends for:
   - Today
   - Last 7 Days
   - Last 30 Days
40. Goals trends in MVP must include small charts for calories and macros.
41. The app must reuse the existing body-metrics / daily-calorie-expenditure calculation approach from the inspiration app as closely as practical.
42. First-launch onboarding must introduce body metrics.
43. Body metrics onboarding must be skippable.
44. If the user skips body metrics onboarding, the Goals screen must remain incomplete until the user provides the required data.
45. The MVP must use a developer-provided OpenRouter key only.
46. The MVP must not require user login or account creation.
47. The MVP architecture should keep room for future login, cloud history, and backend-managed nutrition services.

## 8. Data Requirements
### Meal Draft Data
- Input source type: photo or text.
- Optional text hint for photo flow.
- Original text description when using text-only mode.
- Ingredient rows:
  - Ingredient name
  - Quantity amount
  - Quantity unit

### Saved Meal Data
- Meal ID
- Timestamp
- Input type
- Original text input when present
- Final edited ingredient list
- Total calories
- Total protein grams
- Total carb grams
- Total fat grams
- Stored photo thumbnail/full image for photo-based meals during the 30-day retention period

### Goal Data
- Body metrics needed for calorie goal calculation
- Calculated daily calorie goal
- Aggregated history totals for Today / 7 Days / 30 Days

## 9. Navigation and Information Architecture
The inherited app’s navigation is a useful reference, but the MVP should be simplified for a more explicit meal-entry flow.

Recommended MVP navigation:
- `Capture`
  - Photo entry
  - Text entry
- `Journal`
  - Meal list
  - Meal detail
- `Goals`
  - Body metrics
  - Current progress
  - Trends

Meal entry itself should be linear:
1. Capture or describe meal
2. Review Ingredients
3. Calculate
4. Results
5. Save Meal

This replaces the inspiration app’s more implicit save behavior and reduces hidden interaction patterns.

## 10. Design Considerations
- Use clear, explicit primary actions:
  - `Analyze`
  - `Calculate`
  - `Save Meal`
- Avoid hidden “tap the card to save” behavior.
- Keep photo and text flows visually aligned so users understand they converge to the same review step.
- Prioritize legibility and editing clarity over decorative overlays.
- Ingredient review rows should favor speed and correctness:
  - Searchable ingredient names
  - Clear amount/unit editing
  - Fast add/remove actions
- Journal and Goals should be persistent destinations rather than shortcut buttons hidden inside analysis screens.
- Reuse proven visual patterns from the inspiration app where helpful, but simplify the number of floating icon-only controls on primary screens.

## 11. Technical Considerations
- MVP should be implemented as a local-first iOS app without login.
- OpenRouter access should be abstracted behind a client/service layer.
- USDA lookup should be abstracted behind a nutrition repository/service layer.
- The app should store history locally in MVP, but the architecture should make it straightforward to move:
  - OpenRouter key management
  - History persistence
  - Caloric database access
  - Login/auth
  to Firebase-backed services later.
- The existing `Quick Meal Check` app at `/Users/paze/Documents/_Projects/Quick Meal Check/Quick Meal Check` should be used as implementation inspiration for:
  - Body metrics and calorie-goal calculation
  - Journal/history aggregation patterns
  - Goals time-range logic
- The existing `Quick Meal Check` app at `/Users/paze/Documents/_Projects/Quick Meal Check/Quick Meal Check` should not be copied unchanged in these areas:
  - Hidden save interactions
  - AI-generated final nutrition as the primary source of truth
  - Auth-gated app access for MVP
- Because the coding agent will build from this PRD, services and screens should be separated cleanly enough that photo input, AI parsing, ingredient editing, USDA calculation, history, and goals can be developed and tested independently.

## 12. Non-Goals (Out of Scope)
- Barcode scanning.
- Apple Health integration.
- Meal planning.
- Social/community features.
- Subscriptions/payments.
- Full micronutrient analysis in MVP.
- User-managed OpenRouter keys in MVP.
- Login/account UI in MVP.
- Firebase-backed history sync in MVP.
- Firebase-backed caloric database services in MVP.
- Direct in-place editing of already-saved meals.
- Forcing users to manually choose USDA matches for each ingredient in MVP.

## 13. Success Metrics
- Users can complete the ingredient extraction and review flow for common meals without abandoning the draft.
- Nutrition calculation succeeds for the majority of common meals after user review.
- Users can save completed meal entries successfully from the results screen.
- Journal and Goals screens reflect saved meals consistently.
- Internal MVP feedback indicates that the edit-before-calculate workflow feels more trustworthy than raw AI-only nutrition estimation.

## 14. Acceptance Criteria
- A user can start from either a photo or text description.
- A user can review a machine-generated ingredient list before nutrition totals are finalized.
- A user can add, remove, and edit ingredients, quantities, and units.
- The app calculates final calories and macros using USDA data rather than directly trusting model totals.
- The app shows explicit results and an explicit `Save Meal` button.
- Saved meals appear in Journal and affect Goals totals.
- Journal detail shows nutrition totals, ingredient list, and original input context.
- Goals show calorie progress, macro progress, and small-chart trends for Today / 7 Days / 30 Days.
- Body metrics can be skipped initially, but the app clearly shows when Goals is incomplete.
- Photo retention expires after 30 days without deleting the meal record.
- Text/history retention works for 365 days.

## 15. Open Questions
- Exact JSON schema to require from the OpenRouter model for ingredient rows.
- Exact heuristic/rules for synonym cleanup before USDA search.
- Exact chart style and visual density for the Goals trends screen.
- Exact retention implementation for removing photo data while preserving meal records.
- Whether future Firebase migration will preserve local-only history automatically or require a one-time import flow.

## 16. Suggested Screen List For Implementation
- Onboarding / Welcome
- Capture Screen
- Text Entry Screen or Sheet
- Review Ingredients Screen
- Nutrition Results Screen
- Journal Screen
- Meal Detail Screen
- Goals Screen
- Body Metrics Screen
