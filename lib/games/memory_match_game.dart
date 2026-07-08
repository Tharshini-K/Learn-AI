import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class MemoryMatchGame extends StatefulWidget {
  final Function(String, int) onScoreUpdate;
  const MemoryMatchGame({super.key, required this.onScoreUpdate});

  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends State<MemoryMatchGame>
    with TickerProviderStateMixin {
  static const List<String> _emojis = [
    '🐶', '🐱', '🐸', '🦊', '🐨', '🦁', '🐯', '🦋',
    '🌟', '🍕', '🎸', '🚀',
  ];

  late List<CardModel> _cards;
  final List<int> _flippedIndexes = [];
  bool _canFlip = true;
  int _score = 0;
  int _moves = 0;
  int _timeLeft = 60;
  Timer? _timer;
  bool _gameOver = false;
  bool _gameStarted = false;
  late AnimationController _celebrationController;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _initGame();
  }

  void _initGame() {
    final shuffled = List<String>.from(_emojis.take(8))
      ..addAll(_emojis.take(8))
      ..shuffle(Random());

    _cards = shuffled
        .asMap()
        .entries
        .map((e) => CardModel(id: e.key, emoji: e.value))
        .toList();

    setState(() {
      _flippedIndexes.clear();
      _score = 0;
      _moves = 0;
      _timeLeft = 60;
      _gameOver = false;
      _gameStarted = false;
    });
  }

  void _startTimer() {
    _timer?.cancel();
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

  void _flipCard(int index) {
    if (!_canFlip || _cards[index].isMatched || _cards[index].isFlipped) return;
    if (_flippedIndexes.length >= 2) return;

    if (!_gameStarted) {
      _gameStarted = true;
      _startTimer();
    }

    setState(() {
      _cards[index].isFlipped = true;
      _flippedIndexes.add(index);
    });

    if (_flippedIndexes.length == 2) {
      _moves++;
      _checkMatch();
    }
  }

  void _checkMatch() {
    final a = _flippedIndexes[0];
    final b = _flippedIndexes[1];

    if (_cards[a].emoji == _cards[b].emoji) {
      setState(() {
        _cards[a].isMatched = true;
        _cards[b].isMatched = true;
        _score += 10 + (_timeLeft ~/ 5);
        _flippedIndexes.clear();
      });
      _celebrationController.forward(from: 0);
      if (_cards.every((c) => c.isMatched)) _endGame(win: true);
    } else {
      _canFlip = false;
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) {
          setState(() {
            _cards[a].isFlipped = false;
            _cards[b].isFlipped = false;
            _flippedIndexes.clear();
            _canFlip = true;
          });
        }
      });
    }
  }

  void _endGame({bool win = false}) {
    _timer?.cancel();
    if (win) _score += _timeLeft * 2;
    widget.onScoreUpdate('memory', _score);
    setState(() => _gameOver = true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _celebrationController.dispose();
    super.dispose();
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
          '🃏 Memory Match',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
        ),
      ),
      body: _gameOver ? _buildGameOverScreen() : _buildGameScreen(),
    );
  }

  Widget _buildGameScreen() {
    return Column(
      children: [
        _buildStats(),
        const SizedBox(height: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _cards.length,
              itemBuilder: (_, i) => _buildCard(i),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _statChip(Icons.star_rounded, '$_score', const Color(0xFFFFBE0B)),
          const SizedBox(width: 12),
          _statChip(Icons.touch_app_rounded, '$_moves', const Color(0xFF6C63FF)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _timeLeft < 15
                  ? const Color(0xFFFF6B6B).withOpacity(0.2)
                  : Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _timeLeft < 15
                    ? const Color(0xFFFF6B6B)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer_rounded,
                  color: _timeLeft < 15
                      ? const Color(0xFFFF6B6B)
                      : Colors.white70,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '$_timeLeft s',
                  style: TextStyle(
                    color: _timeLeft < 15
                        ? const Color(0xFFFF6B6B)
                        : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w700, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildCard(int index) {
    final card = _cards[index];
    return GestureDetector(
      onTap: () => _flipCard(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: card.isMatched
              ? const Color(0xFF00C9A7).withOpacity(0.2)
              : card.isFlipped
                  ? const Color(0xFF6C63FF).withOpacity(0.2)
                  : const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: card.isMatched
                ? const Color(0xFF00C9A7)
                : card.isFlipped
                    ? const Color(0xFF6C63FF)
                    : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: card.isFlipped
              ? [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                    blurRadius: 10,
                  )
                ]
              : [],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: card.isFlipped || card.isMatched
                ? Text(
                    card.emoji,
                    key: ValueKey('emoji_$index'),
                    style: const TextStyle(fontSize: 30),
                  )
                : Text(
                    '?',
                    key: ValueKey('hidden_$index'),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverScreen() {
    final matched = _cards.where((c) => c.isMatched).length ~/ 2;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              matched == 8 ? '🎉 You Won!' : '⏰ Time\'s Up!',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: const Color(0xFF6C63FF).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  _resultRow('⭐ Score', '$_score'),
                  _resultRow('🃏 Pairs Found', '$matched / 8'),
                  _resultRow('👆 Moves', '$_moves'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => setState(_initGame),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
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

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 16)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class CardModel {
  final int id;
  final String emoji;
  bool isFlipped;
  bool isMatched;

  CardModel({
    required this.id,
    required this.emoji,
    this.isFlipped = false,
    this.isMatched = false,
  });
}
