import 'package:html/dom.dart';

import 'ts_element.dart';

///
Iterable<TsElement> recursiveSearch(TsElement bs4) sync* {
  yield bs4;
  for (final e in bs4.children) {
    yield* recursiveSearch(e);
  }
}

///
Iterable<Node> recursiveNodeSearch(Node node) sync* {
  yield node;
  for (final e in node.nodes) {
    yield* recursiveNodeSearch(e);
  }
}
