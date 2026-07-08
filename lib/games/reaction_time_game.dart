import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReactionTimeGame extends StatefulWidget {
  final Function(String, int) onScoreUpdate;
  const ReactionTimeGame({super.key, required this.onScoreUpdate});

  @override
  State<ReactionTimeGame> createState() => _ReactionTimeGameState();
}

enum GamePhase { waiting, ready, go, tooEarly, result }

class _ReactionTimeGameState extends State<ReactionTimeGame>
    with TickerProviderStateMixin {
  GamePhase _phase = GamePhase.waiting;
  DateTime? _goTime;
  int _lastReaction = 0;
  List<int> _results = [];
  Timer? _waitTimer;
  int _round = 0;
  static const int _totalRounds = 5;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  late AnimationController _bgController;
  late Animation<Color?> _bgAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _bgAnim = ColorTween(
      begin: const Color(0xFF1A1A2E),
      end: const Color(0xFF00C9A7),
    ).animate(_bgController);
  }

  @override
  void dispose() {
    _waitTimer?.cancel();
    _pulseController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  void _startRound() {
    setState(() => _phase = GamePhase.ready);
    _bgController.reverse();

    final delay = Duration(milliseconds: 1500 + Random().nextInt(2500));
    _waitTimer = Timer(delay, () {
      if (mounted && _phase == GamePhase.ready) {
        setState(() => _phase = GamePhase.go);
        _goTime = DateTime.now();
        _bgController.forward();
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _onTap() {
    if (_phase == GamePhase.waiting) {
      _round = 0;
      _results = [];
      _startRound();
    } else if (_phase == GamePhase.ready) {
      // Too early!
      _waitTimer?.cancel();
      _bgController.reverse();
      setState(() => _phase = GamePhase.tooEarly);
    } else if (_phase == GamePhase.go) {
      final reaction = DateTime.now().difference(_goTime!).inMilliseconds;
      _lastReaction = reaction;
      _results.add(reaction);
      _round++;
      HapticFeedback.lightImpact();
      _bgController.reverse();

      if (_round >= _totalRounds) {
        final score = _calcScore();
        widget.onScoreUpdate('reaction', score);
        setState(() => _phase = GamePhase.result);
      } else {
        setState(() => _phase = GamePhase.result);
      }
    } else if (_phase == GamePhase.tooEarly || _phase == GamePhase.result) {
      if (_round < _totalRounds) {
        _startRound();
      }
    }
  }

  int _calcScore() {
    if (_results.isEmpty) return 0;
    final avg = _results.reduce((a, b) => a + b) / _results.length;
    // Score: faster = higher. Max ~100, min ~10
    final score = ((1000 / avg) * 50).clamp(10, 100).toInt();
    return score * _results.length;
  }

  int get _avgReaction {
    if (_results.isEmpty) return 0;
    return (_results.reduce((a, b) => a + b) / _results.length).round();
  }

  String get _reactionRating {
    final avg = _avgReaction;
    if (avg < 200) return '⚡ Lightning Fast!';
    if (avg < 250) return '🔥 Excellent!';
    if (avg < 300) return '🌟 Great!';
    if (avg < 400) return '👍 Good';
    return '📚 Keep Practicing';
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
          '⚡ Reaction Time',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          _buildRoundIndicator(),
          const SizedBox(height: 20),
          Expanded(child: _buildMainArea()),
          _buildResults(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildRoundIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_totalRounds, (i) {
          final done = i < _round;
          final current = i == _round && _phase != GamePhase.waiting;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: 40,
            height: 8,
            decoration: BoxDecoration(
              color: done
                  ? const Color(0xFF00C9A7)
                  : current
                      ? const Color(0xFFFFBE0B)
                      : Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMainArea() {
    return GestureDetector(
      onTap: _phase == GamePhase.result && _round >= _totalRounds
          ? null
          : _onTap,
      child: AnimatedBuilder(
        animation: _bgAnim,
        builder: (_, child) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: _bgAnim.value ?? const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: _phase == GamePhase.go
                  ? const Color(0xFF00C9A7)
                  : _phase == GamePhase.tooEarly
                      ? const Color(0xFFFF6B6B)
                      : Colors.white.withOpacity(0.1),
              width: 2,
            ),
            boxShadow: _phase == GamePhase.go
                ? [
                    BoxShadow(
                      color: const Color(0xFF00C9A7).withOpacity(0.4),
                      blurRadius: 30,
                    )
                  ]
                : [],
          ),
          child: Center(
            child: _buildPhaseContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseContent() {
    switch (_phase) {
      case GamePhase.waiting:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _pulseAnim,
              child: const Text('⚡', style: TextStyle(fontSize: 80)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Reaction Test',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              '5 rounds - Tap when GREEN!',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF6584)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'TAP TO START',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1),
              ),
            ),
          ],
        );

      case GamePhase.ready:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _pulseAnim,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFFFF6B6B).withOpacity(0.6), width: 3),
                ),
                child: const Center(
                  child:
                      Text('🔴', style: TextStyle(fontSize: 50)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Wait for GREEN...',
              style: TextStyle(
                  color: Colors.white70, fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Round ${_round + 1} of $_totalRounds',
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 15),
            ),
          ],
        );

      case GamePhase.go:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🟢', style: TextStyle(fontSize: 90)),
            const SizedBox(height: 24),
            const Text(
              'TAP NOW!',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2),
            ),
          ],
        );

      case GamePhase.tooEarly:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😬', style: TextStyle(fontSize: 70)),
            const SizedBox(height: 16),
            const Text(
              'Too Early!',
              style: TextStyle(
                  color: Color(0xFFFF6B6B),
                  fontSize: 32,
                  fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              'Tap to try again',
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
            ),
          ],
        );

      case GamePhase.result:
        if (_round >= _totalRounds) {
          return _buildFinalResult();
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚡', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text(
              '${_lastReaction}ms',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.w900),
            ),
            Text(
              _lastReaction < 250 ? '🔥 Lightning Fast!' : '👍 Good',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7), fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              'Tap for round ${_round + 1}',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.4), fontSize: 14),
            ),
          ],
        );
    }
  }

  Widget _buildFinalResult() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🏆', style: TextStyle(fontSize: 60)),
        const SizedBox(height: 12),
        Text(
          _reactionRating,
          style: const TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Avg: ${_avgReaction}ms',
          style: const TextStyle(
              color: Color(0xFF00C9A7), fontSize: 32, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _phase = GamePhase.waiting;
              _round = 0;
              _results = [];
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B6B),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Play Again',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Widget _buildResults() {
    if (_results.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _results.asMap().entries.map((e) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: e.value < 250
                  ? const Color(0xFF00C9A7).withOpacity(0.15)
                  : Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: e.value < 250
                    ? const Color(0xFF00C9A7).withOpacity(0.4)
                    : Colors.white.withOpacity(0.1),
              ),
            ),
            child: Text(
              '${e.value}ms',
              style: TextStyle(
                color: e.value < 250
                    ? const Color(0xFF00C9A7)
                    : Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
