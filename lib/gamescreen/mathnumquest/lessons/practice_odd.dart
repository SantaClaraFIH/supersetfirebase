import 'package:flutter/material.dart';
import '../analytics_engine.dart'; // Import analytics engine

class WordProblemPractice extends StatefulWidget {
  @override
  _WordProblemPracticeState createState() => _WordProblemPracticeState();
}

class _WordProblemPracticeState extends State<WordProblemPractice> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _controller3 = TextEditingController();
  final String practiceType = 'word_problems_candy'; // Define practice type
  bool _isEnglish = true; // Language state

  // Problem sets for different languages
  final List<Map<String, dynamic>> _allProblems = [
    {
      'question_en': 'You have 15 candies. How many candies will be left over after dividing them equally with your friend?',
      'question_es': 'Tienes 15 dulces. ¿Cuántos dulces sobraran después de dividirlos igualmente con tu amigo?',
      'answer': '1',
    },
    {
      'question_en': 'If you have 9 candies and divide them into pairs, how many candies will be left over?',
      'question_es': 'Si tienes 9 dulces y los divides en pares, ¿cuántos dulces sobraran?',
      'answer': '1',
    },
    {
      'question_en': 'Sarah has 7 pens, and Jack has 6 pens. Together, do they have an even or an odd number of pens?',
      'question_es': 'Sarah tiene 7 plumas, y Jack tiene 6 plumas. Juntos, ¿tienen un número par o impar de plumas?',
      'answer': 'Odd',
      'answer_es': 'Impar',
    },
    {
      'question_en': 'You have 20 stickers. If you give away 3 stickers, will you have an even or odd number left?',
      'question_es': 'Tienes 20 calcomanías. Si regalas 3 calcomanías, ¿te quedará un número par o impar?',
      'answer': 'Odd',
      'answer_es': 'Impar',
    },
    {
      'question_en': 'If you have 12 cookies and eat 1, how many cookies will be left?',
      'question_es': 'Si tienes 12 galletas y comes 1, ¿cuántas galletas quedarán?',
      'answer': '11',
    },
    {
      'question_en': 'Tom has 8 marbles. If he loses 2 marbles, will he have an even or odd number left?',
      'question_es': 'Tom tiene 8 canicas. Si pierde 2 canicas, ¿le quedará un número par o impar?',
      'answer': 'Even',
      'answer_es': 'Par',
    },
  ];

  List<Map<String, dynamic>> _currentProblems = [];

  @override
  void initState() {
    super.initState();
    _refreshProblems();
  }

  void _refreshProblems() {
    setState(() {
      _currentProblems = (_allProblems.toList()..shuffle()).take(3).toList();
      // Clear controllers when refreshing
      _controller1.clear();
      _controller2.clear();
      _controller3.clear();
    });
    
    // Log "More Examples" button click
    AnalyticsEngine.logMoreExamplesClick(practiceType);
    print('More Examples clicked in Word Problems Practice');
  }

  void _onTranslatePressed() {
    setState(() {
      _isEnglish = !_isEnglish;
    });
    
    // Log translate button click
    String language = AnalyticsEngine.getLanguageString(_isEnglish);
    AnalyticsEngine.logTranslateButtonClickPractice(language, practiceType);
    print('Translate button clicked in Word Problems Practice: $language');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEnglish ? 'Word Problem Practice' : 'Práctica de Problemas de Palabras'),
        actions: [
          // Add translate button to app bar
          IconButton(
            icon: Icon(Icons.translate),
            onPressed: _onTranslatePressed,
            tooltip: _isEnglish ? 'Translate to Spanish' : 'Traducir al inglés',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/word_problem.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Control buttons at the top
            Container(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _refreshProblems,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      backgroundColor: Colors.lightBlueAccent.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      _isEnglish ? 'More Examples' : 'Más ejemplos',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _onTranslatePressed,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      backgroundColor: Colors.amber.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      _isEnglish ? 'Translate' : 'Traducir',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            // Problems list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _currentProblems.length,
                itemBuilder: (context, index) {
                  return _buildProblemCard(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProblemCard(int index) {
    final problem = _currentProblems[index];
    final controller = index == 0 ? _controller1 : (index == 1 ? _controller2 : _controller3);
    
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _isEnglish ? problem['question_en'] : problem['question_es'],
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: _isNumericAnswer(problem) 
                  ? TextInputType.number 
                  : TextInputType.text,
              decoration: InputDecoration(
                labelText: _isEnglish ? 'Enter your answer' : 'Ingresa tu respuesta',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                _checkAnswer(controller.text, problem, index);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _isEnglish ? 'Check Answer' : 'Verificar respuesta',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isNumericAnswer(Map<String, dynamic> problem) {
    // Check if answer is numeric
    final answer = problem['answer'];
    return RegExp(r'^\d+$').hasMatch(answer);
  }

  void _checkAnswer(String userAnswer, Map<String, dynamic> problem, int questionIndex) {
    String correctAnswer = problem['answer'];
    String correctAnswerEs = problem['answer_es'] ?? correctAnswer;
    
    // Check against both English and Spanish answers if applicable
    bool isCorrect = userAnswer.trim().toLowerCase() == correctAnswer.toLowerCase() ||
                    userAnswer.trim().toLowerCase() == correctAnswerEs.toLowerCase();
    
    // Log practice answer
    AnalyticsEngine.logPracticeAnswer(practiceType, isCorrect);
    print('Word Problems Practice Answer logged: ${isCorrect ? 'Correct' : 'Incorrect'}');
    
    String message = isCorrect
        ? (_isEnglish ? 'Correct Answer!' : '¡Respuesta correcta!')
        : (_isEnglish ? 'Incorrect Answer! Try again.' : '¡Respuesta incorrecta! Inténtalo de nuevo.');
    
    _showSnackBar(message);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        backgroundColor: message.contains('Correct') || message.contains('correcta') 
            ? Colors.green 
            : Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }
}