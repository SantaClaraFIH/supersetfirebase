import 'package:flutter/material.dart';
class SessionScoreProvider with ChangeNotifier {
  int _game1BestScore = 0;
  int _game2BestScore = 0;

  int get game1BestScore => _game1BestScore;
  int get game2BestScore => _game2BestScore;

  void updateGame1Score(int score) {
    if (score > _game1BestScore) {
      _game1BestScore = score;
      notifyListeners();
    }
  }

  void updateGame2Score(int score) {
    if (score > _game2BestScore) {
      _game2BestScore = score;
      notifyListeners();
    }
  }

  void resetGame1Score() {
    if (_game1BestScore == 0) return;
    _game1BestScore = 0;
    notifyListeners();
  }

  void resetGame2Score() {
    if (_game2BestScore == 0) return;
    _game2BestScore = 0;
    notifyListeners();
  }

  void resetSessionScores() {
    if (_game1BestScore == 0 && _game2BestScore == 0) return;
    _game1BestScore = 0;
    _game2BestScore = 0;
    notifyListeners();
  }
}
