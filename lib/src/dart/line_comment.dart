import 'abstract/dart_element.dart';

class LineComment extends DartElement {
  LineComment(String comment) : super.fromTextualContent('// $comment');

  @override
  String generate() => super.generate() ?? '';
}
