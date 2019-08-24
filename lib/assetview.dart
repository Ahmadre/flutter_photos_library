import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'asset.dart';
import 'photos_library.dart';
import 'dart:typed_data';

class AssetView extends StatefulWidget {
  final int index;
  final Asset asset;
  final double width;
  final double height;
  Uint8List _imageBytes;

  AssetView(
      {@required this.index,
      @required this.asset,
      @required this.width,
      @required this.height});

  Uint8List get getImageBytes => _imageBytes;

  @override
  State<StatefulWidget> createState() => AssetState(
      index: this.index,
      asset: this.asset,
      width: this.width,
      height: this.height);
}

class AssetState extends State<AssetView> {
  int index = 0;
  Asset asset;
  final double width;
  final double height;

  String _channelName;

  Widget assetWidget = Center(
      child: SizedBox(
          width: 32.0, height: 32.0, child: CircularProgressIndicator()));

  AssetState(
      {@required this.index,
      @required this.asset,
      @required this.width,
      @required this.height}) {
    const prefix = 'flutter.yang.me/photos_library/image';
    this._channelName = prefix + '/' + this.asset.identifier;
  }

  @override
  void initState() {
    super.initState();

    this._requestThumbnail(
        width: this.width.toInt(), height: this.height.toInt());
  }

  @override
  void deactivate() {
    super.deactivate();
    BinaryMessages.setMessageHandler(this._channelName, null);
  }

  void _requestThumbnail({int width, int height}) {
    BinaryMessages.setMessageHandler(this._channelName, (message) {
      widget._imageBytes = message.buffer.asUint8List();
      setState(() {});
      assetWidget = AnimatedSwitcher(
        duration: const Duration(milliseconds: 2000),
        child: message != null
            ? Image.memory(
                message.buffer.asUint8List(),
                fit: BoxFit.cover,
                width: this.width,
                height: this.height,
                gaplessPlayback: true,
              )
            : Container(),
        key: ValueKey<ByteData>(message),
      );
    });

    PhotosLibrary.requestThumbnail(this.asset.identifier, width, height);
  }

  @override
  Widget build(BuildContext context) {
    return assetWidget;
  }
}
