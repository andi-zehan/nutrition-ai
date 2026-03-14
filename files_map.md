# Project File Map

Last updated: 2026-03-14

## Root
### nutritionai_prd.md
Description: Product Requirements Document for the NutritionAI MVP.
### implementation-brief.md
Description: Build strategy, architecture, build order, and reuse guidance.
### tasks/tasks-nutritionai_prd.md
Description: Implementation task list derived from the PRD.
### project.yml
Description: XcodeGen project specification for generating NutritionAI.xcodeproj.
### Secrets.xcconfig
Description: Developer-provided API keys for OpenRouter and USDA (git-ignored).
### .gitignore
Description: Git ignore rules for secrets, build artifacts, and Xcode noise.

## App Shell
### NutritionAI/NutritionAIApp.swift
Description: App entry point with onboarding gate and environment setup.
### NutritionAI/App/RootTabView.swift
Description: Main tab navigation for Capture, Journal, and Goals.
### NutritionAI/App/AppEnvironment.swift
Description: Shared dependency container managing history store, retention, body metrics, and onboarding state.

## Domain Models
### NutritionAI/Domain/Models/IngredientDraft.swift
Description: Editable ingredient row with name, quantity, unit. Defines IngredientUnit enum.
### NutritionAI/Domain/Models/MealDraft.swift
Description: In-progress meal before calculation with input type, photo, text, and ingredient list.
### NutritionAI/Domain/Models/NutritionTotals.swift
Description: Calories and macros (protein, carbs, fat) value type with addition operator.
### NutritionAI/Domain/Models/SavedMeal.swift
Description: Persisted meal record with retention-aware photo metadata.
### NutritionAI/Domain/Models/BodyMetrics.swift
Description: User body metrics, BMR/TDEE/goal calculations using Mifflin-St Jeor.
### NutritionAI/Domain/Models/TrendSnapshot.swift
Description: Aggregated nutrition data for Today/7/30 day windows with macro percentages.

## Features
### NutritionAI/Features/Onboarding/OnboardingView.swift
Description: Welcome screen with skippable body metrics setup.
### NutritionAI/Features/Capture/CaptureView.swift
Description: Main capture screen with camera, photo picker, text entry, hint sheet, and navigation to review.
### NutritionAI/Features/Capture/CaptureViewModel.swift
Description: State management for photo/text capture, AI identification calls, and draft creation.
### NutritionAI/Features/Capture/TextEntryView.swift
Description: Free-form text meal description input sheet.
### NutritionAI/Features/ReviewIngredients/IngredientReviewView.swift
Description: Review/edit screen for AI-detected ingredients with add/remove and calculate trigger.
### NutritionAI/Features/ReviewIngredients/IngredientReviewViewModel.swift
Description: Draft editing, USDA calculation, unit conversion, and skipped ingredient tracking.
### NutritionAI/Features/ReviewIngredients/IngredientRowView.swift
Description: Single editable ingredient row with name, quantity, and unit picker.
### NutritionAI/Features/Results/NutritionResultsView.swift
Description: Results screen showing calorie/macro totals with explicit Save Meal button.
### NutritionAI/Features/Journal/JournalView.swift
Description: Date-grouped saved meal list with swipe delete and duplicate-as-new navigation.
### NutritionAI/Features/Journal/MealDetailView.swift
Description: Meal detail with nutrition, ingredients, photo, delete confirmation, and duplicate action.
### NutritionAI/Features/Goals/GoalsView.swift
Description: Goals dashboard with calorie progress, macro breakdown, bar/line trend charts (Swift Charts), and summary.
### NutritionAI/Features/Goals/BodyMetricsView.swift
Description: Body metrics entry form with live BMR/TDEE/goal calculation preview.

## Services
### NutritionAI/Services/Configuration/AppConfig.swift
Description: Reads API keys from Info.plist, defines model choice and API base URLs.
### NutritionAI/Services/AI/MealIdentificationService.swift
Description: Protocol for AI-backed ingredient identification (photo and text).
### NutritionAI/Services/AI/OpenRouterMealIdentificationService.swift
Description: OpenRouter GPT-4.1 Mini implementation with strict JSON schema for ingredients.
### NutritionAI/Services/AI/MealIdentificationParser.swift
Description: Parses chat completion responses into IngredientDraft arrays.
### NutritionAI/Services/Search/IngredientNormalizationService.swift
Description: Synonym mapping and modifier cleanup for USDA search input.
### NutritionAI/Services/Nutrition/NutritionLookupService.swift
Description: Protocol for nutrition data lookup and food search.
### NutritionAI/Services/Nutrition/USDANutritionRepository.swift
Description: USDA FoodData Central API implementation for search and nutrient retrieval.
### NutritionAI/Services/History/MealHistoryService.swift
Description: MealHistoryRepository protocol and MealHistoryStore with aggregation and snapshots.
### NutritionAI/Services/History/LocalMealHistoryRepository.swift
Description: JSON file-backed actor for meal persistence in Application Support.
### NutritionAI/Services/Retention/MealRetentionService.swift
Description: Enforces 30-day photo and 365-day meal retention policies.
### NutritionAI/Services/Goals/CalorieGoalCalculator.swift
Description: Gauge range, normalized progress, and remaining calorie calculations.

## Utilities
### NutritionAI/Utilities/CameraService.swift
Description: AVFoundation camera session, photo capture, flash, orientation, and SwiftUI preview.
### NutritionAI/Utilities/PhotoLibraryPicker.swift
Description: PHPicker SwiftUI wrapper for selecting and downscaling photos.
### NutritionAI/Utilities/ImageResizer.swift
Description: Image resize (longest side clamping) and JPEG encoding utility.

## Tests
### NutritionAITests/CalorieGoalCalculatorTests.swift
Description: Tests for gauge range, normalized progress, and remaining calorie logic.
### NutritionAITests/BodyMetricsTests.swift
Description: Tests for BMR, TDEE, daily goal, BMI, and 1200 kcal floor.
### NutritionAITests/MealRetentionServiceTests.swift
Description: Tests for photo stripping after 30 days and meal removal after 365 days.
### NutritionAITests/MealHistoryStoreTests.swift
Description: Tests for add, delete, snapshots, date filtering, and sort order.
### NutritionAITests/MealIdentificationParserTests.swift
Description: Tests for valid JSON parsing, empty/malformed responses, negative quantities, unknown units.
### NutritionAITests/IngredientNormalizationServiceTests.swift
Description: Tests for synonym replacement, modifier removal, whitespace cleanup.
### NutritionAIUITests/NutritionAIUITests.swift
Description: Basic UI test verifying app launch shows onboarding.

## Resources
### NutritionAI/Resources/Assets.xcassets
Description: Asset catalog with app icon placeholder.
### NutritionAI/Info.plist
Description: App info plist with camera/photo permissions and API key injection.
