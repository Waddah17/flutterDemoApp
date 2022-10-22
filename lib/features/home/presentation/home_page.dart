import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:uni_links/uni_links.dart';
import 'package:thevendor/features/product/presentation/product_page.dart';
import 'package:thevendor/features/search/presentation/search_page.dart';
import '../../../shared/components/search_field.dart';
import '../../../shared/components/bottom_navigation_bar.dart';
import '../../../utils/color_helpers.dart';
import '../models/promotion.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

bool initialURILinkHandled = false;

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Promotion>> promotionsList;
  // late Future<UpdateInfo> updateInfo;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  Uri? initialURI;
  Uri? currentURI;
  Object? err;
  StreamSubscription? streamSubscription;

  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    initURIHandler();
    incomingLinkHandler();
    promotionsList = PromotionApi.getMainPromotions().then((value) {
      FlutterNativeSplash.remove();
      return value;
    });
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  Future<void> initURIHandler() async {
    if (!initialURILinkHandled) {
      initialURILinkHandled = true;
      try {
        final initialURITemp = await getInitialUri();
        if (initialURI != null) {
          debugPrint("Initial URI received $initialURITemp");
          if (!mounted) {
            return;
          }
          setState(() {
            initialURI = initialURITemp;
          });
        } else {
          debugPrint("Null Initial URI received");
        }
      } on PlatformException {
        debugPrint("Failed to receive initial uri");
      } on FormatException catch (error) {
        if (!mounted) {
          return;
        }
        debugPrint('Malformed Initial URI received');
        setState(() => err = error);
      }
    }
  }

  void incomingLinkHandler() {
    if (!kIsWeb) {
      streamSubscription = uriLinkStream.listen((Uri? uri) {
        if (!mounted) {
          return;
        }
        debugPrint('Received URI: $uri');
        setState(() {
          currentURI = uri;
          err = null;
        });
      }, onError: (Object error) {
        if (!mounted) {
          return;
        }
        debugPrint('Error occurred: $error');
        setState(() {
          currentURI = null;
          if (error is FormatException) {
            err = error;
          } else {
            err = null;
          }
        });
      });
    }
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    promotionsList = PromotionApi.getMainPromotions();
    if (mounted) {
      setState(() {});
    }
    if (kDebugMode) {
      print("refreshing");
    }
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    //promotionsList.add((promotionsList.length + 1).toString());
    promotionsList = PromotionApi.getMainPromotions();
    if (kDebugMode) {
      print("loading");
    }
    if (mounted) {
      setState(() {});
    }
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    final queryParams = currentURI?.queryParametersAll.entries.toList();

    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 68,
          leading: Container(
            padding: const EdgeInsets.only(right: 10.0, bottom: 2.5),
            child: const Image(image: AssetImage('assets/images/icon.png')),
          ),
          title: const AppBarSearch(query: ""),
          shape: Border(
              bottom: BorderSide(
            color: HexColor.borderPrimaryColor,
            width: 0.2,
          )),
        ),
        bottomNavigationBar: bottomNavigationBar(context),
        body: SmartRefresher(
          enablePullDown: true,
          enablePullUp: false,
          header: const ClassicHeader(
            refreshingText: "",
            completeText: "",
            releaseText: "",
            idleText: "",
            refreshStyle: RefreshStyle.Follow,
          ),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
            children: promotions(context),
          ),
        )

        );
  }

  promotions(BuildContext context) {
    return <Widget>[
      Container(
        padding: const EdgeInsets.fromLTRB(0, 30, 5, 10),
        child: Text(AppLocalizations.of(context).promotionsHeader, style: Theme.of(context).primaryTextTheme.headline6),
      ),
      FutureBuilder(
          future: promotionsList,
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData || snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            } else {
              //promotionsList = snapshot.data;
              return ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        child: GestureDetector(
                          onTap: () => {
                            snapshot.data[index].productId == null
                                ? Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SearchPage(
                                              query: snapshot.data[index].query ?? "",
                                              vendorId: snapshot.data[index].vendorId ?? "",
                                            )),
                                  )
                                : Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProductPage(
                                              id: snapshot.data[index].productId ?? "",
                                            )),
                                  )
                          },
                          child: Image.network(snapshot.data[index].imageUrl),
                        ));
                  });
            }
          })
    ];
  }
}
