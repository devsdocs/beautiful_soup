import 'package:html/dom.dart';

import '../ts_element.dart';

/// Contains methods from [Navigating the tree](https://www.crummy.com/software/TypedSoup/bs4/doc/#navigating-the-tree).
abstract class ITreeNavigator {
  /// {@template tree_navigator_children}
  /// The element's (tag's) children.
  /// {@endtemplate}
  List<TsElement> get children;

  /// {@macro tree_navigator_children}
  ///
  /// Same as [element.children].
  List<TsElement> get contents;

  /// The element's (tag's) descendants.
  ///
  /// Similar to [children] but it iterates recursively.
  List<TsElement> get descendants;

  /// Returns the element itself followed by all its descendants.
  ///
  /// This is useful when you want to include the current element in descendant navigation.
  List<TsElement> get selfAndDescendants;

  /// {@template TsElement_string}
  /// Returns or modifies the text of element(s).
  /// {@endtemplate}
  String get string;

  /// The element's parent.
  ///
  /// Returns null if this node either does not have a parent or its parent is
  /// not an element.
  TsElement? get parent;

  /// The element's all parents.
  ///
  /// Iterates from the element buried deep within the document,
  /// to the very top of the document.
  List<TsElement> get parents;

  /// Gets previous element on the same level of the parse tree.
  TsElement? get previousSibling;

  /// Gets all previous elements on the same level of the parse tree.
  List<TsElement> get previousSiblings;

  /// Gets next element on the same level of the parse tree.
  TsElement? get nextSibling;

  /// Gets all next elements on the same level of the parse tree.
  List<TsElement> get nextSiblings;

  /// {@template tree_navigator_nextElement}
  /// The [nextElement] is an element that was parsed immediately afterwards
  /// (firstly searches next elements of [children], if empty then
  /// [nextSiblings]).
  ///
  /// Use [nextParsed] if you want to get any type
  /// (doc comment, part of string, ...).
  /// {@endtemplate}
  TsElement? get nextElement;

  /// {@macro tree_navigator_nextElement}
  ///
  /// Returns a list of [nextElement]s.
  List<TsElement> get nextElements;

  /// {@template tree_navigator_previousElement}
  /// The [previousElement] is an element that was parsed
  /// immediately before the current element
  /// (firstly searches [previousSiblings], if empty then [parent]).
  ///
  /// Use [previousParsed] if you want to get any type
  /// (doc comment, part of string, ...).
  /// {@endtemplate}
  TsElement? get previousElement;

  /// {@macro tree_navigator_previousElement}
  ///
  /// Returns a list of [previousElement]s.
  List<TsElement> get previousElements;

  /// {@template tree_navigator_nextParsed}
  /// Similar to [nextElement] but it returns a [Node] of what was parsed
  /// immediately after the current element. It might be doc comment, element,
  /// part of string, etc...
  ///
  /// To get the [String] (data) representation of this [Node], use
  /// `node.data`.
  /// {@endtemplate}
  Node? get nextParsed;

  /// {@macro tree_navigator_nextParsed}
  ///
  /// Returns a list of [nextParsed]s.
  List<Node> get nextParsedAll;

  /// {@template tree_navigator_previousParsed}
  /// Similar to [previousElement] but it returns a [Node] of what was parsed
  /// immediately before the current element. It might be doc comment, element,
  /// part of string, etc...
  ///
  /// To get the [String] (data) representation of this [Node], use
  /// `node.data`.
  /// {@endtemplate}
  Node? get previousParsed;

  /// {@macro tree_navigator_previousParsed}
  ///
  /// Returns a list of [previousParsed]s.
  List<Node> get previousParsedAll;

  /// Returns the element itself followed by all its parents.
  ///
  /// This is useful when you want to include the current element in parent navigation.
  List<TsElement> get selfAndParents;

  /// Returns the element itself followed by all its next elements.
  ///
  /// This is useful when you want to include the current element in forward navigation.
  List<TsElement> get selfAndNextElements;

  /// Returns the element itself followed by all its previous elements.
  ///
  /// This is useful when you want to include the current element in backward navigation.
  List<TsElement> get selfAndPreviousElements;

  /// Returns the element itself followed by all its next siblings.
  ///
  /// This is useful when you want to include the current element in sibling navigation.
  List<TsElement> get selfAndNextSiblings;

  /// Returns the element itself followed by all its previous siblings.
  ///
  /// This is useful when you want to include the current element in sibling navigation.
  List<TsElement> get selfAndPreviousSiblings;
}
