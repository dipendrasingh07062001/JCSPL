import 'dart:io';

import 'package:active_ecommerce_flutter/custom/lang_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import '../../custom/device_info.dart';
import '../../custom/my_widget.dart';
import '../../custom/toast_component.dart';
import '../../data_model/uploaded_file_list_response.dart';
import '../../helpers/shimmer_helper.dart';
import '../../my_theme.dart';
import '../../repositories/upload_repository.dart';
import '../classified_ads/classified_product_add.dart';

class UploadFile extends StatefulWidget {
  const UploadFile(
      {Key? key,
      this.fileType = "",
      this.canSelect = false,
      this.canMultiSelect = false,
      this.prevData})
      : super(key: key);
  final String fileType;
  final bool canSelect;
  final bool canMultiSelect;
  final List<FileInfo>? prevData;

  @override
  State<UploadFile> createState() => _UploadFileState();
}

class _UploadFileState extends State<UploadFile> {
  ScrollController mainScrollController = ScrollController();
  TextEditingController searchEditingController = TextEditingController();
  String searchTxt = "";

  //for image uploading

  CommonDropDownItem? sortBy;
  List<CommonDropDownItem> sortList = [
    CommonDropDownItem("newest", "Newest"),
    CommonDropDownItem("oldest", "Oldest"),
    CommonDropDownItem("smallest", "Smallest"),
    CommonDropDownItem("largest", "Largest")
  ];

  List<FileInfo> _images = [];
  List<FileInfo>? _selectedImages = [];
  bool _faceData = false;
  int currentPage = 1;
  int? lastPage = 1;

