import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../utils/http_client.dart';

/// WebRTC连接管理器
class WebRTCService {
  RTCPeerConnection? _pc;
  MediaStream? _localStream;
  final List<RTCIceCandidate> _localCandidates = [];
  bool _iceGatheringComplete = false;
  
  // 连接状态
  RTCIceConnectionState _iceConnectionState = RTCIceConnectionState.RTCIceConnectionStateNew;
  RTCPeerConnectionState _connectionState = RTCPeerConnectionState.RTCPeerConnectionStateNew;
  RTCSignalingState _signalingState = RTCSignalingState.RTCSignalingStateStable;
  
  // 回调函数
  final Function(String) onLog;
  final Function(RTCIceConnectionState) onIceConnectionStateChanged;
  final Function(RTCPeerConnectionState) onConnectionStateChanged;
  final Function(RTCSignalingState) onSignalingStateChanged;
  final Function(MediaStream) onRemoteStreamReceived;
  final Function(bool) onIceGatheringStateChanged;

  WebRTCService({
    required this.onLog,
    required this.onIceConnectionStateChanged,
    required this.onConnectionStateChanged,
    required this.onSignalingStateChanged,
    required this.onRemoteStreamReceived,
    required this.onIceGatheringStateChanged,
  });

  // Getters
  RTCPeerConnection? get peerConnection => _pc;
  MediaStream? get localStream => _localStream;
  List<RTCIceCandidate> get localCandidates => _localCandidates;
  bool get iceGatheringComplete => _iceGatheringComplete;
  RTCIceConnectionState get iceConnectionState => _iceConnectionState;
  RTCPeerConnectionState get connectionState => _connectionState;
  RTCSignalingState get signalingState => _signalingState;

  /// 创建PeerConnection
  Future<void> createPeer({
    required String turnIp,
    required String turnPort,
    required String turnUser,
    required String turnPass,
    required String turnRealm,
  }) async {
    final config = _buildRtcConfig(turnIp, turnPort, turnUser, turnPass, turnRealm);
    final constraints = {
      'mandatory': {},
      'optional': [
        {'DtlsSrtpKeyAgreement': true},
      ],
    };

    onLog('Creating RTCPeerConnection...');
    _pc = await createPeerConnection(config, constraints);

    _setupEventHandlers();
    await _openCameraAndMic();
  }

