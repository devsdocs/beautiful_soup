// ignore_for_file: non_constant_identifier_names

import 'package:typed_soup/typed_soup.dart';
import 'package:html/dom.dart';

import 'interface/interface.dart';
import 'tags.dart';

final _firstChildRegex = RegExp(r':first-child\b');
final _nthChildRegex = RegExp(r':nth-child\((.*?)\)');
final _nthChildFormulaRegex = RegExp(r'^\s*([-+]?\d*)?n\s*([-+]\s*\d+)?\s*$');

///
class Shared extends Tags implements ITreeSearcher, IOutput {
  @override
  TsElement? findFirstAny() =>
      ((element ?? doc).querySelector('html') as Element?)?.bs4 ??
      ((element ?? doc).querySelector('*') as Element?)?.bs4;

  @override
  TsElement? find(
    String name, {
    String? id,
    String? class_,
    Map<String, Object>? attrs,
    Pattern? regex,
    Pattern? string,
    String? selector,
  }) {
    if (selector != null) {
      if (selector.contains(':nth-child') ||
          selector.contains(':first-child')) {
        return findAll('', selector: selector).firstOrNull;
      }
      return ((element ?? doc).querySelector(selector) as Element?)?.bs4;
    }
    if (id == null && class_ == null && regex == null && string == null) {
      bool anyTag = _isAnyTag(name);
      bool validTag = _isValidTag(name);
      if (attrs == null && !anyTag && validTag) {
        return ((element ?? doc).querySelector(name) as Element?)?.bs4;
      }
      final cssSelector = ((!validTag || anyTag) && (attrs == null))
          ? '*'
          : _selectorBuilder(tagName: validTag ? name : '*', attrs: attrs!);
      return ((element ?? doc).querySelector(cssSelector) as Element?)?.bs4;
    }
    return findAll(
      name,
      id: id,
      class_: class_,
      attrs: attrs,
      regex: regex,
      string: string,
      selector: selector,
    ).firstOrNull;
  }

  @override
  List<TsElement> findAll(
    String name, {
    String? id,
    String? class_,
    Map<String, Object>? attrs,
    Pattern? regex,
    Pattern? string,
    String? selector,
    int? limit,
  }) {
    assert(limit == null || limit >= 0);

    if (selector != null) {
      // Handle :nth-child / :first-child if present
      String cleanSelector = selector;
      var hasFirstChild = false;
      var nthChildExpression = '';

      if (_firstChildRegex.hasMatch(selector)) {
        hasFirstChild = true;
        cleanSelector = cleanSelector.replaceAll(_firstChildRegex, '');
      } else if (_nthChildRegex.hasMatch(selector)) {
        final match = _nthChildRegex.firstMatch(selector);
        if (match != null) {
          nthChildExpression = match.group(1) ?? '';
          cleanSelector = cleanSelector.replaceAll(_nthChildRegex, '');
        }
      }

      cleanSelector = cleanSelector.trim();
      // If selector becomes empty (matches *) or ends with a combinator such as
      // "div >" after removing :nth-child, normalize it to include the
      // universal selector.
      if (cleanSelector.isEmpty) {
        cleanSelector = '*';
      } else if (RegExp(r'[>+~]\s*$').hasMatch(cleanSelector)) {
        cleanSelector = '$cleanSelector *';
      }

      final elements =
          ((element ?? doc).querySelectorAll(cleanSelector) as List<Element>)
              .map((e) => e.bs4)
              .toList();

      if (hasFirstChild) {
        return elements.where((e) {
          final parent = e.element?.parentNode;
          if (parent == null) return false;
          // :first-child means it is the first ELEMENT child
          // package:html parent.children returns elements only
          final children = parent.children;
          return children.isNotEmpty && children.first == e.element;
        }).toList();
      }

      if (nthChildExpression.isNotEmpty) {
        return elements.where((e) {
          return _isNthChildMatch(e, nthChildExpression);
        }).toList();
      }

      return elements;
    }
    bool anyTag = _isAnyTag(name);
    bool validTag = _isValidTag(name);
    if (attrs == null && !anyTag && validTag) {
      final elements =
          ((element ?? doc).querySelectorAll(name) as List<Element>)
              .map((e) => e.bs4)
              .toList();
      final filtered = _filterResults(
        allResults: elements.toList(),
        id: id,
        class_: class_,
        regex: regex,
        string: string,
      );
      return _limitedList(filtered, limit);
    }
    final cssSelector = ((!validTag || anyTag) && (attrs == null))
        ? '*'
        : _selectorBuilder(tagName: validTag ? name : '*', attrs: attrs!);
    final elements =
        ((element ?? doc).querySelectorAll(cssSelector) as List<Element>).map(
          (e) => e.bs4,
        );

    final filtered = _filterResults(
      allResults: elements.toList(),
      id: id,
      class_: class_,
      regex: regex,
      string: string,
    );
    return _limitedList(filtered, limit);
  }

