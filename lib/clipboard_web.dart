import 'dart:js_interop';

void writeClipboard(String text) {
  try {
    _jsWriteClipboard(text.toJS);
  } catch (_) {
    // Ignore if clipboard API is not available or rejected.
  }
}

@JS('navigator.clipboard.writeText')
external JSPromise<JSAny?> _jsWriteClipboard(JSString text);
