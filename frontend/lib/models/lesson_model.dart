import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────
//  VOCAB PREVIEW MODELS
// ─────────────────────────────────────────────────────────

/// A single vocabulary card shown in the intro preview screen.
class VocabItem {
  final String word;               // Target language word/phrase
  final String meaning;            // English meaning
  final String example;            // Example sentence in target language
  final String exampleTranslation; // English translation of the example

  const VocabItem({
    required this.word,
    required this.meaning,
    required this.example,
    required this.exampleTranslation,
  });
}

/// A preparatory lesson shown before the quiz lessons of a unit.
class IntroLesson {
  final String id;
  final String title;
  final List<VocabItem> vocabItems;

  const IntroLesson({
    required this.id,
    required this.title,
    required this.vocabItems,
  });
}

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

    // 2. Overwrite with Detailed Content for German (all 3 beginner units)
    _addGermanUnit1(data);
    _addGermanUnit2(data);
    _addGermanUnit3(data);

    // 3. Overwrite with Detailed Content for French (all 9 units)
    _addFrenchUnit1(data);
    _addFrenchUnit2(data);
    _addFrenchUnit3(data);
    _addFrenchUnit4(data);
    _addFrenchUnit5(data);
    _addFrenchUnit6(data);
    _addFrenchUnit7(data);
    _addFrenchUnit8(data);
    _addFrenchUnit9(data);

    // 4. Overwrite with Detailed Content for Spanish (all 9 units)
    _addSpanishUnit1(data);
    _addSpanishUnit2(data);
    _addSpanishUnit3(data);
    _addSpanishUnit4(data);
    _addSpanishUnit5(data);
    _addSpanishUnit6(data);
    _addSpanishUnit7(data);
    _addSpanishUnit8(data);
    _addSpanishUnit9(data);

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



  // ==================== FRENCH — ALL 9 UNITS ====================
  static void _addFrenchUnit1(Map<String, Lesson> data) {
    // 1.1 Un Café, SVP
    data['fr_u1_l1'] = Lesson(id: 'fr_u1_l1', title: 'Un Café, SVP', description: 'Ordering politely', exercises: [
      MultipleChoiceExercise(id: 'fr_u1_l1_e1', question: 'How do you say "I would like"?', options: ['Je voudrais', 'Je suis', "J'aime", 'Non'], answer: 'Je voudrais'),
      MultipleChoiceExercise(id: 'fr_u1_l1_e2', question: 'Translate: "A coffee, please"', options: ["Un café, s'il vous plaît", 'Un thé', 'Merci', 'Bonjour'], answer: "Un café, s'il vous plaît"),
      TranslateExercise(id: 'fr_u1_l1_e3', question: 'Translate to French: "with sugar"', answer: 'avec du sucre'),
      MultipleChoiceExercise(id: 'fr_u1_l1_e4', question: 'Which word means "milk"?', options: ['Du lait', 'Du sucre', 'De l\'eau', 'Du pain'], answer: 'Du lait'),
    ]);
    // 1.2 Croissants
    data['fr_u1_l2'] = Lesson(id: 'fr_u1_l2', title: 'Le Petit-déjeuner', description: 'Breakfast items', exercises: [
      MultipleChoiceExercise(id: 'fr_u1_l2_e1', question: 'What is "Le petit-déjeuner"?', options: ['Breakfast', 'Lunch', 'Dinner', 'Snack'], answer: 'Breakfast'),
      TranslateExercise(id: 'fr_u1_l2_e2', question: 'Translate: "The menu"', answer: 'La carte'),
      MultipleChoiceExercise(id: 'fr_u1_l2_e3', question: 'What does "végétarien" mean?', options: ['Vegetarian', 'Vegan', 'Meat dish', 'Fish'], answer: 'Vegetarian'),
      TranslateExercise(id: 'fr_u1_l2_e4', question: 'Translate: "A croissant"', answer: 'Un croissant'),
    ]);
    // 1.3 Paying
    data['fr_u1_l3'] = Lesson(id: 'fr_u1_l3', title: "L'Addition", description: 'Paying the bill', exercises: [
      MultipleChoiceExercise(id: 'fr_u1_l3_e1', question: 'How do you say "The bill, please"?', options: ["L'addition, s'il vous plaît", 'Je ne paie pas', 'Bonjour', 'Merci'], answer: "L'addition, s'il vous plaît"),
      MultipleChoiceExercise(id: 'fr_u1_l3_e2', question: 'How do you say "service included"?', options: ['Service compris', 'Service inclus', 'Prix fixe', 'Hors service'], answer: 'Service compris'),
      TranslateExercise(id: 'fr_u1_l3_e3', question: 'Translate: "A tip"', answer: 'Un pourboire'),
    ]);
  }

  static void _addFrenchUnit2(Map<String, Lesson> data) {
    // 2.1 Family Members
    data['fr_u2_l1'] = Lesson(id: 'fr_u2_l1', title: 'La Famille', description: 'Parents & siblings', exercises: [
      MultipleChoiceExercise(id: 'fr_u2_l1_e1', question: 'How do you say "Mother"?', options: ['La mère', 'Le père', 'Le frère', 'La sœur'], answer: 'La mère'),
      MultipleChoiceExercise(id: 'fr_u2_l1_e2', question: 'How do you say "Father"?', options: ['Le père', 'La mère', "L'oncle", 'La tante'], answer: 'Le père'),
      TranslateExercise(id: 'fr_u2_l1_e3', question: 'Translate: "Brother and sister"', answer: 'Le frère et la sœur'),
      MultipleChoiceExercise(id: 'fr_u2_l1_e4', question: 'What means "Parents"?', options: ['Les parents', 'Les enfants', 'Les grands-parents', 'Les amis'], answer: 'Les parents'),
    ]);
    // 2.2 Describing People
    data['fr_u2_l2'] = Lesson(id: 'fr_u2_l2', title: 'Décrire les Gens', description: 'Descriptions', exercises: [
      MultipleChoiceExercise(id: 'fr_u2_l2_e1', question: 'Translate: "Tall"', options: ['Grand(e)', 'Petit(e)', 'Gros(se)', 'Mince'], answer: 'Grand(e)'),
      TranslateExercise(id: 'fr_u2_l2_e2', question: 'Translate to French: "Small"', answer: 'Petit(e)'),
      MultipleChoiceExercise(id: 'fr_u2_l2_e3', question: 'How do you say "Friendly"?', options: ['Sympa', 'Méchant', 'Triste', 'Fatigue'], answer: 'Sympa'),
      TranslateExercise(id: 'fr_u2_l2_e4', question: 'Translate: "Beautiful"', answer: 'Beau / Belle'),
    ]);
    // 2.3 Pets
    data['fr_u2_l3'] = Lesson(id: 'fr_u2_l3', title: 'Les Animaux', description: 'Pets & animals', exercises: [
      MultipleChoiceExercise(id: 'fr_u2_l3_e1', question: 'How do you say "Dog"?', options: ['Le chien', 'Le chat', 'La souris', "L'oiseau"], answer: 'Le chien'),
      MultipleChoiceExercise(id: 'fr_u2_l3_e2', question: 'How do you say "Cat"?', options: ['Le chat', 'Le chien', 'Le cheval', 'Le cochon'], answer: 'Le chat'),
      TranslateExercise(id: 'fr_u2_l3_e3', question: 'Translate: "I have a pet"', answer: "J'ai un animal de compagnie"),
    ]);
  }

  static void _addFrenchUnit3(Map<String, Lesson> data) {
    // 3.1 Rooms
    data['fr_u3_l1'] = Lesson(id: 'fr_u3_l1', title: 'Les Pièces', description: 'Rooms in the house', exercises: [
      MultipleChoiceExercise(id: 'fr_u3_l1_e1', question: 'How do you say "The kitchen"?', options: ['La cuisine', 'La chambre', 'Le couloir', 'La salle de bain'], answer: 'La cuisine'),
      MultipleChoiceExercise(id: 'fr_u3_l1_e2', question: 'What is "La chambre"?', options: ['Bedroom', 'Living room', 'Bathroom', 'Kitchen'], answer: 'Bedroom'),
      TranslateExercise(id: 'fr_u3_l1_e3', question: 'Translate: "Living room"', answer: 'Le salon'),
    ]);
    // 3.2 Furniture
    data['fr_u3_l2'] = Lesson(id: 'fr_u3_l2', title: 'Les Meubles', description: 'Furniture items', exercises: [
      TranslateExercise(id: 'fr_u3_l2_e1', question: 'Translate: "The table"', answer: 'La table'),
      MultipleChoiceExercise(id: 'fr_u3_l2_e2', question: 'What is "La chaise"?', options: ['The chair', 'The sofa', 'The bed', 'The lamp'], answer: 'The chair'),
      MultipleChoiceExercise(id: 'fr_u3_l2_e3', question: 'How do you say "Bed"?', options: ['Le lit', 'La baignoire', 'La table', "L'armoire"], answer: 'Le lit'),
    ]);
    // 3.3 Location
    data['fr_u3_l3'] = Lesson(id: 'fr_u3_l3', title: 'Où est-il?', description: 'Prepositions of place', exercises: [
      MultipleChoiceExercise(id: 'fr_u3_l3_e1', question: 'What means "On top of"?', options: ['Sur', 'Sous', 'Dans', 'À côté de'], answer: 'Sur'),
      TranslateExercise(id: 'fr_u3_l3_e2', question: 'Translate: "On the table"', answer: 'Sur la table'),
      MultipleChoiceExercise(id: 'fr_u3_l3_e3', question: 'How do you say "Under"?', options: ['Sous', 'Sur', 'Derrière', 'Devant'], answer: 'Sous'),
    ]);
  }

  static void _addFrenchUnit4(Map<String, Lesson> data) {
    data['fr_u4_l1'] = Lesson(id: 'fr_u4_l1', title: 'Le Métro', description: 'Using public transport', exercises: [
      MultipleChoiceExercise(id: 'fr_u4_l1_e1', question: 'How do you say "A ticket"?', options: ['Un billet', 'Un passeport', 'Un sac', 'Un train'], answer: 'Un billet'),
      TranslateExercise(id: 'fr_u4_l1_e2', question: 'Translate: "Which platform?"', answer: 'Quel quai?'),
      MultipleChoiceExercise(id: 'fr_u4_l1_e3', question: '"Le prochain train" means?', options: ['The next train', 'The last train', 'The fast train', 'The slow train'], answer: 'The next train'),
    ]);
    data['fr_u4_l2'] = Lesson(id: 'fr_u4_l2', title: 'Le Musée', description: 'At the museum', exercises: [
      MultipleChoiceExercise(id: 'fr_u4_l2_e1', question: 'How do you say "The entrance"?', options: ["L'entrée", 'La sortie', 'Le tableau', 'Le guide'], answer: "L'entrée"),
      TranslateExercise(id: 'fr_u4_l2_e2', question: 'Translate: "How much is a ticket?"', answer: "Combien coûte un billet?"),
      MultipleChoiceExercise(id: 'fr_u4_l2_e3', question: '"Un tableau" means?', options: ['A painting', 'A table', 'A ticket', 'A tour'], answer: 'A painting'),
    ]);
    data['fr_u4_l3'] = Lesson(id: 'fr_u4_l3', title: 'Les Directions', description: 'Asking for directions', exercises: [
      MultipleChoiceExercise(id: 'fr_u4_l3_e1', question: 'How do you say "Turn left"?', options: ['Tournez à gauche', 'Tournez à droite', 'Allez tout droit', 'Revenez'], answer: 'Tournez à gauche'),
      TranslateExercise(id: 'fr_u4_l3_e2', question: 'Translate: "Straight ahead"', answer: 'Tout droit'),
      MultipleChoiceExercise(id: 'fr_u4_l3_e3', question: '"À droite" means?', options: ['To the right', 'To the left', 'Behind', 'In front'], answer: 'To the right'),
    ]);
  }

  static void _addFrenchUnit5(Map<String, Lesson> data) {
    data['fr_u5_l1'] = Lesson(id: 'fr_u5_l1', title: 'Les Sports', description: 'Talking about sport', exercises: [
      MultipleChoiceExercise(id: 'fr_u5_l1_e1', question: 'How do you say "I play football"?', options: ['Je joue au football', 'Je regarde le foot', 'Je cours', 'Je nage'], answer: 'Je joue au football'),
      TranslateExercise(id: 'fr_u5_l1_e2', question: 'Translate: "I like running"', answer: "J'aime courir"),
      MultipleChoiceExercise(id: 'fr_u5_l1_e3', question: '"Nager" means?', options: ['To swim', 'To run', 'To jump', 'To play'], answer: 'To swim'),
    ]);
    data['fr_u5_l2'] = Lesson(id: 'fr_u5_l2', title: 'Cinéma & Musique', description: 'Entertainment', exercises: [
      MultipleChoiceExercise(id: 'fr_u5_l2_e1', question: 'How do you say "I watch a movie"?', options: ['Je regarde un film', 'Je lis un livre', "J'écoute la radio", 'Je joue'], answer: 'Je regarde un film'),
      TranslateExercise(id: 'fr_u5_l2_e2', question: 'Translate: "I love music"', answer: "J'adore la musique"),
      MultipleChoiceExercise(id: 'fr_u5_l2_e3', question: '"Un concert" means?', options: ['A concert', 'A contest', 'A film', 'A song'], answer: 'A concert'),
    ]);
    data['fr_u5_l3'] = Lesson(id: 'fr_u5_l3', title: 'Le Week-end', description: 'Weekend activities', exercises: [
      MultipleChoiceExercise(id: 'fr_u5_l3_e1', question: 'How do you say "I go out with friends"?', options: ['Je sors avec des amis', 'Je reste chez moi', 'Je travaille', 'Je dors'], answer: 'Je sors avec des amis'),
      TranslateExercise(id: 'fr_u5_l3_e2', question: 'Translate: "On Saturday"', answer: 'Le samedi'),
      MultipleChoiceExercise(id: 'fr_u5_l3_e3', question: '"Se reposer" means?', options: ['To rest', 'To work', 'To play', 'To travel'], answer: 'To rest'),
    ]);
  }

  static void _addFrenchUnit6(Map<String, Lesson> data) {
    data['fr_u6_l1'] = Lesson(id: 'fr_u6_l1', title: 'Les Vêtements', description: 'Clothing vocabulary', exercises: [
      MultipleChoiceExercise(id: 'fr_u6_l1_e1', question: 'How do you say "Shirt"?', options: ['La chemise', 'Le pantalon', 'La robe', 'La veste'], answer: 'La chemise'),
      TranslateExercise(id: 'fr_u6_l1_e2', question: 'Translate: "Shoes"', answer: 'Les chaussures'),
      MultipleChoiceExercise(id: 'fr_u6_l1_e3', question: '"Une robe" means?', options: ['A dress', 'A robe', 'A coat', 'A skirt'], answer: 'A dress'),
    ]);
    data['fr_u6_l2'] = Lesson(id: 'fr_u6_l2', title: 'Les Couleurs', description: 'Colors & descriptions', exercises: [
      MultipleChoiceExercise(id: 'fr_u6_l2_e1', question: 'How do you say "Blue"?', options: ['Bleu', 'Rouge', 'Vert', 'Jaune'], answer: 'Bleu'),
      TranslateExercise(id: 'fr_u6_l2_e2', question: 'Translate: "The green bag"', answer: 'Le sac vert'),
      MultipleChoiceExercise(id: 'fr_u6_l2_e3', question: '"Noir" means?', options: ['Black', 'White', 'Grey', 'Brown'], answer: 'Black'),
    ]);
    data['fr_u6_l3'] = Lesson(id: 'fr_u6_l3', title: 'La Boutique', description: 'Shopping phrases', exercises: [
      MultipleChoiceExercise(id: 'fr_u6_l3_e1', question: 'How do you say "How much does it cost?"', options: ["Ça coûte combien?", 'Où est la caisse?', 'Je voudrais', 'Avez-vous?'], answer: "Ça coûte combien?"),
      TranslateExercise(id: 'fr_u6_l3_e2', question: 'Translate: "Too expensive"', answer: 'Trop cher'),
      MultipleChoiceExercise(id: 'fr_u6_l3_e3', question: '"La caisse" means?', options: ['The checkout', 'The window', 'The bag', 'The price'], answer: 'The checkout'),
    ]);
  }

  static void _addFrenchUnit7(Map<String, Lesson> data) {
    data['fr_u7_l1'] = Lesson(id: 'fr_u7_l1', title: "L'Entretien", description: 'Job interviews', exercises: [
      MultipleChoiceExercise(id: 'fr_u7_l1_e1', question: 'How do you say "I am applying for the job"?', options: ['Je postule pour le poste', 'Je démissionne', 'Je travaille', "J'apprends"], answer: 'Je postule pour le poste'),
      TranslateExercise(id: 'fr_u7_l1_e2', question: 'Translate: "My experience"', answer: 'Mon expérience'),
      MultipleChoiceExercise(id: 'fr_u7_l1_e3', question: '"Un CV" means?', options: ['A résumé', 'A contract', 'A certificate', 'A business card'], answer: 'A résumé'),
    ]);
    data['fr_u7_l2'] = Lesson(id: 'fr_u7_l2', title: 'Au Bureau', description: 'Office life', exercises: [
      MultipleChoiceExercise(id: 'fr_u7_l2_e1', question: 'How do you say "The office"?', options: ['Le bureau', 'La salle', 'La réunion', 'Le couloir'], answer: 'Le bureau'),
      TranslateExercise(id: 'fr_u7_l2_e2', question: 'Translate: "My colleague"', answer: 'Mon/ma collègue'),
      MultipleChoiceExercise(id: 'fr_u7_l2_e3', question: '"Télétravailler" means?', options: ['To work from home', 'To telephone', 'To travel for work', 'To retire'], answer: 'To work from home'),
    ]);
    data['fr_u7_l3'] = Lesson(id: 'fr_u7_l3', title: 'La Réunion', description: 'Business meetings', exercises: [
      MultipleChoiceExercise(id: 'fr_u7_l3_e1', question: 'How do you say "The meeting starts at 10"?', options: ['La réunion commence à 10h', 'La réunion finit à 10h', 'Je suis en retard', 'Excusez-moi'], answer: 'La réunion commence à 10h'),
      TranslateExercise(id: 'fr_u7_l3_e2', question: 'Translate: "I have an appointment"', answer: "J'ai un rendez-vous"),
      MultipleChoiceExercise(id: 'fr_u7_l3_e3', question: '"Un ordre du jour" means?', options: ['An agenda', 'A working day', 'A deadline', 'A proposal'], answer: 'An agenda'),
    ]);
  }

  static void _addFrenchUnit8(Map<String, Lesson> data) {
    data['fr_u8_l1'] = Lesson(id: 'fr_u8_l1', title: 'Le Journal', description: 'Reading the news', exercises: [
      MultipleChoiceExercise(id: 'fr_u8_l1_e1', question: 'How do you say "The news"?', options: ['Les informations', 'Les nouvelles', 'Le roman', 'Le magazine'], answer: 'Les informations'),
      TranslateExercise(id: 'fr_u8_l1_e2', question: 'Translate: "The headline"', answer: 'Le titre / La manchette'),
      MultipleChoiceExercise(id: 'fr_u8_l1_e3', question: '"Un reportage" means?', options: ['A news report', 'A novel', 'A report card', 'An interview'], answer: 'A news report'),
    ]);
    data['fr_u8_l2'] = Lesson(id: 'fr_u8_l2', title: 'La Politique', description: 'Politics & society', exercises: [
      MultipleChoiceExercise(id: 'fr_u8_l2_e1', question: 'How do you say "The government"?', options: ['Le gouvernement', 'La police', 'Le tribunal', 'Le maire'], answer: 'Le gouvernement'),
      TranslateExercise(id: 'fr_u8_l2_e2', question: 'Translate: "The election"', answer: "L'élection"),
      MultipleChoiceExercise(id: 'fr_u8_l2_e3', question: '"Voter" means?', options: ['To vote', 'To see', 'To travel', 'To protest'], answer: 'To vote'),
    ]);
    data['fr_u8_l3'] = Lesson(id: 'fr_u8_l3', title: "L'Internet", description: 'Digital life', exercises: [
      MultipleChoiceExercise(id: 'fr_u8_l3_e1', question: 'How do you say "Social media"?', options: ['Les réseaux sociaux', 'Les médias', 'Le web', 'Les données'], answer: 'Les réseaux sociaux'),
      TranslateExercise(id: 'fr_u8_l3_e2', question: 'Translate: "I send an email"', answer: "J'envoie un courriel"),
      MultipleChoiceExercise(id: 'fr_u8_l3_e3', question: '"Télécharger" means?', options: ['To download', 'To upload', 'To send', 'To delete'], answer: 'To download'),
    ]);
  }

  static void _addFrenchUnit9(Map<String, Lesson> data) {
    data['fr_u9_l1'] = Lesson(id: 'fr_u9_l1', title: 'La Nature', description: 'The natural world', exercises: [
      MultipleChoiceExercise(id: 'fr_u9_l1_e1', question: 'How do you say "The forest"?', options: ['La forêt', 'La mer', 'La montagne', 'La rivière'], answer: 'La forêt'),
      TranslateExercise(id: 'fr_u9_l1_e2', question: 'Translate: "The river"', answer: 'La rivière'),
      MultipleChoiceExercise(id: 'fr_u9_l1_e3', question: '"La faune" means?', options: ['Wildlife / Fauna', 'Flora', 'The sky', 'The soil'], answer: 'Wildlife / Fauna'),
    ]);
    data['fr_u9_l2'] = Lesson(id: 'fr_u9_l2', title: 'La Pollution', description: 'Environmental issues', exercises: [
      MultipleChoiceExercise(id: 'fr_u9_l2_e1', question: 'How do you say "Pollution"?', options: ['La pollution', 'Le recyclage', 'La nature', "L'énergie"], answer: 'La pollution'),
      TranslateExercise(id: 'fr_u9_l2_e2', question: 'Translate: "Climate change"', answer: 'Le changement climatique'),
      MultipleChoiceExercise(id: 'fr_u9_l2_e3', question: '"Les énergies renouvelables" means?', options: ['Renewable energy', 'Nuclear energy', 'Fossil fuels', 'Solar panels'], answer: 'Renewable energy'),
    ]);
    data['fr_u9_l3'] = Lesson(id: 'fr_u9_l3', title: 'Recycler', description: 'Sustainability debate', exercises: [
      MultipleChoiceExercise(id: 'fr_u9_l3_e1', question: 'How do you say "We must protect the environment"?', options: ["Il faut protéger l'environnement", 'Je recycle', 'La planète est belle', "L'avenir est sombre"], answer: "Il faut protéger l'environnement"),
      TranslateExercise(id: 'fr_u9_l3_e2', question: 'Translate: "In my opinion"', answer: 'À mon avis'),
      MultipleChoiceExercise(id: 'fr_u9_l3_e3', question: '"Durable" means?', options: ['Sustainable', 'Durable (goods)', 'Hard', 'Long'], answer: 'Sustainable'),
    ]);
  }

  // ==================== SPANISH — ALL 9 UNITS ====================
  static void _addSpanishUnit1(Map<String, Lesson> data) {
    // 1.1 Tapas
    data['es_u1_l1'] = Lesson(id: 'es_u1_l1', title: 'Ordenar Tapas', description: 'Ordering food', exercises: [
      MultipleChoiceExercise(id: 'es_u1_l1_e1', question: 'How do you say "I want"?', options: ['Yo quiero', 'Yo soy', 'Hola', 'Gracias'], answer: 'Yo quiero'),
      MultipleChoiceExercise(id: 'es_u1_l1_e2', question: 'Translate: "The menu, please"', options: ['El menú, por favor', 'La cuenta', 'Gracias', 'Hola'], answer: 'El menú, por favor'),
      TranslateExercise(id: 'es_u1_l1_e3', question: 'Translate to Spanish: "with water"', answer: 'con agua'),
      MultipleChoiceExercise(id: 'es_u1_l1_e4', question: 'Which word means "sugar"?', options: ['Azúcar', 'Sal', 'Leche', 'Agua'], answer: 'Azúcar'),
    ]);
    // 1.2 Bebidas
    data['es_u1_l2'] = Lesson(id: 'es_u1_l2', title: 'Las Bebidas', description: 'Drinks & breakfast', exercises: [
      MultipleChoiceExercise(id: 'es_u1_l2_e1', question: 'What is "El desayuno"?', options: ['Breakfast', 'Lunch', 'Dinner', 'Snack'], answer: 'Breakfast'),
      TranslateExercise(id: 'es_u1_l2_e2', question: 'Translate: "An orange juice"', answer: 'Un zumo de naranja'),
      MultipleChoiceExercise(id: 'es_u1_l2_e3', question: 'What does "sin gluten" mean?', options: ['Gluten-free', 'Vegan', 'With meat', 'With fish'], answer: 'Gluten-free'),
    ]);
    // 1.3 La Cuenta
    data['es_u1_l3'] = Lesson(id: 'es_u1_l3', title: 'La Cuenta', description: 'Paying the bill', exercises: [
      MultipleChoiceExercise(id: 'es_u1_l3_e1', question: 'How do you say "The bill, please"?', options: ['La cuenta, por favor', 'No pago', 'Hola', 'Gracias'], answer: 'La cuenta, por favor'),
      MultipleChoiceExercise(id: 'es_u1_l3_e2', question: 'Which phrase means "Is service included?"', options: ['¿Está incluido el servicio?', '¿Tienen mesa?', '¿Dónde está?', 'Gracias'], answer: '¿Está incluido el servicio?'),
      TranslateExercise(id: 'es_u1_l3_e3', question: 'Translate: "A tip"', answer: 'Una propina'),
    ]);
  }

  static void _addSpanishUnit2(Map<String, Lesson> data) {
    data['es_u2_l1'] = Lesson(id: 'es_u2_l1', title: 'La Familia', description: 'Family members', exercises: [
      MultipleChoiceExercise(id: 'es_u2_l1_e1', question: 'How do you say "Mother"?', options: ['La madre', 'El padre', 'El hermano', 'La hermana'], answer: 'La madre'),
      MultipleChoiceExercise(id: 'es_u2_l1_e2', question: 'How do you say "Father"?', options: ['El padre', 'La madre', 'El tío', 'La tía'], answer: 'El padre'),
      TranslateExercise(id: 'es_u2_l1_e3', question: 'Translate: "Brother and sister"', answer: 'El hermano y la hermana'),
      MultipleChoiceExercise(id: 'es_u2_l1_e4', question: 'What means "Parents"?', options: ['Los padres', 'Los hijos', 'Los abuelos', 'Los amigos'], answer: 'Los padres'),
    ]);
    data['es_u2_l2'] = Lesson(id: 'es_u2_l2', title: 'Describir Personas', description: 'Descriptions', exercises: [
      MultipleChoiceExercise(id: 'es_u2_l2_e1', question: 'Translate: "Tall"', options: ['Alto/Alta', 'Bajo/Baja', 'Gordo/Gorda', 'Delgado/Delgada'], answer: 'Alto/Alta'),
      TranslateExercise(id: 'es_u2_l2_e2', question: 'Translate to Spanish: "Short"', answer: 'Bajo/Baja'),
      MultipleChoiceExercise(id: 'es_u2_l2_e3', question: 'How do you say "Friendly"?', options: ['Simpático/a', 'Antipático/a', 'Triste', 'Cansado/a'], answer: 'Simpático/a'),
      TranslateExercise(id: 'es_u2_l2_e4', question: 'Translate: "Beautiful"', answer: 'Hermoso/Hermosa'),
    ]);
    data['es_u2_l3'] = Lesson(id: 'es_u2_l3', title: 'Las Mascotas', description: 'Pets & animals', exercises: [
      MultipleChoiceExercise(id: 'es_u2_l3_e1', question: 'How do you say "Dog"?', options: ['El perro', 'El gato', 'El ratón', 'El pájaro'], answer: 'El perro'),
      MultipleChoiceExercise(id: 'es_u2_l3_e2', question: 'How do you say "Cat"?', options: ['El gato', 'El perro', 'El caballo', 'El cerdo'], answer: 'El gato'),
      TranslateExercise(id: 'es_u2_l3_e3', question: 'Translate: "I have a pet"', answer: 'Tengo una mascota'),
    ]);
  }

  static void _addSpanishUnit3(Map<String, Lesson> data) {
    data['es_u3_l1'] = Lesson(id: 'es_u3_l1', title: 'Las Habitaciones', description: 'Rooms of a house', exercises: [
      MultipleChoiceExercise(id: 'es_u3_l1_e1', question: 'How do you say "The kitchen"?', options: ['La cocina', 'El dormitorio', 'El pasillo', 'El baño'], answer: 'La cocina'),
      MultipleChoiceExercise(id: 'es_u3_l1_e2', question: 'What is "El dormitorio"?', options: ['Bedroom', 'Living room', 'Bathroom', 'Kitchen'], answer: 'Bedroom'),
      TranslateExercise(id: 'es_u3_l1_e3', question: 'Translate: "Living room"', answer: 'El salón / La sala de estar'),
    ]);
    data['es_u3_l2'] = Lesson(id: 'es_u3_l2', title: 'Los Muebles', description: 'Furniture', exercises: [
      TranslateExercise(id: 'es_u3_l2_e1', question: 'Translate: "The table"', answer: 'La mesa'),
      MultipleChoiceExercise(id: 'es_u3_l2_e2', question: 'What is "La silla"?', options: ['The chair', 'The sofa', 'The bed', 'The lamp'], answer: 'The chair'),
      MultipleChoiceExercise(id: 'es_u3_l2_e3', question: 'How do you say "Bed"?', options: ['La cama', 'El baño', 'La mesa', 'El armario'], answer: 'La cama'),
    ]);
    data['es_u3_l3'] = Lesson(id: 'es_u3_l3', title: '¿Dónde está?', description: 'Location prepositions', exercises: [
      MultipleChoiceExercise(id: 'es_u3_l3_e1', question: 'What means "On top of"?', options: ['Encima de', 'Debajo de', 'Dentro de', 'Al lado de'], answer: 'Encima de'),
      TranslateExercise(id: 'es_u3_l3_e2', question: 'Translate: "Under the table"', answer: 'Debajo de la mesa'),
      MultipleChoiceExercise(id: 'es_u3_l3_e3', question: 'How do you say "Next to"?', options: ['Al lado de', 'Encima de', 'Detrás de', 'Delante de'], answer: 'Al lado de'),
    ]);
  }

  static void _addSpanishUnit4(Map<String, Lesson> data) {
    data['es_u4_l1'] = Lesson(id: 'es_u4_l1', title: 'El Mercado', description: 'At the market', exercises: [
      MultipleChoiceExercise(id: 'es_u4_l1_e1', question: 'How do you say "How much does this cost?"', options: ['¿Cuánto cuesta esto?', '¿Dónde está?', '¿Qué hora es?', '¿Cómo estás?'], answer: '¿Cuánto cuesta esto?'),
      TranslateExercise(id: 'es_u4_l1_e2', question: 'Translate: "I want to buy..."', answer: 'Quiero comprar...'),
      MultipleChoiceExercise(id: 'es_u4_l1_e3', question: '"El mercado" means?', options: ['The market', 'The supermarket', 'The mall', 'The bank'], answer: 'The market'),
    ]);
    data['es_u4_l2'] = Lesson(id: 'es_u4_l2', title: 'El Taxi', description: 'Getting around', exercises: [
      MultipleChoiceExercise(id: 'es_u4_l2_e1', question: 'How do you say "To the airport, please"?', options: ['Al aeropuerto, por favor', 'A la derecha', 'Recto', 'A la izquierda'], answer: 'Al aeropuerto, por favor'),
      TranslateExercise(id: 'es_u4_l2_e2', question: 'Translate: "How far is it?"', answer: '¿A qué distancia está?'),
      MultipleChoiceExercise(id: 'es_u4_l2_e3', question: '"Dobla a la derecha" means?', options: ['Turn right', 'Turn left', 'Go straight', 'Stop here'], answer: 'Turn right'),
    ]);
    data['es_u4_l3'] = Lesson(id: 'es_u4_l3', title: 'Las Direcciones', description: 'Asking for directions', exercises: [
      MultipleChoiceExercise(id: 'es_u4_l3_e1', question: 'How do you say "Go straight ahead"?', options: ['Sigue recto', 'Gira a la izquierda', 'Gira a la derecha', 'Da la vuelta'], answer: 'Sigue recto'),
      TranslateExercise(id: 'es_u4_l3_e2', question: 'Translate: "Where is the pharmacy?"', answer: '¿Dónde está la farmacia?'),
      MultipleChoiceExercise(id: 'es_u4_l3_e3', question: '"A la izquierda" means?', options: ['To the left', 'To the right', 'Behind', 'In front'], answer: 'To the left'),
    ]);
  }

  static void _addSpanishUnit5(Map<String, Lesson> data) {
    data['es_u5_l1'] = Lesson(id: 'es_u5_l1', title: 'El Fútbol', description: 'Sports & activities', exercises: [
      MultipleChoiceExercise(id: 'es_u5_l1_e1', question: 'How do you say "I play football"?', options: ['Juego al fútbol', 'Veo el fútbol', 'Corro', 'Nado'], answer: 'Juego al fútbol'),
      TranslateExercise(id: 'es_u5_l1_e2', question: 'Translate: "I like swimming"', answer: 'Me gusta nadar'),
      MultipleChoiceExercise(id: 'es_u5_l1_e3', question: '"Correr" means?', options: ['To run', 'To swim', 'To jump', 'To play'], answer: 'To run'),
    ]);
    data['es_u5_l2'] = Lesson(id: 'es_u5_l2', title: 'Música y Cine', description: 'Entertainment', exercises: [
      MultipleChoiceExercise(id: 'es_u5_l2_e1', question: 'How do you say "I watch a movie"?', options: ['Veo una película', 'Leo un libro', 'Escucho la radio', 'Juego'], answer: 'Veo una película'),
      TranslateExercise(id: 'es_u5_l2_e2', question: 'Translate: "I love music"', answer: 'Me encanta la música'),
      MultipleChoiceExercise(id: 'es_u5_l2_e3', question: '"Un concierto" means?', options: ['A concert', 'A contest', 'A film', 'A song'], answer: 'A concert'),
    ]);
    data['es_u5_l3'] = Lesson(id: 'es_u5_l3', title: 'La Playa', description: 'Beach & weekend', exercises: [
      MultipleChoiceExercise(id: 'es_u5_l3_e1', question: 'How do you say "I go to the beach"?', options: ['Voy a la playa', 'Me quedo en casa', 'Trabajo', 'Duermo'], answer: 'Voy a la playa'),
      TranslateExercise(id: 'es_u5_l3_e2', question: 'Translate: "On Sunday"', answer: 'El domingo'),
      MultipleChoiceExercise(id: 'es_u5_l3_e3', question: '"Descansar" means?', options: ['To rest', 'To work', 'To play', 'To travel'], answer: 'To rest'),
    ]);
  }

  static void _addSpanishUnit6(Map<String, Lesson> data) {
    data['es_u6_l1'] = Lesson(id: 'es_u6_l1', title: 'La Ropa', description: 'Clothing vocabulary', exercises: [
      MultipleChoiceExercise(id: 'es_u6_l1_e1', question: 'How do you say "Shirt"?', options: ['La camisa', 'El pantalón', 'El vestido', 'La chaqueta'], answer: 'La camisa'),
      TranslateExercise(id: 'es_u6_l1_e2', question: 'Translate: "Shoes"', answer: 'Los zapatos'),
      MultipleChoiceExercise(id: 'es_u6_l1_e3', question: '"Un vestido" means?', options: ['A dress', 'A T-shirt', 'A coat', 'A skirt'], answer: 'A dress'),
    ]);
    data['es_u6_l2'] = Lesson(id: 'es_u6_l2', title: 'Los Colores', description: 'Colors & descriptions', exercises: [
      MultipleChoiceExercise(id: 'es_u6_l2_e1', question: 'How do you say "Blue"?', options: ['Azul', 'Rojo', 'Verde', 'Amarillo'], answer: 'Azul'),
      TranslateExercise(id: 'es_u6_l2_e2', question: 'Translate: "The green bag"', answer: 'El bolso verde'),
      MultipleChoiceExercise(id: 'es_u6_l2_e3', question: '"Negro" means?', options: ['Black', 'White', 'Grey', 'Brown'], answer: 'Black'),
    ]);
    data['es_u6_l3'] = Lesson(id: 'es_u6_l3', title: 'De Compras', description: 'Shopping phrases', exercises: [
      MultipleChoiceExercise(id: 'es_u6_l3_e1', question: 'How do you say "How much does it cost?"', options: ['¿Cuánto cuesta?', '¿Dónde está la caja?', 'Lo quiero', '¿Tiene?'], answer: '¿Cuánto cuesta?'),
      TranslateExercise(id: 'es_u6_l3_e2', question: 'Translate: "Too expensive"', answer: 'Demasiado caro'),
      MultipleChoiceExercise(id: 'es_u6_l3_e3', question: '"La caja" means?', options: ['The checkout / till', 'The box', 'The bag', 'The price tag'], answer: 'The checkout / till'),
    ]);
  }

  static void _addSpanishUnit7(Map<String, Lesson> data) {
    data['es_u7_l1'] = Lesson(id: 'es_u7_l1', title: 'La Entrevista', description: 'Job interviews', exercises: [
      MultipleChoiceExercise(id: 'es_u7_l1_e1', question: 'How do you say "I am applying for the job"?', options: ['Solicito el puesto', 'Dimito', 'Trabajo aquí', 'Aprendo'], answer: 'Solicito el puesto'),
      TranslateExercise(id: 'es_u7_l1_e2', question: 'Translate: "My experience"', answer: 'Mi experiencia'),
      MultipleChoiceExercise(id: 'es_u7_l1_e3', question: '"Un currículum" means?', options: ['A résumé', 'A contract', 'A certificate', 'A business card'], answer: 'A résumé'),
    ]);
    data['es_u7_l2'] = Lesson(id: 'es_u7_l2', title: 'La Oficina', description: 'Office life', exercises: [
      MultipleChoiceExercise(id: 'es_u7_l2_e1', question: 'How do you say "The office"?', options: ['La oficina', 'La sala', 'La reunión', 'El pasillo'], answer: 'La oficina'),
      TranslateExercise(id: 'es_u7_l2_e2', question: 'Translate: "My colleague"', answer: 'Mi colega / compañero(a)'),
      MultipleChoiceExercise(id: 'es_u7_l2_e3', question: '"Teletrabajar" means?', options: ['To work from home', 'To telephone', 'To travel for work', 'To retire'], answer: 'To work from home'),
    ]);
    data['es_u7_l3'] = Lesson(id: 'es_u7_l3', title: 'La Reunión', description: 'Business meetings', exercises: [
      MultipleChoiceExercise(id: 'es_u7_l3_e1', question: 'How do you say "The meeting starts at 10"?', options: ['La reunión empieza a las 10', 'La reunión termina a las 10', 'Llego tarde', 'Disculpe'], answer: 'La reunión empieza a las 10'),
      TranslateExercise(id: 'es_u7_l3_e2', question: 'Translate: "I have an appointment"', answer: 'Tengo una cita'),
      MultipleChoiceExercise(id: 'es_u7_l3_e3', question: '"El orden del día" means?', options: ['The agenda', 'The working day', 'The deadline', 'The proposal'], answer: 'The agenda'),
    ]);
  }

  static void _addSpanishUnit8(Map<String, Lesson> data) {
    data['es_u8_l1'] = Lesson(id: 'es_u8_l1', title: 'El Periódico', description: 'Reading the news', exercises: [
      MultipleChoiceExercise(id: 'es_u8_l1_e1', question: 'How do you say "The news"?', options: ['Las noticias', 'Las novedades', 'La novela', 'La revista'], answer: 'Las noticias'),
      TranslateExercise(id: 'es_u8_l1_e2', question: 'Translate: "The headline"', answer: 'El titular'),
      MultipleChoiceExercise(id: 'es_u8_l1_e3', question: '"Un reportaje" means?', options: ['A news report', 'A novel', 'A school report', 'An interview'], answer: 'A news report'),
    ]);
    data['es_u8_l2'] = Lesson(id: 'es_u8_l2', title: 'El Mundo', description: 'World affairs', exercises: [
      MultipleChoiceExercise(id: 'es_u8_l2_e1', question: 'How do you say "The government"?', options: ['El gobierno', 'La policía', 'El tribunal', 'El alcalde'], answer: 'El gobierno'),
      TranslateExercise(id: 'es_u8_l2_e2', question: 'Translate: "The election"', answer: 'La elección / Las elecciones'),
      MultipleChoiceExercise(id: 'es_u8_l2_e3', question: '"Votar" means?', options: ['To vote', 'To see', 'To travel', 'To protest'], answer: 'To vote'),
    ]);
    data['es_u8_l3'] = Lesson(id: 'es_u8_l3', title: 'El Internet', description: 'Digital life', exercises: [
      MultipleChoiceExercise(id: 'es_u8_l3_e1', question: 'How do you say "Social media"?', options: ['Las redes sociales', 'Los medios', 'La web', 'Los datos'], answer: 'Las redes sociales'),
      TranslateExercise(id: 'es_u8_l3_e2', question: 'Translate: "I send an email"', answer: 'Envío un correo electrónico'),
      MultipleChoiceExercise(id: 'es_u8_l3_e3', question: '"Descargar" means?', options: ['To download', 'To upload', 'To send', 'To delete'], answer: 'To download'),
    ]);
  }

  static void _addSpanishUnit9(Map<String, Lesson> data) {
    data['es_u9_l1'] = Lesson(id: 'es_u9_l1', title: 'La Naturaleza', description: 'The natural world', exercises: [
      MultipleChoiceExercise(id: 'es_u9_l1_e1', question: 'How do you say "The forest"?', options: ['El bosque', 'El mar', 'La montaña', 'El río'], answer: 'El bosque'),
      TranslateExercise(id: 'es_u9_l1_e2', question: 'Translate: "The river"', answer: 'El río'),
      MultipleChoiceExercise(id: 'es_u9_l1_e3', question: '"La fauna" means?', options: ['Wildlife / Fauna', 'Flora', 'The sky', 'The soil'], answer: 'Wildlife / Fauna'),
    ]);
    data['es_u9_l2'] = Lesson(id: 'es_u9_l2', title: 'La Contaminación', description: 'Environmental issues', exercises: [
      MultipleChoiceExercise(id: 'es_u9_l2_e1', question: 'How do you say "Pollution"?', options: ['La contaminación', 'El reciclaje', 'La naturaleza', 'La energía'], answer: 'La contaminación'),
      TranslateExercise(id: 'es_u9_l2_e2', question: 'Translate: "Climate change"', answer: 'El cambio climático'),
      MultipleChoiceExercise(id: 'es_u9_l2_e3', question: '"Las energías renovables" means?', options: ['Renewable energy', 'Nuclear energy', 'Fossil fuels', 'Solar panels'], answer: 'Renewable energy'),
    ]);
    data['es_u9_l3'] = Lesson(id: 'es_u9_l3', title: 'Reciclar', description: 'Sustainability debate', exercises: [
      MultipleChoiceExercise(id: 'es_u9_l3_e1', question: 'How do you say "We must protect the environment"?', options: ['Debemos proteger el medio ambiente', 'Reciclo', 'El planeta es hermoso', 'El futuro es oscuro'], answer: 'Debemos proteger el medio ambiente'),
      TranslateExercise(id: 'es_u9_l3_e2', question: 'Translate: "In my opinion"', answer: 'En mi opinión'),
      MultipleChoiceExercise(id: 'es_u9_l3_e3', question: '"Sostenible" means?', options: ['Sustainable', 'Strong', 'Hard', 'Long'], answer: 'Sustainable'),
    ]);
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

// ─────────────────────────────────────────────────────────
//  INTRO LESSON DATA — hardcoded for offline speed
// ─────────────────────────────────────────────────────────
class IntroLessonData {
  static final Map<String, IntroLesson> _data = {
    // ── GERMAN ────────────────────────────────────────────
    'de_u1': IntroLesson(id: 'de_u1_intro', title: 'Preview: The Café', vocabItems: [
      VocabItem(word: 'Ich möchte', meaning: 'I would like', example: 'Ich möchte einen Kaffee.', exampleTranslation: 'I would like a coffee.'),
      VocabItem(word: 'Die Speisekarte', meaning: 'The menu', example: 'Die Speisekarte, bitte.', exampleTranslation: 'The menu, please.'),
      VocabItem(word: 'Die Rechnung', meaning: 'The bill', example: 'Die Rechnung, bitte.', exampleTranslation: 'The bill, please.'),
      VocabItem(word: 'Zucker', meaning: 'Sugar', example: 'Mit Zucker, bitte.', exampleTranslation: 'With sugar, please.'),
      VocabItem(word: 'Milch', meaning: 'Milk', example: 'Mit Milch, bitte.', exampleTranslation: 'With milk, please.'),
      VocabItem(word: 'Bitte', meaning: 'Please', example: 'Einen Tee, bitte.', exampleTranslation: 'A tea, please.'),
      VocabItem(word: 'Danke', meaning: 'Thank you', example: 'Danke schön!', exampleTranslation: 'Thank you very much!'),
    ]),
    'de_u2': IntroLesson(id: 'de_u2_intro', title: 'Preview: Family & Friends', vocabItems: [
      VocabItem(word: 'Die Mutter', meaning: 'The mother', example: 'Meine Mutter ist nett.', exampleTranslation: 'My mother is kind.'),
      VocabItem(word: 'Der Vater', meaning: 'The father', example: 'Mein Vater ist groß.', exampleTranslation: 'My father is tall.'),
      VocabItem(word: 'Der Bruder', meaning: 'The brother', example: 'Ich habe einen Bruder.', exampleTranslation: 'I have a brother.'),
      VocabItem(word: 'Die Schwester', meaning: 'The sister', example: 'Meine Schwester heißt Anna.', exampleTranslation: 'My sister is called Anna.'),
      VocabItem(word: 'Die Eltern', meaning: 'The parents', example: 'Meine Eltern wohnen in Berlin.', exampleTranslation: 'My parents live in Berlin.'),
      VocabItem(word: 'Groß', meaning: 'Tall / Big', example: 'Mein Bruder ist groß.', exampleTranslation: 'My brother is tall.'),
      VocabItem(word: 'Klein', meaning: 'Small / Short', example: 'Die Katze ist klein.', exampleTranslation: 'The cat is small.'),
    ]),
    'de_u3': IntroLesson(id: 'de_u3_intro', title: 'Preview: My Home', vocabItems: [
      VocabItem(word: 'Die Küche', meaning: 'The kitchen', example: 'Ich koche in der Küche.', exampleTranslation: 'I cook in the kitchen.'),
      VocabItem(word: 'Das Schlafzimmer', meaning: 'The bedroom', example: 'Das Schlafzimmer ist groß.', exampleTranslation: 'The bedroom is big.'),
      VocabItem(word: 'Das Wohnzimmer', meaning: 'The living room', example: 'Wir sitzen im Wohnzimmer.', exampleTranslation: 'We sit in the living room.'),
      VocabItem(word: 'Der Tisch', meaning: 'The table', example: 'Der Tisch ist neu.', exampleTranslation: 'The table is new.'),
      VocabItem(word: 'Der Stuhl', meaning: 'The chair', example: 'Der Stuhl ist bequem.', exampleTranslation: 'The chair is comfortable.'),
      VocabItem(word: 'Auf', meaning: 'On / On top of', example: 'Das Buch liegt auf dem Tisch.', exampleTranslation: 'The book is on the table.'),
      VocabItem(word: 'Unter', meaning: 'Under / Below', example: 'Die Katze sitzt unter dem Stuhl.', exampleTranslation: 'The cat sits under the chair.'),
    ]),
    'de_u4': IntroLesson(id: 'de_u4_intro', title: 'Preview: Travel & City', vocabItems: [
      VocabItem(word: 'Der Zug', meaning: 'The train', example: 'Der Zug fährt um 9 Uhr ab.', exampleTranslation: 'The train departs at 9 o\'clock.'),
      VocabItem(word: 'Das Ticket', meaning: 'The ticket', example: 'Ich kaufe ein Ticket.', exampleTranslation: 'I buy a ticket.'),
      VocabItem(word: 'Das Hotel', meaning: 'The hotel', example: 'Das Hotel ist sehr schön.', exampleTranslation: 'The hotel is very beautiful.'),
      VocabItem(word: 'Links', meaning: 'Left', example: 'Gehen Sie links.', exampleTranslation: 'Go left.'),
      VocabItem(word: 'Rechts', meaning: 'Right', example: 'Das Hotel ist rechts.', exampleTranslation: 'The hotel is on the right.'),
      VocabItem(word: 'Geradeaus', meaning: 'Straight ahead', example: 'Gehen Sie geradeaus.', exampleTranslation: 'Go straight ahead.'),
    ]),
    'de_u5': IntroLesson(id: 'de_u5_intro', title: 'Preview: Hobbies & Sports', vocabItems: [
      VocabItem(word: 'Fußball', meaning: 'Football / Soccer', example: 'Ich spiele Fußball.', exampleTranslation: 'I play football.'),
      VocabItem(word: 'Die Musik', meaning: 'The music', example: 'Ich höre gern Musik.', exampleTranslation: 'I like listening to music.'),
      VocabItem(word: 'Der Film', meaning: 'The film / movie', example: 'Wir schauen einen Film.', exampleTranslation: 'We are watching a film.'),
      VocabItem(word: 'Das Wochenende', meaning: 'The weekend', example: 'Am Wochenende schlafe ich lang.', exampleTranslation: 'On the weekend I sleep in.'),
      VocabItem(word: 'Gern', meaning: 'Gladly / Like to', example: 'Ich tanze gern.', exampleTranslation: 'I like to dance.'),
      VocabItem(word: 'Spielen', meaning: 'To play', example: 'Wir spielen Tennis.', exampleTranslation: 'We play tennis.'),
    ]),
    'de_u6': IntroLesson(id: 'de_u6_intro', title: 'Preview: Shopping', vocabItems: [
      VocabItem(word: 'Das Hemd', meaning: 'The shirt', example: 'Das Hemd ist blau.', exampleTranslation: 'The shirt is blue.'),
      VocabItem(word: 'Die Hose', meaning: 'The trousers', example: 'Die Hose ist zu groß.', exampleTranslation: 'The trousers are too big.'),
      VocabItem(word: 'Rot', meaning: 'Red', example: 'Das Auto ist rot.', exampleTranslation: 'The car is red.'),
      VocabItem(word: 'Blau', meaning: 'Blue', example: 'Der Himmel ist blau.', exampleTranslation: 'The sky is blue.'),
      VocabItem(word: 'Wie viel kostet das?', meaning: 'How much does it cost?', example: 'Wie viel kostet das Hemd?', exampleTranslation: 'How much does the shirt cost?'),
      VocabItem(word: 'Zu teuer', meaning: 'Too expensive', example: 'Das ist zu teuer.', exampleTranslation: 'That is too expensive.'),
    ]),
    'de_u7': IntroLesson(id: 'de_u7_intro', title: 'Preview: Business', vocabItems: [
      VocabItem(word: 'Die Besprechung', meaning: 'The meeting', example: 'Die Besprechung beginnt um 10.', exampleTranslation: 'The meeting starts at 10.'),
      VocabItem(word: 'Das Büro', meaning: 'The office', example: 'Ich arbeite im Büro.', exampleTranslation: 'I work in the office.'),
      VocabItem(word: 'Der Kollege', meaning: 'The colleague', example: 'Mein Kollege heißt Klaus.', exampleTranslation: 'My colleague is called Klaus.'),
      VocabItem(word: 'Die E-Mail', meaning: 'The email', example: 'Ich schreibe eine E-Mail.', exampleTranslation: 'I write an email.'),
      VocabItem(word: 'Der Termin', meaning: 'The appointment', example: 'Ich habe einen Termin.', exampleTranslation: 'I have an appointment.'),
    ]),
    'de_u8': IntroLesson(id: 'de_u8_intro', title: 'Preview: Media & News', vocabItems: [
      VocabItem(word: 'Die Nachrichten', meaning: 'The news', example: 'Ich schaue die Nachrichten.', exampleTranslation: 'I watch the news.'),
      VocabItem(word: 'Die Zeitung', meaning: 'The newspaper', example: 'Ich lese die Zeitung.', exampleTranslation: 'I read the newspaper.'),
      VocabItem(word: 'Der Computer', meaning: 'The computer', example: 'Ich arbeite am Computer.', exampleTranslation: 'I work at the computer.'),
      VocabItem(word: 'Soziale Medien', meaning: 'Social media', example: 'Ich nutze soziale Medien.', exampleTranslation: 'I use social media.'),
      VocabItem(word: 'Die Schlagzeile', meaning: 'The headline', example: 'Die Schlagzeile ist interessant.', exampleTranslation: 'The headline is interesting.'),
    ]),
    'de_u9': IntroLesson(id: 'de_u9_intro', title: 'Preview: Environment', vocabItems: [
      VocabItem(word: 'Der Wald', meaning: 'The forest', example: 'Der Wald ist grün.', exampleTranslation: 'The forest is green.'),
      VocabItem(word: 'Das Tier', meaning: 'The animal', example: 'Das Tier lebt im Wald.', exampleTranslation: 'The animal lives in the forest.'),
      VocabItem(word: 'Die Umwelt', meaning: 'The environment', example: 'Wir müssen die Umwelt schützen.', exampleTranslation: 'We must protect the environment.'),
      VocabItem(word: 'Recyceln', meaning: 'To recycle', example: 'Ich recycele meinen Müll.', exampleTranslation: 'I recycle my rubbish.'),
      VocabItem(word: 'Die Zukunft', meaning: 'The future', example: 'Die Zukunft ist wichtig.', exampleTranslation: 'The future is important.'),
    ]),

    // ── FRENCH ────────────────────────────────────────────
    'fr_u1': IntroLesson(id: 'fr_u1_intro', title: 'Preview: Le Café', vocabItems: [
      VocabItem(word: 'Je voudrais', meaning: 'I would like', example: 'Je voudrais un café.', exampleTranslation: 'I would like a coffee.'),
      VocabItem(word: "S'il vous plaît", meaning: 'Please (formal)', example: "Un thé, s'il vous plaît.", exampleTranslation: 'A tea, please.'),
      VocabItem(word: "L'addition", meaning: 'The bill', example: "L'addition, s'il vous plaît.", exampleTranslation: 'The bill, please.'),
      VocabItem(word: 'Du sucre', meaning: 'Some sugar', example: 'Avec du sucre, s\'il vous plaît.', exampleTranslation: 'With some sugar, please.'),
      VocabItem(word: 'Du lait', meaning: 'Some milk', example: 'Avec du lait.', exampleTranslation: 'With some milk.'),
      VocabItem(word: 'Merci', meaning: 'Thank you', example: 'Merci beaucoup!', exampleTranslation: 'Thank you very much!'),
    ]),
    'fr_u2': IntroLesson(id: 'fr_u2_intro', title: 'Preview: Famille', vocabItems: [
      VocabItem(word: 'La mère', meaning: 'The mother', example: 'Ma mère est médecin.', exampleTranslation: 'My mother is a doctor.'),
      VocabItem(word: 'Le père', meaning: 'The father', example: 'Mon père est grand.', exampleTranslation: 'My father is tall.'),
      VocabItem(word: 'Le frère', meaning: 'The brother', example: "J'ai un frère.", exampleTranslation: 'I have a brother.'),
      VocabItem(word: 'La sœur', meaning: 'The sister', example: 'Ma sœur s\'appelle Marie.', exampleTranslation: 'My sister is called Marie.'),
      VocabItem(word: 'Les parents', meaning: 'The parents', example: 'Mes parents vivent à Paris.', exampleTranslation: 'My parents live in Paris.'),
    ]),
    'fr_u3': IntroLesson(id: 'fr_u3_intro', title: 'Preview: Ma Maison', vocabItems: [
      VocabItem(word: 'La cuisine', meaning: 'The kitchen', example: 'Je cuisine dans la cuisine.', exampleTranslation: 'I cook in the kitchen.'),
      VocabItem(word: 'La chambre', meaning: 'The bedroom', example: 'La chambre est grande.', exampleTranslation: 'The bedroom is big.'),
      VocabItem(word: 'Le salon', meaning: 'The living room', example: 'Nous regardons la télé au salon.', exampleTranslation: 'We watch TV in the living room.'),
      VocabItem(word: 'La table', meaning: 'The table', example: 'La table est en bois.', exampleTranslation: 'The table is made of wood.'),
      VocabItem(word: 'Sur', meaning: 'On top of', example: 'Le livre est sur la table.', exampleTranslation: 'The book is on the table.'),
    ]),
    'fr_u4': IntroLesson(id: 'fr_u4_intro', title: 'Preview: Voyage à Paris', vocabItems: [
      VocabItem(word: 'Le métro', meaning: 'The metro', example: 'Je prends le métro.', exampleTranslation: 'I take the metro.'),
      VocabItem(word: 'Le billet', meaning: 'The ticket', example: "J'achète un billet.", exampleTranslation: 'I buy a ticket.'),
      VocabItem(word: 'À gauche', meaning: 'To the left', example: 'Tournez à gauche.', exampleTranslation: 'Turn left.'),
      VocabItem(word: 'À droite', meaning: 'To the right', example: "L'hôtel est à droite.", exampleTranslation: 'The hotel is on the right.'),
      VocabItem(word: 'Tout droit', meaning: 'Straight ahead', example: 'Allez tout droit.', exampleTranslation: 'Go straight ahead.'),
    ]),
    'fr_u5': IntroLesson(id: 'fr_u5_intro', title: 'Preview: Loisirs', vocabItems: [
      VocabItem(word: 'Le football', meaning: 'Football', example: 'Je joue au football.', exampleTranslation: 'I play football.'),
      VocabItem(word: 'La musique', meaning: 'The music', example: "J'écoute de la musique.", exampleTranslation: 'I listen to music.'),
      VocabItem(word: 'Le cinéma', meaning: 'The cinema', example: 'On va au cinéma.', exampleTranslation: "We're going to the cinema."),
      VocabItem(word: 'Aimer', meaning: 'To like / love', example: "J'aime danser.", exampleTranslation: 'I like to dance.'),
      VocabItem(word: 'Jouer', meaning: 'To play', example: 'Nous jouons au tennis.', exampleTranslation: 'We play tennis.'),
    ]),
    'fr_u6': IntroLesson(id: 'fr_u6_intro', title: 'Preview: Shopping', vocabItems: [
      VocabItem(word: 'La chemise', meaning: 'The shirt', example: 'La chemise est bleue.', exampleTranslation: 'The shirt is blue.'),
      VocabItem(word: 'Le pantalon', meaning: 'The trousers', example: 'Le pantalon est trop grand.', exampleTranslation: 'The trousers are too big.'),
      VocabItem(word: 'Rouge', meaning: 'Red', example: 'La robe est rouge.', exampleTranslation: 'The dress is red.'),
      VocabItem(word: 'Ça coûte combien?', meaning: 'How much does it cost?', example: 'Ça coûte combien, la chemise?', exampleTranslation: 'How much does the shirt cost?'),
      VocabItem(word: 'Trop cher', meaning: 'Too expensive', example: "C'est trop cher.", exampleTranslation: "That's too expensive."),
    ]),
    'fr_u7': IntroLesson(id: 'fr_u7_intro', title: 'Preview: Vie Pro', vocabItems: [
      VocabItem(word: 'La réunion', meaning: 'The meeting', example: 'La réunion commence à 10h.', exampleTranslation: 'The meeting starts at 10.'),
      VocabItem(word: 'Le bureau', meaning: 'The office', example: 'Je travaille au bureau.', exampleTranslation: 'I work at the office.'),
      VocabItem(word: 'Un rendez-vous', meaning: 'An appointment', example: "J'ai un rendez-vous.", exampleTranslation: 'I have an appointment.'),
      VocabItem(word: 'Excusez-moi', meaning: 'Excuse me', example: 'Excusez-moi pour le retard.', exampleTranslation: 'Excuse me for the delay.'),
    ]),
    'fr_u8': IntroLesson(id: 'fr_u8_intro', title: 'Preview: Actualités', vocabItems: [
      VocabItem(word: 'Les informations', meaning: 'The news', example: 'Je regarde les informations.', exampleTranslation: 'I watch the news.'),
      VocabItem(word: 'Le journal', meaning: 'The newspaper', example: 'Je lis le journal.', exampleTranslation: 'I read the newspaper.'),
      VocabItem(word: 'Les réseaux sociaux', meaning: 'Social media', example: "J'utilise les réseaux sociaux.", exampleTranslation: 'I use social media.'),
      VocabItem(word: 'Actuel(le)', meaning: 'Current', example: "C'est très actuel.", exampleTranslation: "That's very current."),
    ]),
    'fr_u9': IntroLesson(id: 'fr_u9_intro', title: 'Preview: Environnement', vocabItems: [
      VocabItem(word: 'La forêt', meaning: 'The forest', example: 'La forêt est verte.', exampleTranslation: 'The forest is green.'),
      VocabItem(word: "L'environnement", meaning: 'The environment', example: "Il faut protéger l'environnement.", exampleTranslation: 'We must protect the environment.'),
      VocabItem(word: 'Recycler', meaning: 'To recycle', example: 'Je recycle mes déchets.', exampleTranslation: 'I recycle my rubbish.'),
      VocabItem(word: "À mon avis", meaning: 'In my opinion', example: "À mon avis, c'est faux.", exampleTranslation: 'In my opinion, that is wrong.'),
    ]),

    // ── SPANISH ───────────────────────────────────────────
    'es_u1': IntroLesson(id: 'es_u1_intro', title: 'Preview: El Restaurante', vocabItems: [
      VocabItem(word: 'Yo quiero', meaning: 'I want', example: 'Yo quiero unas tapas.', exampleTranslation: 'I want some tapas.'),
      VocabItem(word: 'Por favor', meaning: 'Please', example: 'El menú, por favor.', exampleTranslation: 'The menu, please.'),
      VocabItem(word: 'La cuenta', meaning: 'The bill', example: 'La cuenta, por favor.', exampleTranslation: 'The bill, please.'),
      VocabItem(word: 'Gracias', meaning: 'Thank you', example: '¡Muchas gracias!', exampleTranslation: 'Thank you very much!'),
      VocabItem(word: '¿Cuánto cuesta?', meaning: 'How much does it cost?', example: '¿Cuánto cuesta un café?', exampleTranslation: 'How much does a coffee cost?'),
    ]),
    'es_u2': IntroLesson(id: 'es_u2_intro', title: 'Preview: Familia', vocabItems: [
      VocabItem(word: 'La madre', meaning: 'The mother', example: 'Mi madre es médica.', exampleTranslation: 'My mother is a doctor.'),
      VocabItem(word: 'El padre', meaning: 'The father', example: 'Mi padre es alto.', exampleTranslation: 'My father is tall.'),
      VocabItem(word: 'El hermano', meaning: 'The brother', example: 'Tengo un hermano.', exampleTranslation: 'I have a brother.'),
      VocabItem(word: 'La hermana', meaning: 'The sister', example: 'Mi hermana se llama Ana.', exampleTranslation: 'My sister is called Ana.'),
      VocabItem(word: 'Los padres', meaning: 'The parents', example: 'Mis padres viven en Madrid.', exampleTranslation: 'My parents live in Madrid.'),
    ]),
    'es_u3': IntroLesson(id: 'es_u3_intro', title: 'Preview: Mi Casa', vocabItems: [
      VocabItem(word: 'La cocina', meaning: 'The kitchen', example: 'Cocino en la cocina.', exampleTranslation: 'I cook in the kitchen.'),
      VocabItem(word: 'El dormitorio', meaning: 'The bedroom', example: 'El dormitorio es grande.', exampleTranslation: 'The bedroom is big.'),
      VocabItem(word: 'La mesa', meaning: 'The table', example: 'La mesa es de madera.', exampleTranslation: 'The table is made of wood.'),
      VocabItem(word: 'Encima de', meaning: 'On top of', example: 'El libro está encima de la mesa.', exampleTranslation: 'The book is on the table.'),
      VocabItem(word: 'Debajo de', meaning: 'Under / Below', example: 'El gato está debajo de la silla.', exampleTranslation: 'The cat is under the chair.'),
    ]),
    'es_u4': IntroLesson(id: 'es_u4_intro', title: 'Preview: La Ciudad', vocabItems: [
      VocabItem(word: 'El taxi', meaning: 'The taxi', example: 'Tomo un taxi.', exampleTranslation: 'I take a taxi.'),
      VocabItem(word: 'El mercado', meaning: 'The market', example: 'Voy al mercado.', exampleTranslation: 'I go to the market.'),
      VocabItem(word: 'A la izquierda', meaning: 'To the left', example: 'Gira a la izquierda.', exampleTranslation: 'Turn left.'),
      VocabItem(word: 'A la derecha', meaning: 'To the right', example: 'El hotel está a la derecha.', exampleTranslation: 'The hotel is on the right.'),
      VocabItem(word: '¿Dónde está?', meaning: 'Where is it?', example: '¿Dónde está la farmacia?', exampleTranslation: 'Where is the pharmacy?'),
    ]),
    'es_u5': IntroLesson(id: 'es_u5_intro', title: 'Preview: Hobbies', vocabItems: [
      VocabItem(word: 'El fútbol', meaning: 'Football / Soccer', example: 'Juego al fútbol.', exampleTranslation: 'I play football.'),
      VocabItem(word: 'La música', meaning: 'The music', example: 'Escucho música.', exampleTranslation: 'I listen to music.'),
      VocabItem(word: 'La playa', meaning: 'The beach', example: 'Voy a la playa.', exampleTranslation: 'I go to the beach.'),
      VocabItem(word: 'Me gusta', meaning: 'I like', example: 'Me gusta bailar.', exampleTranslation: 'I like to dance.'),
    ]),
    'es_u6': IntroLesson(id: 'es_u6_intro', title: 'Preview: Compras', vocabItems: [
      VocabItem(word: 'La camisa', meaning: 'The shirt', example: 'La camisa es azul.', exampleTranslation: 'The shirt is blue.'),
      VocabItem(word: 'Rojo/Roja', meaning: 'Red', example: 'El coche es rojo.', exampleTranslation: 'The car is red.'),
      VocabItem(word: '¿Cuánto cuesta esto?', meaning: 'How much does this cost?', example: '¿Cuánto cuesta esta camisa?', exampleTranslation: 'How much does this shirt cost?'),
      VocabItem(word: 'Demasiado caro', meaning: 'Too expensive', example: 'Eso es demasiado caro.', exampleTranslation: 'That is too expensive.'),
    ]),
    'es_u7': IntroLesson(id: 'es_u7_intro', title: 'Preview: Negocios', vocabItems: [
      VocabItem(word: 'La reunión', meaning: 'The meeting', example: 'La reunión empieza a las 10.', exampleTranslation: 'The meeting starts at 10.'),
      VocabItem(word: 'La oficina', meaning: 'The office', example: 'Trabajo en la oficina.', exampleTranslation: 'I work in the office.'),
      VocabItem(word: 'Un correo electrónico', meaning: 'An email', example: 'Escribo un correo.', exampleTranslation: "I'm writing an email."),
      VocabItem(word: 'Disculpe', meaning: 'Excuse me', example: 'Disculpe por el retraso.', exampleTranslation: 'Excuse me for the delay.'),
    ]),
    'es_u8': IntroLesson(id: 'es_u8_intro', title: 'Preview: Noticias', vocabItems: [
      VocabItem(word: 'Las noticias', meaning: 'The news', example: 'Veo las noticias.', exampleTranslation: 'I watch the news.'),
      VocabItem(word: 'El periódico', meaning: 'The newspaper', example: 'Leo el periódico.', exampleTranslation: 'I read the newspaper.'),
      VocabItem(word: 'Las redes sociales', meaning: 'Social media', example: 'Uso las redes sociales.', exampleTranslation: 'I use social media.'),
      VocabItem(word: 'El titular', meaning: 'The headline', example: 'El titular es interesante.', exampleTranslation: 'The headline is interesting.'),
    ]),
    'es_u9': IntroLesson(id: 'es_u9_intro', title: 'Preview: Medio Ambiente', vocabItems: [
      VocabItem(word: 'El bosque', meaning: 'The forest', example: 'El bosque es verde.', exampleTranslation: 'The forest is green.'),
      VocabItem(word: 'El medio ambiente', meaning: 'The environment', example: 'Debemos proteger el medio ambiente.', exampleTranslation: 'We must protect the environment.'),
      VocabItem(word: 'Reciclar', meaning: 'To recycle', example: 'Reciclo mi basura.', exampleTranslation: 'I recycle my rubbish.'),
      VocabItem(word: 'En mi opinión', meaning: 'In my opinion', example: 'En mi opinión, eso es incorrecto.', exampleTranslation: 'In my opinion, that is wrong.'),
    ]),
  };

  /// Returns the [IntroLesson] for the given unit ID (e.g. 'de_u1'), or null.
  static IntroLesson? getIntroLesson(String unitId) => _data[unitId];
}
