import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dis_app/core/logger.dart';
import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/utils/app_colors.dart';
import 'package:flutter/material.dart';

/// Ein einzelner Strich.
class Stroke {
  Stroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  /// Ob [point] den Strich trifft — für den Radiergummi.
  bool hitBy(Offset point, double radius) {
    final reach = radius + strokeWidth / 2;
    for (final own in points) {
      if ((own - point).distance <= reach) return true;
    }
    return false;
  }
}

/// Ein Sticker auf der Fläche.
class StickerInstance {
  StickerInstance({
    required this.emoji,
    required this.position,
    this.size = 48.0,
  });

  final String emoji;
  Offset position;
  final double size;
}

/// Die Zeichenfläche des Chats.
///
/// Sie ist durchscheinend und liegt über dem Nachrichtenverlauf: für Anteile,
/// die nicht schreiben, ist Malen die Grundhandlung im Chat und nicht ein
/// Sonderfall, den man erst einschalten muss. Der Verlauf bleibt dahinter
/// sichtbar, damit erkennbar ist, worauf geantwortet wird.
///
/// Weil die Fläche keinen eigenen Grund hat, kann der Radiergummi nicht mehr
/// mit Hintergrundfarbe übermalen — er entfernt jetzt, was er berührt. Das ist
/// ohnehin das Verhalten, das erwartet wird: über einen Sticker gefahren, war
/// der alte Radierer wirkungslos, weil Sticker über der gemalten Ebene liegen.
class DoodleCanvas extends StatefulWidget {
  const DoodleCanvas({
    required this.onSend,
    required this.profileColor,
    required this.drawingEnabled,
    required this.onToggleDrawing,
    this.showStickers = true,
    this.showModeToggle = true,
    this.confirmIcon = Icons.send,
    this.confirmTooltip,
    this.confirmEmptyTooltip,
    super.key,
  });

  /// Breite der Werkzeugleiste am rechten Rand.
  ///
  /// Die Leiste liegt über allem, was der Chat darunter zeigt. Wer dort
  /// mittig etwas darstellt, muss diesen Streifen aussparen — sonst
  /// verschwindet der rechte Rand des Textes darunter.
  static const double toolRailWidth = 60;

  final void Function(Uint8List imageBytes) onSend;
  final Color profileColor;

  /// Ob Berührungen ans Malen gehen. Sonst erreichen sie den Verlauf darunter.
  final bool drawingEnabled;
  final VoidCallback onToggleDrawing;

  /// Ob die Sticker angeboten werden.
  ///
  /// Im Chat gehören sie dazu — dort ist ein Sticker eine Antwort. Wer ein
  /// Bild für sich selbst malt, braucht sie nicht, und jeder Knopf weniger
  /// zählt: gleichzeitig sichtbare Wahlmöglichkeiten sollen fünf bis sieben
  /// nicht überschreiten (Hick).
  final bool showStickers;

  /// Ob der Umschalter zwischen Malen und Blättern angeboten wird.
  ///
  /// Er ergibt nur Sinn, wenn unter der Fläche etwas liegt, das man erreichen
  /// will. Steht die Fläche für sich, wäre er ein Knopf, der nichts tut.
  final bool showModeToggle;

  /// Symbol und Worte des abschließenden Knopfes.
  ///
  /// Im Chat wird gesendet, beim Profilbild übernommen — dieselbe Handlung
  /// technisch, zwei verschiedene Zusagen an den Menschen davor. Bleiben die
  /// Worte leer, gelten die des Chats.
  final IconData confirmIcon;
  final String? confirmTooltip;
  final String? confirmEmptyTooltip;

  @override
  State<DoodleCanvas> createState() => _DoodleCanvasState();
}

class _DoodleCanvasState extends State<DoodleCanvas> {
  /// Feinheit des gesendeten Bildes gegenüber der Anzeige.
  static const double _exportScale = 2;

  final List<Stroke> _strokes = [];
  final List<StickerInstance> _stickers = [];
  List<Offset> _currentStrokePoints = [];

  Color _selectedColor = Colors.white;
  double _strokeWidth = 8;
  bool _eraserMode = false;

  final List<Color> _availableColors = const [
    Colors.white,
    Color(0xFFFF6B6B),
    Color(0xFFFFA94D),
    Color(0xFFFFE066),
    Color(0xFF69DB7C),
    Color(0xFF4DABF7),
    Color(0xFFB197FC),
    Color(0xFF212529),
  ];

