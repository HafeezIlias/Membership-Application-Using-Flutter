class Myproduct {
  String? productId;
  String? productTitle;
  String? productDescription;
  String? productType;
  String? productFilename;
  String? productDate;
  double? productPrice; // Changed to int
  int? productStock; // Changed to int

  Myproduct({
    this.productId,
    this.productTitle,
    this.productDescription,
    this.productType,
    this.productFilename,
    this.productDate,
    this.productPrice,
    this.productStock,
  });

  Myproduct.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'];
    productTitle = json['product_title'];
    productDescription = json['product_description'];
    productType = json['product_type'];
    productFilename = json['product_filename'];
    productDate = json['product_date'];
    productPrice = json['product_price'] != null
        ? double.tryParse(json['product_price'].toString())
        : null;
    productStock = json['product_stock'] != null
        ? int.tryParse(json['product_stock'].toString())
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = productId;
    data['product_title'] = productTitle;
    data['product_description'] = productDescription;
    data['product_type'] = productType;
    data['product_filename'] = productFilename;
    data['product_date'] = productDate;
    data['product_price'] = productPrice?.toString(); // Convert to string for JSON
    data['product_stock'] = productStock?.toString(); // Convert to string for JSON
    return data;
  }
}
