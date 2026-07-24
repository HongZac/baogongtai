import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';


class FullScreenWrapper extends StatelessWidget {

  const FullScreenWrapper({
    super.key,
    this.buildContext,
    this.imageProvider,
    this.loadingChild,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialScale,
    this.basePosition = Alignment.center,
    this.isCloudServiceView = false,
  });

  final BuildContext? buildContext;
  final ImageProvider? imageProvider;
  final Widget? loadingChild;
  final BoxDecoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final dynamic initialScale;
  final Alignment basePosition;

  final bool isCloudServiceView;

  @override
  Widget build(BuildContext context) {
    Widget child = ClipRect(
      child: PhotoView(
        imageProvider: imageProvider,
        loadingBuilder: (context, url) => loadingChild ?? Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.blue),
            backgroundColor: Colors.white,
          ),
        ),
        backgroundDecoration: backgroundDecoration,
        minScale: minScale,
        maxScale: maxScale,
        enableRotation: true,
      ),
    );
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              right: 0,
              child: child,
            ),
            ///右上角关闭按钮
            if (!isCloudServiceView)
              Positioned(
                right: 10,
                top: MediaQuery.of(context).padding.top,
                child: IconButton(
                  icon: Icon(
                    Icons.cancel,
                    size: 55,
                    color: Colors.white.withAlpha(179),
                  ),
                  onPressed: (){
                    //Navigator.of(context).pop();
                    //Navigator.of(this.buildContext ?? Get.context!).pop();
                    Get.back();
                  },
                ),
              )
          ],
        ),
      ),
    );
  }

}
