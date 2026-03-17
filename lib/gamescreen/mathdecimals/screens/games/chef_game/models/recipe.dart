// Chef game recipe and step models.

class Recipe {
  final String name;
  final String description;
  final List<CookingStep> steps;

  Recipe({
    required this.name,
    required this.description,
    required this.steps,
  });
}

class CookingStep {
  final String type;
  final String instruction;
  final String question;
  final String correctAnswer;
  final List<String> options;
  final String ingredient;
  final double measurement;

  CookingStep({
    required this.type,
    required this.instruction,
    required this.question,
    required this.correctAnswer,
    required this.options,
    required this.ingredient,
    required this.measurement,
  });
}

class RecipeCompletionData {
  final String message;
  final String visualType; // Visual key used by rendering logic (e.g. 'pan', 'oven_cookies', 'oven_cake', 'cup_hummus', 'glass_smoothie')

  RecipeCompletionData({required this.message, required this.visualType});
}
