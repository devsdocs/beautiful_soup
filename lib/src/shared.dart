// ignore_for_file: non_constant_identifier_names
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:html/dom.dart';

import 'bs4_element.dart';
import 'extensions.dart';
import 'interface/interface.dart';
import 'tags.dart';

class Shared extends Tags implements ITreeSearcher, IOutput {
  @override
  Bs4Element? findFirstAny() =>
      ((element ?? doc).querySelector('html') as Element?)?.bs4 ??
      ((element ?? doc).querySelector('*') as Element?)?.bs4;

  @override
  Bs4Element? find(
    String name, {
    String? id,
    String? class_,
    Map<String, Object>? attrs,
    String? selector,
  }) {
    if (selector != null) {
      return ((element ?? doc).querySelector(selector) as Element?)?.bs4;
    }
    if (id == null && class_ == null) {
      bool anyTag = _isAnyTag(name);
      if (attrs == null && !anyTag) {
        return ((element ?? doc).querySelector(name) as Element?)?.bs4;
      }
      final cssSelector = (anyTag && attrs == null)
          ? '*'
          : _selectorBuilder(tagName: name, attrs: attrs!);
      return ((element ?? doc).querySelector(cssSelector) as Element?)?.bs4;
    }
    return findAll(
      name,
      id: id,
      class_: class_,
      attrs: attrs,
      selector: selector,
    ).firstOrNull;
  }

  @override
  List<Bs4Element> findAll(
    String name, {
    String? id,
    String? class_,
    Map<String, Object>? attrs,
    String? selector,
  }) {
    if (selector != null) {
      return ((element ?? doc).querySelectorAll(selector) as List<Element>)
          .map((e) => e.bs4)
          .toList();
    }
    bool anyTag = _isAnyTag(name);
    if (attrs == null && !anyTag) {
      final elements = ((element ?? doc).querySelectorAll(name) as List<Element>)
          .map((e) => e.bs4)
          .toList();
      return _filterResults(
        allResults: elements.toList(),
        id: id,
        class_: class_,
      );
    }
    final cssSelector = (anyTag && attrs == null)
        ? '*'
        : _selectorBuilder(tagName: name, attrs: attrs!);
    final elements =
        ((element ?? doc).querySelectorAll(cssSelector) as List<Element>)
            .map((e) => e.bs4);

    return _filterResults(
      allResults: elements.toList(),
      id: id,
      class_: class_,
    );
  }

  List<Bs4Element> _filterResults({
    required List<Bs4Element> allResults,
    required String? id,
    required String? class_,
  }) {
    if (id == null && class_ == null) return allResults;

    var filtered = List.of(allResults);
    if (class_ != null) {
      filtered =
          List.of(filtered).where((e) => e.className.contains(class_)).toList();
    }
    if (id != null) {
      filtered = List.of(filtered).where((e) => e.id == id).toList();
    }
    return filtered;
  }

  Bs4Element get _bs4 {
    if (element != null) return element!.bs4;
    return findFirstAny()!;
  }

  Bs4Element _getTopElement(Bs4Element bs4) {
    final parents = bs4.parents;
    return parents.isEmpty ? bs4 : parents.last;
  }

  List<Bs4Element> _getAllResults({
    required Bs4Element topElement,
    required String name,
    required String? id,
    required String? class_,
    required Map<String, Object>? attrs,
    required String? selector,
  }) {
    final allResults =
        topElement.findAll(name, attrs: attrs, selector: selector);

    // findAll does not return top most element, thus must be checked if
    // it matches as well
    if (attrs == null && selector == null) {
      if (name == '*' || name == topElement.name) {
        allResults.insert(0, topElement);
      }
    }

    return allResults;
  }

  Iterable<Bs4Element> _findMatches(
    List<Bs4Element> allResults,
    List<Bs4Element> filteredResults,
  ) {
    return allResults.where((anyResult) {
      return filteredResults.any((parent) {
        return parent.element == anyResult.element;
      });
    });
  }

  @override
  Bs4Element? findParent(
    String name, {
    String? id,
    String? class_,
    Map<String, Object>? attrs,
    String? selector,
  }) {
    final filtered = findParents(name, attrs: attrs, selector: selector);
    return filtered.isNotEmpty ? filtered.first : null;
  }

  @override
  List<Bs4Element> findParents(
    String name, {
    String? id,
    String? class_,
    Map<String, Object>? attrs,
    String? selector,
  }) {
    final matched = <Bs4Element>[];

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
      selector: selector,
    );

    final filtered = _findMatches(allResults, bs4Parents);
    matched.addAll(List.of(filtered).reversed);

