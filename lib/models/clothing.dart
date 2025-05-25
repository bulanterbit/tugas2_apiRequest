// lib/models/clothing.dart
class Clothing {
  final int? id;
  final String name;
  final int? price; // Changed to nullable int
  final String category;
  final String? brand;
  final int? sold;
  final double? rating; // Changed to nullable double
  final int? stock;
  final int? yearReleased; // Changed to nullable int
  final String? material;

  Clothing({
    this.id,
    required this.name,
    this.price, // Now nullable
    required this.category,
    this.brand,
    this.sold,
    this.rating, // Now nullable
    this.stock,
    this.yearReleased, // Now nullable
    this.material,
  });

  factory Clothing.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse numbers that might be null or of wrong type
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      if (value is double)
        return value
            .toInt(); // If API sometimes sends int as double e.g. 15000.0
      return null;
    }

    return Clothing(
      id: parseInt(json['id']), // Made parsing more robust
      name:
          json['name'] as String? ??
          'Unnamed Product', // Provide default if name is null
      price: parseInt(json['price']),
      category:
          json['category'] as String? ?? 'Uncategorized', // Provide default
      brand: json['brand'] as String?,
      sold: parseInt(json['sold']),
      rating: parseDouble(json['rating']),
      stock: parseInt(json['stock']),
      yearReleased: parseInt(json['yearReleased']),
      material: json['material'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    // This method is used when sending data TO the API (e.g., POST, PUT)
    // Ensure that fields required by the API are not null when this is called.
    // The form validation should handle this.
    final Map<String, dynamic> data = {
      'name': name,
      'price': price, // API expects int
      'category': category,
      'rating': rating, // API expects float/double
      'yearReleased': yearReleased, // API expects int
    };
    // Add optional fields only if they have values
    if (id != null) data['id'] = id;
    if (brand != null) data['brand'] = brand;
    if (sold != null) data['sold'] = sold;
    if (stock != null) data['stock'] = stock;
    if (material != null) data['material'] = material;

    // If your API for POST/PUT is strict about not receiving nulls for optional fields:
    // data.removeWhere((key, value) => value == null && key != 'id'); // 'id' might be null for new items but not sent

    return data;
  }
}
