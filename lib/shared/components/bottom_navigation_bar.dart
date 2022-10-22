import 'package:flutter/material.dart';
import 'package:thevendor/features/Home/presentation/home_page.dart';
import 'package:thevendor/features/basket/models/basket.dart';
import 'package:thevendor/features/basket/presentation/basket_page.dart';
import 'package:thevendor/constants/configurations.dart';
import 'package:thevendor/utils/string_helpers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'counter_badge.dart';

bottomNavigationBar(BuildContext context, {int pageIndex = 2}) {
  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    selectedFontSize: 12,
    ///This allow more than 3 items
    backgroundColor: Colors.white,
    currentIndex: pageIndex,
    onTap: (index) => {
      if (index == 0)
        {
          {launchUrl(Uri.parse('${ApiConfigurations.WhatsAppBaseUrl}${AppLocalizations.of(context).whatsAppContactMessage}'))}
        }
      else if (index == 1)
        {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BasketPage(),
              ))
        }
      else if (index == 2)
          {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(title: ""),
                ))
          }
    },
    items: [
      BottomNavigationBarItem(
        icon: const Icon(
          Icons.whatsapp,
        ),
        label: AppLocalizations.of(context).contactUs,
      ),
      BottomNavigationBarItem(
        icon: Stack(
          alignment: Alignment.topRight,
          children: [
            const SizedBox(
              width: 39,
              child: Icon(Icons.shopping_cart),
            ),
            Positioned(
              bottom: 6,
              child: FutureBuilder(
                future: BasketApi.fetchBasketItemsCountAsync(),
                builder: (context, snapshot){
                  if(snapshot.hasData  && snapshot.data != 0) {
                    return counterBadge(snapshot.data.toString().toFixedPrice());
                  } else {
                    return const SizedBox(height: 0);
                  }},
              ),
            )
          ],
        ),
        label: AppLocalizations.of(context).shoppingCart,
      ),
      BottomNavigationBarItem(
        icon: const Icon(
          Icons.home,
        ),
        label: AppLocalizations.of(context).home,
      ),
    ],
  );
}
