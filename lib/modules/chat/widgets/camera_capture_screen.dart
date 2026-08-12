import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dis_app/core/logger.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/l10n/app_texts.dart';
import 'package:flutter/material.dart';

/// Auroras eigene Kameraansicht: Bild sehen, Knopf drücken, fertig.
///
/// Vorher führte der Weg zu einem Foto über „+" in ein Blatt mit fünf
/// beschrifteten Zeilen und von dort in die Kamera-App des Telefons. Drei
/// Bildschirme, zwei davon fremd und beschriftet. Für Anteile, die kognitiv im
/// frühkindlichen Bereich sind, endete der Weg spätestens am Blatt.
///
/// Hier gibt es genau drei Bedienelemente, alle ohne Beschriftung verständlich:
/// ein großer Auslöser, ein Wechsel zwischen Vorder- und Rückkamera, ein Kreuz
/// zum Verlassen. Der Auslöser sitzt mittig unten, wo der Daumen ohnehin liegt.
class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  /// Öffnet die Kamera und liefert die aufgenommene Datei, oder `null`.
  static Future<File?> open(BuildContext context) {
    return Navigator.of(context).push<File>(
      MaterialPageRoute(builder: (_) => const CameraCaptureScreen()),
    );
  }

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  int _cameraIndex = 0;
  bool _busy = false;
  String? _failure;

  @override
  void initState() {
    super.initState();
    _setUpCameras();
  }

  Future<void> _setUpCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _failure = AppTexts.current.cameraNotFound);
        return;
      }
      await _activate(0);
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.ui,
        AppTexts.current.cameraCouldNotOpen,
        data: {'error': e.toString()},
        stackTrace: stackTrace,
      );
      if (mounted) {
        setState(() => _failure = AppTexts.current.cameraCouldNotOpen);
      }
    }
  }

  Future<void> _activate(int index) async {
    final previous = _controller;
    final controller = CameraController(
      _cameras[index],
      ResolutionPreset.high,
      enableAudio: false,
    );

    await controller.initialize();
    await previous?.dispose();

    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() {
      _controller = controller;
      _cameraIndex = index;
    });
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _busy) return;
    setState(() => _busy = true);
    try {
      await _activate((_cameraIndex + 1) % _cameras.length);
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.ui,
        'Kamerawechsel fehlgeschlagen',
        data: {'error': e.toString()},
        stackTrace: stackTrace,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _busy) return;

    setState(() => _busy = true);
    try {
      final shot = await controller.takePicture();
      if (!mounted) return;
      Navigator.of(context).pop(File(shot.path));
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.ui,
        'Aufnahme fehlgeschlagen',
        data: {'error': e.toString()},
        stackTrace: stackTrace,
      );
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_failure != null)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.no_photography_outlined,
                    size: 96,
                    color: Colors.white38,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _failure!,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            )
          else if (controller == null || !controller.value.isInitialized)
            const Center(child: CircularProgressIndicator())
          else
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.previewSize?.height ?? 1080,
                height: controller.value.previewSize?.width ?? 1920,
                child: CameraPreview(controller),
              ),
            ),

          // Verlassen
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: _RoundButton(
              icon: Icons.close,
              size: 56,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Vorder- und Rückkamera
          if (_cameras.length > 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 8,
              child: _RoundButton(
                icon: Icons.cameraswitch,
                size: 56,
                onPressed: _switchCamera,
              ),
            ),

          // Auslöser
          if (_failure == null)
            Positioned(
              left: 0,
              right: 0,
              bottom: MediaQuery.of(context).padding.bottom + 32,
              child: Center(
                child: Semantics(
                  label: AppLocalizations.of(context).chatCapturePhoto,
                  button: true,
                  child: GestureDetector(
                    onTap: _capture,
                    child: Container(
                      // Der klassische runde Auslöser: groß, mittig und ohne
                      // Beschriftung eindeutig.
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: _busy ? 0.4 : 1),
                        border: Border.all(color: Colors.white54, width: 4),
                      ),
                      child: const Icon(
                        Icons.photo_camera,
                        size: 40,
                        color: Color(0xFF1C1B1F),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.size,
    required this.onPressed,
  });

  final IconData icon;
  final double size;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: Colors.white, size: size * 0.5),
        ),
      ),
    );
  }
}
