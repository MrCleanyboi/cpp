import 'package:flutter/foundation.dart';

// Base class for all exercises
abstract class LessonExercise {
  final String id;
  final String question;

  LessonExercise({
    required this.id,
    required this.question,
  });
}

// Multiple choice exercise
class MultipleChoiceExercise extends LessonExercise {
  final List<String> options;
  final String answer;

  MultipleChoiceExercise({
    required String id,
    required String question,
    required this.options,
    required this.answer,
  }) : super(id: id, question: question);
}

// Translation exercise
class TranslateExercise extends LessonExercise {
  final String answer;

  TranslateExercise({
    required String id,
    required String question,
    required this.answer,
  }) : super(id: id, question: question);
}

// Lesson model
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

// Data Source with Dynamic Generation
class LessonData {
  static final Map<String, Lesson> lessons = _generateLessons();

  static Map<String, Lesson> _generateLessons() {
    final Map<String, Lesson> data = {};
    final languages = ['de', 'fr', 'es'];

    // 1. Generate Placeholders for ALL 9 Units (3 Lessons each)
    for (var lang in languages) {
      for (var u = 1; u <= 9; u++) {
        for (var l = 1; l <= 3; l++) {
          final id = '${lang}_u${u}_l${l}';
          data[id] = Lesson(
            id: id,
            title: 'Lesson $u-$l', // Fallback title
            description: 'This lesson content is coming soon.',
            exercises: [
              MultipleChoiceExercise(
                id: '${id}_e1',
                question: 'This is a placeholder exercise.',
                options: ['Option A', 'Option B', 'Option C'],
                answer: 'Option A',
              ),
            ],
          );
        }
      }
    }

    // 2. Overwrite with Detailed Content for German Beginner
    _addGermanUnit1(data);
    _addGermanUnit2(data); // Unit 2: Family & Friends
    _addGermanUnit3(data); // Unit 3: My Home

    // 3. Overwrite with Detailed Content for Other Unit 1s
    _addFrenchUnit1(data);
    _addSpanishUnit1(data);

    return data;
  }

  // ==================== GERMAN UNIT 1: THE CAFÉ ====================
  static void _addGermanUnit1(Map<String, Lesson> data) {
    // Lesson 1.1
    data['de_u1_l1'] = Lesson(
      id: 'de_u1_l1',
      title: 'Ordering Coffee',
      description: 'Basic ordering phrases',
      exercises: [
        MultipleChoiceExercise(
          id: 'de_u1_l1_e1',
          question: 'How do you say "I would like" inside a café?',
          options: ['Ich möchte', 'Ich bin', 'Hallo', 'Tschüss'],
          answer: 'Ich möchte',
        ),
        MultipleChoiceExercise(
          id: 'de_u1_l1_e2',
          question: 'Translate: "A coffee, please"',
          options: ['Einen Kaffee, bitte', 'Ein Wasser', 'Bitte schön', 'Danke'],
          answer: 'Einen Kaffee, bitte',
        ),
        TranslateExercise(
          id: 'de_u1_l1_e3',
          question: 'Translate to German: "with milk"',
          answer: 'mit Milch',
        ),
        MultipleChoiceExercise(
          id: 'de_u1_l1_e4',
          question: 'Which word means "sugar"?',
          options: ['Zucker', 'Salz', 'Milch', 'Wasser'],
          answer: 'Zucker',
        ),
      ],
    );
     // Lesson 1.2
    data['de_u1_l2'] = Lesson(
      id: 'de_u1_l2',
      title: 'The Menu',
      description: 'Reading the card',
      exercises: [
        MultipleChoiceExercise(
          id: 'de_u1_l2_e1',
          question: 'What is "Das Frühstück"?',
          options: ['Breakfast', 'Lunch', 'Dinner', 'Snack'],
          answer: 'Breakfast',
        ),
        TranslateExercise(
          id: 'de_u1_l2_e2',
          question: 'Translate: "The menu"',
          answer: 'Die Speisekarte',
        ),
        MultipleChoiceExercise(
          id: 'de_u1_l2_e3',
          question: 'What does "Vegetarisch" mean?',
          options: ['Vegetarian', 'Vegan', 'Meat', 'Fish'],
          answer: 'Vegetarian',
        ),
      ],
    );
     // Lesson 1.3
    data['de_u1_l3'] = Lesson(
      id: 'de_u1_l3',
      title: 'Paying the Bill',
      description: 'Handling money',
      exercises: [
         MultipleChoiceExercise(
          id: 'de_u1_l3_e1',
          question: 'How do you say "The bill, please"?',
          options: ['Die Rechnung, bitte', 'Ich zahle nicht', 'Hallo', 'Danke'],
          answer: 'Die Rechnung, bitte',
        ),
        MultipleChoiceExercise(
          id: 'de_u1_l3_e2',
          question: 'Which phrase means "Is service included?"',
          options: ['Ist Service inklusive?', 'Haben Sie?', 'Wo ist?', 'Danke'],
          answer: 'Ist Service inklusive?',
        ),
        TranslateExercise(
          id: 'de_u1_l3_e3',
          question: 'Translate: "Tips"',
          answer: 'Trinkgeld',
        ),
      ],
    );
  }

