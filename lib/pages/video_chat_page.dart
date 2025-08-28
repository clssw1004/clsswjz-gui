import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../utils/http_client.dart';
import '../models/api_response.dart';

/// 简易 WebRTC 视频聊天页面（演示用）
/// 说明：
/// - 该示例提供本地/远端视频渲染与基础的 Offer/Answer 交换
/// - 使用超短配对码（6字符）+ 服务器存储，支持复制/粘贴
/// - 支持输入 TURN 服务器（ip、端口、用户名、密码）以提升打洞成功率
class VideoChatPage extends StatefulWidget {
  const VideoChatPage({super.key});

  @override
  State<VideoChatPage> createState() => _VideoChatPageState();
}

class _VideoChatPageState extends State<VideoChatPage> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  RTCPeerConnection? _pc;
  MediaStream? _localStream;
  final TextEditingController _sdpController = TextEditingController();

  // TURN 输入
  final TextEditingController _turnIpCtl = TextEditingController(text: "139.224.41.190");
  final TextEditingController _turnPortCtl = TextEditingController(text: "3478");
  final TextEditingController _turnUserCtl = TextEditingController(text: "clssw");
  final TextEditingController _turnPassCtl = TextEditingController(text: "123456");
  final TextEditingController _turnRealmCtl = TextEditingController(text: "clssw");

  // 聚合 ICE，便于生成配对代码
  final List<RTCIceCandidate> _localCandidates = [];
  bool _iceGatheringComplete = false;

  // 简易日志
  final List<String> _logs = <String>[];
  void _log(String message) {
    final ts = DateTime.now().toIso8601String().substring(11, 19);
    final line = '[$ts] $message';
    // 控制日志长度
    if (_logs.length > 200) _logs.removeAt(0);
    _logs.add(line);
    // 控制台输出
    debugPrint(line);
    if (mounted) setState(() {});
  }

  bool _micOn = true;
  bool _camOn = true;

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _createPeer();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Map<String, dynamic> _buildRtcConfig() {
    final List<Map<String, dynamic>> iceServers = [
      {'urls': 'stun:stun.l.google.com:19302'},
    ];
    final ip = _turnIpCtl.text.trim();
    final port = _turnPortCtl.text.trim();
    final user = _turnUserCtl.text.trim();
    final pass = _turnPassCtl.text.trim();
    final realm = _turnRealmCtl.text.trim();
    
    if (ip.isNotEmpty && port.isNotEmpty) {
      final url = 'turn:$ip:$port';
      _log('Adding TURN server: $url');
      
      if (user.isNotEmpty && pass.isNotEmpty) {
        // 标准用户名认证
        iceServers.add({
          'urls': url, 
          'username': user, 
          'credential': pass,
          'realm': realm.isNotEmpty ? realm : null,
        });
        _log('TURN with auth: username=$user, realm=$realm, credential=${pass.substring(0, 1)}***');
      } else {
        iceServers.add({'urls': url});
        _log('TURN without auth (anonymous)');
      }
    }
    
    final config = {
      'sdpSemantics': 'unified-plan',
      'iceServers': iceServers,
    };
    
    _log('RTC config: ${jsonEncode(config)}');
    return config;
  }

  Future<void> _recreatePeerWithConfig() async {
    _log('Applying TURN and recreating peer...');
    await _disposePeer();
    await _createPeer();
  }

  Future<void> _createPeer() async {
    final Map<String, dynamic> config = _buildRtcConfig();
    final Map<String, dynamic> constraints = {
      'mandatory': {},
      'optional': [
        {'DtlsSrtpKeyAgreement': true},
      ],
    };

    _log('Creating RTCPeerConnection...');
    _pc = await createPeerConnection(config, constraints);

    _pc?.onIceCandidate = (RTCIceCandidate candidate) async {
      _localCandidates.add(candidate);
      final frag = (candidate.candidate ?? '').split(' ').take(4).join(' ');
      _log('ICE candidate gathered: ${frag.isEmpty ? 'empty' : frag}');
    };
    _pc?.onIceGatheringState = (RTCIceGatheringState state) {
      _iceGatheringComplete = state == RTCIceGatheringState.RTCIceGatheringStateComplete;
      _log('ICE gathering state: $state');
      if (_iceGatheringComplete) _log('ICE gathering completed. Total: ${_localCandidates.length}');
      setState(() {});
    };
    _pc?.onIceConnectionState = (RTCIceConnectionState state) {
      _log('ICE connection state: $state');
    };
    _pc?.onConnectionState = (RTCPeerConnectionState state) {
      _log('Peer connection state: $state');
    };
    _pc?.onSignalingState = (RTCSignalingState state) {
      _log('Signaling state: $state');
    };

    _pc?.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        _remoteRenderer.srcObject = event.streams.first;
        _log('Remote track added: kind=${event.track.kind}, stream=${event.streams.first.id}');
        setState(() {});
      }
    };

    await _openCameraAndMic();
  }

  Future<void> _openCameraAndMic() async {
    final Map<String, dynamic> mediaConstraints = {
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

    _localRenderer.srcObject = _localStream;

    // Unified-Plan: 使用 addTransceiver 保持更好兼容性
    final videoTrack = _localStream!.getVideoTracks().first;
    final audioTrack = _localStream!.getAudioTracks().first;
    await _pc?.addTransceiver(track: videoTrack, kind: RTCRtpMediaType.RTCRtpMediaTypeVideo);
    await _pc?.addTransceiver(track: audioTrack, kind: RTCRtpMediaType.RTCRtpMediaTypeAudio);
    _log('Local media started: video+audio');
  }

  // 生成6位超短配对码
  String _generateShortCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
  }

  // 存储配对数据到服务器
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
        _log('Stored pair data with code: $shortCode');
        return shortCode;
      } else {
        _log('Failed to store pair data: ${response.message}');
        return null;
      }
    } catch (e) {
      _log('Store pair data error: $e');
      return null;
    }
  }

  // 从服务器获取配对数据
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
          _log('Fetched pair data for code: $shortCode');
          return data;
        }
      }
      _log('Failed to fetch pair data: ${response.message}');
      return null;
    } catch (e) {
      _log('Fetch pair data error: $e');
      return null;
    }
  }

  // 生成本地"配对代码"：生成6位短码并存储到服务器
  Future<void> _generatePairCode() async {
    if (_pc == null) return;
    final desc = await _pc!.getLocalDescription();
    if (desc == null) return;
    
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
      _sdpController.text = shortCode;
      await Clipboard.setData(ClipboardData(text: shortCode));
      _log('Generated short pair code: $shortCode (${_localCandidates.length} candidates)');
      setState(() {});
    } else {
      _log('Failed to generate pair code');
    }
  }

  // 粘贴对端"配对代码"：从服务器获取数据并设置
  Future<void> _consumePairCodeAndReplyIfNeeded({required bool reply}) async {
    if (_pc == null) return;
    
    final shortCode = _sdpController.text.trim();
    if (shortCode.length != 6) {
      _log('Invalid short code length: ${shortCode.length}');
      return;
    }
    
    final data = await _fetchPairData(shortCode);
    if (data == null) {
      _log('Failed to fetch data for code: $shortCode');
      return;
    }
    
    try {
      final sdp = RTCSessionDescription(data['sdp'] as String, data['type'] as String);
      await _pc!.setRemoteDescription(sdp);
      _log('Set remote description: type=${sdp.type}, sdpLen=${(sdp.sdp ?? '').length}');
      
      final List<dynamic> cands = (data['candidates'] as List<dynamic>? ?? <dynamic>[]);
      for (final c in cands) {
        await _pc!.addCandidate(RTCIceCandidate(
          (c as Map<String, dynamic>)['candidate'] as String?,
          c['sdpMid'] as String?,
          c['sdpMLineIndex'] as int?,
        ));
      }
      _log('Added remote candidates: count=${cands.length}');
      
      if (reply && sdp.type == 'offer') {
        // 只有在收到 offer 时才创建 answer
        final answer = await _pc!.createAnswer({'offerToReceiveAudio': 1, 'offerToReceiveVideo': 1});
        await _pc!.setLocalDescription(answer);
        _log('Created local answer. Gathering ICE...');
        await Future.delayed(const Duration(seconds: 1));
        await _generatePairCode(); // 生成本端的回复代码
      } else if (reply) {
        _log('Received ${sdp.type}, no need to create answer');
      }
    } catch (e) {
      _log('Consume code failed: $e');
    }
  }

  // 仅设置远端描述（用于发起方完成连接）
  Future<void> _setRemoteOnly() async {
    if (_pc == null) return;
    
    final shortCode = _sdpController.text.trim();
    if (shortCode.length != 6) {
      _log('Invalid short code length: ${shortCode.length}');
      return;
    }
    
    final data = await _fetchPairData(shortCode);
    if (data == null) {
      _log('Failed to fetch data for code: $shortCode');
      return;
    }
    
    try {
      final sdp = RTCSessionDescription(data['sdp'] as String, data['type'] as String);
      await _pc!.setRemoteDescription(sdp);
      _log('Set remote description: type=${sdp.type}, sdpLen=${(sdp.sdp ?? '').length}');
      
      final List<dynamic> cands = (data['candidates'] as List<dynamic>? ?? <dynamic>[]);
      for (final c in cands) {
        await _pc!.addCandidate(RTCIceCandidate(
          (c as Map<String, dynamic>)['candidate'] as String?,
          c['sdpMid'] as String?,
          c['sdpMLineIndex'] as int?,
        ));
      }
      _log('Added remote candidates: count=${cands.length}');
    } catch (e) {
      _log('Set remote only failed: $e');
    }
  }

  Future<void> _createOffer() async {
    if (_pc == null) return;
    _localCandidates.clear();
    _iceGatheringComplete = false;
    _log('Creating offer...');
    final offer = await _pc!.createOffer({'offerToReceiveAudio': 1, 'offerToReceiveVideo': 1});
    await _pc!.setLocalDescription(offer);
    _log('Local offer set. Gathering ICE...');
    // 简单等待一小段时间聚合部分 ICE
    await Future.delayed(const Duration(seconds: 1));
    await _generatePairCode();
  }


  Future<void> _toggleMic() async {
    _micOn = !_micOn;
    for (final t in _localStream?.getAudioTracks() ?? []) {
      t.enabled = _micOn;
    }
    _log('Mic ${_micOn ? 'enabled' : 'disabled'}');
    setState(() {});
  }

  Future<void> _toggleCam() async {
    _camOn = !_camOn;
    for (final t in _localStream?.getVideoTracks() ?? []) {
      t.enabled = _camOn;
    }
    _log('Cam ${_camOn ? 'enabled' : 'disabled'}');
    setState(() {});
  }

  Future<void> _disposePeer() async {
    _localCandidates.clear();
    _iceGatheringComplete = false;
    _log('Disposing peer...');
    await _pc?.close();
    _pc = null;
  }

  // 测试 TURN 服务器连接
  Future<void> _testTurnServer() async {
    final ip = _turnIpCtl.text.trim();
    final port = _turnPortCtl.text.trim();
    final user = _turnUserCtl.text.trim();
    final pass = _turnPassCtl.text.trim();
    final realm = _turnRealmCtl.text.trim();
    
    if (ip.isEmpty || port.isEmpty) {
      _log('TURN IP or Port is empty');
      return;
    }
    
    _log('Testing TURN server: $ip:$port');
    _log('Username: ${user.isEmpty ? "empty" : user}');
    _log('Password: ${pass.isEmpty ? "empty" : pass}');
    _log('Realm: ${realm.isEmpty ? "empty" : realm}');
    
    // 创建临时 PeerConnection 来测试 TURN
    try {
      final testConfig = {
        'sdpSemantics': 'unified-plan',
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
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
      
      _log('Test config: ${jsonEncode(testConfig)}');
      
      final testPc = await createPeerConnection(testConfig, {});
      
      testPc.onIceCandidate = (candidate) {
        final candidateStr = candidate.candidate ?? '';
        if (candidateStr.contains('typ relay')) {
          _log('✅ TURN test SUCCESS: relay candidate received');
        } else if (candidateStr.contains('typ srflx')) {
          _log('ℹ️ STUN working: srflx candidate received');
        } else if (candidateStr.contains('typ host')) {
          _log('ℹ️ Local candidate: host candidate received');
        }
      };
      
      testPc.onIceGatheringState = (state) {
        _log('TURN test ICE gathering state: $state');
      };
      
      testPc.onIceConnectionState = (state) {
        _log('TURN test ICE connection state: $state');
      };
      
      // 创建 dummy offer 来触发 ICE gathering
      final offer = await testPc.createOffer({});
      await testPc.setLocalDescription(offer);
      
      // 等待一段时间收集 ICE candidates
      await Future.delayed(const Duration(seconds: 3));
      
      await testPc.close();
      _log('TURN test completed');
      
    } catch (e) {
      _log('❌ TURN test FAILED: $e');
    }
  }

  @override
  void dispose() {
    _sdpController.dispose();
    _turnIpCtl.dispose();
    _turnPortCtl.dispose();
    _turnUserCtl.dispose();
    _turnPassCtl.dispose();
    _turnRealmCtl.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _localStream?.getTracks().forEach((t) => t.stop());
    _pc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Chat (WebRTC)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // TURN 配置
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _turnIpCtl,
                    decoration: const InputDecoration(labelText: 'TURN IP'),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _turnPortCtl,
                    decoration: const InputDecoration(labelText: 'Port'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _turnUserCtl,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _turnPassCtl,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _turnRealmCtl,
                    decoration: const InputDecoration(labelText: 'Realm'),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: _recreatePeerWithConfig,
                  child: const Text('Apply TURN'),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: _testTurnServer,
                  child: const Text('Test TURN'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.outlineVariant.withAlpha(80)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: RTCVideoView(_localRenderer, mirror: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.outlineVariant.withAlpha(80)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: RTCVideoView(_remoteRenderer),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _sdpController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: '输入6位配对码（自动复制到剪贴板）。粘贴对方的配对码到这里。',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withAlpha(24),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    // 简化流程：一键发起/加入
                    FilledButton.tonal(
                      onPressed: _createOffer,
                      child: const Text('发起（生成6位码）'),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.tonal(
                      onPressed: () => _consumePairCodeAndReplyIfNeeded(reply: true),
                      child: const Text('加入（粘贴6位码）'),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.tonal(
                      onPressed: _setRemoteOnly,
                      child: const Text('仅设置远端'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _iceGatheringComplete ? 'ICE 已收集完成' : '收集中 ICE…',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 简易日志面板
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant.withAlpha(80)),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('日志', style: theme.textTheme.titleSmall),
                      ),
                      TextButton(
                        onPressed: () {
                          _logs.clear();
                          if (mounted) setState(() {});
                        },
                        child: const Text('清空'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (_, i) => Text(
                        _logs[i],
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.tonalIcon(
                  onPressed: _toggleMic,
                  icon: Icon(_micOn ? Icons.mic : Icons.mic_off),
                  label: Text(_micOn ? 'Mic On' : 'Mic Off'),
                ),
                const SizedBox(width: 12),
                FilledButton.tonalIcon(
                  onPressed: _toggleCam,
                  icon: Icon(_camOn ? Icons.videocam : Icons.videocam_off),
                  label: Text(_camOn ? 'Cam On' : 'Cam Off'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
