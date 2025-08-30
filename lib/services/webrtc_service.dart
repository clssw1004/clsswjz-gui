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
      onLog('🎯 onTrack事件触发: kind=${event.track.kind}, id=${event.track.id}');
      onLog('🎯 远端轨道数量: ${event.streams.length}');
      
      if (event.streams.isNotEmpty) {
        final stream = event.streams.first;
        onLog('🎯 远端流ID: ${stream.id}');
        onLog('🎯 远端流轨道数量: ${stream.getTracks().length}');
        
        // 检查视频轨道状态
        final videoTracks = stream.getVideoTracks();
        final audioTracks = stream.getAudioTracks();
        
        onLog('🎯 远端视频轨道: ${videoTracks.length} 个');
        onLog('🎯 远端音频轨道: ${audioTracks.length} 个');
        
        for (int i = 0; i < videoTracks.length; i++) {
          final track = videoTracks[i];
          onLog('🎯 远端视频轨道 $i: enabled=${track.enabled}, muted=${track.muted}, id=${track.id}');
          
          // 确保视频轨道启用
          if (!track.enabled) {
            onLog('⚠️ 远端视频轨道被禁用，尝试启用...');
            track.enabled = true;
          }
        }
        
        for (int i = 0; i < audioTracks.length; i++) {
          final track = audioTracks[i];
          onLog('🎯 远端音频轨道 $i: enabled=${track.enabled}, muted=${track.muted}, id=${track.id}');
        }
        
        onLog('✅ 远端流准备就绪，通知UI层');
        onLog('💡 重要：确保UI层正确设置 remoteRenderer.srcObject = stream');
        onRemoteStreamReceived(stream);
      } else {
        onLog('⚠️ onTrack事件触发但流为空');
        onLog('💡 这可能是正常的，某些情况下轨道可能没有关联的流');
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
      onLog('🎥 正在获取摄像头和麦克风权限...');
      
      final mediaConstraints = {
        'audio': true,
        'video': {
          'facingMode': 'user',
          'width': {'ideal': 1280},
          'height': {'ideal': 720},
          'frameRate': {'ideal': 30},
        },
      };
      
      onLog('📱 媒体约束: ${jsonEncode(mediaConstraints)}');
      
      final stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localStream = stream;
      
      onLog('✅ 成功获取媒体流: ${stream.id}');
      
      // 检查轨道数量
      final videoTracks = _localStream!.getVideoTracks();
      final audioTracks = _localStream!.getAudioTracks();
      
      onLog('📹 视频轨道数量: ${videoTracks.length}');
      onLog('🎤 音频轨道数量: ${audioTracks.length}');
      
      if (videoTracks.isEmpty) {
        onLog('❌ 警告：没有获取到视频轨道！');
        onLog('💡 可能原因：摄像头权限被拒绝或设备没有摄像头');
      }
      
      if (audioTracks.isEmpty) {
        onLog('❌ 警告：没有获取到音频轨道！');
        onLog('💡 可能原因：麦克风权限被拒绝或设备没有麦克风');
      }
      
      // 使用addTrack而不是addTransceiver，确保轨道正确添加
      for (final videoTrack in videoTracks) {
        onLog('➕ 添加视频轨道: ${videoTrack.id}, enabled=${videoTrack.enabled}');
        await _pc?.addTrack(videoTrack, _localStream!);
      }
      
      for (final audioTrack in audioTracks) {
        onLog('➕ 添加音频轨道: ${audioTrack.id}, enabled=${audioTrack.enabled}');
        await _pc?.addTrack(audioTrack, _localStream!);
      }
      
      onLog('✅ 本地媒体轨道添加完成');
      
      // 检查当前PeerConnection的轨道数量
      try {
        final transceivers = await _pc?.getTransceivers();
        onLog('📊 当前PeerConnection轨道数量: ${transceivers?.length ?? 0}');
        
        if (transceivers != null) {
          for (int i = 0; i < transceivers.length; i++) {
            final transceiver = transceivers[i];
            onLog('  轨道 $i: kind=${transceiver.receiver.track?.kind}, mid=${transceiver.mid}');
          }
        }
      } catch (e) {
        onLog('⚠️ 无法获取轨道信息: $e');
      }
      
    } catch (e) {
      onLog('❌ Failed to open camera/mic: $e');
      onLog('💡 请检查摄像头和麦克风权限');
      onLog('💡 Android: 检查AndroidManifest.xml中的CAMERA、RECORD_AUDIO权限');
      onLog('💡 iOS: 检查Info.plist中的NSCameraUsageDescription、NSMicrophoneUsageDescription');
    }
  }

  /// 创建Offer
  Future<String?> createOffer() async {
    if (_pc == null) return null;
    
    onLog('🔄 Creating offer...');
    _localCandidates.clear();
    _iceGatheringComplete = false;
    
    try {
      // 检查当前PeerConnection的轨道状态
      try {
        final transceivers = await _pc?.getTransceivers();
        onLog('📊 Offer创建前轨道状态: ${transceivers?.length ?? 0} 个轨道');
        
        if (transceivers != null) {
          for (int i = 0; i < transceivers.length; i++) {
            final transceiver = transceivers[i];
            final track = transceiver.receiver.track;
            onLog('  轨道 $i: kind=${track?.kind}, enabled=${track?.enabled}, mid=${transceiver.mid}');
          }
        }
      } catch (e) {
        onLog('⚠️ 无法获取轨道状态: $e');
      }
      
      final offer = await _pc!.createOffer({
        'offerToReceiveAudio': 1, 
        'offerToReceiveVideo': 1
      });
      
      // 检查SDP内容，确保包含视频轨道
      final sdp = offer.sdp ?? '';
      onLog('📋 SDP Offer内容检查:');
      onLog('  SDP长度: ${sdp.length} 字符');
      
      if (sdp.contains('m=video')) {
        onLog('✅ SDP包含视频轨道 (m=video)');
      } else {
        onLog('❌ SDP缺少视频轨道！');
        onLog('💡 可能原因：视频轨道未正确添加到PeerConnection');
      }
      
      if (sdp.contains('m=audio')) {
        onLog('✅ SDP包含音频轨道 (m=audio)');
      } else {
        onLog('❌ SDP缺少音频轨道！');
      }
      
      // 统计SDP中的轨道数量
      final videoLines = sdp.split('\n').where((line) => line.startsWith('m=video')).length;
      final audioLines = sdp.split('\n').where((line) => line.startsWith('m=audio')).length;
      onLog('  SDP中视频轨道数量: $videoLines');
      onLog('  SDP中音频轨道数量: $audioLines');
      
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

  /// 检查媒体设备权限
  Future<void> checkMediaPermissions() async {
    onLog('🔐 === 媒体设备权限检查 ===');
    
    try {
      // 检查摄像头权限
      onLog('📹 检查摄像头权限...');
      try {
        final videoStream = await navigator.mediaDevices.getUserMedia({'video': true});
        onLog('✅ 摄像头权限正常');
        onLog('  摄像头轨道数量: ${videoStream.getVideoTracks().length}');
        
        // 检查摄像头轨道状态
        for (final track in videoStream.getVideoTracks()) {
          onLog('  轨道ID: ${track.id}, enabled: ${track.enabled}');
        }
        
        // 清理测试流
        videoStream.getTracks().forEach((track) => track.stop());
      } catch (e) {
        onLog('❌ 摄像头权限被拒绝: $e');
        onLog('💡 解决方案：');
        onLog('  Android: 检查AndroidManifest.xml中的<uses-permission android:name="android.permission.CAMERA" />');
        onLog('  iOS: 检查Info.plist中的NSCameraUsageDescription');
        onLog('  应用内: 确保用户已授予摄像头权限');
      }
      
      // 检查麦克风权限
      onLog('🎤 检查麦克风权限...');
      try {
        final audioStream = await navigator.mediaDevices.getUserMedia({'audio': true});
        onLog('✅ 麦克风权限正常');
        onLog('  麦克风轨道数量: ${audioStream.getAudioTracks().length}');
        
        // 检查音频轨道状态
        for (final track in audioStream.getAudioTracks()) {
          onLog('  轨道ID: ${track.id}, enabled: ${track.enabled}');
        }
        
        // 清理测试流
        audioStream.getTracks().forEach((track) => track.stop());
      } catch (e) {
        onLog('❌ 麦克风权限被拒绝: $e');
        onLog('💡 解决方案：');
        onLog('  Android: 检查AndroidManifest.xml中的<uses-permission android:name="android.permission.RECORD_AUDIO" />');
        onLog('  iOS: 检查Info.plist中的NSMicrophoneUsageDescription');
        onLog('  应用内: 确保用户已授予麦克风权限');
      }
      
      // 检查设备列表
      onLog('📱 检查可用设备...');
      try {
        final devices = await navigator.mediaDevices.enumerateDevices();
        final videoDevices = devices.where((d) => d.kind == 'videoinput').toList();
        final audioDevices = devices.where((d) => d.kind == 'audioinput').toList();
        
        onLog('  视频输入设备: ${videoDevices.length} 个');
        for (final device in videoDevices) {
          onLog('    ${device.label.isNotEmpty ? device.label : '未知设备'} (${device.deviceId})');
        }
        
        onLog('  音频输入设备: ${audioDevices.length} 个');
        for (final device in audioDevices) {
          onLog('    ${device.label.isNotEmpty ? device.label : '未知设备'} (${device.deviceId})');
        }
      } catch (e) {
        onLog('⚠️ 无法枚举设备: $e');
      }
      
    } catch (e) {
      onLog('❌ 权限检查失败: $e');
    }
    
    onLog('🔐 === 权限检查完成 ===');
  }

  /// 强制刷新远端流状态
  void forceRefreshRemoteStream() {
    onLog('🔄 强制刷新远端流状态...');
    
    // 检查当前连接状态
    if (_pc == null) {
      onLog('❌ PeerConnection未初始化');
      return;
    }
    
    onLog('🔗 当前连接状态:');
    onLog('  ICE连接: $_iceConnectionState');
    onLog('  对等连接: $_connectionState');
    onLog('  信令状态: $_signalingState');
    
    // 如果连接已建立，尝试重新触发onTrack
    if (_iceConnectionState == RTCIceConnectionState.RTCIceConnectionStateConnected ||
        _iceConnectionState == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
      onLog('✅ 连接已建立，检查是否有远端流...');
      
      // 这里可以添加逻辑来检查是否有远端流
      // 由于onTrack是异步触发的，我们只能记录当前状态
      onLog('💡 建议：检查日志中的onTrack事件信息');
    } else {
      onLog('⚠️ 连接未完全建立，当前状态: $_iceConnectionState');
    }
  }

  /// 检查视频状态
  void checkVideoStatus() {
    onLog('🔍 === 视频状态全面检查 ===');
    
    // 检查本地流
    if (_localStream == null) {
      onLog('❌ 本地视频流未初始化');
    } else {
      final videoTracks = _localStream!.getVideoTracks();
      final audioTracks = _localStream!.getAudioTracks();
      onLog('📹 本地流: ${videoTracks.length} 个视频轨道, ${audioTracks.length} 个音频轨道');

      for (int i = 0; i < videoTracks.length; i++) {
        final track = videoTracks[i];
        onLog('  本地视频轨道 $i: enabled=${track.enabled}, muted=${track.muted}, id=${track.id}');
      }

      for (int i = 0; i < audioTracks.length; i++) {
        final track = audioTracks[i];
        onLog('  本地音频轨道 $i: enabled=${track.enabled}, muted=${track.muted}, id=${track.id}');
      }
    }

    // 检查PeerConnection状态
    if (_pc == null) {
      onLog('❌ PeerConnection未初始化');
    } else {
      onLog('🔗 PeerConnection状态: $_connectionState');
      onLog('🔗 ICE连接状态: $_iceConnectionState');
      onLog('🔗 信令状态: $_signalingState');
      onLog('🔗 ICE收集完成: $_iceGatheringComplete');
      onLog('🔗 ICE候选者数量: ${_localCandidates.length}');
    }

    // 检查远端流（通过回调获取）
    onLog('🔍 请检查日志中的onTrack事件信息');
    onLog('🔍 === 检查完成 ===');
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
