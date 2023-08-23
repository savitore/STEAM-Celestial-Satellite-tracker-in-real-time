import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ZoomedScreen extends StatelessWidget {
  final String image;

  const ZoomedScreen({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: const Icon(Icons.clear_rounded)
        ),
      ),
      body: GestureDetector(
        onVerticalDragStart: (details){
          Navigator.pop(context);
        },
        child: Center(
          child: PhotoView(
            imageProvider: NetworkImage(image),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2.5,
          ),
        ),
      ),
    );
  }
}
