import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:thevendor/constants/configurations.dart';
import 'package:thevendor/features/basket/models/basket.dart';
import 'package:thevendor/features/basket/presentation/basket_page.dart';
import 'package:thevendor/shared/components/snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:thevendor/features/product/models/product.dart';
import '../../../shared/components/border.dart';
import '../../../shared/components/counter_badge.dart';
import '../../../shared/components/unordered_list.dart';
import '../../../utils/color_helpers.dart';
import '../../../utils/string_helpers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

int availableQuantity = 1;

class ProductPage extends ConsumerStatefulWidget {
  const ProductPage({super.key, required this.id});

  final String id;

  @override
  ConsumerState<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends ConsumerState<ProductPage> {
  late Future<ProductDetails> product;

  @override
  void initState() {
    super.initState();
    product = ProductDetailsApi.getProduct(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        //backgroundColor: HexColor.bodyBackgroundPrimaryColor,
        leading: BackButton(
          color: HexColor.cardTextPrimaryColor,
        ),
        actions: [
          Container(
            padding: const EdgeInsets.only(left: 20),
            child: GestureDetector(
              onTap: () async => await launchUrl(Uri.parse(
                  '${ApiConfigurations.WhatsAppShareBaseUrl}${AppLocalizations.of(context).shareProductMessage} ${ApiConfigurations.WebsiteBaseUrl}/ar/Product/Details/${widget.id}')),
              child: Icon(
                Icons.share,
                color: HexColor.cardTextPrimaryColor,
                size: 22,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 25),
            width: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BasketPage(),
                        ));
                  },
                  child: Icon(
                    Icons.shopping_cart,
                    color: HexColor.cardTextPrimaryColor,
                    size: 22,
                  ),
                ),
                Positioned(
                  top: 15,
                  left: 18,
                  child: FutureBuilder(
                    future: BasketApi.fetchBasketItemsCountAsync(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != 0) {
                        return counterBadge(snapshot.data.toString().toFixedPrice());
                      } else {
                        return const SizedBox(height: 0);
                      }
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: FutureBuilder(
        future: product,
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return bottomBar(snapshot.data.id, snapshot.data.price.toString().toPriceStr(snapshot.data.currency));
          }
        },
      ),
      body: Center(
        child: FutureBuilder(
          future: product,
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return buildPage(context, snapshot);
            }
          },
        ),
      ),
    );
  }

  Widget buildPage(BuildContext context, AsyncSnapshot snapshot) {
    var product = snapshot.data;

    return ListView(
      children: [
        hero(product),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                border: borderBottom,
                boxShadow: borderBottomShadow,
              ),
              child: Column(
                children: [
                  title(context, product),
                  const SizedBox(
                    height: 10,
                    child: Divider(),
                  ),
                  price(product),
                  brand(product),
                  quantity(product),
                  buyNow(product.id)
                ],
              ),
            ),
            //howToPurchase(product),
            description(product),
            features(product)
          ],
        )
      ],
    );
  }

  Widget hero(ProductDetails product) {
    List<ImageDto> imgList = [];
    imgList.insert(0, product.mainImage);
    imgList.insertAll(imgList.length, product.subImages);
    int current = 0;

    return Stack(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 400,
            maxHeight: 485,
          ),
          child: Container(
            padding: const EdgeInsets.only(bottom: 5),
            decoration: const BoxDecoration(color: Colors.white),
            child: imgList.length > 1
                ? CarouselSliderWithIndicator(
                    imgList: imgList,
                  )
                : GestureDetector(
                    onTap: () => {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return ImageViewerPage(
                          tag: "product-image+$current",
                          image: product.mainImage.url,
                          imgList: imgList,
                          initialImageIndex: current,
                        );
                      }))
                    },
                    child: FadeInImage.assetNetwork(
                      placeholder: AppConfigurations.productPlaceHolderImage,
                      image: product.mainImage.url,
                    ),
                  ),
          ),
        ),
        Positioned(
            bottom: 10,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () async => await launchUrl(Uri.parse(
                  '${ApiConfigurations.WhatsAppBaseUrl}${product.title} ${ApiConfigurations.WebsiteBaseUrl}/ar/Product/Details/${product.id}')),
              child: Icon(
                Icons.whatsapp,
                color: HexColor.cardTextPrimaryColor,
              ),
            ))
      ],
    );
  }

  Widget title(BuildContext context, ProductDetails product) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 20,
      child: Text(
        maxLines: 3,
        product.title,
        style: TextStyle(color: HexColor.headerPrimaryColor, fontWeight: FontWeight.w500, fontSize: 16),
      ),
    );
  }

  Widget price(ProductDetails product) {
    return Row(
      children: [
        Expanded(
            child: Text(
          product.price.toString().toPriceStr(product.currency),
          style: TextStyle(color: HexColor.cardTextPrimaryColor, fontWeight: FontWeight.bold, fontSize: 16),
        )),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check,
              color: HexColor.textSuccessColor,
              size: 18,
            ),
            Text(
              product.condition,
              style: TextStyle(color: HexColor.textSuccessColor, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ],
    );
  }

  Widget brand(ProductDetails product) {
    if (product.brand == null) {
      return Container();
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Text(
              "${AppLocalizations.of(context).brand}:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              width: 10,
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(product.brand ?? ""),
            )
          ],
        ),
      );
    }
  }

  Widget quantity(ProductDetails product) {
    if (product.quantity == null) {
      return Container();
    }

    if (product.price == 0) {
      return quantityRow("0", product.price);
    } else {
      late Future<int> stock = ProductDetailsApi.checkStock(product.id);
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: product.externalDetailsUrl != null
            ? FutureBuilder(
                future: stock,
                builder: (context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(); //const Center(child: CircularProgressIndicator());
                  } else {
                    availableQuantity = snapshot.data;
                    return quantityRow(availableQuantity.toString().toFixedPrice(), product.price);
                  }
                },
              )
            : quantityRow(product.quantity.toString().toFixedPrice(), product.price),
      );
    }
  }

  Widget quantityRow(String quantity, double price) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "${AppLocalizations.of(context).availableQuantity}:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              width: 5,
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                quantity,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            )
          ],
        ),
        quantity == "0" || price == 0
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: HexColor.dangerAlertBackgroundColor,
                    border: border(HexColor.dangerAlertBorderColor),
                    boxShadow: borderShadow,
                    borderRadius: const BorderRadius.all(Radius.circular(5))),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        AppLocalizations.of(context).outOfStockMessage,
                        style: TextStyle(color: HexColor.dangerAlertTextColor, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              )
            : Container()
      ],
    );
  }

  Widget buyNow(String id) {
    return Container(
      alignment: Alignment.topRight,
      child: ElevatedButton(
        onPressed: () async => await launchUrl(Uri.parse(
            '${ApiConfigurations.WhatsAppBaseUrl}${AppLocalizations.of(context).whatsAppOrderMessage} ${ApiConfigurations.WebsiteBaseUrl}/ar/Product/Details/$id')),
        style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), side: BorderSide(color: HexColor.yellowColor))),
            backgroundColor: MaterialStateProperty.all(Color(toIntegerColor(HexColor.yellowColor)))),
        child: Text(
          AppLocalizations.of(context).orderNow,
          style: TextStyle(color: HexColor.cardTextPrimaryColor, fontSize: 18),
        ),
      ),
    );
  }

  Widget howToPurchase(ProductDetails product) {
    if (product.howToPurchase == null) {
      return Container();
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: border(),
          boxShadow: borderShadow,
        ),
        child: Html(data: product.howToPurchase),
      );
    }
  }

  Widget description(ProductDetails product) {
    if (product.description == null) {
      return const SizedBox(
        height: 10,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: border(),
        boxShadow: borderShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 15),
            child: Text(
              AppLocalizations.of(context).description,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: HexColor.primaryColor),
            ),
          ),
          Html(data: product.description)
        ],
      ),
    );
  }

  Widget features(ProductDetails product) {
    final attributesWidgets = product.productAttributes.map<Widget>((e) => featuresListTile(e.name, e.value)).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: border(),
        boxShadow: borderShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 15),
            child: Text(
              AppLocalizations.of(context).features,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: HexColor.primaryColor),
            ),
          ),
          Column(
            children: attributesWidgets,
          )
        ],
      ),
    );
  }

  Widget featuresListTile(String name, String value) {
    return Container(
      decoration: BoxDecoration(border: borderBottom),
      child: ListTile(
        title: Text(
          name,
          style: TextStyle(color: HexColor.cardTextPrimaryColor),
        ),
        trailing: Text(
          value,
          style: TextStyle(color: HexColor.cardTextPrimaryColor),
        ),
        onTap: () => {},
      ),
    );
  }

  Widget bottomBar(String productId, String price) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: Colors.white,
        border: border(),
        boxShadow: borderShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: ElevatedButton(
              onPressed: () => {
                if (availableQuantity == 0 || price.split(" ")[0] == "0")
                  {
                    CustomSnackBar.dangerAlert(
                        context, AppLocalizations.of(context).cannotAddThisProductToShoppingCartOutOfStockMessage)
                  }
                else
                  {
                    BasketApi.addItemAsync(productId).then((value) => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BasketPage(),
                        )))
                  }
              },
              child: Text(
                AppLocalizations.of(context).addToCart,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          Container(
            height: 40,
            padding: const EdgeInsets.only(right: 5, top: 10),
            child: Text(
              price,
              style: TextStyle(color: HexColor.primaryColor, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          )
        ],
      ),
    );
  }
}

