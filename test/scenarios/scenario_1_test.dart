import 'package:typed_soup/typed_soup.dart';
import 'package:test/test.dart';

import '../fixtures/fixtures.dart';

void main() {
  late TypedSoup bs;

  group('George R. R. Martin blog', () {
    setUp(() {
      bs = TypedSoup(scenario_1_html);
    });

    group('searches and extracts elements correctly', () {
      test('finds main contents of the post', () {
        final bs4 = bs.find('div', attrs: {'class': 'post-main'});
        expect(bs4, isNotNull);
        expect(bs4!.name, equals('div'));

        final textList = bs4.strippedStrings.toList();

        // title
        expect(textList.first, startsWith("Here’s the Scoop on NIGHTFLYERS"));

        // content
        expect(
          textList.join(' '),
          contains(
            'Needless to say, once those stories appeared I was deluged with requests for comment and clarification.',
          ),
        );

        // tags
        expect(
          textList.join(' '),
          contains('Tags: science fiction, syfy, television'),
        );

        // comment section
        expect(
          textList.join(' '),
          contains('Comments are disabled for this post.'),
        );
      });

      test('finds all image links within main post content', () {
        final images = bs
            .find('div', attrs: {'class': 'post-main'})
            ?.findAll('img');
        expect(images, isNotNull);
        expect(images!.length, 3);

        expect(
          images[0]['src'],
          equals(
            'https://georgerrmartin.com/notablog/wp-content/themes/dark-shop-lite/profiles/thumb.png',
          ),
        );
        expect(
          images[1]['src'],
          equals(
            'http://georgerrmartin.com/notablog/wp-content/uploads/import/463237_800.jpg',
          ),
        );
        expect(
          images[2]['src'],
          equals(
            'http://georgerrmartin.com/notablog/wp-content/uploads/import/462875_800.jpg',
          ),
        );
      });
    });
  });
}
