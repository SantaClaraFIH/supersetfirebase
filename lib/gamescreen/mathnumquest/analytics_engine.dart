import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

class AnalyticsEngine {
  static final instance = FirebaseAnalytics.instance;
  static bool _isInitialized = false;

  static Future<void> init() async {
    try {
      // Ensure Firebase is initialized first
      if (Firebase.apps.isEmpty) {
        print('Firebase not initialized. Please initialize Firebase first in main.dart');
        return;
      }
      
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      _isInitialized = true;
      print('NumQuest Analytics initialized successfully');
    } catch (e) {
      print('Analytics initialization failed: $e');
      _isInitialized = false;
    }
  }

  // Helper method to safely log events
  static Future<void> _logEventSafely(String eventName, Map<String, Object> parameters) async {
    if (!_isInitialized) {
      print('Analytics not initialized. Event: $eventName');
      return;
    }
    
    try {
      await instance.logEvent(name: eventName, parameters: parameters);
    } catch (e) {
      print('Failed to log analytics event $eventName: $e');
    }
  }

  
  // LESSONS MODULE ANALYTICS
 

  // Log translate button clicks for Lessons (MultipageContainer)
  static void logTranslateButtonClickLessons(String language, String lessonType) async {
    print('Lessons - $lessonType: Translate button clicked for language: $language');
    await _logEventSafely(
      'numquest_lessons_translate',
      <String, Object>{
        'language': language,
        'lesson_type': lessonType,
        'module': 'lessons',
      },
    );
  }

  // Log audio button clicks in lessons
  static void logAudioButtonClickLessons(String language, String lessonType) async {
    print('Lessons - $lessonType: Audio button clicked for language: $language');
    await _logEventSafely(
      'numquest_lessons_audio',
      <String, Object>{
        'language': language,
        'lesson_type': lessonType,
        'module': 'lessons',
      },
    );
  }

  // Log lesson completion (when user clicks Quiz button)
  static void logLessonCompletion(String lessonType) async {
    print('Lesson Completed: $lessonType');
    await _logEventSafely(
      'numquest_lesson_complete',
      <String, Object>{
        'lesson_type': lessonType,
        'module': 'lessons',
      },
    );
  }


  // PRACTICE MODULE ANALYTICS (FlashCards)
  

  // Log translate button clicks for Practice pages
  static void logTranslateButtonClickPractice(String language, String practiceType) async {
    print('Practice - $practiceType: Translate button clicked for language: $language');
    await _logEventSafely(
      'numquest_practice_translate',
      <String, Object>{
        'language': language,
        'practice_type': practiceType,
        'module': 'practice',
      },
    );
  }

  // Log "More Examples" button clicks
  static void logMoreExamplesClick(String practiceType) async {
    print('Practice - $practiceType: More Examples clicked');
    await _logEventSafely(
      'numquest_practice_more_examples',
      <String, Object>{
        'practice_type': practiceType,
        'module': 'practice',
      },
    );
  }

  // Log correct/incorrect answers in practice 
static void logPracticeAnswer(String practiceType, bool isCorrect) async {
  print('Practice - $practiceType: Answer ${isCorrect ? 'Correct' : 'Incorrect'}');
  await _logEventSafely(
    'numquest_practice_answer',
    <String, Object>{
      'practice_type': practiceType,
      'is_correct': isCorrect ? 'true' : 'false', // Convert boolean to string
      'module': 'practice',
    },
  );
}

  // Log card flips in flip card games
  static void logCardFlip(String practiceType) async {
    print('Practice - $practiceType: Card flipped');
    await _logEventSafely(
      'numquest_practice_card_flip',
      <String, Object>{
        'practice_type': practiceType,
        'module': 'practice',
      },
    );
  }

  
  // GAMES MODULE ANALYTICS
  

  // Log game start
  static void logGameStart(String gameType) async {
    print('Game Started: $gameType');
    await _logEventSafely(
      'numquest_game_start',
      <String, Object>{
        'game_type': gameType,
        'module': 'games',
      },
    );
  }

