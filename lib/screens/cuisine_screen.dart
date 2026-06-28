import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/recipe_service.dart';
import '../services/matching_service.dart';
import 'recipe_list_screen.dart';

class CuisineScreen extends StatefulWidget {
  final List<String> userIngredients;

  const CuisineScreen({
    Key? key,
    required this.userIngredients,
  }) : super(key: key);

  @override
  State<CuisineScreen> createState() => _CuisineScreenState();
}

class _CuisineScreenState extends State<CuisineScreen> {
  final recipeService = RecipeService();
  final matchingService = MatchingService();

  late Future<Map<String, int>> _cuisinesFuture;

  @override
  void initState() {
    super.initState();
    _cuisinesFuture = _loadCuisines();
  }

  Future<Map<String, int>> _loadCuisines() async {
    final recipes = recipeService.getRecipes();
    if (recipes.isEmpty) {
      await recipeService.loadRecipes();
    }
    return matchingService.getCuisinesWithCount(
      recipeService.getRecipes(),
      widget.userIngredients,
    );
  }

  void _selectCuisine(String cuisine) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecipeListScreen(
          userIngredients: widget.userIngredients,
          selectedCuisine: cuisine,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Cuisine'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, int>>(
        future: _cuisinesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final cuisines = snapshot.data ?? {};

          if (cuisines.isEmpty) {
            return const Center(
              child: Text('No recipes found with selected ingredients'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cuisines.length,
            itemBuilder: (context, index) {
              String cuisine = cuisines.keys.toList()[index];
              int recipeCount = cuisines[cuisine] ?? 0;

              return GestureDetector(
                onTap: () => _selectCuisine(cuisine),
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cuisine,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$recipeCount recipes',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
