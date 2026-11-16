/// Katalogdaki tek bir bitkiyi temsil eden model sınıfı.
class Product {
  final int id;
  final String name;
  final String latinName;
  final String category;
  final double price;
  final String image;
  final String description;
  final String light;
  final String water;
  final String difficulty;
  final bool petFriendly;

  const Product({
    required this.id,
    required this.name,
    required this.latinName,
    required this.category,
    required this.price,
    required this.image,
    required this.description,
    required this.light,
    required this.water,
    required this.difficulty,
    required this.petFriendly,
  });

  /// JSON (Map) verisinden Product nesnesi oluşturur.
  factory Product.fromJson(Map<String, dynamic> json) {
    final care = json['care'] as Map<String, dynamic>;
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      latinName: json['latinName'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String,
      description: json['description'] as String,
      light: care['light'] as String,
      water: care['water'] as String,
      difficulty: care['difficulty'] as String,
      petFriendly: json['petFriendly'] as bool? ?? false,
    );
  }

  /// Product nesnesini tekrar JSON (Map) yapısına çevirir.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latinName': latinName,
      'category': category,
      'price': price,
      'image': image,
      'description': description,
      'care': {
        'light': light,
        'water': water,
        'difficulty': difficulty,
      },
      'petFriendly': petFriendly,
    };
  }
}
