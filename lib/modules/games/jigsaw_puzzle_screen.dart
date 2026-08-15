import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/puzzle_config.dart';
import 'package:dis_app/services/puzzle_screenshot_service.dart';
import 'package:dis_app/utils/custom_snackbar.dart';
import 'package:flutter/material.dart';

/// Jigsaw Puzzle Screen mit Drag & Drop Mechanik
class JigsawPuzzleScreen extends StatefulWidget {
  const JigsawPuzzleScreen({
    required this.config,
    this.imageFile,
    this.imageBytes,
    super.key,
  }) : assert(
         imageFile != null || imageBytes != null,
         'Either imageFile or imageBytes must be provided',
       );

  final PuzzleConfig config;
  final File? imageFile;
  final Uint8List? imageBytes;

  @override
  State<JigsawPuzzleScreen> createState() => _JigsawPuzzleScreenState();
}

class _JigsawPuzzleScreenState extends State<JigsawPuzzleScreen> {
  ui.Image? _image;
  List<PuzzlePiece> _pieces = [];
  List<PuzzlePiece?> _placedPieces = [];
  bool _isLoading = true;
  bool _isPuzzleComplete = false;
  int _moveCount = 0;
  final GlobalKey _screenshotKey = GlobalKey();
  final PuzzleScreenshotService _screenshotService = PuzzleScreenshotService();

  @override
  void initState() {
    super.initState();
    _loadAndSplitImage();
  }

