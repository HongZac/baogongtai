import 'package:material_color_utilities/material_color_utilities.dart' show MathUtils;


class MyContrastCurve {
  final double low;
  final double normal;
  final double medium;
  final double high;

  /// Creates a `MyContrastCurve` object.
  ///
  /// [low] Value for contrast level -1.0
  /// [normal] Value for contrast level 0.0
  /// [medium] Value for contrast level 0.5
  /// [high] Value for contrast level 1.0
  MyContrastCurve(this.low, this.normal, this.medium, this.high);

  /// Returns the value at a given contrast level.
  ///
  /// [contrastLevel] The contrast level. 0.0 is the default (normal);
  /// -1.0 is the lowest; 1.0 is the highest.
  /// Returns the value. For contrast ratios, a number between 1.0 and 21.0.
  ///
  /// [contrastLevel] == 0 时，返回 [normal]
  double get(double contrastLevel) {
    if (contrastLevel <= -1.0) {
      return low;
    } else if (contrastLevel < 0.0) {
      return MathUtils.lerp(low, normal, (contrastLevel - (-1)) / 1);
    } else if (contrastLevel < 0.5) {
      return MathUtils.lerp(normal, medium, (contrastLevel - 0) / 0.5);
    } else if (contrastLevel < 1.0) {
      return MathUtils.lerp(medium, high, (contrastLevel - 0.5) / 0.5);
    } else {
      return high;
    }
  }
}