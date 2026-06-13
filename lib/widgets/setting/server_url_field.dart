import 'package:flutter/material.dart';
import '../../manager/l10n_manager.dart';
import '../../services/health_service.dart';
import '../common/common_text_form_field.dart';

class ServerUrlField extends StatefulWidget {
  final TextEditingController controller;

  const ServerUrlField({
    super.key,
    required this.controller,
  });

  @override
  State<ServerUrlField> createState() => _ServerUrlFieldState();
}

class _ServerUrlFieldState extends State<ServerUrlField> {
  bool _isChecking = false;
  bool? _serverValid;

  Future<bool> _checkServer(String serverUrl) async {
    final healthService = HealthService(serverUrl);
    final result = await healthService.checkHealth();
    return result.ok;
  }

  Future<void> _handleCheckServer() async {
    final serverUrl = widget.controller.text.trim();
    if (serverUrl.isEmpty) return;

    setState(() {
      _isChecking = true;
      _serverValid = null;
    });

    try {
      final isValid = await _checkServer(serverUrl);
      if (mounted) {
        setState(() {
          _serverValid = isValid;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  Widget _buildPrefixIcon(ColorScheme colorScheme) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _serverValid == true
          ? Icon(Icons.link_rounded,
              key: const ValueKey('success'),
              color: Colors.green,
              size: 22)
          : _serverValid == false
              ? Icon(Icons.link_off_rounded,
                  key: const ValueKey('error'),
                  color: colorScheme.error,
                  size: 22)
              : Icon(Icons.link_off_rounded,
                  key: const ValueKey('idle'),
                  color: colorScheme.onSurfaceVariant.withAlpha(80),
                  size: 22),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final checkServer = L10nManager.l10n.checkServer;

    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          _handleCheckServer();
        }
      },
      child: CommonTextFormField(
        controller: widget.controller,
        labelText: L10nManager.l10n.serverAddress,
        hintText: 'http://192.168.2.1:3000',
        prefixIcon: _buildPrefixIcon(colorScheme),
        suffixIcon: Tooltip(
          message: checkServer,
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: _isChecking ? null : _handleCheckServer,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: _isChecking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : Icon(
                      Icons.refresh_rounded,
                      size: 20,
                      color: _serverValid == true
                          ? Colors.green
                          : colorScheme.onSurfaceVariant,
                    ),
            ),
          ),
        ),
        required: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return L10nManager.l10n.pleaseInput(L10nManager.l10n.serverAddress);
          }
          return null;
        },
        onChanged: (value) {
          if (_serverValid != null) {
            setState(() {
              _serverValid = null;
            });
          }
        },
      ),
    );
  }
}
