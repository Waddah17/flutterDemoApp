import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thevendor/constants/configurations.dart';
import '../../../exceptions/my_erros_handler.dart';
import '../../../shared/models/currency.dart';

class ProductDetails {
  final String id;
  final String vendorId;
  final String storeName;
  final String title;
  final Currency currency;
  final double price;
  final double? oldPrice;
  final double? quantity;
  final String? brand;
  final String condition;
  final String? conditionNotes;
  final String? description;
  final String? howToPurchase;
  final String? externalDetailsUrl;
  final bool inWishList;
  final ImageDto mainImage;
  
  final List<ImageDto> subImages;
  final List<ProductAttribute> productAttributes;

  const ProductDetails(
      {required this.id,
        required this.vendorId,
        required this.storeName,
        required this.title,
        required this.currency,
        required this.price,
        required this.oldPrice,
        required this.quantity,
        required this.brand,
        required this.condition,
        required this.conditionNotes,
        required this.description,
        required this.howToPurchase,
        required this.externalDetailsUrl,
        required this.inWishList,
        required this.mainImage,
        required this.subImages,
        required this.productAttributes
      });

  static ProductDetails fromJson(Map<String, dynamic> json) => ProductDetails(
    id: json['id'],
    vendorId: json['vendorId'],
    storeName: json['storeName'],
    title: json['title'],
    currency: Currency.fromJson(json["currency"]),
    price: json['price'] as double,
    oldPrice: json['oldPrice'] as double?,
    quantity: json['quantity'] as double?,
    brand: json['brand'],
    condition: json['conditionDisplayName'],
    conditionNotes: json['conditionNotes'],
    description: json['description'],
    howToPurchase: json['howToPurchase'],
    externalDetailsUrl: json['externalDetailsUrl'],
    inWishList: json['inWishList'] as bool,
    mainImage: ImageDto.fromJson(json['mainImage']) ,
    subImages: json["subImages"].map<ImageDto>((json) => ImageDto.fromJson(json)).toList(),
    productAttributes: json["productAttributes"].map<ProductAttribute>((json) => ProductAttribute.fromJson(json)).toList(),
  );
}

class ProductAttribute {
  final String name;
  final String value;

  const ProductAttribute({required this.name, required this.value});

  static ProductAttribute fromJson(Map<String, dynamic> json) => ProductAttribute(
    name: json['attributeName'],
    value: json['value'],
  );
}

class ImageDto {
  final String name;
  final String originalName;
  final String url;
  final String originalUrl;
  final int displayOrder;

  const ImageDto({required this.name, required this.originalName, required this.url, required this.originalUrl, required this.displayOrder});

  static ImageDto fromJson(Map<String, dynamic> json) => ImageDto(
    name: json['name'],
    originalName: json['originalName'],
    url: "${ApiConfigurations.ImagesBaseUrl}${json['url']}",
    originalUrl: "${ApiConfigurations.ImagesBaseUrl}${json['originalUrl']}",
    displayOrder: json['displayOrder'] as int,
  );
}

class ProductDetailsApi {
  static Future<ProductDetails> getProduct(String id) async {
    ProductDetails product;
    try {
      final url = Uri.parse('${ApiConfigurations.BaseUrl}/Products/$id');

      final response = await http.get(url).timeout(Duration(seconds: ApiConfigurations.HttpGetTimeout));
      if (response.statusCode == 200) {
        final result = json.decode(response.body)['result'];
        product = ProductDetails.fromJson(result);

        return product;
      } else {
        throw Exception("Failed to get product");
      }
    }
    on Exception catch (ex) {
      MyErrorsHandler.handleException(ex);
    }

    throw Exception("Failed to get product");
  }

  static Future<int> checkStock(String id) async {
    final url = Uri.parse('${ApiConfigurations.BaseUrl}/Products/$id/CheckStock');

    final response = await http.get(url).timeout(Duration(seconds: ApiConfigurations.HttpGetTimeout));
    if (response.statusCode == 200) {
      final result = json.decode(response.body)['result'] as int;
      return result;
    } else {
      throw Exception();
    }
  }
}