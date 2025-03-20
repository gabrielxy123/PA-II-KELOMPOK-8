class Laundry {
  final int id;
  final String name;
  final String address;
  final String profileImage;
  final bool isOpen;
  final double rating;
  final int minPrice;

  Laundry({
    required this.id,
    required this.name,
    required this.address,
    required this.profileImage,
    required this.isOpen,
    required this.rating,
    required this.minPrice,
  });

  factory Laundry.fromJson(Map<String, dynamic> json) {
    return Laundry(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      profileImage: json['profile_image'] ?? '',
      isOpen: json['is_open'] ?? false,
      rating: (json['rating'] ?? 0.0).toDouble(),
      minPrice: json['min_price'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'profile_image': profileImage,
      'is_open': isOpen,
      'rating': rating,
      'min_price': minPrice,
    };
  }
}
