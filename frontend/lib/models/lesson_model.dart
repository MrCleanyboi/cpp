enum ExerciseType { multipleChoice, translate, fillInBlank, listening }

abstract class LessonExercise {
  final String id;
  final ExerciseType type;
  final String question;
  final String answer; // The correct answer

  LessonExercise({
    required this.id,
    required this.type,
    required this.question,
    required this.answer,
  });
}

class MultipleChoiceExercise extends LessonExercise {
  final List<String> options;

  MultipleChoiceExercise({
    required super.id,
    required super.question,
    required super.answer,
    required this.options,
  }) : super(type: ExerciseType.multipleChoice);
}

class TranslateExercise extends LessonExercise {
  // Can add source language / target language fields if needed later
  TranslateExercise({
    required super.id,
    required super.question, // The sentence to translate
    required super.answer,   // The expected translation
  }) : super(type: ExerciseType.translate);
}

// Simple container for a full lesson
class Lesson {
  final String id;
  final String title;
  final String description;
  final List<LessonExercise> exercises;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.exercises,
  });
}

// Hardcoded data source for now
class LessonData {
  static final Map<String, Lesson> lessons = {
    // Beginner Section
    'Beginner 1': Lesson(
      id: 'beginner_1', 
      title: 'Beginner 1', 
      description: 'Start with simple greetings',
      exercises: [
        MultipleChoiceExercise(
          id: 'b1_e1', 
          question: "How do you say 'Hello'?", 
          options: ["Hallo", "Danke", "Tschüss", "Bitte"], 
          answer: "Hallo"
        ),
      ]
    ),
    'Beginner 2': Lesson(
      id: 'beginner_2', 
      title: 'Beginner 2', 
      description: 'Basic introduction phrases',
      exercises: [
        TranslateExercise(
          id: 'b2_e1',
          question: "My name is...", 
          answer: "Mein Name ist..."
        ),
      ]
    ),
    'Beginner 3': Lesson(
      id: 'beginner_3', 
      title: 'Beginner 3', 
      description: 'Common courtesies',
      exercises: [
        MultipleChoiceExercise(
          id: 'b3_e1', 
          question: "How do you say 'Thank you'?", 
          options: ["Danke", "Bitte", "Hallo"], 
          answer: "Danke"
        ),
      ]
    ),

    // Intermediate Section
    'Intermediate 1': Lesson(
      id: 'intermediate_1', 
      title: 'Intermediate 1', 
      description: 'Talking about daily routine',
      exercises: [
        TranslateExercise(
          id: 'i1_e1',
          question: "I wake up early", 
          answer: "Ich wache früh auf"
        ),
      ]
    ),
    'Intermediate 2': Lesson(
      id: 'intermediate_2', 
      title: 'Intermediate 2', 
      description: 'Ordering food in a restaurant',
      exercises: [
        MultipleChoiceExercise(
          id: 'i2_e1', 
          question: "I would like a menu", 
          options: ["Ich möchte eine Speisekarte", "Ich will Wasser", "Zahlen bitte"], 
          answer: "Ich möchte eine Speisekarte"
        ),
      ]
    ),
    'Intermediate 3': Lesson(
      id: 'intermediate_3', 
      title: 'Intermediate 3', 
      description: 'Travel and directions',
      exercises: [
        TranslateExercise(
          id: 'i3_e1',
          question: "Where is the train station?", 
          answer: "Wo ist der Bahnhof?"
        ),
      ]
    ),

    // Advanced Section
    'Advanced 1': Lesson(
      id: 'advanced_1', 
      title: 'Advanced 1', 
      description: 'Complex sentence structures',
      exercises: [
        TranslateExercise(
          id: 'a1_e1',
          question: "Although it rained, we went out.", 
          answer: "Obwohl es regnete, gingen wir raus."
        ),
      ]
    ),
    'Advanced 2': Lesson(
      id: 'advanced_2', 
      title: 'Advanced 2', 
      description: 'Business communication',
      exercises: [
        MultipleChoiceExercise(
          id: 'a2_e1', 
          question: "Formal greeting in a letter", 
          options: ["Sehr geehrte Damen und Herren", "Hallo Leute", "Was geht"], 
          answer: "Sehr geehrte Damen und Herren"
        ),
      ]
    ),
    'Advanced 3': Lesson(
      id: 'advanced_3', 
      title: 'Advanced 3', 
      description: 'Cultural nuances',
      exercises: [
        TranslateExercise(
          id: 'a3_e1',
          question: "The early bird catches the worm", 
          answer: "Der frühe Vogel fängt den Wurm"
        ),
      ]
    ),
  };

  static Lesson? getLesson(String title) {
    return lessons[title];
  }
}
