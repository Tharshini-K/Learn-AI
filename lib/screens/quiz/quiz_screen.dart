import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/lesson_model.dart';
import '../../models/quiz_model.dart';
import '../../services/app_provider.dart';
import '../../utils/constants.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final Lesson lesson;
  final bool isGameMode;
  final int numberOfQuestions;

  const QuizScreen({
    super.key,
    required this.lesson,
    this.isGameMode = false,
    this.numberOfQuestions = 5,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Quiz? _quiz;
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  bool _isAnswered = false;
  int? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    
    try {
      final quiz = await provider.generateQuiz(
        lessonId: widget.lesson.id,
        topic: widget.lesson.title,
        difficulty: widget.lesson.difficulty,
        numberOfQuestions: widget.numberOfQuestions,
      );
      
      setState(() {
        _quiz = quiz;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating quiz: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  void _answerQuestion(int answer) {
    if (_isAnswered) return;
    
    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;
      _quiz!.questions[_currentQuestionIndex].userAnswer = answer;
      
      if (answer == _quiz!.questions[_currentQuestionIndex].correctAnswer) {
        _quiz!.score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _quiz!.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswered = false;
        _selectedAnswer = null;
      });
    } else {
      _completeQuiz();
    }
  }

  Future<void> _completeQuiz() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    await provider.completeQuiz(
      _quiz!,
      _quiz!.score,
      category: widget.lesson.category,
    );
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => QuizResultScreen(quiz: _quiz!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: Text(
            widget.isGameMode ? 'Starting Quiz Game' : 'Generating Quiz',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                widget.isGameMode
                    ? 'AI is preparing your quiz game...'
                    : 'AI is creating your quiz...',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final question = _quiz!.questions[_currentQuestionIndex];
    final categoryColor = AppConstants.categories
        .firstWhere((c) => c['name'] == widget.lesson.category)['color'] as Color;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: categoryColor,
        foregroundColor: Colors.white,
        title: Text(
          widget.isGameMode ? 'Quiz Game' : 'Quiz',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_currentQuestionIndex + 1}/${_quiz!.questions.length}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _quiz!.questions.length,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
            minHeight: 5,
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Question Card
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      question.question,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  
                  // Options
                  ...List.generate(question.options.length, (index) {
                    final isCorrect = index == question.correctAnswer;
                    final isSelected = index == _selectedAnswer;
                    
                    Color getColor() {
                      if (!_isAnswered) return Colors.white;
                      if (isSelected && isCorrect) return AppColors.success;
                      if (isSelected && !isCorrect) return AppColors.error;
                      if (isCorrect) return AppColors.success;
                      return Colors.white;
                    }
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: InkWell(
                        onTap: () => _answerQuestion(index),
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: getColor(),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: _isAnswered && isSelected
                                  ? getColor()
                                  : categoryColor.withValues(alpha: 0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isAnswered && isSelected
                                      ? Colors.white
                                      : categoryColor.withValues(alpha: 0.1),
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index),
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: _isAnswered && isSelected
                                          ? getColor()
                                          : categoryColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Text(
                                  question.options[index],
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: _isAnswered && isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (_isAnswered && isCorrect)
                                const Icon(Icons.check_circle, color: Colors.white),
                              if (_isAnswered && isSelected && !isCorrect)
                                const Icon(Icons.cancel, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  
                  // Explanation
                  if (_isAnswered)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb_outline, color: AppColors.primary),
                              const SizedBox(width: 10),
                              Text(
                                'Explanation',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            question.explanation,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Next Button
          if (_isAnswered)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: categoryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    _currentQuestionIndex < _quiz!.questions.length - 1
                        ? 'Next Question'
                        : 'See Results',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
