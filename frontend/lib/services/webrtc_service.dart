import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'chat_websocket_service.dart';

/// Service to handle WebRTC Peer Connection and Media Streams
class WebRTCService {
  final ChatWebSocketService chatService;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  
  // Callbacks for UI
  Function(MediaStream)? onLocalStream;
  Function(MediaStream)? onRemoteStream;
  Function()? onConnected;
  Function()? onDisconnected;
  
  // WebRTC Configuration
  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      // Add TURN servers here for production
    ]
  };
  
  final Map<String, dynamic> _mediaConstraints = {
    'audio': true,
    'video': {
      'facingMode': 'user',
      'width': 640,
      'height': 480
    }
  };

  WebRTCService({required this.chatService}) {
    // Listen for signaling messages
    chatService.onSignal = _handleSignal;
  }
  
  /// Initialize P2P connection
  Future<void> initialize() async {
    try {
      print("WebRTC: Initializing...");
      // Get local media stream
      _localStream = await navigator.mediaDevices.getUserMedia(_mediaConstraints);
      print("WebRTC: Local stream obtained");
      onLocalStream?.call(_localStream!);
      
      // Create peer connection
      _peerConnection = await createPeerConnection(_configuration);
      print("WebRTC: Peer connection created");
      
      // Add local tracks to peer connection
      _localStream?.getTracks().forEach((track) {
        _peerConnection?.addTrack(track, _localStream!);
      });
      
      // Handle ICE candidates
      _peerConnection?.onIceCandidate = (candidate) {
        print("WebRTC: Generated ICE candidate");
        chatService.sendSignal({
          'type': 'ice_candidate',
          'candidate': {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          }
        });
      };
      
      // Handle remote stream
      _peerConnection?.onTrack = (event) {
        print("WebRTC: Received remote track");
        if (event.streams.isNotEmpty) {
          onRemoteStream?.call(event.streams[0]);
          onConnected?.call();
        }
      };
      
      // Handle connection state
      _peerConnection?.onConnectionState = (state) {
        print('WebRTC Connection State: $state');
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
            state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
          onDisconnected?.call();
        }
      };
    } catch (e) {
      print("WebRTC Error in initialize: $e");
      rethrow;
    }
  }
  
  /// Start a call (Create Offer)
  Future<void> startCall() async {
    try {
      print("WebRTC: Starting call...");
      if (_peerConnection == null) await initialize();
      
      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      print("WebRTC: Offer created and set");
      
      chatService.sendSignal({
        'type': 'offer',
        'sdp': offer.sdp,
      });
    } catch (e) {
      print("WebRTC Error in startCall: $e");
    }
  }
  
  /// Handle incoming signaling messages
  Future<void> _handleSignal(Map<String, dynamic> data) async {
    try {
      final type = data['type'];
      print("WebRTC: Received signal $type");
      
      switch (type) {
        case 'offer':
          await _handleOffer(data['sdp']);
          break;
          
        case 'answer':
          await _handleAnswer(data['sdp']);
          break;
          
        case 'ice_candidate':
          await _handleIceCandidate(data['candidate']);
          break;
      }
    } catch (e) {
      print("WebRTC Error handling signal: $e");
    }
  }
  
  Future<void> _handleOffer(String sdp) async {
    if (_peerConnection == null) await initialize();
    
    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(sdp, 'offer'),
    );
    
    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    
    chatService.sendSignal({
      'type': 'answer',
      'sdp': answer.sdp,
    });
  }
  
  Future<void> _handleAnswer(String sdp) async {
    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(sdp, 'answer'),
    );
  }
  
  Future<void> _handleIceCandidate(Map<String, dynamic> candidateData) async {
    if (_peerConnection == null) return;
    
    await _peerConnection!.addCandidate(
      RTCIceCandidate(
        candidateData['candidate'],
        candidateData['sdpMid'],
        candidateData['sdpMLineIndex'],
      ),
    );
  }
  
  /// Toggle Microphone
  void toggleMic(bool enabled) {
    if (_localStream != null) {
      _localStream!.getAudioTracks().forEach((track) {
        track.enabled = enabled;
      });
    }
  }
  
  /// Toggle Camera
  void toggleCamera(bool enabled) {
    if (_localStream != null) {
      _localStream!.getVideoTracks().forEach((track) {
        track.enabled = enabled;
      });
    }
  }
  
  /// Switch Camera
  Future<void> switchCamera() async {
    if (_localStream != null) {
      // Helper found in flutter_webrtc examples usually involves getting video track helper
      // For simple implementation:
      final videoTrack = _localStream!.getVideoTracks().firstOrNull;
      if (videoTrack != null) {
        await Helper.switchCamera(videoTrack);
      }
    }
  }
  
  /// Dispose
  Future<void> dispose() async {
    await _localStream?.dispose();
    await _peerConnection?.dispose();
    _peerConnection = null;
    _localStream = null;
  }
}