class CarouselSliderWithIndicator extends StatefulWidget {
  const CarouselSliderWithIndicator({super.key, required this.imgList});

  final List<ImageDto> imgList;

  @override
  State<StatefulWidget> createState() {
    return _CarouselSliderWithIndicatorState();
  }
}

class _CarouselSliderWithIndicatorState extends State<CarouselSliderWithIndicator> {
  int current = 0;
  final CarouselController controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Hero(
            tag: "product-image+$current",
            child: CarouselSlider(
              carouselController: controller,
              options: CarouselOptions(
                  height: 450,
                  viewportFraction: 1,
                  onPageChanged: (index, reason) {
                    setState(() {
                      current = index;
                    });
                  }),
              items: widget.imgList
                  .map((img) => GestureDetector(
                        onTap: () => {
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return ImageViewerPage(
                              tag: "product-image+$current",
                              image: img.url,
                              imgList: widget.imgList,
                              initialImageIndex: current,
                            );
                          }))
                        },
                        child: FadeInImage.assetNetwork(
                          placeholder: AppConfigurations.productPlaceHolderImage,
                          image: img.url,
                        ),
                      ))
                  .toList(),
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.imgList.asMap().entries.map((entry) {
            return GestureDetector(
              //onTap: () => controller.animateToPage(entry.key),
              child: Container(
                width: 12.0,
                height: 12.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: HexColor.primaryColor.withOpacity(current == entry.key ? 0.9 : 0.4)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class ImageViewerPage extends StatelessWidget {
  ImageViewerPage(
      {super.key, required this.tag, required this.image, required this.imgList, required this.initialImageIndex});

  final String tag;
  final String image;
  final List<ImageDto> imgList;
  final int initialImageIndex;

  TransformationController transformationController = TransformationController();
  TapDownDetails doubleTapDetails = TapDownDetails();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        backgroundColor: HexColor.bodyBackgroundPrimaryColor,
        //backgroundColor: HexColor.bodyBackgroundPrimaryColor,
        leading: BackButton(
          color: HexColor.cardTextPrimaryColor,
        ),
      ),
      body: GestureDetector(
        // onTap: () {
        //   Navigator.pop(context);
        // },
        onDoubleTapDown: handleDoubleTapDown,
        onDoubleTap: handleDoubleTap,
        child: Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: UnorderedList([
                  AppLocalizations.of(context).doubleClickOnImageToZoomMessage,
                  AppLocalizations.of(context).useYourFingersToMoveImageMessage
                ]),
              ),
              Hero(
                tag: tag,
                child: CarouselSlider(
                  options: CarouselOptions(
                      viewportFraction: 1,
                      height: 450,
                      initialPage: initialImageIndex,
                      enableInfiniteScroll: imgList.length == 1 ? false : true),
                  items: imgList
                      .map((item) => Center(
                              child: InteractiveViewer(
                            transformationController: transformationController,
                            panEnabled: true,
                            // Set it to false
                            //boundaryMargin: const EdgeInsets.all(100),
                            minScale: 0.5,
                            maxScale: 2,
                            child: Image.network(
                              item.url,
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                            ),
                          )))
                      .toList(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void handleDoubleTapDown(TapDownDetails details) {
    doubleTapDetails = details;
  }

  void handleDoubleTap() {
    if (transformationController.value != Matrix4.identity()) {
      transformationController.value = Matrix4.identity();
    } else {
      final position = doubleTapDetails.localPosition;
      // For a 3x zoom
      transformationController.value = Matrix4.identity()
        //   ..translate(-position.dx * 2, -position.dy * 2)
        //   ..scale(3.0);
        //Fox a 2x zoom
        ..translate(-position.dx, -position.dy)
        ..scale(2.0);
    }
  }
}
