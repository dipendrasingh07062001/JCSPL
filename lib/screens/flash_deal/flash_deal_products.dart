import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/custom/useful_elements.dart';
import 'package:active_ecommerce_flutter/data_model/flash_deal_response.dart';
import 'package:active_ecommerce_flutter/data_model/product_mini_response.dart'
    as productMini;
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/helpers/string_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/repositories/flash_deal_repository.dart';
import 'package:active_ecommerce_flutter/repositories/product_repository.dart';
import 'package:active_ecommerce_flutter/ui_elements/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class FlashDealProducts extends StatefulWidget {
  FlashDealProducts({
    Key? key,
    required this.slug,
    // this.flash_deal_name,
    // this.countdownTimerController,
    // this.bannerUrl
  }) : super(key: key);
  // final int? flash_deal_id;
  // final
  final String? slug;
  // final String? flash_deal_name;

  @override
  _FlashDealProductsState createState() => _FlashDealProductsState();
}

class _FlashDealProductsState extends State<FlashDealProducts> {
  TextEditingController _searchController = new TextEditingController();
  CountdownTimerController? countdownTimerController;
  Future<productMini.ProductMiniResponse>? _future;

  late List<productMini.Product> _searchList;
  late List<productMini.Product> _fullList;
  ScrollController? _scrollController;

  FlashDealResponseDatum? flashDealInfo;

  String timeText(String txt, {default_length = 3}) {
    var blank_zeros = default_length == 3 ? "000" : "00";
    var leading_zeros = "";
    if (txt != null) {
      if (default_length == 3 && txt.length == 1) {
        leading_zeros = "00";
      } else if (default_length == 3 && txt.length == 2) {
        leading_zeros = "0";
      } else if (default_length == 2 && txt.length == 1) {
        leading_zeros = "0";
      }
    }

    var newtxt = (txt == null || txt == "" || txt == null.toString())
        ? blank_zeros
        : txt;

    // print(txt + " " + default_length.toString());
    // print(newtxt);

    if (default_length > txt.length) {
      newtxt = leading_zeros + newtxt;
    }
    //print(newtxt);

    return newtxt;
  }

  getInfo() async {
    var res = await FlashDealRepository().getFlashDealInfo(widget.slug);
    print(res.toJson());
    if (res.flashDeals?.isNotEmpty ?? false) {
      flashDealInfo = res.flashDeals?.first;

      DateTime end =
          convertTimeStampToDateTime(flashDealInfo!.date!); // YYYY-mm-dd
      DateTime now = DateTime.now();
      int diff = end.difference(now).inMilliseconds;
      int endTime = diff + now.millisecondsSinceEpoch;

      void onEnd() {}

      countdownTimerController =
          CountdownTimerController(endTime: endTime, onEnd: onEnd);
    }
    setState(() {});
  }

  DateTime convertTimeStampToDateTime(int timeStamp) {
    var dateToTimeStamp = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
    return dateToTimeStamp;
  }

  @override
  void initState() {
    // TODO: implement initState
    getInfo();
    _future = ProductRepository().getFlashDealProducts(widget.slug);
    _searchList = [];
    _fullList = [];
    super.initState();
  }

