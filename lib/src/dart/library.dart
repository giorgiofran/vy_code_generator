import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:dart_style/dart_style.dart';
import 'package:vy_string_utils/vy_string_utils.dart';

import 'abstract/dart_element.dart';
import 'export_directive.dart';
import 'identifier.dart';
import 'import_directive.dart';
import 'line_comment.dart';
import 'part_directive.dart';
import 'separator.dart';

PartDirective libraryPart = PartDirective('.', Identifier(''));

class Library {
  Library(this.libraryName);

  final Map<PartDirective, List<DartElement>> elements =
      <PartDirective, List<DartElement>>{};
  final List<ImportDirective> imports = <ImportDirective>[];
  final List<ExportDirective> exports = <ExportDirective>[];
  final List<LineComment> topComments = <LineComment>[];

  final Set<PartDirective> parts = <PartDirective>{};
  String libraryName;

  void addElement(DartElement element) {
    /*  assert(filled(libraryName),
        'Cannot add element if the name has not been specified'); */
    element.library = this;
    var key = element.part ?? libraryPart;
    key.libraryName = libraryName;
    parts.add(key);
    var elementList = elements[key] ?? <DartElement>[];
    elementList.add(element);
    elements[key] = elementList;
  }

  void addTopComments(LineComment comment) => topComments.add(comment);

  void addImport(ImportDirective import) {
    if (import.package == null) {
      throw ArgumentError('Cannot add import with no package');
    }
    ImportDirective existingImport;
    try {
      existingImport =
          imports.firstWhere((element) => element.package == import.package);
    } on StateError {
      import.library = this;
      imports.add(import);
      imports.sort();
      return;
    }
    if (unfilled(import.useAs) && filled(existingImport.useAs) ||
        filled(import.useAs) && unfilled(existingImport.useAs) ||
        filled(import.useAs) &&
            filled(existingImport.useAs) &&
            import.useAs != existingImport.useAs) {
      throw StateError('Import of package "${import.package}" is already '
          'present with a different "as" definition ("${import.useAs ?? ''}" '
          'vs "${existingImport.useAs ?? ''}")');
    }
    for (var id in import.showSet) {
      existingImport.addShow(id);
    }
    for (var id in import.hideSet) {
      existingImport.addHide(id);
    }
  }

  void addExport(ExportDirective export) {
    if (export.package == null) {
      throw ArgumentError('Cannot add export with no package');
    }
    ExportDirective existingExport;
    try {
      existingExport =
          exports.firstWhere((element) => element.package == export.package);
    } on StateError {
      export.library = this;
      exports.add(export);
      exports.sort();
      return;
    }
    for (var id in export.showSet) {
      existingExport.addShow(id);
    }
    for (var id in export.hideSet) {
      existingExport.addHide(id);
    }
  }

  void addSeparator({PartDirective? part}) => addElement(Separator()
    ..library = this
    ..part = part);

  Map<String, String> generate() {
    /*   assert(filled(libraryName),
        'Cannot generate library if the name has not been specified'); */
    var importExport = <String>[
      for (var import in imports) import.generate(),
      if (imports.isNotEmpty) (Separator()..library = this).generate(),
      for (var export in exports) export.generate(),
      if (exports.isNotEmpty) (Separator()..library = this).generate(),
    ];

    if (elements.isEmpty) {
      return {'': importExport.join('\n')};
    }
    return {
      for (var part in elements.keys)
        if (part == libraryPart)
          '': <String>[
            for (var comment in topComments) comment.generate(),
            ...importExport,
            if (elements.length > 1)
              for (var part in parts)
                if (part != libraryPart) part.generate(),
            if (elements.length > 1) (Separator()..library = this).generate(),
            for (var element in elements[part] ?? <DartElement>[])
              element.generate() ?? ''
          ].join('\n')
        else
          part.partPath: <String>[
            for (var comment in topComments) comment.generate(),
            if (elements.length > 1) part.generate(isPartOf: true),
            if (elements.length > 1) (Separator()..library = this).generate(),
            for (var element in elements[part] ?? <DartElement>[])
              element.generate() ?? ''
          ].join('\n')
    };
  }

  /// Persists the library.
  /// fileName must not have the extension: ".dart" will be added automatically
  Future<void> persist(Directory directory, {bool? overwrite}) async {
    var locOverwrite = overwrite ?? true;
    /*    assert(filled(libraryName),
        'Cannot persist library if the name has not been specified'); */
    final dartFmt = DartFormatter();
    var parts = generate();
    for (var relativePath in parts.keys) {
      File persistedSource;
      if (relativePath == '') {
        persistedSource = File('${directory.path}/$libraryName.dart');
      } else {
        persistedSource = File('${directory.path}/$relativePath');
      }
      if (!locOverwrite && await persistedSource.exists()) {
        throw StateError(
            'It is not possbile to overwrite ${persistedSource.path}');
      }
      var dir = Directory(path.dirname(persistedSource.path));
      if (!(await dir.exists())) {
        await dir.create(recursive: true);
      }

      await persistedSource
          .writeAsString(dartFmt.format(parts[relativePath] ?? ''));
    }
  }
}