  @override
  TsElement? findParent(
    String name, {
    String? id,
    String? class_,
    Map<String, Object>? attrs,
    Pattern? regex,
    Pattern? string,
    String? selector,
  }) {
    final filtered = findParents(name, attrs: attrs, selector: selector);
    return filtered.firstOrNull;
  }

  @override
  List<TsElement> findParents(
    String name, {
    String? id,
    String? class_,
    Map<String, Object>? attrs,
    Pattern? regex,
    Pattern? string,
    String? selector,
    int? limit,
  }) {
    assert(limit == null || limit >= 0);
    final matched = <TsElement>[];

    final bs4 = _bs4;
    final bs4Parents = bs4.parents;
    if (bs4Parents.isEmpty) return matched;

    final topElement = _getTopElement(bs4);
    final allResults = _getAllResults(
      topElement: topElement,
      name: name,
      class_: class_,
      id: id,
      attrs: attrs,
      regex: regex,
      string: string,
      selector: selector,
    );

    final filtered = _findMatches(allResults, bs4Parents);
    matched.addAll(List.of(filtered).reversed);

    return _limitedList(matched, limit);
  }

  @override
  TsElement? findNextSibling(
    String name, {
    String? id,
    String? class_,
    Map<String, Object>? attrs,
    Pattern? regex,
    Pattern? string,
    String? selector,
  }) {
    final filtered = findNextSiblings(name, attrs: attrs, selector: selector);
    return filtered.firstOrNull;
  }

  @override
  List<TsElement> findNextSiblings(
    String name, {
    String? id,
    String? class_,
    Map<String, Object>? attrs,
    Pattern? regex,
    Pattern? string,
    String? selector,
    int? limit,
  }) {
    assert(limit == null || limit >= 0);

    final matched = <TsElement>[];
    final bs4 = _bs4;
    final bs4NextSiblings = bs4.nextSiblings;
    if (bs4NextSiblings.isEmpty) return matched;

    final topElement = _getTopElement(bs4);
    final allResults = _getAllResults(
      topElement: topElement,
      name: name,
      class_: class_,
      id: id,
      attrs: attrs,
      regex: regex,
      string: string,
      selector: selector,
    );

    final filtered = _findMatches(allResults, bs4NextSiblings);
    matched.addAll(filtered);

    return _limitedList(matched, limit);
  }

  @override
  TsElement? findPreviousSibling(
    String name, {
    String? id,
    String? class_,
    Map<String, Object>? attrs,
    Pattern? regex,
    Pattern? string,
    String? selector,
  }) {
    final filtered = findPreviousSiblings(
      name,
      attrs: attrs,
      selector: selector,
    );
    return filtered.firstOrNull;
  }

  @override
  List<TsElement> findPreviousSiblings(
    String name, {
    String? id,
    String? class_,
    Map<String, Object>? attrs,
    Pattern? regex,
    Pattern? string,
    String? selector,
    int? limit,
  }) {
    assert(limit == null || limit >= 0);

    final matched = <TsElement>[];
    final bs4 = _bs4;
    final bs4PrevSiblings = bs4.previousSiblings;
    if (bs4PrevSiblings.isEmpty) return matched;

    final topElement = _getTopElement(bs4);
    final allResults = _getAllResults(
      topElement: topElement,
      name: name,
      class_: class_,
      id: id,
      attrs: attrs,
      regex: regex,
      string: string,
      selector: selector,
    );

    final filtered = _findMatches(allResults, bs4PrevSiblings);
    matched.addAll(List.of(filtered).reversed);

    return _limitedList(matched, limit);
  }

  @override
  TsElement? findNextElement(
    String name, {
    String? id,
    String? class_,
    Map<String, Object>? attrs,
    Pattern? regex,
    Pattern? string,
    String? selector,
  }) {
    final filtered = findAllNextElements(
      name,
      attrs: attrs,
      selector: selector,
    );
    return filtered.firstOrNull;
  }

