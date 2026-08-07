import 'package:flutter/material.dart';

/// Displays one cell from a generated 4x2 illustration sheet without loading
/// eight separate bitmap files. The crop is done at paint time and remains
/// responsive inside cards of any size.
class IllustrationTile extends StatelessWidget {
  final String asset;
  final int index;
  final int columns;
  final int rows;
  final String? semanticLabel;
  final BorderRadius borderRadius;

  const IllustrationTile({
    super.key,
    required this.asset,
    required this.index,
    this.columns = 4,
    this.rows = 2,
    this.semanticLabel,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    assert(columns > 0 && rows > 0);
    assert(index >= 0 && index < columns * rows);

    return Semantics(
      image: true,
      label: semanticLabel,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : 100.0;
          final height = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : width;
          final column = index % columns;
          final row = index ~/ columns;

          return ClipRRect(
            borderRadius: borderRadius,
            child: ColoredBox(
              color: const Color(0xFFFFF8E8),
              child: OverflowBox(
                alignment: Alignment.topLeft,
                minWidth: width * columns,
                maxWidth: width * columns,
                minHeight: height * rows,
                maxHeight: height * rows,
                child: Transform.translate(
                  offset: Offset(-column * width, -row * height),
                  child: Image.asset(
                    asset,
                    width: width * columns,
                    height: height * rows,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.black38,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
