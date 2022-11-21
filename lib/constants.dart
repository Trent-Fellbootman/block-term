var _promptList = [
  String.fromCharCode(27),
  r'\[\?2004h',
  String.fromCharCode(27),
  // r'\[34;1m\d+:\d+:\d+ ',
  r'\[[^\n]+m\d+:\d+:\d+ ',
  String.fromCharCode(27),
  r'[^\n]*',
  // r'\[0;97m',
  r'\[[^\n]+m',
  String.fromCharCode(27),
  r'[^\n]*',
  // r'\[90;1m',
  r'\[[^\n]+m',
  'trent@trent-AORUS-15-XE4 ',
  r'.*',
  // String.fromCharCode(27),
  // r'\[36;1mterminal_test ',
  // String.fromCharCode(27),
  // r'\[32;1m→ ',
  r'→ ',
  String.fromCharCode(27),
  r'\[0m'
];

var _bufferPromptList = [r'\d+:\d+:\d+[^\n]*trent@trent-AORUS-15-XE4[^\n]*→ '];

String promptPattern = _promptList.join('');
String bufferPromptPattern = _bufferPromptList.join('');
String continuer = r'\';
String submitCommand = '\n';

class Detectors {
  static bool detectBackspace(String input) {
    return input.contains('\b') || input.contains(String.fromCharCode(7));
  }

  static bool detectContinuer(String input) {
    return input.contains(r'\');
  }

  static bool detectCommandSubmitter(String input) {
    return input.contains('\n') || input.contains(String.fromCharCode(13));
  }
}
