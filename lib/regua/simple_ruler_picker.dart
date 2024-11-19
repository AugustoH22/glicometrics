library;

import 'package:flutter/material.dart';

/// A widget that displays a ruler-like picker for selecting numeric values.
class SimpleRulerPicker extends StatefulWidget {
  /// The minimum value that can be selected.
  final int minValue;

  /// The maximum value that can be selected.
  final int maxValue;

  /// The initial value displayed when the picker is first shown. Must be between `minValue` and `maxValue`.
  final int initialValue;

  /// The size of the text for the scale labels.
  final double scaleLabelSize;

  /// The width of the text for the scale labels when axis is vertical.
  final double scaleLabelWidth;

  /// Padding below the scale labels, creating space between the labels and the bottom of the picker.
  final double scaleBottomPadding;

  /// The width of each scale item (i.e., the distance between the lines on the ruler).
  final int scaleItemWidth;

  /// Callback triggered whenever the selected value changes.
  final ValueChanged<int>? onValueChanged;

  /// Height of the long lines in the ruler (typically for major units).
  final double longLineHeight;

  /// Height of the short lines in the ruler (typically for minor units).
  final double shortLineHeight;

  /// Color of the ruler's lines (both long and short).
  final Color lineColor;

  /// Color of the selected item on the ruler.
  final Color selectedColor;

  /// Color of the scale labels.
  final Color labelColor;

  /// The thickness (stroke width) of the ruler's lines.
  final double lineStroke;

  /// The overall height of the ruler picker.
  final double height;

  /// The axis along which the picker scrolls.
  final Axis axis;

  /// Creates a [SimpleRulerPicker] widget.
  ///
  /// The [minValue] must be less than or equal to [initialValue],
  /// and [initialValue] must be less than or equal to [maxValue].
  const SimpleRulerPicker({
    super.key,
    this.minValue = 0,
    this.maxValue = 200,
    this.initialValue = 100,
    this.onValueChanged,
    this.scaleLabelSize = 14,
    this.scaleLabelWidth = 40,
    this.scaleBottomPadding = 6,
    this.scaleItemWidth = 10,
    this.longLineHeight = 24,
    this.shortLineHeight = 12,
    this.lineColor = Colors.grey,
    this.selectedColor = Colors.orange,
    this.labelColor = Colors.grey,
    this.lineStroke = 2,
    this.height = 100,
    this.axis = Axis.horizontal,
  }) : assert(
          minValue <= initialValue &&
              initialValue <= maxValue &&
              minValue < maxValue,
        );

  @override
  // ignore: library_private_types_in_public_api
  _SimpleRulerPickerState createState() => _SimpleRulerPickerState();
}

class _SimpleRulerPickerState extends State<SimpleRulerPicker> {
  late ScrollController _scrollController;
  late int _selectedValue;
  bool _isPosFixed = false;

  bool get _isHorizontalAxis => widget.axis == Axis.horizontal;

  int getScrolledItemIndex(double scrolledPixels, int itemWidth) {
    return scrolledPixels ~/ itemWidth;
  }

  bool onNotification(ScrollNotification scrollNotification) {
    if (scrollNotification is ScrollEndNotification) {
      final scrollPixels = scrollNotification.metrics.pixels;
      if (!_isPosFixed) {
        final jumpIndex =
            getScrolledItemIndex(scrollPixels, widget.scaleItemWidth);

        final jumpPixels =
            (jumpIndex * widget.scaleItemWidth) + (widget.scaleItemWidth / 2);

        Future.delayed(const Duration(milliseconds: 100)).then((_) {
          _isPosFixed = true;
          _scrollController.jumpTo(
            jumpPixels,
          );
        });
      }
    }
    return true;
  }

