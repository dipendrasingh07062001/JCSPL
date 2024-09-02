import 'dart:async';

import 'package:active_ecommerce_flutter/custom/box_decorations.dart';
import 'package:active_ecommerce_flutter/custom/btn.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:active_ecommerce_flutter/custom/text_styles.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/repositories/chat_repository.dart';
import 'package:active_ecommerce_flutter/screens/brand_products.dart';
import 'package:active_ecommerce_flutter/screens/cart.dart';
import 'package:active_ecommerce_flutter/screens/chat/chat.dart';
import 'package:active_ecommerce_flutter/screens/common_webview_screen.dart';
import 'package:active_ecommerce_flutter/screens/auth/login.dart';
import 'package:active_ecommerce_flutter/screens/seller_details.dart';
import 'package:active_ecommerce_flutter/screens/video_description_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_countdown_timer/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:photo_view/photo_view.dart';
import 'package:social_share/social_share.dart';
import 'package:toast/toast.dart';

import '../../app_config.dart';
import '../../custom/lang_text.dart';
import '../../helpers/main_helpers.dart';
import '../../repositories/auction_products_repository.dart';

class AuctionProductsDetails extends StatefulWidget {
  String slug;

  AuctionProductsDetails({Key? key, required this.slug}) : super(key: key);

  @override
  _AuctionProductsDetailsState createState() => _AuctionProductsDetailsState();
}

