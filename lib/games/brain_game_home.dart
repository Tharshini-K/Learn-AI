import 'package:ed_tech_ai/games/brain_score.dart';
import 'package:ed_tech_ai/games/math_blitz_game.dart';
import 'package:ed_tech_ai/games/memory_match_game.dart';
import 'package:ed_tech_ai/games/pattern_recall_game.dart';
import 'package:ed_tech_ai/games/reaction_time_game.dart';
import 'package:ed_tech_ai/games/word_scramble_game.dart';
import 'package:flutter/material.dart';


class BrainGameHome extends StatefulWidget {
  const BrainGameHome({super.key});

  @override
  State<BrainGameHome> createState() => _BrainGameHomeState();
}

class _BrainGameHomeState extends State<BrainGameHome>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final BrainScoreManager _scoreManager = BrainScoreManager();

  final List<GameInfo> _games = [
    GameInfo(
      title: 'Memory Match',
      description: 'Flip cards & find pairs',
      icon: Icons.grid_view_rounded,
      color: const Color(0xFF6C63FF),
      tag: 'memory',
      difficulty: 'Easy',
    ),
    GameInfo(
      title: 'Math Blitz',
      description: 'Solve equations fast!',
      icon: Icons.calculate_rounded,
      color: const Color(0xFF00C9A7),
      tag: 'math',
      difficulty: 'Medium',
    ),
    GameInfo(
      title: 'Pattern Recall',
      description: 'Remember the sequence',
      icon: Icons.pattern_rounded,
      color: const Color(0xFFFF6584),
      tag: 'pattern',
      difficulty: 'Hard',
    ),
    GameInfo(
      title: 'Word Scramble',
      description: 'Unscramble the letters',
      icon: Icons.sort_by_alpha_rounded,
      color: const Color(0xFFFFBE0B),
      tag: 'word',
      difficulty: 'Easy',
    ),
    GameInfo(
      title: 'Reaction Time',
      description: 'Tap when you see green!',
      icon: Icons.bolt_rounded,
      color: const Color(0xFFFF6B6B),
      tag: 'reaction',
      difficulty: 'Medium',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _openGame(GameInfo game) {
    Widget gameWidget;
    switch (game.tag) {
      case 'memory':
        gameWidget = MemoryMatchGame(onScoreUpdate: _scoreManager.updateScore);
        break;
      case 'math':
        gameWidget = MathBlitzGame(onScoreUpdate: _scoreManager.updateScore);
        break;
      case 'pattern':
        gameWidget = PatternRecallGame(onScoreUpdate: _scoreManager.updateScore);
        break;
      case 'word':
        gameWidget = WordScrambleGame(onScoreUpdate: _scoreManager.updateScore);
        break;
      case 'reaction':
        gameWidget = ReactionTimeGame(onScoreUpdate: _scoreManager.updateScore);
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => gameWidget,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
            child: child,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildBrainIQCard()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text(
                  'Choose Your Challenge',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildGameCard(_games[index], index),
                  childCount: _games.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🧠 Brain Gym',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Train your mind daily',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.leaderboard_rounded,
                color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildBrainIQCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF3A86FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${_scoreManager.brainIQ}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Brain IQ Score',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _scoreManager.brainLevel,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _scoreManager.progressToNextLevel,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(_scoreManager.progressToNextLevel * 100).toInt()}% to next level',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(GameInfo game, int index) {
    final score = _scoreManager.getScore(game.tag);
    return GestureDetector(
      onTap: () => _openGame(game),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: game.color.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: game.color.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: game.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(game.icon, color: game.color, size: 26),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: game.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      game.difficulty,
                      style: TextStyle(
                        color: game.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                game.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                game.description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.star_rounded, color: game.color, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Best: $score',
                    style: TextStyle(
                      color: game.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameInfo {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String tag;
  final String difficulty;

  GameInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.tag,
    required this.difficulty,
  });
}
