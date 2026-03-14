import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/correction_helper.dart';
import '../services/voice_service.dart';



class ChatScreen extends StatefulWidget {
  final String? topic;
  const ChatScreen({super.key, this.topic});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();
  final List<Map<String, dynamic>> messages = [];
  final ScrollController _scrollController = ScrollController();
  final VoiceService _voiceService = VoiceService();
  
  bool isLoading = false;

  // New State for Translation Demo
  String selectedLanguage = "German";
  String selectedLevel = "A1";
  
  final List<String> languages = ["German", "French", "Spanish"];
  final List<String> levels = ["A1", "A2", "B1", "B2"];

  @override
  void initState() {
    super.initState();
    _initVoice();
    
    // Use topic if provided, otherwise generic greeting
    String greeting = widget.topic != null 
        ? "Welcome to the ${widget.topic} lesson! Shall we start practice?"
        : "Hello! I'm your AI Tutor. I can translate English words for you. Choose a language and level explicitly!";

    messages.add({
      "role": "ai", 
      "text": greeting
    });
  }

  Future<void> _initVoice() async {
    await _voiceService.init();
    await _voiceService.setLanguage(selectedLanguage);
  }

  void send() async {
    if (controller.text.trim().isEmpty) return;

    String userMsg = controller.text;
    
    // Analyze for errors locally before sending (keep existing logic)
    List<CorrectionSpan> errors = CorrectionHelper.analyze(userMsg);

    setState(() {
      messages.add({
        "role": "user", 
        "text": userMsg,
        "errors": errors
      });
      isLoading = true;
    });
    controller.clear();
    _scrollToBottom();

    // ── Translation Logic ──────────────────────────────────────────────────
    String reply = "";
    final String input = userMsg.trim().toLowerCase();

    // Shared level index  (A1=0, A2=1, B1=2, B2=3)
    int lvl = 0;
    if (selectedLevel == "A2") lvl = 1;
    else if (selectedLevel == "B1") lvl = 2;
    else if (selectedLevel == "B2") lvl = 3;

    // ── German dictionary ─────────────────────────────────────────────────
    const germanDictionary = <String, List<String>>{
      "how are you": ["Wie geht's?", "Wie geht es dir?", "Wie geht es Ihnen?", "Wie befinden Sie sich?"],
      "good morning": ["Guten Morgen", "Guten Morgen", "Einen schönen guten Morgen", "Einen wunderschönen guten Morgen"],
      "good night":   ["Gute Nacht", "Gute Nacht", "Schlafen Sie gut", "Eine geruhsame Nacht"],
      "thank you":    ["Danke", "Vielen Dank", "Herzlichen Dank", "Ich danke Ihnen vielmals"],
      "thanks":       ["Danke", "Vielen Dank", "Herzlichen Dank", "Besten Dank"],
      "hello":        ["Hallo", "Guten Tag", "Grüß Gott", "Herzlich willkommen"],
      "hi":           ["Hallo", "Guten Tag", "Servus", "Seien Sie gegrüßt"],
      "goodbye":      ["Tschüss", "Auf Wiedersehen", "Auf Wiedersehen", "Leben Sie wohl"],
      "bye":          ["Tschüss", "Auf Wiedersehen", "Bis bald", "Auf Wiederhören"],
      "yes":          ["Ja", "Ja", "Ja, gerne", "Selbstverständlich"],
      "no":           ["Nein", "Nein", "Leider nein", "Auf gar keinen Fall"],
      "please":       ["Bitte", "Bitte", "Bitte sehr", "Ich bitte darum"],
      "sorry":        ["Sorry", "Tut mir leid", "Entschuldigung", "Ich bitte um Verzeihung"],
      "friend":       ["Freund", "Freund", "Freund", "Bekannter"],
      "love":         ["Liebe", "Liebe", "Zuneigung", "Leidenschaft"],
      "beautiful":    ["Schön", "Schön", "Wunderschön", "Atemberaubend"],
      "good":         ["Gut", "Gut", "Gut", "Hervorragend"],
      "bad":          ["Schlecht", "Schlecht", "Schlecht", "Mangelhaft"],
      "time":         ["Zeit", "Zeit", "Uhrzeit", "Uhrzeit"],
      "today":        ["Heute", "Heute", "Heute", "Heutzutage"],
      "tomorrow":     ["Morgen", "Morgen", "Morgen", "Am morgigen Tag"],
      "yesterday":    ["Gestern", "Gestern", "Gestern", "Am gestrigen Tag"],
      "work":         ["Arbeit", "Arbeit", "Arbeit", "Beruf"],
      "learn":        ["Lernen", "Lernen", "Lernen", "Studieren"],
      "money":        ["Geld", "Geld", "Geld", "Bargeld"],
      "water":        ["Wasser", "Wasser", "Wasser", "Wasser"],
      "food":         ["Essen", "Essen", "Essen", "Nahrung"],
      "apple":        ["Apfel", "Apfel", "Apfel", "Apfel"],
      "bread":        ["Brot", "Brot", "Brot", "Brot"],
      "coffee":       ["Kaffee", "Kaffee", "Kaffee", "Kaffee"],
      "red":          ["Rot", "Rot", "Rot", "Rot"],
      "blue":         ["Blau", "Blau", "Blau", "Blau"],
      "green":        ["Grün", "Grün", "Grün", "Grün"],
      "yellow":       ["Gelb", "Gelb", "Gelb", "Gelb"],
      "black":        ["Schwarz", "Schwarz", "Schwarz", "Schwarz"],
      "white":        ["Weiß", "Weiß", "Weiß", "Weiß"],
      "mother":       ["Mutter", "Mutter", "Mutter", "Mutter"],
      "father":       ["Vater", "Vater", "Vater", "Vater"],
      "sister":       ["Schwester", "Schwester", "Schwester", "Schwester"],
      "brother":      ["Bruder", "Bruder", "Bruder", "Bruder"],
      "child":        ["Kind", "Kind", "Kind", "Kind"],
      "dog":          ["Hund", "Hund", "Hund", "Hund"],
      "cat":          ["Katze", "Katze", "Katze", "Katze"],
      "bird":         ["Vogel", "Vogel", "Vogel", "Vogel"],
      "one":          ["Eins", "Eins", "Eins", "Eins"],
      "two":          ["Zwei", "Zwei", "Zwei", "Zwei"],
      "three":        ["Drei", "Drei", "Drei", "Drei"],
      "house":        ["Haus", "Haus", "Haus", "Gebäude"],
      "school":       ["Schule", "Schule", "Schule", "Bildungseinrichtung"],
      "book":         ["Buch", "Buch", "Buch", "Lektüre"],
      "city":         ["Stadt", "Stadt", "Stadt", "Metropole"],
      "sun":          ["Sonne", "Sonne", "Sonne", "Sonne"],
      "moon":         ["Mond", "Mond", "Mond", "Mond"],
      "car":          ["Auto", "Auto", "Fahrzeug", "Automobil"],
      "happy":        ["Glücklich", "Glücklich", "Freudig", "Überaus glücklich"],
      "sad":          ["Traurig", "Traurig", "Unglücklich", "Betrübt"],
    };

    // ── French dictionary ─────────────────────────────────────────────────
    const frenchDictionary = <String, List<String>>{
      "how are you": ["Ça va?", "Comment allez-vous?", "Comment vous portez-vous?", "Comment vous portez-vous aujourd'hui?"],
      "good morning": ["Bonjour", "Bonjour", "Bonjour à vous", "Permettez-moi de vous souhaiter un bon matin"],
      "good night":   ["Bonne nuit", "Bonne nuit", "Dormez bien", "Je vous souhaite une bonne nuit"],
      "thank you":    ["Merci", "Merci beaucoup", "Je vous remercie", "Je vous remercie infiniment"],
      "thanks":       ["Merci", "Merci beaucoup", "Je vous remercie", "Grand merci"],
      "hello":        ["Bonjour", "Bonjour", "Salut", "Bonjour, bienvenue"],
      "hi":           ["Salut", "Bonjour", "Coucou", "Bienvenue"],
      "goodbye":      ["Au revoir", "Au revoir", "À bientôt", "Je vous dis au revoir"],
      "bye":          ["Au revoir", "À bientôt", "Ciao", "À la prochaine"],
      "yes":          ["Oui", "Oui", "Bien sûr", "Absolument"],
      "no":           ["Non", "Non", "Malheureusement non", "Certainement pas"],
      "please":       ["S'il vous plaît", "S'il vous plaît", "Je vous en prie", "Je vous prie"],
      "sorry":        ["Désolé", "Pardon", "Excusez-moi", "Je vous présente mes excuses"],
      "friend":       ["Ami", "Ami", "Camarade", "Compagnon"],
      "love":         ["Amour", "Amour", "Affection", "Passion"],
      "beautiful":    ["Beau", "Beau", "Magnifique", "Splendide"],
      "good":         ["Bon", "Bon", "Bien", "Excellent"],
      "bad":          ["Mauvais", "Mauvais", "Médiocre", "Déficient"],
      "time":         ["Temps", "Temps", "Heure", "L'heure"],
      "today":        ["Aujourd'hui", "Aujourd'hui", "Ce jour", "En ce jour"],
      "tomorrow":     ["Demain", "Demain", "Demain", "Le lendemain"],
      "yesterday":    ["Hier", "Hier", "Hier", "La veille"],
      "work":         ["Travail", "Travail", "Travail", "Profession"],
      "learn":        ["Apprendre", "Apprendre", "Apprendre", "Étudier"],
      "money":        ["Argent", "Argent", "Argent", "Monnaie"],
      "water":        ["Eau", "Eau", "Eau", "Eau"],
      "food":         ["Nourriture", "Nourriture", "Alimentation", "Nourriture"],
      "apple":        ["Pomme", "Pomme", "Pomme", "Pomme"],
      "bread":        ["Pain", "Pain", "Pain", "Pain"],
      "coffee":       ["Café", "Café", "Café", "Café"],
      "red":          ["Rouge", "Rouge", "Rouge", "Rouge"],
      "blue":         ["Bleu", "Bleu", "Bleu", "Bleu"],
      "green":        ["Vert", "Vert", "Vert", "Vert"],
      "yellow":       ["Jaune", "Jaune", "Jaune", "Jaune"],
      "black":        ["Noir", "Noir", "Noir", "Noir"],
      "white":        ["Blanc", "Blanc", "Blanc", "Blanc"],
      "mother":       ["Mère", "Mère", "Maman", "Mère"],
      "father":       ["Père", "Père", "Papa", "Père"],
      "sister":       ["Sœur", "Sœur", "Sœur", "Sœur"],
      "brother":      ["Frère", "Frère", "Frère", "Frère"],
      "child":        ["Enfant", "Enfant", "Enfant", "Enfant"],
      "dog":          ["Chien", "Chien", "Chien", "Chien"],
      "cat":          ["Chat", "Chat", "Chat", "Chat"],
      "bird":         ["Oiseau", "Oiseau", "Oiseau", "Oiseau"],
      "one":          ["Un", "Un", "Un", "Un"],
      "two":          ["Deux", "Deux", "Deux", "Deux"],
      "three":        ["Trois", "Trois", "Trois", "Trois"],
      "house":        ["Maison", "Maison", "Maison", "Demeure"],
      "school":       ["École", "École", "École", "Établissement scolaire"],
      "book":         ["Livre", "Livre", "Livre", "Ouvrage"],
      "city":         ["Ville", "Ville", "Cité", "Métropole"],
      "sun":          ["Soleil", "Soleil", "Soleil", "Soleil"],
      "moon":         ["Lune", "Lune", "Lune", "Lune"],
      "car":          ["Voiture", "Voiture", "Véhicule", "Automobile"],
      "happy":        ["Heureux", "Content", "Joyeux", "Comblé"],
      "sad":          ["Triste", "Triste", "Malheureux", "Mélancolique"],
    };

    // ── Spanish dictionary ─────────────────────────────────────────────────
    const spanishDictionary = <String, List<String>>{
      "how are you": ["¿Cómo estás?", "¿Cómo estás?", "¿Cómo se encuentra usted?", "¿Cómo se encuentra usted hoy?"],
      "good morning": ["Buenos días", "Buenos días", "Muy buenos días", "Le deseo unos muy buenos días"],
      "good night":   ["Buenas noches", "Buenas noches", "Que duerma bien", "Le deseo buenas noches"],
      "thank you":    ["Gracias", "Muchas gracias", "Le agradezco", "Le agradezco muchísimo"],
      "thanks":       ["Gracias", "Muchas gracias", "Le agradezco", "Muchísimas gracias"],
      "hello":        ["Hola", "Hola", "Buenos días", "Bienvenido"],
      "hi":           ["Hola", "Hola", "Buenas", "Bienvenido"],
      "goodbye":      ["Adiós", "Adiós", "Hasta luego", "Me despido con cordialidad"],
      "bye":          ["Adiós", "Hasta luego", "Chao", "Hasta la próxima"],
      "yes":          ["Sí", "Sí", "Por supuesto", "Absolutamente"],
      "no":           ["No", "No", "Lamentablemente no", "De ninguna manera"],
      "please":       ["Por favor", "Por favor", "Le ruego", "Por favor, se lo pido"],
      "sorry":        ["Lo siento", "Perdón", "Disculpe", "Le presento mis disculpas"],
      "friend":       ["Amigo", "Amigo", "Camarada", "Compañero"],
      "love":         ["Amor", "Amor", "Afecto", "Pasión"],
      "beautiful":    ["Bonito", "Hermoso", "Magnífico", "Espléndido"],
      "good":         ["Bueno", "Bueno", "Bien", "Excelente"],
      "bad":          ["Malo", "Malo", "Deficiente", "Pésimo"],
      "time":         ["Tiempo", "Tiempo", "Hora", "La hora"],
      "today":        ["Hoy", "Hoy", "Hoy día", "En el día de hoy"],
      "tomorrow":     ["Mañana", "Mañana", "Mañana", "El día de mañana"],
      "yesterday":    ["Ayer", "Ayer", "Ayer", "El día anterior"],
      "work":         ["Trabajo", "Trabajo", "Trabajo", "Profesión"],
      "learn":        ["Aprender", "Aprender", "Aprender", "Estudiar"],
      "money":        ["Dinero", "Dinero", "Dinero", "Moneda"],
      "water":        ["Agua", "Agua", "Agua", "Agua"],
      "food":         ["Comida", "Comida", "Alimento", "Comida"],
      "apple":        ["Manzana", "Manzana", "Manzana", "Manzana"],
      "bread":        ["Pan", "Pan", "Pan", "Pan"],
      "coffee":       ["Café", "Café", "Café", "Café"],
      "red":          ["Rojo", "Rojo", "Rojo", "Rojo"],
      "blue":         ["Azul", "Azul", "Azul", "Azul"],
      "green":        ["Verde", "Verde", "Verde", "Verde"],
      "yellow":       ["Amarillo", "Amarillo", "Amarillo", "Amarillo"],
      "black":        ["Negro", "Negro", "Negro", "Negro"],
      "white":        ["Blanco", "Blanco", "Blanco", "Blanco"],
      "mother":       ["Madre", "Madre", "Mamá", "Madre"],
      "father":       ["Padre", "Padre", "Papá", "Padre"],
      "sister":       ["Hermana", "Hermana", "Hermana", "Hermana"],
      "brother":      ["Hermano", "Hermano", "Hermano", "Hermano"],
      "child":        ["Niño", "Niño", "Niño", "Niño"],
      "dog":          ["Perro", "Perro", "Perro", "Perro"],
      "cat":          ["Gato", "Gato", "Gato", "Gato"],
      "bird":         ["Pájaro", "Pájaro", "Pájaro", "Pájaro"],
      "one":          ["Uno", "Uno", "Uno", "Uno"],
      "two":          ["Dos", "Dos", "Dos", "Dos"],
      "three":        ["Tres", "Tres", "Tres", "Tres"],
      "house":        ["Casa", "Casa", "Casa", "Vivienda"],
      "school":       ["Escuela", "Escuela", "Colegio", "Centro educativo"],
      "book":         ["Libro", "Libro", "Libro", "Obra"],
      "city":         ["Ciudad", "Ciudad", "Ciudad", "Metrópolis"],
      "sun":          ["Sol", "Sol", "Sol", "Sol"],
      "moon":         ["Luna", "Luna", "Luna", "Luna"],
      "car":          ["Coche", "Coche", "Vehículo", "Automóvil"],
      "happy":        ["Feliz", "Contento", "Alegre", "Muy feliz"],
      "sad":          ["Triste", "Triste", "Infeliz", "Melancólico"],
    };

    // Pick the right dictionary
    Map<String, List<String>> dictionary = {};
    if (selectedLanguage == "German")  dictionary = germanDictionary;
    if (selectedLanguage == "French")  dictionary = frenchDictionary;
    if (selectedLanguage == "Spanish") dictionary = spanishDictionary;

    // Find the longest matching key
    String matchedKey = "";
    for (final key in dictionary.keys) {
      if (input.contains(key) && key.length > matchedKey.length) {
        matchedKey = key;
      }
    }

    if (matchedKey.isNotEmpty) {
      reply = "${dictionary[matchedKey]![lvl]} ($selectedLevel)";
    }

    // Fallback: send ONLY the raw word to the AI (no extra noise)
    if (reply.isEmpty) {
      reply = await ApiService.sendMessage(userMsg, targetLanguage: selectedLanguage);
    }

    // delayed response simulation for local mock
    if (!reply.startsWith("Error")) { 
        await Future.delayed(const Duration(milliseconds: 600)); 
    }
    
    if (mounted) {
      setState(() {
        messages.add({"role": "ai", "text": reply});
        isLoading = false;
      });
      _scrollToBottom();
      
      // Auto-speak the AI response (using cleaned text from VoiceService)
      await _voiceService.setLanguage(selectedLanguage);
      _voiceService.speak(reply);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
             CircleAvatar(
               backgroundColor: Color(0xFF6C63FF),
               child: Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("AI Tutor", style: TextStyle(fontSize: 18)),
                Text(
                  "Translator Mode", 
                  style: TextStyle(fontSize: 12, color: Colors.greenAccent),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // --- SETTINGS HEADER ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF1E212B),
            child: Row(
              children: [
                // Language Dropdown
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedLanguage,
                        dropdownColor: const Color(0xFF1E212B),
                        isExpanded: true,
                        style: const TextStyle(color: Colors.white),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                        items: languages.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                        onChanged: (val) {
                          setState(() => selectedLanguage = val!);
                          _voiceService.setLanguage(val!);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Level Dropdown
                Container(
                  width: 100,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedLevel,
                      dropdownColor: const Color(0xFF1E212B),
                      style: const TextStyle(color: Colors.white),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      items: levels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                      onChanged: (val) => setState(() => selectedLevel = val!),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: messages.length + (isLoading ? 1 : 0) + 1, // +1 for header
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildAvatarHeader();
                }

                // Adjust index for header
                final msgIndex = index - 1;
                
                if (isLoading && msgIndex == messages.length) {
                  return const Padding(
                    padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2)
                        ),
                        SizedBox(width: 12),
                        Text("AI is typing...", style: TextStyle(color: Colors.white54)),
                      ],
                    ),
                  );
                }
                
                final msg = messages[msgIndex];
                final isUser = msg["role"] == "user";
                final List<CorrectionSpan>? errors = msg["errors"];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser) const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF1E212B),
                        child: Icon(Icons.smart_toy, size: 16, color: Colors.white54),
                      ),
                      if (!isUser) const SizedBox(width: 12),
                      
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            gradient: isUser 
                              ? const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)])
                              : null,
                            color: isUser ? null : const Color(0xFF1E212B),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: Radius.circular(isUser ? 20 : 4),
                              bottomRight: Radius.circular(isUser ? 4 : 20),
                            ),
                          ),
                          child: isUser && errors != null && errors.isNotEmpty
                              ? _buildCorrectedText(msg["text"], errors)
                              : Text(
                                  msg["text"],
                                  style: TextStyle(
                                    color: isUser ? Colors.white : Colors.white.withOpacity(0.9),
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                      
                      if (isUser) const SizedBox(width: 12),
                      if (isUser) const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF6C63FF),
                        child: Icon(Icons.person, size: 16, color: Colors.white),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E212B),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Type phrase to translate...",
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.3)
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      filled: true,
                      fillColor: const Color(0xFF0F1117),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const SizedBox(width: 8),

                // Send Button
                Container(
                  width: 45,
                  height: 45,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)]),
                  ),
                  child: IconButton(
                    onPressed: send,
                    icon: const Icon(Icons.translate_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _voiceService.stopSpeaking();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _buildAvatarHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
              image: const DecorationImage(
                image: AssetImage('assets/images/ai_tutor_avatar.png'), // Placeholder path
                fit: BoxFit.cover,
              ),
              border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.5), width: 3),
            ),
            child: const Icon(Icons.smart_toy_outlined, size: 60, color: Colors.white24), // Changed to robot icon
          ),
          const SizedBox(height: 16),
          const Text(
            "AI Tutor",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            "Translation Mode Active",
            style: TextStyle(fontSize: 14, color: Colors.greenAccent),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.1)),
        ],
      ),
    );
  }

  Widget _buildCorrectedText(String text, List<CorrectionSpan> errors) {
    List<Widget> children = [];
    int lastIndex = 0;

    // Sort errors by start index just in case
    // errors.sort((a, b) => a.start.compareTo(b.start));

    for (var error in errors) {
      if (error.start > lastIndex) {
        children.add(TextSpanWidget(text: text.substring(lastIndex, error.start)));
      }

      children.add(
        ErrorPopupWidget(
           original: text.substring(error.start, error.end),
           suggestion: error.suggestion,
        )
      );
      
      lastIndex = error.end;
    }

    if (lastIndex < text.length) {
      children.add(TextSpanWidget(text: text.substring(lastIndex)));
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      children: children,
    );
  }
}

class TextSpanWidget extends StatelessWidget {
  final String text;
  const TextSpanWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white, fontSize: 16),
    );
  }
}

class ErrorPopupWidget extends StatelessWidget {
  final String original;
  final String suggestion;

  const ErrorPopupWidget({super.key, required this.original, required this.suggestion});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E212B),
            title: const Text("Correction Suggestion", style: TextStyle(color: Colors.white)),
            content: Text(
              "You wrote \"$original\".\nDid you mean \"$suggestion\"?",
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Got it"))
            ],
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.redAccent, width: 2, style: BorderStyle.solid)), // Wavy underline hard in flutter basic, using solid red
        ),
        child: Text(
          original,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
