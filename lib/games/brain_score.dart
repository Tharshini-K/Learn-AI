class BrainScoreManager {
  static final BrainScoreManager _instance = BrainScoreManager._internal();
  factory BrainScoreManager() => _instance;
  BrainScoreManager._internal();

  final Map<String, int> _scores = {
    'memory': 0,
    'math': 0,
    'pattern': 0,
    'word': 0,
    'reaction': 0,
  };

  int get totalScore => _scores.values.fold(0, (a, b) => a + b);

  int get brainIQ {
    final base = 80 + (totalScore ~/ 10).clamp(0, 70);
    return base;
  }

  String get brainLevel {
    final iq = brainIQ;
    if (iq >= 145) return '🔥 Genius Level';
    if (iq >= 130) return '⚡ Superior Mind';
    if (iq >= 115) return '🌟 Above Average';
    if (iq >= 100) return '💪 Average Intelligence';
    if (iq >= 90) return '📚 Developing Mind';
    return '🌱 Just Getting Started';
  }

  double get progressToNextLevel {
    final score = totalScore % 100;
    return score / 100.0;
  }

  int getScore(String game) => _scores[game] ?? 0;

  void updateScore(String game, int score) {
    if ((_scores[game] ?? 0) < score) {
      _scores[game] = score;
    }
  }
}
