import 'package:flutter/material.dart';

class RoundedGreyContainer extends StatelessWidget {
  final double width;
  final double height;
  final List<Widget> children;
  // optional:
  final String? imagePath;
  final String? defaultImagePath;

  RoundedGreyContainer({
    required this.width,
    required this.height,
    required this.children,
    this.imagePath,
    this.defaultImagePath,
  });

  @override
  Widget build(BuildContext context) {
    double containerWidth = width;
    double containerHeight = height;

    // Adjust container size if image dimensions are provided
    if (imagePath != null) {
      containerWidth = width + 20;
      containerHeight = height + 20;
    }

    return Container(
      width: containerWidth,
      height: containerHeight,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        // below we can accept numerous widgets like text, image and more...ą
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imagePath != null)
              Image.network(
                imagePath!,
                width: width,
                height: height,
                fit: BoxFit.cover, // Ensure the image fits inside the box
              ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
