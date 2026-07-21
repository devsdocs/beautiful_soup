import 'package:html/dom.dart';

import 'ts_element.dart';
import 'ts_soup.dart';
import 'extensions.dart';
import 'interface/interface.dart';

///
class Tags implements ITags {
  ///
  Element? element;
  Document? _doc;
  DocumentFragment? _docFragment;

  /// Returns [Document] or [DocumentFragment], based on what parser was used
  /// with the [TypedSoup] constructor.
  ///
  /// This should not be used publicly along with setter.
  ///
  /// Can return null.
  dynamic get doc => _doc ?? _docFragment;

  set doc(dynamic value) {
    if (value is Document) {
      _doc = value;
      _docFragment = null;
    } else {
      _docFragment = value;
      _doc = null;
    }
  }

  TsElement? _findFirst(String tagName) =>
      ((element ?? doc).querySelector(tagName) as Element?)?.bs4;

  @override
  TsElement? get html => _findFirst('html');

  @override
  TsElement? get body => _findFirst('body');

  @override
  TsElement? get head => _findFirst('head');

  @override
  TsElement? get a => _findFirst('a');

  @override
  TsElement? get b => _findFirst('b');

  @override
  TsElement? get i => _findFirst('i');

  @override
  TsElement? get p => _findFirst('p');

  @override
  TsElement? get title => _findFirst('title');

  @override
  TsElement? get h1 => _findFirst('h1');

  @override
  TsElement? get h2 => _findFirst('h2');

  @override
  TsElement? get h3 => _findFirst('h3');

  @override
  TsElement? get h4 => _findFirst('h4');

  @override
  TsElement? get h5 => _findFirst('h5');

  @override
  TsElement? get h6 => _findFirst('h6');

  @override
  TsElement? get img => _findFirst('img');

  @override
  TsElement? get table => _findFirst('table');

  @override
  TsElement? get dl => _findFirst('dl');

  @override
  TsElement? get ul => _findFirst('ul');

  @override
  TsElement? get ol => _findFirst('ol');
}