  _buildSearchList(search_key) async {
    _searchList.clear();
    //print(_fullList.length);

    if (search_key.isEmpty) {
      _searchList.addAll(_fullList);
      setState(() {});
    } else {
      for (var i = 0; i < _fullList.length; i++) {
        if (StringHelper().stringContains(_fullList[i].name, search_key)!) {
          _searchList.add(_fullList[i]);
          setState(() {});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: buildProductList(context),
      ),
    );
  }

  bool? shouldProductBoxBeVisible(product_name, search_key) {
    if (search_key == "") {
      return true; //do not check if the search key is empty
    }
    return StringHelper().stringContains(product_name, search_key);
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      toolbarHeight: 75,
      leading: Builder(
        builder: (context) => IconButton(
          icon: UsefulElements.backButton(context),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Container(
        width: 250,
        child: TextField(
          controller: _searchController,
          onChanged: (txt) {
            print(txt);
            _buildSearchList(txt);
            // print(_searchList.toString());
            // print(_searchList.length);
          },
          onTap: () {},
          autofocus: true,
          decoration: InputDecoration(
              hintText:
                  "${AppLocalizations.of(context)!.search_products_from} : ",
              hintStyle:
                  TextStyle(fontSize: 14.0, color: MyTheme.textfield_grey),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: MyTheme.white, width: 0.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: MyTheme.white, width: 0.0),
              ),
              contentPadding: EdgeInsets.all(0.0)),
        ),
      ),
      elevation: 0.0,
      titleSpacing: 0,
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
          child: IconButton(
            icon: Icon(Icons.search, color: MyTheme.dark_grey),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  buildProductList(context) {
    return FutureBuilder(
        future: _future,
        builder:
            (context, AsyncSnapshot<productMini.ProductMiniResponse> snapshot) {
          if (snapshot.hasError) {
            return Container();
          } else if (snapshot.hasData) {
            var productResponse = snapshot.data;
            if (_fullList.length == 0) {
              _fullList.addAll(productResponse!.products!);
              _searchList.addAll(productResponse!.products!);
            }

            //print('called');

            return SingleChildScrollView(
              child: Column(
                children: [
                  buildFlashDealsBanner(context),
                  MasonryGridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    itemCount: _searchList.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(
                        top: 10.0, bottom: 10, left: 18, right: 18),
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      // 3
                      return ProductCard(
                        id: _searchList[index].id,
                        slug: _searchList[index].slug!,
                        image: _searchList[index].thumbnail_image,
                        name: _searchList[index].name,
                        main_price: _searchList[index].main_price,
                        stroked_price: _searchList[index].stroked_price,
                        has_discount: _searchList[index].has_discount,
                        discount: _searchList[index].discount,
                        is_wholesale: _searchList[index].isWholesale,
                      );
                    },
                  ),
                ],
              ),
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  headerShimmer(),
                  ShimmerHelper()
                      .buildProductGridShimmer(scontroller: _scrollController),
                ],
              ),
            );
          }
        });
  }

  Container buildFlashDealsBanner(BuildContext context) {
    return Container(
      //color: MyTheme.amber,
      height: 215,
      child: CountdownTimer(
        controller: countdownTimerController,
        widgetBuilder: (_, CurrentRemainingTime? time) {
          return Stack(
            children: [
              buildFlashDealBanner(),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: DeviceInfo(context).width,
                  margin: EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecorations.buildBoxDecoration_1(),
                  child: Column(
                    children: [
                      Container(
                        child: Center(
                            child: time == null
                                ? Text(
                                    AppLocalizations.of(context)!.ended_ucf,
                                    style: TextStyle(
                                        color: MyTheme.accent_color,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600),
                                  )
                                : buildTimerRowRow(time)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  headerShimmer() {
    return Container(
      // color: MyTheme.amber,
      height: 215,
      child: Stack(
        children: [
          buildFlashDealBannerShimmer(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: DeviceInfo(context).width,
              margin: EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecorations.buildBoxDecoration_1(),
              child: Container(
                child: buildTimerRowRowShimmer(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container buildFlashDealBanner() {
    return Container(
      child: FadeInImage.assetNetwork(
        placeholder: 'assets/placeholder_rectangle.png',
        image: flashDealInfo?.banner ?? "",
        fit: BoxFit.cover,
        width: DeviceInfo(context).width,
        height: 180,
      ),
    );
  }

  Widget buildFlashDealBannerShimmer() {
    return ShimmerHelper().buildBasicShimmerCustomRadius(
        width: DeviceInfo(context).width,
        height: 180,
        color: MyTheme.medium_grey_50);
  }

  Widget buildTimerRowRow(CurrentRemainingTime time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(
            Icons.watch_later_outlined,
            color: MyTheme.grey_153,
          ),
          SizedBox(
            width: 10,
          ),
          timerContainer(
            Text(
              timeText(time.days.toString(), default_length: 3),
              style: TextStyle(
                  color: MyTheme.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            width: 4,
          ),
          timerContainer(
            Text(
              timeText(time.hours.toString(), default_length: 2),
              style: TextStyle(
                  color: MyTheme.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            width: 4,
          ),
          timerContainer(
            Text(
              timeText(time.min.toString(), default_length: 2),
              style: TextStyle(
                  color: MyTheme.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            width: 4,
          ),
          timerContainer(
            Text(
              timeText(time.sec.toString(), default_length: 2),
              style: TextStyle(
                  color: MyTheme.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Image.asset(
            "assets/flash_deal.png",
            height: 20,
            color: MyTheme.golden,
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget buildTimerRowRowShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(
            Icons.watch_later_outlined,
            color: MyTheme.grey_153,
          ),
          SizedBox(
            width: 10,
          ),
          ShimmerHelper().buildBasicShimmerCustomRadius(
              height: 30,
              width: 30,
              radius: BorderRadius.circular(6),
              color: MyTheme.shimmer_base),
          SizedBox(
            width: 4,
          ),
          ShimmerHelper().buildBasicShimmerCustomRadius(
              height: 30,
              width: 30,
              radius: BorderRadius.circular(6),
              color: MyTheme.shimmer_base),
          SizedBox(
            width: 4,
          ),
          ShimmerHelper().buildBasicShimmerCustomRadius(
              height: 30,
              width: 30,
              radius: BorderRadius.circular(6),
              color: MyTheme.shimmer_base),
          SizedBox(
            width: 4,
          ),
          ShimmerHelper().buildBasicShimmerCustomRadius(
              height: 30,
              width: 30,
              radius: BorderRadius.circular(6),
              color: MyTheme.shimmer_base),
          SizedBox(
            width: 10,
          ),
          Image.asset(
            "assets/flash_deal.png",
            height: 20,
            color: MyTheme.golden,
          ),
          Spacer(),
        ],
      ),
    );
  }

  Widget timerContainer(Widget child) {
    return Container(
      constraints: BoxConstraints(minWidth: 30, minHeight: 24),
      child: child,
      alignment: Alignment.center,
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: MyTheme.accent_color,
      ),
    );
  }
}
