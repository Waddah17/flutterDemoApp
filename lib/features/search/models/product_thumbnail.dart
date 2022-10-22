import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thevendor/constants/configurations.dart';
import '../../../exceptions/my_erros_handler.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/models/currency.dart';

class ProductThumbnail {
  final String id;
  final String vendorId;
  final String storeName;
  final String title;
  final String imageUrl;
  final Currency currency;
  final double price;
  final double? oldPrice;
  final bool isInWishList;
  final int order;

  const ProductThumbnail(
      {required this.id,
      required this.vendorId,
      required this.storeName,
      required this.title,
      required this.imageUrl,
      required this.currency,
      required this.price,
      required this.oldPrice,
      required this.isInWishList,
      required this.order});

  static ProductThumbnail fromJson(Map<String, dynamic> json) => ProductThumbnail(
        id: json['id'],
        vendorId: json['vendorId'],
        storeName: json['storeName'],
        title: json['title'],
        imageUrl: json['mainImage'],
        currency: Currency.fromJson(json["currency"]),
        price: json['price'] as double,
        oldPrice: json['oldPrice'] as double?,
        isInWishList: json['isInWishList'] as bool,
        order: json['order'] as int,
      );
}

class ProductAttribute {
  final String displayName;
  final String name;
  final List<ProductAttributeValue> values;

  const ProductAttribute({required this.displayName, required this.name, required this.values});

  static ProductAttribute fromJson(Map<String, dynamic> json) => ProductAttribute(
        displayName: json['displayName'],
        name: json['name'],
        values: json["values"].map<ProductAttributeValue>((json) => ProductAttributeValue.fromJson(json)).toList(),
      );
}

class ProductAttributeValue {
  final String displayValue;
  final String value;
  final int productsCount;

  const ProductAttributeValue({required this.displayValue, required this.value, required this.productsCount});

  static ProductAttributeValue fromJson(Map<String, dynamic> json) => ProductAttributeValue(
        displayValue: json['displayValue'],
        value: json['value'],
        productsCount: json['productsCount'] as int,
      );
}

class SelectedProductAttribute {
  final String name;
  List<String> values = [];
  List<String> appliedValues = [];

  SelectedProductAttribute({required this.name, required this.values});

  String toQueryString() {
    appliedValues.clear();
    appliedValues.insertAll(0, values);
    return "$name=${values.join(',')}";
  }
}

class SearchProductsApi {
  static Future<List<ProductThumbnail>> searchProducts(
      List<ProductThumbnail> products,
      List<ProductAttribute> productAttributes,
      String query,
      String? vendorId,
      SearchSort? searchSort,
      String? attributes,
      int page,
      int size,
      bool appendRes,
      {bool isSortingRequest = false}) async {
    try {
      if (page == 1) {
        size = 16;
      }

      final url = Uri.parse(
          '${ApiConfigurations.BaseUrl}/Search/Products?searchText=$query&vendorId=$vendorId&searchSort=${searchSort?.toShortString()}&attributes=$attributes&page=$page&size=$size');

      final response = await http.get(url).timeout(Duration(seconds: ApiConfigurations.HttpGetTimeout));
      if (response.statusCode == 200) {
        final result = json.decode(response.body)['result'];
        final List productsRes = result['data']['products'];
        final List<ProductThumbnail> productsList = productsRes.map((json) => ProductThumbnail.fromJson(json)).toList();

        if (appendRes) {
          products.insertAll(products.length, productsList);
        } else {
          products.insertAll(0, productsList);
          if (!isSortingRequest) {
            final List productAttributesRes = result['data']['productAttributes'];
            productAttributes.insertAll(
                0, productAttributesRes.map((json) => ProductAttribute.fromJson(json)).toList());
          }
        }
        return products;
      } else {
        throw Exception("Failed to search products");
      }
    } on Exception catch (ex) {
      MyErrorsHandler.handleException(ex);
    }
    return products;
  }
}
