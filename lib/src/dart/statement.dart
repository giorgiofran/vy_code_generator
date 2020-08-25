import 'abstract/dart_element.dart';

Statement emptyLineStatement = Statement.fromTextualContext('\n\n');

class Statement extends DartElement {
  Statement.fromTextualContext(String text) : super.fromTextualContent(text);

  @override
  String generate() {
    // Todo update this
    var ret = super.generate();
    if (ret != null) {
      return '$ret';
    }
    return super.generate();
  }
}
