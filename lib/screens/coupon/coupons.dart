import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/screens/seller_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:toast/toast.dart';

import '../../custom/lang_text.dart';
import '../../custom/my_separator.dart';
import '../../custom/toast_component.dart';
import '../../custom/useful_elements.dart';
import '../../helpers/main_helpers.dart';
import '../../helpers/shared_value_helper.dart';
import '../../helpers/shimmer_helper.dart';
import '../../my_theme.dart';
import '../../repositories/coupon_repository.dart';
import '../inhouse_products.dart';
import 'coupon_products.dart';

class Coupons extends StatefulWidget {
  const Coupons({Key? key}) : super(key: key);

  @override
  State<Coupons> createState() => _CouponsState();
}

class _CouponsState extends State<Coupons> {
  ScrollController _xcrollController = ScrollController();

  //init
  bool _dataFetch = false;
  List<dynamic> _couponsList = [];
  int _page = 1;
  int? _totalData = 0;
  bool _showLoadingContainer = false;

  _selectGradient(index) {
    if (index == 0 || (index + 1 > 3 && ((index + 1) % 3) == 1)) {
      return MyTheme.buildLinearGradient1();
    } else if (index == 1 || (index + 1 > 3 && ((index + 1) % 3) == 2)) {
      return MyTheme.buildLinearGradient2();
    } else if (index == 2 || (index + 1 > 3 && ((index + 1) % 3) == 0)) {
      return MyTheme.buildLinearGradient3();
    }
  }

  fetchData() async {
    var couponRes = await CouponRepository().getCouponResponseList(page: _page);
    _couponsList.addAll(couponRes.data!);
    _totalData = couponRes.meta!.total;
    _dataFetch = true;
    _showLoadingContainer = false;
    setState(() {});
  }

  reset() {
    _dataFetch = false;
    _couponsList.clear();
    _totalData = 0;
    _page = 1;
    _showLoadingContainer = false;
    setState(() {});
  }

  Future<void> _onPageRefresh() async {
    reset();
    fetchData();
  }

  @override
  void initState() {
    fetchData();
    _xcrollController.addListener(() {
      if (_xcrollController.position.pixels ==
          _xcrollController.position.maxScrollExtent) {
        setState(() {
          _page++;
          _showLoadingContainer = true;
        });
        fetchData();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // _mainScrollController.dispose();
    _xcrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: Stack(
          children: [
            body(),
            Align(
                alignment: Alignment.bottomCenter,
                child: buildLoadingContainer())
          ],
        ),
      ),
    );
  }

  Container buildLoadingContainer() {
    return Container(
      height: _showLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(_totalData == _couponsList.length
            ? AppLocalizations.of(context)!.no_more_coupons_ucf
            : AppLocalizations.of(context)!.loading_coupons_ucf),
      ),
    );
  }

  Widget body() {
    if (!_dataFetch) {
      return ShimmerHelper().buildListShimmer();
    }

    if (_couponsList.length == 0) {
      return Center(
        child: Text(LangText(context).local.no_data_is_available),
      );
    }
    return RefreshIndicator(
      onRefresh: _onPageRefresh,
      child: SingleChildScrollView(
        controller: _xcrollController,
        physics: AlwaysScrollableScrollPhysics(),
        child: ListView.separated(
          itemCount: _couponsList.length,
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          physics: NeverScrollableScrollPhysics(),
          separatorBuilder: (BuildContext context, int index) => itemSpacer(),
          itemBuilder: (context, index) {
            return Stack(
              alignment: AlignmentDirectional.centerStart,
              children: [
                Material(
                  elevation: 8,
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(30.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: _selectGradient(index),
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(30.0),
                      ),
                    ),
                    padding: EdgeInsets.only(
                        left: 30, right: 30, top: 30, bottom: 20),
                    height: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_couponsList[index].shopName}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // print(_couponsList[index].userType);
                                    // print(_couponsList[index].shopId);

                                    if (_couponsList[index].userType ==
                                        'seller') {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return SellerDetails(
                                            slug: _couponsList[index].shopSlug);
                                      }));
                                    } else {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return InhouseProducts();
                                      }));
                                    }
                                  },
                                  child: Text(
                                    LangText(context).local.visit_store_ucf,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            itemSpacer(),
                            _couponsList[index].discountType == "percent"
                                ? Text(
                                    "${_couponsList[index].discount}% ${LangText(context).local.off}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : Text(
                                    "${convertPrice(_couponsList[index].discount.toString())} ${LangText(context).local.off}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ],
                        ),
                        itemSpacer(height: DeviceInfo(context).width! / 16),
                        MySeparator(color: Colors.white),
                        Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: _couponsList[index]
                                          .couponDiscountDetails !=
                                      null
                                  ? richText(context, index)
                                  : GestureDetector(
                                      onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return CouponProducts(
                                              code: _couponsList[index].code!,
                                              id: _couponsList[index].id!);
                                        }));
                                      },
                                      child: Text(
                                        LangText(context)
                                            .local
                                            .view_products_ucf,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                            ),
                            itemSpacer(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "${LangText(context).local.code}: ${_couponsList[index].code}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(
                                            text: _couponsList[index].code!))
                                        .then((_) {
                                      ToastComponent.showDialog(
                                          LangText(context).local.copied_ucf,
                                          gravity: Toast.center,
                                          duration: 1);
                                    });
                                  },
                                  icon: Icon(
                                    color: Colors.white,
                                    Icons.copy,
                                    size: 18.0,
                                  ),
                                )
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 40,
                      width: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topRight: const Radius.circular(30.0),
                          bottomRight: const Radius.circular(30.0),
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: const Radius.circular(30.0),
                          bottomLeft: const Radius.circular(30.0),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }

  RichText richText(BuildContext context, int index) {
    return RichText(
      text: TextSpan(
        text: '${LangText(context).local.min_spend_ucf} ',
        style: TextStyle(
          fontSize: 12,
        ),
        children: [
          TextSpan(
            text:
                '${convertPrice(_couponsList[index].couponDiscountDetails!.minBuy)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          TextSpan(
            text: ' ${LangText(context).local.from}',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          TextSpan(
            text: ' ${_couponsList[index].shopName}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          TextSpan(
            text: ' ${LangText(context).local.store_to_get}',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          TextSpan(
            text:
                ' ${_couponsList[index].discountType == "percent" ? _couponsList[index].discount.toString() + "%" : convertPrice(_couponsList[index].discount.toString())}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: ' ${LangText(context).local.off_on_total_orders}',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  itemSpacer({height = 15.0}) {
    return SizedBox(
      height: height,
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: false,
      leading: UsefulElements.backButton(context),
      title: Text(
        LangText(context).local.coupons_ucf,
        style: TextStyle(
            fontSize: 16,
            color: MyTheme.dark_font_grey,
            fontWeight: FontWeight.bold),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }
}