  // Log game completion with score
  static void logGameComplete(String gameType, int score) async {
    print('Game Completed: $gameType with score: $score');
    await _logEventSafely(
      'numquest_game_complete',
      <String, Object>{
        'game_type': gameType,
        'score': score,
        'module': 'games',
      },
    );
  }
  static void logGameCompleteInMiddle() async {
    print('Game Completed');
    //await _logEventSafely();
  }

  // Log correct/incorrect answers in games (Unsed Kept for future implementation)
  static void logGameAnswer(String gameType, bool isCorrect, int currentScore) async {
    print('Game - $gameType: Answer ${isCorrect ? 'Correct' : 'Incorrect'}, Score: $currentScore');
    await _logEventSafely(
      'numquest_game_answer',
      <String, Object>{
        'game_type': gameType,
        'is_correct': isCorrect,
        'current_score': currentScore,
        'module': 'games',
      },
    );
  }

  // Log new game/reset clicks (Unsed Kept for future implementation)
  static void logNewGameClick(String gameType) async {
    print('Game - $gameType: New Game started');
    await _logEventSafely(
      'numquest_game_new_game',
      <String, Object>{
        'game_type': gameType,
        'module': 'games',
      },
    );
  }

  // Log drag and drop actions in games (Unsed Kept for future implementation)
  static void logDragDropAction(String gameType, String action) async {
    print('Game - $gameType: Drag-Drop action: $action');
    await _logEventSafely(
      'numquest_game_drag_drop',
      <String, Object>{
        'game_type': gameType,
        'action': action,
        'module': 'games',
      },
    );
  }


  // NAVIGATION ANALYTICS
  

  // Log module navigation (Lessons, Practice, Games)
  static void logModuleNavigation(String moduleType) async {
    print('Module Navigation: $moduleType');
    await _logEventSafely(
      'numquest_module_navigation',
      <String, Object>{
        'module_type': moduleType,
      },
    );
  }

  // Log specific lesson/practice/game selection
  static void logContentSelection(String contentType, String contentName) async {
    print('Content Selection: $contentType - $contentName');
    await _logEventSafely(
      'numquest_content_selection',
      <String, Object>{
        'content_type': contentType,
        'content_name': contentName,
      },
    );
  }

  // QUIZ ANALYTICS


  // Log quiz start from lessons
  static void logQuizStart(String lessonType) async {
    print('Quiz Started: $lessonType');
    await _logEventSafely(
      'numquest_quiz_start',
      <String, Object>{
        'lesson_type': lessonType,
        'module': 'quiz',
      },
    );
  }

  // Log quiz answers
  static void logQuizAnswer(String lessonType, bool isCorrect) async {
    print('Quiz - $lessonType: Answer ${isCorrect ? 'Correct' : 'Incorrect'}');
    await _logEventSafely(
      'numquest_quiz_answer',
      <String, Object>{
        'lesson_type': lessonType,
        'is_correct': isCorrect,
        'module': 'quiz',
      },
    );
  }


  // UTILITY FUNCTIONS
 

  // Helper function to convert boolean to string for language
  static String getLanguageString(bool isEnglish) {
    return isEnglish ? 'English' : 'Spanish';
  }

  // Helper function to get lesson type from class name or context
  static String getLessonTypeFromContext(String context) {
    if (context.toLowerCase().contains('even')) return 'even_numbers';
    if (context.toLowerCase().contains('odd')) return 'odd_numbers';
    if (context.toLowerCase().contains('prime')) return 'prime_numbers';
    if (context.toLowerCase().contains('composite')) return 'composite_numbers';
    if (context.toLowerCase().contains('square')) return 'square_numbers';
    if (context.toLowerCase().contains('cube')) return 'cube_numbers';
    if (context.toLowerCase().contains('perfect')) return 'perfect_numbers';
    if (context.toLowerCase().contains('triangular')) return 'triangular_numbers';
    if (context.toLowerCase().contains('fibonacci')) return 'fibonacci_numbers';
    if (context.toLowerCase().contains('factor')) return 'factors';
    return 'unknown';
  }
}