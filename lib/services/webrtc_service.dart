import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'server_cache_service.dart';

/// WebRTC连接管理器
class WebRTCService {
  RTCPeerConnection? _pc;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
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
    };
    
    _pc?.onIceGatheringState = (RTCIceGatheringState state) {
      _iceGatheringComplete = state == RTCIceGatheringState.RTCIceGatheringStateComplete;
      onIceGatheringStateChanged(_iceGatheringComplete);
    };
    
    _pc?.onIceConnectionState = (RTCIceConnectionState state) {
      _iceConnectionState = state;
      onIceConnectionStateChanged(state);
    };
    
    _pc?.onConnectionState = (RTCPeerConnectionState state) {
      _connectionState = state;
      onConnectionStateChanged(state);
    };
    
    _pc?.onSignalingState = (RTCSignalingState state) {
      _signalingState = state;
      onSignalingStateChanged(state);
    };

    _pc?.onTrack = (RTCTrackEvent event) {
      onLog('🎯 onTrack事件触发: kind=${event.track.kind}, id=${event.track.id}');
      onLog('🎯 远端流数量: ${event.streams.length}');

      // If we don't have a stream yet, try to get it from the event.
      if (_remoteStream == null && event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
      }

      // If we have a stream, add the track if it's not already there.
      if (_remoteStream != null) {
        final existingTrackIds = _remoteStream!.getTracks().map((t) => t.id).toSet();
        if (!existingTrackIds.contains(event.track.id)) {
          _remoteStream!.addTrack(event.track);
        }
      }
      // If we still don't have a stream, we can't do anything.
      else {
        return;
      }

      // By now, _remoteStream should be non-null.
      final stream = _remoteStream!;
      
      // 检查视频轨道状态
      final videoTracks = stream.getVideoTracks();
      
      for (int i = 0; i < videoTracks.length; i++) {
        final track = videoTracks[i];
        
        // 确保视频轨道启用
        if (!track.enabled) {
          track.enabled = true;
        }
      }
      
      onRemoteStreamReceived(stream);
    };
  }

  /// 构建RTC配置
  Map<String, dynamic> _buildRtcConfig(String ip, String port, String user, String pass, String realm) {
    final List<Map<String, dynamic>> iceServers = [];
    
    if (ip.isNotEmpty && port.isNotEmpty) {
      final url = 'turn:$ip:$port';
      
      if (user.isNotEmpty && pass.isNotEmpty) {
        iceServers.add({
          'urls': url, 
          'username': user, 
          'credential': pass,
          'realm': realm.isNotEmpty ? realm : null,
        });
      } else {
        iceServers.add({'urls': url});
      }
    } else {
      iceServers.add({'urls': 'stun:stun.l.google.com:19302'});
    }
    
    final config = {
      'sdpSemantics': 'unified-plan',
      'iceServers': iceServers,
      'iceCandidatePoolSize': 10,
      'bundlePolicy': 'max-bundle',
      'rtcpMuxPolicy': 'require',
    };
    
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

  /// 创建房间（真正简化版 - 等待Answer）
  Future<String?> createRoom() async {
    if (_pc == null) return null;
    
    onLog('🔄 创建房间...');
    _localCandidates.clear();
    _iceGatheringComplete = false;
    
    try {
      final offer = await _pc!.createOffer({
        'offerToReceiveAudio': 1, 
        'offerToReceiveVideo': 1
      });
      
      await _pc!.setLocalDescription(offer);
      onLog('✅ 本地Offer已设置，开始ICE收集...');
      
      // 等待ICE收集完成
      await _waitForIceGathering();
      final roomCode = await _generateRoomCode();
      
      if (roomCode != null) {
        // 开始轮询等待Answer
        _startWaitingForAnswer(roomCode);
      }
      
      return roomCode;
    } catch (e) {
      onLog('❌ 创建房间失败: $e');
      return null;
    }
  }

  /// 创建Offer（保留原方法以兼容）
  Future<String?> createOffer() async {
    return await createRoom();
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

  /// 生成房间码字符串
  String _generateRoomCodeString() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
  }

  /// 生成房间码（简化版）
  Future<String?> _generateRoomCode() async {
    if (_pc == null) return null;
    
    final desc = await _pc!.getLocalDescription();
    if (desc == null) {
      onLog('❌ 无法获取本地描述');
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
    
    final roomCode = await _storeRoomData(payload);
    if (roomCode != null) {
      onLog('✅ 房间创建成功: $roomCode (${_localCandidates.length} 个候选者)');
    } else {
      onLog('❌ 房间创建失败');
    }
    return roomCode;
  }


  /// 存储房间数据（简化版）
  Future<String?> _storeRoomData(Map<String, dynamic> data) async {
    try {
      final roomCode = _generateRoomCodeString();
      final success = await ServerCacheService().setData(roomCode, data);
      
      if (success) {
        onLog('房间数据已存储: $roomCode');
        return roomCode;
      } else {
        onLog('房间数据存储失败');
        return null;
      }
    } catch (e) {
      onLog('房间数据存储错误: $e');
      return null;
    }
  }



  /// 加入房间（真正简化版 - 单向连接）
  Future<bool> joinRoom(String roomCode) async {
    if (_pc == null) return false;
    
    if (roomCode.length != 6) {
      onLog('❌ 房间码长度无效: ${roomCode.length}');
      return false;
    }
    
    onLog('🔄 正在加入房间: $roomCode...');
    final data = await ServerCacheService().getData(roomCode);
    if (data == null) {
      onLog('❌ 无法获取房间数据: $roomCode');
      return false;
    }
    
    try {
      final sdp = RTCSessionDescription(data['sdp'] as String, data['type'] as String);
      await _pc!.setRemoteDescription(sdp);
      onLog('✅ 远端描述已设置: type=${sdp.type}');
      
      // 添加ICE候选者
      final List<dynamic> cands = (data['candidates'] as List<dynamic>? ?? <dynamic>[]);
      for (final c in cands) {
        try {
          await _pc!.addCandidate(RTCIceCandidate(
            (c as Map<String, dynamic>)['candidate'] as String?,
            c['sdpMid'] as String?,
            c['sdpMLineIndex'] as int?,
          ));
        } catch (e) {
          onLog('⚠️ 添加候选者失败: $e');
        }
      }
      onLog('✅ 已添加远端候选者: ${cands.length} 个');
      
      // 如果是offer，自动创建answer并存储回房间
      if (sdp.type == 'offer') {
        onLog('🔄 正在创建Answer...');
        final answer = await _pc!.createAnswer({
          'offerToReceiveAudio': 1, 
          'offerToReceiveVideo': 1
        });
        await _pc!.setLocalDescription(answer);
        onLog('✅ 本地Answer已设置，等待ICE收集...');
        
        await _waitForIceGathering();
        
        // 将Answer存储回同一个房间，供发起方获取
        await _storeAnswerToRoom(roomCode, answer);
        onLog('✅ Answer已存储到房间: $roomCode');
      }
      return true;
    } catch (e) {
      onLog('❌ 加入房间失败: $e');
      onLog('💡 建议：检查网络连接或重新尝试');
      return false;
    }
  }

  /// 消费配对码并回复（保留原方法以兼容）
  Future<bool> consumePairCodeAndReply(String shortCode, {required bool reply}) async {
    return await joinRoom(shortCode);
  }

  /// 仅设置远端描述
  Future<bool> setRemoteOnly(String shortCode) async {
    if (_pc == null) return false;
    
    if (shortCode.length != 6) {
      onLog('❌ Invalid short code length: ${shortCode.length}');
      return false;
    }
    
    onLog('🔄 Setting remote description only...');
    final data = await _fetchRoomData(shortCode);
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

  /// 开始等待Answer
  void _startWaitingForAnswer(String roomCode) {
    onLog('🔄 开始等待Answer，房间码: $roomCode');
    _pollForAnswer(roomCode);
  }

  /// 轮询等待Answer
  Future<void> _pollForAnswer(String roomCode) async {
    int attempts = 0;
    const maxAttempts = 60; // 最多等待60秒
    
    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 1));
      attempts++;
      
      try {
        final answerData = await ServerCacheService().getData('${roomCode}_answer');
        if (answerData != null) {
          onLog('✅ 收到Answer，正在建立连接...');
            
            // 设置Answer
            final answer = RTCSessionDescription(answerData['sdp'] as String, answerData['type'] as String);
            await _pc!.setRemoteDescription(answer);
            
            // 添加Answer的ICE候选者
            final List<dynamic> cands = (answerData['candidates'] as List<dynamic>? ?? <dynamic>[]);
            for (final c in cands) {
              try {
                await _pc!.addCandidate(RTCIceCandidate(
                  (c as Map<String, dynamic>)['candidate'] as String?,
                  c['sdpMid'] as String?,
                  c['sdpMLineIndex'] as int?,
                ));
              } catch (e) {
                onLog('⚠️ 添加Answer候选者失败: $e');
              }
            }
            
            onLog('✅ Answer设置完成，连接建立中...');
            return;
          }
        
        if (attempts % 10 == 0) {
          onLog('⏳ 等待Answer中... (${attempts}s)');
        }
      } catch (e) {
        onLog('⚠️ 轮询Answer时出错: $e');
      }
    }
    
    onLog('❌ 等待Answer超时');
  }

  /// 存储Answer到房间
  Future<void> _storeAnswerToRoom(String roomCode, RTCSessionDescription answer) async {
    try {
      final answerData = {
        'sdp': answer.sdp,
        'type': answer.type,
        'candidates': _localCandidates.map((c) => {
          'candidate': c.candidate,
          'sdpMid': c.sdpMid,
          'sdpMLineIndex': c.sdpMLineIndex,
        }).toList(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      final success = await ServerCacheService().setData('${roomCode}_answer', answerData);
      
      if (success) {
        onLog('Answer已存储到房间: ${roomCode}_answer');
      } else {
        onLog('Answer存储失败');
      }
    } catch (e) {
      onLog('Answer存储错误: $e');
    }
  }

  /// 获取房间数据（简化版）
  Future<Map<String, dynamic>?> _fetchRoomData(String roomCode) async {
    try {
      final data = await ServerCacheService().getData(roomCode);
      if (data != null) {
        onLog('已获取房间数据: $roomCode');
        return data;
      } else {
        onLog('获取房间数据失败');
        return null;
      }
    } catch (e) {
      onLog('获取房间数据错误: $e');
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
    onLog('🔐 开始检查媒体设备权限...');
    
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
    
    onLog('✅ 权限检查完成');
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
    onLog('正在释放WebRTC资源...');
    
    // 关闭并清理本地媒体流
    if (_localStream != null) {
      onLog('停止本地媒体流轨道...');
      _localStream!.getTracks().forEach((track) {
        track.stop();
        onLog('已停止轨道: ${track.id}');
      });
      await _localStream!.dispose();
      _localStream = null;
      onLog('本地媒体流已释放');
    }
    
    // 关闭并清理远程媒体流
    if (_remoteStream != null) {
      onLog('释放远程媒体流...');
      _remoteStream!.getTracks().forEach((track) {
        track.stop();
        onLog('已停止远程轨道: ${track.id}');
      });
      await _remoteStream!.dispose();
      _remoteStream = null;
      onLog('远程媒体流已释放');
    }
    
    // 关闭对等连接
    if (_pc != null) {
      onLog('关闭对等连接...');
      await _pc!.close();
      _pc = null;
      onLog('对等连接已关闭');
    }
    
    onLog('所有WebRTC资源已释放');
  }
}
