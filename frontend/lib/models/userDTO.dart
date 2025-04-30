class UserDTO {
  final String nombre;
  final String username;
  final String password;
  final String email;

  UserDTO({
    required this.nombre,
    required this.username,
    required this.password,
    required this.email,
  });

  // Convierte el objeto a un mapa (JSON)
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'username': username,
      'password': password,
      'email': email,
    };
  }
}