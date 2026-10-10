import 'dart:math';
import 'package:supersetfirebase/gamescreen/mathdecimals/selection_pages/GameSelectionDialog.dart';
import 'package:supersetfirebase/gamescreen/mathdecimals/screens/games/chef_game/data/chef_game_data.dart';
import 'package:supersetfirebase/gamescreen/mathdecimals/screens/games/chef_game/models/recipe.dart';
import 'package:supersetfirebase/gamescreen/mathdecimals/screens/games/chef_game/painters/chef_game_painters.dart';
import 'package:supersetfirebase/gamescreen/mathdecimals/screens/games/chef_game/widgets/chef_game_widgets.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:supersetfirebase/services/translation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChefGameScreen extends StatefulWidget {
  const ChefGameScreen({super.key});

  @override
  State<ChefGameScreen> createState() => _ChefGameScreenState();
}

class _ChefGameScreenState extends State<ChefGameScreen> with TickerProviderStateMixin {
  late SharedPreferences _preferences;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  int score = 0;
  int bestScore = 0;
  int currentRecipeIndex = 0;
  int currentStepIndex = 0;
  String selectedAnswer = '';
  String feedbackText = '';
  bool _showRecipeSelection = true;
  late AnimationController _ingredientAnimationController;
  late Animation<double> _ingredientScaleAnimation;
  List<String> _addedIngredients = [];
  List<String> _shuffledScaledOptions = [];
  late AnimationController _entranceController;
  final List<Animation<double>> _entranceAnimations = [];
  int _pressedChoiceIndex = -1;
  late AnimationController _correctPulseController;
  late Animation<double> _correctPulseAnimation;
  late AnimationController _wrongShakeController;
  int _wrongShakeIndex = -1;
  late AnimationController _correctSparkleController;
  late Animation<double> _correctSparkleAnimation;
  bool _allCompleteDialogShown = false;
  bool _isSpeaking = false;
  String _currentSpokenText = '';
  late AnimationController _chefMumbleController;
  late Animation<double> _chefMumbleAnimation;
  int _pressedRecipeIndex = -1;
  bool _recipeEntranceStarted = false;
  late AnimationController _recipeEntranceController;
  final List<Animation<double>> _recipeEntranceAnimations = [];

  static const String _decimalChef = 'Decimal Chef!';
  static const String _score = 'Score';
  static const String _bestScore = 'Best Score';
  static const String _listen = 'Listen';
  static const String _emptyBowl = 'Empty Bowl';
  static const String _step = 'Step';
  static const String _of = 'of';

  final Map<String, String> originalTexts = {
    'heading': 'Let\'s cook with decimals!',
    'instruction': 'Follow the recipe steps',
  };
  Map<String, String> translatedTexts = {};
  bool translated = false;

  List<Recipe> get recipes => chefGameRecipes;

