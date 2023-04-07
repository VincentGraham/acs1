// https://rodolfohernan20.blogspot.com/2019/12/upload-files-to-server-with-flutter-web.html
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

startWebFilePicker() async {
  Completer<String> completer = Completer();
  var result;
  html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
  uploadInput.multiple = true;
  uploadInput.draggable = true;
  uploadInput.click();

  uploadInput.onChange.listen((e) {
    final file = uploadInput.files![0];
    final reader = html.FileReader();
    reader.readAsDataUrl(file);
    reader.onLoadEnd.listen((e) {
      final bytes =
          Base64Decoder().convert(reader.result.toString().split(',').last);
      // this is the file's contents
      result = String.fromCharCodes(bytes);
      if (result != null) completer.complete(result);
    });
  });
  return await completer.future;
}
