import 'package:flutter/material.dart';
import 'package:ichat_app/allConstants/app_constants.dart';
import 'package:ichat_app/allConstants/color_constants.dart';
import 'package:photo_view/photo_view.dart';

import '../main.dart';

class FullPhotoPage extends StatelessWidget {

   final String url;

   const FullPhotoPage({Key ? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isWhite ? Colors.white : Colors.black,
      appBar: AppBar(
        backgroundColor: isWhite ? Colors.white : Colors.black,
        iconTheme: IconThemeData(
          color: ColorConstants.primaryColor,
        ),
        title: Text(
          AppConstants.fullPhotoTitle,
          style: TextStyle(
            color: ColorConstants.primaryColor
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: PhotoView(
          imageProvider: NetworkImage(url),
        ),
      ),
    );
  }
}
