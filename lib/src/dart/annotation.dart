import 'dart_class.dart';
import 'identifier.dart';
import 'utils/string_buffer_extension.dart';

class Annotation extends DartClass {
  Annotation.id(Identifier id) : super.id(id);
  Annotation(String annotationName) : super(annotationName);
  Annotation.fromTextualContent(String text) : super.fromTextualContent(text);

  @override
  String generate() {
    var buffer = StringBuffer();
    if (id == null) {
      throw StateError('Annotation with no id detected');
    }
    buffer.write('@');
    buffer.write(id!.id);
    if (constructors != null &&
        constructors!.isNotEmpty &&
        constructors!.first.parmList != null) {
      buffer.openParentheses();
      buffer.write(constructors!.first.parmList!.listCall);
      buffer.closeParentheses();
    }
    return buffer.toString();
  }
}