class _AuctionProductsDetailsState extends State<AuctionProductsDetails>
    with TickerProviderStateMixin {
  bool _showCopied = false;
  String _appbarPriceString = ". . .";
  int _currentImage = 0;
  ScrollController _mainScrollController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController _colorScrollController = ScrollController();
  ScrollController _variantScrollController = ScrollController();
  ScrollController _imageScrollController = ScrollController();
  TextEditingController sellerChatTitleController = TextEditingController();
  TextEditingController sellerChatMessageController = TextEditingController();
  TextEditingController _bidPriceController = TextEditingController();

  CountdownTimerController? countDownTimercontroller;

  double _scrollPosition = 0.0;

  Animation? _colorTween;
  late AnimationController _ColorAnimationController;

  CarouselSliderController _carouselController = CarouselSliderController();
  late BuildContext loadingcontext;

  //init values
  final _formKey = GlobalKey<FormState>();

  var _productDetailsFetched = false;
  dynamic _auctionproductDetails = null;
  var _productImageList = [];
  var _selectedChoices = [];
  var _variant = "";
  int _quantity = 1;

  double opacity = 0;

  @override
  void initState() {
    _ColorAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 0));

    _colorTween = ColorTween(begin: Colors.transparent, end: Colors.white)
        .animate(_ColorAnimationController);

    _mainScrollController.addListener(() {
      _scrollPosition = _mainScrollController.position.pixels;

      if (_mainScrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (100 > _scrollPosition && _scrollPosition > 1) {
          opacity = _scrollPosition / 100;
        }
      }

      if (_mainScrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (100 > _scrollPosition && _scrollPosition > 1) {
          opacity = _scrollPosition / 100;

          if (100 > _scrollPosition) {
            opacity = 1;
          }
        }
      }
      print("opachity{} $_scrollPosition");

      setState(() {});
    });
    fetchAll();
    super.initState();
  }

  // @override
  // void dispose() {
  //   _mainScrollController.dispose();
  //   _variantScrollController.dispose();
  //   _imageScrollController.dispose();
  //   _colorScrollController.dispose();
  //   // countDownTimercontroller.dispose();
  //   _bidPriceController.dispose();
  //   super.dispose();
  // }

  onPressBidPlace() async {
    var bidPlacedResponse = await AuctionProductsRepository().placeBidResponse(
        _auctionproductDetails.id.toString(), _bidPriceController.text);

    if (bidPlacedResponse.result == true) {
      ToastComponent.showDialog(bidPlacedResponse.message!,
          gravity: Toast.center, duration: Toast.lengthLong);

      fetchAll();
    }
  }

  fetchAll() {
    fetchAuctionProductDetails();
  }

  fetchAuctionProductDetails() async {
    var auctionproductDetailsResponse = await AuctionProductsRepository()
        .getAuctionProductsDetails(widget.slug);

    if (auctionproductDetailsResponse.auction_product!.length > 0) {
      _auctionproductDetails =
          auctionproductDetailsResponse.auction_product![0];
      sellerChatTitleController.text =
          auctionproductDetailsResponse.auction_product![0].name!;
    }

    setProductDetailValues();

    setState(() {});
  }

  setProductDetailValues() {
    if (_auctionproductDetails != null) {
      _auctionproductDetails.photos.forEach((photo) {
        _productImageList.add(photo.path);
      });
      _productDetailsFetched = true;

      setState(() {});
    }
  }

  reset() {
    restProductDetailValues();
    _currentImage = 0;
    _productImageList.clear();
    _productDetailsFetched = false;
    sellerChatTitleController.clear();
    setState(() {});
  }

  restProductDetailValues() {
    _appbarPriceString = " . . .";
    _auctionproductDetails = null;
    _productImageList.clear();
    _currentImage = 0;
    setState(() {});
  }

  Future<void> _onPageRefresh() async {
    reset();
    fetchAll();
  }

  onPopped(value) async {
    reset();
    fetchAll();
  }

  onCopyTap(setState) {
    setState(() {
      _showCopied = true;
    });
    Timer timer = Timer(Duration(seconds: 3), () {
      setState(() {
        _showCopied = false;
      });
    });
  }

  onPressShare(context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 10),
              contentPadding: EdgeInsets.only(
                  top: 36.0, left: 36.0, right: 36.0, bottom: 2.0),
              content: Container(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Btn.minWidthFixHeight(
                          minWidth: 75,
                          height: 26,
                          color: Color.fromRGBO(253, 253, 253, 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side:
                                  BorderSide(color: Colors.black, width: 1.0)),
                          child: Text(
                            AppLocalizations.of(context)!.copy_product_link_ucf,
                            style: TextStyle(
                              color: MyTheme.medium_grey,
                            ),
                          ),
                          onPressed: () {
                            onCopyTap(setState);
                            SocialShare.copyToClipboard(
                                text: _auctionproductDetails.link);
                          },
                        ),
                      ),
                      _showCopied
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                AppLocalizations.of(context)!.copied_ucf,
                                style: TextStyle(
                                    color: MyTheme.medium_grey, fontSize: 12),
                              ),
                            )
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Btn.minWidthFixHeight(
                          minWidth: 75,
                          height: 26,
                          color: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side:
                                  BorderSide(color: Colors.black, width: 1.0)),
                          child: Text(
                            AppLocalizations.of(context)!.share_options_ucf,
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            // print("share links ${_auctionproductDetails.link}");
                            SocialShare.shareOptions(
                                _auctionproductDetails.link);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: app_language_rtl.$!
                          ? EdgeInsets.only(left: 8.0)
                          : EdgeInsets.only(right: 8.0),
                      child: Btn.minWidthFixHeight(
                        minWidth: 75,
                        height: 30,
                        color: Color.fromRGBO(253, 253, 253, 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide(
                                color: MyTheme.font_grey, width: 1.0)),
                        child: Text(
                          LangText(context).local.close_all_capital,
                          style: TextStyle(
                            color: MyTheme.font_grey,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                      ),
                    ),
                  ],
                )
              ],
            );
          });
        });
  }

  onTapSellerChat() {
    return showDialog(
        context: context,
        builder: (_) => Directionality(
              textDirection:
                  app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
              child: AlertDialog(
                insetPadding: EdgeInsets.symmetric(horizontal: 10),
                contentPadding: EdgeInsets.only(
                    top: 36.0, left: 36.0, right: 36.0, bottom: 2.0),
                content: Container(
                  width: 400,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(AppLocalizations.of(context)!.title_ucf,
                              style: TextStyle(
                                  color: MyTheme.font_grey, fontSize: 12)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Container(
                            height: 40,
                            child: TextField(
                              controller: sellerChatTitleController,
                              autofocus: false,
                              decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!
                                      .enter_title_ucf,
                                  hintStyle: TextStyle(
                                      fontSize: 12.0,
                                      color: MyTheme.textfield_grey),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: MyTheme.textfield_grey,
                                        width: 0.5),
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(8.0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: MyTheme.textfield_grey,
                                        width: 1.0),
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(8.0),
                                    ),
                                  ),
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 8.0)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                              "${AppLocalizations.of(context)!.message_ucf} *",
                              style: TextStyle(
                                  color: MyTheme.font_grey, fontSize: 12)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Container(
                            height: 55,
                            child: TextField(
                              controller: sellerChatMessageController,
                              autofocus: false,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!
                                      .enter_message_ucf,
                                  hintStyle: TextStyle(
                                      fontSize: 12.0,
                                      color: MyTheme.textfield_grey),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: MyTheme.textfield_grey,
                                        width: 0.5),
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(8.0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: MyTheme.textfield_grey,
                                        width: 1.0),
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(8.0),
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.only(
                                      right: 16.0,
                                      left: 8.0,
                                      top: 16.0,
                                      bottom: 16.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Btn.minWidthFixHeight(
                          minWidth: 75,
                          height: 30,
                          color: Color.fromRGBO(253, 253, 253, 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              side: BorderSide(
                                  color: MyTheme.light_grey, width: 1.0)),
                          child: Text(
                            AppLocalizations.of(context)!.close_all_capital,
                            style: TextStyle(
                              color: MyTheme.font_grey,
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
                              borderRadius: BorderRadius.circular(8.0),
                              side: BorderSide(
                                  color: MyTheme.light_grey, width: 1.0)),
                          child: Text(
                            AppLocalizations.of(context)!.send_all_capital,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                            onPressSendMessage();
                          },
                        ),
                      )
                    ],
                  )
                ],
              ),
            ));
  }

  loading() {
    showDialog(
        context: context,
        builder: (context) {
          loadingcontext = context;
          return AlertDialog(
              content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(
                width: 10,
              ),
              Text("${AppLocalizations.of(context)!.please_wait_ucf}"),
            ],
          ));
        });
  }

  showLoginWarning() {
    return ToastComponent.showDialog(
        AppLocalizations.of(context)!.you_need_to_log_in,
        gravity: Toast.center,
        duration: Toast.lengthLong);
  }

  onPressSendMessage() async {
    if (!is_logged_in.$) {
      showLoginWarning();
      return;
    }
    loading();
    var title = sellerChatTitleController.text.toString();
    var message = sellerChatMessageController.text.toString();

    if (title == "" || message == "") {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.title_or_message_empty_warning,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }

    var conversationCreateResponse = await ChatRepository()
        .getCreateConversationResponse(
            product_id: _auctionproductDetails.id,
            title: title,
            message: message);

    Navigator.of(loadingcontext).pop();

    if (conversationCreateResponse.result == false) {
      ToastComponent.showDialog(
          AppLocalizations.of(context)!.could_not_create_conversation,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }

    sellerChatTitleController.clear();
    sellerChatMessageController.clear();
    setState(() {});

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Chat(
        conversation_id: conversationCreateResponse.conversation_id,
        messenger_name: conversationCreateResponse.shop_name,
        messenger_title: conversationCreateResponse.title,
        messenger_image: conversationCreateResponse.shop_logo,
      );
    })).then((value) {
      onPopped(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    SnackBar _addedToCartSnackbar = SnackBar(
      content: Text(
        AppLocalizations.of(context)!.added_to_cart,
        style: TextStyle(color: MyTheme.font_grey),
      ),
      backgroundColor: MyTheme.soft_accent_color,
      duration: const Duration(seconds: 3),
      action: SnackBarAction(
        label: AppLocalizations.of(context)!.show_cart_all_capital,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Cart(has_bottomnav: false);
          })).then((value) {
            onPopped(value);
          });
        },
        textColor: MyTheme.accent_color,
        disabledTextColor: Colors.grey,
      ),
    );

    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
          extendBody: true,
          // bottomNavigationBar: buildBottomAppBar(context, _addedToCartSnackbar),
          bottomNavigationBar: _auctionproductDetails != null
              ? Container(
                  padding:
                      EdgeInsets.only(left: 18, right: 18, bottom: 10, top: 10),
                  color: MyTheme.white.withOpacity(0.9),
                  child: InkWell(
                    onTap: () {
                      is_logged_in.$
                          ? showAlertDialog(context)
                          : Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Login()));
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        left: 0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.0),
                        color: MyTheme.accent_color,
                        boxShadow: [
                          BoxShadow(
                            color: MyTheme.accent_color_shadow,
                            blurRadius: 20,
                            spreadRadius: 0.0,
                            offset: Offset(
                                0.0, 10.0), // shadow direction: bottom right
                          )
                        ],
                      ),
                      height: 50,
                      child: Center(
                        child: Text(
                          (_auctionproductDetails.highestBid == '' ||
                                  _auctionproductDetails.highestBid == null)
                              ? AppLocalizations.of(context)!.place_bid_ucf
                              : AppLocalizations.of(context)!.change_bid_ucf,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ))
              : ShimmerHelper().buildBasicShimmer(height: 30.0, width: 60),
          body: RefreshIndicator(
            color: MyTheme.accent_color,
            backgroundColor: Colors.white,
            onRefresh: _onPageRefresh,
            child: CustomScrollView(
              controller: _mainScrollController,
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              slivers: <Widget>[
                SliverAppBar(
                  elevation: 0,
                  backgroundColor: Colors.white.withOpacity(opacity),
                  pinned: true,
                  automaticallyImplyLeading: false,
                  //titleSpacing: 0,
                  title: Row(
                    children: [
                      Builder(
                        builder: (context) => InkWell(
                          onTap: () {
                            return Navigator.of(context).pop();
                          },
                          child: Container(
                            decoration: BoxDecorations
                                .buildCircularButtonDecoration_1(),
                            width: 36,
                            height: 36,
                            child: Center(
                              child: Icon(
                                CupertinoIcons.arrow_left,
                                color: MyTheme.dark_font_grey,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),

                      //Show product name in appbar
                      AnimatedOpacity(
                          opacity: _scrollPosition > 350 ? 1 : 0,
                          duration: Duration(milliseconds: 200),
                          child: Container(
                              padding: EdgeInsets.only(left: 8),
                              width: DeviceInfo(context).width! / 2,
                              child: Text(
                                "${_auctionproductDetails != null ? _auctionproductDetails.name : ''}",
                                style: TextStyle(
                                    color: MyTheme.dark_font_grey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ))),
                      Spacer(),
                    ],
                  ),
                  expandedHeight: 375.0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: buildProductSliderImageSection(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecorations.buildBoxDecoration_1(),
                    margin: EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.only(top: 14, left: 14, right: 14),
                          child: _auctionproductDetails != null
                              ? Text(
                                  _auctionproductDetails.name,
                                  style: TextStyles.smallTitleTexStyle(),
                                  maxLines: 2,
                                )
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 30.0,
                                ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(top: 14, left: 14, right: 14),
                          child: _auctionproductDetails != null
                              ? buildMainPriceRow()
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 30.0,
                                ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(top: 14, left: 14, right: 14),
                          child: _auctionproductDetails != null
                              ? buildBrandRow()
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 50.0,
                                ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 14),
                          child: _auctionproductDetails != null
                              ? buildSellerRow(context)
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 50.0,
                                ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(top: 14, left: 12, right: 14),
                          child: _auctionproductDetails != null
                              ? buildAuctionWillEndRow()
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 30.0,
                                ),
                        ),
                        // starting bid
                        Padding(
                          padding:
                              EdgeInsets.only(top: 14, left: 12, right: 14),
                          child: _auctionproductDetails != null
                              ? buildAuctionStartingBidRow()
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 30.0,
                                ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 14, left: 12, right: 14, bottom: 14),
                          child: _auctionproductDetails != null
                              ? buildAuctionHighestBidRow()
                              : ShimmerHelper().buildBasicShimmer(
                                  height: 30.0,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: MyTheme.white,
                          margin: EdgeInsets.only(top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16.0,
                                  20.0,
                                  16.0,
                                  0.0,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.description_ucf,
                                  style: TextStyle(
                                      color: MyTheme.dark_font_grey,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  8.0,
                                  0.0,
                                  8.0,
                                  8.0,
                                ),
                                child: _auctionproductDetails != null
                                    ? buildExpandableDescription()
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 8.0),
                                        child:
                                            ShimmerHelper().buildBasicShimmer(
                                          height: 60.0,
                                        )),
                              ),
                            ],
                          ),
                        ),
                        divider(),
                        InkWell(
                          onTap: () {
                            if (_auctionproductDetails.videoLink == "") {
                              ToastComponent.showDialog(
                                  AppLocalizations.of(context)!
                                      .video_not_available,
                                  gravity: Toast.center,
                                  duration: Toast.lengthLong);
                              return;
                            }

                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return VideoDescription(
                                url: _auctionproductDetails.videoLink,
                              );
                            })).then((value) {
                              onPopped(value);
                            });
                          },
                          child: Container(
                            color: MyTheme.white,
                            height: 48,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                18.0,
                                14.0,
                                18.0,
                                14.0,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.video_ucf,
                                    style: TextStyle(
                                        color: MyTheme.dark_font_grey,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Spacer(),
                                  Image.asset(
                                    "assets/arrow.png",
                                    height: 11,
                                    width: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        divider(),
                        InkWell(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return CommonWebviewScreen(
                                url:
                                    "${AppConfig.RAW_BASE_URL}/mobile-page/seller-policy",
                                page_name: AppLocalizations.of(context)!
                                    .seller_policy_ucf,
                              );
                            }));
                          },
                          child: Container(
                            color: MyTheme.white,
                            height: 48,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                18.0,
                                14.0,
                                18.0,
                                14.0,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!
                                        .seller_policy_ucf,
                                    style: TextStyle(
                                        color: MyTheme.dark_font_grey,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Spacer(),
                                  Image.asset(
                                    "assets/arrow.png",
                                    height: 11,
                                    width: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        divider(),
                        InkWell(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return CommonWebviewScreen(
                                url:
                                    "${AppConfig.RAW_BASE_URL}/mobile-page/return-policy",
                                page_name: AppLocalizations.of(context)!
                                    .return_policy_ucf,
                              );
                            }));
                          },
                          child: Container(
                            color: MyTheme.white,
                            height: 48,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                18.0,
                                14.0,
                                18.0,
                                14.0,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!
                                        .return_policy_ucf,
                                    style: TextStyle(
                                        color: MyTheme.dark_font_grey,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Spacer(),
                                  Image.asset(
                                    "assets/arrow.png",
                                    height: 11,
                                    width: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        divider(),
                        InkWell(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return CommonWebviewScreen(
                                url:
                                    "${AppConfig.RAW_BASE_URL}/mobile-page/support-policy",
                                page_name: AppLocalizations.of(context)!
                                    .support_policy_ucf,
                              );
                            }));
                          },
                          child: Container(
                            color: MyTheme.white,
                            height: 48,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                18.0,
                                14.0,
                                18.0,
                                14.0,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!
                                        .support_policy_ucf,
                                    style: TextStyle(
                                        color: MyTheme.dark_font_grey,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Spacer(),
                                  Image.asset(
                                    "assets/arrow.png",
                                    height: 11,
                                    width: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        divider(),
                      ]),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16.0,
                        0.0,
                        16.0,
                        0.0,
                      ),
                    ),
                    Container(
                      height: 83,
                    )
                  ]),
                )
              ],
            ),
          )),
    );
  }

  Widget buildSellerRow(BuildContext context) {
    //print("sl:" +  _productDetails.shop_logo);
    return Container(
      color: MyTheme.light_grey,
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          _auctionproductDetails.addedBy == "admin"
              ? Container()
              : InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SellerDetails(
                                  slug: _auctionproductDetails.shopSlug,
                                )));
                  },
                  child: Padding(
                    padding: app_language_rtl.$!
                        ? EdgeInsets.only(left: 8.0)
                        : EdgeInsets.only(right: 8.0),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(
                            color: Color.fromRGBO(112, 112, 112, .3), width: 1),
                        //shape: BoxShape.rectangle,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6.0),
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/placeholder.png',
                          image: _auctionproductDetails.shopLogo,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
          Container(
            width: MediaQuery.of(context).size.width * (.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.seller_ucf,
                    style: TextStyle(
                      color: Color.fromRGBO(153, 153, 153, 1),
                    )),
                Text(
                  _auctionproductDetails.shopName,
                  style: TextStyle(
                      color: MyTheme.font_grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                )
              ],
            ),
          ),
          Spacer(),
          Visibility(
            visible: conversation_system_status.$,
            child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecorations.buildCircularButtonDecoration_1(),
                child: Row(
                  children: [
                    InkWell(
                        onTap: () {
                          if (is_logged_in == false) {
                            ToastComponent.showDialog("You need to log in",
                                gravity: Toast.center,
                                duration: Toast.lengthLong);
                            return;
                          }

                          onTapSellerChat();
                        },
                        child: Image.asset('assets/chat.png',
                            height: 16, width: 16, color: MyTheme.dark_grey)),
                  ],
                )),
          )
        ],
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget submitBtn = TextButton(
      style: TextButton.styleFrom(
        backgroundColor: MyTheme.accent_color,
      ),
      child: Text(
        AppLocalizations.of(context)!.submit_ucf,
        style: TextStyle(color: MyTheme.white),
      ),
      onPressed: () {
        _bidPriceController.clear();
      },
    );

    // set up the AlertDialog
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.bid_for_product_ucf,
                        style: TextStyle(
                            fontSize: 13, color: MyTheme.dark_font_grey),
                      ),
                      Text(
                        "(${AppLocalizations.of(context)!.min_bid_amount_ucf}: ${_auctionproductDetails.minBidPrice})",
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () {
                      // todo:: navigator does not pop
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 1,
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.place_bid_price_ucf,
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    "*",
                    style: TextStyle(color: Colors.red),
                  )
                ],
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _bidPriceController,
                      decoration: InputDecoration(
                        hintText:
                            AppLocalizations.of(context)!.enter_amount_ucf,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppLocalizations.of(context)!
                              .please_fill_out_this_form;
                        }

                        if (_auctionproductDetails.highestBid != '') {
                          if (double.parse(value) <
                              _auctionproductDetails.minBidPrice.toDouble()) {
                            return AppLocalizations.of(context)!
                                .value_must_be_greater;
                          }
                        }
                        if (_auctionproductDetails.highestBid == '') {
                          if (double.parse(value) <
                              _auctionproductDetails.minBidPrice.toDouble()) {
                            return AppLocalizations.of(context)!
                                .value_must_be_greater_or_equal;
                          }
                        }

                        return null;
                        ;
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: MyTheme.accent_color,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.submit_ucf,
                            style: TextStyle(color: MyTheme.white),
                          ),
                          onPressed: () {
                            if (!_formKey.currentState!.validate()) {
                            } else {
                              onPressBidPlace();
                              Navigator.pop(context);

                              _bidPriceController.clear();
                            }
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          actions: [
            // cancelButton,
            // submitBtn,
          ],
        );
      },
    );
  }

  Widget buildTotalPriceRow() {
    return Container(
      height: 40,
      color: MyTheme.amber,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Container(
            child: Padding(
              padding: app_language_rtl.$!
                  ? EdgeInsets.only(left: 8.0)
                  : EdgeInsets.only(right: 8.0),
              child: Container(
                width: 75,
                child: Text(
                  AppLocalizations.of(context)!.total_price_ucf,
                  style: TextStyle(
                      color: Color.fromRGBO(153, 153, 153, 1), fontSize: 10),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Text(
              _auctionproductDetails.currencySymbol.toString(),
              style: TextStyle(
                  color: MyTheme.accent_color,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }

  Widget buildAuctionStartingBidRow() {
    return Row(
      children: [
        Padding(
          padding: app_language_rtl.$!
              ? EdgeInsets.only(left: 8.0)
              : EdgeInsets.only(right: 8.0),
          child: Container(
            width: 95,
            child: Text(
              AppLocalizations.of(context)!.starting_bid_ucf,
              style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Text(convertPrice(_auctionproductDetails.startingBid)),
              Text(" /${_auctionproductDetails.unit}"),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildAuctionHighestBidRow() {
    return Row(
      children: [
        Padding(
          padding: app_language_rtl.$!
              ? EdgeInsets.only(left: 8.0)
              : EdgeInsets.only(right: 8.0),
          child: Container(
            width: 95,
            child: Text(
              AppLocalizations.of(context)!.highest_bid_ucf,
              style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: _auctionproductDetails.highestBid != ''
              ? Text(convertPrice(_auctionproductDetails.highestBid))
              : Text(''),
        ),
      ],
    );
  }

  Row buildAuctionWillEndRow() {
    return Row(
      children: [
        Padding(
          padding: app_language_rtl.$!
              ? EdgeInsets.only(left: 8.0)
              : EdgeInsets.only(right: 8.0),
          child: Container(
            width: 95,
            child: Text(
              AppLocalizations.of(context)!.auction_will_end,
              style: TextStyle(color: Color.fromRGBO(153, 153, 153, 1)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
            height: 25,
            width: 200,
            child: CountdownTimer(
              controller: countDownTimercontroller,
              endTime: DateTime.now().day +
                  (1000 * _auctionproductDetails.auctionEndDate as int),
              widgetBuilder: (_, CurrentRemainingTime? time) {
                List _auctionEndTimeList = [];
                _auctionEndTimeList
                    .addAll([time!.days, time.hours, time.min, time.sec]);

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _auctionEndTimeList.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(":"),
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding: EdgeInsets.all(6),
                      child: Text(
                        '${_auctionEndTimeList[index] ?? 00}',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(3.0)),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Padding buildVariantShimmers() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16.0,
        0.0,
        8.0,
        0.0,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Padding(
                  padding: app_language_rtl.$!
                      ? EdgeInsets.only(left: 8.0)
                      : EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$!
                      ? EdgeInsets.only(left: 8.0)
                      : EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$!
                      ? EdgeInsets.only(left: 8.0)
                      : EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$!
                      ? EdgeInsets.only(left: 8.0)
                      : EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Padding(
                  padding: app_language_rtl.$!
                      ? EdgeInsets.only(left: 8.0)
                      : EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$!
                      ? EdgeInsets.only(left: 8.0)
                      : EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$!
                      ? EdgeInsets.only(left: 8.0)
                      : EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                ),
                Padding(
                  padding: app_language_rtl.$!
                      ? EdgeInsets.only(left: 8.0)
                      : EdgeInsets.only(right: 8.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 30.0, width: 60),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Row buildMainPriceRow() {
    return Row(
      children: [
        // Text(
        //   _singlePriceString,
        //   style: TextStyle(
        //       color: MyTheme.accent_color,
        //       fontSize: 16.0,
        //       fontWeight: FontWeight.w600),
        // ),
        // Visibility(
        //   visible: _auctionproductDetails.has_discount,
        //   child: Padding(
        //     padding: EdgeInsets.only(left: 8.0),
        //     child: Text(_auctionproductDetails.stroked_price,
        //         style: TextStyle(
        //           decoration: TextDecoration.lineThrough,
        //           color: Color.fromRGBO(224, 224, 225, 1),
        //           fontSize: 12.0,
        //           fontWeight: FontWeight.normal,
        //         )),
        //   ),
        // ),
        // Visibility(
        //   visible: _auctionproductDetails.has_discount,
        //   child: Padding(
        //     padding: EdgeInsets.only(left: 8.0),
        //     child: Text(
        //       "${_auctionproductDetails.discount}",
        //       style: TextStyles.largeBoldAccentTexStyle(),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  AppBar buildAppBar(double statusBarHeight, BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(CupertinoIcons.arrow_left, color: MyTheme.dark_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Container(
        height: kToolbarHeight +
            statusBarHeight -
            (MediaQuery.of(context).viewPadding.top > 40 ? 32.0 : 16.0),
        //MediaQuery.of(context).viewPadding.top is the statusbar height, with a notch phone it results almost 50, without a notch it shows 24.0.For safety we have checked if its greater than thirty
        child: Container(
            width: 300,
            child: Padding(
              padding: const EdgeInsets.only(top: 22.0),
              child: Text(
                _appbarPriceString,
                style: TextStyle(fontSize: 16, color: MyTheme.font_grey),
              ),
            )),
      ),
      elevation: 0.0,
      titleSpacing: 0,
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
          child: IconButton(
            icon: Icon(Icons.share_outlined, color: MyTheme.dark_grey),
            onPressed: () {
              onPressShare(context);
            },
          ),
        ),
      ],
    );
  }

  buildBrandRow() {
    return _auctionproductDetails.brand.id > 0
        ? InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return BrandProducts(
                  slug: _auctionproductDetails.brand.slug,
                );
              }));
            },
            child: Row(
              children: [
                Padding(
                  padding: app_language_rtl.$!
                      ? EdgeInsets.only(left: 8.0)
                      : EdgeInsets.only(right: 8.0),
                  child: Container(
                    width: 75,
                    child: Text(
                      AppLocalizations.of(context)!.brand_ucf,
                      style: TextStyle(
                          color: Color.fromRGBO(
                            153,
                            153,
                            153,
                            1,
                          ),
                          fontSize: 10),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    _auctionproductDetails.brand.name,
                    style: TextStyle(
                        color: MyTheme.font_grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 10),
                  ),
                ),
                /*Spacer(),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                        color: Color.fromRGBO(112, 112, 112, .3), width: 1),
                    //shape: BoxShape.rectangle,
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/placeholder.png',
                        image: _auctionproductDetails.brand.logo,
                        fit: BoxFit.contain,
                      )),
                ),*/
              ],
            ),
          )
        : Container();
  }

  ExpandableNotifier buildExpandableDescription() {
    return ExpandableNotifier(
        child: ScrollOnExpand(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expandable(
            collapsed: Container(
                height: 50,
                child: Html(data: _auctionproductDetails.description)),
            expanded: Container(
                child: Html(data: _auctionproductDetails.description)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Builder(
                builder: (context) {
                  var controller = ExpandableController.of(context)!;
                  return Btn.basic(
                    child: Text(
                      !controller.expanded
                          ? AppLocalizations.of(context)!.view_more_ucf
                          : AppLocalizations.of(context)!.show_less_ucf,
                      style: TextStyle(color: MyTheme.font_grey, fontSize: 11),
                    ),
                    onPressed: () {
                      controller.toggle();
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ));
  }

  openPhotoDialog(BuildContext context, path) => showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
                child: Stack(
              children: [
                PhotoView(
                  enableRotation: true,
                  heroAttributes: const PhotoViewHeroAttributes(tag: "someTag"),
                  imageProvider: NetworkImage(path),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: ShapeDecoration(
                      color: MyTheme.medium_grey_50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          bottomRight: Radius.circular(25),
                          topRight: Radius.circular(25),
                          topLeft: Radius.circular(25),
                        ),
                      ),
                    ),
                    width: 40,
                    height: 40,
                    child: IconButton(
                      icon: Icon(Icons.clear, color: MyTheme.white),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                    ),
                  ),
                ),
              ],
            )),
          );
        },
      );

  buildProductImageSection() {
    if (_productImageList.length == 0) {
      return Row(
        children: [
          Container(
            width: 40,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 40.0, width: 40.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 40.0, width: 40.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 40.0, width: 40.0),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ShimmerHelper()
                      .buildBasicShimmer(height: 40.0, width: 40.0),
                ),
              ],
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ShimmerHelper().buildBasicShimmer(
                height: 190.0,
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 250,
            width: 64,
            child: Scrollbar(
              controller: _imageScrollController,
              // isAlwaysShown: false,
              thickness: 4.0,
              child: Padding(
                padding: app_language_rtl.$!
                    ? EdgeInsets.only(left: 8.0)
                    : EdgeInsets.only(right: 8.0),
                child: ListView.builder(
                    itemCount: _productImageList.length,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      int itemIndex = index;
                      return GestureDetector(
                        onTap: () {
                          _currentImage = itemIndex;
                          // print(_currentImage);
                          setState(() {});
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          margin: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 2.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: _currentImage == itemIndex
                                    ? MyTheme.accent_color
                                    : Color.fromRGBO(112, 112, 112, .3),
                                width: _currentImage == itemIndex ? 2 : 1),
                            //shape: BoxShape.rectangle,
                          ),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child:
                                  /*Image.asset(
                                        singleProduct.product_images[index])*/
                                  FadeInImage.assetNetwork(
                                placeholder: 'assets/placeholder.png',
                                image: _productImageList[index],
                                fit: BoxFit.contain,
                              )),
                        ),
                      );
                    }),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              openPhotoDialog(context, _productImageList[_currentImage]);
            },
            child: Container(
              height: 250,
              width: MediaQuery.of(context).size.width - 96,
              child: Container(
                  child: FadeInImage.assetNetwork(
                placeholder: 'assets/placeholder_rectangle.png',
                image: _productImageList[_currentImage],
                fit: BoxFit.scaleDown,
              )),
            ),
          ),
        ],
      );
    }
  }

  Widget buildProductSliderImageSection() {
    if (_productImageList.length == 0) {
      return ShimmerHelper().buildBasicShimmer(
        height: 190.0,
      );
    } else {
      return CarouselSlider(
        carouselController: _carouselController,
        options: CarouselOptions(
            aspectRatio: 355 / 375,
            viewportFraction: 1,
            initialPage: 0,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 5),
            autoPlayAnimationDuration: Duration(milliseconds: 1000),
            autoPlayCurve: Curves.easeInExpo,
            enlargeCenterPage: false,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              print(index);
              setState(() {
                _currentImage = index;
              });
            }),
        items: _productImageList.map((i) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                child: Stack(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        openPhotoDialog(
                            context, _productImageList[_currentImage]);
                      },
                      child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/placeholder_rectangle.png',
                            image: i,
                            fit: BoxFit.fitHeight,
                          )),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                              _productImageList.length,
                              (index) => Container(
                                    width: 7.0,
                                    height: 7.0,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 4.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentImage == index
                                          ? MyTheme.font_grey
                                          : Colors.grey.withOpacity(0.2),
                                    ),
                                  ))),
                    ),
                  ],
                ),
              );
            },
          );
        }).toList(),
      );
    }
  }

  Widget divider() {
    return Container(
      color: MyTheme.light_grey,
      height: 5,
    );
  }
}
