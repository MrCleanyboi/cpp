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
    _voiceService.init();
    
    // Use topic if provided, otherwise generic greeting
    String greeting = widget.topic != null 
        ? "Welcome to the ${widget.topic} lesson! Shall we start practice?"
        : "Hello! I'm your AI Tutor. I can translate English words for you. Choose a language and level explicitly!";

    messages.add({
      "role": "ai", 
      "text": greeting
    });
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

    // --- MOCK TRANSLATION LOGIC FOR DEMO ---
    String reply = "";
    
    // Simple normalization
    String input = userMsg.trim().toLowerCase();
    
    if (selectedLanguage == "German") {
      final Map<String, List<String>> germanDictionary = {
        // Greetings & Basics
        "how are you": ["Wie geht's?", "Wie geht es dir?", "Wie geht es Ihnen?", "Wie befinden Sie sich heute?"],
        "good morning": ["Guten Morgen", "Guten Morgen", "Einen schönen guten Morgen", "Einen wunderschönen guten Morgen"],
        "good night": ["Gute Nacht", "Gute Nacht", "Schlafen Sie gut", "Eine geruhsame Nacht"],
        "thank you": ["Danke", "Vielen Dank", "Herzlichen Dank", "Ich danke Ihnen vielmals"],
        "thanks": ["Danke", "Vielen Dank", "Herzlichen Dank", "Besten Dank"],
        "hello": ["Hallo", "Guten Tag", "Grüß Gott", "Herzlich willkommen"],
        "hi": ["Hallo", "Guten Tag", "Servus", "Seien Sie gegrüßt"],
        "goodbye": ["Tschüss", "Auf Wiedersehen", "Auf Wiedersehen", "Leben Sie wohl"],
        "bye": ["Tschüss", "Auf Wiedersehen", "Bis bald", "Auf Wiederhören"],
        "yes": ["Ja", "Ja", "Ja, gerne", "Selbstverständlich"],
        "no": ["Nein", "Nein", "Leider nein", "Auf gar keinen Fall"],
        "please": ["Bitte", "Bitte", "Bitte sehr", "Ich bitte darum"],
        "sorry": ["Sorry", "Tut mir leid", "Entschuldigung", "Ich bitte um Verzeihung"],
        "friend": ["Freund", "Freund", "Freund", "Bekannter"],
        "love": ["Liebe", "Liebe", "Zuneigung", "Leidenschaft"],
        "beautiful": ["Schön", "Schön", "Wunderschön", "Atemberaubend"],
        "good": ["Gut", "Gut", "Gut", "Hervorragend"],
        "bad": ["Schlecht", "Schlecht", "Schlecht", "Mangelhaft"],

        // Time & Work
        "time": ["Zeit", "Zeit", "Zeit", "Uhrzeit"],
        "today": ["Heute", "Heute", "Heute", "Heutzutage"],
        "tomorrow": ["Morgen", "Morgen", "Morgen", "Am morgigen Tag"],
        "yesterday": ["Gestern", "Gestern", "Gestern", "Am gestrigen Tag"],
        "work": ["Arbeit", "Arbeit", "Arbeit", "Beruf"],
        "learn": ["Lernen", "Lernen", "Lernen", "Studieren"],
        "money": ["Geld", "Geld", "Geld", "Bargeld"],

        // Food & Drink
        "water": ["Wasser", "Wasser", "Wasser", "Wasser"],
        "food": ["Essen", "Essen", "Essen", "Nahrung"],
        "apple": ["Apfel", "Apfel", "Apfel", "Apfel"],
        "bread": ["Brot", "Brot", "Brot", "Brot"],
        "coffee": ["Kaffee", "Kaffee", "Kaffee", "Kaffee"],
        
        // Colors
        "red": ["Rot", "Rot", "Rot", "Rot"],
        "blue": ["Blau", "Blau", "Blau", "Blau"],
        "green": ["Grün", "Grün", "Grün", "Grün"],
        "yellow": ["Gelb", "Gelb", "Gelb", "Gelb"],
        "black": ["Schwarz", "Schwarz", "Schwarz", "Schwarz"],
        "white": ["Weiß", "Weiß", "Weiß", "Weiß"],

        // Family
        "mother": ["Mutter", "Mutter", "Mutter", "Mutter"],
        "father": ["Vater", "Vater", "Vater", "Vater"],
        "sister": ["Schwester", "Schwester", "Schwester", "Schwester"],
        "brother": ["Bruder", "Bruder", "Bruder", "Bruder"],
        "child": ["Kind", "Kind", "Kind", "Kind"],

        // Animals
        "dog": ["Hund", "Hund", "Hund", "Hund"],
        "cat": ["Katze", "Katze", "Katze", "Katze"],
        "bird": ["Vogel", "Vogel", "Vogel", "Vogel"],

        // Numbers
        "one": ["Eins", "Eins", "Eins", "Eins"],
        "two": ["Zwei", "Zwei", "Zwei", "Zwei"],
        "three": ["Drei", "Drei", "Drei", "Drei"],
      };


      int levelIndex = 0;
      if (selectedLevel == "A2") levelIndex = 1;
      else if (selectedLevel == "B1") levelIndex = 2;
      else if (selectedLevel == "B2") levelIndex = 3;

      // Find the longest matching key in the dictionary
      String matchedKey = "";
      for (var key in germanDictionary.keys) {
        if (input.contains(key)) {
          if (key.length > matchedKey.length) {
            matchedKey = key;
          }
        }
      }
      
      if (matchedKey.isNotEmpty) {
          reply = "${germanDictionary[matchedKey]![levelIndex]} ($selectedLevel)";
      }
    }
    
    // Fallback if not hit or other language (just for demo safety)
    if (reply.isEmpty) {
        // Fallback to API if we had it, but for now just a generic or echo
        // Or actually call the API if we want real chat
        // For the demo request: "simply implement this for german for now for a specific or 2-3 words"
        // I'll just say use the API for others, but for safety in this demo I'll just explain.
        reply = await ApiService.sendMessage("Translate '$userMsg' to $selectedLanguage at $selectedLevel level."); 
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
      
      // Auto-speak the AI response
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
                        onChanged: (val) => setState(() => selectedLanguage = val!),
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
