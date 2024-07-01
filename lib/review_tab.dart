import 'package:flutter/material.dart';
import 'utils/flashcard.dart';
import 'utils/flashcards_collection.dart';

class ReviewTab extends StatefulWidget {
  // The ReviewTab widget is a StatefulWidget because it needs to be able to update its state
  final FlashcardsCollection flashcardsCollection;

  const ReviewTab({Key? key, required this.flashcardsCollection})
      : super(key: key);

  @override
  State<ReviewTab> createState() => ReviewTabState();
}

class ReviewTabState extends State<ReviewTab> with TickerProviderStateMixin {
  // The _ReviewTabState class is a State because it needs to be able to update its state
  List<Flashcard> dueFlashcards = [];
  late Flashcard _currentFlashcard;
  bool isResponseHidden = true;
  bool isDue = false;
  String _questionText = "";
  String _responseText = "";

  set currentFlashcard(Flashcard currentFlashcard) {
    _currentFlashcard = currentFlashcard;
  }

  @override
  void initState() {
    // The initState() method is called when the stateful widget is inserted into the widget tree
    super.initState();
    updateQuestionText();
  }

  void updateQuestionText() async {
    // Get the due flashcards from the database and set the question text and translated text
    List<Flashcard> dueFlashcards =
        await widget.flashcardsCollection.dueFlashcards();

    if (dueFlashcards.isNotEmpty) {
      _currentFlashcard = dueFlashcards[0];
      setState(() {
        _questionText = _currentFlashcard.front;
        isResponseHidden = true;
        isDue = true;
        _responseText = _currentFlashcard.back;
      });
    } else {
      setState(() {
        _questionText = "Pas de carte à réviser aujourd'hui";
        isResponseHidden = true;
        isDue = false;
      });
    }
  }

  void _displayAnswer() {
    // Display the answer to the question
    setState(() {
      isResponseHidden = false;
    });
  }

  void _onQualityButtonPress(int quality) async {
    // Update the flashcard with the quality in the database then update the question text
    await widget.flashcardsCollection
        .review(_currentFlashcard.front, _currentFlashcard.back, quality);
    updateQuestionText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child:
                  Text(_questionText, style: const TextStyle(fontSize: 18.0)),
            ),
            const SizedBox(height: 16.0),
            Visibility(visible: !isResponseHidden, child: 
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Container(
                  height: 1.0,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16.0),
                Center(child: 
                  Text(_responseText,
                          style: const TextStyle(fontSize: 18.0)
                  ),
                ),
              ])
            ),
            Expanded(
              child: Container(),
            ),
            const SizedBox(height: 16.0),
            Visibility(
              visible: isResponseHidden && isDue,
              child: ElevatedButton(
                onPressed: () async {
                  _displayAnswer();
                },
                child: const Text('Afficher la réponse'),
              ),
            ),
            Visibility(
              visible: !isResponseHidden,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [                    
                    Expanded(
                        child: ElevatedButton(
                      onPressed: () {
                        _onQualityButtonPress(2);
                      },
                      child: const Text("Encore", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red, // Change the color here
                      ),
                    )),
                    Expanded(
                        child: ElevatedButton(
                      onPressed: () {
                        _onQualityButtonPress(3);
                      },
                      child: const Text("Difficile", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.grey, // Change the color here
                      ),
                    )),
                    Expanded(
                        child: ElevatedButton(
                      onPressed: () {
                        _onQualityButtonPress(4);
                      },
                      child: const Text("Correct", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green, // Change the color here
                      ),
                    )),
                    Expanded(
                        child: ElevatedButton(
                      onPressed: () {
                        _onQualityButtonPress(5);
                      },
                      child: const Text("Facile", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue, // Change the color here
                      ),
                    )),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}
    
    
//     Container(padding: const EdgeInsets.all(8.0), child: 
//       Column(children: [

//         Text(_questionText),

//         Visibility(visible: !isResponseHidden, child: 
//           Text(_responseText)
//         ),

//         Expanded(child: 
//           Align(alignment: Alignment.bottomCenter, child: 
//             Visibility(visible: isResponseHidden, child: 
//               ElevatedButton(
//                 onPressed: () async {_displayAnswer();},
//                 child: const Text('Display Answer'),
//               ),
//             )
//           )
//         ),

//         Visibility(visible: !isResponseHidden, child: 
//           Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
//             ElevatedButton(
//               onPressed: () {_onQualityButtonPress(2);},
//               child: const Text("Encore"),
//             ),

//             ElevatedButton(
//               onPressed: () {_onQualityButtonPress(3);},
//               child: const Text("Difficile"),
//             ),
            
//             ElevatedButton(
//               onPressed: () {_onQualityButtonPress(4);},
//               child: const Text("Correct"),
//             ),
            
//             ElevatedButton(
//               onPressed: () {_onQualityButtonPress(5);},
//               child: const Text("Facile"),
//             ),

//           ]),
//         ),
//       ],),  
//     );
//   }
// }
