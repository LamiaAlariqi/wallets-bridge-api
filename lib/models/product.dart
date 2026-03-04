class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is String ? int.parse(json['id']) : json['id'].toInt(),
      title: json['title']?.toString() ?? 'No Title',
      price: (json['price'] ?? 0).toDouble(),
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'uncategorized',
      image: json['thumbnail']?.toString() ?? '',
    );
  }
}