  // ==================== GERMAN UNIT 2: FAMILY & FRIENDS ====================
  static void _addGermanUnit2(Map<String, Lesson> data) {
    // Lesson 2.1: Family Members
    data['de_u2_l1'] = Lesson(
      id: 'de_u2_l1',
      title: 'Family Members',
      description: 'Mom, Dad, Siblings',
      exercises: [
        MultipleChoiceExercise(
          id: 'de_u2_l1_e1',
          question: 'How do you say "Mother"?',
          options: ['Mutter', 'Vater', 'Bruder', 'Schwester'],
          answer: 'Mutter',
        ),
        MultipleChoiceExercise(
          id: 'de_u2_l1_e2',
          question: 'How do you say "Father"?',
          options: ['Vater', 'Mutter', 'Onkel', 'Tante'],
          answer: 'Vater',
        ),
        TranslateExercise(
          id: 'de_u2_l1_e3',
          question: 'Translate: "Brother and Sister"',
          answer: 'Bruder und Schwester',
        ),
        MultipleChoiceExercise(
          id: 'de_u2_l1_e4',
          question: 'What means "Parents"?',
          options: ['Eltern', 'Kinder', 'Großeltern', 'Freunde'],
          answer: 'Eltern',
        ),
      ],
    );
    // Lesson 2.2: Describing People
    data['de_u2_l2'] = Lesson(
      id: 'de_u2_l2',
      title: 'Describing People',
      description: 'Is he tall or short?',
      exercises: [
        MultipleChoiceExercise(
          id: 'de_u2_l2_e1',
          question: 'Translate: "High / Tall"',
          options: ['Groß', 'Klein', 'Dick', 'Dünn'],
          answer: 'Groß',
        ),
        TranslateExercise(
          id: 'de_u2_l2_e2',
          question: 'Translate to German: "Small"',
          answer: 'Klein',
        ),
        MultipleChoiceExercise(
          id: 'de_u2_l2_e3',
          question: 'How do you say "Friendly"?',
          options: ['Freundlich', 'Böse', 'Traurig', 'Müde'],
          answer: 'Freundlich',
        ),
        TranslateExercise(
          id: 'de_u2_l2_e4',
          question: 'Translate: "Beautiful"',
          answer: 'Schön',
        ),
      ],
    );
    // Lesson 2.3: Pets
    data['de_u2_l3'] = Lesson(
      id: 'de_u2_l3',
      title: 'Pets',
      description: 'Cats & Dogs',
      exercises: [
        MultipleChoiceExercise(
          id: 'de_u2_l3_e1',
          question: 'How do you say "Dog"?',
          options: ['Hund', 'Katze', 'Maus', 'Vogel'],
          answer: 'Hund',
        ),
        MultipleChoiceExercise(
          id: 'de_u2_l3_e2',
          question: 'How do you say "Cat"?',
          options: ['Katze', 'Hund', 'Pferd', 'Schwein'],
          answer: 'Katze',
        ),
        TranslateExercise(
          id: 'de_u2_l3_e3',
          question: 'Translate: "I have a pet"',
          answer: 'Ich habe ein Haustier',
        ),
      ],
    );
  }

