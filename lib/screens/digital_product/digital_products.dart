import 'package:active_ecommerce_flutter/custom/lang_text.dart';
import 'package:active_ecommerce_flutter/custom/useful_elements.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/helpers/string_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/repositories/product_repository.dart';
import 'package:active_ecommerce_flutter/ui_elements/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class DigitalProducts extends StatefulWidget {
  DigitalProducts({
    Key? key,
  }) : super(key: key);

  @override
  _DigitalProductsState createState() => _DigitalProductsState();
}

class _DigitalProductsState extends State<DigitalProducts> {
  ScrollController _mainScrollController = ScrollController();
  ScrollController _xcrollController = ScrollController();

  //init
  bool _dataFetch = false;
  List<dynamic> _digitalProducts = [];
  int _page = 1;
  int? _totalData = 0;

  bool _showLoadingContainer = false;

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
    _mainScrollController.dispose();
    _xcrollController.dispose();
    super.dispose();
  }

  reset() {
    _dataFetch = false;
    _digitalProducts.clear();
    _totalData = 0;
    _page = 1;
    _showLoadingContainer = false;
    setState(() {});
  }

  fetchData() async {
    var digitalProductRes =
        await ProductRepository().getDigitalProducts(page: _page);

    _digitalProducts.addAll(digitalProductRes.products!);
    _totalData = digitalProductRes.meta!.total;
    _dataFetch = true;
    _showLoadingContainer = false;
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
          body: Stack(
            children: [
              body(),
              Align(
                alignment: Alignment.bottomCenter,
                child: buildLoadingContainer(),
              )
            ],
          )),
    );
  }

  Container buildLoadingContainer() {
    return Container(
      height: _showLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(_totalData == _digitalProducts.length
            ? AppLocalizations.of(context)!.no_more_products_ucf
            : AppLocalizations.of(context)!.loading_more_products_ucf),
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
        AppLocalizations.of(context)!.digital_product_ucf,
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

    if (_digitalProducts.length == 0) {
      return Center(
        child: Text(LangText(context).local.no_data_is_available),
      );
    }
    return RefreshIndicator(
      onRefresh: _onPageRefresh,
      child: SingleChildScrollView(
        controller: _xcrollController,
        physics: AlwaysScrollableScrollPhysics(),
        child: MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          itemCount: _digitalProducts.length,
          shrinkWrap: true,
          padding: EdgeInsets.only(top: 10.0, bottom: 10, left: 18, right: 18),
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            // 3
            return ProductCard(
              id: _digitalProducts[index].id,
              slug: _digitalProducts[index].slug,
              image: _digitalProducts[index].thumbnail_image,
              name: _digitalProducts[index].name,
              main_price: _digitalProducts[index].main_price,
              stroked_price: _digitalProducts[index].stroked_price,
              has_discount: _digitalProducts[index].has_discount,
              discount: _digitalProducts[index].discount,
            );
          },
        ),
      ),
    );
  }
}
