import 'package:html/dom.dart';

import '../ts_element.dart';

/// Contains methods from [Modifying the tree](https://www.crummy.com/software/TypedSoup/bs4/doc/#modifying-the-tree).
abstract class ITreeModifier {
  /// {@macro TsElement_string}
  set string(String? value);

  /// {@macro TsElement_name}
  set name(String? value);

  /// Adds an element just before the closing tags of the current element.
  ///
  /// If you want to pass [Node] instead [TsElement], you can do it via
  /// `TsElement.element.append(node)`.
  void append(TsElement element);

  /// Adds elements just before the closing tags of the current element,
  /// in order.
  void extend(List<TsElement> element);

  /// {@template tree_modifier_newTag}
  /// Creates a new [TsElement].
  ///
  /// * [name] - tag name
  /// * [attrs] - attributes to be added to the tag
  /// * [string] - text content
  /// {@endtemplate}
  TsElement newTag(String? name, {Map<String, String>? attrs, String? string});

  /// It is just like [append], except the new element does not necessarily
  /// go at the end of its parent’s .[contents]. It’ll be inserted at
  /// whatever numeric position you say, just after the opening tag of the
  /// current element.
  ///
  /// If the position is out of range, throws [RangeError].
  ///
  ///
  /// If you want to pass [Node] instead [TsElement], you can do it via
  /// `TsElement.element.insert(index, node)`.
  void insert(int position, TsElement element);

  /// Inserts an element immediately before the current element in
  /// the parse tree.
  ///
  /// [ref] specifies an position of an element, where should the insertion
  /// apply.
  ///
  /// If the [ref] is not in the parse tree, throws [RangeError].
  ///
  /// If you want to pass [Node] instead [TsElement], you can do it via
  /// `TsElement.element.insertBefore(node, nodeRef)`.
  void insertBefore(TsElement element, [TsElement? ref]);

  /// Inserts an element immediately following the element in the parse tree.
  ///
  /// Without [ref] argument it acts just like the [append] method.
  ///
  /// [ref] specifies an position of an element, where should the insertion
  /// apply.
  ///
  /// If the [ref] is not in the parse tree, throws [RangeError].
  void insertAfter(TsElement element, [TsElement? ref]);

  /// Removes the contents of a tag.
  void clear();

  /// Removes an element from the tree.
  ///
  /// Returns the element that was extracted.
  TsElement extract();

  /// Removes a tag from the tree, then completely destroys it and its contents.
  void decompose();

  /// Removes an element from the tree, and replaces it with [otherElement].
  ///
  /// Returns the element that was replaced.
  ///
  ///
  /// If you want to pass [Node] instead [TsElement], you can do it via
  /// `TsElement.element.replaceWith(node)`.
  TsElement replaceWith(TsElement otherElement);

  /// Replaces the element with its children.
  ///
  /// This is the opposite of [wrap]. It removes the tag but keeps its contents.
  ///
  /// Returns the element that was replaced.
  TsElement replaceWithChildren();

  /// Wraps an element in the tag you specify. It returns the new wrapper.
  TsElement wrap(TsElement newParentElement);

  /// Wraps an element in the tag you specify. It returns the new wrapper.
  ///
  /// [newParentElement] - the tag to wrap with
  /// [string] - optional string content to add to the wrapper
  TsElement wrapWithString(TsElement newParentElement, String string);

  /// [unwrap] is the opposite of [wrap].
  ///
  /// It replaces a tag with whatever’s inside that tag.
  ///
  /// It’s good for stripping out markup.
  ///
  /// Like [replaceWith], `unwrap` returns the tag that was replaced.
  TsElement? unwrap();

  /// Cleans up the parse tree by consolidating adjacent strings.
  void smooth();

  /// {@template tree_modifier_setAttr}
  /// Sets the [value] of an attribute on the specified element.
  ///
  /// If the attribute already exists, the value is updated;
  /// otherwise a new attribute is added with the specified [name] and [value].
  /// {@endtemplate}
  void operator []=(String name, String value);

  /// {@macro tree_modifier_setAttr}
  void setAttr(String name, String value);

  /// Removes the attribute with the specified [name] from the element.
  void removeAttr(String name);
}
