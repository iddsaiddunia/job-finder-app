import 'package:flutter/material.dart';

class RatingBar extends StatelessWidget {
  final double rating;
  final int maxRating;
  final void Function(double)? onRatingUpdate;
  final bool readOnly;

  const RatingBar({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.onRatingUpdate,
    this.readOnly = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final isFilled = index < rating.round();
        return IconButton(
          icon: Icon(
            isFilled ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 28,
          ),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
          onPressed: readOnly
              ? null
              : () {
                  if (onRatingUpdate != null) {
                    onRatingUpdate!(index + 1.0);
                  }
                },
        );
      }),
    );
  }
}
