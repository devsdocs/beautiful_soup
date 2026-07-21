import '../ts_element.dart';

/// Contains some most common tags for quick and easy navigating
/// down the parse tree.
abstract class ITags {
  /// {@template tags_common_tag}
  /// Returns the first occurrence of this tag down the parse tree.
  /// {@endtemplate}
  TsElement? get html;

  /// {@macro tags_common_tag}
  TsElement? get head;

  /// {@macro tags_common_tag}
  TsElement? get body;

  /// {@macro tags_common_tag}
  TsElement? get title;

  /// {@macro tags_common_tag}
  TsElement? get h1;

  /// {@macro tags_common_tag}
  TsElement? get h2;

  /// {@macro tags_common_tag}
  TsElement? get h3;

  /// {@macro tags_common_tag}
  TsElement? get h4;

  /// {@macro tags_common_tag}
  TsElement? get h5;

  /// {@macro tags_common_tag}
  TsElement? get h6;

  /// {@macro tags_common_tag}
  TsElement? get p;

  /// {@macro tags_common_tag}
  TsElement? get a;

  /// {@macro tags_common_tag}
  TsElement? get b;

  /// {@macro tags_common_tag}
  TsElement? get i;

  /// {@macro tags_common_tag}
  TsElement? get img;

  /// {@macro tags_common_tag}
  TsElement? get table;

  /// {@macro tags_common_tag}
  TsElement? get ul;

  /// {@macro tags_common_tag}
  TsElement? get ol;

  /// {@macro tags_common_tag}
  TsElement? get dl;
}
