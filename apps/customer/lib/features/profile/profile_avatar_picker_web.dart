import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

Future<(Uint8List, String, String)?> pickAvatarFile() async {
  final completer = Completer<(Uint8List, String, String)?>();
  final input = html.FileUploadInputElement()
    ..accept = 'image/jpeg,image/png'
    ..click();

  input.onChange.listen((_) {
    final file = input.files?.first;
    if (file == null) {
      completer.complete(null);
      return;
    }

    // Validate type
    final mime = file.type.toLowerCase();
    final isValidFormat = mime == 'image/jpeg' || mime == 'image/jpg' || mime == 'image/png';
    if (!isValidFormat) {
      completer.completeError('invalid_format');
      return;
    }

    // Validate size (max 2 MB = 2 * 1024 * 1024 bytes)
    if (file.size > 2 * 1024 * 1024) {
      completer.completeError('file_too_large');
      return;
    }

    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    reader.onLoad.listen((_) {
      final result = reader.result;
      if (result is List<int>) {
        completer.complete((Uint8List.fromList(result), file.name, file.type));
      } else {
        completer.complete(null);
      }
    });
    reader.onError.listen((_) => completer.complete(null));
  });

  return completer.future;
}