  /// 设置事件处理器
  void _setupEventHandlers() {
    _pc?.onIceCandidate = (RTCIceCandidate candidate) async {
      _localCandidates.add(candidate);
      final frag = (candidate.candidate ?? '').split(' ').take(4).join(' ');
      onLog('ICE candidate gathered: ${frag.isEmpty ? 'empty' : frag}');
    };
    
    _pc?.onIceGatheringState = (RTCIceGatheringState state) {
      _iceGatheringComplete = state == RTCIceGatheringState.RTCIceGatheringStateComplete;
      onLog('ICE gathering state: $state');
      if (_iceGatheringComplete) {
        onLog('ICE gathering completed. Total: ${_localCandidates.length}');
      }
      onIceGatheringStateChanged(_iceGatheringComplete);
    };
    
    _pc?.onIceConnectionState = (RTCIceConnectionState state) {
      _iceConnectionState = state;
      onLog('ICE connection state: $state');
      onIceConnectionStateChanged(state);
    };
    
    _pc?.onConnectionState = (RTCPeerConnectionState state) {
      _connectionState = state;
      onLog('Peer connection state: $state');
      onConnectionStateChanged(state);
    };
    
    _pc?.onSignalingState = (RTCSignalingState state) {
      _signalingState = state;
      onLog('Signaling state: $state');
      onSignalingStateChanged(state);
    };

    _pc?.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        onLog('Remote track added: kind=${event.track.kind}, stream=${event.streams.first.id}');
        onRemoteStreamReceived(event.streams.first);
      }
    };
  }

  /// 构建RTC配置
  Map<String, dynamic> _buildRtcConfig(String ip, String port, String user, String pass, String realm) {
    final List<Map<String, dynamic>> iceServers = [];
    
    if (ip.isNotEmpty && port.isNotEmpty) {
      final url = 'turn:$ip:$port';
      onLog('Adding TURN server: $url');
      
      if (user.isNotEmpty && pass.isNotEmpty) {
        iceServers.add({
          'urls': url, 
          'username': user, 
          'credential': pass,
          'realm': realm.isNotEmpty ? realm : null,
        });
        onLog('TURN with auth: username=$user, realm=$realm, credential=${pass.substring(0, 1)}***');
      } else {
        iceServers.add({'urls': url});
        onLog('TURN without auth (anonymous)');
      }
    } else {
      iceServers.add({'urls': 'stun:stun.l.google.com:19302'});
      onLog('No TURN configured, using fallback STUN');
    }
    
    final config = {
      'sdpSemantics': 'unified-plan',
      'iceServers': iceServers,
      'iceCandidatePoolSize': 10,
      'bundlePolicy': 'max-bundle',
      'rtcpMuxPolicy': 'require',
    };
    
    onLog('RTC config: ${jsonEncode(config)}');
    return config;
  }

  /// 打开摄像头和麦克风
  Future<void> _openCameraAndMic() async {
    try {
      final mediaConstraints = {
        'audio': true,
        'video': {
          'facingMode': 'user',
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
          'frameRate': {'ideal': 30},
        },
      };
      final stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localStream = stream;

      final videoTrack = _localStream!.getVideoTracks().first;
      final audioTrack = _localStream!.getAudioTracks().first;
      
      await _pc?.addTransceiver(track: videoTrack, kind: RTCRtpMediaType.RTCRtpMediaTypeVideo);
      await _pc?.addTransceiver(track: audioTrack, kind: RTCRtpMediaType.RTCRtpMediaTypeAudio);
      onLog('Local media started: video+audio');
    } catch (e) {
      onLog('❌ Failed to open camera/mic: $e');
      onLog('💡 请检查摄像头和麦克风权限');
    }
  }

  /// 创建Offer
  Future<String?> createOffer() async {
    if (_pc == null) return null;
    
    onLog('🔄 Creating offer...');
    _localCandidates.clear();
    _iceGatheringComplete = false;
    
    try {
      final offer = await _pc!.createOffer({
        'offerToReceiveAudio': 1, 
        'offerToReceiveVideo': 1
      });
      await _pc!.setLocalDescription(offer);
      onLog('✅ Local offer set. Starting ICE gathering...');
      
      // 等待ICE收集完成
      await _waitForIceGathering();
      return await _generatePairCode();
    } catch (e) {
      onLog('❌ Failed to create offer: $e');
      return null;
    }
  }

  /// 等待ICE收集完成
  Future<void> _waitForIceGathering() async {
    if (_iceGatheringComplete) return;
    
    onLog('⏳ Waiting for ICE gathering to complete...');
    int waitCount = 0;
    while (!_iceGatheringComplete && waitCount < 30) {
      await Future.delayed(const Duration(seconds: 1));
      waitCount++;
      if (waitCount % 5 == 0) {
        onLog('⏳ Still waiting for ICE... (${waitCount}s)');
      }
    }
    
    if (_iceGatheringComplete) {
      onLog('✅ ICE gathering completed successfully');
    } else {
      onLog('⚠️ ICE gathering timeout, proceeding with current candidates');
    }
  }

  /// 生成配对码
  Future<String?> _generatePairCode() async {
    if (_pc == null) return null;
    
    final desc = await _pc!.getLocalDescription();
    if (desc == null) {
      onLog('❌ Failed to get local description');
      return null;
    }
    
    final payload = {
      'sdp': desc.sdp,
      'type': desc.type,
      'candidates': _localCandidates.map((c) => {
        'candidate': c.candidate,
        'sdpMid': c.sdpMid,
        'sdpMLineIndex': c.sdpMLineIndex,
      }).toList(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    final shortCode = await _storePairData(payload);
    if (shortCode != null) {
      onLog('✅ Generated short pair code: $shortCode (${_localCandidates.length} candidates)');
    } else {
      onLog('❌ Failed to generate pair code');
    }
    return shortCode;
  }

  /// 存储配对数据
  Future<String?> _storePairData(Map<String, dynamic> data) async {
    try {
      final shortCode = _generateShortCode();
      final response = await HttpClient.instance.post(
        path: '/api/sync/tmp/set',
        data: {
          'key': shortCode,
          'value': jsonEncode(data),
        },
      );
      
      if (response.ok) {
        onLog('Stored pair data with code: $shortCode');
        return shortCode;
      } else {
        onLog('Failed to store pair data: ${response.message}');
        return null;
      }
    } catch (e) {
      onLog('Store pair data error: $e');
      return null;
    }
  }

  /// 生成短码
  String _generateShortCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
  }

  /// 消费配对码并回复
  Future<bool> consumePairCodeAndReply(String shortCode, {required bool reply}) async {
    if (_pc == null) return false;
    
    if (shortCode.length != 6) {
      onLog('❌ Invalid short code length: ${shortCode.length}');
      return false;
    }
    
    onLog('🔄 Processing pair code: $shortCode...');
    final data = await _fetchPairData(shortCode);
    if (data == null) {
      onLog('❌ Failed to fetch data for code: $shortCode');
      return false;
    }
    
    try {
      final sdp = RTCSessionDescription(data['sdp'] as String, data['type'] as String);
      await _pc!.setRemoteDescription(sdp);
      onLog('✅ Set remote description: type=${sdp.type}, sdpLen=${(sdp.sdp ?? '').length}');
      
      final List<dynamic> cands = (data['candidates'] as List<dynamic>? ?? <dynamic>[]);
      for (final c in cands) {
        try {
          await _pc!.addCandidate(RTCIceCandidate(
            (c as Map<String, dynamic>)['candidate'] as String?,
            c['sdpMid'] as String?,
            c['sdpMLineIndex'] as int?,
          ));
        } catch (e) {
          onLog('⚠️ Failed to add candidate: $e');
        }
      }
      onLog('✅ Added remote candidates: count=${cands.length}');
      
      if (reply && sdp.type == 'offer') {
        onLog('🔄 Creating answer for offer...');
        final answer = await _pc!.createAnswer({
          'offerToReceiveAudio': 1, 
          'offerToReceiveVideo': 1
        });
        await _pc!.setLocalDescription(answer);
        onLog('✅ Local answer set. Waiting for ICE gathering...');
        
        await _waitForIceGathering();
        await _generatePairCode();
      } else if (reply) {
        onLog('ℹ️ Received ${sdp.type}, no need to create answer');
      }
      return true;
    } catch (e) {
      onLog('❌ Consume code failed: $e');
      onLog('💡 建议：检查网络连接或重新尝试');
      return false;
    }
  }

  /// 仅设置远端描述
  Future<bool> setRemoteOnly(String shortCode) async {
    if (_pc == null) return false;
    
    if (shortCode.length != 6) {
      onLog('❌ Invalid short code length: ${shortCode.length}');
      return false;
    }
    
    onLog('🔄 Setting remote description only...');
    final data = await _fetchPairData(shortCode);
    if (data == null) {
      onLog('❌ Failed to fetch data for code: $shortCode');
      return false;
    }
    
    try {
      final sdp = RTCSessionDescription(data['sdp'] as String, data['type'] as String);
      await _pc!.setRemoteDescription(sdp);
      onLog('✅ Set remote description: type=${sdp.type}, sdpLen=${(sdp.sdp ?? '').length}');
      
      final List<dynamic> cands = (data['candidates'] as List<dynamic>? ?? <dynamic>[]);
      for (final c in cands) {
        try {
          await _pc!.addCandidate(RTCIceCandidate(
            (c as Map<String, dynamic>)['candidate'] as String?,
            c['sdpMid'] as String?,
            c['sdpMLineIndex'] as int?,
          ));
        } catch (e) {
          onLog('⚠️ Failed to add candidate: $e');
        }
      }
      onLog('✅ Added remote candidates: count=${cands.length}');
      onLog('✅ Remote setup completed. Waiting for connection...');
      return true;
    } catch (e) {
      onLog('❌ Set remote only failed: $e');
      return false;
    }
  }

  /// 获取配对数据
  Future<Map<String, dynamic>?> _fetchPairData(String shortCode) async {
    try {
      final response = await HttpClient.instance.post(
        path: '/api/sync/tmp/get',
        data: {'key': shortCode},
      );
      
      if (response.ok && response.data != null) {
        final value = response.data['data'] as String?;
        if (value != null) {
          final data = jsonDecode(value) as Map<String, dynamic>;
          onLog('Fetched pair data for code: $shortCode');
          return data;
        }
      }
      onLog('Failed to fetch pair data: ${response.message}');
      return null;
    } catch (e) {
      onLog('Fetch pair data error: $e');
      return null;
    }
  }

  /// 测试TURN服务器
  Future<void> testTurnServer({
    required String ip,
    required String port,
    required String user,
    required String pass,
    required String realm,
  }) async {
    if (ip.isEmpty || port.isEmpty) {
      onLog('TURN IP or Port is empty');
      return;
    }
    
    onLog('Testing TURN server: $ip:$port');
    onLog('Username: ${user.isEmpty ? "empty" : user}');
    onLog('Password: ${pass.isEmpty ? "empty" : pass}');
    onLog('Realm: ${realm.isEmpty ? "empty" : realm}');
    
    try {
      final testConfig = {
        'sdpSemantics': 'unified-plan',
        'iceServers': [
          if (user.isNotEmpty && pass.isNotEmpty) {
            'urls': 'turn:$ip:$port',
            'username': user,
            'credential': pass,
            'realm': realm.isNotEmpty ? realm : null,
          } else {
            'urls': 'turn:$ip:$port'
          },
        ],
      };
      
      onLog('Test config: ${jsonEncode(testConfig)}');
      
      final testPc = await createPeerConnection(testConfig, {});
      
      testPc.onIceCandidate = (candidate) {
        final candidateStr = candidate.candidate ?? '';
        if (candidateStr.contains('typ relay')) {
          onLog('✅ TURN test SUCCESS: relay candidate received');
        } else if (candidateStr.contains('typ srflx')) {
          onLog('ℹ️ STUN working: srflx candidate received');
        } else if (candidateStr.contains('typ host')) {
          onLog('ℹ️ Local candidate: host candidate received');
        }
      };
      
      testPc.onIceGatheringState = (state) {
        onLog('TURN test ICE gathering state: $state');
      };
      
      testPc.onIceConnectionState = (state) {
        onLog('TURN test ICE connection state: $state');
      };
      
      final offer = await testPc.createOffer({});
      await testPc.setLocalDescription(offer);
      
      await Future.delayed(const Duration(seconds: 3));
      
      await testPc.close();
      onLog('TURN test completed');
      
    } catch (e) {
      onLog('❌ TURN test FAILED: $e');
    }
  }

  /// 切换麦克风状态
  void toggleMic(bool enabled) {
    for (final t in _localStream?.getAudioTracks() ?? []) {
      t.enabled = enabled;
    }
    onLog('Mic ${enabled ? 'enabled' : 'disabled'}');
  }

  /// 切换摄像头状态
  void toggleCam(bool enabled) {
    for (final t in _localStream?.getVideoTracks() ?? []) {
      t.enabled = enabled;
    }
    onLog('Cam ${enabled ? 'enabled' : 'disabled'}');
  }

  /// 检查视频状态
  void checkVideoStatus() {
    if (_localStream == null) {
      onLog('❌ 本地视频流未初始化');
      return;
    }

    final videoTrack = _localStream!.getVideoTracks().first;
    final audioTrack = _localStream!.getAudioTracks().first;

    onLog('🔄 检查视频状态...');
    onLog('视频轨道状态: ${videoTrack.enabled}');
    onLog('音频轨道状态: ${audioTrack.enabled}');

    if (videoTrack.enabled) {
      onLog('✅ 视频已启用');
    } else {
      onLog('❌ 视频已禁用');
    }
    if (audioTrack.enabled) {
      onLog('✅ 音频已启用');
    } else {
      onLog('❌ 音频已禁用');
    }
  }

  /// 清理资源
  Future<void> dispose() async {
    _localCandidates.clear();
    _iceGatheringComplete = false;
    onLog('Disposing peer...');
    await _pc?.close();
    _pc = null;
    _localStream?.getTracks().forEach((t) => t.stop());
    _localStream = null;
  }
}
