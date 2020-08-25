import 'abstract/dart_element.dart';
import 'abstract/identified.dart';
import 'abstract/named_element.dart';
import 'enum_field.dart';
import 'identifier.dart';
import 'library.dart';

class EnumDefinition extends NamedElement with Identified {
  List<EnumField> fields = <EnumField>[];

  EnumDefinition.id(Identifier id) : super(id);
  EnumDefinition(String enumName) : super(Identifier(enumName));

  EnumDefinition.fromTextualContent(String text)
      : super.fromTextualContent(text);

  @override
  String generate() {
    //Todo
    return super.generate();
  }

  @override
  void libraryUpdated(Library library) {
    super.libraryUpdated(library);
    for (var element in fields) {
      element.library = library;
    }
  }
}