  /// Drei Stärken, nicht vier. Sie stehen jetzt sichtbar nebeneinander statt
  /// hinter einem Knopf, der bei jedem Tippen weiterschaltet: Was der nächste
  /// Griff bewirkt, war vorher nicht zu sehen, und rückwärts kam man nur,
  /// indem man einmal ganz herum tippte.
  static const List<double> _brushSizes = [3.0, 8.0, 16.0];

  final GlobalKey _canvasKey = GlobalKey();

  /// Eigener Controller für die Werkzeugleiste.
  ///
  /// Ohne ihn greift sie auf den PrimaryScrollController zu — denselben, an
  /// dem der Nachrichtenverlauf darunter hängt. Zwei ScrollPositions an einem
  /// Controller, und die Scrollbar der Leiste kann nicht mehr zeichnen: beim
  /// Öffnen des Chats kam dann jedes Mal ein Framework-Fehler.
  final ScrollController _railScrollController = ScrollController();

  @override
  void dispose() {
    _railScrollController.dispose();
    super.dispose();
  }

  bool get _hasContent => _strokes.isNotEmpty || _stickers.isNotEmpty;

  double get _eraserRadius => math.max(_strokeWidth * 2, 16);

  Size? get _canvasSize {
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    return (box != null && box.hasSize) ? box.size : null;
  }

  // ---------------------------------------------------------------- Zeichnen

