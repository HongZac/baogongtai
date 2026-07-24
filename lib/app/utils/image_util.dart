import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart';

///图片工具类，图片格片转换
class ImageUtil {

   /// 生成缩略图
   static File getThumbnail(Uint8List bytes,String path)  {

     // Read an image from file (webp in this case).
     // decodeImage will identify the format of the image and use the appropriate
     // decoder.
     final image = decodeImage(bytes)!;

     // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
     final thumbnail = copyResize(image, width: 800);
     var file = File(path);
     file.writeAsBytesSync(encodeJpg(thumbnail,quality:100));
     return file;
   }

   /// 生成缩略图
   static Uint8List getThumbnailBytes(Uint8List bytes)  {

     // Read an image from file (webp in this case).
     // decodeImage will identify the format of the image and use the appropriate
     // decoder.
     final image = decodeImage(bytes)!;

     // Resize the image to a 120x? thumbnail (maintaining the aspect ratio).
     final thumbnail = copyResize(image, width: 800);
     return Uint8List.fromList(encodeJpg(thumbnail,quality: 80));
   }


}