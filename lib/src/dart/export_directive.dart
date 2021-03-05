import 'abstract/dart_element.dart';
import 'abstract/identified.dart';
import 'import_directive.dart';
import 'utils/keywords.dart';
import 'utils/string_buffer_extension.dart';

var _dartIgnoreCase = RegExp('[dD][aA][rR][tT]:');
var _packageIgnoreCase = RegExp('[pP][aA][cC][kK][aA][gG][eE]:');

class ExportDirective extends DartElement
    implements Comparable<ExportDirective> {
  String? package;
  bool showUsingList = true;
  final Set<Identified> showSet = <Identified>{};
  final Set<Identified> hideSet = <Identified>{};

  ExportDirective(this.package, Identified id) {
    addShow(id);
  }
  ExportDirective.genericPackage(String packagePath) {
    package = 'package:$packagePath';
  }
  ExportDirective.fromTextualContent(String text)
      : package = '',
        super.fromTextualContent(text);

  @override
  bool operator ==(other) =>
      other is ExportDirective && package == other.package;
  @override
  int get hashCode => package.hashCode;

  bool get isDartPackage => package?.startsWith(_dartIgnoreCase) ?? false;
  bool get isPackage => package?.startsWith(_packageIgnoreCase) ?? false;
  bool get isRelative => !isDartPackage && !isPackage;

  void addShow(Identified identified) {
    if (hideSet.contains(identified)) {
      throw StateError('The identified element ${identified.id?.id} '
          'cannot be added to show elements because it is already '
          'present in hide list;');
    }
    showSet.add(identified);
  }

  void addHide(Identified identified) {
    if (showSet.contains(identified)) {
      throw StateError('The identified element ${identified.id?.id} '
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
    buffer.writeKeyword(keywordExport);
    buffer.write("'");
    buffer.write(package);
    buffer.write("'");
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
  int compareTo(ExportDirective other) {
    if (package == null) {
      throw StateError('Package not yet declared');
    }
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
    /*  var comp = path.dirname(package).compareTo(path.dirname(other.package));
    if (comp != 0) {
      return comp;
    } */
    return package!.compareTo(other.package ?? '');
  }

  @override
  void addImport(ImportDirective import) =>
      throw StateError('You cannot add an import to an export directive!');

  @override
  void addExport(ExportDirective export) =>
      throw StateError('You cannot add an export to an export directive!');
}
