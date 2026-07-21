import 'dart:collection';

import 'package:typed_soup/typed_soup.dart';
import 'package:html/dom.dart';

import 'helpers.dart';
import 'interface/interface.dart';
import 'shared.dart';

///
class TsElement extends Shared
    implements IElement, ITreeNavigator, ITreeModifier {
  TsElement._(Element element) {
    this.element = element;
  }

  ///
  factory TsElement(Element element) => TsElement._(element);

  bool _isDecomposed = false;

  ///
  bool get decomposed => _isDecomposed;

  Element get _element => element!;

  @override
  String? get name => _element.localName;

  @override
  String get outerHtml => _element.outerHtml;

  @override
  String get string => _element.text;

  @override
  set string(String? value) => _element.text = value;

  @override
  set name(String? name) {
    final newElement = Element.tag(name);

    final defaultNodes = _element.clone(true);
    newElement
      ..attributes = defaultNodes.attributes
      ..nodes.addAll(defaultNodes.nodes);

    if (_element.parentNode != null) {
      final index = _element.parentNode!.nodes.indexOf(_element);
      _element.parentNode!.nodes.insert(index, newElement);
      element = _element.parentNode!.nodes[index] as Element;
    }
  }

  @override
  Iterable<String> get strippedStrings sync* {
    final strLines = _element.text.split('\n');
    for (final str in strLines) {
      final trimmed = str.trimLeft();
      if (trimmed != '') {
        yield trimmed;
      }
    }
  }

  @override
  String get innerHtml => _element.innerHtml;

  @override
  set innerHtml(String value) => _element.innerHtml = value;

  @override
  String get className => _element.className;

  @override
  set className(String value) => _element.className = value;

  @override
  String get id => _element.id;

  @override
  set id(String value) => _element.id = value;

  @override
  List<TsElement> get children => _element.children.map((e) => e.bs4).toList();

  @override
  List<TsElement> get contents => children;

  @override
  List<TsElement> get descendants {
    return _element.children
        .map((e) => recursiveSearch(e.bs4))
        .expand((e) => e)
        .toList();
  }

  @override
  List<TsElement> get selfAndDescendants {
    return [this, ...descendants];
  }

  @override
  TsElement? get parent => _element.parent?.bs4;

  @override
  List<TsElement> get parents {
    final parents = <TsElement>[];
    TsElement? elementIter = parent;
    while (elementIter != null) {
      parents.add(elementIter);
      elementIter = elementIter.parent;
    }
    return parents;
  }

  @override
  TsElement? get previousSibling => _element.previousElementSibling?.bs4;

  @override
  List<TsElement> get previousSiblings {
    final previousSiblings = <TsElement>[];
    TsElement? elementIter = previousSibling;
    while (elementIter != null) {
      previousSiblings.add(elementIter);
      elementIter = elementIter.previousSibling;
    }
    return previousSiblings;
  }

  @override
  TsElement? get nextSibling => _element.nextElementSibling?.bs4;

  @override
  List<TsElement> get nextSiblings {
    final nextSiblings = <TsElement>[];
    TsElement? elementIter = nextSibling;
    while (elementIter != null) {
      nextSiblings.add(elementIter);
      elementIter = elementIter.nextSibling;
    }
    return nextSiblings;
  }

  @override
  TsElement? get nextElement {
    // find within children
    final children = this.children;
    if (children.isNotEmpty) {
      return children.first;
    }

    // find within next sibling
    final nextSibling = this.nextSibling;
    if (nextSibling != null) {
      return nextSibling;
    }

    // find within parent and next siblings
    var parent = this.parent;
    while (parent != null) {
      if (parent.nextSibling == null) {
        parent = parent.parent;
      } else {
        return parent.nextSibling;
      }
    }

    return null;
  }

  @override
  List<TsElement> get nextElements {
    final nextElements = <TsElement>[];

    // find within children
    nextElements.addAll(descendants);

    // find within next siblings
    nextElements.addAll(nextSiblings);

    // find within parent and next siblings
    var parent = this.parent;
    while (parent != null) {
      nextElements.addAll(parent.nextSiblings);
      parent = parent.parent;
    }

    return nextElements;
  }

  @override
  TsElement? get previousElement {
    // find within prev sibling
    final prevSibling = previousSibling;
    if (prevSibling != null) {
      return prevSibling;
    }

    // find within parent, or null
    return parent;
  }

  @override
  List<TsElement> get previousElements {
    final prevElements = <TsElement>[];

    // find within prev siblings
    prevElements.addAll(previousSiblings);

    // find within parent and prev siblings
    var parent = this.parent;
    while (parent != null) {
      prevElements
        ..add(parent)
        ..addAll(parent.previousSiblings);

      parent = parent.parent;
    }

    return prevElements;
  }

  @override
  List<TsElement> get selfAndParents {
    return [this, ...parents];
  }

  @override
  List<TsElement> get selfAndNextElements {
    return [this, ...nextElements];
  }

  @override
  List<TsElement> get selfAndPreviousElements {
    return [this, ...previousElements];
  }

  @override
  List<TsElement> get selfAndNextSiblings {
    return [this, ...nextSiblings];
  }

  @override
  List<TsElement> get selfAndPreviousSiblings {
    return [this, ...previousSiblings];
  }

  @override
  Node? get nextParsed {
    final element = this.element;
    if (element == null) return null;

    // find within children
    if (element.hasChildNodes()) {
      return element.nodes.first;
    }

    final parentNode = element.parentNode;
    if (parentNode == null) return null;

    // find within next siblings
    final nextIndex = _getCurrNodeIndex(parentNode, element) + 1;
    final allSiblings = parentNode.nodes;
    if (nextIndex < allSiblings.length) {
      return allSiblings[nextIndex];
    }

    // find within parent and next siblings
    Node prevNode = parentNode;
    Node? parent = parentNode.parentNode;
    while (parent != null) {
      final nextIndex = _getCurrNodeIndex(parent, prevNode) + 1;
      final allSiblings = parent.nodes;

      if (nextIndex < allSiblings.length) {
        return allSiblings[nextIndex];
      }

      prevNode = parent;
      parent = parent.parentNode;
    }

    return null;
  }

  @override
  List<Node> get nextParsedAll {
    final nextParsedAll = <Node>[];

    final element = this.element;
    if (element == null) return nextParsedAll;

    // find within children
    if (element.hasChildNodes()) {
      final descendants = element.nodes
          .map((node) => recursiveNodeSearch(node))
          .expand((e) => e)
          .toList();
      nextParsedAll.addAll(descendants);
    }

    final parentNode = element.parentNode;
    if (parentNode == null) return nextParsedAll;

    // find within next siblings (and their descendants)
    final nextIndex = _getCurrNodeIndex(parentNode, element) + 1;
    final allSiblings = parentNode.nodes;
    if (nextIndex < allSiblings.length) {
      final rangeList = allSiblings.getRange(nextIndex, allSiblings.length);
      for (final sibling in rangeList) {
        nextParsedAll.add(sibling);
        nextParsedAll.addAll(recursiveNodeSearch(sibling));
      }
    }

    // find within parent and next siblings (and their descendants)
    Node prevNode = parentNode;
    Node? parent = parentNode.parentNode;
    while (parent != null) {
      final nextIndex = _getCurrNodeIndex(parent, prevNode) + 1;
      final allSiblings = parent.nodes;

      if (nextIndex < allSiblings.length) {
        final rangeList = allSiblings.getRange(nextIndex, allSiblings.length);
        for (final sibling in rangeList) {
          nextParsedAll.add(sibling);
          nextParsedAll.addAll(recursiveNodeSearch(sibling));
        }
      }

      prevNode = parent;
      parent = parent.parentNode;
    }

    return nextParsedAll;
  }

  @override
  Node? get previousParsed {
    final element = this.element;
    if (element == null) return null;

    final parentNode = element.parentNode;
    if (parentNode == null) return null;

    // find within prev siblings
    final prevIndex = _getCurrNodeIndex(parentNode, element) - 1;
    final allSiblings = parentNode.nodes;
    if (prevIndex >= 0) {
      return allSiblings[prevIndex];
    }

    // find within parent or null
    return parentNode.parentNode;
  }

  @override
  List<Node> get previousParsedAll {
    final prevParsedAll = <Node>[];

    final element = this.element;
    if (element == null) return prevParsedAll;

    final parentNode = element.parentNode;
    if (parentNode == null) return prevParsedAll;

    // find within parent and prev siblings (and their descendants)
    final prevIndex = _getCurrNodeIndex(parentNode, element) - 1;
    final allSiblings = parentNode.nodes;
    if (prevIndex >= 0) {
      final rangeList = allSiblings.getRange(0, prevIndex + 1);
      for (final sibling in rangeList.toList().reversed) {
        prevParsedAll.add(sibling);
        prevParsedAll.addAll(recursiveNodeSearch(sibling));
      }
    }

    Node prevNode = parentNode;
    Node? parent = parentNode.parentNode;
    while (parent != null) {
      final prevIndex = _getCurrNodeIndex(parent, prevNode) - 1;
      final allSiblings = parent.nodes;

      if (prevIndex == -1) {
        // top most element (?)
        prevParsedAll.add(allSiblings.first);
        prevParsedAll.addAll(recursiveNodeSearch(allSiblings.first));
      } else if (prevIndex >= 0) {
        final rangeList = allSiblings.getRange(0, prevIndex + 1);
        for (final sibling in rangeList.toList().reversed) {
          prevParsedAll.add(sibling);
          prevParsedAll.addAll(recursiveNodeSearch(sibling));
        }
      }

      prevNode = parent;
      parent = parent.parentNode;
    }

    return prevParsedAll;
  }

  @override
  void append(TsElement element) => _element.append(element._element);

  @override
  void extend(List<TsElement> element) {
    for (final e in element) {
      _element.append(e._element);
    }
  }

  @override
  TsElement newTag(String? name, {Map<String, String>? attrs, String? string}) {
    return TypedSoup.newTag(name, attrs: attrs, string: string);
  }

  @override
  void insert(int position, TsElement element) =>
      _element.nodes.insert(position, element._element);

  @override
  void insertBefore(TsElement element, [TsElement? ref]) {
    if (ref == null) {
      insert(0, element);
    } else {
      _element.insertBefore(element._element, ref._element);
    }
  }

  @override
  void insertAfter(TsElement element, [TsElement? ref]) {
    if (ref == null) {
      _element.nodes.add(element._element);
    } else {
      final nodes = _element.nodes;
      final nl = nodes.length;
      final indexOf = nodes.indexOf(ref._element);
      if (indexOf < 0) {
        final msg = 'Referenced element does not exist in the parse tree.';
        throw (RangeError(msg));
      } else if ((nl - 1 == indexOf) ||
          (nl - 2 == indexOf && nodes[nl - 1].nodeType == 3)) {
        append(element);
      } else {
        _element.nodes.insert(indexOf + 1, element._element);
      }
    }
  }

  @override
  void clear() => element = _element.clone(false);

  @override
  TsElement extract() => (_element.remove() as Element).bs4;

  @override
  void decompose() {
    _isDecomposed = true;
    _element
      ..attributes.clear()
      ..text = null
      ..remove();
  }

  @override
  TsElement replaceWith(TsElement otherElement) =>
      (_element.replaceWith(otherElement._element) as Element).bs4;

  @override
  TsElement replaceWithChildren() {
    final children = _element.nodes.toList();
    for (final child in children) {
      _element.replaceWith(child);
    }
    return this;
  }

  @override
  TsElement wrap(TsElement newParentElement) {
    final newElement = newParentElement._element.clone(true)
      ..nodes.add(_element.clone(true));

    if (_element.parentNode != null) {
      final index = _element.parentNode!.nodes.indexOf(_element);
      _element.parentNode!.nodes.insert(index, newElement);
      element = _element.parentNode!.nodes[index] as Element;
    }
    return this;
  }

  @override
  TsElement wrapWithString(TsElement newParentElement, String string) {
    final newElement = newParentElement._element.clone(true);
    final textNode = Text(string);
    newElement.nodes.add(textNode);
    newElement.nodes.add(_element.clone(true));

    if (_element.parentNode != null) {
      final index = _element.parentNode!.nodes.indexOf(_element);
      _element.parentNode!.nodes.insert(index, newElement);
      element = _element.parentNode!.nodes[index] as Element;
    }
    return this;
  }

  @override
  TsElement? unwrap() {
    for (final child in _element.nodes) {
      if (child.nodeType == Node.ELEMENT_NODE) {
        final index = _element.nodes.indexOf(child);
        final insideElement = _element.nodes.elementAt(index).clone(true);
        _element.nodes
          ..removeAt(index)
          ..insertAll(index, insideElement.nodes);
      }
    }
    return null;
  }

  @override
  LinkedHashMap<Object, String> get attributes => _element.attributes;

  @override
  set attributes(LinkedHashMap<Object, String> attributes) =>
      _element.attributes = attributes;

  @override
  CssClassSet get classes => _element.classes;

  @override
  NodeList get nodes => _element.nodes;

  @override
  void reparentChildren(Node newParent) => _element.reparentChildren(newParent);

  @override
  void smooth() {
    void smoothNode(Node node) {
      if (node is Element && node.hasChildNodes()) {
        final nodes = node.nodes.toList();
        for (int i = 0; i < nodes.length - 1; i++) {
          if (nodes[i] is Text && nodes[i + 1] is Text) {
            final textNode = nodes[i] as Text;
            final nextTextNode = nodes[i + 1] as Text;
            textNode.data = '${textNode.data}${nextTextNode.data}';
            node.nodes.removeAt(i + 1);
            i--;
          }
        }
        for (final child in node.nodes) {
          smoothNode(child);
        }
      }
    }

    smoothNode(_element);
  }

  @override
  TsElement clone(bool deep) => (_element.clone(deep)).bs4;

  @override
  String? operator [](String name) => _element.attributes[name];

  @override
  void operator []=(String name, String value) =>
      _element.attributes[name] = value;

  @override
  String? getAttrValue(String name) => this[name];

  @override
  bool hasAttr(String name) => _element.attributes.containsKey(name);

  @override
  String? get(String name, {String? defaultValue}) {
    final value = this[name];
    return value ?? defaultValue;
  }

  @override
  void removeAttr(String name) => _element.attributes.remove(name);

  @override
  void setAttr(String name, String value) => this[name] = value;

  @override
  String toString() => outerHtml;
}

int _getCurrNodeIndex(Node parentNode, Node currentNode) {
  final allSiblings = parentNode.nodes;
  final nextIndex = allSiblings.indexOf(currentNode);
  return nextIndex;
}