  @override
  List<TsElement> findAllNextElements(
    String name, {
    String? id,
    String? class_,
    Map<String, Object>? attrs,
    Pattern? regex,
    Pattern? string,
    String? selector,
    int? limit,
  }) {
    assert(limit == null || limit >= 0);

    final matched = <TsElement>[];
    final bs4 = _bs4;
    final bs4NextElements = bs4.nextElements;
    if (bs4NextElements.isEmpty) return matched;

    final topElement = _getTopElement(bs4);
    final allResults = _getAllResults(
      topElement: topElement,
      name: name,
      class_: class_,
      id: id,
      attrs: attrs,
      regex: regex,
      string: string,
      selector: selector,
    );

    final filtered = _findMatches(allResults, bs4NextElements);
    matched.addAll(filtered);

    return _limitedList(matched, limit);
  }

  @override
  TsElement? findPreviousElement(
    String name, {
    String? id,
    String? class_,
    Map<String, Object>? attrs,
    Pattern? regex,
    Pattern? string,
    String? selector,
  }) {
    final filtered = findAllPreviousElements(
      name,
      attrs: attrs,
      selector: selector,
    );
    return filtered.firstOrNull;
  }

  @override
  List<TsElement> findAllPreviousElements(
    String name, {
    String? id,
    String? class_,
    Map<String, Object>? attrs,
    Pattern? regex,
    Pattern? string,
    String? selector,
    int? limit,
  }) {
    assert(limit == null || limit >= 0);

    final matched = <TsElement>[];
    final bs4 = _bs4;
    final bs4PrevElements = bs4.previousElements;
    if (bs4PrevElements.isEmpty) return matched;

    final topElement = _getTopElement(bs4);
    final allResults = _getAllResults(
      topElement: topElement,
      name: name,
      class_: class_,
      id: id,
      attrs: attrs,
      regex: regex,
      string: string,
      selector: selector,
    );

    final filtered = _findMatches(allResults, bs4PrevElements);
    matched.addAll(List.of(filtered).reversed);

    return _limitedList(matched, limit);
  }

  @override
  Node? findNextParsed({RegExp? pattern, int? nodeType}) {
    final filtered = findNextParsedAll(pattern: pattern, nodeType: nodeType);
    return filtered.firstOrNull;
  }

  @override
  List<Node> findNextParsedAll({RegExp? pattern, int? nodeType, int? limit}) {
    assert(limit == null || limit >= 0);

    final bs4 = _bs4;
    final bs4NextParsedAll = bs4.nextParsedAll;
    if (bs4NextParsedAll.isEmpty) return <Node>[];
    if (pattern == null && nodeType == null) {
      return _limitedList(bs4NextParsedAll, limit);
    }

    final filtered = bs4NextParsedAll.where((node) {
      if (pattern != null && nodeType == null) {
        return pattern.hasMatch(node.data);
      } else if (pattern == null && nodeType != null) {
        return nodeType == node.nodeType;
      } else {
        return (nodeType == node.nodeType) && (pattern!.hasMatch(node.data));
      }
    });

    return _limitedList(filtered.toList(), limit);
  }

  @override
  Node? findPreviousParsed({RegExp? pattern, int? nodeType}) {
    final filtered = findPreviousParsedAll(
      pattern: pattern,
      nodeType: nodeType,
    );
    return filtered.firstOrNull;
  }

  @override
  List<Node> findPreviousParsedAll({
    RegExp? pattern,
    int? nodeType,
    int? limit,
  }) {
    assert(limit == null || limit >= 0);

    final bs4 = _bs4;
    final bs4PrevParsedAll = bs4.previousParsedAll;
    if (bs4PrevParsedAll.isEmpty) return <Node>[];
    if (pattern == null && nodeType == null) {
      return _limitedList(bs4PrevParsedAll, limit);
    }

    final filtered = bs4PrevParsedAll.where((node) {
      if (pattern != null && nodeType == null) {
        return pattern.hasMatch(node.data);
      } else if (pattern == null && nodeType != null) {
        return nodeType == node.nodeType;
      } else {
        return (nodeType == node.nodeType) && (pattern!.hasMatch(node.data));
      }
    });

    return _limitedList(filtered.toList(), limit);
  }

  @override
  String getText({String separator = '', bool strip = false}) {
    if (separator.isEmpty && !strip) {
      return element?.text ?? _bs4.text;
    }

    final texts =
        _bs4.nextParsedAll
            .where((node) => node.nodeType == Node.TEXT_NODE)
            .map((textNode) => strip ? textNode.data.trim() : textNode.data)
            .toList()
          ..removeWhere((e) => e.isEmpty);

    return texts.join(separator);
  }