  // ==================== GERMAN UNIT 3: MY HOME ====================
  static void _addGermanUnit3(Map<String, Lesson> data) {
    // Lesson 3.1: Rooms
    data['de_u3_l1'] = Lesson(
      id: 'de_u3_l1',
      title: 'Rooms',
      description: 'Kitchen, Bath, Bedroom',
      exercises: [
        MultipleChoiceExercise(
          id: 'de_u3_l1_e1',
          question: 'How do you say "The Kitchen"?',
          options: ['Die Küche', 'Das Bad', 'Der Flur', 'Das Zimmer'],
          answer: 'Die Küche',
        ),
        MultipleChoiceExercise(
          id: 'de_u3_l1_e2',
          question: 'What is "Das Schlafzimmer"?',
          options: ['Bedroom', 'Living room', 'Bathroom', 'Kitchen'],
          answer: 'Bedroom',
        ),
        TranslateExercise(
          id: 'de_u3_l1_e3',
          question: 'Translate: "Living room"',
          answer: 'Wohnzimmer',
        ),
      ],
    );
    // Lesson 3.2: Furniture
    data['de_u3_l2'] = Lesson(
      id: 'de_u3_l2',
      title: 'Furniture',
      description: 'Table, Chair, Bed',
      exercises: [
        TranslateExercise(
          id: 'de_u3_l2_e1',
          question: 'Translate: "The Table"',
          answer: 'Der Tisch',
        ),
        MultipleChoiceExercise(
          id: 'de_u3_l2_e2',
          question: 'What is "Der Stuhl"?',
          options: ['The Chair', 'The Sofa', 'The Bed', 'The Lamp'],
          answer: 'The Chair',
        ),
        MultipleChoiceExercise(
          id: 'de_u3_l2_e3',
          question: 'How do you say "Bed"?',
          options: ['Bett', 'Bad', 'Tisch', 'Schrank'],
          answer: 'Bett',
        ),
      ],
    );
    // Lesson 3.3: Location (Prepositions)
    data['de_u3_l3'] = Lesson(
      id: 'de_u3_l3',
      title: 'Where is it?',
      description: 'Location prepositions',
      exercises: [
        MultipleChoiceExercise(
          id: 'de_u3_l3_e1',
          question: 'What means "In"?',
          options: ['In', 'Auf', 'Unter', 'Neben'],
          answer: 'In',
        ),
        TranslateExercise(
          id: 'de_u3_l3_e2',
          question: 'Translate: "On the table"',
          answer: 'Auf dem Tisch',
        ),
        MultipleChoiceExercise(
          id: 'de_u3_l3_e3',
          question: 'How do you say "Under"?',
          options: ['Unter', 'Über', 'Hinter', 'Vor'],
          answer: 'Unter',
        ),
      ],
    );
  }


  // ==================== FRENCH UNIT 1: LE CAFÉ ====================
  static void _addFrenchUnit1(Map<String, Lesson> data) {
    data['fr_u1_l1'] = Lesson(
      id: 'fr_u1_l1',
      title: 'Un Café, SVP',
      description: 'Ordering politely',
      exercises: [
        MultipleChoiceExercise(
          id: 'fr_u1_l1_e1',
          question: 'How do you say "I would like"?',
          options: ['Je voudrais', 'Je suis', 'J\'aime', 'Non'],
          answer: 'Je voudrais',
        ),
        MultipleChoiceExercise(
          id: 'fr_u1_l1_e2',
          question: 'Translate: "A coffee, please"',
          options: ['Un café, s\'il vous plaît', 'Un thé', 'Merci', 'Bonjour'],
          answer: 'Un café, s\'il vous plaît',
        ),
        TranslateExercise(
          id: 'fr_u1_l1_e3',
          question: 'Translate to French: "with sugar"',
          answer: 'avec du sucre',
        ),
      ],
    );
    // Add simple placeholders for l2/l3 if needed
  }

  // ==================== SPANISH UNIT 1: EL RESTAURANTE ====================
  static void _addSpanishUnit1(Map<String, Lesson> data) {
    data['es_u1_l1'] = Lesson(
      id: 'es_u1_l1',
      title: 'Ordering Tapas',
      description: 'Small plates',
      exercises: [
        MultipleChoiceExercise(
          id: 'es_u1_l1_e1',
          question: 'How do you say "I want"?',
          options: ['Yo quiero', 'Yo soy', 'Hola', 'Gracias'],
          answer: 'Yo quiero',
        ),
        MultipleChoiceExercise(
          id: 'es_u1_l1_e2',
          question: 'Translate: "The menu, please"',
          options: ['El menú, por favor', 'La cuenta', 'Gracias', 'Hola'],
          answer: 'El menú, por favor',
        ),
      ],
    );
  }

  static Lesson? getLessonByLanguage(String langCode, String lessonId) {
    return lessons[lessonId];
  }

  static Lesson? getLesson(String title) {
    if (title.isEmpty) return null;
    try {
      return lessons.values.firstWhere((l) => l.title == title);
    } catch (e) {
      return null;
    }
  }
}
