import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/custom/lang_text.dart';
import 'package:active_ecommerce_flutter/custom/style.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/data_model/followed_sellers_response.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/repositories/shop_repository.dart';
import 'package:active_ecommerce_flutter/screens/seller_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class FollowedSellers extends StatefulWidget {
  const FollowedSellers({Key? key}) : super(key: key);

  @override
  State<FollowedSellers> createState() => _FollowedSellersState();
}

class _FollowedSellersState extends State<FollowedSellers> {
  List<SellerInfo> sellers = [];
  int page = 1;
  bool _isShopsInitial = false;
  bool _hasMoreData = true;

  ScrollController _scrollController = ScrollController();

  Future fetchShopData() async {
    var shopResponse = await ShopRepository().followedList(page: page);
    // print(shopResponse.data!.length);
    sellers.addAll(shopResponse.data!);
    _isShopsInitial = true;
    if (shopResponse.meta!.lastPage == page) {
      _hasMoreData = false;
    }
    setState(() {});
  }

  Future removedFollow(id) async {
    var shopResponse = await ShopRepository().followedRemove(id);

    if (shopResponse.result!) {
      reset();
    }
    ToastComponent.showDialog(shopResponse.message!);
  }

  clearData() {
    sellers = [];
    page = 1;
    _isShopsInitial = false;
    _hasMoreData = true;
    setState(() {});
  }

  Future reset() async {
    clearData();
    return fetchShopData();
  }

  @override
  void initState() {
    fetchShopData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!_hasMoreData) page++;
        // _showLoadingContainer = true;
        fetchShopData();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LangText(context).local!.followed_sellers_ucf,
          style: MyStyle.appBarStyle,
        ),
        backgroundColor: MyTheme.white,
        iconTheme: IconThemeData(color: MyTheme.dark_font_grey),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          //  clearData();
          return reset();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: bodyContainer(),
        ),
      ),
    );
  }

  Widget bodyContainer() {
    if (_isShopsInitial) {
      if (sellers.isNotEmpty)
        return GridView.builder(
          // 2
          //addAutomaticKeepAlives: true,
          itemCount: sellers.length,
          controller: _scrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.7),
          padding: EdgeInsets.only(top: 20, bottom: 10, left: 18, right: 18),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            // 3
            return shopModel(sellers[index]);
          },
        );
      else
        return Container(
          height: DeviceInfo(context).height,
          child: Center(
            child: Text(LangText(context).local!.no_data_is_available),
          ),
        );
    } else {
      return buildShimmer();
    }
  }

  Widget shopModel(SellerInfo sellerInfo) {
    return Container(
      decoration: BoxDecorations.buildBoxDecoration_1(),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return SellerDetails(
                    slug: sellerInfo.shopSlug ?? "",
                  );
                }));
              },
              child: Container(
                  width: double.infinity,
                  height: 100,
                  child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16), bottom: Radius.zero),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/placeholder.png',
                        image: sellerInfo.shopLogo!,
                        fit: BoxFit.scaleDown,
                        imageErrorBuilder: (BuildContext errorContext,
                            Object obj, StackTrace? st) {
                          return Image.asset('assets/placeholder.png');
                        },
                      ))),
            ),
            Container(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  sellerInfo.shopName!,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                      color: MyTheme.dark_font_grey,
                      fontSize: 13,
                      height: 1.6,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Container(
                height: 15,
                child: RatingBar(
                    ignoreGestures: true,
                    initialRating:
                        double.parse(sellerInfo.shopRating.toString()),
                    maxRating: 5,
                    direction: Axis.horizontal,
                    itemSize: 15.0,
                    itemCount: 5,
                    ratingWidget: RatingWidget(
                      full: Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      half: Icon(Icons.star_half),
                      empty: Icon(Icons.star,
                          color: Color.fromRGBO(224, 224, 225, 1)),
                    ),
                    onRatingUpdate: (newValue) {}),
              ),
            ),
            InkWell(
              onTap: () {
                removedFollow(sellerInfo.shopId);
              },
              child: Container(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    LangText(context).local!.unfollow_ucf,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                        color: Color.fromRGBO(230, 46, 4, 1),
                        fontSize: 13,
                        height: 1.6,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return SellerDetails(
                    slug: sellerInfo.shopSlug ?? "",
                  );
                }));
              },
              child: Container(
                  height: 23,
                  width: 103,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.amber),
                      color: MyTheme.amber,
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    "Visit Store",
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.amber.shade700,
                        fontWeight: FontWeight.w500),
                  )),
            )
          ]),
    );
  }

  Widget buildShimmer() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1,
        crossAxisCount: 3,
      ),
      itemCount: 18,
      padding: EdgeInsets.only(left: 18, right: 18),
      scrollDirection: Axis.vertical,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecorations.buildBoxDecoration_1(),
          child: ShimmerHelper().buildBasicShimmer(),
        );
      },
    );
  }
}
