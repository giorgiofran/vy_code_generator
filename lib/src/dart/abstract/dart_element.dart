import 'package:vy_string_utils/vy_string_utils.dart';

import '../export_directive.dart';
import '../import_directive.dart';
import '../library.dart';
import '../part_directive.dart';

abstract class DartElement {
  String? explicit;
  List<ImportDirective> imports = <ImportDirective>[];
  List<ExportDirective> exports = <ExportDirective>[];
  PartDirective? part;

  // parent, if not library child
  DartElement? parent;
  // top level library, passed by parent. Always present
  Library? _library;

  DartElement();
  DartElement.fromTextualContent(this.explicit);

  Library? get library => _library;
  set library(Library? value) => libraryUpdated(value);

  void addImport(ImportDirective import) {
    if (_library == null) {
      imports.add(import);
      return;
    }
    _library!.addImport(import);
  }

  void addExport(ExportDirective export) {
    if (_library == null) {
      exports.add(export);
      return;
    }
    _library!.addExport(export);
  }

  void libraryUpdated(Library? library) {
    if (library == null) {
      throw StateError('You cannot set a null library');
    }
    _library = library;
    for (var import in imports) {
      _library!.addImport(import);
    }
    for (var export in exports) {
      _library!.addExport(export);
    }
  }

  String? generate() {
    if (filled(explicit)) {
      return '$explicit';
    }
    return null;
  }
}
