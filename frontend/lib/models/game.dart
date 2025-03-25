class Game {
  final String name;
  final double precio;
  final int metacritic;
  final String consola;
  final String imageUrl;

  Game({
    required this.name,
    required this.precio,
    required this.metacritic,
    required this.consola,
    required this.imageUrl,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      name: json['name'],
      precio: json['precio'].toDouble(),
      metacritic: json['metacritic'],
      consola: json['consola'],
      imageUrl: json['imagen'],
    );
  }
}