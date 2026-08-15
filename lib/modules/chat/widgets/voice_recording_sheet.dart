import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dis_app/core/logger.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';

/// Sprachaufnahme, bedienbar ohne ein Wort zu lesen.
///
/// Vorher stand hier ein Dialog mit der Zeile „Aufnahme läuft" und zwei
/// beschrifteten Knöpfen — und einem unbewegten Mikrofon-Symbol, an dem nicht
/// zu erkennen war, ob überhaupt etwas aufgenommen wird. Fehlte die
/// Mikrofon-Berechtigung, erschien der Dialog trotzdem und behauptete es.
///
/// Jetzt zeigt ein Kreis in der Profilfarbe im Takt des Herzschlags, dass
/// zugehört wird, daneben läuft die Zeit. Unten liegen zwei große Ziele: ein
/// Haken zum Behalten, ein Kreuz zum Verwerfen. Die beiden tragen [AppColors.go]
/// und [AppColors.signal] — hier bedeuten die Handlungsfarben genau das, wofür
/// sie reserviert sind.
class VoiceRecordingSheet extends StatefulWidget {
  const VoiceRecordingSheet({required this.profileColor, super.key});

  final Color profileColor;

  /// Nimmt auf und liefert die Aufnahme, oder `null` bei Abbruch.
  static Future<Uint8List?> record(BuildContext context, Color profileColor) {
    return showDialog<Uint8List>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (_) => VoiceRecordingSheet(profileColor: profileColor),
    );
  }

  @override
  State<VoiceRecordingSheet> createState() => _VoiceRecordingSheetState();
}

class _VoiceRecordingSheetState extends State<VoiceRecordingSheet>
    with SingleTickerProviderStateMixin {
  final AudioRecorder _recorder = AudioRecorder();
  late final AnimationController _pulse;
  Timer? _ticker;
  Duration _elapsed = Duration.zero;
  String? _path;
  bool _running = false;
  bool _denied = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _start();
  }

  Future<void> _start() async {
    try {
      if (!await _recorder.hasPermission()) {
        if (mounted) setState(() => _denied = true);
        return;
      }

      final directory = Directory.systemTemp;
      _path =
          '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(), path: _path!);

      if (!mounted) return;
      setState(() => _running = true);
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() => _elapsed += const Duration(seconds: 1));
        }
      });
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.ui,
        'Sprachaufnahme konnte nicht starten',
        data: {'error': e.toString()},
        stackTrace: stackTrace,
      );
      if (mounted) setState(() => _denied = true);
    }
  }

  Future<void> _finish() async {
    if (!_running) {
      Navigator.of(context).pop();
      return;
    }
    _ticker?.cancel();

    try {
      final path = await _recorder.stop();
      if (path == null) {
        if (mounted) Navigator.of(context).pop();
        return;
      }
      final file = File(path);
      final bytes = await file.exists() ? await file.readAsBytes() : null;
      if (await file.exists()) await file.delete();
      if (mounted) Navigator.of(context).pop(bytes);
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.ui,
        'Sprachaufnahme konnte nicht beendet werden',
        data: {'error': e.toString()},
        stackTrace: stackTrace,
      );
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _discard() async {
    _ticker?.cancel();
    try {
      if (_running) await _recorder.stop();
      final path = _path;
      if (path != null) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.ui,
        'Sprachaufnahme konnte nicht verworfen werden',
        data: {'error': e.toString()},
        stackTrace: stackTrace,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pulse.dispose();
    _recorder.dispose();
    super.dispose();
  }

  String get _clock {
    final minutes = _elapsed.inMinutes.toString().padLeft(2, '0');
    final seconds = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_denied)
            const Icon(Icons.mic_off, size: 120, color: Colors.white38)
          else
            AnimatedBuilder(
              animation: _pulse,
              builder: (context, child) {
                final scale = 1 + (_pulse.value * 0.18);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.profileColor.withValues(alpha: 0.25),
                      border: Border.all(color: widget.profileColor, width: 4),
                    ),
                    child: Icon(
                      Icons.mic,
                      size: 72,
                      color: widget.profileColor,
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: 32),

          Text(
            _denied ? '—' : _clock,
            style: const TextStyle(
              fontSize: 44,
              color: Colors.white,
              fontWeight: FontWeight.w300,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),

          const SizedBox(height: 40),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _BigChoice(
                icon: Icons.close,
                color: AppColors.signal,
                label: AppLocalizations.of(context).actionDiscard,
                onTap: _discard,
              ),
              if (!_denied)
                _BigChoice(
                  icon: Icons.check,
                  color: AppColors.go,
                  label: AppLocalizations.of(context).actionKeep,
                  onTap: _finish,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BigChoice extends StatelessWidget {
  const _BigChoice({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: Material(
        color: color,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 88,
            height: 88,
            child: Icon(icon, size: 44, color: AppColors.onColor(color)),
          ),
        ),
      ),
    );
  }
}
