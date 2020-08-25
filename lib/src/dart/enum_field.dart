import 'abstract/dart_element.dart';
import 'abstract/identified.dart';
import 'identifier.dart';

class EnumField extends DartElement with Identified {
  EnumField.id(Identifier id) {
    this.id = id;
  }
  EnumField(String fieldName) {
    id = Identifier(fieldName);
  }
  EnumField.fromTextualContent(String text)
      : super.fromTextualContent(text);

  @override
  bool operator ==(other) => id.id == other.id.id;

  @override
  int get hashCode => id.id.hashCode;

  @override
  String generate() {
    // Todo update this
    var ret = super.generate();
    if (ret != null) {
      return '$ret';
    }
    return 'var ${id.id}';
  }
}
