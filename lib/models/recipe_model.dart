class Recipe {
  final int id;
  final String name;
  final List<String> cuisines;
  final double rating;
  final String image;
  final String externalLink;
  final Map<String, List<String>> ingredients;
  final int prepTime;
  final int cookTime;
  final int servings;
  final String summary;
  double? matchPercentage;

  Recipe({
    required this.id,
    required this.name,
    required this.cuisines,
    required this.rating,
    required this.image,
    required this.externalLink,
    required this.ingredients,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.summary,
    this.matchPercentage,
  });

  // Factory constructor to create Recipe from JSON
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as int,
      name: json['name'] as String,
      cuisines: List<String>.from(json['cuisines'] as List),
      rating: (json['rating'] as num).toDouble(),
      image: json['image'] as String? ?? '',
      externalLink: json['externalLink'] as String? ?? '',
      ingredients: Map<String, List<String>>.from(
        (json['ingredients'] as Map).map(
          (key, value) => MapEntry(
            key as String,
            List<String>.from(value as List),
          ),
        ),
      ),
      prepTime: json['prepTime'] as int? ?? 0,
      cookTime: json['cookTime'] as int? ?? 0,
      servings: json['servings'] as int? ?? 4,
      summary: json['summary'] as String? ?? '',
    );
  }

  // Get all ingredients as flat list
  List<String> getAllIngredients() {
    List<String> all = [];
    ingredients.forEach((category, items) {
      all.addAll(items);
    });
    return all;
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cuisines': cuisines,
      'rating': rating,
      'image': image,
      'externalLink': externalLink,
      'ingredients': ingredients,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'servings': servings,
      'summary': summary,
      'matchPercentage': matchPercentage,
    };
  }

  @override
  String toString() => 'Recipe(id: $id, name: $name, rating: $rating)';
}
