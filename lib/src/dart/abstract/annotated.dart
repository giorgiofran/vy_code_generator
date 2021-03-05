import '../annotation.dart';

mixin Annotated {
  List<Annotation> annotations = <Annotation>[];

  void addAnnotation(Annotation annotation) => annotations.add(annotation);

  String generateAnnotations() => [
        for (var annotation in annotations) annotation.generate(),
      ].join('\n');
}
