
class CartItem {
  int? cartId;
  int? userId;
  int? productId;
  int? quantity;
  DateTime? addedDate;
  String? productTitle;
  double? productPrice;
  String? productFilename;

  CartItem({
    this.cartId,
    this.userId,
    this.productId,
    this.quantity,
    this.addedDate,
    this.productTitle,
    this.productPrice,
    this.productFilename,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      cartId: json['cart_id'] as int?,
      userId: json['user_id'] as int?,
      productId: json['product_id'] as int?,
      quantity: json['quantity'] as int?,
      addedDate: json['added_date'] != null
          ? DateTime.parse(json['added_date'])
          : null,
      productTitle: json['product_title'] as String?,
      productPrice: json['product_price'] != null
          ? (json['product_price'] as num).toDouble()
          : null,
      productFilename: json['product_filename'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cart_id': cartId,
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
      'added_date': addedDate?.toIso8601String(),
      'product_title': productTitle,
      'product_price': productPrice,
      'product_filename': productFilename,
    };
  }
}
