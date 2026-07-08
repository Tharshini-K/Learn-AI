import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class MathBlitzGame extends StatefulWidget {
  final Function(String, int) onScoreUpdate;
  const MathBlitzGame({super.key, required this.onScoreUpdate});

  @override
  State<MathBlitzGame> createState() => _MathBlitzGameState();
}

class _MathBlitzGameState extends State<MathBlitzGame>
    with TickerProviderStateMixin {
  final Random _random = Random();
  int _num1 = 0, _num2 = 0;
  String _operator = '+';
  int _correctAnswer = 0;
  List<int> _choices = [];
  int _score = 0;
  int _streak = 0;
  int _timeLeft = 30;
  int _totalAnswered = 0;
  int _correct = 0;
  Timer? _timer;
  bool _gameOver = false;
  bool _gameStarted = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _correctController;
  String _feedbackText = '';
  Color _feedbackColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _correctController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _generateQuestion();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    _correctController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _endGame();
        }
      });
    });
  }

  void _generateQuestion() {
    const operators = ['+', '-', '×'];
    _operator = operators[_random.nextInt(
        _score < 50 ? 2 : 3)]; // Only add multiplication after score 50

    switch (_operator) {
      case '+':
        _num1 = _random.nextInt(50) + 1;
        _num2 = _random.nextInt(50) + 1;
        _correctAnswer = _num1 + _num2;
        break;
      case '-':
        _num1 = _random.nextInt(50) + 10;
        _num2 = _random.nextInt(_num1);
        _correctAnswer = _num1 - _num2;
        break;
      case '×':
        _num1 = _random.nextInt(10) + 1;
        _num2 = _random.nextInt(10) + 1;
        _correctAnswer = _num1 * _num2;
        break;
    }

    // Generate 3 wrong answers
    final wrongs = <int>{};
    while (wrongs.length < 3) {
      final offset = _random.nextInt(20) - 10;
      if (offset != 0) wrongs.add(_correctAnswer + offset);
    }

    _choices = [_correctAnswer, ...wrongs]..shuffle(_random);
    setState(() {});
  }

  void _answer(int value) {
    if (!_gameStarted) {
      _gameStarted = true;
      _startTimer();
    }

    _totalAnswered++;
    if (value == _correctAnswer) {
      _correct++;
      _streak++;
      final bonus = _streak >= 3 ? 20 : 10;
      setState(() {
        _score += bonus + (_timeLeft ~/ 5);
        _feedbackText = _streak >= 3 ? '🔥 x$_streak Streak! +$bonus' : '✅ Correct! +$bonus';
        _feedbackColor = const Color(0xFF00C9A7);
      });
      _correctController.forward(from: 0);
    } else {
      _streak = 0;
      setState(() {
        _feedbackText = '❌ Wrong! It was $_correctAnswer';
        _feedbackColor = const Color(0xFFFF6B6B);
      });
      _shakeController.forward(from: 0);
    }

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _feedbackText = '';
          _feedbackColor = Colors.transparent;
        });
        _generateQuestion();
      }
    });
  }

  void _endGame() {
    _timer?.cancel();
    widget.onScoreUpdate('math', _score);
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
          '⚡ Math Blitz',
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
        _buildTopBar(),
        const SizedBox(height: 20),
        _buildQuestion(),
        const SizedBox(height: 20),
        if (_feedbackText.isNotEmpty)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: _feedbackColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _feedbackColor.withOpacity(0.5)),
            ),
            child: Text(
              _feedbackText,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _feedbackColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
          ),
        const Spacer(),
        _buildAnswerGrid(),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildTopBar() {
    final accuracy = _totalAnswered > 0
        ? ((_correct / _totalAnswered) * 100).toInt()
        : 100;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _chip('⭐', '$_score', const Color(0xFFFFBE0B)),
          const SizedBox(width: 10),
          _chip('🎯', '$accuracy%', const Color(0xFF00C9A7)),
          const SizedBox(width: 10),
          if (_streak >= 2) _chip('🔥', 'x$_streak', const Color(0xFFFF6584)),
          const Spacer(),
          _timerWidget(),
        ],
      ),
    );
  }

  Widget _chip(String emoji, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$emoji $text',
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13),
      ),
    );
  }

  Widget _timerWidget() {
    final isLow = _timeLeft <= 10;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isLow
            ? const Color(0xFFFF6B6B).withOpacity(0.2)
            : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLow ? const Color(0xFFFF6B6B) : Colors.transparent,
        ),
      ),
      child: Text(
        '${_timeLeft}s',
        style: TextStyle(
          color: isLow ? const Color(0xFFFF6B6B) : Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildQuestion() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (_, child) => Transform.translate(
        offset: Offset(
          _shakeController.isAnimating
              ? sin(_shakeAnimation.value) * 5
              : 0,
          0,
        ),
        child: child,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00C9A7), Color(0xFF3A86FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00C9A7).withOpacity(0.3),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '$_num1  $_operator  $_num2  =  ?',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
        children: _choices.map((choice) {
          return GestureDetector(
            onTap: () => _answer(choice),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFF00C9A7).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  '$choice',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGameOver() {
    final accuracy = _totalAnswered > 0
        ? ((_correct / _totalAnswered) * 100).toInt()
        : 0;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚡ Time\'s Up!',
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
                    color: const Color(0xFF00C9A7).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  _row('⭐ Final Score', '$_score'),
                  _row('✅ Correct', '$_correct / $_totalAnswered'),
                  _row('🎯 Accuracy', '$accuracy%'),
                  _row('🔥 Best Streak', '$_streak'),
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
                  _timeLeft = 30;
                  _totalAnswered = 0;
                  _correct = 0;
                  _gameOver = false;
                  _gameStarted = false;
                  _generateQuestion();
                }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C9A7),
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
