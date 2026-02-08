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
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _voiceService.init(); // Init Voice Service
    
    // Use topic if provided, otherwise generic greeting
    String greeting = widget.topic != null 
        ? "Welcome to the ${widget.topic} lesson! Shall we start practice?"
        : "Hello! I'm your AI English Tutor. I can help you practice conversation and fix your mistakes. What shall we talk about today?";

    messages.add({
      "role": "ai", 
      "text": greeting
    });
  }

  void send() async {
    if (controller.text.trim().isEmpty) return;

    String userMsg = controller.text;
    
    // Analyze for errors locally before sending
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

    // API call
    String reply = await ApiService.sendMessage(userMsg); 
    
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
                  "Online", 
                  style: TextStyle(fontSize: 12, color: Colors.greenAccent),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Avatar Header (Only visible if scrolled to top usually, but let's put it in list or fixed?)
          // Let's put a small branding header
          
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
                      hintText: _isListening ? "🎤 Listening..." : "Type or speak...",
                      hintStyle: TextStyle(
                        color: _isListening ? Colors.greenAccent : Colors.white.withOpacity(0.3)
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      filled: true,
                      fillColor: _isListening ? const Color(0xFF1E2F2B) : const Color(0xFF0F1117),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: _isListening 
                          ? const BorderSide(color: Colors.greenAccent, width: 2) 
                          : BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Mic Button
                GestureDetector(
                  onTap: _toggleListening,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _isListening 
                        ? const LinearGradient(colors: [Colors.red, Colors.redAccent])
                        : const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)]),
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none, 
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
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
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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

  void _toggleListening() async {
    if (_isListening) {
      // Stop listening and get result (Map)
      final result = await _voiceService.stopListening((state) {
        setState(() => _isListening = state);
      });
      
      // result = { "text": "...", "reply": "...", "pause_analysis": ... }
      if (result != null) {
        String userText = result["text"] ?? "";
        String aiReply = result["reply"] ?? "";
        
        if (userText.isNotEmpty) {
            setState(() {
                controller.text = userText; // Show user what they said
                
                // Add USER message to chat
                messages.add({
                    "role": "user", 
                    "text": userText,
                    "errors": [] // Add correction logic later if needed
                });

                // Add AI reply to chat IMMEDIATELY (since backend already generated it)
                if (aiReply.isNotEmpty) {
                    messages.add({
                        "role": "ai", 
                        "text": aiReply
                    });
                    _voiceService.speak(aiReply);
                }
            });
            _scrollToBottom();
        }
      }
    } else {
      // Start listening
      await _voiceService.startListening(
        onResult: (text) {
          // Not used
        }, 
        onListeningStateChanged: (state) {
          setState(() => _isListening = state);
        }
      );
    }
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
            child: const Icon(Icons.person_outline, size: 60, color: Colors.white24), // Fallback if image missing
          ),
          const SizedBox(height: 16),
          const Text(
            "English Tutor",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            "Expert Verification Active",
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