  @override
  String get text => getText();

  @override
  List<TsElement> select(String selector, {int? limit}) {
    return findAll('*', selector: selector, limit: limit);
  }

  @override
  TsElement? select_one(String selector) {
    return find('*', selector: selector);
  }

  @override
  Iterable<String> get strings sync* {
    Iterable<String> collectStrings(Node node) sync* {
      if (node.nodeType == Node.TEXT_NODE) {
        yield node.data;
      }
      if (node.hasChildNodes()) {
        for (final child in node.nodes) {
          yield* collectStrings(child);
        }
      }
    }

    final target = element ?? _bs4.element;
    if (target != null) {
      yield* collectStrings(target);
    }
  }

  @override
  Iterable<String> get strippedStrings sync* {
    for (final str in strings) {
      final stripped = str.trim();
      if (stripped.isNotEmpty) {
        yield stripped;
      }
    }
  }

  @override
  String prettify() {
    final topElement = findFirstAny()?.clone(true);
    if (topElement == null ||
        topElement.element == null ||
        topElement.nextParsed == null) {
      return _bs4.outerHtml;
    }

    final strBuffer = StringBuffer();
    void indent(int? indentation) {
      for (int i = 0; i < (indentation ?? 1); i++) {
        strBuffer.write(' ');
      }
    }

    final topElementData = _TagDataExtractor.parseElement(topElement.element!);
    final topClosingTag = topElementData.closingTag;
    strBuffer
      ..write(topElementData.startingTag)
      ..write('\n');

    final lists = <_TagDataExtractor>[];
    if (topElement.element!.hasChildNodes()) {
      final children = topElement.element!.nodes;

      var spaces = 1;
      for (final child in children) {
        spaces = 1;
        final current = _TagDataExtractor.parseNode(child, indentation: spaces);
        lists.add(current);

        final descendants = child.nodes
            .map((node) {
              spaces++;
              return _recursiveNodeExtractorSearch(node, indentation: spaces);
            })
            .expand((e) => e)
            .toList();
        lists.addAll(descendants);
      }
    }

    _TagDataExtractor? prevNode;
    for (final item in lists) {
      indent(item.indentation);
      strBuffer
        ..write(item.isElement ? item.startingTag : item.node.data)
        ..write('\n');

      if (prevNode != null && prevNode.isElement && prevNode != item) {
        indent(prevNode.indentation);
        strBuffer
          ..write(prevNode.closingTag)
          ..write('\n');
      }

      prevNode = item;
    }

    strBuffer.write(topClosingTag);
    return strBuffer.toString();
  }

  TsElement get _bs4 => element != null ? element!.bs4 : findFirstAny()!;
}

String _selectorBuilder({
  required String tagName,
  required Map<String, Object> attrs,
}) {
  final strBuffer = StringBuffer()..write(tagName);
  for (var entry in attrs.entries) {
    final attrName = entry.key;
    final attrValue = entry.value;
    assert(
      attrValue is bool || attrValue is String,
      'The allowed type of value of an attribute is '
      'either String or bool but was: ${attrValue.runtimeType}',
    );
    final attrHasValue = !(attrValue is bool && attrValue == true);
    if (attrHasValue) {
      // if the value space then search for exact attribute, otherwise search
      // any, https://drafts.csswg.org/selectors-4/#attribute-representation
      final searchMode = attrValue.toString().contains(' ') ? ' ' : '~';
      strBuffer.write('[$attrName$searchMode="$attrValue"]');
    } else {
      strBuffer.write('[$attrName]');
    }
  }
  return strBuffer.toString();
}

TsElement _getTopElement(TsElement bs4) {
  final parents = bs4.parents;
  return parents.isEmpty ? bs4 : parents.last;
}

List<TsElement> _filterResults({
  required List<TsElement> allResults,
  required String? id,
  required String? class_,
  required Pattern? regex,
  required Pattern? string,
}) {
  if (id == null && class_ == null && regex == null && string == null) {
    return allResults;
  }

  var filtered = List.of(allResults);
  if (class_ != null) {
    filtered = List.of(
      filtered,
    ).where((e) => e.className.contains(class_)).toList();
  }
  if (id != null) {
    filtered = List.of(filtered).where((e) => e.id == id).toList();
  }
  if (regex != null) {
    final regExp = regex.asRegExp;
    filtered = List.of(filtered).where((e) {
      if (regExp.hasMatch(e.name ?? '')) return true;
      return false;
    }).toList();
  }
  if (string != null) {
    final regExp = string.asRegExp;
    filtered = List.of(filtered).where((e) {
      if (regExp.hasMatch(e.string)) return true;
      return false;
    }).toList();
  }
  return filtered;
}

