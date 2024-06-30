import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:toast/toast.dart';

import '../../custom/lang_text.dart';
import '../../custom/toast_component.dart';
import '../../data_model/product_mini_response.dart';
import '../../helpers/shared_value_helper.dart';
import '../../helpers/shimmer_helper.dart';
import '../../my_theme.dart';
import '../../repositories/coupon_repository.dart';
import '../../ui_elements/product_card.dart';

class CouponProducts extends StatefulWidget {
  final String? code;
  final int? id;

  const CouponProducts({
    Key? key,
    this.code,
    this.id,
  }) : super(key: key);

  @override
  State<CouponProducts> createState() => _CouponProductsState();
}

class _CouponProductsState extends State<CouponProducts> {
  ScrollController? _scrollController;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context, widget.code),
        body: buildCouponProductList(context),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context, code) {
    return AppBar(
      backgroundColor: Colors.white,
      // centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.dark_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(right: 18.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              code,
              style: TextStyle(
                  fontSize: 16,
                  color: MyTheme.dark_font_grey,
                  fontWeight: FontWeight.bold),
            ),
            // code copy
            IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code)).then((_) {
                  ToastComponent.showDialog(LangText(context).local.copied_ucf,
                      gravity: Toast.center, duration: 1);
                });
              },
              icon: Icon(
                color: Colors.black,
                Icons.copy,
                size: 18.0,
              ),
            )
          ],
        ),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  buildCouponProductList(context) {
    return FutureBuilder(
        future: CouponRepository().getCouponProductList(id: widget.id),
        builder: (context, AsyncSnapshot<ProductMiniResponse> snapshot) {
          if (snapshot.hasError) {
            return Container();
          } else if (snapshot.hasData) {
            var productResponse = snapshot.data;
            return SingleChildScrollView(
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                itemCount: productResponse!.products!.length,
                shrinkWrap: true,
                padding:
                    EdgeInsets.only(top: 20.0, bottom: 10, left: 18, right: 18),
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  // 3
                  return ProductCard(
                    id: productResponse.products![index].id,
                    slug: productResponse.products![index].slug!,
                    image: productResponse.products![index].thumbnail_image,
                    name: productResponse.products![index].name,
                    main_price: productResponse.products![index].main_price,
                    stroked_price:
                        productResponse.products![index].stroked_price,
                    has_discount: productResponse.products![index].has_discount,
                    discount: productResponse.products![index].discount,
                    is_wholesale: productResponse.products![index].isWholesale,
                  );
                },
              ),
            );
          } else {
            return ShimmerHelper()
                .buildProductGridShimmer(scontroller: _scrollController);
          }
        });
  }
}
