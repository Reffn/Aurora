import 'package:flutter/material.dart';

/// Rating-Widget - Zeigt Bewertung als Sterne mit Farbcodierung an
/// 1-2 = Rot (negativ), 3 = Orange (neutral), 4-5 = Grün (positiv)
class RatingWidget extends StatelessWidget {
  const RatingWidget({
    required this.rating,
    super.key,
    this.size = 20,
    this.showNumber = false,
    this.interactive = false,
    this.onRatingChanged,
  }) : assert(
         rating >= 1 && rating <= 5,
         'Rating muss zwischen 1 und 5 liegen',
       );
  final int rating;
  final double size;
  final bool showNumber;
  final bool interactive;
  final ValueChanged<int>? onRatingChanged;

  @override
  Widget build(BuildContext context) {
    final color = _getRatingColor(rating);

    if (interactive) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 1; i <= 5; i++)
            GestureDetector(
              onTap: () => onRatingChanged?.call(i),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Icon(
                  i <= rating ? Icons.star : Icons.star_border,
                  size: size,
                  color: i <= rating ? color : Colors.grey,
                ),
              ),
            ),
          if (showNumber) ...[
            const SizedBox(width: 8),
            Text(
              '$rating',
              style: TextStyle(
                fontSize: size * 0.8,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ],
      );
    }

    // Non-interactive
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 1; i <= 5; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Icon(
              i <= rating ? Icons.star : Icons.star_border,
              size: size,
              color: i <= rating ? color : Colors.grey.withValues(alpha: 0.3),
            ),
          ),
        if (showNumber) ...[
          const SizedBox(width: 8),
          Text(
            '$rating',
            style: TextStyle(
              fontSize: size * 0.8,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ],
    );
  }

  /// Farbcodierung basierend auf Rating
  /// 1-2 = Rot (negativ), 3 = Orange (neutral), 4-5 = Grün (positiv)
  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1:
      case 2:
        return Colors.red;
      case 3:
        return Colors.orange;
      case 4:
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

/// Rating-Badge mit Container und Sentiment-Icon
class RatingBadge extends StatelessWidget {
  const RatingBadge({
    required this.rating,
    super.key,
  }) : assert(
         rating >= 1 && rating <= 5,
         'Rating muss zwischen 1 und 5 liegen',
       );
  final int rating;

  @override
  Widget build(BuildContext context) {
    final color = _getRatingColor(rating);
    final icon = _getSentimentIcon(rating);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 6),
          RatingWidget(rating: rating, size: 18),
        ],
      ),
    );
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1:
      case 2:
        return Colors.red;
      case 3:
        return Colors.orange;
      case 4:
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getSentimentIcon(int rating) {
    switch (rating) {
      case 1:
        return Icons.sentiment_very_dissatisfied;
      case 2:
        return Icons.sentiment_dissatisfied;
      case 3:
        return Icons.sentiment_neutral;
      case 4:
        return Icons.sentiment_satisfied;
      case 5:
        return Icons.sentiment_very_satisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }
}
