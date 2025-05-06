class ClothingItemData {
  final String nama;
  final int harga;
  int quantity;
  

  ClothingItemData({
    required this.nama,
    required this.harga,
    required this.quantity,
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
