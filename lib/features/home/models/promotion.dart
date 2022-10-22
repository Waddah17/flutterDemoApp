import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thevendor/constants/configurations.dart';
import '../../../exceptions/my_erros_handler.dart';

class Promotion {
  final String imageUrl;
  final int order;
  final String? query;
  final String? vendorId;
  final String? productId;

  const Promotion(
      {required this.imageUrl,
      required this.order,
      required this.query,
      required this.vendorId,
      required this.productId});

  static Promotion fromJson(Map<String, dynamic> json) => Promotion(
        imageUrl: json['imageUrl'],
        order: json['order'] as int,
        query: json['query'],
        vendorId: json['vendorId'],
        productId: json['productId'],
      );
}

class PromotionApi {
  static Future<List<Promotion>> getMainPromotions() async {
    List<Promotion> promotions = [];
    try {
      final url = Uri.parse('${ApiConfigurations.BaseUrl}/Promotions');
      final response = await http.get(url).timeout(Duration(seconds: ApiConfigurations.HttpGetTimeout));
      if (response.statusCode == 200) {
        final List result = json.decode(response.body)['result'];
        promotions = result.map((json) => Promotion.fromJson(json)).toList();
        return promotions;
      } else {
        throw Exception("Failed to get promotions");
      }
    }
    on Exception catch (ex) {
      MyErrorsHandler.handleException(ex);
    }

    return promotions;
  }
}