  Future<FilePickerResult?> pickSingleFile() async {
    return await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: [
      "jpg",
      "jpeg",
      "png",
      "svg",
      "webp",
      "gif",
      "mp4",
      "mpg",
      "mpeg",
      "webm",
      "ogg",
      "avi",
      "mov",
      "flv",
      "swf",
      "mkv",
      "wmv",
      "wma",
      "aac",
      "wav",
      "mp3",
      "zip",
      "rar",
      "7z",
      "doc",
      "txt",
      "docx",
      "pdf",
      "csv",
      "xml",
      "ods",
      "xlr",
      "xls",
      "xlsx"
    ]);
  }

  chooseAndUploadFile(context) async {
    FilePickerResult? file = await pickSingleFile();
    if (file == null) {
      ToastComponent.showDialog(LangText(context).local.no_file_chosen_ucf,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    // print("file");
    // print(file);

    var fileUploadResponse =
        await FileUploadRepository().fileUpload(File(file.paths.first!));
    resetData();
    if (fileUploadResponse.result == false) {
      ToastComponent.showDialog(fileUploadResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    } else {
      ToastComponent.showDialog(fileUploadResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
    }
  }

  getImageList() async {
    var response = await FileUploadRepository()
        .getFiles(currentPage, searchTxt, widget.fileType, sortBy!.key);
    _images.addAll(response.data!);
    _faceData = true;
    lastPage = response.meta == null ? 0 : response.meta!.lastPage;
    setState(() {});
  }

  Future<bool> fetchData() async {
    getImageList();
    return true;
  }

  _tabOption(int index, imageId, listIndex) {
    switch (index) {
      case 0:
        delete(imageId);
        break;
      default:
        break;
    }
  }

  delete(id) async {
    var response = await FileUploadRepository().deleteFile(id);

    if (response.result) {
      resetData();
    }

    ToastComponent.showDialog(response.message);
  }

  Future<bool> clearData() async {
    _images = [];
    _faceData = false;
    setState(() {});
    return true;
  }

  sorted() {
    refresh();
  }

  search() {
    searchTxt = searchEditingController.text.trim();
    refresh();
  }

  Future<bool> resetData() async {
    await clearData();
    await fetchData();
    return true;
  }

  Future<void> refresh() async {
    await resetData();
    return Future.delayed(Duration(seconds: 1));
  }

  scrollControllerPosition() {
    mainScrollController.addListener(() {
      if (mainScrollController.position.pixels ==
          mainScrollController.position.maxScrollExtent) {
        if (currentPage >= lastPage!) {
          currentPage++;
          getImageList();
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    if (widget.canMultiSelect && widget.prevData != null) {
      _selectedImages = widget.prevData;
      setState(() {});
    }
    sortBy = sortList.first;
    fetchData();
    scrollControllerPosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _selectedImages);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: MyTheme.white,
          iconTheme: IconThemeData(color: MyTheme.dark_grey),
          title: Text(
            LangText(context).local.upload_file_ucf,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: MyTheme.dark_font_grey),
          ),
          actions: [
            if (widget.canSelect && _selectedImages!.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.pop(context, _selectedImages);
                },
                child: Text(
                  LangText(context).local.select_ucf,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: MyTheme.green),
                ),
              ),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
        body: RefreshIndicator(
            onRefresh: refresh,
            child: Stack(
              children: [
                _faceData
                    ? _images.isEmpty
                        ? Center(
                            child: Text(
                                LangText(context).local.no_data_is_available),
                          )
                        : buildImageListView()
                    : buildShimmerList(context),
                Container(
                  child: buildFilterSection(context),
                )
              ],
            )),
      ),
    );
  }

  Widget buildShimmerList(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(
            5,
            (index) => Container(
                margin: EdgeInsets.only(bottom: 20),
                child: ShimmerHelper().buildBasicShimmer(
                    height: 96, width: DeviceInfo(context).width!))),
      ),
    );
  }

  Widget buildImageListView() {
    return Padding(
      padding: const EdgeInsets.only(top: 145.0),
      child: GridView.builder(
          controller: mainScrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 12),
          padding: EdgeInsets.all(12),
          itemCount: _images.length,
          itemBuilder: (context, index) {
            return buildImageItem(index);
          }),
    );
  }

  int findIndex(id) {
    int index = 0;
    _selectedImages!.forEach((element) {
      if (element.id == id) {
        index = _selectedImages!.indexOf(element);
      }
    });
    return index;
  }

  Widget buildImageItem(int index) {
    return InkWell(
      splashColor: MyTheme.noColor,
      onTap: () {
        if (widget.canSelect) {
          if (widget.canMultiSelect) {
            if (_selectedImages!
                .any((element) => element.id == _images[index].id)) {
              int getIndex = findIndex(_images[index].id);
              _selectedImages!.removeAt(getIndex);
            } else {
              _selectedImages!.add(_images[index]);
            }
          } else {
            if (_selectedImages!
                .any((element) => element.id == _images[index].id)) {
              _selectedImages!.removeWhere((element) => _selectedImages!
                  .any((element) => element.id == _images[index].id));
            } else {
              _selectedImages = [];
              _selectedImages!.add(_images[index]);
            }
          }
        }
        setState(() {});
      },
      child: Stack(
        children: [
          MyWidget().productContainer(
            width: DeviceInfo(context).width!,
            margin: EdgeInsets.only(bottom: 20),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            height: 170,
            borderColor: MyTheme.grey_153,
            borderRadius: 10,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _images[index].type != "document"
                    ? MyWidget.imageWithPlaceholder(
                        url: _images[index].url, height: 100.0, width: 100.0)
                    : Container(
                        color: MyTheme.light_grey,
                        alignment: Alignment.center,
                        height: 100,
                        width: DeviceInfo(context).width!,
                        child: Icon(
                          Icons.description,
                          size: 35,
                          color: MyTheme.white,
                        )),
                Text(
                  "${_images[index].fileOriginalName}.${_images[index].extension}",
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          ),
          if (_selectedImages!
              .any((element) => element.id == _images[index].id))
            Positioned(top: 10, right: 10, child: buildCheckContainer()),
          if (!widget.canMultiSelect && !widget.canSelect)
            Positioned(
                top: 10,
                right: 10,
                child:
                    showOptions(imageId: _images[index].id, listIndex: index))
        ],
      ),
    );
  }

  Widget buildUploadFileContainer(BuildContext context) {
    return InkWell(
      onTap: () {
        chooseAndUploadFile(context);
      },
      child: MyWidget().myContainer(
        marginY: 10.0,
        marginX: 5,
        height: 75,
        width: DeviceInfo(context).width!,
        borderRadius: 10,
        bgColor: MyTheme.white,
        borderColor: MyTheme.accent_color,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              LangText(context).local.upload_file_ucf,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: MyTheme.dark_font_grey),
            ),
            Icon(
              Icons.upload_file,
              size: 18,
              color: MyTheme.dark_font_grey,
            )
          ],
        ),
      ),
    );
  }

  buildFilterSection(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        buildUploadFileContainer(context),
        Container(
          height: 40,
          margin: EdgeInsets.only(top: 10),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: DeviceInfo(context).width! / 2 - 16 * 1.5,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: const Color.fromRGBO(255, 255, 255, 0),
                        width: 0.0),
                    boxShadow: [
                      BoxShadow(
                        color: MyTheme.white,
                      ),
                    ],
                  ),
                  child: DropdownButton<CommonDropDownItem>(
                    isDense: true,
                    underline: Container(),
                    isExpanded: true,
                    onChanged: (value) {
                      sortBy = value;
                      sorted();
                      //onchange(value);
                    },
                    icon: const Icon(Icons.arrow_drop_down),
                    value: sortBy,
                    items: sortList
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
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: const Color.fromRGBO(255, 255, 255, 0),
                        width: 0.0),
                    boxShadow: [
                      BoxShadow(
                        color: MyTheme.white,
                      ),
                    ],
                  ),
                  width: DeviceInfo(context).width! / 2 - 16 * 1.5,
                  child: Row(
                    children: [
                      buildFlatEditTextFiled(),
                      InkWell(
                        onTap: () {
                          search();
                        },
                        child: const SizedBox(
                          width: 40,
                          child: Icon(Icons.search_sharp),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildFlatEditTextFiled() {
    return Container(
      width: DeviceInfo(context).width! / 2 - (16 * 1.5 + 50),
      padding: EdgeInsets.symmetric(horizontal: 8),
      height: 45,
      alignment: Alignment.center,
      child: TextField(
        controller: searchEditingController,
        decoration: InputDecoration.collapsed(
            hintText: LangText(context).local.search_here_ucf),
      ),
    );
  }

  Widget buildCheckContainer() {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 400),
      opacity: 1,
      child: Container(
        height: 16,
        width: 16,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0), color: Colors.green),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Icon(Icons.check, color: Colors.white, size: 10),
        ),
      ),
    );
  }

  Widget showOptions({listIndex, imageId}) {
    return Container(
      width: 35,
      child: PopupMenuButton<MenuOptions>(
        offset: Offset(-12, 0),
        child: Padding(
          padding: EdgeInsets.zero,
          child: Container(
            width: 35,
            padding: EdgeInsets.symmetric(horizontal: 15),
            alignment: Alignment.topRight,
            child: Image.asset("assets/more.png",
                width: 3,
                height: 15,
                fit: BoxFit.contain,
                color: MyTheme.grey_153),
          ),
        ),
        onSelected: (MenuOptions result) {
          _tabOption(result.index, imageId, listIndex);
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuOptions>>[
          PopupMenuItem<MenuOptions>(
            value: MenuOptions.Delete,
            child: Text(LangText(context).local.delete_ucf),
          ),
        ],
      ),
    );
  }
}

enum MenuOptions { Delete }
