class CorrectionHelper {
  
  // A simple mock map of errors -> corrections
  static final Map<String, String> _commonErrors = {
    "goed": "went",
    "falled": "fell",
    "runned": "ran",
    "speek": "speak",
    "haved": "had",
    "eated": "ate",
    "teached": "taught",
    "mispelled": "misspelled",
    "definately": "definitely",
    "seperate": "separate",
    "thier": "their",
    "recieve": "receive",
    "doesnt": "doesn't",
    "dont": "don't",
    "im": "I'm",
    "wont": "won't",
    "cant": "can't",
  };

  /// Returns a list of "CorrectionSpan" objects
  /// Each span contains instructions on what range of the text is wrong and the suggestion.
  static List<CorrectionSpan> analyze(String text) {
    List<CorrectionSpan> spans = [];
    final words = text.split(' ');
    int currentIndex = 0;

    for (var word in words) {
      // Remove punctuation for checking
      String cleanWord = word.replaceAll(RegExp(r'[^\w\s\-]'), '').toLowerCase();
      
      if (_commonErrors.containsKey(cleanWord)) {
        spans.add(CorrectionSpan(
          start: currentIndex, 
          end: currentIndex + word.length, 
          original: word, 
          suggestion: _commonErrors[cleanWord]!
        ));
      }
      currentIndex += word.length + 1; // +1 for space
    }

    return spans;
  }
}

class CorrectionSpan {
  final int start;
  final int end;
  final String original;
  final String suggestion;

  CorrectionSpan({
    required this.start, 
    required this.end, 
    required this.original, 
    required this.suggestion
  });
}
