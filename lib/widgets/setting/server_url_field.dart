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
  bool _serverValid = false;

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
    });

    try {
      final isValid = await _checkServer(serverUrl);
      setState(() {
        _serverValid = isValid;
      });
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        prefixIcon: Icons.computer,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isChecking)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                _serverValid ? Icons.check_circle : Icons.error,
                color: _serverValid ? Colors.green : Colors.red,
              ),
            IconButton(
              onPressed: _isChecking ? null : _handleCheckServer,
              icon: const Icon(Icons.refresh),
              tooltip: L10nManager.l10n.checkServer,
            ),
          ],
        ),
        required: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return L10nManager.l10n.pleaseInput(L10nManager.l10n.serverAddress);
          }
          return null;
        },
        onChanged: (value) {
          if (_serverValid) {
            setState(() {
              _serverValid = false;
            });
          }
        },
      ),
    );
  }
}
