import 'package:flutter/material.dart';


class ImageDocCard extends StatelessWidget {
  final String image;

  const ImageDocCard({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0.0),
        child: Stack(
          children: [
            Image.asset(image,
              height: 450,
              width: 150,
              fit: BoxFit.fill,
            ),
          ],
        ),
      ),
    );
  }
}
