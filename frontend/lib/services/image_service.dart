import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ImageService {
  static Future<AssetImage> loadUserProfileImage(int imageId, BuildContext context) async {
    final String imagePath = 'images/$imageId.jpg';
    try {
      final AssetImage image = AssetImage(imagePath);
      await precacheImage(image, context);
      return image; // imagen si existe
    } catch (e) {
      // Si no existe, imagen por defecto
      return const AssetImage('images/default.jpg');
    }
  }

  static Future<List<AssetImage>> loadAllProfileImages() async {
    final List<AssetImage> images = [];
    const int totalImages = 17; 

    for (int i = 0; i < totalImages; i++) {
      final String imagePath = 'images/$i.jpg';
      images.add(AssetImage(imagePath));
    }

    return images;
  }
}

