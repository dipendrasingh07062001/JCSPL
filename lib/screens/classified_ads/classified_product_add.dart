import 'dart:convert';

import 'package:active_ecommerce_flutter/data_model/category.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import '../../custom/aiz_summer_note.dart';
import '../../custom/device_info.dart';
import '../../custom/lang_text.dart';
import '../../custom/loading.dart';
import '../../custom/my_widget.dart';
import '../../custom/toast_component.dart';
import '../../custom/useful_elements.dart';
import '../../data_model/uploaded_file_list_response.dart';
import '../../helpers/shared_value_helper.dart';
import '../../my_theme.dart';
import '../../repositories/brand_repository.dart';
import '../../repositories/classified_product_repository.dart';
import '../../repositories/product_repository.dart';
import '../uploads/upload_file.dart';

class ClassifiedProductAdd extends StatefulWidget {
  const ClassifiedProductAdd({Key? key}) : super(key: key);

  @override
  State<ClassifiedProductAdd> createState() => _ClassifiedProductAddState();
}

class _ClassifiedProductAddState extends State<ClassifiedProductAdd> {
  double mHeight = 0.0, mWidht = 0.0;
  bool _generalExpanded = true;
  bool _mediaExpanded = false;
  bool _priceExpanded = false;
  bool _descriptionExpanded = false;
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

  // controllers
  TextEditingController productNameEditTextController = TextEditingController();
  TextEditingController unitEditTextController = TextEditingController();
  TextEditingController tagEditTextController = TextEditingController();
  TextEditingController locationTextController = TextEditingController();
  TextEditingController metaTitleTextController = TextEditingController();
  TextEditingController metaDescriptionEditTextController =
      TextEditingController();
  TextEditingController videoLinkController = TextEditingController();
  TextEditingController unitPriceEditTextController =
      TextEditingController(text: "0");

  GlobalKey<FlutterSummernoteState> productDescriptionKey = GlobalKey();

  CommonDropDownItemWithChild? selectedCategory;
  List<CommonDropDownItemWithChild> categories = [];
  CommonDropDownItem? selectedBrand;
  List<CommonDropDownItem> brands = [];

  CommonDropDownItem? selectedVideoType;
  List<CommonDropDownItem> videoType = [];
  List<FileInfo> productGalleryImages = [];
  FileInfo? thumbnailImage;
  FileInfo? pdfSpecification;
  FileInfo? metaImage;
  List<String?>? tags = [];
  String? description = "";
  List itemList = ['new', 'used'];
  String? selectedCondition;

  setConstDropdownValues() {
    videoType.addAll([
      CommonDropDownItem("youtube", LangText(context).local.youtube_ucf),
      CommonDropDownItem(
          "dailymotion", LangText(context).local.dailymotion_ucf),
      CommonDropDownItem("vimeo", LangText(context).local.vimeo_ucf),
    ]);
    selectedVideoType = videoType.first;
  }

  List<CommonDropDownItemWithChild> setChildCategory(List<CatData> child) {
    List<CommonDropDownItemWithChild> list = [];
    child.forEach((element) {
      var children = element.child ?? [];
      CommonDropDownItemWithChild model = CommonDropDownItemWithChild(
        key: element.id.toString(),
        value: element.name,
        children: children.isNotEmpty ? setChildCategory(children) : [],
      );

      categories.add(model);
    });
    return list;
  }

  getCategories() async {
    var categoryResponse = await ProductRepository().getCategoryRes();
    categoryResponse.data!.forEach((element) {
      CommonDropDownItemWithChild model = CommonDropDownItemWithChild(
          key: element.id.toString(),
          value: element.name,
          level: element.level,
          children: setChildCategory(element.child!));
      categories.add(model);
    });
    if (categories.isNotEmpty) {
      selectedCategory = categories.first;
    }
    setState(() {});
  }

  getBrands() async {
    var brandsRes = await BrandRepository().getBrands();
    // print(brandsRes.brands);
    brandsRes.brands!.forEach((element) {
      brands.addAll([
        CommonDropDownItem("${element.id}", element.name),
      ]);
    });
    setState(() {});
  }

