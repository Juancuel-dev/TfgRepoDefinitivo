import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ImageService {
  /// Carga la imagen de perfil del usuario actual según su `imageId`.
  static Future<AssetImage> loadUserProfileImage(int imageId, BuildContext context) async {
    final String imagePath = 'images/$imageId.jpg'; // Ruta completa de la imagen
    try {
      // Verificar si la imagen existe utilizando AssetImage
      final AssetImage image = AssetImage(imagePath);
      // Precargar la imagen después de que el contexto esté completamente inicializado
      await precacheImage(image, context);
      return image; // Retornar la imagen si existe
    } catch (e) {
      print('Error loading image: $e'); // Imprimir error en caso de fallo
      // Si no existe, retornar una imagen por defecto
      return const AssetImage('images/default.jpg');
    }
  }

  /// Genera una lista de imágenes basadas en un rango de índices.
  static Future<List<AssetImage>> loadAllProfileImages() async {
    final List<AssetImage> images = [];
    const int totalImages = 15; // Número total de imágenes (0.jpg a 14.jpg)

    for (int i = 0; i < totalImages; i++) {
      final String imagePath = 'images/$i.jpg';
      images.add(AssetImage(imagePath));
    }

    return images;
  }
}

