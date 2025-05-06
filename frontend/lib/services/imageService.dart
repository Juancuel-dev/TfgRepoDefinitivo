import 'dart:async';
import 'package:flutter/services.dart';

class ImageService {
  static const String _assetsPath = 'assets/profile_pictures'; // Ruta de las imágenes de perfil

  /// Carga la imagen de perfil del usuario actual según su `imageId`.
  static Future<String> loadUserProfileImage(int imageId) async {
    final String imagePath = '$_assetsPath/$imageId.png';
    try {
      // Verificar si la imagen existe en los assets
      await rootBundle.load(imagePath);
      return imagePath; // Retornar la ruta de la imagen si existe
    } catch (e) {
      // Si no existe, retornar una imagen por defecto
      return '$_assetsPath/default.png';
    }
  }

  /// Carga todas las imágenes disponibles en la carpeta `assets/profile_pictures`.
  static Future<List<String>> loadAllProfileImages() async {
    try {
      // Obtener la lista de archivos en la carpeta de imágenes
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = Map<String, dynamic>.from(
        await Future.value((manifestContent.isNotEmpty ? manifestContent : {}) as FutureOr<Map>?),
      );

      // Filtrar las imágenes que están en la carpeta de perfil
      final List<String> imagePaths = manifestMap.keys
          .where((String key) => key.startsWith(_assetsPath) && key.endsWith('.png'))
          .toList();

      return imagePaths; // Retornar la lista de rutas de imágenes
    } catch (e) {
      // Si ocurre un error, retornar una lista vacía
      return [];
    }
  }
}