  bool requiredFieldVerification() {
    if (productNameEditTextController.text.trim().toString().isEmpty) {
      ToastComponent.showDialog(LangText(context).local.product_name_required,
          gravity: Toast.center);
      return false;
    } else if (unitEditTextController.text.trim().toString().isEmpty) {
      ToastComponent.showDialog(LangText(context).local.product_unit_required,
          gravity: Toast.center);
      return false;
    } else if (locationTextController.text.trim().toString().isEmpty) {
      ToastComponent.showDialog(LangText(context).local.location_required,
          gravity: Toast.center);
      return false;
    } else if (tags!.isEmpty) {
      ToastComponent.showDialog(LangText(context).local.product_tag_required,
          gravity: Toast.center);
      return false;
    } else if (description.toString() == "") {
      ToastComponent.showDialog(
          LangText(context).local.product_description_required,
          gravity: Toast.center);
      return false;
    }
    return true;
  }

  String? productName,
      brandId,
      categoryId,
      unit,
      condition,
      location,
      photos,
      thumbnailImg,
      videoProvider,
      videoLink,
      unitPrice,
      externalLink,
      pdf,
      metaTitle,
      metaDescription,
      metaImg;
  var tagMap = [];

  setProductPhotoValue() {
    photos = "";
    for (int i = 0; i < productGalleryImages.length; i++) {
      if (i != (productGalleryImages.length - 1)) {
        photos = "$photos " + "${productGalleryImages[i].id},";
      } else {
        photos = "$photos " + "${productGalleryImages[i].id}";
      }
    }
  }

  setProductValues() async {
    productName = productNameEditTextController.text.trim();
    if (selectedBrand != null) brandId = selectedBrand!.key;
    if (selectedCategory != null) categoryId = selectedCategory!.key;
    unit = unitEditTextController.text.trim();
    condition = selectedCondition;
    location = locationTextController.text.trim();

    tagMap.clear();
    tags!.forEach((element) {
      tagMap.add(jsonEncode({"value": '$element'}));
    });
    // description is up there
    if (productDescriptionKey.currentState != null) {
      description = await productDescriptionKey.currentState!.getText() ?? "";
      // description = await productDescriptionKey.currentState!.getText() ?? "";
    }

    // media
    setProductPhotoValue();

    if (thumbnailImage != null) thumbnailImg = "${thumbnailImage!.id}";
    videoProvider = selectedVideoType!.key;
    videoLink = videoLinkController.text.trim().toString();

    if (pdfSpecification != null) pdf = "${pdfSpecification!.id}";
    // price
    unitPrice = unitPriceEditTextController.text.trim().toString();
    metaTitle = metaTitleTextController.text.trim().toString();
    metaDescription = metaDescriptionEditTextController.text.trim().toString();
    if (metaImage != null) metaImg = "${metaImage!.id}";
  }

  submit() async {
    // print('submit');

    if (!requiredFieldVerification()) {
      return;
    }
    Loading.show(context);
    await setProductValues();
    Map postValue = {};

    postValue.addAll({
      "name": productName,
      "added_by": "customer",
      "category_id": categoryId,
      "brand_id": brandId,
      "unit": unit,
      "conditon": condition,
      "location": location,
      "tags": [tagMap.toString()],
      "description": description,
      // media
      "photos": photos,
      "thumbnail_img": thumbnailImg,
      "video_provider": videoProvider,
      "video_link": videoLink,
      "pdf": pdf,
      // price
      "unit_price": unitPrice,
      "meta_title": metaTitle,
      "meta_description": metaDescription,
      "meta_img": metaImg,
    });

    var postBody = jsonEncode(postValue);
    var response =
        await ClassifiedProductRepository().addProductResponse(postBody);

    // print(postBody);

    Loading.close();
    if (response.result) {
      ToastComponent.showDialog(response.message, gravity: Toast.center);

      Navigator.pop(context);
    } else {
      dynamic errorMessages = response.message;
      if (errorMessages.runtimeType == String) {
        ToastComponent.showDialog(errorMessages, gravity: Toast.center);
      } else {
        ToastComponent.showDialog(errorMessages.join(","),
            gravity: Toast.center);
      }
    }
  }

