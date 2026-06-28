import '../models/recipe_model.dart';

class MatchingService {
  static final MatchingService _instance = MatchingService._internal();

  factory MatchingService() {
    return _instance;
  }

  MatchingService._internal();

  /// Calculate match percentage between user ingredients and recipe ingredients
  /// Formula: (User Ingredients / Total Recipe Ingredients) × 100
  double calculateMatchPercentage(
    List<String> userIngredients,
    List<String> recipeIngredients,
  ) {
    if (recipeIngredients.isEmpty) return 0;

    // Normalize to lowercase for case-insensitive matching
    List<String> normalizedUserIngredients =
        userIngredients.map((ing) => ing.toLowerCase().trim()).toList();
    List<String> normalizedRecipeIngredients =
        recipeIngredients.map((ing) => ing.toLowerCase().trim()).toList();

    // Count matches
    int matchCount = 0;
    for (String userIng in normalizedUserIngredients) {
      for (String recipeIng in normalizedRecipeIngredients) {
        if (recipeIng.contains(userIng) || userIng.contains(recipeIng)) {
          matchCount++;
          break; // Count each user ingredient only once
        }
      }
    }

    // Calculate percentage
    double percentage =
        (matchCount / normalizedRecipeIngredients.length) * 100;
    return percentage.clamp(0, 100); // Ensure between 0-100
  }

  /// Find matching recipes based on user ingredients
  List<Recipe> findMatchingRecipes(
    List<Recipe> allRecipes,
    List<String> userIngredients, {
    String? selectedCuisine,
    double minMatchPercentage = 25.0,
  }) {
    if (userIngredients.isEmpty) return [];

    List<Recipe> matched = [];

    for (Recipe recipe in allRecipes) {
      // Get all ingredients from recipe
      List<String> recipeIngredients = recipe.getAllIngredients();

      // Calculate match percentage
      double matchPercentage =
          calculateMatchPercentage(userIngredients, recipeIngredients);

      // Filter by cuisine if specified
      if (selectedCuisine != null &&
          !recipe.cuisines.contains(selectedCuisine)) {
        continue;
      }

      // Filter by minimum match percentage
      if (matchPercentage >= minMatchPercentage) {
        recipe.matchPercentage = matchPercentage;
        matched.add(recipe);
      }
    }

    // Sort: By match percentage (highest first), then by rating
    matched.sort((a, b) {
      int compareMatch =
          (b.matchPercentage ?? 0).compareTo(a.matchPercentage ?? 0);
      if (compareMatch != 0) return compareMatch;
      return b.rating.compareTo(a.rating);
    });

    return matched;
  }

  /// Get cuisines available for given ingredients
  List<String> getAvailableCuisines(
    List<Recipe> allRecipes,
    List<String> userIngredients,
  ) {
    Set<String> cuisinesSet = {};

    for (Recipe recipe in allRecipes) {
      List<String> recipeIngredients = recipe.getAllIngredients();
      double matchPercentage =
          calculateMatchPercentage(userIngredients, recipeIngredients);

      // Include cuisines with at least 25% match
      if (matchPercentage >= 25.0) {
        cuisinesSet.addAll(recipe.cuisines);
      }
    }

    return cuisinesSet.toList()..sort();
  }

  /// Get cuisine with recipe count
  Map<String, int> getCuisinesWithCount(
    List<Recipe> allRecipes,
    List<String> userIngredients,
  ) {
    Map<String, int> cuisineCount = {};

    for (Recipe recipe in allRecipes) {
      List<String> recipeIngredients = recipe.getAllIngredients();
      double matchPercentage =
          calculateMatchPercentage(userIngredients, recipeIngredients);

      if (matchPercentage >= 25.0) {
        for (String cuisine in recipe.cuisines) {
          cuisineCount[cuisine] = (cuisineCount[cuisine] ?? 0) + 1;
        }
      }
    }

    // Sort by count descending
    var sortedEntries = cuisineCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }
}
