import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/custom/useful_elements.dart';
import 'package:active_ecommerce_flutter/data_model/currency_response.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/helpers/system_config.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/presenter/currency_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CurrencyChange extends StatefulWidget {
  CurrencyChange({Key? key}) : super(key: key);

  @override
  _CurrencyChangeState createState() => _CurrencyChangeState();
}

class _CurrencyChangeState extends State<CurrencyChange> {
  onchange(CurrencyInfo currencyInfo) {
    SystemConfig.systemCurrency = currencyInfo;
    system_currency.$ = currencyInfo.id;
    setState(() {});

    system_currency.save().then((value) {
      context.go("/");
    });
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
              RefreshIndicator(
                color: MyTheme.accent_color,
                backgroundColor: Colors.white,
                onRefresh: () {
                  return Provider.of<CurrencyPresenter>(context, listen: false)
                      .fetchListData();
                },
                displacement: 0,
                child: CustomScrollView(
                  //controller: _mainScrollController,
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate([
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: buildLanguageMethodList(),
                        ),
                      ]),
                    )
                  ],
                ),
              ),
            ],
          )),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: false,
      leading: Builder(
        builder: (context) => IconButton(
          padding: EdgeInsets.zero,
          icon: UsefulElements.backButton(context),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Text(
        "${AppLocalizations.of(context)!.currency_change_ucf}",
        style: TextStyle(
            fontSize: 16,
            color: MyTheme.dark_font_grey,
            fontWeight: FontWeight.bold),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  buildLanguageMethodList() {
    return Consumer<CurrencyPresenter>(
        builder: (context, currencyModel, child) {
      return SingleChildScrollView(
        child: ListView.separated(
          separatorBuilder: (context, index) {
            return SizedBox(
              height: 14,
              width: 10,
            );
          },
          itemCount: currencyModel.currencyList.length,
          scrollDirection: Axis.vertical,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          //padding: EdgeInsets.symmetric(horizontal: 80),

          itemBuilder: (context, index) {
            return buildPaymentMethodItemCard(
                currencyModel.currencyList[index]);
          },
        ),
      );
    });
  }

  Widget buildPaymentMethodItemCard(CurrencyInfo currencyInfo) {
    return GestureDetector(
      onTap: () {
        onchange(currencyInfo);
      },
      child: AnimatedContainer(
        decoration: BoxDecorations.buildBoxDecoration_1().copyWith(
            border: Border.all(
                color: currencyInfo.id == system_currency.$
                    ? MyTheme.accent_color
                    : MyTheme.noColor)),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        duration: Duration(milliseconds: 400),
        child: Row(
          children: [
            Text(
              "${currencyInfo.name} - ${currencyInfo.symbol}",
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                  color: MyTheme.font_grey,
                  fontSize: 16,
                  height: 1.6,
                  fontWeight: FontWeight.w400),
            ),
            Spacer(),
            if (currencyInfo.id == system_currency.$) buildCheckContainer(true)
          ],
        ),
      ),
    );
  }

  Container buildCheckContainer(bool check) {
    return check
        ? Container(
            height: 16,
            width: 16,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0), color: Colors.green),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Icon(Icons.check, color: Colors.white, size: 10),
            ),
          )
        : Container();
  }
}
