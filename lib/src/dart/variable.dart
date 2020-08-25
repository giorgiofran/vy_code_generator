import 'abstract/annotated.dart';
import 'abstract/dart_element.dart';
import 'abstract/identified.dart';
import 'utils/string_buffer_extension.dart';

enum FieldModifier { staticModifier, constModifier }

class Variable extends DartElement with Identified, Annotated {
  List<FieldModifier> modifiers = <FieldModifier>[];

  Variable.fromTextualContent(String text)
      : super.fromTextualContent(text);

  @override
  String generate() {
    // Todo update this
    var ret = super.generate();
    if (ret != null) {
      return '${generateAnnotations()} $ret';
    }
    var buffer = StringBuffer();
    buffer.writeln(generateAnnotations());
    buffer.writeIdentifier('var ${id.id}');
    return '$buffer;';
  }

}
