import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/custom/device_info.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class HtmlContentWebView extends StatefulWidget {
   HtmlContentWebView({super.key,required this.html});
  String html;

  @override
  State<HtmlContentWebView> createState() => _HtmlContentWebViewState();
}

class _HtmlContentWebViewState extends State<HtmlContentWebView> {

  WebViewController viewController = WebViewController();
  double webViewHeight = 100.0;

  makeHeight()async{
    await Future.delayed(Duration(seconds:1));
    var h =await viewController.runJavaScriptReturningResult("document.getElementById('scaled-frame').clientHeight");

    webViewHeight = double.parse(
      (h).toString(),
    );
    setState(() {

    });
  }


  @override
  void initState() {
    // TODO: implement initState
    viewController.setJavaScriptMode(JavaScriptMode.unrestricted);
    viewController.enableZoom(false);
    viewController.loadHtmlString(makeHtml()).then((value) {
          makeHeight();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: DeviceInfo(context).width,
      height: webViewHeight,
      child: WebViewWidget(
        controller: viewController,
      ),
    );
  }



  String makeHtml() {
    return """
<!DOCTYPE html>
<html>

<head>

<meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link rel="stylesheet" href="${AppConfig.RAW_BASE_URL}/public/assets/css/vendors.css">
  <style>
  *{
  margin:0 !important;
  padding:0 !important;
  }
  </style>
</head>

<body id="main_id">
  <div id="scaled-frame">
    ${widget.html}
  </div>
</body>

</html>
""";
  }
}
