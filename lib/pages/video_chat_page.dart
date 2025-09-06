import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../manager/app_config_manager.dart';
import '../manager/l10n_manager.dart';
import '../models/dto/webrtc_config_dto.dart';
import '../services/webrtc_service.dart';
import '../widgets/webrtc/turn_server_config_dialog.dart';
import '../widgets/webrtc/video_renderer_widget.dart';
import '../widgets/webrtc/pair_code_operations.dart';
import '../widgets/webrtc/simple_room_operations.dart';

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
  final TextEditingController _roomCodeController = TextEditingController();

  // WebRTC配置
  late WebRTCConfigDTO _webrtcConfig;

  // WebRTC连接管理器
  late WebRTCService _connectionManager;
  
  // 状态变量
  bool _iceGatheringComplete = false;
  RTCIceConnectionState _iceConnectionState = RTCIceConnectionState.RTCIceConnectionStateNew;
  bool _isConnecting = false;
  bool _micOn = true;
  bool _camOn = true;
  bool _showLocalVideo = true;
  bool _showRemoteVideo = true;
  bool _isInitiator = false; // 是否为发起方
  bool _isJoiner = false; // 是否为加入方
  bool _isVideoControlExpanded = true; // 视频控制面板是否展开
  bool _isConnectionOperationsExpanded = true; // 连接操作面板是否展开
  bool _useSimpleMode = true; // 是否使用简化模式
  bool _isWaitingForAnswer = false; // 是否在等待Answer

  // 简化的日志方法，仅用于关键信息
  void _log(String message) {
    debugPrint(message);
  }

  @override
  void initState() {
    super.initState();
    // 从AppConfigManager获取WebRTC配置
    _webrtcConfig = AppConfigManager.instance.webrtcConfig;
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
          
          // 当连接断开时，重置发起方/加入方状态
          if (state == RTCIceConnectionState.RTCIceConnectionStateFailed ||
              state == RTCIceConnectionState.RTCIceConnectionStateDisconnected ||
              state == RTCIceConnectionState.RTCIceConnectionStateNew) {
            _isInitiator = false;
            _isJoiner = false;
          }
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
      turnIp: _webrtcConfig.turnIp,
      turnPort: _webrtcConfig.turnPort,
      turnUser: _webrtcConfig.turnUser,
      turnPass: _webrtcConfig.turnPass,
      turnRealm: _webrtcConfig.turnRealm,
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
        initialConfig: _webrtcConfig,
        onApply: (config) {
          setState(() {
            _webrtcConfig = config;
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

  // 创建房间（简化版）
  Future<void> _createRoom() async {
    final roomCode = await _connectionManager.createRoom();
    if (roomCode != null) {
      _roomCodeController.text = roomCode;
      await Clipboard.setData(ClipboardData(text: roomCode));
      setState(() {
        _isInitiator = true;
        _isJoiner = false;
        _isWaitingForAnswer = true;
      });
    }
  }

  // 发起连接（保留原方法以兼容）
  Future<void> _createOffer() async {
    return await _createRoom();
  }

  // 加入房间（简化版）
  Future<void> _joinRoom() async {
    final roomCode = _roomCodeController.text.trim();
    if (roomCode.isNotEmpty) {
      await _connectionManager.joinRoom(roomCode);
      setState(() {
        _isJoiner = true;
        _isInitiator = false;
        _isWaitingForAnswer = false;
      });
    }
  }

  // 加入连接（保留原方法以兼容）
  Future<void> _join() async {
    return await _joinRoom();
  }

  // 仅设置远端
  Future<void> _setRemoteOnly() async {
    final shortCode = _sdpController.text.trim();
    if (shortCode.isNotEmpty) {
      await _connectionManager.setRemoteOnly(shortCode);
      setState(() {
        _isJoiner = false;
        _isInitiator = false;
      });
    }
  }

  // 清除房间码和状态
  void _clearRoomCode() {
    setState(() {
      _roomCodeController.clear();
      _sdpController.clear();
      _isInitiator = false;
      _isJoiner = false;
    });
  }

  // 清除配对码和状态（保留原方法以兼容）
  void _clearPairingCode() {
    _clearRoomCode();
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

  // 获取连接状态图标
  IconData _getConnectionStatusIcon() {
    switch (_iceConnectionState) {
      case RTCIceConnectionState.RTCIceConnectionStateConnected:
      case RTCIceConnectionState.RTCIceConnectionStateCompleted:
        return Icons.check_circle;
      case RTCIceConnectionState.RTCIceConnectionStateChecking:
        return Icons.hourglass_empty;
      case RTCIceConnectionState.RTCIceConnectionStateFailed:
      case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
        return Icons.cancel;
      default:
        return Icons.signal_wifi_off;
    }
  }

  @override
  void dispose() {
    // 确保在页面关闭前断开WebRTC连接
    _log('🔄 正在关闭WebRTC连接...');
    // 先停止本地媒体流
    if (_connectionManager.localStream != null) {
      for (final track in _connectionManager.localStream!.getTracks()) {
        track.stop();
      }
    }
    // 异步释放资源，但不等待完成
    _connectionManager.dispose().then((_) {
      _log('✅ WebRTC连接已关闭');
    });
    
    // 释放其他资源
    _sdpController.dispose();
    _roomCodeController.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = L10nManager.l10n;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Chat (WebRTC)'),
        backgroundColor: colorScheme.surfaceContainerHighest,
        elevation: 0,
        actions: [
          // 模式切换按钮
          IconButton(
            onPressed: () => setState(() => _useSimpleMode = !_useSimpleMode),
            icon: Icon(
              _useSimpleMode ? Icons.tune : Icons.smart_toy,
              color: colorScheme.primary,
            ),
            tooltip: _useSimpleMode ? '切换到高级模式' : '切换到简化模式',
          ),
          const SizedBox(width: 8),
          // 连接状态指示器
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getConnectionStatusColor(),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getConnectionStatusIcon(),
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  _getConnectionStatusText(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // TURN服务器配置图标 - 使用主题色图标，无边框
          IconButton(
            onPressed: _showTurnServerConfig,
            icon: Icon(
              Icons.settings,
              color: colorScheme.primary,
            ),
            tooltip: 'TURN服务器配置',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // 视频显示区域 - 占据主要空间
            Expanded(
              flex: 4, // 进一步增加视频区域的比例
              child: Row(
                children: [
                  if (_showLocalVideo)
                    Expanded(
                      child: VideoRendererWidget(
                        renderer: _localRenderer,
                        label: '本地',
                        isLocal: true,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  if (_showLocalVideo && _showRemoteVideo) const SizedBox(width: 12),
                  if (_showRemoteVideo)
                    Expanded(
                      child: VideoRendererWidget(
                        renderer: _remoteRenderer,
                        label: '远端',
                        isLocal: false,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // 连接操作区域 - 可折叠
            Card(
              elevation: 0,
              color: colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  // 可点击的标题栏
                  InkWell(
                    onTap: () => setState(() => _isConnectionOperationsExpanded = !_isConnectionOperationsExpanded),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            _useSimpleMode ? Icons.meeting_room : Icons.link,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _useSimpleMode ? '房间操作' : '连接操作',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            _isConnectionOperationsExpanded ? Icons.expand_less : Icons.expand_more,
                            color: colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 可折叠的内容
                  if (_isConnectionOperationsExpanded)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: _useSimpleMode 
                        ? SimpleRoomOperations(
                            roomCodeController: _roomCodeController,
                            isConnecting: _isConnecting || _isWaitingForAnswer,
                            showReconnectButton: _iceConnectionState == RTCIceConnectionState.RTCIceConnectionStateFailed ||
                                                _iceConnectionState == RTCIceConnectionState.RTCIceConnectionStateDisconnected,
                            hasConnection: _iceConnectionState == RTCIceConnectionState.RTCIceConnectionStateConnected ||
                                         _iceConnectionState == RTCIceConnectionState.RTCIceConnectionStateCompleted,
                            onCreateRoom: _createRoom,
                            onJoinRoom: _joinRoom,
                            onReconnect: _reconnect,
                            onClearCode: _clearRoomCode,
                            isWaitingForAnswer: _isWaitingForAnswer,
                          )
                        : PairCodeOperations(
                            sdpController: _sdpController,
                            iceGatheringComplete: _iceGatheringComplete,
                            isConnecting: _isConnecting,
                            showReconnectButton: _iceConnectionState == RTCIceConnectionState.RTCIceConnectionStateFailed ||
                                                _iceConnectionState == RTCIceConnectionState.RTCIceConnectionStateDisconnected,
                            isInitiator: _isInitiator,
                            isJoiner: _isJoiner,
                            hasConnection: _iceConnectionState == RTCIceConnectionState.RTCIceConnectionStateConnected ||
                                         _iceConnectionState == RTCIceConnectionState.RTCIceConnectionStateCompleted,
                            onCreateOffer: _createOffer,
                            onJoin: _join,
                            onSetRemoteOnly: _setRemoteOnly,
                            onReconnect: _reconnect,
                            onClearCode: _clearPairingCode,
                          ),
                    ),
                ],
              ),
            ),
            
            // 生成的房间码展示（可点击复制）
            if ((_useSimpleMode ? _roomCodeController.text : _sdpController.text).isNotEmpty)
              Card(
                elevation: 0,
                color: colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    final code = _useSimpleMode ? _roomCodeController.text : _sdpController.text;
                    await Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.linkCopied)),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(
                          _useSimpleMode ? Icons.meeting_room : Icons.qr_code_2,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _useSimpleMode ? '房间码' : '配对码',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _useSimpleMode ? _roomCodeController.text : _sdpController.text,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'monospace',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () async {
                            final code = _useSimpleMode ? _roomCodeController.text : _sdpController.text;
                            await Clipboard.setData(ClipboardData(text: code));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.linkCopied)),
                            );
                          },
                          icon: const Icon(Icons.copy_all),
                          tooltip: l10n.copyLink,
                          style: IconButton.styleFrom(
                            backgroundColor: colorScheme.primaryContainer,
                            foregroundColor: colorScheme.onPrimaryContainer,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            
            // 合并的控制面板 - 可折叠
            Card(
              elevation: 0,
              color: colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  // 可点击的标题栏
                  InkWell(
                    onTap: () => setState(() => _isVideoControlExpanded = !_isVideoControlExpanded),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.control_camera,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '视频控制',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            _isVideoControlExpanded ? Icons.expand_less : Icons.expand_more,
                            color: colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 可折叠的内容
                  if (_isVideoControlExpanded)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // 麦克风控制
                          Column(
                            children: [
                              IconButton.filled(
                                onPressed: _toggleMic,
                                icon: Icon(_micOn ? Icons.mic : Icons.mic_off),
                                tooltip: _micOn ? '关闭麦克风' : '开启麦克风',
                              ),
                              const SizedBox(height: 4),
                              Text('麦克风', style: theme.textTheme.bodySmall),
                            ],
                          ),
                          
                          // 摄像头控制
                          Column(
                            children: [
                              IconButton.filled(
                                onPressed: _toggleCam,
                                icon: Icon(_camOn ? Icons.videocam : Icons.videocam_off),
                                tooltip: _camOn ? '关闭摄像头' : '开启摄像头',
                              ),
                              const SizedBox(height: 4),
                              Text('摄像头', style: theme.textTheme.bodySmall),
                            ],
                          ),
                          
                          // 本地视频显示控制
                          Column(
                            children: [
                              IconButton.filled(
                                onPressed: () => setState(() => _showLocalVideo = !_showLocalVideo),
                                icon: Icon(_showLocalVideo ? Icons.visibility : Icons.visibility_off),
                                tooltip: _showLocalVideo ? '隐藏本地视频' : '显示本地视频',
                              ),
                              const SizedBox(height: 4),
                              Text('本地视频', style: theme.textTheme.bodySmall),
                            ],
                          ),
                          
                          // 远端视频显示控制
                          Column(
                            children: [
                              IconButton.filled(
                                onPressed: () => setState(() => _showRemoteVideo = !_showRemoteVideo),
                                icon: Icon(_showRemoteVideo ? Icons.visibility : Icons.visibility_off),
                                tooltip: _showRemoteVideo ? '隐藏远端视频' : '显示远端视频',
                              ),
                              const SizedBox(height: 4),
                              Text('远端视频', style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
