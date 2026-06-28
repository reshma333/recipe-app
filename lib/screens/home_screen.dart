import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/recipe_service.dart';
import '../services/matching_service.dart';
import 'cuisine_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final recipeService = RecipeService();
  final matchingService = MatchingService();

  late Future<List<Recipe>> _recipesFuture;

  Map<String, List<String>> selectedIngredients = {
    'vegetables': [],
    'spices': [],
    'lentils': [],
    'millets': [],
    'flours': [],
  };

  final Map<String, TextEditingController> controllers = {
    'vegetables': TextEditingController(),
    'spices': TextEditingController(),
    'lentils': TextEditingController(),
    'millets': TextEditingController(),
    'flours': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _recipesFuture = recipeService.loadRecipes();
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addIngredient(String category, String ingredient) {
    if (ingredient.isNotEmpty) {
      setState(() {
        if (!selectedIngredients[category]!.contains(ingredient)) {
          selectedIngredients[category]!.add(ingredient);
        }
      });
      controllers[category]!.clear();
    }
  }

  void _removeIngredient(String category, String ingredient) {
    setState(() {
      selectedIngredients[category]!.remove(ingredient);
    });
  }

  void _clearAll() {
    setState(() {
      selectedIngredients.forEach((key, value) {
        value.clear();
        controllers[key]!.clear();
      });
    });
  }

  void _findRecipes() {
    // Collect all selected ingredients
    List<String> allIngredients = [];
    selectedIngredients.forEach((category, ingredients) {
      allIngredients.addAll(ingredients);
    });

    if (allIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient')),
      );
      return;
    }

    // Navigate to cuisine screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CuisineScreen(userIngredients: allIngredients),
      ),
    );
  }

  Widget _buildIngredientSection(String category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.toUpperCase(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controllers[category],
          decoration: InputDecoration(
            hintText: 'e.g., Tomato, Onion',
            suffix: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addIngredient(
                category,
                controllers[category]!.text,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onSubmitted: (value) => _addIngredient(category, value),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: selectedIngredients[category]!
              .map(
                (ingredient) => Chip(
                  label: Text(ingredient),
                  onDeleted: () => _removeIngredient(category, ingredient),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🍳 Recipe Finder'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Recipe>>(
        future: _recipesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'What ingredients do you have?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...[
                  'vegetables',
                  'spices',
                  'lentils',
                  'millets',
                  'flours',
                ].map((category) => _buildIngredientSection(category)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _findRecipes,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      'Find Recipes',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _clearAll,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Clear All'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
