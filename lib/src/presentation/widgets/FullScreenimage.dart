import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  const FullScreenImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios_new_outlined,
                  color: Colors.white,
                ),
              ),
      ),
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
