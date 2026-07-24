

import 'dart:typed_data';

class PdfControllerWithKeyModel {
  String keyName;
  Uint8List imageUint8List;

  PdfControllerWithKeyModel({
    required this.keyName,
    required this.imageUint8List,
  });
}