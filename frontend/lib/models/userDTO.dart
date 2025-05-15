class UserDTO {
  final String nombre;
  final String username;
  final String email;
  final int image;
  final int edad;
  final String pais;

  UserDTO({
    required this.nombre,
    required this.username,
    required this.email,
    required this.image,
    required this.edad,
    required this.pais,
  });

  // Convierte el objeto a un mapa (JSON)
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'username': username,
      'email': email,
      'image': image,
      'edad': edad,
      'pais': pais,
    };
  }
}