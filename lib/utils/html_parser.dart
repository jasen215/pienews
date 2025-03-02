import 'package:html/parser.dart' show parse;

String parseHtmlContent(String html) {
  final document = parse(html);
  return document.body?.text ?? html;
}
