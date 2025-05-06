class UserDTO {
  final String nombre;
  final String username;
  final String email;
  final int image;

  UserDTO({
    required this.nombre,
    required this.username,
    required this.email,
    required this.image,
  });

  // Convierte el objeto a un mapa (JSON)
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'username': username,
      'email': email,
      'image': image,
    };
  }
}