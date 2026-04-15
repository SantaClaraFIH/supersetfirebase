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
  final String practiceType = 'word_problems'; // Define practice type
  bool _isEnglish = true; // Language state

  // Problem sets for different languages
  final List<Map<String, dynamic>> _allProblems = [
    {
      'question_en': 'Which of the following is NOT an odd number?\n225\n233\n370\n391',
      'question_es': '¿Cuál de los siguientes NO es un número impar?\n225\n233\n370\n391',
      'answer': '370',
    },
    {
      'question_en': 'Which number is an even number?\n23\n19\n24\n31',
      'question_es': '¿Qué número es un número par?\n23\n19\n24\n31',
      'answer': '24',
    },
    {
      'question_en': 'Which is a set of EVEN numbers?\n96, 107, 128, 139\n85, 97, 119, 211\n106, 148, 190, 202\n112, 153, 188, 216',
      'question_es': '¿Cuál es un conjunto de números PARES?\n96, 107, 128, 139\n85, 97, 119, 211\n106, 148, 190, 202\n112, 153, 188, 216',
      'answer': '106, 148, 190, 202',
    },
    {
      'question_en': 'Which number is prime?\n15\n21\n17\n25',
      'question_es': '¿Qué número es primo?\n15\n21\n17\n25',
      'answer': '17',
    },
    {
      'question_en': 'Which is the smallest composite number?\n1\n2\n3\n4',
      'question_es': '¿Cuál es el número compuesto más pequeño?\n1\n2\n3\n4',
      'answer': '4',
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
        title: Text(_isEnglish ? 'Word Problem Practice ' : 'Práctica de Problemas de Palabras'),
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
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: _isEnglish ? 'Enter your answer' : 'Ingresa tu respuesta',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                _checkAnswer(controller.text, problem['answer'], index);
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

  void _checkAnswer(String userAnswer, String correctAnswer, int questionIndex) {
    bool isCorrect = userAnswer.trim().toLowerCase() == correctAnswer.toLowerCase();
    
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