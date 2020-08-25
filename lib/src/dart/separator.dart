import 'abstract/dart_element.dart';

class Separator extends DartElement {
  Separator() : super.fromTextualContent(' ');

  @override
  String generate() => '';
}
