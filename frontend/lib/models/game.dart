class Game {
  final String id;
  final String name;
  double precio;
  final int? metacritic; // Cambiar a nullable (int?)
  final String consola;
  final String imageUrl;

  Game({
    required this.id,
    required this.name,
    required this.precio,
    this.metacritic, // Permitir que sea null
    required this.consola,
    required this.imageUrl,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'] ?? '', // Valor predeterminado si el id es null
      name: json['name'] ?? 'Sin nombre', // Valor predeterminado si el nombre es null
      precio: (json['precio'] != null) ? json['precio'].toDouble() : 0.0, // Manejar null en precio
      metacritic: json['metacritic'] != null ? json['metacritic'] as int : null, // Manejar null en metacritic
      consola: json['consola'] ?? 'Desconocida', // Valor predeterminado si consola es null
      imageUrl: json['imagen'] ?? '', // Valor predeterminado si la imagen es null
    );
  }

  // Método para convertir un objeto Game a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'precio': precio,
      'metacritic': metacritic,
      'consola': consola,
      'imagen': imageUrl,
    };
  }
}