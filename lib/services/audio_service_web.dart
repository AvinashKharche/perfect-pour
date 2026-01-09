// ignore: avoid_web_libraries_in_flutter
import 'dart:js_util' as js_util;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void playWebSound(String type) {
  try {
    js_util.callMethod(html.window, 'playGameSound', [type]);
  } catch (e) {
    // Silently fail if audio not available
  }
}
