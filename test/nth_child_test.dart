import 'package:typed_soup/typed_soup.dart';
import 'package:test/test.dart';

void main() {
  test('nth-child check', () {
    final html = '''
<div>
  <p>1</p>
  <p>2</p>
  <p>3</p>
  <p>4</p>
  <p>5</p>
</div>
''';
    final bs = TypedSoup(html);

    final p2DivFirst = bs.find('', selector: 'div');
    final p2DivLast = p2DivFirst?.find('', selector: ':nth-child(2)');
    expect(p2DivLast?.string, '2', reason: 'Should find 2nd paragraph');

    // :nth-child(n)
    final p2Div = bs.find('', selector: 'div > :nth-child(2)');
    expect(p2Div?.string, '2', reason: 'Should find 2nd paragraph');

    // :nth-child(n)
    final p2 = bs.find('', selector: 'p:nth-child(2)');
    expect(p2?.string, '2', reason: 'Should find 2nd paragraph');

    // :nth-child( n ) with spaces
    final p2spaces = bs.find('', selector: 'p:nth-child( 2 )');
    expect(
      p2spaces?.string,
      '2',
      reason: 'Should find 2nd paragraph even with spaces',
    );

    // :first-child
    final p1 = bs.find('', selector: 'p:first-child');
    expect(p1?.string, '1', reason: 'Should find 1st paragraph');

    // :nth-child(odd) -> 1, 3, 5
    final odds = bs.findAll('', selector: 'p:nth-child(odd)');
    expect(odds.length, 3, reason: 'Should find 3 odd paragraphs');
    expect(odds.map((e) => e.string).toList(), ['1', '3', '5']);

    // :nth-child(even) -> 2, 4
    final evens = bs.findAll('', selector: 'p:nth-child(even)');
    expect(evens.length, 2, reason: 'Should find 2 even paragraphs');
    expect(evens.map((e) => e.string).toList(), ['2', '4']);

    // :nth-child(2n+1) -> 1, 3, 5
    final formula = bs.findAll('', selector: 'p:nth-child(2n+1)');
    expect(formula.length, 3);
    expect(formula.map((e) => e.string).toList(), ['1', '3', '5']);

    // complex selector: div > p:nth-child(2)
    final complex = bs.find('', selector: 'div > p:nth-child(2)');
    expect(complex?.string, '2');
  });
}
