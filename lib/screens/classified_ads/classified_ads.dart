import 'package:active_ecommerce_flutter/custom/lang_text.dart';
import 'package:active_ecommerce_flutter/custom/useful_elements.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/helpers/string_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/ui_elements/classified_product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../repositories/classified_product_repository.dart';

class ClassifiedAds extends StatefulWidget {
  ClassifiedAds({
    Key? key,
  }) : super(key: key);

  @override
  _ClassifiedAdsState createState() => _ClassifiedAdsState();
}

class _ClassifiedAdsState extends State<ClassifiedAds> {
  ScrollController _mainScrollController = ScrollController();

  //init
  bool _dataFetch = false;
  dynamic _classifiedProducts = [];
  int page = 1;

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
    _classifiedProducts.clear();
    setState(() {});
  }

  fetchData() async {
    var classifiedProductRes =
        await ClassifiedProductRepository().getClassifiedProducts(page: page);

    _classifiedProducts.addAll(classifiedProductRes.data);
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

  bool? shouldProductBoxBeVisible(product_name, search_key) {
    if (search_key == "") {
      return true; //do not check if the search key is empty
    }
    return StringHelper().stringContains(product_name, search_key);
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: false,
      leading: UsefulElements.backButton(context),
      title: Text(
        AppLocalizations.of(context)!.classified_ads_ucf,
        style: TextStyle(
            fontSize: 16,
            color: MyTheme.dark_font_grey,
            fontWeight: FontWeight.bold),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  Widget body() {
    if (!_dataFetch) {
      return ShimmerHelper()
          .buildProductGridShimmer(scontroller: _mainScrollController);
    }

    if (_classifiedProducts.length == 0) {
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
          itemCount: _classifiedProducts.length,
          shrinkWrap: true,
          padding: EdgeInsets.only(top: 10.0, bottom: 10, left: 18, right: 18),
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            // 3
            return ClassifiedAdsCard(
              id: _classifiedProducts[index].id,
              slug: _classifiedProducts[index].slug,
              image: _classifiedProducts[index].thumbnailImage,
              name: _classifiedProducts[index].name,
              unit_price: _classifiedProducts[index].unitPrice,
              condition: _classifiedProducts[index].condition,
            );
          },
        ),
      ),
    );
  }
}
