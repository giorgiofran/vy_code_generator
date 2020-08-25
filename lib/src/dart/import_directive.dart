import 'package:vy_string_utils/vy_string_utils.dart';

import 'abstract/dart_element.dart';
import 'abstract/identified.dart';
import 'export_directive.dart';
import 'utils/keywords.dart';
import 'utils/string_buffer_extension.dart';

class ImportDirective extends DartElement
    implements Comparable<ImportDirective> {
  String package;
  String useAs;
  bool showUsingList = true;
  final Set<Identified> showSet = <Identified>{};
  final Set<Identified> hideSet = <Identified>{};

  ImportDirective(this.package, Identified id) {
    addShow(id);
  }
  ImportDirective.genericPackage(String packagePath) {
    package = 'package:$packagePath';
  }
  ImportDirective.fromTextualContent(String text)
      : super.fromTextualContent(text);

  @override
  bool operator ==(other) => package == other.package;
  @override
  int get hashCode => package.hashCode;

  bool get isDartPackage => package.startsWith(RegExp('[dD][aA][rR][tT]:'));
  bool get isPackage =>
      package.startsWith(RegExp('[pP][aA][cC][kK][aA][gG][eE]:'));
  bool get isRelative => !isDartPackage && !isPackage;

  void addShow(Identified identified) {
    if (hideSet.contains(identified)) {
      throw StateError('The identified element ${identified.id.id} '
          'cannot be added to show elements because it is already '
          'present in hide list;');
    }
    showSet.add(identified);
  }

  void addHide(Identified identified) {
    if (showSet.contains(identified)) {
      throw StateError('The identified element ${identified.id.id} '
          'cannot be added to hide list because it is already '
          'present in show elements;');
    }
    hideSet.add(identified);
  }

  @override
  String generate() {
    var ret = super.generate();
    if (ret != null) {
      return '$ret;';
    }
    var buffer = StringBuffer();
    buffer.writeKeyword(keywordImport);
    buffer.write("'");
    buffer.write(package);
    buffer.write("'");
    if (filled(useAs)) {
      buffer.writeKeyword(keywordAs);
      buffer.write(useAs);
      buffer.write(' ');
    }
    if (showUsingList && showSet.isNotEmpty) {
      buffer.writeKeyword(keywordShow);
      buffer.writeIdentifiedSet(showSet);
    }
    if (hideSet.isNotEmpty) {
      buffer.writeKeyword(keywordHide);
      buffer.writeIdentifiedSet(hideSet);
    }
    return '$buffer;';
  }

  @override
  int compareTo(ImportDirective other) {
    if (isDartPackage) {
      if (!other.isDartPackage) {
        return -1;
      }
    } else if (isPackage) {
      {
        if (other.isDartPackage) {
          return 1;
        } else if (other.isRelative) {
          return -1;
        }
      }
    } else if (isRelative) {
      if (!other.isRelative) {
        return 1;
      }
    }
    return package.compareTo(other.package);
  }

  @override
  void addImport(ImportDirective import) =>
      throw StateError('You cannot add an import to an import directive!');

  @override
  void addExport(ExportDirective export) =>
      throw StateError('You cannot add an export to an import directive!');
}
