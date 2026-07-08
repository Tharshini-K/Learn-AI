import 'package:google_generative_ai/google_generative_ai.dart';
import '../utils/constants.dart';
import '../models/quiz_model.dart';
import 'dart:convert';

class GeminiService {
  late GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: AppConstants.geminiApiKey,
    );
  }

  // Generate micro lesson content
  Future<String> generateLesson({
    required String topic,
    required String category,
    required String difficulty,
  }) async {
    try {
      final prompt =
          '''
Generate a concise micro-lesson on the topic: "$topic" in the category "$category" at "$difficulty" level.

Requirements:
- Keep it brief (300-500 words)
- Use simple, clear language
- Include 3-5 key points
- Add practical examples
- Make it engaging and easy to understand
- Format with proper paragraphs

Generate only the lesson content, no additional text.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text ?? 'Error generating lesson';
    } catch (e) {
      return 'Error: $e';
    }
  }

  // Generate quiz questions
  Future<List<Question>> generateQuiz({
    required String topic,
    required String difficulty,
    int numberOfQuestions = 5,
  }) async {
    try {
      final prompt =
          '''
Generate exactly $numberOfQuestions multiple-choice quiz questions on the topic: "$topic" at "$difficulty" level.

For each question, provide:
1. The question text
2. Exactly 4 answer options (labeled A, B, C, D)
3. The correct answer (as a number 0-3, where 0=A, 1=B, 2=C, 3=D)
4. A brief explanation of why the answer is correct

Return the response in this exact JSON format:
{
  "questions": [
    {
      "question": "Question text here?",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "correctAnswer": 0,
      "explanation": "Brief explanation here"
    }
  ]
}

IMPORTANT: Return ONLY valid JSON, no additional text or markdown formatting.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      String responseText = response.text ?? '';

      // Clean response
      responseText = responseText.trim();
      responseText = responseText.replaceAll('```json', '');
      responseText = responseText.replaceAll('```', '');
      responseText = responseText.trim();

      final jsonData = json.decode(responseText);
      final List<dynamic> questionsJson = jsonData['questions'];

      return questionsJson
          .map(
            (q) => Question(
              question: q['question'],
              options: List<String>.from(q['options']),
              correctAnswer: q['correctAnswer'],
              explanation: q['explanation'],
            ),
          )
          .toList();
    } catch (e) {
      print('Error generating quiz: $e');
      // Return fallback questions
      return _getFallbackQuestions(topic);
    }
  }

  // Fallback questions if API fails
  List<Question> _getFallbackQuestions(String topic) {
    return [
      Question(
        question: 'This is a sample question about $topic?',
        options: ['Option A', 'Option B', 'Option C', 'Option D'],
        correctAnswer: 0,
        explanation: 'This is the correct answer because...',
      ),
    ];
  }

  String getRecommendedDifficulty(int averageScore) {
    if (averageScore >= 80) {
      return 'Advanced';
    } else if (averageScore >= 60) {
      return 'Intermediate';
    } else {
      return 'Beginner';
    }
  }
}
