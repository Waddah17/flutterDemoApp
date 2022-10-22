import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/color_helpers.dart';
import '../../utils/string_helpers.dart';
import '../../features/search/presentation/search_page.dart';
import '../../constants/configurations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppBarSearch extends StatelessWidget {
  const AppBarSearch({super.key, this.query = ""});

  final String query;

  @override
  Widget build(BuildContext context) {
    final textEditingController = TextEditingController(text: query.firstFewWords(10));
    textEditingController.selection = const TextSelection.collapsed(offset: 0);

    return Container(
      child: TypeAheadField<Product?>(
        hideSuggestionsOnKeyboardHide: true,
        textFieldConfiguration: TextFieldConfiguration(
            onTap: () => {
                  //textEditingController.text = query ?? "",
                  textEditingController.selection = TextSelection.collapsed(offset: textEditingController.text.length),
                },
            onSubmitted: (String queryStr) => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SearchPage(
                              query: queryStr,
                              vendorId: "" ,
                            )),
                  )
                },
            style: const TextStyle(
              fontSize: 16,
              overflow: TextOverflow.ellipsis,
            ),
            controller: textEditingController,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: HexColor.borderPrimaryColor,
                    width: 0.2,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              border: const OutlineInputBorder(),
              hintText: AppLocalizations.of(context).searchForProducts,
              isDense: true,
              contentPadding: const EdgeInsets.all(10),
              suffixIcon: const Icon(Icons.search),
            )),
        suggestionsCallback: SearchApi.getProductSuggestions,
        itemBuilder: (context, Product? suggestion) {
          final product = suggestion;
          return Container(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2))),
            child: ListTile(
              title: Text(product?.title.firstFewWords(10) ?? '', style: const TextStyle(overflow: TextOverflow.clip)),
            ),
          );
        },
        noItemsFoundBuilder: (context) {
          return SizedBox(
            height: 0,
            child: Center(
              child: Text(
                AppLocalizations.of(context).noResultsMessage,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          );
        },
        onSuggestionSelected: (Product? suggestion) {
          final product = suggestion!;
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SearchPage(
                      query: product.title,
                      vendorId: "",
                    )),
          );
        },
      ),
    );
  }
}

class Product {
  final String title;

  const Product({required this.title});

  static Product fromJson(Map<String, dynamic> json) => Product(
        title: json['title'],
      );
}

class SearchApi {
  static Future<List<Product>> getProductSuggestions(String query) async {
    if (query.length < 2) {
      return <Product>[];
    }

    final url = Uri.parse(
        '${ApiConfigurations.BaseUrl}/Products/Suggest?query=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List products = json.decode(response.body)['result'];

      final res = products.map((json) => Product.fromJson(json)).where((product) {
        final titleLower = product.title.toLowerCase();
        final queryLower = query.toLowerCase();
        return titleLower.contains(queryLower);
      }).toList();

      return res;
    } else {
      throw Exception();
    }
  }
}