  fetchAll() {
    getBrands();
    getCategories();
    setConstDropdownValues();
  }

  @override
  void initState() {
    // set intial value
    selectedCondition = itemList.first;

    fetchAll();

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          app_language_rtl.$! ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            "Add New Classified Product",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: MyTheme.dark_font_grey),
          ),
          backgroundColor: MyTheme.white,
          leading: UsefulElements.backButton(context),
        ),
        body: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Column(
          children: [
            buildGeneral(),
            itemSpacer(),
            buildMedia(),
            itemSpacer(),
            buildPrice(),
          ],
        ),
      ),
    );
  }

  buildGeneral() {
    return GestureDetector(
      onTap: () {
        _generalExpanded = !_generalExpanded;
        setState(() {});
      },
      child: Material(
        elevation: 10,
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: const Color.fromRGBO(255, 255, 255, 0), width: 0.0),
            boxShadow: [
              BoxShadow(
                color: MyTheme.white,
              ),
            ],
          ),
          padding: EdgeInsets.only(top: 10, left: 5, right: 5),
          alignment: Alignment.topCenter,
          // height: _generalExpanded ? 200 : 40,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LangText(context).local.general_ucf,
                    style: TextStyle(
                        fontSize: 13,
                        color: MyTheme.dark_font_grey,
                        fontWeight: FontWeight.bold),
                  ),
                  Icon(
                    _generalExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.navigate_next_rounded,
                    size: 20,
                    color: MyTheme.dark_font_grey,
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Visibility(
                visible: _generalExpanded,
                child: Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildEditTextField(
                        LangText(context).local.product_name_ucf,
                        LangText(context).local.product_name_ucf,
                        productNameEditTextController,
                        isMandatory: true,
                      ),
                      itemSpacer(),
                      _buildDropDownField(LangText(context).local.brand_ucf,
                          (value) {
                        selectedBrand = value;
                        setChange();
                      }, selectedBrand, brands),
                      itemSpacer(),
                      _buildDropDownFieldWithChildren(
                          LangText(context).local.categories_ucf, (value) {
                        selectedCategory = value;
                        setChange();
                      }, selectedCategory, categories),
                      itemSpacer(),
                      buildEditTextField(
                          LangText(context).local.product_unit_ucf,
                          LangText(context).local.product_unit_ucf,
                          unitEditTextController,
                          isMandatory: true),
                      itemSpacer(),
                      buildGroupItems(
                        LangText(context).local.condition_ucf,
                        Focus(
                          onFocusChange: (hasFocus) {
                            setState(() {
                              _hasFocus = hasFocus;
                            });
                          },
                          child: Container(
                            height: 36,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: MyTheme.white,
                              border: Border.all(
                                  color: _hasFocus
                                      ? MyTheme.textfield_grey
                                      : MyTheme.accent_color,
                                  style: BorderStyle.solid,
                                  width: _hasFocus ? 0.5 : 0.2),
                              boxShadow: [
                                BoxShadow(
                                  color: MyTheme.blue_grey.withOpacity(0.15),
                                  blurRadius: 20,
                                  spreadRadius: 0.0,
                                  offset: const Offset(0.0,
                                      10.0), // shadow direction: bottom right
                                )
                              ],
                            ),
                            child: DropdownButton<String>(
                              menuMaxHeight: 300,
                              isDense: true,
                              underline: Container(),
                              isExpanded: true,
                              onChanged: (String? value) {
                                setState(() {
                                  selectedCondition = value;
                                });
                              },
                              icon: const Icon(Icons.arrow_drop_down),
                              value: selectedCondition,
                              items: itemList
                                  .map(
                                    (value) => DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                      itemSpacer(),
                      buildEditTextField(
                          LangText(context).local.location_ucf,
                          LangText(context).local.location_ucf,
                          locationTextController,
                          isMandatory: true),
                      itemSpacer(),
                      buildTagsEditTextField(
                          LangText(context).local.tags_ucf,
                          LangText(context).local.tags_ucf,
                          tagEditTextController,
                          isMandatory: true),
                      itemSpacer(),
                      buildGroupItems(
                        LangText(context).local.descriptions_ucf,
                        summerNote(LangText(context).local.descriptions_ucf),
                      ),
                      itemSpacer(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  buildMedia() {
    return GestureDetector(
      onTap: () {
        _mediaExpanded = !_mediaExpanded;
        setState(() {});
      },
      child: Material(
        elevation: 10,
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: const Color.fromRGBO(255, 255, 255, 0), width: 0.0),
            boxShadow: [
              BoxShadow(
                color: MyTheme.white,
              ),
            ],
          ),
          padding: EdgeInsets.only(top: 10, left: 5, right: 5),
          alignment: Alignment.topCenter,
          // height: _mediaExpanded ? 200 : 40,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LangText(context).local.media_ucf,
                    style: TextStyle(
                        fontSize: 13,
                        color: MyTheme.dark_font_grey,
                        fontWeight: FontWeight.bold),
                  ),
                  Icon(
                    _mediaExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.navigate_next_rounded,
                    size: 20,
                    color: MyTheme.dark_font_grey,
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Visibility(
                visible: _mediaExpanded,
                child: Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      chooseGalleryImageField(),
                      itemSpacer(),
                      chooseSingleImageField(
                          LangText(context).local.thumbnail_image_ucf,
                          (onChosenImage) {
                        thumbnailImage = onChosenImage;
                        setChange();
                      }, thumbnailImage),
                      buildGroupItems(
                          LangText(context).local.video_form_ucf,
                          _buildDropDownField(
                              LangText(context).local.video_url_ucf,
                              (newValue) {
                            selectedVideoType = newValue;
                            setChange();
                          }, selectedVideoType, videoType)),
                      itemSpacer(),
                      buildEditTextField(
                        LangText(context).local.video_url_ucf,
                        LangText(context).local.video_link_ucf,
                        videoLinkController,
                      ),
                      itemSpacer(),
                      // chooseSingleImageField("Pdf Specification",
                      //     (onChosenImage) {
                      //   pdfSpecification = onChosenImage;
                      //   setChange();
                      // }, pdfSpecification),
                      chooseSingleFileField(
                          LangText(context).local.pdf_specification_ucf, "",
                          (onChosenFile) {
                        pdfSpecification = onChosenFile;
                        setChange();
                      }, pdfSpecification),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget chooseSingleFileField(String title, String shortMessage,
      dynamic onChosenFile, FileInfo? selectedFile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 12,
                  color: MyTheme.font_grey,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            fileField(
                LangText(context).local.document, onChosenFile, selectedFile)
          ],
        ),
      ],
    );
  }

  Widget fileField(
      String fileType, dynamic onChosenFile, FileInfo? selectedFile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
          onPressed: () async {
            // XFile chooseFile = await pickSingleImage();
            List<FileInfo> chooseFile = await (Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UploadFile(
                          fileType: fileType,
                          canSelect: true,
                        ))));
            // print("chooseFile.url");
            // print(chooseFile.first.url);
            if (chooseFile.isNotEmpty) {
              onChosenFile(chooseFile.first);
            }
          },
          // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          child: MyWidget().myContainer(
            width: DeviceInfo(context).width!.toDouble(),
            height: 36,
            borderRadius: 6.0,
            borderColor: MyTheme.light_grey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 14.0),
                  child: Text(
                    LangText(context).local.choose_file,
                    style: TextStyle(fontSize: 12, color: MyTheme.grey_153),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  height: 46,
                  width: 80,
                  color: MyTheme.light_grey,
                  child: Text(
                    LangText(context).local.browse,
                    style: TextStyle(fontSize: 12, color: MyTheme.grey_153),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        if (selectedFile != null)
          Stack(
            children: [
              Container(
                padding: EdgeInsets.all(3),
                height: 40,
                alignment: Alignment.center,
                width: 40,
                decoration: BoxDecoration(
                  color: MyTheme.grey_153,
                ),
                child: Text(
                  selectedFile.fileOriginalName! +
                      "." +
                      selectedFile.extension!,
                  style: TextStyle(fontSize: 9, color: MyTheme.white),
                ),
              ),
              Positioned(
                top: 0,
                right: 5,
                child: Container(
                  height: 15,
                  width: 15,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: MyTheme.white),
                  // remove the selected file button
                  child: InkWell(
                    onTap: () {
                      onChosenFile(null);
                    },
                    child: Icon(
                      Icons.close,
                      size: 12,
                      color: MyTheme.brick_red,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget chooseSingleImageField(
      String title, dynamic onChosenImage, FileInfo? selectedFile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 12,
                  color: MyTheme.font_grey,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            imageField(onChosenImage, selectedFile)
          ],
        ),
      ],
    );
  }

  Widget imageField(dynamic onChosenImage, FileInfo? selectedFile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
          onPressed: () async {
            // XFile chooseFile = await pickSingleImage();
            List<FileInfo> chooseFile = await (Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UploadFile(
                          fileType: "image",
                          canSelect: true,
                        ))));
            // print("chooseFile.url");
            // print(chooseFile.first.url);
            if (chooseFile.isNotEmpty) {
              onChosenImage(chooseFile.first);
            }
          },
          child: MyWidget().myContainer(
            width: DeviceInfo(context).width!,
            height: 36,
            borderColor: MyTheme.accent_color,
            borderWith: 0.2,
            borderRadius: 6.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 14.0),
                  child: Text(
                    LangText(context).local.choose_file,
                    style: TextStyle(fontSize: 12, color: MyTheme.grey_153),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  height: 46,
                  width: 80,
                  color: MyTheme.light_grey,
                  child: Text(
                    LangText(context).local.browse,
                    style: TextStyle(fontSize: 12, color: MyTheme.grey_153),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (selectedFile != null)
          Stack(
            fit: StackFit.passthrough,
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.bottomCenter,
            children: [
              SizedBox(
                height: 60,
                width: 70,
              ),
              MyWidget.imageWithPlaceholder(
                  border: Border.all(width: 0.5, color: MyTheme.light_grey),
                  radius: BorderRadius.circular(5),
                  height: 50.0,
                  width: 50.0,
                  url: selectedFile.url),
              Positioned(
                top: 3,
                right: 2,
                child: Container(
                  height: 15,
                  width: 15,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: MyTheme.light_grey),
                  child: InkWell(
                    onTap: () {
                      onChosenImage(null);
                    },
                    child: Icon(
                      Icons.close,
                      size: 12,
                      color: MyTheme.cinnabar,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  buildPrice() {
    return GestureDetector(
      onTap: () {
        _priceExpanded = !_priceExpanded;
        setState(() {});
      },
      child: Material(
        elevation: 10,
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: const Color.fromRGBO(255, 255, 255, 0), width: 0.0),
            boxShadow: [
              BoxShadow(
                color: MyTheme.white,
              ),
            ],
          ),
          padding: EdgeInsets.only(top: 10, left: 5, right: 5),
          alignment: Alignment.topCenter,
          // height: _priceExpanded ? 200 : 40,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LangText(context).local.auction_price_ucf,
                    style: TextStyle(
                        fontSize: 13,
                        color: MyTheme.dark_font_grey,
                        fontWeight: FontWeight.bold),
                  ),
                  Icon(
                    _priceExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.navigate_next_rounded,
                    size: 20,
                    color: MyTheme.dark_font_grey,
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Visibility(
                visible: _priceExpanded,
                child: Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildEditTextField(
                        LangText(context).local.auction_price_ucf,
                        LangText(context)
                            .local
                            .custom_unit_price_and_base_price,
                        unitPriceEditTextController,
                        isMandatory: true,
                      ),
                      itemSpacer(),
                      buildGroupItems(
                        LangText(context).local.meta_tags_ucf,
                        buildEditTextField(
                          LangText(context).local.meta_title_ucf,
                          LangText(context).local.meta_title_ucf,
                          metaTitleTextController,
                          isMandatory: false,
                        ),
                      ),
                      itemSpacer(),
                      buildGroupItems(
                        LangText(context).local.meta_description_ucf,
                        Container(
                          padding: EdgeInsets.all(8),
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: MyTheme.accent_color,
                                style: BorderStyle.solid,
                                width: 0.1),
                            boxShadow: [
                              BoxShadow(
                                color: MyTheme.white.withOpacity(0.15),
                                blurRadius: 20,
                                spreadRadius: 0.0,
                                offset: const Offset(0.0,
                                    10.0), // shadow direction: bottom right
                              )
                            ],
                          ),
                          child: TextField(
                            controller: metaDescriptionEditTextController,
                            keyboardType: TextInputType.multiline,
                            minLines: 1,
                            maxLines: 50,
                            enabled: true,
                            style: TextStyle(fontSize: 12),
                            decoration: InputDecoration.collapsed(
                                hintText: LangText(context)
                                    .local
                                    .meta_description_ucf),
                          ),
                        ),
                      ),
                      itemSpacer(),
                      chooseSingleImageField(
                          LangText(context).local.meta_image_ucf,
                          (onChosenImage) {
                        metaImage = onChosenImage;
                        setChange();
                      }, metaImage),

                      // submit button
                      itemSpacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: TextButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  MyTheme.accent_color),
                              shape: WidgetStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6.0),
                                  side: BorderSide(color: Colors.red),
                                ),
                              ),
                            ),
                            onPressed: submit,
                            child: Text(
                              LangText(context).local.save_product_ucf,
                              style: TextStyle(color: Colors.white),
                            )),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEditTextField(
      String title, String hint, TextEditingController textEditingController,
      {isMandatory = false}) {
    return Container(
      child: buildCommonSingleField(
        title,
        MyWidget.customCardView(
          shadowColor: MyTheme.noColor,
          backgroundColor: MyTheme.white,
          elevation: 0,
          width: DeviceInfo(context).width!,
          height: 36,
          borderRadius: 10,
          child: TextField(
            controller: textEditingController,
            decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: MyTheme.white,
                hintStyle:
                    TextStyle(fontSize: 12.0, color: MyTheme.textfield_grey),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: MyTheme.accent_color, width: 0.2),
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(6.0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: MyTheme.textfield_grey, width: 0.5),
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(6.0),
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0)),
          ),
        ),
        isMandatory: isMandatory,
      ),
    );
  }

  buildCommonSingleField(title, Widget child, {isMandatory = false}) {
    return Column(
      children: [
        Row(
          children: [
            buildFieldTitle(title),
            if (isMandatory)
              Text(
                " *",
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        child,
      ],
    );
  }

  Text buildFieldTitle(title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.bold, color: MyTheme.font_grey),
    );
  }

  Widget itemSpacer({double height = 10}) {
    return SizedBox(
      height: height,
    );
  }

  Widget _buildDropDownField(
    String title,
    dynamic onchange,
    CommonDropDownItem? selectedValue,
    List<CommonDropDownItem> itemList, {
    bool isMandatory = false,
    double? width,
  }) {
    return buildCommonSingleField(
        title, _buildDropDown(onchange, selectedValue, itemList, width: width),
        isMandatory: isMandatory);
  }

  Widget _buildDropDownFieldWithChildren(
    String title,
    dynamic onchange,
    CommonDropDownItemWithChild? selectedValue,
    List<CommonDropDownItemWithChild> itemList, {
    bool isMandatory = false,
    double? width,
  }) {
    return buildCommonSingleField(
        title,
        _buildDropDownWithChildren(onchange, selectedValue, itemList,
            width: width),
        isMandatory: isMandatory);
  }

  Widget _buildDropDown(
    dynamic onchange,
    CommonDropDownItem? selectedValue,
    List<CommonDropDownItem> itemList, {
    double? width,
  }) {
    return Focus(
      onFocusChange: (hasFocus) {},
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: MyTheme.accent_color,
              style: BorderStyle.solid,
              width: 0.2),
          boxShadow: [
            BoxShadow(
              color: MyTheme.white.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 0.0,
              offset: const Offset(0.0, 10.0), // shadow direction: bottom right
            )
          ],
        ),
        child: DropdownButton<CommonDropDownItem>(
          menuMaxHeight: 300,
          isDense: true,
          underline: Container(),
          isExpanded: true,
          onChanged: (CommonDropDownItem? value) {
            onchange(value);
          },
          icon: const Icon(Icons.arrow_drop_down),
          value: selectedValue,
          items: itemList
              .map(
                (value) => DropdownMenuItem<CommonDropDownItem>(
                  value: value,
                  child: Text(
                    value.value!,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildDropDownWithChildren(
    dynamic onchange,
    CommonDropDownItemWithChild? selectedValue,
    List<CommonDropDownItemWithChild> itemList, {
    double? width,
  }) {
    return Focus(
      onFocusChange: (hasFocus) {},
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
              color: MyTheme.accent_color,
              style: BorderStyle.solid,
              width: 0.2),
          boxShadow: [
            BoxShadow(
              color: MyTheme.white.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 0.0,
              offset: const Offset(0.0, 10.0), // shadow direction: bottom right
            )
          ],
        ),
        child: DropdownButton<CommonDropDownItemWithChild>(
          menuMaxHeight: 300,
          isDense: true,
          underline: Container(),
          isExpanded: true,
          onChanged: (CommonDropDownItemWithChild? value) {
            onchange(value);
          },
          icon: const Icon(Icons.arrow_drop_down),
          value: selectedValue,
          items: itemList
              .map(
                (value) => DropdownMenuItem<CommonDropDownItemWithChild>(
                  value: value,
                  child: Text(
                    value.value!,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  setChange() {
    setState(() {});
  }

  Widget buildTagsEditTextField(
      String title, String hint, TextEditingController textEditingController,
      {isMandatory = false}) {
    return buildCommonSingleField(
      title,
      Container(
        padding: EdgeInsets.only(top: 10, bottom: 8, left: 10, right: 10),
        alignment: Alignment.centerLeft,
        constraints: BoxConstraints(minWidth: DeviceInfo(context).width!),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          // color: MyTheme.light_grey,
          border: Border.all(
              color: MyTheme.accent_color,
              style: BorderStyle.solid,
              width: 0.2),
          boxShadow: [
            BoxShadow(
              color: MyTheme.white.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 0.0,
              offset: const Offset(0.0, 10.0), // shadow direction: bottom right
            )
          ],
        ),
        child: Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          runAlignment: WrapAlignment.start,
          clipBehavior: Clip.antiAlias,
          children: List.generate(tags!.length + 1, (index) {
            if (index == tags!.length) {
              return TextField(
                onSubmitted: (string) {
                  var tag = textEditingController.text
                      .trim()
                      .replaceAll(",", "")
                      .toString();
                  if (tag.isNotEmpty) addTag(tag);
                },
                onChanged: (string) {
                  if (string.trim().contains(",")) {
                    var tag = string.trim().replaceAll(",", "").toString();
                    if (tag.isNotEmpty) addTag(tag);
                  }
                },
                controller: textEditingController,
                keyboardType: TextInputType.text,
                maxLines: 1,
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration.collapsed(
                  hintText: LangText(context).local.type_and_hit_submit_ucf,
                  hintStyle: TextStyle(fontSize: 12),
                ).copyWith(
                  constraints: BoxConstraints(maxWidth: 150),
                ),
              );
            }
            return Container(
                decoration: BoxDecoration(
                    color: MyTheme.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(width: 2, color: MyTheme.grey_153)),
                constraints: BoxConstraints(
                    maxWidth: (DeviceInfo(context).width! - 50) / 4),
                margin: const EdgeInsets.only(right: 5, bottom: 5),
                child: Stack(
                  fit: StackFit.loose,
                  children: [
                    Container(
                        padding: const EdgeInsets.only(
                            left: 10, right: 20, top: 5, bottom: 5),
                        constraints: BoxConstraints(
                            maxWidth: (DeviceInfo(context).width! - 50) / 4),
                        child: Text(
                          tags![index].toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        )),
                    Positioned(
                      right: 2,
                      child: InkWell(
                        onTap: () {
                          tags!.removeAt(index);
                          setChange();
                        },
                        child: Icon(Icons.highlight_remove,
                            size: 15, color: MyTheme.cinnabar),
                      ),
                    )
                  ],
                ));
          }),
        ),
      ),
      isMandatory: isMandatory,
    );
  }

  addTag(String string) {
    if (string.trim().isNotEmpty) {
      tags!.add(string.trim());
    }
    tagEditTextController.clear();
    setChange();
  }

  Widget buildGroupItems(groupTitle, Widget children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildGroupTitle(groupTitle),
        itemSpacer(height: 14.0),
        children,
      ],
    );
  }

  Text buildGroupTitle(title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.bold, color: MyTheme.font_grey),
    );
  }

  summerNote(title) {
    if (productDescriptionKey.currentState != null) {
      productDescriptionKey.currentState!.getText().then((value) {
        description = value;
        print(description);
        if (description != null) {
          // productDescriptionKey.currentState.setText(description);
        }
      });
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: MyTheme.font_grey),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          height: 220,
          width: double.infinity,
          child: FlutterSummernote(
              showBottomToolbar: false,
              value: description,
              key: productDescriptionKey),
        ),
      ],
    );
  }

  pickGalleryImages() async {
    var tmp = productGalleryImages;
    List<FileInfo>? images = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UploadFile(
                  fileType: "image",
                  canSelect: true,
                  canMultiSelect: true,
                  prevData: tmp,
                )));
    // print(images != null);
    if (images != null) {
      productGalleryImages = images;
      setChange();
    }
  }

  Widget chooseGalleryImageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LangText(context).local.gallery_images,
              style: TextStyle(
                  fontSize: 12,
                  color: MyTheme.font_grey,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            TextButton(
              // padding: EdgeInsets.zero,
              onPressed: () {
                pickGalleryImages();
              },
              // shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(6)),
              child: MyWidget().myContainer(
                  width: DeviceInfo(context).width!,
                  height: 36,
                  borderRadius: 6.0,
                  borderColor: MyTheme.accent_color,
                  borderWith: 0.2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 14.0),
                        child: Text(
                          LangText(context).local.choose_file,
                          style:
                              TextStyle(fontSize: 12, color: MyTheme.grey_153),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        height: 46,
                        width: 80,
                        color: MyTheme.light_grey,
                        child: Text(
                          LangText(context).local.browse,
                          style:
                              TextStyle(fontSize: 12, color: MyTheme.grey_153),
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        if (productGalleryImages.isNotEmpty)
          Wrap(
            children: List.generate(
              productGalleryImages.length,
              (index) => Stack(
                children: [
                  MyWidget.imageWithPlaceholder(
                      height: 60.0,
                      width: 60.0,
                      url: productGalleryImages[index].url),
                  Positioned(
                    top: 0,
                    right: 5,
                    child: Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: MyTheme.white),
                      child: InkWell(
                        onTap: () {
                          print(index);
                          productGalleryImages.removeAt(index);
                          setState(() {});
                        },
                        child: Icon(
                          Icons.close,
                          size: 12,
                          color: MyTheme.cinnabar,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class CommonDropDownItem {
  String? key, value;

  CommonDropDownItem(this.key, this.value);
}

class CommonDropDownItemWithChild {
  String? key, value, levelText;
  int? level;
  List<CommonDropDownItemWithChild> children;

  CommonDropDownItemWithChild(
      {this.key,
      this.value,
      this.levelText,
      this.children = const [],
      this.level});

  setLevelText() {
    String tmpTxt = "";
    for (int i = 0; i < level!; i++) {
      tmpTxt += "–";
    }
    levelText = "$tmpTxt $levelText";
  }
}
