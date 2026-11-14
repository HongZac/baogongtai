

import 'dart:typed_data';

class PdfControllerWithKeyModel {
  String keyName;
  Uint8List imageUint8List;
  Uint8List uint8listForAllPage;

  PdfControllerWithKeyModel({
    required this.keyName,
    required this.imageUint8List,
    required this.uint8listForAllPage,
  });
}