import 'package:typed_soup/typed_soup.dart';
import 'package:typed_soup/src/helpers.dart';
import 'package:html/parser.dart';
import 'package:test/test.dart';

import 'fixtures/fixtures.dart';

void main() {
  late TypedSoup bs;

  setUp(() {
    bs = TypedSoup(html_doc);
  });

  group('Extensions', () {
    group('TsElement from html.Element', () {
      test('parsing fragment does not add html tag', () {
        final bs4 = parse(html_doc).querySelector('p')?.bs4;
        expect(bs4, isNotNull);
        expect(bs4!.name, equals('p'));
      });

      test('parsing html has html tag', () {
        final bs4 = parse(html_doc).querySelector('*')?.bs4;
        expect(bs4, isNotNull);
        expect(bs4!.name, equals('html'));
        expect(bs4.children.first.name, equals('head'));
      });
    });
  });

  group('Helpers', () {
    group('recursiveSearch', () {
      test('finds all recursively', () {
        final bs4 = bs.body;
        expect(bs4, isNotNull);

        // body has 3 elements
        expect(bs4!.children.length, 3);

        // recursive search gets also nested, deep ones
        final recursive = recursiveSearch(bs4).toList();
        expect(recursive.length, 9);
      });
    });
  });
}
