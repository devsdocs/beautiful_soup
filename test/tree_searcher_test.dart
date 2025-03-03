import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:html/dom.dart';
import 'package:test/test.dart';

import 'fixtures/fixtures.dart';

void main() {
  late BeautifulSoup bs;

  setUp(() {
    bs = BeautifulSoup(html_doc);
  });

  group('TreeSearcher', () {
    group('findAll', () {
      test('finds all with the given tag', () {
        final elements = bs.findAll('a');

        expect(elements.length, 4);
        expect(elements.every((e) => e.name == 'a'), isTrue);
        expect(elements.last.toString(), '<a href="unknown">Some name</a>');
        expect(elements.last.outerHtml, '<a href="unknown">Some name</a>');
      });

      test('finds all with the given tag and specified attributes', () {
        final elements = bs.findAll(
          'a',
          attrs: {'id': 'link1', 'href': 'http://example.com/elsie'},
        );

        expect(elements.length, 1);
        expect(
          elements[0].toString(),
          '<a href="http://example.com/elsie" class="sister" id="link1">Elsie</a>',
        );
        expect(
          elements[0].outerHtml,
          '<a href="http://example.com/elsie" class="sister" id="link1">Elsie</a>',
        );
      });

      test('does not find if element with specified attributes '
          'does not exists', () {
        final elements = bs.findAll(
          'a',
          attrs: {'id': 'link1', 'href': 'unknown'},
        );

        expect(elements.length, 0);
      });

      test('finds all with any href tag', () {
        final elements = bs.findAll('a', attrs: {'href': true});

        expect(elements.length, 3);
        expect(elements.last.outerHtml, '<a href="unknown">Some name</a>');
      });

      test('finds all when iterated by tags', () {
        final elements = bs.body?.findAll('a');

        expect(elements, isNotNull);
        expect(elements!.length, 4);
        expect(elements.last.outerHtml, '<a href="unknown">Some name</a>');
      });

      test('finds all when using selector', () {
        var elements = bs.findAll('', selector: '.sister');

        expect(elements.length, 3);
        expect(
          elements.last.toString(),
          '<a class="sister" id="link3">Tillie</a>',
        );

        // specifying attributes does not have influence
        elements = bs.findAll('', selector: '.sister', attrs: {'class': 'top'});
        expect(elements.length, 3);
        expect(
          elements.last.toString(),
          '<a class="sister" id="link3">Tillie</a>',
        );
      });

      test('finds all by id', () {
        final elements = bs.findAll('a', id: 'link1');

        expect(elements.length, 1);
        expect(
          elements[0].toString(),
          '<a href="http://example.com/elsie" class="sister" id="link1">Elsie</a>',
        );
        expect(
          elements[0].outerHtml,
          '<a href="http://example.com/elsie" class="sister" id="link1">Elsie</a>',
        );

        // any tag
        final elementsAny = bs.findAll('*', id: 'link1');
        expect(elementsAny.length, 1);
        expect(
          elementsAny[0].toString(),
          '<a href="http://example.com/elsie" class="sister" id="link1">Elsie</a>',
        );
        expect(
          elementsAny[0].outerHtml,
          '<a href="http://example.com/elsie" class="sister" id="link1">Elsie</a>',
        );
      });

      test('finds all by class_', () {
        final elements = bs.findAll('a', class_: 'sister');

        expect(elements.length, 3);
        expect(
          elements[0].toString(),
          '<a href="http://example.com/elsie" class="sister" id="link1">Elsie</a>',
        );
        expect(elements.map((e) => e.name), equals(<String>['a', 'a', 'a']));
        expect(
          elements.map((e) => e.id),
          equals(<String>['link1', 'link2', 'link3']),
        );

        // any tag
        final elementsAny = bs.findAll('*', class_: 'sister');
        expect(elementsAny.length, 3);
        expect(
          elementsAny[0].toString(),
          '<a href="http://example.com/elsie" class="sister" id="link1">Elsie</a>',
        );
        expect(
          elementsAny.map((e) => e.id),
          equals(<String>['link1', 'link2', 'link3']),
        );
      });

      test('finds all both by id and class_', () {
        final elements = bs.findAll('a', id: 'link2', class_: 'sister');

        expect(elements.length, 1);
        expect(
          elements[0].toString(),
          '<a href="http://example.com/lacie" class="sister" id="link2">Lacie</a>',
        );

        // any tag
        final elementsAny = bs.findAll('*', id: 'link2', class_: 'sister');
        expect(elementsAny.length, 1);
        expect(
          elementsAny[0].toString(),
          '<a href="http://example.com/lacie" class="sister" id="link2">Lacie</a>',
        );
      });

      test('finds all by regex', () {
        final elements = bs.findAll('*', regex: r'^b');

        expect(elements.length, 2);
        expect(elements[0].toString(), startsWith('<body>\n'));
        expect(elements[1].toString(), "<b>The Dormouse's story</b>");
      });

      test('finds all by string, part of string', () {
        final elements = bs.findAll('*', string: r'ie$');
        expect(elements.length, 3);
        expect(
          elements.map((e) => e.id),
          equals(<String>['link1', 'link2', 'link3']),
        );
      });

      test('finds all by string, exact string match', () {
        final elements = bs.findAll('*', string: r'^Some name$');
        expect(elements.length, 1);
        expect(elements.first.toString(), '<a href="unknown">Some name</a>');
      });

      test('finds all with the given tag and limit', () {
        final elements = bs.findAll('a', limit: 1);
        expect(elements.length, 1);
        expect(elements.every((e) => e.name == 'a'), isTrue);
        expect(
          elements.first.toString(),
          '<a href="http://example.com/elsie" class="sister" id="link1">Elsie</a>',
        );

        final elements2 = bs.findAll('a', limit: 2);
        expect(elements2.length, 2);
        expect(elements2.every((e) => e.name == 'a'), isTrue);
        expect(
          elements2[0].toString(),
          '<a href="http://example.com/elsie" class="sister" id="link1">Elsie</a>',
        );
        expect(
          elements2[1].toString(),
          '<a href="http://example.com/lacie" class="sister" id="link2">Lacie</a>',
        );

        final elements3 = bs.findAll('a', limit: 0);
        expect(elements3.length, 0);

        final elements4 = bs.findAll('a', limit: 100);
        expect(elements4.length, 4);
        expect(elements4.every((e) => e.name == 'a'), isTrue);
      });

      test('does not find with invalid limit', () {
        expect(
          () => bs.findAll('a', limit: -1),
          throwsA(isA<AssertionError>()),
        );

        expect(() => bs.findAll('', limit: -2), throwsA(isA<AssertionError>()));

        expect(
          () => bs.findAll('*', limit: -50),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('find', () {
      test('finds with the given tag', () {
        final element = bs.find('a');

        expect(element, isNotNull);
        expect(element!.name, 'a');
        expect(element.className, 'sister');
        expect(element.id, 'link1');
      });

      test('finds with the given tag and specified attributes', () {
        final element = bs.find(
          'a',
          attrs: {'id': 'link1', 'href': 'http://example.com/elsie'},
        );

        expect(element, isNotNull);
        expect(
          element.toString(),
          '<a href="http://example.com/elsie" class="sister" id="link1">Elsie</a>',
        );
        expect(
          element!.outerHtml,
          '<a href="http://example.com/elsie" class="sister" id="link1">Elsie</a>',
        );
      });

      test('does not find if element with specified attributes '
          'does not exists', () {
        final element = bs.find('a', attrs: {'id': 'link1', 'href': 'unknown'});
        expect(element, isNull);
      });

      test('finds first element in the parse tree with the given tag if '
          'the attribute has multiple elements', () {
        final element = bs.find('p', attrs: {'class': 'story'});

        expect(element, isNotNull);
        expect(element!.string, startsWith('Once upon a time'));
      });

      test('finds when iterated by elements', () {
        final element = bs.body?.p?.find('b');

        expect(element, isNotNull);
        expect(element!.name, equals("b"));
        expect(element.string, equals("The Dormouse's story"));
        expect(element.getText(), equals("The Dormouse's story"));
        expect(element.toString(), equals("<b>The Dormouse's story</b>"));
        expect(element.outerHtml, equals("<b>The Dormouse's story</b>"));
      });

      test('finds when using customSelector', () {
        var element = bs.find('', selector: '#link1');

        expect(element, isNotNull);
        expect(
          element!.toString(),
          '<a href="http://example.com/elsie" class="sister" id="link1">Elsie</a>',
        );

        // specifying attributes does not have influence
        element = bs.find('', selector: '#link1', attrs: {'class': 'top'});
        expect(element, isNotNull);
        expect(
          element!.toString(),
          '<a href="http://example.com/elsie" class="sister" id="link1">Elsie</a>',
        );
      });

      test('finds by id', () {
        final element = bs.find('a', id: 'link1');

        expect(
          element.toString(),
          '<a href="http://example.com/elsie" class="sister" id="link1">Elsie</a>',
        );

        // any tag
        final elementAny = bs.find('*', id: 'link1');
        expect(
          elementAny.toString(),
          '<a href="http://example.com/elsie" class="sister" id="link1">Elsie</a>',
        );
      });

      test('finds by class_', () {
        final element = bs.find('p', class_: 'story');

        expect(
          element.toString(),
          startsWith(
            '<p class="story">Once upon a time there were three little',
          ),
        );
      });

      test('finds by class_, variants', () {
        bs = BeautifulSoup.fragment('<p class="body strikeout"></p>');

        final element1 = bs.find('p', class_: 'strikeout');
        expect(element1.toString(), '<p class="body strikeout"></p>');

        final element2 = bs.find('p', class_: 'body');
        expect(element2.toString(), '<p class="body strikeout"></p>');

        final element3 = bs.find('p', class_: 'body strikeout');
        expect(element3.toString(), '<p class="body strikeout"></p>');

        final element4 = bs.find('p', class_: 'strikeout body');
        expect(element4, isNull);
      });

      test('finds both by id and class_', () {
        final element = bs.find('a', id: 'link2', class_: 'sister');

        expect(
          element.toString(),
          '<a href="http://example.com/lacie" class="sister" id="link2">Lacie</a>',
        );
      });

      test('finds by regex', () {
        final element = bs.find('*', regex: r'^he');
        expect(element.toString(), startsWith('<head>'));
      });

      test('finds by string', () {
        const pattern = r'^The Dormouse';

        final element = bs.find('*', string: pattern);
        expect(
          element.toString(),
          equals("<title>The Dormouse's story</title>"),
        );

        final element2 = bs.find('*', string: RegExp(pattern));
        expect(
          element2.toString(),
          equals("<title>The Dormouse's story</title>"),
        );
      });
    });

    group('findParent', () {
      test('finds with any tag', () {
        final element = bs.a;
        expect(element, isNotNull);

        final parent = element!.findParent('*');
        expect(parent!.name, equals('p'));
        expect(parent.children.length, 4);
      });

      test('finds with defined tag', () {
        final element = bs.a;
        expect(element, isNotNull);

        final parent = element!.findParent('body');
        expect(parent!.name, equals('body'));
        expect(parent.children.length, 3);
      });

      test('does not find any', () {
        final element = bs.findParent('*');
        expect(element, isNull);
      });
    });

    group('findParents', () {
      test('finds all with any tag', () {
        final element = bs.a;
        expect(element, isNotNull);

        final parentElements = element!.findParents('*');
        expect(parentElements.length, 3);
        expect(
          parentElements.map((e) => e.name),
          equals(<String>['p', 'body', 'html']),
        );
      });

      test('finds all with defined tag', () {
        final element = bs.a;
        expect(element, isNotNull);

        final parentElements = element!.findParents('body');
        expect(parentElements.length, 1);
        expect(parentElements.map((e) => e.name), equals(<String>['body']));
      });

      test('does not find any', () {
        final elements = bs.findParents('*');
        expect(elements.isEmpty, isTrue);
      });
    });

    group('findNextSibling', () {
      test('finds with any tag', () {
        final element = bs.a;
        expect(element, isNotNull);

        final nextSibling = element!.findNextSibling(
          'a',
          attrs: {'id': 'link3'},
        );
        expect(
          nextSibling.toString(),
          equals('<a class="sister" id="link3">Tillie</a>'),
        );

        // any tag name should return same result
        final nextSibling2 = element.findNextSibling(
          'a',
          attrs: {'id': 'link3'},
        );
        expect(
          nextSibling2.toString(),
          equals('<a class="sister" id="link3">Tillie</a>'),
        );
      });

      test('finds with defined tag', () {
        final element = bs.p;
        expect(element, isNotNull);

        final nextSibling = element!.findNextSibling('p');
        expect(nextSibling!.name, equals('p'));
        expect(nextSibling.className, equals('story'));
        expect(nextSibling.children.length, 4);
      });

      test('does not find any', () {
        final element = bs.findNextSibling('*');
        expect(element, isNull);
      });
    });

    group('findNextSiblings', () {
      test('finds all with any tag', () {
        final element = bs.a;
        expect(element, isNotNull);

        final nextSiblings = element!.findNextSiblings('*');
        expect(nextSiblings.length, 3);
        expect(
          nextSiblings.map((e) => '${e.name}:${e.id}'),
          equals(<String>['a:link2', 'a:link3', 'a:']),
        );
      });

      test('finds all with defined tag', () {
        final element = bs.head;
        expect(element, isNotNull);

        final nextSiblings = element!.findNextSiblings('body');
        expect(nextSiblings.length, 1);
        expect(nextSiblings.map((e) => e.name), equals(<String>['body']));
      });

      test('does not find from BeautifulSoup instance', () {
        final elements = bs.findNextSiblings('*');
        expect(elements.isEmpty, isTrue);
      });

      test('does not find any', () {
        final element = bs.body;
        expect(element, isNotNull);

        final nextSiblings = element!.findNextSiblings('body');
        expect(nextSiblings.isEmpty, isTrue);
      });
    });

    group('findPreviousSibling', () {
      test('finds with any tag', () {
        final element = bs.body!.findAll('a').last;

        final prevSibling = element.findPreviousSibling('*');
        expect(
          prevSibling!.toString(),
          equals('<a class="sister" id="link3">Tillie</a>'),
        );
      });

      test('finds with defined tag', () {
        bs = BeautifulSoup.fragment(html_comment);
        final element = bs.find('br');
        expect(element, isNotNull);

        final prevSibling = element!.findPreviousSibling('b');
        expect(prevSibling, isNotNull);
        expect(prevSibling!.name, equals('b'));
      });

      test('does not find any', () {
        final element = bs.findPreviousSibling('*');
        expect(element, isNull);
      });
    });

    group('findPreviousSiblings', () {
      test('finds all with any tag', () {
        final element = bs.body;
        expect(element, isNotNull);

        final prevSiblings = element!.findPreviousSiblings('*');
        expect(prevSiblings.length, 1);
        expect(prevSiblings.map((e) => e.name), equals(<String>['head']));
      });

      test('finds all with defined tag', () {
        final element = bs.findAll('a').last;

        final prevSiblings = element.findPreviousSiblings(
          '*',
          attrs: {'href': true},
        );
        expect(prevSiblings.length, 2);
        expect(
          prevSiblings.map((e) => e.id),
          equals(<String>['link2', 'link1']),
        );
      });

      test('finds from BeautifulSoup instance', () {
        final elements = bs.findPreviousSiblings('*');
        expect(elements.isEmpty, isTrue);
      });

      test('does not find any', () {
        final element = bs.head;
        expect(element, isNotNull);

        final prevSiblings = element!.findPreviousSiblings('*');
        expect(prevSiblings.isEmpty, isTrue);
      });
    });

    group('findNextElement', () {
      test('finds with any tag', () {
        final element = bs.p;
        expect(element, isNotNull);

        final nextElement = element!.findNextElement('*');
        expect(nextElement.toString(), equals('<b>The Dormouse\'s story</b>'));
      });

      test('finds with defined tag', () {
        final element = bs.a;
        expect(element, isNotNull);

        final nextElement = element!.findNextElement('p');
        expect(nextElement!.toString(), equals('<p class="story">...</p>'));
      });

      test('finds from BeautifulSoup instance', () {
        final element = bs.findNextElement('*');
        expect(element, isNotNull);
        expect(element!.name, equals('head'));
      });

      test('does not find any', () {
        final element = bs.findAll('p').last.findNextElement('*');
        expect(element, isNull);
      });
    });

    group('findAllNextElements', () {
      test('finds all with any tag', () {
        final element = bs.a;
        expect(element, isNotNull);

        final nextElements = element!.findAllNextElements('*');
        expect(nextElements.length, 4);
        expect(
          nextElements.map((e) => '${e.name}:${e.id}'),
          equals(<String>['a:link2', 'a:link3', 'a:', 'p:']),
        );
        expect(
          nextElements.last.toString(),
          equals('<p class="story">...</p>'),
        );
      });

      test('finds all with defined tag', () {
        final element = bs.body;
        expect(element, isNotNull);

        final nextElements = element!.findAllNextElements(
          '',
          selector: '.story',
        );
        expect(nextElements.length, 2);
        expect(nextElements.map((e) => e.name), equals(<String>['p', 'p']));
        expect(
          nextElements.last.toString(),
          equals('<p class="story">...</p>'),
        );
      });

      test('finds from BeautifulSoup instance', () {
        final elements = bs.findAllNextElements('*');
        expect(elements.length, 11);
        expect(
          elements.map((e) => e.name),
          equals(<String>[
            'head',
            'title',
            'body',
            'p',
            'b',
            'p',
            'a',
            'a',
            'a',
            'a',
            'p',
          ]),
        );
      });

      test('does not find any', () {
        final elements = bs.findAllNextElements('footer');
        expect(elements.length, 0);
      });
    });

    group('findPreviousElement', () {
      test('finds with any tag', () {
        final element = bs.body;
        expect(element, isNotNull);

        final prevElement = element!.findPreviousElement('*');
        expect(prevElement!.name, equals('head'));
      });

      test('finds with defined tag', () {
        final element = bs.a;
        expect(element, isNotNull);

        final prevElement = element!.findPreviousElement('p');
        expect(
          prevElement!.toString(),
          startsWith('<p class="story">Once upon a time'),
        );
      });

      test('does not find any', () {
        final element = bs.findPreviousElement('*');
        expect(element, isNull);
      });
    });

    group('findAllPreviousElements', () {
      test('finds all with any tag', () {
        final element = bs.a;
        expect(element, isNotNull);

        final prevElements = element!.findAllPreviousElements('*');
        expect(prevElements.length, 5);
        expect(
          prevElements.map((e) => e.name),
          equals(<String>['p', 'p', 'body', 'head', 'html']),
        );
      });

      test('finds all with defined tag', () {
        final element = bs.a;
        expect(element, isNotNull);

        final prevElements = element!.findAllPreviousElements('body');
        expect(prevElements.length, 1);
        expect(prevElements.map((e) => e.name), equals(<String>['body']));
      });

      test('does not find any', () {
        final element = bs.a;
        expect(element, isNotNull);

        final prevElements = element!.findAllPreviousElements(
          'body',
          attrs: {'class': true},
        );
        expect(prevElements.isEmpty, isTrue);
      });

      test('does not find any from BeautifulSoup instance', () {
        final elements = bs.findAllPreviousElements('*');
        expect(elements.isEmpty, isTrue);
      });
    });

    group('findNextParsed', () {
      test('finds with defined pattern', () {
        final element = bs.body;
        expect(element, isNotNull);

        final nextParsed = element!.findNextParsed(
          pattern: RegExp('^(<a).*id="link'),
        );
        expect(nextParsed, isNotNull);
        expect(
          nextParsed!.data,
          startsWith('<a href="http://example.com/elsie"'),
        );
        expect(nextParsed.nodeType, Node.ELEMENT_NODE);
      });

      test('finds with defined pattern and nodeType (url link)', () {
        bs = BeautifulSoup.fragment(html_prettify);
        final nextParsed = bs.findNextParsed(
          pattern: RegExp(r'.*(.com)'),
          nodeType: Node.TEXT_NODE,
        );

        expect(nextParsed, isNotNull);
        expect(nextParsed!.data, equals('example.com'));
        expect(nextParsed.nodeType, Node.TEXT_NODE);
      });

      test('does not find any', () {
        bs = BeautifulSoup.fragment(html_placeholder_empty);
        final element = bs.findNextParsed();
        expect(element, isNull);
      });
    });

    group('findNextParsedAll', () {
      test('finds all any', () {
        final element = bs.findAll('p').last;

        final nextParsedAll = element.findNextParsedAll();
        expect(nextParsedAll.length, 2);
        expect(nextParsedAll[0].data, startsWith('...'));
        expect(nextParsedAll[1].data, startsWith('\n'));
        expect(
          nextParsedAll.map((e) => e.nodeType),
          equals(<int>[Node.TEXT_NODE, Node.TEXT_NODE]),
        );
      });

      test('finds all with defined pattern', () {
        final element = bs.html;
        expect(element, isNotNull);

        // find all elements that starts with: <p class="story"
        final nextParsedAll = element!.findNextParsedAll(
          pattern: RegExp(r'^(<p class="story")'),
        );
        expect(nextParsedAll.length, 2);
        expect(
          nextParsedAll[0].data,
          startsWith('<p class="story">Once upon a'),
        );
        expect(nextParsedAll[1].data, equals('<p class="story">...</p>'));
        expect(
          nextParsedAll.map((e) => e.nodeType),
          equals(<int>[Node.ELEMENT_NODE, Node.ELEMENT_NODE]),
        );
      });

      test('does not find any', () {
        bs = BeautifulSoup.fragment(html_placeholder_empty);
        final elements = bs.findNextParsedAll();
        expect(elements.isEmpty, isTrue);
      });
    });

    group('findPreviousParsed', () {
      test('finds with defined pattern (url link)', () {
        bs = BeautifulSoup.fragment(html_prettify);
        final element = bs.find('i');
        expect(element, isNotNull);

        final prevParsed = element!.findPreviousParsed(
          pattern: RegExp(r'.*(.com)'),
        );

        expect(prevParsed, isNotNull);
        expect(prevParsed!.data, startsWith('<a href="http://example.com'));
        expect(prevParsed.nodeType, Node.ELEMENT_NODE);
      });

      test('does not find any', () {
        bs = BeautifulSoup.fragment(html_placeholder_empty);
        final element = bs.findPreviousParsed();
        expect(element, isNull);
      });
    });

    group('findPreviousParsedAll', () {
      test('finds all any', () {
        bs = BeautifulSoup.fragment(html_comment);
        final element = bs.find('c');
        expect(element, isNotNull);

        final prevParsedAll = element!.findPreviousParsedAll(
          nodeType: Node.COMMENT_NODE,
        );
        expect(prevParsedAll.length, 1);
        expect(prevParsedAll[0].data, equals('<!-- some comment -->'));
        expect(prevParsedAll[0].nodeType, Node.COMMENT_NODE);
      });

      test('finds all with defined pattern and nodeType', () {
        final element = bs.findAll('p').last;

        // find all elements that starts with: <p class="story"
        final prevParsedAll = element.findPreviousParsedAll(
          pattern: RegExp(r'id="link1"'),
        );
        expect(prevParsedAll.length, 2);
        expect(
          prevParsedAll[0].data,
          startsWith('<p class="story">Once upon a time'),
        );
        // TODO: recursive search: nextParsedAll/prevParsedAll, should output as well: <a href="http://example.com/elsie" class="sister
        expect(prevParsedAll[1].data, startsWith('<html><head>\n'));
        expect(
          prevParsedAll.map((e) => e.nodeType),
          equals(<int>[Node.ELEMENT_NODE, Node.ELEMENT_NODE]),
        );
      });

      test('does not find any', () {
        bs = BeautifulSoup.fragment(html_placeholder_empty);
        final elements = bs.findPreviousParsedAll();
        expect(elements.isEmpty, isTrue);
      });
    });
  });
}