  void _onPanStart(DragStartDetails details) {
    if (_eraserMode) {
      setState(() => _eraseAt(details.localPosition));
      return;
    }
    setState(() => _currentStrokePoints = [details.localPosition]);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_eraserMode) {
      setState(() => _eraseAt(details.localPosition));
      return;
    }
    setState(() => _currentStrokePoints.add(details.localPosition));
  }

  void _onPanEnd(DragEndDetails details) {
    if (_currentStrokePoints.isEmpty) return;
    setState(() {
      _strokes.add(
        Stroke(
          points: List.from(_currentStrokePoints),
          color: _selectedColor,
          strokeWidth: _strokeWidth,
        ),
      );
      _currentStrokePoints.clear();
    });
  }

  /// Ein Tippen setzt einen Punkt. Wer tupft statt streicht, malte sonst ins
  /// Nichts — `drawLine` braucht zwei Punkte.
  void _onTapDown(TapDownDetails details) {
    setState(() {
      if (_eraserMode) {
        _eraseAt(details.localPosition);
        return;
      }
      _strokes.add(
        Stroke(
          points: [details.localPosition],
          color: _selectedColor,
          strokeWidth: _strokeWidth,
        ),
      );
    });
  }

  void _eraseAt(Offset point) {
    _stickers.removeWhere(
      (sticker) => (sticker.position - point).distance < sticker.size / 2,
    );
    _strokes.removeWhere((stroke) => stroke.hitBy(point, _eraserRadius));
  }

  // ------------------------------------------------------------------ Senden

  /// Der Bereich, in dem etwas steht. `null`, wenn die Fläche leer ist.
  Rect? _contentBounds() {
    var left = double.infinity;
    var top = double.infinity;
    var right = double.negativeInfinity;
    var bottom = double.negativeInfinity;
    var found = false;

    void include(Offset point, double radius) {
      left = math.min(left, point.dx - radius);
      top = math.min(top, point.dy - radius);
      right = math.max(right, point.dx + radius);
      bottom = math.max(bottom, point.dy + radius);
      found = true;
    }

    for (final stroke in _strokes) {
      for (final point in stroke.points) {
        include(point, stroke.strokeWidth / 2);
      }
    }
    for (final sticker in _stickers) {
      include(sticker.position, sticker.size / 2);
    }

    if (!found) return null;
    return Rect.fromLTRB(left, top, right, bottom).inflate(16);
  }

  /// Zeichnet den beschriebenen Ausschnitt neu und gibt ihn als PNG zurück.
  ///
  /// Nur der Ausschnitt, nicht die ganze Fläche: ein Strich in der Ecke wurde
  /// sonst zu einem bildschirmhohen, fast leeren Bild, das im Verlauf allen
  /// Platz einnahm. Der Grund bleibt durchsichtig, damit die Zeichnung in der
  /// Bubble steht und nicht auf einem abweichend gefärbten Rechteck.
  Future<Uint8List?> _exportToPng() async {
    try {
      final bounds = _contentBounds();
      if (bounds == null) return null;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.scale(_exportScale);
      canvas.translate(-bounds.left, -bounds.top);

      DoodlePainter(
        strokes: _strokes,
        currentStroke: const [],
        currentColor: _selectedColor,
        currentWidth: _strokeWidth,
      ).paint(canvas, bounds.size);

      for (final sticker in _stickers) {
        final painter = TextPainter(
          text: TextSpan(
            text: sticker.emoji,
            style: TextStyle(fontSize: sticker.size),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        painter.paint(
          canvas,
          sticker.position - Offset(painter.width / 2, painter.height / 2),
        );
      }

      final image = await recorder.endRecording().toImage(
        (bounds.width * _exportScale).ceil(),
        (bounds.height * _exportScale).ceil(),
      );
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e, stackTrace) {
      logger.error(
        LogCategory.ui,
        'Error exporting doodle',
        data: {'error': e.toString()},
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<void> _send() async {
    final imageBytes = await _exportToPng();
    if (imageBytes == null) return;
    widget.onSend(imageBytes);
    // Der Empfänger darf die Fläche schließen — beim Profilbild tut er genau
    // das. Ohne diese Prüfung setzt der nächste Aufruf den Zustand eines
    // Widgets, das es nicht mehr gibt.
    if (!mounted) return;
    setState(() {
      _strokes.clear();
      _stickers.clear();
      _currentStrokePoints.clear();
      _eraserMode = false;
    });
  }

  // --------------------------------------------------------------- Werkzeuge

  void _undo() {
    setState(() {
      if (_stickers.isNotEmpty) {
        _stickers.removeLast();
      } else if (_strokes.isNotEmpty) {
        _strokes.removeLast();
      }
    });
  }

  void _clear() {
    setState(() {
      _strokes.clear();
      _stickers.clear();
      _currentStrokePoints.clear();
    });
  }

  void _selectBrushSize(double width) {
    setState(() {
      _strokeWidth = width;
      // Wer eine Stärke wählt, will malen, nicht radieren.
      _eraserMode = false;
    });
  }

  void _addSticker(String emoji) {
    // Die Mitte der Fläche, nicht ein fester Punkt: bei kleineren Flächen lag
    // der Sticker sonst außerhalb — angetippt, aber nirgends zu sehen.
    final size = _canvasSize;
    final center = size != null
        ? Offset(size.width / 2, size.height / 2)
        : const Offset(150, 150);
    setState(() {
      _stickers.add(StickerInstance(emoji: emoji, position: center));
    });
  }

  void _showStickerPicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1C1B1F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            shrinkWrap: true,
            crossAxisCount: 5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children:
                const [
                  '😊',
                  '😂',
                  '😍',
                  '🤔',
                  '😎',
                  '😢',
                  '😡',
                  '😴',
                  '🤗',
                  '🥰',
                  '🎉',
                  '🎈',
                  '🎁',
                  '⭐',
                  '❤️',
                  '👍',
                  '👋',
                  '✨',
                  '🌈',
                  '☀️',
                  '🐶',
                  '🐱',
                  '🦒',
                  '🐾',
                  '🌙',
                ].map((emoji) {
                  return InkWell(
                    onTap: () {
                      _addSticker(emoji);
                      Navigator.pop(sheetContext);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 34),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------- Aufbau

  @override
  Widget build(BuildContext context) {
    // Werkzeuge zeigt nur, wer malt.
    //
    // Vorher standen sechs Werkzeugknöpfe und die dreizehn Punkte der
    // Materialleiste dauerhaft über dem Nachrichtenverlauf — auch für
    // jemanden, der gerade blätterte. Neun Symbole ohne ein Wort, für eine
    // Handlung, die niemand gewählt hatte, und zwei gleiche Sende-Pfeile
    // gleichzeitig auf dem Schirm. Wer nicht malt, sieht jetzt den Pinsel
    // und sonst nichts (Regel 9: Zustände werden angeboten, nicht erkannt).
    //
    // Ohne Umschalter gibt es keinen Weg zurück in die Werkzeuge — dann
    // bleiben sie stehen. Das ist der Fall beim gemalten Profilbild, wo die
    // Fläche für sich steht und ohnehin immer malt.
    final zeigeWerkzeuge = widget.drawingEnabled || !widget.showModeToggle;

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildDrawingSurface()),
              if (!zeigeWerkzeuge)
                _FoldedRail(
                  profileColor: widget.profileColor,
                  onToggleDrawing: widget.onToggleDrawing,
                )
              else
                _ToolRail(
                  scrollController: _railScrollController,
                  profileColor: widget.profileColor,
                  drawingEnabled: widget.drawingEnabled,
                  hasContent: _hasContent,
                  eraserMode: _eraserMode,
                  showStickers: widget.showStickers,
                  showModeToggle: widget.showModeToggle,
                  confirmIcon: widget.confirmIcon,
                  confirmTooltip: widget.confirmTooltip,
                  confirmEmptyTooltip: widget.confirmEmptyTooltip,
                  onToggleDrawing: widget.onToggleDrawing,
                  onSend: _send,
                  onSticker: _showStickerPicker,
                  onEraser: () => setState(() => _eraserMode = !_eraserMode),
                  onUndo: _hasContent ? _undo : null,
                  onClear: _hasContent ? _clear : null,
                ),
            ],
          ),
        ),
        if (zeigeWerkzeuge)
          _MaterialStrip(
            sizes: _brushSizes,
            selectedSize: _eraserMode ? null : _strokeWidth,
            onSizeSelected: _selectBrushSize,
            colors: _availableColors,
            selectedColor: _eraserMode ? null : _selectedColor,
            onColorSelected: (color) => setState(() {
              _selectedColor = color;
              _eraserMode = false;
            }),
          ),
      ],
    );
  }

  Widget _buildDrawingSurface() {
    return IgnorePointer(
      // Aus: Berührungen erreichen den Nachrichtenverlauf darunter, der sich
      // dann wieder blättern lässt und dessen Bilder sich öffnen lassen.
      ignoring: !widget.drawingEnabled,
      // Die Abblendung geht in beide Richtungen: beim Malen tritt der Verlauf
      // zurück, beim Blättern die Zeichnung. Ohne das lag eine halbfertige
      // Zeichnung quer über den Nachrichten und machte sie unlesbar —
      // verworfen ist sie damit nicht, sie kehrt beim Umschalten zurück.
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: widget.drawingEnabled ? 1 : 0.25,
        child: GestureDetector(
          onTapDown: _onTapDown,
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            key: _canvasKey,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: DoodlePainter(
                    strokes: _strokes,
                    currentStroke: _currentStrokePoints,
                    currentColor: _selectedColor,
                    currentWidth: _strokeWidth,
                  ),
                ),
              ),
              for (final sticker in _stickers)
                Positioned(
                  left: sticker.position.dx - sticker.size / 2,
                  top: sticker.position.dy - sticker.size / 2,
                  child: Draggable<StickerInstance>(
                    feedback: Text(
                      sticker.emoji,
                      style: TextStyle(fontSize: sticker.size),
                    ),
                    childWhenDragging: const SizedBox.shrink(),
                    onDragEnd: (details) {
                      // details.offset ist global und meint die linke obere Ecke
                      // des gezogenen Bildes; position ist lokal und meint dessen
                      // Mitte. Ungerechnet sprang der Sticker beim Loslassen quer
                      // über die Fläche.
                      final box =
                          _canvasKey.currentContext?.findRenderObject()
                              as RenderBox?;
                      if (box == null) return;
                      final local = box.globalToLocal(details.offset);
                      setState(() {
                        sticker.position =
                            local + Offset(sticker.size / 2, sticker.size / 2);
                      });
                    },
                    child: Text(
                      sticker.emoji,
                      style: TextStyle(fontSize: sticker.size),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Werkzeuge am rechten Rand, von oben nach unten in der Reihenfolge, in der
/// sie gebraucht werden. Senden steht zuoberst: es ist die Handlung, um die es
/// geht, und lag vorher als neuntes Element unterhalb des sichtbaren Bereichs.
class _ToolRail extends StatelessWidget {
  const _ToolRail({
    required this.scrollController,
    required this.profileColor,
    required this.drawingEnabled,
    required this.hasContent,
    required this.eraserMode,
    required this.showStickers,
    required this.showModeToggle,
    required this.confirmIcon,
    required this.confirmTooltip,
    required this.confirmEmptyTooltip,
    required this.onToggleDrawing,
    required this.onSend,
    required this.onSticker,
    required this.onEraser,
    required this.onUndo,
    required this.onClear,
  });

  /// Gehört dem Zeichenflächen-State, damit die Leiste nicht den
  /// PrimaryScrollController des Nachrichtenverlaufs mitbenutzt.
  final ScrollController scrollController;

  final Color profileColor;
  final bool drawingEnabled;
  final bool hasContent;
  final bool eraserMode;
  final bool showStickers;
  final bool showModeToggle;
  final IconData confirmIcon;
  final String? confirmTooltip;
  final String? confirmEmptyTooltip;
  final VoidCallback onToggleDrawing;
  final VoidCallback onSend;
  final VoidCallback onSticker;
  final VoidCallback onEraser;
  final VoidCallback? onUndo;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: DoodleCanvas.toolRailWidth,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B1F).withValues(alpha: 0.92),
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
      ),
      // Scrollbar mit sichtbarem Balken: dass die Leiste sich schieben lässt,
      // war ihr vorher nicht anzusehen — der unterste Eintrag lag angeschnitten
      // am Rand und wirkte wie ein Darstellungsfehler.
      child: Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Fester Platz, ob es etwas zu senden gibt oder nicht: sonst
              // rutschen alle Werkzeuge nach, und der oberste Knopf wechselt
              // die Bedeutung — aus dem Mal-Umschalter wurde beim ersten
              // Strich der Sende-Knopf, gleiche Stelle, gleiches Weiß.
              // Reihenfolge ist eine Zusage (Regel 7).
              _RailButton(
                icon: confirmIcon,
                tooltip: hasContent
                    ? (confirmTooltip ?? l10n.doodleSendDrawing)
                    : (confirmEmptyTooltip ?? l10n.doodleSendEmptyHint),
                background: hasContent ? profileColor : null,
                foreground: hasContent ? AppColors.onColor(profileColor) : null,
                onPressed: hasContent ? onSend : null,
              ),
              if (showModeToggle)
                _RailButton(
                  icon: drawingEnabled ? Icons.pan_tool_alt : Icons.brush,
                  tooltip: drawingEnabled
                      ? l10n.doodleHistory
                      : l10n.doodleDraw,
                  background: drawingEnabled ? null : profileColor,
                  foreground: drawingEnabled
                      ? Colors.white
                      : AppColors.onColor(profileColor),
                  onPressed: onToggleDrawing,
                ),
              if (showStickers)
                _RailButton(
                  icon: Icons.emoji_emotions,
                  tooltip: l10n.doodleSticker,
                  onPressed: onSticker,
                ),
              _RailButton(
                icon: Icons.auto_fix_normal,
                tooltip: l10n.doodleErase,
                background: eraserMode ? profileColor : null,
                foreground: eraserMode
                    ? AppColors.onColor(profileColor)
                    : Colors.white,
                onPressed: onEraser,
              ),
              _RailButton(
                icon: Icons.undo,
                tooltip: l10n.doodleUndo,
                onPressed: onUndo,
              ),
              _RailButton(
                icon: Icons.delete_outline,
                tooltip: l10n.doodleClear,
                onPressed: onClear,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// Was im Blättermodus von der Werkzeugleiste übrig bleibt: der Pinsel.
///
/// Er steht an der Stelle, an der im aufgeklappten Zustand der Umschalter
/// steht — eine Reihe tiefer als ganz oben. Läge er zuoberst, erschiene nach
/// dem Tippen der Sende-Knopf genau dort, wo der Finger eben war. Reihenfolge
/// ist eine Zusage (Regel 7), und sie gilt über den Wechsel hinweg.
///
/// Die Spalte bleibt so breit wie die volle Leiste, damit unter ihr nichts
/// springt, wenn die Werkzeuge auf- und zugehen. Einen eigenen Grund hat sie
/// nicht: Ein dunkler Streifen über dem Verlauf, der nur einen Knopf trägt,
/// nähme Platz für nichts.
class _FoldedRail extends StatelessWidget {
  const _FoldedRail({
    required this.profileColor,
    required this.onToggleDrawing,
  });

  final Color profileColor;
  final VoidCallback onToggleDrawing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: DoodleCanvas.toolRailWidth,
      child: Column(
        children: [
          const SizedBox(height: 8 + _RailButton.slotHeight),
          _RailButton(
            icon: Icons.brush,
            tooltip: l10n.doodleDraw,
            background: profileColor,
            foreground: AppColors.onColor(profileColor),
            onPressed: onToggleDrawing,
          ),
        ],
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.background,
    this.foreground,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? background;
  final Color? foreground;

  /// Was ein Knopf samt Abstand in der Leiste einnimmt.
  ///
  /// Der eingeklappte Streifen rechnet damit seinen Platz aus, damit der
  /// Pinsel dort steht, wo der Umschalter stehen wird.
  static const double slotHeight = 48 + 3 * 2;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      child: Material(
        color: background ?? Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Tooltip(
            message: tooltip,
            child: SizedBox(
              // 48 px: die kleinste Fläche, die auch mit ungenauer Motorik
              // zuverlässig getroffen wird.
              width: 48,
              height: 48,
              child: Icon(
                icon,
                size: 26,
                color: enabled ? (foreground ?? Colors.white) : Colors.white24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Womit gemalt wird: Strichstärke und Farbe, beide sichtbar.
///
/// Zwei Gruppen in einer Zeile, durch einen Strich getrennt. Getrennt, weil
/// dreizehn Punkte nebeneinander eine einzige lange Reihe wären und niemand
/// darin zwei Bedeutungen erkennt; sichtbar, weil Verstecken hier der
/// schlechtere Tausch ist — was man nicht sieht, findet man nicht.
class _MaterialStrip extends StatelessWidget {
  const _MaterialStrip({
    required this.sizes,
    required this.selectedSize,
    required this.onSizeSelected,
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
  });

  final List<double> sizes;
  final double? selectedSize;
  final ValueChanged<double> onSizeSelected;
  final List<Color> colors;
  final Color? selectedColor;
  final ValueChanged<Color> onColorSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = [
      l10n.doodleStrokeThin,
      l10n.doodleStrokeMedium,
      l10n.doodleStrokeThick,
    ];

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: const Color(0xFF1C1B1F).withValues(alpha: 0.92),
      child: Row(
        children: [
          for (var i = 0; i < sizes.length; i++)
            _StrokeDot(
              width: sizes[i],
              // Der Punkt zeigt die Stärke selbst — er ist so groß, wie der
              // Strich breit wird. Das Wort steht daneben für alle, die
              // vorgelesen bekommen.
              label: i < labels.length ? labels[i] : l10n.doodleStrokeWidth,
              selected: sizes[i] == selectedSize,
              onTap: () => onSizeSelected(sizes[i]),
            ),

          Container(
            width: 1,
            height: 28,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            color: Colors.white24,
          ),

          // Rollbar statt gleichmäßig verteilt: Die Punkte sind fest breit,
          // die Wortlängen der Stärke-Labels nicht. Auf schmalen Schirmen
          // lief die Reihe rechts über — der letzte Farbton war halb da und
          // damit gar nicht wählbar.
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: colors.map((color) {
                  final isSelected = color == selectedColor;
                  return GestureDetector(
                    onTap: () => onColorSelected(color),
                    child: Container(
                      // Die Trefferfläche ist größer als der sichtbare Kreis.
                      width: 36,
                      height: 56,
                      alignment: Alignment.center,
                      child: Container(
                        width: isSelected ? 32 : 26,
                        height: isSelected ? 32 : 26,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            // Die Auswahl zeigt sich in Größe und Rahmen, nicht
                            // in der Farbe — sonst wäre sie bei Weiß unsichtbar.
                            color: isSelected ? Colors.white : Colors.white38,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ein Punkt, so groß wie der Strich, den er einstellt.
class _StrokeDot extends StatelessWidget {
  const _StrokeDot({
    required this.width,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final double width;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 56,
          alignment: Alignment.center,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? Colors.white12 : Colors.transparent,
              border: Border.all(
                color: selected ? Colors.white : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Container(
                // Der sichtbare Punkt trägt die Aussage: doppelte Strichbreite,
                // damit auch der dünnste noch zu treffen und zu sehen ist.
                width: width * 1.3 + 6,
                height: width * 1.3 + 6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Malt Striche. Öffentlich, weil der Export dieselbe Darstellung braucht wie
/// die Anzeige — zwei Zeichenwege würden früher oder später auseinanderlaufen.
class DoodlePainter extends CustomPainter {
  DoodlePainter({
    required this.strokes,
    required this.currentStroke,
    required this.currentColor,
    required this.currentWidth,
  });

  final List<Stroke> strokes;
  final List<Offset> currentStroke;
  final Color currentColor;
  final double currentWidth;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke.points, stroke.color, stroke.strokeWidth);
    }
    if (currentStroke.isNotEmpty) {
      _drawStroke(canvas, currentStroke, currentColor, currentWidth);
    }
  }

  void _drawStroke(
    Canvas canvas,
    List<Offset> points,
    Color color,
    double width,
  ) {
    if (points.isEmpty) return;

    // Ein einzelner Punkt hat keine Strecke — drawLine zeichnete nichts.
    if (points.length == 1) {
      canvas.drawCircle(
        points.first,
        width / 2,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );
      return;
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(DoodlePainter oldDelegate) => true;
}