    return matched;
  }

  @override
  Bs4Element? findNextSibling(
    String name, {
    String? id,
    String? class_,
    Map<String, Object>? attrs,
    String? selector,
  }) {
    final filtered = findNextSiblings(name, attrs: attrs, selector: selector);
    return filtered.isNotEmpty ? filtered.first : null;
  }

  @override
  List<Bs4Element> findNextSiblings(
    String name, {
    String? id,
    String? class_,
    Map<String, Object>? attrs,
    String? selector,
  }) {
    final matched = <Bs4Element>[];

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
      selector: selector,
    );

    final filtered = _findMatches(allResults, bs4NextSiblings);
    matched.addAll(filtered);

    return matched;
  }

  @override
  Bs4Element? findPreviousSibling(
    String name, {
    String? id,
    String? class_,
    Map<String, Object>? attrs,
    String? selector,
  }) {
    final filtered = findPreviousSiblings(
      name,
      attrs: attrs,
      selector: selector,
    );
    return filtered.isNotEmpty ? filtered.first : null;
  }

  @override
  List<Bs4Element> findPreviousSiblings(
    String name, {
    String? id,
    String? class_,
    Map<String, Object>? attrs,
    String? selector,
  }) {
    final matched = <Bs4Element>[];

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
      selector: selector,
    );

    final filtered = _findMatches(allResults, bs4PrevSiblings);
    matched.addAll(List.of(filtered).reversed);

    return matched;
  }

  @override
  Bs4Element? findNextElement(
    String name, {
    String? id,
    String? class_,
    Map<String, Object>? attrs,
    String? selector,
  }) {
    final filtered =
        findAllNextElements(name, attrs: attrs, selector: selector);
    return filtered.isNotEmpty ? filtered.first : null;
  }

  @override
  List<Bs4Element> findAllNextElements(
    String name, {
    String? id,
    String? class_,
    Map<String, Object>? attrs,
    String? selector,
  }) {
    final matched = <Bs4Element>[];

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
      selector: selector,
    );

    final filtered = _findMatches(allResults, bs4NextElements);
    matched.addAll(filtered);

    return matched;
  }

  @override
  Bs4Element? findPreviousElement(
    String name, {
    String? id,
    String? class_,
    Map<String, Object>? attrs,
    String? selector,
  }) {
    final filtered = findAllPreviousElements(
      name,
      attrs: attrs,
      selector: selector,
    );
    return filtered.isNotEmpty ? filtered.first : null;
  }

  @override
  List<Bs4Element> findAllPreviousElements(
    String name, {
    String? id,
    String? class_,
    Map<String, Object>? attrs,
    String? selector,
  }) {
    final matched = <Bs4Element>[];

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
      selector: selector,
    );

    final filtered = _findMatches(allResults, bs4PrevElements);
    matched.addAll(List.of(filtered).reversed);

    return matched;
  }

  @override
  Node? findNextParsed({RegExp? pattern, int? nodeType}) {
    final filtered = findNextParsedAll(pattern: pattern, nodeType: nodeType);
    return filtered.isNotEmpty ? filtered.first : null;
  }

  @override
  List<Node> findNextParsedAll({RegExp? pattern, int? nodeType}) {
    final bs4 = _bs4;
    final bs4NextParsedAll = bs4.nextParsedAll;
    if (bs4NextParsedAll.isEmpty) return <Node>[];
    if (pattern == null && nodeType == null) return bs4NextParsedAll;

    final filtered = bs4NextParsedAll.where((node) {
      if (pattern != null && nodeType == null) {
        return pattern.hasMatch(node.data);
      } else if (pattern == null && nodeType != null) {
        return nodeType == node.nodeType;
      } else {
        return (nodeType == node.nodeType) && (pattern!.hasMatch(node.data));
      }
    });

    return filtered.toList();
  }

  @override
  Node? findPreviousParsed({RegExp? pattern, int? nodeType}) {
    final filtered =
        findPreviousParsedAll(pattern: pattern, nodeType: nodeType);
    return filtered.isNotEmpty ? filtered.first : null;
  }

  @override
  List<Node> findPreviousParsedAll({RegExp? pattern, int? nodeType}) {
    final bs4 = _bs4;
    final bs4PrevParsedAll = bs4.previousParsedAll;
    if (bs4PrevParsedAll.isEmpty) return <Node>[];
    if (pattern == null && nodeType == null) return bs4PrevParsedAll;

    final filtered = bs4PrevParsedAll.where((node) {
      if (pattern != null && nodeType == null) {
        return pattern.hasMatch(node.data);
      } else if (pattern == null && nodeType != null) {
        return nodeType == node.nodeType;
      } else {
        return (nodeType == node.nodeType) && (pattern!.hasMatch(node.data));
      }
    });

    return filtered.toList();
  }

  @override
  String getText() => element?.text ?? findFirstAny()?.getText() ?? '';

  @override
  String get text => getText();
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

bool _isAnyTag(String name) => name == '*';
