import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thevendor/features/Home/presentation/home_page.dart';
import 'package:thevendor/features/basket/models/basket.dart';
import 'package:thevendor/features/search/presentation/search_page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../constants/configurations.dart';
import '../../../shared/components/border.dart';
import '../../../shared/components/bottom_navigation_bar.dart';
import '../../../shared/components/snack_bar.dart';
import '../../../utils/color_helpers.dart';
import '../../../utils/string_helpers.dart';
import '../../product/presentation/product_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final rebuildBasketStateProvider = StateProvider<double>((ref) {
  return 0;
});

class BasketPage extends ConsumerStatefulWidget {
  const BasketPage({super.key});

  @override
  ConsumerState<BasketPage> createState() => _BasketPageState();
}

class _BasketPageState extends ConsumerState<BasketPage> with TickerProviderStateMixin {
  late Future<BasketViewDto?> basket;
  late AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..addListener(() {
        setState(() {});
      });
    animationController.repeat(reverse: false);

    super.initState();
    basket = BasketApi.getAsync();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // var temp = ref.watch(rebuildBasketStateProvider);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        leading: const BackButton(
          color: Colors.black,
        ),
        title: Text(
          AppLocalizations.of(context).shoppingCart,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        shape: Border(
            bottom: BorderSide(
          color: HexColor.borderPrimaryColor,
          width: 0.2,
        )),
      ),
      bottomNavigationBar: bottomNavigationBar(context, pageIndex: 1),
      body: Center(
        child: FutureBuilder(
          future: basket,
          builder: (context, snapshot) {
            if (!snapshot.hasData && snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.data == null && snapshot.connectionState == ConnectionState.done) {
              return Container(
                padding: const EdgeInsets.only(top: 100),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          color: HexColor.textPrimaryColor,
                          size: 100,
                        ),
                        Positioned(
                          top: 25,
                          child: Icon(
                            Icons.emoji_emotions_outlined,
                            color: HexColor.textPrimaryColor,
                            size: 22,
                          ),
                        )
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        AppLocalizations.of(context).shoppingCartIsEmpty,
                        style: TextStyle(fontSize: 20, color: HexColor.textPrimaryColor),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return const HomePage(title: "");
                          },
                        ));
                      },
                      child: Text(
                        AppLocalizations.of(context).startShoppingNow,
                      ),
                    )
                  ],
                ),
              );
            } else {
              return buildBasket(snapshot);
            }
          },
        ),
      ),
    );
  }

  Widget buildBasket(AsyncSnapshot snapshot) {
    return ListView(
      children: [
        snapshot.connectionState != ConnectionState.done
            ? LinearProgressIndicator(
                value: animationController.value,
                semanticsLabel: 'Linear progress indicator',
              )
            : const SizedBox(
                height: 0,
              ),
        SizedBox(
          height: MediaQuery.of(context).size.height - 220,
          child: ListView(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            children: List.generate(snapshot.data.basketVendors.length, (index) {
              return buildBasketVendorCard(snapshot.data.basketVendors[index]);
            }),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 15),
          decoration: const BoxDecoration(color: Colors.white),
          child: ListTile(
            leading: ElevatedButton(
              onPressed: () async => await launchUrl(Uri.parse(
                  '${ApiConfigurations.WhatsAppBaseUrl}${AppLocalizations.of(context).whatsAppOrderMessage} ${ApiConfigurations.WebsiteBaseUrl}/ar/Basket/${snapshot.data.id}')),
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), side: BorderSide(color: HexColor.yellowColor))),
                  backgroundColor: MaterialStateProperty.all(Color(toIntegerColor(HexColor.yellowColor)))),
              child: Text(
                AppLocalizations.of(context).placeOrder,
                style: TextStyle(color: HexColor.cardTextPrimaryColor, fontSize: 18),
              ),
            ),
            trailing: Text(
              snapshot.data.total.toString().toPriceStr(snapshot.data.currency),
              style: TextStyle(color: HexColor.primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        )
      ],
    );
  }

  Container buildBasketVendorCard(BasketVendorViewDto basketVendor) {
    return Container(
      margin: const EdgeInsets.only(top: 25),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              border: border(),
              boxShadow: borderShadow,
            ),
            child: Column(
              children: [
                storeName(basketVendor),
                storeDeliveryInfo(basketVendor),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(basketVendor.basketItems.length, (index) {
                    bool isLastItem = basketVendor.basketItems.length - 1 == index;
                    return buildBasketItem(basketVendor.basketItems[index], isLastItem);
                  }),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget storeName(BasketVendorViewDto basketVendor) {
    return GestureDetector(
      onTap: () => {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchPage(query: "", vendorId: basketVendor.vendorId),
            )),
      },
      child: Row(
        children: [
          Text(basketVendor.storeName),
          const SizedBox(
            width: 15,
          ),
          Icon(
            Icons.arrow_back_ios_new,
            color: HexColor.primaryColor,
            size: 18,
          )
        ],
      ),
    );
  }

  Widget storeDeliveryInfo(BasketVendorViewDto basketVendor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(5),
      width: MediaQuery.of(context).size.width - 50,
      decoration: BoxDecoration(
          color: HexColor.bodyBackgroundPrimaryColor,
          border: border(),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Center(
        child: Text(
            "${AppLocalizations.of(context).deliveryFees}: ${basketVendor.delivery.toString().toPriceStr(basketVendor.basketItems[0].currency)}",
            style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget buildBasketItem(BasketItemViewDto basketItem, bool isLastItem) {
    return Container(
      padding: EdgeInsets.only(bottom: !isLastItem ? 15 : 0),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(border: !isLastItem ? borderBottom : null),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          itemThumbnail(basketItem),
          Expanded(
              child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [itemTitle(basketItem), deleteItemBtn(basketItem.id)],
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  itemPrice(basketItem),
                  const SizedBox(
                    width: 15,
                  ),
                  updateQuantityBtn(basketItem.id, basketItem.quantity),
                ],
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget itemThumbnail(BasketItemViewDto basketItem) {
    return GestureDetector(
      onTap: () => {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(id: basketItem.productId),
            )),
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        width: 60,
        child: FadeInImage.assetNetwork(
            placeholder: AppConfigurations.productPlaceHolderImage,
            image: "${ApiConfigurations.ImagesBaseUrl}${basketItem.productImageUrl}",
            fit: BoxFit.contain),
      ),
    );
  }

  Widget itemTitle(BasketItemViewDto basketItem) {
    return GestureDetector(
      onTap: () => {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductPage(id: basketItem.productId),
            )),
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 150,
        child: Text(
          basketItem.productTitle,
          maxLines: 2,
          overflow: TextOverflow.clip,
          style: TextStyle(color: HexColor.cardTextPrimaryColor, fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget deleteItemBtn(String itemId) {
    return GestureDetector(
      onTap: () => {
        basket = BasketApi.deleteItemAsync(itemId),
      },
      child: Icon(
        Icons.delete,
        color: HexColor.cardTextPrimaryColor,
      ),
    );
  }

  Widget itemPrice(BasketItemViewDto basketItem) {
    return SizedBox(
      width: 110,
      child: Text(
        basketItem.total.toString().toPriceStr(basketItem.currency),
        style: TextStyle(color: HexColor.primaryColor, fontSize: 14, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget updateQuantityBtn(String itemId, double quantity) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(border: border(), borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: [
          GestureDetector(
              onTap: () => {
                    quantity = ++quantity,
                    basket = BasketApi.updateQuantityAsync(itemId, quantity),
                    ref.read(rebuildBasketStateProvider.notifier).state = quantity
                  },
              child: Container(
                decoration: BoxDecoration(color: HexColor.bodyBackgroundPrimaryColor, shape: BoxShape.circle),
                child: const Icon(
                  Icons.add,
                  size: 26,
                ),
              )),
          SizedBox(
            width: 35,
            child: Center(
              child: Text(
                quantity.toString().toFixedPrice(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: HexColor.primaryColor),
              ),
            ),
          ),
          GestureDetector(
              onTap: () => {
                    quantity = --quantity,
                    if (quantity == 0)
                      CustomSnackBar.dangerAlert(context, AppLocalizations.of(context).theLowestBasketItemQuantityMsg)
                    else
                      {
                        basket = BasketApi.updateQuantityAsync(itemId, quantity),
                        ref.read(rebuildBasketStateProvider.notifier).state = quantity
                      },
                  },
              child: Container(
                decoration: BoxDecoration(color: HexColor.bodyBackgroundPrimaryColor, shape: BoxShape.circle),
                child: const Icon(
                  Icons.remove,
                  size: 26,
                ),
              ))
        ],
      ),
    );
  }
}
