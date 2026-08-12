import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/puzzle_config.dart';
import 'package:dis_app/services/puzzle_screenshot_service.dart';
import 'package:dis_app/utils/custom_snackbar.dart';
import 'package:flutter/material.dart';

/// Sliding Puzzle Screen (15-Puzzle Style)
class SlidingPuzzleScreen extends StatefulWidget {
  const SlidingPuzzleScreen({
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
  State<SlidingPuzzleScreen> createState() => _SlidingPuzzleScreenState();
}

class _SlidingPuzzleScreenState extends State<SlidingPuzzleScreen> {
  ui.Image? _image;
  List<int?> _tiles = []; // null = leeres Feld
  bool _isLoading = true;
  bool _isPuzzleComplete = false;
  int _moveCount = 0;
  int _emptyIndex = 0;
  final GlobalKey _screenshotKey = GlobalKey();
  final PuzzleScreenshotService _screenshotService = PuzzleScreenshotService();

  @override
  void initState() {
    super.initState();
    _loadAndInitializePuzzle();
  }

  Future<void> _loadAndInitializePuzzle() async {
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

      // Initialisiere Tiles
      final gridSize = widget.config.difficulty.gridSize;
      final totalTiles = gridSize * gridSize;

      // Erstelle sortiertes Grid (0 bis n-1, wobei n-1 das leere Feld ist)
      final tiles = List<int?>.generate(totalTiles - 1, (i) => i);
      tiles.add(null); // Leeres Feld am Ende

      // Mische das Puzzle (aber nur lösbare Konfigurationen!)
      _shuffleTiles(tiles, gridSize);

      setState(() {
        _image = image;
        _tiles = tiles;
        _emptyIndex = tiles.indexOf(null);
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

  /// Mische Tiles durch wiederholte gültige Züge (garantiert lösbar!)
  void _shuffleTiles(List<int?> tiles, int gridSize) {
    final random = Random();
    var emptyIdx = tiles.indexOf(null);

    // Führe 100 zufällige gültige Züge aus
    for (var i = 0; i < 100; i++) {
      final neighbors = _getNeighbors(emptyIdx, gridSize);
      if (neighbors.isEmpty) continue;

      final randomNeighbor = neighbors[random.nextInt(neighbors.length)];

      // Tausche
      tiles[emptyIdx] = tiles[randomNeighbor];
      tiles[randomNeighbor] = null;
      emptyIdx = randomNeighbor;
    }
  }

  /// Gibt die Indizes der Nachbar-Tiles zurück
  List<int> _getNeighbors(int index, int gridSize) {
    final neighbors = <int>[];
    final row = index ~/ gridSize;
    final col = index % gridSize;

    // Oben
    if (row > 0) neighbors.add((row - 1) * gridSize + col);
    // Unten
    if (row < gridSize - 1) neighbors.add((row + 1) * gridSize + col);
    // Links
    if (col > 0) neighbors.add(row * gridSize + (col - 1));
    // Rechts
    if (col < gridSize - 1) neighbors.add(row * gridSize + (col + 1));

    return neighbors;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.puzzleSlidingTitle),
        actions: [
          // Züge-Anzeige
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

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.puzzleTapToMove,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 16),

            // Puzzle-Board
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
                itemCount: _tiles.length,
                itemBuilder: (context, index) {
                  final tileNumber = _tiles[index];

                  if (tileNumber == null) {
                    // Leeres Feld
                    return Container(
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        border: Border.all(color: Colors.white12),
                      ),
                    );
                  }

                  // Tile mit Bild
                  final isMovable = _getNeighbors(
                    _emptyIndex,
                    gridSize,
                  ).contains(index);

                  return GestureDetector(
                    onTap: isMovable ? () => _moveTile(index) : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isMovable ? Colors.blue : Colors.white24,
                          width: isMovable ? 2 : 1,
                        ),
                      ),
                      child: CustomPaint(
                        painter: SlidingTilePainter(
                          image: _image!,
                          tileNumber: tileNumber,
                          gridSize: gridSize,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Hint-Button
            OutlinedButton.icon(
              onPressed: () => _showHint(l10n),
              icon: const Icon(Icons.lightbulb_outline),
              label: Text(l10n.puzzleShowHint),
            ),
          ],
        ),
      ),
    );
  }

  void _moveTile(int index) {
    final gridSize = widget.config.difficulty.gridSize;
    if (!_getNeighbors(_emptyIndex, gridSize).contains(index)) return;

    setState(() {
      // Tausche Tile mit leerem Feld
      _tiles[_emptyIndex] = _tiles[index];
      _tiles[index] = null;
      _emptyIndex = index;
      _moveCount++;

      // Prüfe Completion
      _checkCompletion();
    });
  }

  void _checkCompletion() {
    // Prüfe ob alle Tiles in richtiger Reihenfolge sind
    for (var i = 0; i < _tiles.length - 1; i++) {
      if (_tiles[i] != i) return;
    }

    // Letztes Tile muss leer sein
    if (_tiles.last != null) return;

    // Puzzle ist komplett!
    setState(() => _isPuzzleComplete = true);
  }

  void _showHint(AppLocalizations l10n) {
    final gridSize = widget.config.difficulty.gridSize;
    final neighbors = _getNeighbors(_emptyIndex, gridSize);

    if (neighbors.isEmpty) return;

    showCustomSnackBar(
      context,
      message: l10n.puzzleHintMovablePieces(neighbors.length),
      duration: const Duration(seconds: 2),
    );
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

/// Custom Painter für Sliding Puzzle Tiles
class SlidingTilePainter extends CustomPainter {
  const SlidingTilePainter({
    required this.image,
    required this.tileNumber,
    required this.gridSize,
  });

  final ui.Image image;
  final int tileNumber;
  final int gridSize;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    final row = tileNumber ~/ gridSize;
    final col = tileNumber % gridSize;

    final tileWidth = image.width / gridSize;
    final tileHeight = image.height / gridSize;

    final sourceRect = Rect.fromLTWH(
      col * tileWidth,
      row * tileHeight,
      tileWidth,
      tileHeight,
    );

    final destRect = Offset.zero & size;

    canvas.drawImageRect(image, sourceRect, destRect, paint);
  }

  @override
  bool shouldRepaint(SlidingTilePainter oldDelegate) =>
      image != oldDelegate.image ||
      tileNumber != oldDelegate.tileNumber ||
      gridSize != oldDelegate.gridSize;
}
