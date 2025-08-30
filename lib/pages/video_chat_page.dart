import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../services/webrtc_service.dart';
import '../widgets/webrtc/turn_server_config_dialog.dart';
import '../widgets/webrtc/video_renderer_widget.dart';
import '../widgets/webrtc/pair_code_operations.dart';
import '../widgets/webrtc/log_panel.dart';
import '../widgets/webrtc/media_controls.dart';

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
  final TextEditingController _sdpController = TextEditingController();

  // TURN 配置
  final TextEditingController _turnIpCtl = TextEditingController(text: "139.224.41.190");
  final TextEditingController _turnPortCtl = TextEditingController(text: "3478");
  final TextEditingController _turnUserCtl = TextEditingController(text: "webrtc");
  final TextEditingController _turnPassCtl = TextEditingController(text: "Cuiwei@123.com");
  final TextEditingController _turnRealmCtl = TextEditingController(text: "clssw");

  // WebRTC连接管理器
  late WebRTCService _connectionManager;
  
  // 状态变量
  bool _iceGatheringComplete = false;
  RTCIceConnectionState _iceConnectionState = RTCIceConnectionState.RTCIceConnectionStateNew;
  bool _isConnecting = false;
  bool _micOn = true;
  bool _camOn = true;

  // 日志
  final List<String> _logs = <String>[];
  void _log(String message) {
    final ts = DateTime.now().toIso8601String().substring(11, 19);
    final line = '[$ts] $message';
    if (_logs.length > 200) _logs.removeAt(0);
    _logs.add(line);
    debugPrint(line);
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _initConnectionManager();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void _initConnectionManager() {
    _connectionManager = WebRTCService(
      onLog: _log,
      onIceConnectionStateChanged: (state) {
        setState(() {
          _iceConnectionState = state;
          _isConnecting = state == RTCIceConnectionState.RTCIceConnectionStateChecking;
        });
      },
      onConnectionStateChanged: (state) {
        // 可以添加连接状态处理
      },
      onSignalingStateChanged: (state) {
        // 可以添加信令状态处理
      },
      onRemoteStreamReceived: (stream) {
        _remoteRenderer.srcObject = stream;
        setState(() {});
      },
      onIceGatheringStateChanged: (complete) {
        setState(() {
          _iceGatheringComplete = complete;
        });
      },
    );

    _createPeer();
  }

  Future<void> _createPeer() async {
    await _connectionManager.createPeer(
      turnIp: _turnIpCtl.text,
      turnPort: _turnPortCtl.text,
      turnUser: _turnUserCtl.text,
      turnPass: _turnPassCtl.text,
      turnRealm: _turnRealmCtl.text,
    );
    
    // 设置本地视频流
    if (_connectionManager.localStream != null) {
      _localRenderer.srcObject = _connectionManager.localStream;
      setState(() {});
    }
  }

  // 显示TURN服务器配置对话框
  void _showTurnServerConfig() {
    showDialog(
      context: context,
      builder: (context) => TurnServerConfigDialog(
        initialIp: _turnIpCtl.text,
        initialPort: _turnPortCtl.text,
        initialUser: _turnUserCtl.text,
        initialPass: _turnPassCtl.text,
        initialRealm: _turnRealmCtl.text,
        onApply: (ip, port, user, pass, realm) {
          setState(() {
            _turnIpCtl.text = ip;
            _turnPortCtl.text = port;
            _turnUserCtl.text = user;
            _turnPassCtl.text = pass;
            _turnRealmCtl.text = realm;
          });
          _log('✅ TURN服务器配置已更新');
          _log('🔄 正在应用新配置...');
          _recreatePeerWithConfig();
        },
      ),
    );
  }

  Future<void> _recreatePeerWithConfig() async {
    await _connectionManager.dispose();
    await _createPeer();
  }

  // 重连功能
  Future<void> _reconnect() async {
    _log('🔄 Attempting to reconnect...');
    await _recreatePeerWithConfig();
    _log('✅ Reconnection completed');
  }

  // 发起连接
  Future<void> _createOffer() async {
    final shortCode = await _connectionManager.createOffer();
    if (shortCode != null) {
      _sdpController.text = shortCode;
      await Clipboard.setData(ClipboardData(text: shortCode));
      setState(() {});
    }
  }

  // 加入连接
  Future<void> _join() async {
    final shortCode = _sdpController.text.trim();
    if (shortCode.isNotEmpty) {
      await _connectionManager.consumePairCodeAndReply(shortCode, reply: true);
    }
  }

  // 仅设置远端
  Future<void> _setRemoteOnly() async {
    final shortCode = _sdpController.text.trim();
    if (shortCode.isNotEmpty) {
      await _connectionManager.setRemoteOnly(shortCode);
    }
  }

  // 测试TURN服务器
  Future<void> _testTurnServer() async {
    await _connectionManager.testTurnServer(
      ip: _turnIpCtl.text,
      port: _turnPortCtl.text,
      user: _turnUserCtl.text,
      pass: _turnPassCtl.text,
      realm: _turnRealmCtl.text,
    );
  }

  // 检查视频状态
  void _checkVideoStatus() {
    _connectionManager.checkVideoStatus();
  }

  // 切换麦克风
  void _toggleMic() {
    _micOn = !_micOn;
    _connectionManager.toggleMic(_micOn);
    setState(() {});
  }

  // 切换摄像头
  void _toggleCam() {
    _camOn = !_camOn;
    _connectionManager.toggleCam(_camOn);
    setState(() {});
  }

  // 获取连接状态颜色
  Color _getConnectionStatusColor() {
    switch (_iceConnectionState) {
      case RTCIceConnectionState.RTCIceConnectionStateConnected:
      case RTCIceConnectionState.RTCIceConnectionStateCompleted:
        return Colors.green;
      case RTCIceConnectionState.RTCIceConnectionStateChecking:
        return Colors.orange;
      case RTCIceConnectionState.RTCIceConnectionStateFailed:
      case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // 获取连接状态文本
  String _getConnectionStatusText() {
    switch (_iceConnectionState) {
      case RTCIceConnectionState.RTCIceConnectionStateConnected:
        return '已连接';
      case RTCIceConnectionState.RTCIceConnectionStateCompleted:
        return '连接完成';
      case RTCIceConnectionState.RTCIceConnectionStateChecking:
        return '连接中';
      case RTCIceConnectionState.RTCIceConnectionStateFailed:
        return '连接失败';
      case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
        return '已断开';
      default:
        return '未连接';
    }
  }

  @override
  void dispose() {
    _connectionManager.dispose();
    _sdpController.dispose();
    _turnIpCtl.dispose();
    _turnPortCtl.dispose();
    _turnUserCtl.dispose();
    _turnPassCtl.dispose();
    _turnRealmCtl.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Chat (WebRTC)'),
        actions: [
          // 连接状态指示器
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _getConnectionStatusColor(),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _getConnectionStatusText(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // TURN服务器配置图标
          IconButton(
            onPressed: _showTurnServerConfig,
            icon: const Icon(Icons.settings),
            tooltip: 'TURN服务器配置',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 视频显示区域
            Expanded(
              child: VideoDisplayArea(
                localRenderer: _localRenderer,
                remoteRenderer: _remoteRenderer,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 12),
            
            // 配对码操作区域
            PairCodeOperations(
              sdpController: _sdpController,
              iceGatheringComplete: _iceGatheringComplete,
              isConnecting: _isConnecting,
              showReconnectButton: _iceConnectionState == RTCIceConnectionState.RTCIceConnectionStateFailed ||
                                  _iceConnectionState == RTCIceConnectionState.RTCIceConnectionStateDisconnected,
              onCreateOffer: _createOffer,
              onJoin: _join,
              onSetRemoteOnly: _setRemoteOnly,
              onTestTurn: _testTurnServer,
              onCheckVideoStatus: _checkVideoStatus,
              onReconnect: _reconnect,
            ),
            const SizedBox(height: 12),
            
            // 日志面板
            LogPanel(
              logs: _logs,
              onClear: () {
                _logs.clear();
                setState(() {});
              },
              title: '连接日志',
            ),
            const SizedBox(height: 12),
            
            // 媒体控制
            MediaControls(
              micOn: _micOn,
              camOn: _camOn,
              onToggleMic: _toggleMic,
              onToggleCam: _toggleCam,
            ),
          ],
        ),
      ),
    );
  }
}
