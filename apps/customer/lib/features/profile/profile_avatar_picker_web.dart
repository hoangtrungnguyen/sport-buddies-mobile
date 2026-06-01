import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

Future<(Uint8List, String, String)?> pickAvatarFile() async {
  final input = html.FileUploadInputElement()
    ..accept = 'image/jpeg,image/png'
    ..click();

  // Stream.first auto-cancels its subscription after the first event,
  // so the input.onChange listener does not leak.
  await input.onChange.first;
  final file = input.files?.first;
  if (file == null) return null;

  final mime = file.type.toLowerCase();
  final isValidFormat =
      mime == 'image/jpeg' || mime == 'image/jpg' || mime == 'image/png';
  if (!isValidFormat) {
    throw 'invalid_format';
  }

  if (file.size > 2 * 1024 * 1024) {
    throw 'file_too_large';
  }

  final reader = html.FileReader();
  final completer = Completer<(Uint8List, String, String)?>();

  late final StreamSubscription<html.Event> loadSub;
  late final StreamSubscription<html.Event> errorSub;
  void cleanup() {
    loadSub.cancel();
    errorSub.cancel();
  }

  loadSub = reader.onLoad.listen((_) {
    cleanup();
    final result = reader.result;
    if (result is List<int>) {
      completer.complete((Uint8List.fromList(result), file.name, file.type));
    } else {
      completer.complete(null);
    }
  });
  errorSub = reader.onError.listen((_) {
    cleanup();
    completer.complete(null);
  });

  reader.readAsArrayBuffer(file);
  return completer.future;
}
