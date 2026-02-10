import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../services/chat_websocket_service.dart';
import '../services/matching_api_service.dart';
import '../services/webrtc_service.dart';
import 'package:intl/intl.dart';

class PartnerChatScreen extends StatefulWidget {
  final String matchId;
  final Map<String, dynamic> partner;
  final String targetLanguage;
  final String websocketUrl;

  const PartnerChatScreen({
    super.key,
    required this.matchId,
    required this.partner,
    required this.targetLanguage,
    required this.websocketUrl,
  });

  @override
  State<PartnerChatScreen> createState() => _PartnerChatScreenState();
}

class _PartnerChatScreenState extends State<PartnerChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  late ChatWebSocketService _chatService;
  WebRTCService? _webRTCService; // Changed from late to nullable
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();

  bool _isVideoEnabled = false;
  bool _isAudioEnabled = true;
  bool _isMicEnabled = true;
  bool _partnerTyping = false;
  bool _isConnected = false;
  int _sessionDuration = 0;
  Timer? _durationTimer;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    print("DEBUG: PartnerChatScreen initialized with Match ID: ${widget.matchId}");
    _initChatService();
    // Delay WebRTC init to allow UI to build and prevent immediate crash on nav
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _initWebRTC();
    });
    _startSessionTimer();
  }

  void _initChatService() {
    _chatService = ChatWebSocketService(matchId: widget.matchId);

    _chatService.onMessage = (message) {
      if (mounted) {
        setState(() {
          _messages.add({
            'sender': 'partner',
            'text': message['text'],
            'timestamp': DateTime.parse(message['timestamp']),
          });
          _partnerTyping = false;
        });
        _scrollToBottom();
      }
    };

    _chatService.onTyping = (isTyping) {
      if (mounted) {
        setState(() => _partnerTyping = isTyping);
        if (isTyping) _scrollToBottom();
      }
    };

    _chatService.onConnected = () {
      if (mounted) setState(() => _isConnected = true);
    };
    
    _chatService.onError = (error) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chat Error: $error'), backgroundColor: Colors.red),
        );
      }
    };
    
    _chatService.onMatchEnded = (reason) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Match ended.'), backgroundColor: Colors.orange),
        );
        Navigator.pop(context); // Close chat screen
      }
    };

    _chatService.connect();
  }

  void _startSessionTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _sessionDuration++);
    });
  }

  Future<void> _initWebRTC() async {
    try {
      print("DEBUG: Requesting permissions...");
      // Request permissions first
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.microphone,
      ].request();
      print("DEBUG: Permissions status: $statuses");

      if (statuses[Permission.camera] != PermissionStatus.granted || 
          statuses[Permission.microphone] != PermissionStatus.granted) {
        print('Camera or Mic permission denied');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Camera & Mic permissions are required for video calls')),
          );
        }
        return; 
      }

      print("DEBUG: Initializing Renderers...");
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();
      
      print("DEBUG: Initializing WebRTC Service...");
      _updateStatus("Initializing Service...");
      _webRTCService = WebRTCService(chatService: _chatService);
      
      _webRTCService?.onLocalStream = (stream) {
        if (mounted) setState(() => _localRenderer.srcObject = stream);
      };
      
      _webRTCService?.onRemoteStream = (stream) {
        if (mounted) {
          _updateStatus("Connected!");
          setState(() {
            _remoteRenderer.srcObject = stream;
            _isVideoEnabled = true; // Auto-show video UI
          });
        }
      };
      
      _webRTCService?.onConnected = () {
         _updateStatus("P2P Connected");
      };

      _webRTCService?.onDisconnected = () {
        if (mounted) {
          _updateStatus("Disconnected");
          setState(() {
            _remoteRenderer.srcObject = null;
            _isVideoEnabled = false;
          });
        }
      };
      print("DEBUG: WebRTC Initialized Successfully");
      _updateStatus("Ready. Press Video to Start.");
    } catch (e, stackTrace) {
      print("CRITICAL ERROR in _initWebRTC: $e");
      print(stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Video Init Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _durationTimer?.cancel();
    _typingTimer?.cancel();
    _typingTimer?.cancel();
    _webRTCService?.dispose(); // Null check
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _chatService.disconnect();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text;

    setState(() {
      _messages.add({
        'sender': 'me',
        'text': messageText,
        'timestamp': DateTime.now(),
      });
    });

    _chatService.sendMessage(messageText);

    _messageController.clear();
    _scrollToBottom();
  }
  
  void _onTypingChanged(String value) {
     // TODO: Implement debounce for sending typing status
     // _chatService.sendTypingIndicator(value.isNotEmpty);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _toggleVideo() async {
    if (_webRTCService == null) {
      print("Starting call but WebRTC not ready yet. Retrying/Waiting...");
      return; 
    }
    
    setState(() => _isVideoEnabled = !_isVideoEnabled);
    if (_isVideoEnabled) {
      _updateStatus("Calling...");
      await _webRTCService?.startCall();
    } else {
      _updateStatus("Ending Call...");
      _webRTCService?.toggleCamera(false);
    }
  }

  void _toggleAudio() {
    // This probably controls speakerphone/output, implementing simple mute for now
    // setState(() => _isAudioEnabled = !_isAudioEnabled);
  }

  void _toggleMic() {
    setState(() => _isMicEnabled = !_isMicEnabled);
    _webRTCService?.toggleMic(_isMicEnabled);
  }

  void _endSession() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E212B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'End Session?',
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to end this conversation?',
          style: GoogleFonts.outfit(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.outfit(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // Dialog
              
              // End via API
              try {
                // Determine reason based on context, default to 'finished'
                await matchingApiService.endMatch(matchId: widget.matchId);
              } catch (e) {
                print("Error ending match: $e");
                // If API fails, force exit
                if (mounted) Navigator.pop(context);
              }
              
              // Do NOT manually pop here. Wait for WebSocket 'match_ended' event.
              // This prevents double-popping (once from here, once from event listener). 
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: Text(
              'End',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _reportPartner() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E212B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Report User', style: GoogleFonts.outfit(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Why are you reporting this user?', style: GoogleFonts.outfit(color: Colors.white70)),
            const SizedBox(height: 16),
            _buildReportOption('Inappropriate content'),
            _buildReportOption('Harassment'),
            _buildReportOption('Spam'),
            _buildReportOption('Other'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.outfit(color: Colors.white54)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReportOption(String reason) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted.'), backgroundColor: Colors.green),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
           reason, 
           style: GoogleFonts.outfit(
            color: const Color(0xFF00E5FF),
            fontSize: 15,
           )
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF6C63FF),
              child: Text(
                widget.partner['display_name'][0],
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.partner['display_name'],
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _isConnected ? Colors.greenAccent : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDuration(_sessionDuration),
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            onPressed: _reportPartner,
            tooltip: 'Report',
          ),
          IconButton(
            icon: const Icon(Icons.call_end_rounded),
            color: Colors.redAccent,
            onPressed: _endSession,
            tooltip: 'End Session',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isVideoEnabled) _buildVideoSection(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_partnerTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_partnerTyping && index == _messages.length) {
                  return _buildTypingIndicator();
                }
                final message = _messages[index];
                final isMe = message['sender'] == 'me';
                return _buildMessageBubble(
                  message['text'],
                  isMe,
                  message['timestamp'],
                );
              },
            ),
          ),
          if (_isVideoEnabled || _isAudioEnabled) _buildMediaControls(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  // Connection Status Debugging
  String _connectionStatus = "Ready";

  void _updateStatus(String status) {
    print("WebRTC STATUS: $status");
    if (mounted) setState(() => _connectionStatus = status);
  }

  Widget _buildVideoSection() {
     return Container(
      height: 180, // Fixed height for video row
      color: const Color(0xFF0F1117),
      child: Stack(
        children: [
          Row(
            children: [
              // Local Video (Self)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black54,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: RTCVideoView(
                      _localRenderer,
                      mirror: true,
                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                  ),
                ),
              ),
              
              // Remote Video (Partner)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black54,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _remoteRenderer.srcObject != null
                        ? RTCVideoView(
                            _remoteRenderer,
                            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                          )
                        : Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                 const Icon(Icons.videocam_off, color: Colors.white24),
                                 Text("Waiting...", style: GoogleFonts.outfit(color: Colors.white24, fontSize: 10)),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
          // Debug Overlay
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                child: Text(_connectionStatus, style: const TextStyle(color: Colors.yellow, fontSize: 10)),
              ),
            ),
          ),
        ],
      ),
     );
  }

  Widget _buildMediaControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: const Color(0xFF1E212B),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildMediaButton(icon: _isMicEnabled ? Icons.mic : Icons.mic_off, label: 'Mic', isActive: _isMicEnabled, onTap: _toggleMic),
          const SizedBox(width: 16),
          _buildMediaButton(icon: _isAudioEnabled ? Icons.volume_up : Icons.volume_off, label: 'Audio', isActive: _isAudioEnabled, onTap: _toggleAudio),
          const SizedBox(width: 16),
          _buildMediaButton(icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off, label: 'Video', isActive: _isVideoEnabled, onTap: _toggleVideo),
        ],
      ),
    );
  }

  Widget _buildMediaButton({required IconData icon, required String label, required bool isActive, required VoidCallback onTap}) {
     return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF6C63FF) : const Color(0xFF0F1117),
              shape: BoxShape.circle,
              border: Border.all(color: isActive ? const Color(0xFF6C63FF) : Colors.white24),
            ),
            child: Icon(icon, color: isActive ? Colors.white : Colors.white54, size: 20),
          ),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.outfit(fontSize: 10, color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, DateTime timestamp) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12, left: isMe ? 50 : 0, right: isMe ? 0 : 50),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF6C63FF) : const Color(0xFF1E212B),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, style: GoogleFonts.outfit(color: Colors.white, fontSize: 15)),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(timestamp),
              style: GoogleFonts.outfit(fontSize: 10, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12, 
            backgroundColor: const Color(0xFF6C63FF), 
            child: Text(widget.partner['display_name'][0], style: const TextStyle(fontSize: 10))
          ),
          const SizedBox(width: 8),
          Text("Typing...", style: GoogleFonts.outfit(color: Colors.white54, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1E212B),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              onChanged: _onTypingChanged,
              style: GoogleFonts.outfit(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: GoogleFonts.outfit(color: Colors.white30),
                filled: true,
                fillColor: const Color(0xFF0F1117),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
             decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF6C63FF)),
             child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
