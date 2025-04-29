class ClothingItemData {
  final String name;
  final int price;
  int quantity;
  final String? imageUrl;

  ClothingItemData({
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });
}

class AdditionalServiceData {
  final String name;
  final int price;
  bool isSelected;

  AdditionalServiceData({
    required this.name,
    required this.price,
    required this.isSelected,
  });
}
