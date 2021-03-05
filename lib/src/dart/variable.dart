import 'package:vy_string_utils/vy_string_utils.dart';

import 'abstract/annotated.dart';
import 'abstract/dart_element.dart';
import 'abstract/identified.dart';
import 'utils/string_buffer_extension.dart';

enum FieldModifier { staticModifier, constModifier }

class Variable extends DartElement with Identified, Annotated {
  List<FieldModifier> modifiers = <FieldModifier>[];

  Variable.fromTextualContent(String text) : super.fromTextualContent(text);

  @override
  String generate() {
    // Todo update this
    var ret = super.generate();
    var annotation = generateAnnotations();
    if (ret != null) {
      return '${filled(annotation) ? '$annotation ' : ''}$ret';
    }
    var buffer = StringBuffer();
    if (filled(annotation)) {
      buffer.writeln(annotation);
    }
    buffer.writeIdentifier('var ${id?.id == null ? '' : id!.id}');
    return '$buffer;';
  }
}
