// ignore_for_file: non_constant_identifier_names

import 'package:typed_soup/src/ts_element.dart';
import 'package:typed_soup/src/extensions.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

import 'shared.dart';

/// {@template bs_soup}
/// Beautiful Soup is a library for pulling data out of HTML files.
/// It provides ways of navigating, searching, and modifying the parse tree.
/// It commonly saves programmers hours or days of work.
///
/// How it should be used? 3 easy steps.
///
/// **1.** parse a document
///
/// ```
/// TypedSoup ts = TypedSoup(html_doc_string);
/// TypedSoup ts = TypedSoup.fragment(html_doc_string); // if it is just a part of html
/// ```
///
/// **2.** navigate quickly to any element
///
/// ```
/// TsElement ts = bs.body.p; // quickly with tags
/// TsElement ts = bs.find('p', class_: 'story'); // finds first element with html tag "p" and which has "class" attribute with value "story"
/// TsElement ts = bs.findAll('a', attrs: {'class': true}); // finds all elements with html tag "a" and which have defined "class" attribute with whatever value
/// TsElement ts = bs.find('', selector: '#link1'); // find with custom CSS selector (other parameters are ignored)
/// TsElement ts = bs.find('*', id: 'link1'); // find by id
/// TsElement ts = bs.find('*', regex: r'^b'); // find any element which tag starts with "b", for example: body, b, ...
/// TsElement ts = bs.find('p', string: r'^Article #\d*'); // find "p" element which text starts with "Article #[number]"
/// TsElement ts = bs.find('a', attrs: {'href': 'http://example.com/elsie'}); // finds by "href" attribute
/// ```
///
/// **3.** perform any actions
///
/// ```
/// bs4.name; // get tag name
/// bs4.string; // get text
/// bs4.toString(); // get String representation of this element, same as outerHtml
/// bs4.innerHtml; // get html elements inside the element
/// bs4.className; // get class attribute value
/// bs4['class']; // get class attribute value
/// bs4['class'] = 'board'; // change class attribute value to 'board'
/// bs4.children; // get all element's children elements
/// bs4.replaceWith(otherTsElement); // replace with other element
/// ```
///
/// and many more!
/// {@endtemplate}
class TypedSoup extends Shared {
  /// {@macro bs_soup}
  TypedSoup(String html_doc) {
    doc = parse(html_doc);
  }

  /// {@macro bs_soup}
  TypedSoup.fragment(String html_doc) {
    doc = parseFragment(html_doc);
  }

  /// {@macro tree_modifier_newTag}
  static TsElement newTag(
    String? name, {
    Map<String, String>? attrs,
    String? string,
  }) {
    final newElement = Element.tag(name);
    if (attrs != null) {
      newElement.attributes.addAll(attrs);
    }
    newElement.text = string;
    return newElement.bs4;
  }

  @override
  String toString() => doc.outerHtml;
}
