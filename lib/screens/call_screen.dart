import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../managers/call_manager.dart';
import '../models/language.dart';
import '../providers/settings_provider.dart';
import '../widgets/conversation/call_turn_list.dart';
import '../widgets/conversation/wave_animation.dart';
import '../widgets/microphone_button.dart';

class CallScreen extends StatefulWidget {
  final bool isCreator;
  final String sessionId;
  final String myName;
  final Language myLanguage;
  final Language peerLanguage;

  const CallScreen({
    super.key,
    this.isCreator = true,
    this.sessionId = '',
    required this.myName,
    required this.myLanguage,
    required this.peerLanguage,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late final CallManager _manager;

  @override
  void initState() {
    super.initState();

    _manager = CallManager();
    _manager.addListener(_refresh);

    final speakTranslations =
        context.read<SettingsProvider>().speakTranslations;

    if (widget.isCreator) {
      _manager.startCall(
        myName: widget.myName,
        myLanguage: widget.myLanguage,
        peerLanguage: widget.peerLanguage,
        speakTranslations: speakTranslations,
      );
    } else {
      _manager.joinCall(
        sessionId: widget.sessionId,
        myName: widget.myName,
        myLanguage: widget.myLanguage,
        peerLanguage: widget.peerLanguage,
        speakTranslations: speakTranslations,
      );
    }
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _endCall() async {
    await _manager.endCall();

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _manager.removeListener(_refresh);
    _manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_manager.state == CallConnectionState.error) {
      return _ErrorView(
        message: _manager.error ?? 'Ocurrió un error',
        onRetry: () => Navigator.pop(context),
      );
    }

    if (_manager.isBusy) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Conectando...'),
            ],
          ),
        ),
      );
    }

    if (_manager.state == CallConnectionState.idle) {
      return const Scaffold(
        body: Center(child: Text('Preparando llamada...')),
      );
    }

    final canTalk =
        _manager.isConnected && _manager.peer != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Llamada'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.call_end, color: Colors.red),
            tooltip: 'Colgar',
            onPressed: _endCall,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              peerName: _manager.peerName,
              myLanguage: _manager.myLanguage,
              sessionId: _manager.sessionId,
              peerConnected: _manager.peer != null,
            ),

            _StatusRow(manager: _manager),

            Expanded(
              child: CallTurnList(
                turns: _manager.history,
                myId: _manager.myId,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  IgnorePointer(
                    ignoring: !canTalk,
                    child: WaveAnimation(
                      isListening: _manager.isListening,
                      child: MicrophoneButton(
                        isListening: _manager.isListening,
                        onPressed: () => _manager.startTurn(),
                        onReleased: canTalk
                            ? () => _manager.finishTurn()
                            : null,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    canTalk
                        ? 'Mantén pulsado para hablar'
                        : _manager.peer == null
                            ? 'Esperando al otro participante...'
                            : 'Conectado',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
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

// ============================================================
// CABECERA DE LA LLAMADA
// ============================================================

class _Header extends StatelessWidget {
  final String peerName;
  final Language myLanguage;
  final String sessionId;
  final bool peerConnected;

  const _Header({
    required this.peerName,
    required this.myLanguage,
    required this.sessionId,
    required this.peerConnected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade800,
            Colors.purple.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(
              peerConnected
                  ? Icons.person
                  : Icons.hourglass_top,
              color: Colors.white,
              size: 34,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            peerName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            peerConnected
                ? 'Conectado · Tu idioma: ${myLanguage.nombre}'
                : 'Comparte el código de sala para conectar',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),

          if (sessionId.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.vpn_key,
                    size: 16,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    sessionId,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// ESTADO DE LA LLAMADA
// ============================================================

class _StatusRow extends StatelessWidget {
  final CallManager manager;

  const _StatusRow({required this.manager});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    String text;
    Color color;

    if (manager.isSpeaking) {
      icon = Icons.volume_up;
      text = 'Reproduciendo traducción...';
      color = Colors.green;
    } else if (manager.isTranslating) {
      icon = Icons.translate;
      text = 'Traduciendo...';
      color = Colors.orange;
    } else if (manager.isListening) {
      icon = Icons.mic;
      text = 'Escuchando...';
      color = Colors.red;
    } else if (manager.peer == null) {
      icon = Icons.wifi_tethering;
      text = 'Esperando al otro participante...';
      color = Colors.blue;
    } else {
      icon = Icons.check_circle;
      text = 'Listo · habla en tu idioma';
      color = Colors.blue;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
// ============================================================
// VISTA DE ERROR
// ============================================================

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 56,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('VOLVER'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}