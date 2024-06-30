import 'package:active_ecommerce_flutter/repositories/product_repository.dart';
import 'package:active_ecommerce_flutter/ui_elements/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../custom/lang_text.dart';
import '../../custom/useful_elements.dart';
import '../../helpers/shared_value_helper.dart';
import '../../helpers/shimmer_helper.dart';
import '../../my_theme.dart';

class LastViewProduct extends StatefulWidget {
  const LastViewProduct({Key? key}) : super(key: key);

  @override
  State<LastViewProduct> createState() => _LastViewProductState();
}

class _LastViewProductState extends State<LastViewProduct> {
  //init
  bool _dataFetch = false;
  dynamic _lastViewProducts = [];
  ScrollController _mainScrollController = ScrollController();

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  reset() {
    _dataFetch = false;
    _lastViewProducts.clear();
    setState(() {});
  }

  fetchData() async {
    var lastViewProductResponse = await ProductRepository().lastViewProduct();

    _lastViewProducts.addAll(lastViewProductResponse.products);
    _dataFetch = true;
    setState(() {});
  }

  Future<void> _onPageRefresh() async {
    reset();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: body(),
      ),
    );
  }

  Widget body() {
    if (!_dataFetch) {
      return ShimmerHelper()
          .buildProductGridShimmer(scontroller: _mainScrollController);
    }

    if (_lastViewProducts.length == 0) {
      return Center(
        child: Text(LangText(context).local!.no_data_is_available),
      );
    }
    return RefreshIndicator(
      onRefresh: _onPageRefresh,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          itemCount: _lastViewProducts.length,
          shrinkWrap: true,
          padding: EdgeInsets.only(top: 10.0, bottom: 10, left: 18, right: 18),
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            // 3
            return ProductCard(
              id: _lastViewProducts[index].id,
              slug: _lastViewProducts[index].slug,
              image: _lastViewProducts[index].thumbnail_image,
              name: _lastViewProducts[index].name,
              main_price: _lastViewProducts[index].main_price,
              stroked_price: _lastViewProducts[index].stroked_price,
              has_discount: _lastViewProducts[index].has_discount,
              discount: _lastViewProducts[index].discount,
              is_wholesale: _lastViewProducts[index].isWholesale,
            );
          },
        ),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: false,
      leading: UsefulElements.backButton(context),
      title: Text(
        AppLocalizations.of(context)!.last_view_product_ucf,
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
