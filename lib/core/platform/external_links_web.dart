import 'package:web/web.dart' as web;

const supportsExternalLinks = true;

void openExternalLink(String url) {
  web.window.open(url, '_blank', 'noopener,noreferrer');
}