  @override
  void initState() {
    super.initState();
    _loadBestScore();
    _ingredientAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _ingredientScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _ingredientAnimationController,
        curve: Curves.elasticOut,
      ),
    );
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    for (int i = 0; i < 4; i++) {
      _entranceAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Interval(i * 0.2, 0.2 + i * 0.2, curve: Curves.easeOut),
          ),
        ),
      );
    }
    _correctPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _correctPulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _correctPulseController,
        curve: Curves.elasticOut,
      ),
    );
    _wrongShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _correctSparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _correctSparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _correctSparkleController,
        curve: Curves.easeOut,
      ),
    );
    _chefMumbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _chefMumbleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _chefMumbleController, curve: Curves.easeInOut),
    );
    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        _chefMumbleController.stop();
        _chefMumbleController.reset();
        setState(() {
          _isSpeaking = false;
          _currentSpokenText = '';
        });
      }
    });
    _recipeEntranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    final n = recipes.length;
    for (int i = 0; i < n; i++) {
      _recipeEntranceAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _recipeEntranceController,
            curve: Interval(i / n, (i + 1) / n, curve: Curves.easeOut),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _flutterTts.stop();
    _ingredientAnimationController.dispose();
    _entranceController.dispose();
    _correctPulseController.dispose();
    _wrongShakeController.dispose();
    _correctSparkleController.dispose();
    _chefMumbleController.dispose();
    _recipeEntranceController.dispose();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await _flutterTts.stop();
    if (mounted) {
      setState(() {
        _currentSpokenText = text;
        _isSpeaking = true;
      });
      _chefMumbleController.repeat(reverse: true);
    }
    await _flutterTts.setLanguage(translated ? "es-ES" : "en-US");
    await _flutterTts.setPitch(1);
    await _flutterTts.setSpeechRate(1);
    await _flutterTts.speak(text);
  }

  String pronounceDecimal(double decimal) {
    if (decimal == decimal.toInt()) {
      return decimal.toInt().toString();
    }

    String decimalString = decimal.toString();
    List<String> parts = decimalString.split('.');
    String wholePart = parts[0];
    String fractionalPart = parts.length > 1 ? parts[1] : "";
    String pronunciation = "";

    if (wholePart == "0") {
      pronunciation += "zero";
    } else {
      pronunciation += wholePart;
    }

    if (fractionalPart.isNotEmpty) {
      int numDigits = fractionalPart.length;
      String placeValue = "";

      switch (numDigits) {
        case 1:
          placeValue = "tenths";
          break;
        case 2:
          placeValue = "hundredths";
          break;
        case 3:
          placeValue = "thousandths";
          break;
        default:
          return "$wholePart point ${fractionalPart.split('').join(' ')}";
      }

      pronunciation += " and ${int.parse(fractionalPart)} $placeValue";
    }

    return pronunciation;
  }

  Future<void> _speakRecipeStep(CookingStep step) async {
    String instruction;
    String options;
    if (translated && translatedTexts.isNotEmpty) {
      instruction = '${translatedTexts['current_instruction'] ?? step.instruction}. ${translatedTexts['current_question'] ?? _scaleAllDecimalsInText(step.question)}';
      final prompt = translatedTexts['options_prompt'] ?? _optionsPrompt;
      options = prompt +
          [0, 1, 2, 3].map((i) => translatedTexts['option_$i'] ?? '').where((s) => s.isNotEmpty).join(', ');
    } else {
      String scaledQuestion = _scaleAllDecimalsInText(step.question);
      instruction = "${step.instruction}. $scaledQuestion";
      options = _optionsPrompt;
      final List<String> displayOpts = _shuffledScaledOptions.length == step.options.length
          ? _shuffledScaledOptions
          : step.options.map((o) => _scaleSingleOption(o)).toList();
      for (String option in displayOpts) {
        if (option.contains('.') && option.split('.').length == 2) {
          try {
            double? value = double.tryParse(option.split(' ')[0]);
            if (value != null) {
              double scaledValue = _getScaledMeasurement(value);
              String unit = option.contains('cup') ? 'cup' : (option.contains('tsp') ? 'tsp' : '');
              options += "${pronounceDecimal(scaledValue)} $unit, ";
            } else {
              options += "$option, ";
            }
          } catch (e) {
            options += "$option, ";
          }
        } else {
          options += "$option, ";
        }
      }
    }
    await _speak("$instruction. $options");
  }

  Future<void> _playSound(String soundPath) async {
    try {
      await _audioPlayer.play(AssetSource(soundPath));
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  double _getScaledMeasurement(double baseMeasurement) {
    return baseMeasurement; // Always return base value for 1 person
  }

  String _scaleAllDecimalsInText(String text) {
    return text; // No scaling needed for 1 person
  }

  void _stopSpeaking() {
    _flutterTts.stop();
    _chefMumbleController.stop();
    _chefMumbleController.reset();
    if (mounted) {
      setState(() {
        _isSpeaking = false;
        _currentSpokenText = '';
      });
    }
  }

  void _speakCurrentStep({bool force = false}) {
    if (_isSpeaking && !force) {
      _stopSpeaking();
      return;
    }
    if (currentRecipeIndex < recipes.length &&
        currentStepIndex < recipes[currentRecipeIndex].steps.length) {
      CookingStep step = recipes[currentRecipeIndex].steps[currentStepIndex];
      _speakRecipeStep(step);
    }
  }

  List<String> _buildShuffledScaledOptionsForCurrentStep() {
    if (currentRecipeIndex >= recipes.length) return [];
    final step = recipes[currentRecipeIndex].steps[currentStepIndex];
    final scaled = step.options.map((o) => _scaleSingleOption(o)).toList();
    scaled.shuffle(Random());
    return scaled;
  }

  void _selectRecipe(int recipeIndex) {
    setState(() {
      currentRecipeIndex = recipeIndex;
      currentStepIndex = 0;
      _showRecipeSelection = false;
      _addedIngredients = [];
      _shuffledScaledOptions = _buildShuffledScaledOptionsForCurrentStep();
      _entranceController.reset();
      _entranceController.forward();
    });
    String intro = "Let's make ${recipes[recipeIndex].name}!";
    _speak(intro);
    if (translated) {
      _refetchTranslationsForCurrentStep();
    }
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _speakCurrentStep(force: true);
      }
    });
  }

  /// Re-fetches translations for the current step and updates [translatedTexts]. Keeps [translated] true.
  Future<void> _refetchTranslationsForCurrentStep() async {
    final keys = <String>[];
    final values = <String>[];
    _buildTranslationPayload(keys, values);
    try {
      final translations = await TranslationService.translateList(values);
      if (mounted && translations.length == keys.length) {
        setState(() {
          translatedTexts = {for (int i = 0; i < keys.length; i++) keys[i]: translations[i]};
        });
      }
    } catch (_) {
      // Keep existing translatedTexts; new step may show mixed until next manual translate
    }
  }

  Future<void> _loadBestScore() async {
    _preferences = await SharedPreferences.getInstance();
    setState(() {
      bestScore = _preferences.getInt('chefBestScore') ?? 0;
    });
  }

  Future<void> _saveBestScore(int newBest) async {
    if (newBest > bestScore) {
      setState(() {
        bestScore = newBest;
      });
      await _preferences.setInt('chefBestScore', newBest);
    }
  }

  void _navigateToCustomPage() {
    _saveBestScore(score);
    Navigator.of(context).pop(
      MaterialPageRoute(builder: (context) => GameSelectionDialog()),
    );
  }

  void _navigateToHome() {
    _saveBestScore(score);
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  static const String _optionsPrompt = 'Your options are: ';

  /// Builds ordered [keys] and [values] for the current game screen for translation.
  void _buildTranslationPayload(List<String> keys, List<String> values) {
    keys.addAll([
      'decimal_chef', 'score', 'best_score', 'listen', 'empty_bowl', 'step', 'of', 'heading',
      'options_prompt',
      'recipe_name', 'current_instruction', 'current_question',
      'option_0', 'option_1', 'option_2', 'option_3',
    ]);
    final recipe = recipes[currentRecipeIndex];
    final step = recipe.steps[currentStepIndex];
    final scaledQuestion = _scaleAllDecimalsInText(step.question);
    final displayOpts = _shuffledScaledOptions.length == step.options.length
        ? _shuffledScaledOptions
        : step.options.map((o) => _scaleSingleOption(o)).toList();
    values.addAll([
      _decimalChef, _score, _bestScore, _listen, _emptyBowl, _step, _of, originalTexts['heading']!,
      _optionsPrompt,
      recipe.name, step.instruction, scaledQuestion,
      displayOpts.isNotEmpty ? displayOpts[0] : '', displayOpts.length > 1 ? displayOpts[1] : '',
      displayOpts.length > 2 ? displayOpts[2] : '', displayOpts.length > 3 ? displayOpts[3] : '',
    ]);
    for (int i = 0; i < _addedIngredients.length; i++) {
      keys.add('ingredient_$i');
      values.add(_addedIngredients[i]);
    }
  }

  Future<void> translateTexts() async {
    if (!translated) {
      final keys = <String>[];
      final values = <String>[];
      _buildTranslationPayload(keys, values);
      try {
        final translations = await TranslationService.translateList(values);
        if (mounted && translations.length == keys.length) {
          setState(() {
            translatedTexts = {for (int i = 0; i < keys.length; i++) keys[i]: translations[i]};
            translated = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Translated to Spanish')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Translation unavailable. Please check your connection.'),
            ),
          );
        }
      }
    } else {
      setState(() {
        translatedTexts.clear();
        translated = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Switched back to English')),
        );
      }
    }
  }

  void _nextStep() {
    final didAdvance = currentStepIndex < recipes[currentRecipeIndex].steps.length - 1;
    setState(() {
      selectedAnswer = '';
      feedbackText = '';
      if (didAdvance) {
        currentStepIndex++;
        _shuffledScaledOptions = _buildShuffledScaledOptionsForCurrentStep();
        _entranceController.reset();
        _entranceController.forward();
        _correctPulseController.reset();
      } else {
        _showRecipeCompleteDialog();
      }
    });
    if (didAdvance) {
      if (translated) {
        // Fetch new step's translations first, then speak so we don't speak the old question.
        _refetchTranslationsForCurrentStep().then((_) {
          if (mounted) _speakCurrentStep(force: true);
        });
      } else {
        _speakCurrentStep(force: true);
      }
    }
  }

  String _scaleSingleOption(String option) {
    return option; // No scaling needed for 1 person
  }

  void checkAnswer(String scaledAnswer) async {
    final currentStep = recipes[currentRecipeIndex].steps[currentStepIndex];
    String correctAnswer = currentStep.correctAnswer;

    setState(() {
      selectedAnswer = scaledAnswer;
    });

    if (scaledAnswer == correctAnswer) {
      await _playSound('MathDecimals/sounds/success.mp3');
      await _speak("Correct! Great job!");
      setState(() {
        feedbackText = "Correct!";
        score += 10;
        _saveBestScore(score);
        _addedIngredients.add(currentStep.ingredient);
      });
      _correctPulseController.forward(from: 0).then((_) {
        _correctPulseController.reverse();
      });
      _correctSparkleController.forward(from: 0);
      _ingredientAnimationController.forward().then((_) {
        _ingredientAnimationController.reverse();
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _nextStep();
        }
      });
    } else {
      await _playSound('MathDecimals/sounds/error.mp3');
      await _speak("Try again!");
      final wrongIndex = _shuffledScaledOptions.indexOf(scaledAnswer);
      setState(() {
        feedbackText = "Try again!";
        _wrongShakeIndex = wrongIndex >= 0 ? wrongIndex : -1;
      });
      if (_wrongShakeIndex >= 0) {
        _wrongShakeController.forward(from: 0);
      }
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            feedbackText = '';
            selectedAnswer = '';
            _wrongShakeIndex = -1;
          });
        }
      });
    }
  }

  Future<void> _showRecipeCompleteDialog() async {
    final String recipeName = recipes[currentRecipeIndex].name;
    final String message = "Amazing! You completed the $recipeName recipe!";
    final RecipeCompletionData? completionData = recipeCompletionData[recipeName];
    
    // Original code kept for reference:
    // _speak(message);
    // if (completionData != null) {
    //   Future.delayed(const Duration(milliseconds: 2500), () {
    //     if (mounted) _speak(completionData.message);
    //   });
    // }
    
    // Combine both sentences into one continuous speech to avoid truncation
    final String fullSpeech = completionData != null 
        ? "$message ${completionData.message}" 
        : message;
    _speak(fullSpeech);

    String dialogTitle = 'Recipe Complete!';
    String dialogMessage = message;
    String dialogStatus = completionData?.message ?? '';
    String scoreLabel = 'Score';
    String homeLabel = 'Home';
    String playAgainLabel = 'Play Again';

    if (translated) {
      final toTranslate = <String>[dialogTitle, dialogMessage];
      if (completionData != null) toTranslate.add(dialogStatus);
      toTranslate.addAll([scoreLabel, homeLabel, playAgainLabel]);
      try {
        final t = await TranslationService.translateList(toTranslate);
        if (mounted && t.length == toTranslate.length) {
          dialogTitle = t[0];
          dialogMessage = t[1];
          int i = 2;
          if (completionData != null) {
            dialogStatus = t[i++];
          }
          scoreLabel = t[i++];
          homeLabel = t[i++];
          playAgainLabel = t[i];
        }
      } catch (_) {}
    }

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFFFFFBF7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.celebration, color: Colors.orange.shade700, size: 28),
            const SizedBox(width: 10),
            Text(
              dialogTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D4037),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dialogMessage,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4E342E),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _buildBowl(isSmall: true, scale: 0.85),
              const SizedBox(height: 16),
              if (completionData != null) ...[
                Divider(height: 28, color: Colors.brown.shade200, thickness: 1),
                Text(
                  dialogStatus,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Center(
            child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey.shade100,
                          Colors.grey.shade200,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.brown.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: _buildCompletionVisual(completionData.visualType),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200, width: 1),
                ),
                child: Text(
                  '$scoreLabel: $score',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, right: 8.0, left: 8.0),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 10,
              children: [
                // Play Again Button (Choose another recipe)
                Material(
                  borderRadius: BorderRadius.circular(24),
                  elevation: 4,
                  shadowColor: Colors.green.withValues(alpha: 0.4),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        _stopSpeaking();
                        Navigator.pop(dialogContext);
                        setState(() {
                          _showRecipeSelection = true;
                          currentStepIndex = 0;
                          selectedAnswer = '';
                          feedbackText = '';
                          _addedIngredients = [];
                        });
                        _recipeEntranceController.reset();
                        _recipeEntranceController.forward();
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.replay_rounded, size: 22, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              playAgainLabel,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Home Button
                Material(
                  borderRadius: BorderRadius.circular(24),
                  elevation: 4,
                  shadowColor: Colors.orange.withValues(alpha: 0.4),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFF9800), Color(0xFFE65100)],
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        _stopSpeaking();
                        Navigator.pop(dialogContext);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.home_rounded, size: 22, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              homeLabel,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAllRecipesCompleteDialog() async {
    String message = "Congratulations! You completed all recipes!";
    _speak(message);

    String dialogTitle = 'All Recipes Complete!';
    String dialogMessage = message;
    String finalScoreLabel = 'Final Score';
    String homeLabel = 'Home';
    String playAgainLabel = 'Play Again';

    if (translated) {
      try {
        final t = await TranslationService.translateList(
          [dialogTitle, dialogMessage, finalScoreLabel, homeLabel, playAgainLabel],
        );
        if (mounted && t.length >= 5) {
          dialogTitle = t[0];
          dialogMessage = t[1];
          finalScoreLabel = t[2];
          homeLabel = t[3];
          playAgainLabel = t[4];
        }
      } catch (_) {}
    }

    if (!mounted) return;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: const Color(0xFFFFFBF7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.celebration, color: Colors.orange.shade700, size: 28),
              const SizedBox(width: 10),
              Flexible(child: Text(dialogTitle, textAlign: TextAlign.center)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dialogMessage,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _buildBowl(isSmall: true, scale: 0.85),
              const SizedBox(height: 16),
              Text(
                '$finalScoreLabel: $score',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, right: 8.0, left: 8.0),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: [
                  // Play Again Button
                  Material(
                    borderRadius: BorderRadius.circular(24),
                    elevation: 4,
                    shadowColor: Colors.green.withValues(alpha: 0.4),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          _stopSpeaking();
                          Navigator.pop(dialogContext);
                          setState(() {
                            _allCompleteDialogShown = false;
                            _showRecipeSelection = true;
                            currentRecipeIndex = 0;
                            currentStepIndex = 0;
                            selectedAnswer = '';
                            feedbackText = '';
                            _addedIngredients = [];
                          });
                          _recipeEntranceController.reset();
                          _recipeEntranceController.forward();
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.replay_rounded, size: 22, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                playAgainLabel,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Home Button
                  Material(
                    borderRadius: BorderRadius.circular(24),
                    elevation: 4,
                    shadowColor: Colors.orange.withValues(alpha: 0.4),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFF9800), Color(0xFFE65100)],
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          _stopSpeaking();
                          Navigator.pop(dialogContext);
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.home_rounded, size: 22, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                homeLabel,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Color _getIngredientColor(String ingredient) {
    switch (ingredient.toLowerCase()) {
      case 'flour':
        return const Color(0xFFF5F5DC);
      case 'milk':
        return Colors.white;
      case 'sugar':
        return Colors.white;
      case 'cocoa powder':
        return Colors.brown.shade800;
      case 'butter':
        return Colors.yellow.shade200;
      case 'chocolate chips':
        return Colors.brown.shade900;
      case 'chickpeas':
        return const Color(0xFFD2B48C);
      case 'tahini':
        return const Color(0xFFC4A574);
      case 'lemon juice':
        return const Color(0xFFFFF8DC);
      case 'olive oil':
        return const Color(0xFFB8860B);
      case 'garlic':
        return const Color(0xFFF5F5DC);
      case 'salt':
        return Colors.white;
      case 'cumin':
        return Colors.brown.shade700;
      case 'banana':
        return const Color(0xFFFFE135);
      case 'yogurt':
        return Colors.white;
      case 'honey':
        return const Color(0xFFE6A336);
      case 'berries':
        return const Color(0xFF4A0E4E);
      case 'orange juice':
        return const Color(0xFFFFA500);
      default:
        return Colors.grey;
    }
  }

  Color _getBlendedMixtureColor() {
    if (_addedIngredients.isEmpty) return Colors.transparent;
    Color blended = _getIngredientColor(_addedIngredients.first);
    for (int i = 1; i < _addedIngredients.length; i++) {
      blended = Color.lerp(
        blended,
        _getIngredientColor(_addedIngredients[i]),
        0.3,
      )!;
    }
    return blended;
  }

  Widget _buildPanIllustration() {
    return SizedBox(
      width: 160,
      height: 100,
      child: CustomPaint(
        painter: PanPainter(),
      ),
    );
  }

  Widget _buildOvenIllustration(String variant) {
    return SizedBox(
      width: 170,
      height: 120,
      child: CustomPaint(
        painter: OvenPainter(variant: variant),
      ),
    );
  }

  Widget _buildHummusCupIllustration() {
    return SizedBox(
      width: 120,
      height: 100,
      child: CustomPaint(
        painter: HummusCupPainter(),
      ),
    );
  }

  Widget _buildSmoothieGlassIllustration() {
    return SizedBox(
      width: 100,
      height: 120,
      child: CustomPaint(
        painter: SmoothieGlassPainter(),
      ),
    );
  }

  Widget _buildCompletionVisual(String visualType) {
    switch (visualType) {
      case 'pan':
        return _buildPanIllustration();
      case 'oven_cookies':
        return _buildOvenIllustration('cookies');
      case 'oven_cake':
        return _buildOvenIllustration('cake');
      case 'cup_hummus':
        return _buildHummusCupIllustration();
      case 'glass_smoothie':
        return _buildSmoothieGlassIllustration();
      default:
        return _buildPanIllustration();
    }
  }

  Widget _buildBowl({bool isSmall = false, double scale = 1.0}) {
    final double s = scale.clamp(0.65, 1.0);
    final double baseWidth = isSmall ? 110 : 130;
    final double baseHeight = isSmall ? 85 : 100;
    final double baseCanvasWidth = isSmall ? 95 : 110;
    final double baseCanvasHeight = isSmall ? 70 : 80;

    final double bowlWidth = (baseWidth * s).clamp(65.0, baseWidth);
    final double bowlHeight = (baseHeight * s).clamp(50.0, baseHeight);
    final double canvasWidth = (baseCanvasWidth * s).clamp(55.0, baseCanvasWidth);
    final double canvasHeight = (baseCanvasHeight * s).clamp(40.0, baseCanvasHeight);
    final int totalSteps = (currentRecipeIndex < recipes.length && recipes[currentRecipeIndex].steps.isNotEmpty)
        ? recipes[currentRecipeIndex].steps.length
        : 4;
    final double fillProgress = (_addedIngredients.length / totalSteps).clamp(0.0, 1.0);
    final double calculatedFillHeight = fillProgress * (canvasHeight - 6);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: bowlWidth,
          height: bowlHeight,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                bottom: 0,
                child: Container(
                  width: canvasWidth,
                  height: (6 * s).clamp(3.0, 6.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Positioned(
                bottom: 4 * s,
                left: 4 * s,
                right: 4 * s,
                child: CustomPaint(
                  size: Size(canvasWidth, canvasHeight),
                  painter: BowlPainter(),
                ),
              ),
              if (_addedIngredients.isNotEmpty)
                Positioned(
                  bottom: 4 * s,
                  left: 4 * s,
                  right: 4 * s,
                  child: AnimatedBuilder(
                    animation: _ingredientScaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _ingredientScaleAnimation.value,
                        alignment: Alignment.bottomCenter,
                        child: CustomPaint(
                          size: Size(canvasWidth, canvasHeight),
                          painter: BowlContentsPainter(
                            fillHeight: calculatedFillHeight,
                            fillColor: _getBlendedMixtureColor(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (_addedIngredients.isEmpty)
                Positioned(
                  bottom: bowlHeight * 0.35,
                  child: Text(
                    translated ? (translatedTexts['empty_bowl'] ?? _emptyBowl) : _emptyBowl,
                    style: TextStyle(
                      color: Colors.brown.shade700,
                      fontSize: (12 * s).clamp(9.0, 12.0),
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.white.withValues(alpha: 0.8),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (_addedIngredients.isNotEmpty) ...[
          SizedBox(height: (4 * s).clamp(2.0, 4.0)),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: (4 * s).clamp(2.0, 4.0),
            runSpacing: (3 * s).clamp(2.0, 3.0),
            children: _addedIngredients.asMap().entries.map((e) {
              final label = translated ? (translatedTexts['ingredient_${e.key}'] ?? e.value) : e.value;
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: (6 * s).clamp(4.0, 6.0),
                  vertical: (2 * s).clamp(1.0, 2.0),
                ),
                decoration: BoxDecoration(
                  color: Colors.brown.shade300.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular((6 * s).clamp(3.0, 6.0)),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: (10 * s).clamp(7.5, 10.0),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildRecipeSelectionScreen() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    // Keep UI elements exactly as before when screen size is at maximum; only scale when reduced
    final double scale = (screenWidth < 900 || screenHeight < 700)
        ? (min(screenWidth / 900, screenHeight / 700)).clamp(0.68, 1.0)
        : 1.0;

    if (!_recipeEntranceStarted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _showRecipeSelection) {
          _recipeEntranceController.reset();
          _recipeEntranceController.forward();
          setState(() => _recipeEntranceStarted = true);
        }
      });
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "Choose a Recipe",
            style: TextStyle(
              fontSize: (22 * scale).clamp(16.0, 22.0),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          iconSize: (24 * scale).clamp(18.0, 24.0),
          onPressed: _navigateToCustomPage,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            iconSize: (24 * scale).clamp(18.0, 24.0),
            onPressed: _navigateToHome,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/MathDecimals/ChooseRecipePage.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all((20.0 * scale).clamp(10.0, 20.0)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Choose a Recipe',
                        style: TextStyle(
                          fontSize: (32 * scale).clamp(20.0, 32.0),
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      SizedBox(height: (30 * scale).clamp(14.0, 30.0)),
                      AnimatedBuilder(
                        animation: _recipeEntranceController,
                        builder: (context, child) {
                          return Column(
                            children: [
                              for (int i = 0; i < recipes.length; i++)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: (12.0 * scale).clamp(6.0, 12.0),
                                  ),
                                  child: Transform.translate(
                                    offset: Offset(
                                      0,
                                      24 *
                                          (1 -
                                              (i < _recipeEntranceAnimations.length
                                                  ? _recipeEntranceAnimations[i].value
                                                  : 1.0)),
                                    ),
                                    child: Opacity(
                                      opacity: i < _recipeEntranceAnimations.length
                                          ? _recipeEntranceAnimations[i].value
                                          : 1.0,
                                      child: Transform.scale(
                                        scale: _pressedRecipeIndex == i ? 0.96 : 1.0,
                                        child: RecipeSelectionCard(
                                          name: recipes[i].name,
                                          description: recipes[i].description,
                                          scale: scale,
                                          onTap: () => _selectRecipe(i),
                                          onTapDown: () =>
                                              setState(() => _pressedRecipeIndex = i),
                                          onTapUp: () =>
                                              setState(() => _pressedRecipeIndex = -1),
                                          onTapCancel: () =>
                                              setState(() => _pressedRecipeIndex = -1),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceWithFeedback({
    required int choiceIndex,
    required String choiceLabel,
    required List<String> displayOptions,
    required CookingStep currentStep,
    required double pulseScale,
    required double shakeOffsetX,
    required double sparkleValue,
    required double wrongBorderValue,
    double scale = 1.0,
  }) {
    final i = choiceIndex;
    final isCorrect = selectedAnswer.isNotEmpty &&
        displayOptions[i] == currentStep.correctAnswer;
    Widget child = Transform.scale(
      scale: _pressedChoiceIndex == i ? 0.96 : 1.0,
      child: GestureDetector(
        onTapDown: (_) {
          if (selectedAnswer.isEmpty) {
            setState(() => _pressedChoiceIndex = i);
          }
        },
        onTapUp: (_) => setState(() => _pressedChoiceIndex = -1),
        onTapCancel: () => setState(() => _pressedChoiceIndex = -1),
        child: ChefChoiceButton(
          label: choiceLabel,
          isCorrect: isCorrect,
          isWrong: selectedAnswer == displayOptions[i] &&
              displayOptions[i] != currentStep.correctAnswer,
          isDisabled: selectedAnswer.isNotEmpty,
          wrongBorderValue: i == _wrongShakeIndex ? wrongBorderValue : 0.0,
          height: (58 * scale).clamp(38.0, 58.0),
          fontSize: (16 * scale).clamp(12.0, 16.0),
          iconSize: (20 * scale).clamp(14.0, 20.0),
          borderRadius: (22 * scale).clamp(12.0, 22.0),
          padding: EdgeInsets.symmetric(
            horizontal: (14 * scale).clamp(8.0, 14.0),
            vertical: (6 * scale).clamp(3.0, 6.0),
          ),
          onTap: selectedAnswer.isEmpty
              ? () => checkAnswer(displayOptions[i])
              : null,
        ),
      ),
    );
    if (isCorrect) {
      child = Transform.scale(scale: pulseScale, child: child);
      if (sparkleValue < 1.0) {
        child = Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            Positioned(
              top: -4,
              right: 12,
              child: _buildSparkle(sparkleValue, 0.3),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: _buildSparkle(sparkleValue, 0.5),
            ),
            Positioned(
              bottom: 4,
              right: 24,
              child: _buildSparkle(sparkleValue, 0.4),
            ),
          ],
        );
      }
    }
    if (i == _wrongShakeIndex) {
      child = Transform.translate(
        offset: Offset(shakeOffsetX, 0),
        child: child,
      );
    }
    return child;
  }

  Widget _buildSparkle(double value, double delay) {
    final t = ((value - delay) / (1 - delay)).clamp(0.0, 1.0);
    final opacity = (1 - t);
    final scale = Curves.easeOut.transform(t);
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.amber.shade100,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.8),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChefWithCloud({
    required bool isSpeaking,
    required double mumbleScale,
    required String spokenText,
    required String chefExpression,
    double chefSize = 72,
    double cloudHeight = 116,
    double cloudFontSize = 15,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.scale(
          scale: mumbleScale,
          alignment: Alignment.topLeft,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(44),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.shade200.withValues(alpha: 0.7),
                  blurRadius: 14,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.85),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ChefNarrator(size: chefSize, expression: chefExpression),
          ),
        ),
        const SizedBox(width: 6),
        if (isSpeaking && spokenText.isNotEmpty)
          Expanded(
            child: SpeechCloud(
              text: spokenText,
              height: cloudHeight,
              fontSize: cloudFontSize,
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildStepProgressDots(int totalSteps, {double scale = 1.0}) {
    final double dotSize = (10 * scale).clamp(6.0, 10.0);
    final double gap = (4 * scale).clamp(2.0, 4.0);
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStepIndex;
            final isCurrent = index == currentStepIndex;
            final itemScale = isCurrent
                ? 1.0 + 0.2 * (1.0 - Curves.easeOut.transform(_entranceController.value))
                : 1.0;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: gap),
              child: Transform.scale(
                scale: itemScale,
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted || isCurrent
                        ? Colors.orange.shade700
                        : Colors.transparent,
                    border: Border.all(
                      color: isCompleted || isCurrent
                          ? Colors.orange.shade700
                          : Colors.orange.shade300,
                      width: 2,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double scale = (min(screenWidth / 750, screenHeight / 650)).clamp(0.65, 1.0);
    final bool isCompact = screenWidth < 850 || screenHeight < 680;

    if (_showRecipeSelection) {
      return _buildRecipeSelectionScreen();
    }

    if (currentRecipeIndex >= recipes.length) {
      if (!_allCompleteDialogShown) {
        _allCompleteDialogShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showAllRecipesCompleteDialog();
        });
      }
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text("Decimal Chef!"),
        ),
        body: const Center(
          child: Text("All recipes completed!"),
        ),
      );
    }

    final currentRecipe = recipes[currentRecipeIndex];
    final currentStep = currentRecipe.steps[currentStepIndex];
    String scaledQuestion = _scaleAllDecimalsInText(currentStep.question);
    final List<String> displayOptions = _shuffledScaledOptions.length == currentStep.options.length
        ? _shuffledScaledOptions
        : currentStep.options.map((o) => _scaleSingleOption(o)).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                translated ? (translatedTexts['decimal_chef'] ?? _decimalChef) : _decimalChef,
                style: TextStyle(
                  fontSize: (22 * scale).clamp(15.0, 22.0),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: (8 * scale).clamp(4.0, 8.0)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: (10 * scale).clamp(6.0, 10.0),
                  vertical: (5 * scale).clamp(3.0, 5.0),
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${translated ? (translatedTexts['score'] ?? _score) : _score}: $score',
                  style: TextStyle(
                    fontSize: (16 * scale).clamp(11.0, 16.0),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          iconSize: (24 * scale).clamp(18.0, 24.0),
          onPressed: _navigateToCustomPage,
        ),
        actions: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              margin: const EdgeInsets.only(top: 4, bottom: 4, right: 4),
              padding: EdgeInsets.symmetric(
                horizontal: (10 * scale).clamp(6.0, 10.0),
                vertical: (5 * scale).clamp(3.0, 5.0),
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${translated ? (translatedTexts['best_score'] ?? _bestScore) : _bestScore}: $bestScore',
                style: TextStyle(
                  fontSize: (14 * scale).clamp(10.0, 14.0),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.home),
            iconSize: (24 * scale).clamp(18.0, 24.0),
            padding: EdgeInsets.all((6 * scale).clamp(3.0, 6.0)),
            constraints: const BoxConstraints(),
            onPressed: _navigateToHome,
          ),
          IconButton(
            icon: const Icon(Icons.translate),
            iconSize: (24 * scale).clamp(18.0, 24.0),
            padding: EdgeInsets.all((6 * scale).clamp(3.0, 6.0)),
            constraints: const BoxConstraints(),
            onPressed: translateTexts,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/MathDecimals/cooking.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: (screenWidth * 0.04).clamp(10.0, 24.0),
                vertical: (12.0 * scale).clamp(6.0, 14.0),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isCompact) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _chefMumbleController,
                              builder: (_, __) {
                                final isCorrect = feedbackText == 'Correct!';
                                final isWrong = feedbackText == 'Try again!';
                                final chefExpression = isCorrect
                                    ? 'happy'
                                    : isWrong
                                        ? 'sad'
                                        : 'neutral';
                                return Transform.scale(
                                  scale: _isSpeaking ? _chefMumbleAnimation.value : 1.0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.orange.shade200.withValues(alpha: 0.7),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: ChefNarrator(
                                      size: (48 * scale).clamp(36.0, 48.0),
                                      expression: chefExpression,
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(width: (12 * scale).clamp(6.0, 12.0)),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    translated
                                        ? (translatedTexts['heading'] ?? originalTexts['heading']!)
                                        : originalTexts['heading']!,
                                    style: TextStyle(
                                      fontSize: (14 * scale).clamp(11.0, 14.0),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.brown.shade700,
                                    ),
                                  ),
                                  Text(
                                    translated
                                        ? (translatedTexts['recipe_name'] ?? currentRecipe.name)
                                        : currentRecipe.name,
                                    style: TextStyle(
                                      fontSize: (22 * scale).clamp(16.0, 22.0),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.brown,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (_isSpeaking && _currentSpokenText.isNotEmpty) ...[
                          SizedBox(height: (6 * scale).clamp(4.0, 6.0)),
                          Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: screenWidth * 0.85),
                              child: SpeechCloud(
                                text: _currentSpokenText,
                                height: (72 * scale).clamp(52.0, 72.0),
                                fontSize: (13 * scale).clamp(10.0, 13.0),
                              ),
                            ),
                          ),
                        ],
                      ] else ...[
                        Text(
                          translated
                              ? (translatedTexts['heading'] ?? originalTexts['heading']!)
                              : originalTexts['heading']!,
                          style: TextStyle(
                            fontSize: (16 * scale).clamp(13.0, 16.0),
                            fontWeight: FontWeight.w600,
                            color: Colors.brown.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: (6 * scale).clamp(4.0, 8.0)),
                        Text(
                          translated
                              ? (translatedTexts['recipe_name'] ?? currentRecipe.name)
                              : currentRecipe.name,
                          style: TextStyle(
                            fontSize: (26 * scale).clamp(18.0, 28.0),
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      SizedBox(height: (6 * scale).clamp(3.0, 8.0)),
                      Center(
                        child: Text(
                          '${translated ? (translatedTexts['step'] ?? _step) : _step} ${currentStepIndex + 1} ${translated ? (translatedTexts['of'] ?? _of) : _of} ${currentRecipe.steps.length}',
                          style: TextStyle(
                            fontSize: (16 * scale).clamp(12.0, 17.0),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: (6 * scale).clamp(3.0, 6.0)),
                      Center(
                        child: _buildStepProgressDots(
                          currentRecipe.steps.length,
                          scale: scale,
                        ),
                      ),
                      SizedBox(height: (6 * scale).clamp(3.0, 8.0)),
                      _buildBowl(scale: scale),
                      SizedBox(height: (8 * scale).clamp(4.0, 10.0)),
                      Center(
                        child: Container(
                          padding: EdgeInsets.all((12 * scale).clamp(7.0, 12.0)),
                          constraints: BoxConstraints(maxWidth: screenWidth * 0.9),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.amber.shade50,
                                Colors.orange.shade50,
                                Colors.amber.shade100,
                              ],
                            ),
                            borderRadius: BorderRadius.circular((18 * scale).clamp(12.0, 18.0)),
                            border: Border.all(
                              color: Colors.orange.shade200,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withValues(alpha: 0.2),
                                blurRadius: 8,
                                spreadRadius: 1,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: (12 * scale).clamp(8.0, 14.0),
                                  vertical: (5 * scale).clamp(3.0, 6.0),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular((14 * scale).clamp(10.0, 16.0)),
                                  border: Border(
                                    left: BorderSide(
                                      color: Colors.orange.shade700,
                                      width: 4,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withValues(alpha: 0.15),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  translated
                                      ? (translatedTexts['current_instruction'] ?? currentStep.instruction)
                                      : currentStep.instruction,
                                  style: TextStyle(
                                    fontSize: (17 * scale).clamp(12.0, 18.0),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade900,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: (6 * scale).clamp(3.0, 6.0)),
                              Text(
                                translated
                                    ? (translatedTexts['current_question'] ?? scaledQuestion)
                                    : scaledQuestion,
                                style: TextStyle(
                                  fontSize: (19 * scale).clamp(13.0, 20.0),
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF3E2723),
                                  shadows: const [
                                    Shadow(
                                      color: Colors.white54,
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: (6 * scale).clamp(3.0, 6.0)),
                              Material(
                                color: Colors.orange.shade400,
                                borderRadius: BorderRadius.circular(24),
                                elevation: 2,
                                child: InkWell(
                                  onTap: _speakCurrentStep,
                                  borderRadius: BorderRadius.circular(24),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: (16 * scale).clamp(10.0, 18.0),
                                      vertical: (7 * scale).clamp(4.0, 8.0),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.volume_up,
                                          size: (20 * scale).clamp(15.0, 22.0),
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: (6 * scale).clamp(3.0, 6.0)),
                                        Text(
                                          translated ? (translatedTexts['listen'] ?? _listen) : _listen,
                                          style: TextStyle(
                                            fontSize: (14 * scale).clamp(11.0, 15.0),
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (feedbackText.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: (8.0 * scale).clamp(4.0, 10.0)),
                          child: Center(
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: 1,
                              child: TweenAnimationBuilder<double>(
                                key: ValueKey(feedbackText),
                                tween: Tween(begin: 0.8, end: 1.0),
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.elasticOut,
                                builder: (context, animScale, child) => Transform.scale(
                                  scale: animScale,
                                  child: child,
                                ),
                                child: Text(
                                  feedbackText,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: (22 * scale).clamp(15.0, 24.0),
                                    fontWeight: FontWeight.bold,
                                    color: feedbackText == "Correct!"
                                        ? const Color(0xFF2E7D32)
                                        : Colors.red.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: (8 * scale).clamp(4.0, 8.0)),
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          _entranceController,
                          _correctPulseController,
                          _correctSparkleController,
                          _wrongShakeController,
                        ]),
                        builder: (context, child) {
                          final pulseScale = selectedAnswer.isNotEmpty
                              ? _correctPulseAnimation.value
                              : 1.0;
                          final sparkleValue = _correctSparkleAnimation.value;
                          final shakeX = _wrongShakeIndex >= 0
                              ? 6 * sin(4 * pi * _wrongShakeController.value)
                              : 0.0;
                          final wrongBorderValue = _wrongShakeIndex >= 0
                              ? _wrongShakeController.value
                              : 0.0;
                          return Column(
                            children: [
                              for (int i = 0; i < displayOptions.length; i++)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: (5.0 * scale).clamp(3.0, 6.0),
                                  ),
                                  child: Transform.translate(
                                    offset: Offset(
                                      0,
                                      24 *
                                          (1 -
                                              (i < _entranceAnimations.length
                                                  ? _entranceAnimations[i].value
                                                  : 1.0)),
                                    ),
                                    child: Opacity(
                                      opacity: i < _entranceAnimations.length
                                          ? _entranceAnimations[i].value
                                          : 1.0,
                                      child: _buildChoiceWithFeedback(
                                        choiceIndex: i,
                                        choiceLabel: translated
                                            ? (translatedTexts['option_$i'] ?? displayOptions[i])
                                            : displayOptions[i],
                                        displayOptions: displayOptions,
                                        currentStep: currentStep,
                                        pulseScale: pulseScale,
                                        shakeOffsetX: shakeX,
                                        sparkleValue: sparkleValue,
                                        wrongBorderValue: wrongBorderValue,
                                        scale: scale,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (!isCompact)
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.02, top: 16),
                  child: SizedBox(
                    width: (screenWidth * 0.3).clamp(160.0, 320.0),
                    child: AnimatedBuilder(
                      animation: _chefMumbleController,
                      builder: (_, __) {
                        final isCorrect = feedbackText == 'Correct!';
                        final isWrong = feedbackText == 'Try again!';
                        final chefExpression = isCorrect
                            ? 'happy'
                            : isWrong
                                ? 'sad'
                                : 'neutral';
                        return _buildChefWithCloud(
                          isSpeaking: _isSpeaking,
                          mumbleScale: _isSpeaking ? _chefMumbleAnimation.value : 1.0,
                          spokenText: _currentSpokenText,
                          chefExpression: chefExpression,
                          chefSize: 72,
                          cloudHeight: 116,
                          cloudFontSize: 15,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
