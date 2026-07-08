import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/lesson_model.dart';
import '../../utils/constants.dart';
import 'quiz_screen.dart';

class QuizGameSetupScreen extends StatefulWidget {
  const QuizGameSetupScreen({super.key});

  @override
  State<QuizGameSetupScreen> createState() => _QuizGameSetupScreenState();
}

class _QuizGameSetupScreenState extends State<QuizGameSetupScreen> {
  final TextEditingController _topicController = TextEditingController();
  String _selectedCategory = AppConstants.categories.first['name'] as String;
  String _selectedDifficulty = AppConstants.difficultyLevels.first;
  int _questionCount = 5;

  @override
  void initState() {
    super.initState();
    _topicController.text = '$_selectedCategory challenge';
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  void _startGame() {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a quiz topic')),
      );
      return;
    }

    final lesson = Lesson(
      id: 'game_${DateTime.now().millisecondsSinceEpoch}',
      title: topic,
      content: '',
      category: _selectedCategory,
      difficulty: _selectedDifficulty,
      estimatedTime: _questionCount,
      isCompleted: true,
      points: 0,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          lesson: lesson,
          isGameMode: true,
          numberOfQuestions: _questionCount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategoryMap = AppConstants.categories.firstWhere(
      (c) => c['name'] == _selectedCategory,
    );
    final categoryColor = selectedCategoryMap['color'] as Color;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Quiz Game',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: categoryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [categoryColor, categoryColor.withValues(alpha: 0.75)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.emoji_events, color: Colors.white, size: 34),
                  const SizedBox(height: 10),
                  Text(
                    'Start a new challenge',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pick a category, difficulty and number of questions.',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Category',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              items: AppConstants.categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category['name'] as String,
                  child: Text(category['name'] as String),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                final previousDefault = '$_selectedCategory challenge';
                setState(() {
                  _selectedCategory = value;
                  if (_topicController.text.trim().isEmpty ||
                      _topicController.text.trim() == previousDefault) {
                    _topicController.text = '$value challenge';
                  }
                });
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Topic',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _topicController,
              decoration: InputDecoration(
                hintText: 'Example: Basic algebra equations',
                prefixIcon: const Icon(Icons.quiz_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Difficulty',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: AppConstants.difficultyLevels.map((difficulty) {
                final isSelected = _selectedDifficulty == difficulty;
                return ChoiceChip(
                  label: Text(difficulty),
                  selected: isSelected,
                  selectedColor: categoryColor.withValues(alpha: 0.2),
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: isSelected
                        ? categoryColor
                        : AppColors.border,
                  ),
                  labelStyle: GoogleFonts.poppins(
                    color: isSelected ? categoryColor : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) {
                    setState(() {
                      _selectedDifficulty = difficulty;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'Questions',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [5, 8, 10].map((count) {
                final isSelected = _questionCount == count;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: count == 10 ? 0 : 10),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _questionCount = count;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected ? categoryColor : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? categoryColor : AppColors.border,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _startGame,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(
                'Start Quiz Game',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: categoryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