  Future<void> _loadAndSplitImage() async {
    try {
      // Lade Bild
      // Typ ausgeschrieben: Ohne ihn leitet der Compiler aus den beiden Zweigen
      // Object ab, und resolve() gibt es dort nicht.
      // ignore: omit_local_variable_types
      final ImageProvider imageProvider = widget.imageFile != null
          ? FileImage(widget.imageFile!)
          : MemoryImage(widget.imageBytes!);

      final stream = imageProvider.resolve(ImageConfiguration.empty);
      final completer = Completer<ui.Image>();

      late ImageStreamListener listener;
      listener = ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info.image);
        stream.removeListener(listener);
      });

      stream.addListener(listener);
      final image = await completer.future;

      // Teile das Bild in Puzzle-Teile
      final gridSize = widget.config.difficulty.gridSize;
      final pieceWidth = image.width ~/ gridSize;
      final pieceHeight = image.height ~/ gridSize;

      final pieces = <PuzzlePiece>[];

      for (var row = 0; row < gridSize; row++) {
        for (var col = 0; col < gridSize; col++) {
          pieces.add(
            PuzzlePiece(
              correctRow: row,
              correctCol: col,
              currentIndex: pieces.length,
              sourceRect: Rect.fromLTWH(
                col * pieceWidth.toDouble(),
                row * pieceHeight.toDouble(),
                pieceWidth.toDouble(),
                pieceHeight.toDouble(),
              ),
            ),
          );
        }
      }

      // Mische die Teile
      pieces.shuffle();

      setState(() {
        _image = image;
        _pieces = pieces;
        _placedPieces = List.filled(pieces.length, null);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        showCustomSnackBar(
          context,
          message: l10n.puzzleErrorLoadingImage(e.toString()),
          type: SnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.puzzleJigsawTitle),
        actions: [
          // Züge-Anzeige (keine Wertung!)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                l10n.puzzleMoves(_moveCount),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l10n.puzzlePreparing),
                ],
              ),
            )
          : _isPuzzleComplete
          ? _buildCompletionScreen(l10n)
          : _buildPuzzleBoard(l10n),
    );
  }

  Widget _buildPuzzleBoard(AppLocalizations l10n) {
    final gridSize = widget.config.difficulty.gridSize;
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = screenWidth - 32;
    final pieceSize = boardSize / gridSize;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Puzzle-Board (Ziel-Grid)
            Container(
              width: boardSize,
              height: boardSize,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(8),
              ),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize,
                ),
                itemCount: _placedPieces.length,
                itemBuilder: (context, index) {
                  return DragTarget<PuzzlePiece>(
                    onAcceptWithDetails: (details) =>
                        _onPiecePlaced(details.data, index),
                    builder: (context, candidateData, rejectedData) {
                      final piece = _placedPieces[index];
                      final isHighlighted = candidateData.isNotEmpty;

                      return Container(
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: isHighlighted
                              ? Colors.blue.withValues(alpha: 0.3)
                              : Colors.transparent,
                          border: Border.all(
                            color: isHighlighted ? Colors.blue : Colors.white12,
                          ),
                        ),
                        child: piece != null
                            ? CustomPaint(
                                painter: PuzzlePiecePainter(
                                  image: _image!,
                                  sourceRect: piece.sourceRect,
                                ),
                              )
                            : Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: Colors.white12,
                                    fontSize: pieceSize * 0.4,
                                  ),
                                ),
                              ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Verfügbare Teile
            Text(
              l10n.puzzleAvailablePieces,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _pieces.map((piece) {
                return Draggable<PuzzlePiece>(
                  data: piece,
                  feedback: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: pieceSize * 0.8,
                      height: pieceSize * 0.8,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        painter: PuzzlePiecePainter(
                          image: _image!,
                          sourceRect: piece.sourceRect,
                        ),
                      ),
                    ),
                  ),
                  childWhenDragging: Container(
                    width: pieceSize * 0.8,
                    height: pieceSize * 0.8,
                    color: Colors.white10,
                  ),
                  child: Container(
                    width: pieceSize * 0.8,
                    height: pieceSize * 0.8,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                    ),
                    child: CustomPaint(
                      painter: PuzzlePiecePainter(
                        image: _image!,
                        sourceRect: piece.sourceRect,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _onPiecePlaced(PuzzlePiece piece, int targetIndex) {
    setState(() {
      // Entferne das Teil aus der verfügbaren Liste
      _pieces.remove(piece);

      // Falls das Zielfeld schon belegt ist, verschiebe das alte Teil zurück
      if (_placedPieces[targetIndex] != null) {
        _pieces.add(_placedPieces[targetIndex]!);
      }

      // Platziere das neue Teil
      _placedPieces[targetIndex] = piece;
      _moveCount++;

      // Prüfe ob Puzzle komplett ist
      _checkCompletion();
    });
  }

  void _checkCompletion() {
    if (_pieces.isNotEmpty) return; // Noch nicht alle Teile platziert

    // Prüfe ob alle Teile korrekt platziert sind
    for (var i = 0; i < _placedPieces.length; i++) {
      final piece = _placedPieces[i];
      if (piece == null) return;

      final correctIndex =
          piece.correctRow * widget.config.difficulty.gridSize +
          piece.correctCol;
      if (correctIndex != i) return;
    }

    // Puzzle ist komplett!
    setState(() => _isPuzzleComplete = true);
  }

  Widget _buildCompletionScreen(AppLocalizations l10n) {
    return RepaintBoundary(
      key: _screenshotKey,
      child: ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.celebration, size: 80, color: Colors.green),
                const SizedBox(height: 24),
                Text(
                  l10n.puzzleSolved,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.puzzleSolvedInMoves(_moveCount),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 32),

                // Komplettes Bild anzeigen
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: widget.imageFile != null
                      ? Image.file(widget.imageFile!, width: 300)
                      : Image.memory(widget.imageBytes!, width: 300),
                ),

                const SizedBox(height: 32),

                // Button-Reihe
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Share-Button
                    ElevatedButton.icon(
                      onPressed: () => _sharePuzzle(l10n),
                      icon: const Icon(Icons.share),
                      label: Text(l10n.actionShare),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Fertig-Button
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check),
                      label: Text(l10n.actionDone),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sharePuzzle(AppLocalizations l10n) async {
    try {
      await _screenshotService.shareCompletedPuzzle(
        screenshotKey: _screenshotKey,
        config: widget.config,
        moveCount: _moveCount,
      );
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(
          context,
          message: l10n.puzzleErrorSharing(e.toString()),
          type: SnackBarType.error,
        );
      }
    }
  }
}

/// Puzzle-Teil Datenmodell
class PuzzlePiece {
  const PuzzlePiece({
    required this.correctRow,
    required this.correctCol,
    required this.currentIndex,
    required this.sourceRect,
  });

  final int correctRow;
  final int correctCol;
  final int currentIndex;
  final Rect sourceRect;
}

/// Custom Painter für Puzzle-Teile
class PuzzlePiecePainter extends CustomPainter {
  const PuzzlePiecePainter({
    required this.image,
    required this.sourceRect,
  });

  final ui.Image image;
  final Rect sourceRect;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final destRect = Offset.zero & size;

    canvas.drawImageRect(image, sourceRect, destRect, paint);
  }

  @override
  bool shouldRepaint(PuzzlePiecePainter oldDelegate) =>
      image != oldDelegate.image || sourceRect != oldDelegate.sourceRect;
}
