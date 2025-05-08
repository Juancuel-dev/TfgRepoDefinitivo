import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

class ImageService {// Ruta de las imágenes de perfil

  /// Carga la imagen de perfil del usuario actual según su `imageId`.
  static Future<AssetImage> loadUserProfileImage(int imageId, BuildContext context) async {
    final String imagePath = '$imageId.png';
    try {
      // Verificar si la imagen existe utilizando AssetImage
      final AssetImage image = AssetImage(imagePath);
      await precacheImage(image, context); // Precargar la imagen con un BuildContext válido
      return image; // Retornar la imagen si existe
    } catch (e) {
      // Si no existe, retornar una imagen por defecto
      return const AssetImage('default.png');
    }
  }

  /// Carga todas las imágenes disponibles en la carpeta `assets/profile_pictures`.
  static Future<List<AssetImage>> loadAllProfileImages() async {
    try {
      // Obtener la lista de imágenes disponibles en la carpeta
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = Map<String, dynamic>.from(
        await Future.value((manifestContent.isNotEmpty ? manifestContent : {}) as FutureOr<Map>?),
      );

      // Filtrar las imágenes que están en la carpeta de perfil
      final List<String> imagePaths = manifestMap.keys
          .where((String key) => key.endsWith('.png'))
          .toList();

      // Convertir las rutas a AssetImage
      return imagePaths.map((path) => AssetImage(path)).toList();
    } catch (e) {
      // Si ocurre un error, retornar una lista vacía
      return [];
    }
  }
}