import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class WordScrambleGame extends StatefulWidget {
  final Function(String, int) onScoreUpdate;
  const WordScrambleGame({super.key, required this.onScoreUpdate});

  @override
  State<WordScrambleGame> createState() => _WordScrambleGameState();
}

class _WordScrambleGameState extends State<WordScrambleGame>
    with TickerProviderStateMixin {
  static const List<Map<String, String>> _wordList = [
    {'word': 'FLUTTER', 'hint': 'Google\'s UI framework'},
    {'word': 'ANDROID', 'hint': 'Mobile OS by Google'},
    {'word': 'PYTHON', 'hint': 'Popular scripting language'},
    {'word': 'LAPTOP', 'hint': 'Portable computer'},
    {'word': 'WIDGET', 'hint': 'Flutter UI building block'},
    {'word': 'MEMORY', 'hint': 'Brain storage'},
    {'word': 'SCIENCE', 'hint': 'Study of natural world'},
    {'word': 'BUTTON', 'hint': 'You tap this in a UI'},
    {'word': 'CODING', 'hint': 'Writing software'},
    {'word': 'GALAXY', 'hint': 'Collection of stars'},
    {'word': 'PLANET', 'hint': 'Orbits a star'},
    {'word': 'SCHOOL', 'hint': 'Place for learning'},
    {'word': 'FINGER', 'hint': 'You have 10 of them'},
    {'word': 'BRIDGE', 'hint': 'Crosses a river'},
    {'word': 'CAMERA', 'hint': 'Captures photos'},
  ];

  late Map<String, String> _currentWord;
  late String _scrambled;
  late List<String> _letterTiles;
  List<String> _selectedLetters = [];
  List<int> _selectedIndexes = [];
  int _score = 0;
  int _streak = 0;
  int _timeLeft = 45;
  int _wordsCompleted = 0;
  Timer? _timer;
  bool _gameOver = false;
  bool _gameStarted = false;
  String _feedbackMsg = '';
  Color _feedbackColor = Colors.transparent;
  final List<int> _usedIndexes = [];

  @override
  void initState() {
    super.initState();
    _loadNewWord();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadNewWord() {
    _usedIndexes.add(_usedIndexes.length);
    final available = _wordList
        .where((w) => !_usedIndexes.contains(_wordList.indexOf(w)))
        .toList();
    if (available.isEmpty) _usedIndexes.clear();

    final pool = available.isEmpty ? _wordList : available;
    _currentWord = pool[Random().nextInt(pool.length)];

    final letters = _currentWord['word']!.split('');
    _scrambled = _scrambleWord(letters);

    setState(() {
      _letterTiles = _scrambled.split('');
      _selectedLetters = [];
      _selectedIndexes = [];
      _feedbackMsg = '';
    });
  }

  String _scrambleWord(List<String> letters) {
    final shuffled = List<String>.from(letters)..shuffle();
    // Make sure it's different from original
    while (shuffled.join() == letters.join()) {
      shuffled.shuffle();
    }
    return shuffled.join();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _endGame();
        }
      });
    });
  }

  void _onLetterTap(int index) {
    if (_selectedIndexes.contains(index)) return;

    if (!_gameStarted) {
      _gameStarted = true;
      _startTimer();
    }

    setState(() {
      _selectedLetters.add(_letterTiles[index]);
      _selectedIndexes.add(index);
    });

    final attempt = _selectedLetters.join();
    if (attempt.length == _currentWord['word']!.length) {
      _checkAnswer(attempt);
    }
  }

  void _onRemoveLetter() {
    if (_selectedLetters.isEmpty) return;
    setState(() {
      _selectedLetters.removeLast();
      _selectedIndexes.removeLast();
    });
  }

  void _checkAnswer(String attempt) {
    if (attempt == _currentWord['word']) {
      _streak++;
      final bonus = _streak >= 2 ? 20 : 10;
      setState(() {
        _score += bonus + (_timeLeft ~/ 5);
        _wordsCompleted++;
        _feedbackMsg = '✅ Correct! ${_streak >= 2 ? "🔥 Streak x$_streak!" : ""}';
        _feedbackColor = const Color(0xFF00C9A7);
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _loadNewWord();
      });
    } else {
      _streak = 0;
      setState(() {
        _feedbackMsg = '❌ Try again!';
        _feedbackColor = const Color(0xFFFF6B6B);
        _selectedLetters = [];
        _selectedIndexes = [];
      });
    }
  }

  void _endGame() {
    _timer?.cancel();
    widget.onScoreUpdate('word', _score);
    setState(() => _gameOver = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '🔤 Word Scramble',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
        ),
      ),
      body: _gameOver ? _buildGameOver() : _buildGame(),
    );
  }

  Widget _buildGame() {
    return Column(
      children: [
        _buildStats(),
        const SizedBox(height: 24),
        _buildHintCard(),
        const SizedBox(height: 24),
        _buildAnswerSlots(),
        const SizedBox(height: 20),
        if (_feedbackMsg.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _feedbackColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _feedbackColor.withOpacity(0.4)),
              ),
              child: Text(_feedbackMsg,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: _feedbackColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        const Spacer(),
        _buildLetterGrid(),
        const SizedBox(height: 20),
        _buildControls(),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _chip('⭐', '$_score', const Color(0xFFFFBE0B)),
          const SizedBox(width: 10),
          _chip('📝', '$_wordsCompleted', const Color(0xFFFFBE0B)),
          const Spacer(),
          _timerChip(),
        ],
      ),
    );
  }

  Widget _chip(String emoji, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text('$emoji $val',
          style: TextStyle(
              color: color, fontWeight: FontWeight.w700, fontSize: 14)),
    );
  }

  Widget _timerChip() {
    final isLow = _timeLeft <= 10;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isLow
            ? const Color(0xFFFF6B6B).withOpacity(0.2)
            : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isLow ? const Color(0xFFFF6B6B) : Colors.transparent),
      ),
      child: Text(
        '⏱ ${_timeLeft}s',
        style: TextStyle(
          color: isLow ? const Color(0xFFFF6B6B) : Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildHintCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFBE0B).withOpacity(0.15),
            const Color(0xFFFF6584).withOpacity(0.1)
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFBE0B).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hint',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 12)),
                Text(_currentWord['hint']!,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Text(
            '${_currentWord['word']!.length} letters',
            style: TextStyle(
                color: const Color(0xFFFFBE0B).withOpacity(0.8),
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerSlots() {
    final word = _currentWord['word']!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(word.length, (i) {
          final filled = i < _selectedLetters.length;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 40,
            height: 50,
            decoration: BoxDecoration(
              color: filled
                  ? const Color(0xFFFFBE0B).withOpacity(0.15)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: filled
                    ? const Color(0xFFFFBE0B)
                    : Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                filled ? _selectedLetters[i] : '',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLetterGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: List.generate(_letterTiles.length, (i) {
          final isUsed = _selectedIndexes.contains(i);
          return GestureDetector(
            onTap: () => !isUsed ? _onLetterTap(i) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isUsed
                    ? Colors.white.withOpacity(0.05)
                    : const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isUsed
                      ? Colors.white.withOpacity(0.1)
                      : const Color(0xFF6C63FF).withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: !isUsed
                    ? [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withOpacity(0.2),
                          blurRadius: 8,
                        )
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  isUsed ? '' : _letterTiles[i],
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _onRemoveLetter,
              icon: const Icon(Icons.backspace_rounded, size: 18),
              label: const Text('Remove'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white60,
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedLetters = [];
                  _selectedIndexes = [];
                  _letterTiles = _scrambleWord(_currentWord['word']!.split('')) as List<String>;
                });
              },
              icon: const Icon(Icons.shuffle_rounded, size: 18),
              label: const Text('Shuffle'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFFBE0B),
                side: const BorderSide(color: Color(0xFFFFBE0B), width: 1),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOver() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⏰ Time\'s Up!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: const Color(0xFFFFBE0B).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  _row('⭐ Score', '$_score'),
                  _row('📝 Words', '$_wordsCompleted'),
                  _row('🔥 Streak', '$_streak'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => setState(() {
                  _score = 0;
                  _streak = 0;
                  _timeLeft = 45;
                  _wordsCompleted = 0;
                  _gameOver = false;
                  _gameStarted = false;
                  _loadNewWord();
                }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFBE0B),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Play Again',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Games',
                  style: TextStyle(color: Colors.white60, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String l, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l, style: const TextStyle(color: Colors.white60, fontSize: 16)),
            Text(v,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );
}
