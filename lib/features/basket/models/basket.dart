import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thevendor/constants/configurations.dart';
import 'package:thevendor/exceptions/my_erros_handler.dart';
import '../../../shared/models/currency.dart';

class BasketViewDto {
  final String id;
  final bool isBasketOwner;
  final Currency currency;
  final double itemsCount;
  final double subTotal;
  final double delivery;
  final double total;

  final List<BasketVendorViewDto> basketVendors;

  const BasketViewDto({
    required this.id,
    required this.isBasketOwner,
    required this.basketVendors,
    required this.currency,
    required this.itemsCount,
    required this.subTotal,
    required this.delivery,
    required this.total,
  });

  static BasketViewDto fromJson(Map<String, dynamic> json) => BasketViewDto(
      id: json['id'],
      isBasketOwner: json['isBasketOwner'] as bool,
      currency: Currency.fromJson(json["currency"]),
      itemsCount: json['itemsCount'] as double,
      subTotal: json['subTotal'] as double,
      delivery: json['delivery'] as double,
      total: json['total'] as double,
      basketVendors:
          json["basketVendors"].map<BasketVendorViewDto>((json) => BasketVendorViewDto.fromJson(json)).toList());
}

class BasketVendorViewDto {
  final String vendorId;
  final String storeName;
  final String howToPurchase;
  final double subTotal;
  final double delivery;
  final double total;

  final List<BasketItemViewDto> basketItems;

  const BasketVendorViewDto(
      {required this.vendorId,
      required this.storeName,
      required this.howToPurchase,
      required this.subTotal,
      required this.delivery,
      required this.total,
      required this.basketItems});

  static BasketVendorViewDto fromJson(Map<String, dynamic> json) => BasketVendorViewDto(
        vendorId: json['vendorId'],
        storeName: json['storeName'],
        howToPurchase: json['howToPurchase'],
        subTotal: json['subTotal'] as double,
        delivery: json['delivery'] as double,
        total: json['total'] as double,
        basketItems: json["basketItems"].map<BasketItemViewDto>((json) => BasketItemViewDto.fromJson(json)).toList(),
      );
}

class BasketItemViewDto {
  final String id;
  final String productId;
  final String productImageUrl;
  final String productTitle;
  final double price;
  final double quantity;
  final Currency currency;
  final double total;

  const BasketItemViewDto(
      {required this.id,
      required this.productId,
      required this.productImageUrl,
      required this.productTitle,
      required this.price,
      required this.quantity,
      required this.currency,
      required this.total});

  static BasketItemViewDto fromJson(Map<String, dynamic> json) => BasketItemViewDto(
        id: json['id'],
        productId: json['productId'],
        productImageUrl: json['productImageUrl'],
        productTitle: json['productTitle'],
        price: json['price'] as double,
        quantity: json['quantity'] as double,
        currency: Currency(iso: json['currencyIso'], name: json['currencyName']),
        total: json['total'] as double,
      );
}

class BasketApi {
  static Future<BasketViewDto?> getAsync() async {
    try {
      var basketId = await _fetchBasketIdAsync();

      final url = Uri.parse('${ApiConfigurations.BaseUrl}/Baskets/$basketId');

      final response = await http.get(url).timeout(Duration(seconds: ApiConfigurations.HttpGetTimeout));
      final prefs = await SharedPreferences.getInstance();

      if (response.statusCode == 200) {
        final result = json.decode(response.body)['result'];
        if (result == null) {
          await prefs.setDouble('itemsCount', 0);
          await prefs.remove('basketId');
          return null;
        }

        final BasketViewDto basket = BasketViewDto.fromJson(result);

        await prefs.setDouble('itemsCount', basket.itemsCount);

        return basket;
      } else {
        await prefs.setDouble('itemsCount', 0);
        await prefs.remove('basketId');
        throw Exception("Failed to get Basket");
      }
    } on Exception catch (ex) {
      MyErrorsHandler.handleException(ex);
    }
  }

  static Future addItemAsync(String productId) async {
    try {
      var basketId = await _fetchBasketIdAsync();
      final url = Uri.parse('${ApiConfigurations.BaseUrl}/Baskets');

      final response = await http.post(
        url,
        headers: ApiConfigurations.JsonContentType,
        body: jsonEncode(<String, String>{
          'basketId': basketId,
          'productId': productId,
          'quantity': "1",
        }),
      ).timeout(Duration(seconds: ApiConfigurations.HttpPostTimeout));

      if (response.statusCode == 201) {
        final basketId = json.decode(response.body)['result']['basketId'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('basketId', basketId);
      } else {
        throw Exception("Failed to add item to basket");
      }
    }
    on Exception catch (ex) {
      MyErrorsHandler.handleException(ex);
    }
  }

  static Future<BasketViewDto?> updateQuantityAsync(String itemId, double quantity) async {
    try {
      var basketId = await _fetchBasketIdAsync();
      final url = Uri.parse('${ApiConfigurations.BaseUrl}/Baskets/$basketId');

      final response = await http.patch(
        url,
        headers: ApiConfigurations.JsonContentType,
        body: jsonEncode(<String, String>{
          'basketId': basketId,
          'id': itemId,
          'quantity': quantity.toString(),
        }),
      ).timeout(Duration(seconds: ApiConfigurations.HttpPostTimeout));

      if (response.statusCode == 200) {
        return await getAsync();
      } else if (response.statusCode == 400) {
        MyErrorsHandler.display400ErrorMessage(json.decode(response.body));
      } else {
        throw Exception('Failed to update basket');
      }
    }
    on Exception catch (ex) {
      MyErrorsHandler.handleException(ex);
    }
  }

  static Future<BasketViewDto?> deleteItemAsync(String itemId) async {
    try {
      var basketId = await _fetchBasketIdAsync();
      final url = Uri.parse('${ApiConfigurations.BaseUrl}/Baskets/$basketId/item/$itemId');

      final response = await http.delete(url).timeout(Duration(seconds: ApiConfigurations.HttpPostTimeout));
      if (response.statusCode == 204) {
        return await getAsync();
      } else {
        throw Exception("Failed to delete basket item");
      }
    }
    on Exception catch (ex) {
      MyErrorsHandler.handleException(ex);
    }
  }

  static Future<String> _fetchBasketIdAsync() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('basketId') ?? "";
  }

  static Future<double> fetchBasketItemsCountAsync() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getDouble('itemsCount') ?? 0;
  }
}
