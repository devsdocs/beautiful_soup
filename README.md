# Typed Soup

[![pub package](https://img.shields.io/pub/v/typed_soup.svg)](https://pub.dev/packages/typed_soup)
![tests](https://github.com/devsdocs/beautiful_soup/actions/workflows/main.yml/badge.svg)
[![codecov](https://codecov.io/gh/devsdocs/beautiful_soup/branch/master/graph/badge.svg)](https://codecov.io/gh/devsdocs/beautiful_soup)

[comment]: <> ([![codecov]&#40;https://codecov.io/gh/mzdm/beautiful_soup/branch/master/graph/badge.svg&#41;]&#40;https://codecov.io/gh/mzdm/beautiful_soup&#41;)

Dart native package inspired by Beautiful Soup 4 Python library. Provides easy ways of navigating, searching, and
modifying the HTML tree.

This package is a fork of the original [beautiful_soup_dart](https://github.com/mzdm/beautiful_soup) by [mzdm](https://github.com/mzdm).

## Usage

A simple usage example:

```dart
import 'package:typed_soup/typed_soup.dart';

/// 1. parse a document String
TypedSoup bs = TypedSoup(html_doc_string);
// use TypedSoup.fragment(html_doc_string) if you parse a part of html

/// 2. navigate quickly to any element
bs.body!.a!; // navigate quickly with tags, use outerHtml or toString to get outer html
bs.find('p', class_: 'story'); // finds first element with html tag "p" and which has "class" attribute with value "story"
bs.findAll('a', attrs: {'class': true}); // finds all elements with html tag "a" and which have defined "class" attribute with whatever value
bs.find('', selector: '#link1'); // find with custom CSS selector (other parameters are ignored)
bs.find('*', id: 'link1'); // any element with id "link1"
bs.find('*', regex: r'^b'); // find any element which tag starts with "b", for example: body, b, ...
bs.find('p', string: r'^Article #\d*'); // find "p" element which text starts with "Article #[number]"
bs.find('a', attrs: {'href': 'http://example.com/elsie'}); // finds by "href" attribute

/// 3. perform any other actions for the navigated element
TsElement ts = bs.body!.p!; // navigate quickly with tags
bs4.name; // get tag name
bs4.string; // get text
bs4.toString(); // get String representation of this element, same as outerHtml
bs4.innerHtml; // get html elements inside the element
bs4.className; // get class attribute value
bs4['class']; // get class attribute value
bs4['class'] = 'board'; // change class attribute value to 'board'
bs4.children; // get all element's children elements
bs4.replaceWith(otherTsElement); // replace with other element
... and many more
```

Check `test` folder for more examples.

## Table of Contents

- [Navigating the tree](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#navigating-the-tree)
    - [Going down](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#going-down)
        - [Navigating using tag names](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#navigating-using-tag-names)
        - [.contents and .children](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#contents-and-children)
        - [.descendants](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#descendants)
        - [.self_and_descendants]() - includes current element with descendants
        - [.string](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#string)
        - [.strings and .strippedStrings](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#strings-and-stripped-strings)
    - [Going up](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#going-up)
        - [.parent](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#parent)
        - [.parents](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#parents)
        - [.self_and_parents]() - includes current element with parents
    - [Going sideways](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#going-sideways)
        - [.nextSibling and .previousSibling](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#next-sibling-and-previous-sibling)
        - [.nextSiblings and .previousSiblings](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#next-siblings-and-previous-siblings)
        - [.self_and_next_siblings]() - includes current element with next siblings
        - [.self_and_previous_siblings]() - includes current element with previous siblings
    - [Going back and forth](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#going-back-and-forth)
        - [.nextElement and .previousElement]() - returns next/previous TsElement
        - [.nextElements and .previousElements]()
        - [.self_and_next_elements]() - includes current element with next elements
        - [.self_and_previous_elements]() - includes current element with previous elements
        - [.nextParsed and .previousParsed]() - returns next/previous any parsed Node (doc comments, tags, text), to get its data as String use `node.data`
        - [.nextParsedAll and .previousParsedAll]()
- [Searching the tree](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#searching-the-tree)
    - [findFirstAny()]() - returns the top most (first) element of the parse tree, of any tag type
    - [findAll()](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#find-all)
    - [find()](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#find)
    - [select() and select_one()]() - CSS selector methods
    - [findParents() and findParent()](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#find-parents-and-find-parent)
    - [findNextSiblings() and findNextSibling()](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#find-next-siblings-and-find-next-sibling)
    - [findPreviousSiblings() and findPreviousSibling()](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#find-previous-siblings-and-find-previous-sibling)
    - [findAllNextElements() and findNextElement()]()
    - [findAllPreviousElements() and findPreviousElement()]()
    - [findNextParsedAll() and findNextParsed()](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#find-all-next-and-find-next)
    - [findPreviousParsedAll() and findPreviousParsed()](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#find-all-previous-and-find-previous)
- [Modifying the tree](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#modifying-the-tree)
    - [Changing tag names and attributes](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#changing-tag-names-and-attributes)
    - [Modifying .string](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#modifying-string)
    - [append()](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#append)
    - [extend()](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#extend)
    - [newTag()](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#navigablestring-and-new-tag)
    - [insert()](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#insert)
    - [insertBefore() and insertAfter()](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#insert-before-and-insert-after)
    - [clear()](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#clear)
    - [extract()](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#extract)
    - [decompose()](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#decompose)
    - [replaceWith()](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#replace-with)
    - [replaceWithChildren()]() - replaces element with its children
    - [wrap()](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#wrap)
    - [wrapWithString()]() - wraps element with optional string content
    - [unwrap()](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#unwrap)
    - [smooth()]() - consolidates adjacent text nodes
- [Output](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#output)
    - [prettify()](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#pretty-printing)
    - [.text and getText()](https://www.crummy.com/software/BeautifulSoup/bs4/doc/#get-text)
    - [.strings]() - generator of all strings in document and descendants
    - [.strippedStrings]() - generator of stripped strings

Other methods from the `Element` from [`html package`](https://pub.dev/packages/html) can be accessed via `TsElement.element`.

## Features and bugs

Please file feature requests and bugs at the [issue tracker](https://github.com/devsdocs/beautiful_soup/issues) or feel
free to raise a PR.