bool _isAnyTag(String name) => name == '*';

bool _isValidTag(String name) => name != '';

List<TsElement> _getAllResults({
  required TsElement topElement,
  required String name,
  required String? id,
  required String? class_,
  required Map<String, Object>? attrs,
  required Pattern? regex,
  required Pattern? string,
  required String? selector,
}) {
  final allResults = topElement.findAll(
    name,
    attrs: attrs,
    regex: regex,
    string: string,
    selector: selector,
  );

  // findAll does not return top most element, thus must be checked if
  // it matches as well
  if (attrs == null &&
      selector == null &&
      id == null &&
      class_ == null &&
      string == null &&
      regex == null) {
    if (name == '*' || name == topElement.name) {
      allResults.insert(0, topElement);
    }
  }

  return allResults;
}

Iterable<TsElement> _findMatches(
  List<TsElement> allResults,
  List<TsElement> filteredResults,
) {
  return allResults.where((anyResult) {
    return filteredResults.any((parent) {
      return parent.element == anyResult.element;
    });
  });
}

List<E> _limitedList<E>(List<E> list, int? limit) {
  return limit == null ? list : list.take(limit).toList();
}

class _TagDataExtractor {
  const _TagDataExtractor._({
    required this.node,
    this.startingTag = '',
    this.closingTag = '',
    this.indentation = 1,
  });

  final Node node;
  final String startingTag;
  final String closingTag;
  final int indentation;

  bool get isElement => node is Element;

  factory _TagDataExtractor.parseNode(Node node, {int? indentation}) {
    return node is Element
        ? _TagDataExtractor.parseElement(node, indentation: indentation)
        : _TagDataExtractor._(node: node, indentation: indentation ?? 1);
  }

  factory _TagDataExtractor.parseElement(Element element, {int? indentation}) {
    final topElement = element.clone(false);
    final closingTag = '</${topElement.localName}>';
    final startingTag = topElement.outerHtml.replaceFirst(closingTag, '');
    return _TagDataExtractor._(
      node: element,
      startingTag: startingTag,
      closingTag: closingTag,
      indentation: indentation ?? 1,
    );
  }

  @override
  String toString() =>
      '_TagDataExtractor{node: $node, startingTag: $startingTag, closingTag: $closingTag, indentation: $indentation}';
}

Iterable<_TagDataExtractor> _recursiveNodeExtractorSearch(
  Node node, {
  int? indentation,
}) sync* {
  yield _TagDataExtractor.parseNode(node, indentation: indentation ?? 1);
  for (final e in node.nodes) {
    yield* _recursiveNodeExtractorSearch(e, indentation: indentation ?? 1);
  }
}

bool _isNthChildMatch(TsElement bs4, String expression) {
  expression = expression.trim();
  final parent = bs4.element?.parentNode;
  if (parent == null) return false;

  final children = parent.children;
  final index = children.indexOf(bs4.element!) + 1; // 1-based index

  if (expression == 'odd') {
    return index % 2 == 1;
  }
  if (expression == 'even') {
    return index % 2 == 0;
  }

  // Handle integers
  final nIndex = int.tryParse(expression);
  if (nIndex != null) {
    return index == nIndex;
  }

  // Handle formula An+B
  // 2n+1, 3n+0, -n+3, etc.
  final match = _nthChildFormulaRegex.firstMatch(expression);
  if (match != null) {
    var aStr = match.group(1);
    var bStr = match.group(2)?.replaceAll(' ', '');

    int a;
    if (aStr == null || aStr.isEmpty) {
      a = 1;
    } else if (aStr == '-') {
      a = -1;
    } else if (aStr == '+') {
      a = 1;
    } else {
      a = int.parse(aStr);
    }

    int b = (bStr == null || bStr.isEmpty) ? 0 : int.parse(bStr);

    // index = a * n + b
    // index - b = a * n
    // (index - b) % a == 0 and n >= 0

    if (a == 0) {
      return index == b;
    }

    // n must be non-negative integer
    // n = (index - b) / a
    if ((index - b) % a == 0) {
      final n = (index - b) ~/ a;
      return n >= 0;
    }
    return false;
  }

  return false;
}
