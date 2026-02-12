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

// Hardcoded data source for now - COMPLETE UNIT 1 FOR ALL 3 LANGUAGES
class LessonData {
  static final Map<String, Lesson> lessons = {
    // ==================== FRENCH UNIT 1 (4 Lessons) ====================
    'fr_beginner_1_1': Lesson(
      id: 'fr_beginner_1_1',
      title: 'Bonjour!',
      description: 'Learn basic French greetings',
      exercises: [
        MultipleChoiceExercise(
          id: 'fr_b1_e1',
          question: 'How do you say "Hello" in French?',
          options: ['Bonjour', 'Merci', 'Au revoir', 'Bonsoir'],
          answer: 'Bonjour',
        ),
        MultipleChoiceExercise(
          id: 'fr_b1_e2',
          question: 'How do you say "Goodbye" in French?',
          options: ['Bonjour', 'Merci', 'Au revoir', 'Salut'],
          answer: 'Au revoir',
        ),
        TranslateExercise(
          id: 'fr_b1_e3',
          question: 'Translate to French: "Good morning"',
          answer: 'Bonjour',
        ),
        MultipleChoiceExercise(
          id: 'fr_b1_e4',
          question: 'How do you say "Thank you" in French?',
          options: ['Bonjour', 'Merci', 'S\'il vous plaît', 'Pardon'],
          answer: 'Merci',
        ),
        TranslateExercise(
          id: 'fr_b1_e5',
          question: 'Translate to French: "My name is..."',
          answer: 'Je m\'appelle',
        ),
        MultipleChoiceExercise(
          id: 'fr_b1_e6',
          question: 'How do you say "Please" in French?',
          options: ['Merci', 'S\'il vous plaît', 'Bonjour', 'Pardon'],
          answer: 'S\'il vous plaît',
        ),
        TranslateExercise(
          id: 'fr_b1_e7',
          question: 'Translate to French: "How are you?"',
          answer: 'Comment allez-vous',
        ),
        MultipleChoiceExercise(
          id: 'fr_b1_e8',
          question: 'How do you say "Excuse me" in French?',
          options: ['Excusez-moi', 'Merci', 'Bonjour', 'S\'il vous plaît'],
          answer: 'Excusez-moi',
        ),
      ],
    ),

    'fr_beginner_1_2': Lesson(
      id: 'fr_beginner_1_2',
      title: 'Je m\'appelle...',
      description: 'Introduce yourself in French',
      exercises: [
        TranslateExercise(
          id: 'fr_b2_e1',
          question: 'Translate to French: "I am"',
          answer: 'Je suis',
        ),
        MultipleChoiceExercise(
          id: 'fr_b2_e2',
          question: 'How do you say "Nice to meet you" in French?',
          options: ['Enchanté', 'Merci', 'Au revoir', 'Bonjour'],
          answer: 'Enchanté',
        ),
        TranslateExercise(
          id: 'fr_b2_e3',
          question: 'Translate to French: "I am a student"',
          answer: 'Je suis étudiant',
        ),
        MultipleChoiceExercise(
          id: 'fr_b2_e4',
          question: 'What does "Comment tu t\'appelles?" mean?',
          options: ['What is your name?', 'How are you?', 'Where are you from?', 'Goodbye'],
          answer: 'What is your name?',
        ),
        TranslateExercise(
          id: 'fr_b2_e5',
          question: 'Translate to French: "I am from Paris"',
          answer: 'Je suis de Paris',
        ),
        MultipleChoiceExercise(
          id: 'fr_b2_e6',
          question: 'How do you ask "And you?" in French?',
          options: ['Et toi?', 'Merci', 'Oui', 'Non'],
          answer: 'Et toi?',
        ),
      ],
    ),

    'fr_beginner_1_3': Lesson(
      id: 'fr_beginner_1_3',
      title: 'Phrases Courantes',
      description: 'Essential everyday French phrases',
      exercises: [
        MultipleChoiceExercise(
          id: 'fr_b3_e1',
          question: 'How do you say "Yes" in French?',
          options: ['Oui', 'Non', 'Peut-être', 'Merci'],
          answer: 'Oui',
        ),
        MultipleChoiceExercise(
          id: 'fr_b3_e2',
          question: 'How do you say "No" in French?',
          options: ['Oui', 'Non', 'Si', 'Jamais'],
          answer: 'Non',
        ),
        TranslateExercise(
          id: 'fr_b3_e3',
          question: 'Translate to French: "I don\'t understand"',
          answer: 'Je ne comprends pas',
        ),
        MultipleChoiceExercise(
          id: 'fr_b3_e4',
          question: 'What does "Parlez-vous anglais?" mean?',
          options: ['Do you speak English?', 'Do you understand?', 'Where are you?', 'What time is it?'],
          answer: 'Do you speak English?',
        ),
        TranslateExercise(
          id: 'fr_b3_e5',
          question: 'Translate to French: "See you soon"',
          answer: 'À bientôt',
        ),
        MultipleChoiceExercise(
          id: 'fr_b3_e6',
          question: 'How do you say "Of course" in French?',
          options: ['Bien sûr', 'Jamais', 'Peut-être', 'Toujours'],
          answer: 'Bien sûr',
        ),
      ],
    ),

    'fr_beginner_1_4': Lesson(
      id: 'fr_beginner_1_4',
      title: 'Questions Simples',
      description: 'Ask basic questions in French',
      exercises: [
        TranslateExercise(
          id: 'fr_b4_e1',
          question: 'Translate to French: "Where is...?"',
          answer: 'Où est',
        ),
        MultipleChoiceExercise(
          id: 'fr_b4_e2',
          question: 'How do you say "What?" in French?',
          options: ['Quoi?', 'Qui?', 'Où?', 'Quand?'],
          answer: 'Quoi?',
        ),
        TranslateExercise(
          id: 'fr_b4_e3',
          question: 'Translate to French: "Why?"',
          answer: 'Pourquoi',
        ),
        MultipleChoiceExercise(
          id: 'fr_b4_e4',
          question: 'What does "Combien?" mean?',
          options: ['How much/many?', 'Why?', 'When?', 'Where?'],
          answer: 'How much/many?',
        ),
        TranslateExercise(
          id: 'fr_b4_e5',
          question: 'Translate to French: "When?"',
          answer: 'Quand',
        ),
        MultipleChoiceExercise(
          id: 'fr_b4_e6',
          question: 'How do you ask "Can you help me?" in French?',
          options: ['Pouvez-vous m\'aider?', 'Où est?', 'Comment?', 'Pourquoi?'],
          answer: 'Pouvez-vous m\'aider?',
        ),
      ],
    ),

    // ==================== GERMAN UNIT 1 (4 Lessons) ====================
    'de_beginner_1_1': Lesson(
      id: 'de_beginner_1_1',
      title: 'Hallo!',
      description: 'Learn basic German greetings',
      exercises: [
        MultipleChoiceExercise(
          id: 'de_b1_e1',
          question: 'How do you say "Hello" in German?',
          options: ['Hallo', 'Danke', 'Tschüss', 'Bitte'],
          answer: 'Hallo',
        ),
        MultipleChoiceExercise(
          id: 'de_b1_e2',
          question: 'How do you say "Goodbye" in German?',
          options: ['Hallo', 'Danke', 'Tschüss', 'Bitte'],
          answer: 'Tschüss',
        ),
        TranslateExercise(
          id: 'de_b1_e3',
          question: 'Translate to German: "Good morning"',
          answer: 'Guten Morgen',
        ),
        MultipleChoiceExercise(
          id: 'de_b1_e4',
          question: 'How do you say "Thank you" in German?',
          options: ['Hallo', 'Danke', 'Bitte', 'Tschüss'],
          answer: 'Danke',
        ),
        TranslateExercise(
          id: 'de_b1_e5',
          question: 'Translate to German: "My name is..."',
          answer: 'Mein Name ist',
        ),
        MultipleChoiceExercise(
          id: 'de_b1_e6',
          question: 'How do you say "Please" in German?',
          options: ['Danke', 'Bitte', 'Hallo', 'Entschuldigung'],
          answer: 'Bitte',
        ),
        TranslateExercise(
          id: 'de_b1_e7',
          question: 'Translate to German: "How are you?"',
          answer: 'Wie geht es dir',
        ),
        MultipleChoiceExercise(
          id: 'de_b1_e8',
          question: 'How do you say "Excuse me" in German?',
          options: ['Entschuldigung', 'Danke', 'Hallo', 'Bitte'],
          answer: 'Entschuldigung',
        ),
      ],
    ),

    'de_beginner_1_2': Lesson(
      id: 'de_beginner_1_2',
      title: 'Ich bin...',
      description: 'Introduce yourself in German',
      exercises: [
        TranslateExercise(
          id: 'de_b2_e1',
          question: 'Translate to German: "I am"',
          answer: 'Ich bin',
        ),
        MultipleChoiceExercise(
          id: 'de_b2_e2',
          question: 'How do you say "Nice to meet you" in German?',
          options: ['Freut mich', 'Danke', 'Tschüss', 'Hallo'],
          answer: 'Freut mich',
        ),
        TranslateExercise(
          id: 'de_b2_e3',
          question: 'Translate to German: "I am a teacher"',
          answer: 'Ich bin Lehrer',
        ),
        MultipleChoiceExercise(
          id: 'de_b2_e4',
          question: 'What does "Wie heißt du?" mean?',
          options: ['What is your name?', 'How are you?', 'Where are you from?', 'Goodbye'],
          answer: 'What is your name?',
        ),
        TranslateExercise(
          id: 'de_b2_e5',
          question: 'Translate to German: "I am from Berlin"',
          answer: 'Ich bin aus Berlin',
        ),
        MultipleChoiceExercise(
          id: 'de_b2_e6',
          question: 'How do you ask "And you?" in German?',
          options: ['Und du?', 'Danke', 'Ja', 'Nein'],
          answer: 'Und du?',
        ),
      ],
    ),

    'de_beginner_1_3': Lesson(
      id: 'de_beginner_1_3',
      title: 'Alltägliche Ausdrücke',
      description: 'Essential everyday German phrases',
      exercises: [
        MultipleChoiceExercise(
          id: 'de_b3_e1',
          question: 'How do you say "Yes" in German?',
          options: ['Ja', 'Nein', 'Vielleicht', 'Danke'],
          answer: 'Ja',
        ),
        MultipleChoiceExercise(
          id: 'de_b3_e2',
          question: 'How do you say "No" in German?',
          options: ['Ja', 'Nein', 'Doch', 'Nie'],
          answer: 'Nein',
        ),
        TranslateExercise(
          id: 'de_b3_e3',
          question: 'Translate to German: "I don\'t understand"',
          answer: 'Ich verstehe nicht',
        ),
        MultipleChoiceExercise(
          id: 'de_b3_e4',
          question: 'What does "Sprechen Sie Englisch?" mean?',
          options: ['Do you speak English?', 'Do you understand?', 'Where are you?', 'What time is it?'],
          answer: 'Do you speak English?',
        ),
        TranslateExercise(
          id: 'de_b3_e5',
          question: 'Translate to German: "See you later"',
          answer: 'Bis später',
        ),
        MultipleChoiceExercise(
          id: 'de_b3_e6',
          question: 'How do you say "Of course" in German?',
          options: ['Natürlich', 'Nie', 'Vielleicht', 'Immer'],
          answer: 'Natürlich',
        ),
      ],
    ),

    'de_beginner_1_4': Lesson(
      id: 'de_beginner_1_4',
      title: 'Einfache Fragen',
      description: 'Ask basic questions in German',
      exercises: [
        TranslateExercise(
          id: 'de_b4_e1',
          question: 'Translate to German: "Where is...?"',
          answer: 'Wo ist',
        ),
        MultipleChoiceExercise(
          id: 'de_b4_e2',
          question: 'How do you say "What?" in German?',
          options: ['Was?', 'Wer?', 'Wo?', 'Wann?'],
          answer: 'Was?',
        ),
        TranslateExercise(
          id: 'de_b4_e3',
          question: 'Translate to German: "Why?"',
          answer: 'Warum',
        ),
        MultipleChoiceExercise(
          id: 'de_b4_e4',
          question: 'What does "Wie viel?" mean?',
          options: ['How much/many?', 'Why?', 'When?', 'Where?'],
          answer: 'How much/many?',
        ),
        TranslateExercise(
          id: 'de_b4_e5',
          question: 'Translate to German: "When?"',
          answer: 'Wann',
        ),
        MultipleChoiceExercise(
          id: 'de_b4_e6',
          question: 'How do you ask "Can you help me?" in German?',
          options: ['Können Sie mir helfen?', 'Wo ist?', 'Wie?', 'Warum?'],
          answer: 'Können Sie mir helfen?',
        ),
      ],
    ),

    // ==================== SPANISH UNIT 1 (4 Lessons) ====================
    'es_beginner_1_1': Lesson(
      id: 'es_beginner_1_1',
      title: '¡Hola!',
      description: 'Learn basic Spanish greetings',
      exercises: [
        MultipleChoiceExercise(
          id: 'es_b1_e1',
          question: 'How do you say "Hello" in Spanish?',
          options: ['Hola', 'Gracias', 'Adiós', 'Por favor'],
          answer: 'Hola',
        ),
        MultipleChoiceExercise(
          id: 'es_b1_e2',
          question: 'How do you say "Goodbye" in Spanish?',
          options: ['Hola', 'Gracias', 'Adiós', 'Buenos días'],
          answer: 'Adiós',
        ),
        TranslateExercise(
          id: 'es_b1_e3',
          question: 'Translate to Spanish: "Good morning"',
          answer: 'Buenos días',
        ),
        MultipleChoiceExercise(
          id: 'es_b1_e4',
          question: 'How do you say "Thank you" in Spanish?',
          options: ['Hola', 'Gracias', 'Por favor', 'Perdón'],
          answer: 'Gracias',
        ),
        TranslateExercise(
          id: 'es_b1_e5',
          question: 'Translate to Spanish: "My name is..."',
          answer: 'Me llamo',
        ),
        MultipleChoiceExercise(
          id: 'es_b1_e6',
          question: 'How do you say "Please" in Spanish?',
          options: ['Gracias', 'Por favor', 'Hola', 'Perdón'],
          answer: 'Por favor',
        ),
        TranslateExercise(
          id: 'es_b1_e7',
          question: 'Translate to Spanish: "How are you?"',
          answer: 'Cómo estás',
        ),
        MultipleChoiceExercise(
          id: 'es_b1_e8',
          question: 'How do you say "Excuse me" in Spanish?',
          options: ['Perdón', 'Gracias', 'Hola', 'Por favor'],
          answer: 'Perdón',
        ),
      ],
    ),

    'es_beginner_1_2': Lesson(
      id: 'es_beginner_1_2',
      title: 'Me llamo...',
      description: 'Introduce yourself in Spanish',
      exercises: [
        TranslateExercise(
          id: 'es_b2_e1',
          question: 'Translate to Spanish: "I am"',
          answer: 'Soy',
        ),
        MultipleChoiceExercise(
          id: 'es_b2_e2',
          question: 'How do you say "Nice to meet you" in Spanish?',
          options: ['Mucho gusto', 'Gracias', 'Adiós', 'Hola'],
          answer: 'Mucho gusto',
        ),
        TranslateExercise(
          id: 'es_b2_e3',
          question: 'Translate to Spanish: "I am a student"',
          answer: 'Soy estudiante',
        ),
        MultipleChoiceExercise(
          id: 'es_b2_e4',
          question: 'What does "¿Cómo te llamas?" mean?',
          options: ['What is your name?', 'How are you?', 'Where are you from?', 'Goodbye'],
          answer: 'What is your name?',
        ),
        TranslateExercise(
          id: 'es_b2_e5',
          question: 'Translate to Spanish: "I am from Madrid"',
          answer: 'Soy de Madrid',
        ),
        MultipleChoiceExercise(
          id: 'es_b2_e6',
          question: 'How do you ask "And you?" in Spanish?',
          options: ['¿Y tú?', 'Gracias', 'Sí', 'No'],
          answer: '¿Y tú?',
        ),
      ],
    ),

    'es_beginner_1_3': Lesson(
      id: 'es_beginner_1_3',
      title: 'Frases Comunes',
      description: 'Essential everyday Spanish phrases',
      exercises: [
        MultipleChoiceExercise(
          id: 'es_b3_e1',
          question: 'How do you say "Yes" in Spanish?',
          options: ['Sí', 'No', 'Quizás', 'Gracias'],
          answer: 'Sí',
        ),
        MultipleChoiceExercise(
          id: 'es_b3_e2',
          question: 'How do you say "No" in Spanish?',
          options: ['Sí', 'No', 'Tal vez', 'Nunca'],
          answer: 'No',
        ),
        TranslateExercise(
          id: 'es_b3_e3',
          question: 'Translate to Spanish: "I don\'t understand"',
          answer: 'No entiendo',
        ),
        MultipleChoiceExercise(
          id: 'es_b3_e4',
          question: 'What does "¿Hablas inglés?" mean?',
          options: ['Do you speak English?', 'Do you understand?', 'Where are you?', 'What time is it?'],
          answer: 'Do you speak English?',
        ),
        TranslateExercise(
          id: 'es_b3_e5',
          question: 'Translate to Spanish: "See you soon"',
          answer: 'Hasta pronto',
        ),
        MultipleChoiceExercise(
          id: 'es_b3_e6',
          question: 'How do you say "Of course" in Spanish?',
          options: ['Claro', 'Nunca', 'Quizás', 'Siempre'],
          answer: 'Claro',
        ),
      ],
    ),

    'es_beginner_1_4': Lesson(
      id: 'es_beginner_1_4',
      title: 'Preguntas Básicas',
      description: 'Ask basic questions in Spanish',
      exercises: [
        TranslateExercise(
          id: 'es_b4_e1',
          question: 'Translate to Spanish: "Where is...?"',
          answer: 'Dónde está',
        ),
        MultipleChoiceExercise(
          id: 'es_b4_e2',
          question: 'How do you say "What?" in Spanish?',
          options: ['¿Qué?', '¿Quién?', '¿Dónde?', '¿Cuándo?'],
          answer: '¿Qué?',
        ),
        TranslateExercise(
          id: 'es_b4_e3',
          question: 'Translate to Spanish: "Why?"',
          answer: 'Por qué',
        ),
        MultipleChoiceExercise(
          id: 'es_b4_e4',
          question: 'What does "¿Cuánto?" mean?',
          options: ['How much/many?', 'Why?', 'When?', 'Where?'],
          answer: 'How much/many?',
        ),
        TranslateExercise(
          id: 'es_b4_e5',
          question: 'Translate to Spanish: "When?"',
          answer: 'Cuándo',
        ),
        MultipleChoiceExercise(
          id: 'es_b4_e6',
          question: 'How do you ask "Can you help me?" in Spanish?',
          options: ['¿Puedes ayudarme?', '¿Dónde está?', '¿Cómo?', '¿Por qué?'],
          answer: '¿Puedes ayudarme?',
        ),
      ],
    ),

    // Get lesson by language code and path (for language-specific lookup)
  };

  static Lesson? getLessonByLanguage(String langCode, String lessonPath) {
    final key = '${langCode}_$lessonPath';
    return lessons[key];
  }

  static Lesson? getLesson(String title) {
    return lessons[title];
  }
}