  void calculateNewValue(double scrollPixels) {
    final scrollPixels = _scrollController.position.pixels;
    final jumpIndex = getScrolledItemIndex(scrollPixels, widget.scaleItemWidth);
    final jumpValue = jumpIndex + widget.minValue;
    final newValue = jumpValue.clamp(widget.minValue, widget.maxValue);
    if (newValue != _selectedValue) {
      setState(() {
        _selectedValue = newValue.toInt();
      });
      widget.onValueChanged?.call(_selectedValue);
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    final rangeFromMinValue = widget.initialValue - widget.minValue;

    final initialItemMiddlePixels =
        (rangeFromMinValue * widget.scaleItemWidth) +
            (widget.scaleItemWidth / 2);

    _scrollController = ScrollController(
      initialScrollOffset: initialItemMiddlePixels,
    );

    _scrollController.addListener(() {
      calculateNewValue(_scrollController.position.pixels);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Listener(
            onPointerDown: (event) {
              FocusScope.of(context).requestFocus(FocusNode());
              _isPosFixed = false;
            },
            child: NotificationListener(
              onNotification: onNotification,
              child: LayoutBuilder(
                builder: (context, constraints) => ListView.builder(
                  padding: _isHorizontalAxis
                      ? EdgeInsets.only(
                          left: constraints.maxWidth / 2,
                          right: constraints.maxWidth / 2,
                        )
                      : EdgeInsets.only(
                          top: constraints.maxHeight / 2,
                          bottom: constraints.maxHeight / 2,
                        ),
                  controller: _scrollController,
                  scrollDirection: widget.axis,
                  itemCount: (widget.maxValue - widget.minValue) + 1,
                  itemBuilder: (context, index) {
                    final int value = widget.minValue + index;
                    return SizedBox(
                      width: _isHorizontalAxis
                          ? widget.scaleItemWidth.toDouble()
                          : null,
                      height: _isHorizontalAxis
                          ? null
                          : widget.scaleItemWidth.toDouble(),
                      child: CustomPaint(
                        painter: _RulerPainter(
                          value: value,
                          selectedValue: _selectedValue,
                          scaleLabelSize: widget.scaleLabelSize,
                          scaleBottomPadding: widget.scaleBottomPadding,
                          longLineHeight: widget.longLineHeight,
                          shortLineHeight: widget.shortLineHeight,
                          lineColor: widget.lineColor,
                          selectedColor: widget.selectedColor,
                          labelColor: widget.labelColor,
                          lineStroke: widget.lineStroke,
                          axis: widget.axis,
                          maxScaleLabelWidth: widget.scaleLabelWidth,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          _isHorizontalAxis
              ? _VerticalPointer(
                  selectedValue: _selectedValue,
                  selectedColor: widget.selectedColor,
                  longLineHeight: widget.longLineHeight,
                  scaleLabelSize: widget.scaleLabelSize,
                  scaleBottomPadding: widget.scaleBottomPadding,
                )
              : _HorizontalPointer(
                  selectedValue: _selectedValue,
                  selectedColor: widget.selectedColor,
                  longLineHeight: widget.longLineHeight,
                  scaleLabelWidth: widget.scaleLabelWidth,
                  scaleBottomPadding: widget.scaleBottomPadding,
                ),
        ],
      ),
    );
  }
}

class _HorizontalPointer extends StatelessWidget {
  const _HorizontalPointer({
    required this.selectedValue,
    required this.selectedColor,
    required this.longLineHeight,
    required this.scaleLabelWidth,
    required this.scaleBottomPadding,
  });

  final int selectedValue;
  final Color selectedColor;
  final double longLineHeight;
  final double scaleLabelWidth;
  final double scaleBottomPadding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 2,
            width: longLineHeight,
            color: selectedColor,
          ),
          SizedBox(
            width: scaleLabelWidth + scaleBottomPadding,
          ),
        ],
      ),
    );
  }
}

class _VerticalPointer extends StatelessWidget {
  const _VerticalPointer({
    required this.selectedValue,
    required this.selectedColor,
    required this.longLineHeight,
    required this.scaleLabelSize,
    required this.scaleBottomPadding,
  });

  final int selectedValue;
  final Color selectedColor;
  final double longLineHeight;
  final double scaleLabelSize;
  final double scaleBottomPadding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: longLineHeight + 20,
            width: 3,
            color: selectedColor,
          ),
          SizedBox(
            height: scaleLabelSize + scaleBottomPadding,
          ),
        ],
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  final int value;
  final int selectedValue;
  final double scaleLabelSize;
  final double maxScaleLabelWidth;
  final double scaleBottomPadding;
  final double longLineHeight;
  final double shortLineHeight;
  final Color lineColor;
  final Color selectedColor;
  final Color labelColor;
  final double lineStroke;
  final Axis axis;

  _RulerPainter({
    required this.value,
    required this.selectedValue,
    required this.scaleLabelSize,
    this.maxScaleLabelWidth = 40,
    required this.scaleBottomPadding,
    this.longLineHeight = 24,
    this.shortLineHeight = 12,
    this.lineColor = Colors.grey,
    this.selectedColor = Colors.orange,
    this.labelColor = Colors.grey,
    this.lineStroke = 2,
    this.axis = Axis.horizontal,
  });

  bool get _isHorizontalAxis => axis == Axis.horizontal;

  @override
  void paint(Canvas canvas, Size size) {
    // Highlight the selected scale in orange, otherwise keep it black/grey
    final Paint paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineStroke;

    // Draw scale line: Long line every 5 cm, short line every 1 cm
    final double lineHeight = value % 5 == 0 ? longLineHeight : shortLineHeight;

    final p1 = _isHorizontalAxis
        ? Offset(
            size.width / 2,
            size.height - scaleLabelSize - scaleBottomPadding,
          )
        : Offset(
            size.width - maxScaleLabelWidth - scaleBottomPadding,
            size.height / 2,
          );

    final p2 = _isHorizontalAxis
        ? Offset(
            size.width / 2,
            size.height - lineHeight - scaleLabelSize - scaleBottomPadding,
          )
        : Offset(
            size.width - lineHeight - maxScaleLabelWidth - scaleBottomPadding,
            size.height / 2,
          );

    canvas.drawLine(
      p1,
      p2,
      paint,
    );

    // Draw height text for every 10 cm, below the scale line
    if (value % 10 == 0) {
      final TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: '$value',
          style: TextStyle(
            color: value == selectedValue ? selectedColor : labelColor,
            fontSize: scaleLabelSize,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      final offset = _isHorizontalAxis
          ? Offset(
              size.width / 2 - textPainter.width / 2,
              size.height - scaleLabelSize,
            )
          : Offset(
              size.width - maxScaleLabelWidth,
              size.height / 2 - textPainter.height / 2,
            );

      textPainter.paint(
        canvas,
        offset,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
