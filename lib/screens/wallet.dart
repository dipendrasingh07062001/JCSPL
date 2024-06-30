import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/custom/enum_classes.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/custom/useful_elements.dart';
import 'package:active_ecommerce_flutter/helpers/reg_ex_inpur_formatter.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/repositories/wallet_repository.dart';
import 'package:active_ecommerce_flutter/screens/checkout.dart';
import 'package:active_ecommerce_flutter/screens/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:toast/toast.dart';

import '../helpers/main_helpers.dart';

class Wallet extends StatefulWidget {
  Wallet({Key? key, this.from_recharge = false}) : super(key: key);
  final bool from_recharge;

  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  final _amountValidator = RegExInputFormatter.withRegex(
      '^\$|^(0|([1-9][0-9]{0,}))(\\.[0-9]{0,})?\$');
  ScrollController _mainScrollController = ScrollController();
  ScrollController _scrollController = ScrollController();
  TextEditingController _amountController = TextEditingController();

  GlobalKey appBarKey = GlobalKey();

  dynamic _balanceDetails = null;

  List<dynamic> _rechargeList = [];
  bool _rechargeListInit = true;
  int _rechargePage = 1;
  int? _totalRechargeData = 0;
  bool _showRechageLoadingContainer = false;

  @override
  void initState() {
    super.initState();
    fetchAll();
    _mainScrollController.addListener(() {
      if (_mainScrollController.position.pixels ==
          _mainScrollController.position.maxScrollExtent) {
        setState(() {
          _rechargePage++;
        });
        _showRechageLoadingContainer = true;
        fetchRechargeList();
      }
    });
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  fetchAll() {
    fetchBalanceDetails();
    fetchRechargeList();
  }

  fetchBalanceDetails() async {
    var balanceDetailsResponse = await WalletRepository().getBalance();

    _balanceDetails = balanceDetailsResponse;

    setState(() {});
  }

  fetchRechargeList() async {
    var rechageListResponse =
        await WalletRepository().getRechargeList(page: _rechargePage);

    if (rechageListResponse.result) {
      _rechargeList.addAll(rechageListResponse.recharges);
      _totalRechargeData = rechageListResponse.meta.total;
    } else {}
    _rechargeListInit = false;
    _showRechageLoadingContainer = false;

    setState(() {});
  }

  reset() {
    _balanceDetails = null;
    _rechargeList.clear();
    _rechargeListInit = true;
    _rechargePage = 1;
    _totalRechargeData = 0;
    _showRechageLoadingContainer = false;
    setState(() {});
  }

  Future<void> _onPageRefresh() async {
    reset();
    fetchAll();
  }

  onPressProceed() {
    var amount_String = _amountController.text.toString();

    if (amount_String == "") {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.amount_cannot_be_empty,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }

    var amount = double.parse(amount_String);

    Navigator.of(context, rootNavigator: true).pop();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Checkout(
        paymentFor: PaymentFor.WalletRecharge,
        rechargeAmount: amount,
        title: AppLocalizations.of(context)!.recharge_wallet_ucf,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (widget.from_recharge) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Main();
          }));
        } else {
          Navigator.of(context).pop();
        }
        return Future.delayed(Duration.zero);
      },
      child: Directionality(
        textDirection:
            app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: buildAppBar(context),
          body: RefreshIndicator(
            color: MyTheme.accent_color,
            backgroundColor: Colors.white,
            onRefresh: _onPageRefresh,
            displacement: 10,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 8.0, bottom: 0.0, left: 16.0, right: 16.0),
                    child: _balanceDetails != null
                        ? buildTopSection(context)
                        : ShimmerHelper().buildBasicShimmer(height: 150),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 100.0, bottom: 0.0),
                  child: buildRechargeList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container buildLoadingContainer() {
    return Container(
      height: _showRechageLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(_totalRechargeData == _rechargeList.length
            ? AppLocalizations.of(context)!.no_more_histories_ucf
            : AppLocalizations.of(context)!.loading_more_histories_ucf),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      key: appBarKey,
      backgroundColor: Colors.white,
      centerTitle: false,
      leading: Builder(
        builder: (context) => IconButton(
          icon: UsefulElements.backButton(context),
          onPressed: () {
            if (widget.from_recharge) {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Main();
              }));
            } else {
              return Navigator.of(context).pop();
            }
          },
        ),
      ),
      title: Text(
        AppLocalizations.of(context)!.my_wallet_ucf,
        style: TextStyle(
            fontSize: 16,
            color: MyTheme.dark_font_grey,
            fontWeight: FontWeight.bold),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  buildRechargeList() {
    if (_rechargeListInit && _rechargeList.length == 0) {
      return SingleChildScrollView(child: buildRechargeListShimmer());
    } else if (_rechargeList.length > 0) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(top: 16.0, bottom: 16.0, left: 16.0),
              child: Text(
                AppLocalizations.of(context)!.wallet_recharge_history_ucf,
                style: TextStyle(
                    color: MyTheme.dark_font_grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ),
            ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _rechargeList.length,
              scrollDirection: Axis.vertical,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: buildRechargeListItemCard(index),
                );
              },
            ),
          ],
        ),
      );
    } else if (_totalRechargeData == 0) {
      return Center(
          child: Text(AppLocalizations.of(context)!.no_recharges_yet));
    } else {
      return Container(); // should never be happening
    }
  }

  buildRechargeListShimmer() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ShimmerHelper().buildBasicShimmer(height: 75.0),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ShimmerHelper().buildBasicShimmer(height: 75.0),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ShimmerHelper().buildBasicShimmer(height: 75.0),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ShimmerHelper().buildBasicShimmer(height: 75.0),
        )
      ],
    );
  }

  Widget buildRechargeListItemCard(int index) {
    return Container(
      decoration: BoxDecorations.buildBoxDecoration_1(),
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: 50,
                child: Text(
                  getFormattedRechargeListIndex(index),
                  style: TextStyle(
                      color: MyTheme.dark_font_grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                )),
            Container(
                width: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _rechargeList[index].date,
                      style: TextStyle(
                        color: MyTheme.dark_font_grey,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      AppLocalizations.of(context)!.payment_method_ucf,
                      style: TextStyle(
                          color: MyTheme.dark_font_grey, fontSize: 12),
                    ),
                    Text(
                      _rechargeList[index].payment_method,
                      style: TextStyle(
                          color: MyTheme.dark_font_grey, fontSize: 12),
                    ),
                  ],
                )),
            Spacer(),
            Container(
              width: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    convertPrice(_rechargeList[index].amount),
                    style: TextStyle(
                        color: MyTheme.accent_color,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    _rechargeList[index].approval_string,
                    style: TextStyle(
                      color: MyTheme.dark_grey,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  getFormattedRechargeListIndex(int index) {
    int num = index + 1;
    var txt = num.toString().length == 1
        ? "# 0" + num.toString()
        : "#" + num.toString();
    return txt;
  }

  Widget buildTopSection(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: DeviceInfo(context).width! / 2.3,
          height: 90,
          decoration: BoxDecorations.buildBoxDecoration_1().copyWith(
            color: MyTheme.accent_color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: Text(
                  AppLocalizations.of(context)!.wallet_balance_ucf,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  convertPrice(_balanceDetails.balance),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "${AppLocalizations.of(context)!.last_recharged} : ${_balanceDetails.last_recharged}",
                  style: TextStyle(
                    color: MyTheme.light_grey,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: DeviceInfo(context).width! / 2.3,
          height: 90,
          decoration: BoxDecorations.buildBoxDecoration_1().copyWith(
            border: Border.all(color: Colors.amber.shade700, width: 1),
          ),
          child: Btn.basic(
            minWidth: MediaQuery.of(context).size.width,
            color: MyTheme.amber,
            shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(5.0))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${AppLocalizations.of(context)!.recharge_wallet_ucf}",
                  style: TextStyle(
                      color: MyTheme.font_grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 14,
                ),
                Image.asset(
                  "assets/add.png",
                  height: 20,
                  width: 20,
                ),
              ],
            ),
            onPressed: () {
              buildShowAddFormDialog(context);
            },
          ),
        ),
      ],
    );
  }

  Future buildShowAddFormDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection:
            app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 10),
          contentPadding:
              EdgeInsets.only(top: 36.0, left: 36.0, right: 36.0, bottom: 2.0),
          content: Container(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(AppLocalizations.of(context)!.amount_ucf,
                        style: TextStyle(
                            color: MyTheme.dark_font_grey,
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                      height: 40,
                      child: TextField(
                        controller: _amountController,
                        autofocus: false,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [_amountValidator],
                        decoration: InputDecoration(
                            fillColor: MyTheme.light_grey,
                            filled: true,
                            hintText:
                                AppLocalizations.of(context)!.enter_amount_ucf,
                            hintStyle: TextStyle(
                                fontSize: 12.0, color: MyTheme.textfield_grey),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: MyTheme.noColor, width: 0.0),
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(8.0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: MyTheme.noColor, width: 0.0),
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(8.0),
                              ),
                            ),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 8.0)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Btn.minWidthFixHeight(
                    minWidth: 75,
                    height: 30,
                    color: Color.fromRGBO(253, 253, 253, 1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        side: BorderSide(
                            color: MyTheme.accent_color, width: 1.0)),
                    child: Text(
                      AppLocalizations.of(context)!.close_ucf,
                      style: TextStyle(
                        fontSize: 10,
                        color: MyTheme.accent_color,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                  ),
                ),
                SizedBox(
                  width: 1,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Btn.minWidthFixHeight(
                    minWidth: 75,
                    height: 30,
                    color: MyTheme.accent_color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.proceed_ucf,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.normal),
                    ),
                    onPressed: () {
                      onPressProceed();
                    },
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
