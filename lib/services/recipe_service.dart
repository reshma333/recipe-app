import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/recipe_model.dart';

class RecipeService {
  static final RecipeService _instance = RecipeService._internal();
  
  List<Recipe> _recipes = [];
  bool _isLoaded = false;

  factory RecipeService() {
    return _instance;
  }

  RecipeService._internal();

  // Load recipes from JSON asset
  Future<List<Recipe>> loadRecipes() async {
    if (_isLoaded && _recipes.isNotEmpty) {
      return _recipes;
    }

    try {
      // Load JSON from assets
      final jsonString = await rootBundle.loadString('assets/recipes_master.json');
      final jsonData = json.decode(jsonString);

      // Parse recipes
      if (jsonData is Map && jsonData['recipes'] is List) {
        _recipes = (jsonData['recipes'] as List)
            .map((recipe) => Recipe.fromJson(recipe as Map<String, dynamic>))
            .toList();
      } else if (jsonData is List) {
        _recipes = jsonData
            .map((recipe) => Recipe.fromJson(recipe as Map<String, dynamic>))
            .toList();
      }

      _isLoaded = true;
      print('✅ Loaded ${_recipes.length} recipes');
      return _recipes;
    } catch (e) {
      print('❌ Error loading recipes: $e');
      return [];
    }
  }

  // Get all recipes
  List<Recipe> getRecipes() => _recipes;

  // Get unique cuisines
  List<String> getCuisines() {
    Set<String> cuisinesSet = {};
    for (var recipe in _recipes) {
      cuisinesSet.addAll(recipe.cuisines);
    }
    return cuisinesSet.toList()..sort();
  }

  // Get recipes by cuisine
  List<Recipe> getRecipesByCuisine(String cuisine) {
    return _recipes
        .where((recipe) => recipe.cuisines.contains(cuisine))
        .toList();
  }

  // Get recipe by ID
  Recipe? getRecipeById(int id) {
    try {
      return _recipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }

  // Clear cache (useful for testing)
  void clearCache() {
    _recipes = [];
    _isLoaded = false;
  }
}
