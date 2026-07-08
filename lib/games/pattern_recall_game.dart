import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PatternRecallGame extends StatefulWidget {
  final Function(String, int) onScoreUpdate;
  const PatternRecallGame({super.key, required this.onScoreUpdate});

  @override
  State<PatternRecallGame> createState() => _PatternRecallGameState();
}

class _PatternRecallGameState extends State<PatternRecallGame>
    with TickerProviderStateMixin {
  static const List<Color> _tileColors = [
    Color(0xFF6C63FF),
    Color(0xFFFF6584),
    Color(0xFF00C9A7),
    Color(0xFFFFBE0B),
  ];
  static const List<String> _tileEmojis = ['🟣', '🔴', '🟢', '🟡'];

  final List<int> _sequence = [];
  final List<int> _playerInput = [];
  int _level = 1;
  int _score = 0;
  bool _isShowingSequence = false;
  bool _canInput = false;
  int _highlightedTile = -1;
  bool _gameOver = false;
  String _message = 'Watch the pattern!';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startNewLevel());
  }

  void _startNewLevel() {
    setState(() {
      _message = 'Level $_level - Watch!';
      _isShowingSequence = true;
      _canInput = false;
      _playerInput.clear();
    });
    _sequence.add(Random().nextInt(4));
    _playSequence();
  }

  Future<void> _playSequence() async {
    await Future.delayed(const Duration(milliseconds: 800));
    for (int i = 0; i < _sequence.length; i++) {
      if (!mounted) return;
      setState(() => _highlightedTile = _sequence[i]);
      HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => _highlightedTile = -1);
      await Future.delayed(const Duration(milliseconds: 300));
    }
    if (!mounted) return;
    setState(() {
      _isShowingSequence = false;
      _canInput = true;
      _message = 'Your turn! Repeat the pattern';
    });
  }

  void _onTileTap(int index) {
    if (!_canInput || _gameOver) return;
    HapticFeedback.selectionClick();

    setState(() {
      _highlightedTile = index;
      _playerInput.add(index);
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _highlightedTile = -1);
    });

    final pos = _playerInput.length - 1;
    if (_playerInput[pos] != _sequence[pos]) {
      _onWrongInput();
      return;
    }

    if (_playerInput.length == _sequence.length) {
      _onLevelComplete();
    }
  }

  void _onWrongInput() {
    HapticFeedback.heavyImpact();
    widget.onScoreUpdate('pattern', _score);
    setState(() {
      _canInput = false;
      _gameOver = true;
      _message = '❌ Wrong! Game Over';
    });
  }

  void _onLevelComplete() {
    _score += _level * 15;
    _level++;
    setState(() {
      _canInput = false;
      _message = '✅ Level ${_level - 1} Complete!';
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _startNewLevel();
    });
  }

  void _restart() {
    setState(() {
      _sequence.clear();
      _playerInput.clear();
      _level = 1;
      _score = 0;
      _gameOver = false;
    });
    _startNewLevel();
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
          '🎮 Pattern Recall',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 30),
          _buildMessageBox(),
          const Spacer(),
          _buildGrid(),
          const Spacer(),
          if (_gameOver) _buildRestartButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _chip('🏆 Level', '$_level', const Color(0xFF6C63FF)),
          _chip('⭐ Score', '$_score', const Color(0xFFFFBE0B)),
          _chip('🔢 Sequence', '${_sequence.length}', const Color(0xFFFF6584)),
        ],
      ),
    );
  }

  Widget _chip(String label, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(color: color.withOpacity(0.7), fontSize: 11)),
          Text(val,
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildMessageBox() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: _gameOver
            ? const Color(0xFFFF6B6B).withOpacity(0.1)
            : _canInput
                ? const Color(0xFF00C9A7).withOpacity(0.1)
                : const Color(0xFF6C63FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _gameOver
              ? const Color(0xFFFF6B6B).withOpacity(0.4)
              : _canInput
                  ? const Color(0xFF00C9A7).withOpacity(0.4)
                  : const Color(0xFF6C63FF).withOpacity(0.4),
        ),
      ),
      child: Text(
        _message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _gameOver
              ? const Color(0xFFFF6B6B)
              : _canInput
                  ? const Color(0xFF00C9A7)
                  : const Color(0xFF6C63FF),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: List.generate(4, (i) => _buildTile(i)),
      ),
    );
  }

  Widget _buildTile(int index) {
    final isHighlighted = _highlightedTile == index;
    final color = _tileColors[index];

    return GestureDetector(
      onTap: () => _onTileTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isHighlighted ? color : color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isHighlighted ? color : color.withOpacity(0.4),
            width: 2,
          ),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.6),
                    blurRadius: 25,
                    spreadRadius: 3,
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(
            _tileEmojis[index],
            style: TextStyle(
              fontSize: isHighlighted ? 50 : 40,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRestartButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _restart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Play Again',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Games',
                style: TextStyle(color: Colors.white60, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
