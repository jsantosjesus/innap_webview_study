import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class HomeStore {
  PrintJobController? printJobController;
  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
      isInspectable: false,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllowFullscreen: true);

  PullToRefreshController? pullToRefreshController;
  double progress = 0;
  bool canGoBack = false;

  void setWebViewController({required InAppWebViewController controller}) {
    webViewController = controller;
  }

  void setPullToRefreshController() {
    pullToRefreshController = kIsWeb ||
            ![TargetPlatform.iOS, TargetPlatform.android]
                .contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(
              color: Colors.blue,
            ),
            onRefresh: reload,
          );
  }

  void reload() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      webViewController?.reload();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      webViewController?.loadUrl(
          urlRequest: URLRequest(url: await webViewController?.getUrl()));
    }
  }

  void printDocument() async {
    printJobController?.dispose();

    final jobSettings = PrintJobSettings(
        handledByClient: true,
        jobName: "${await webViewController?.getTitle() ?? ''} - PDF Document",
        colorMode: PrintJobColorMode.MONOCHROME,
        outputType: PrintJobOutputType.GRAYSCALE,
        // orientation: defaultTargetPlatform == TargetPlatform.iOS
        //     ? PrintJobOrientation.LANDSCAPE
        //     : null,
        numberOfPages: 1);

    printJobController =
        await webViewController?.printCurrentPage(settings: jobSettings);

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      printJobController?.onComplete = (completed, error) async {
        if (completed) {
          print("Print Job Completed");
        } else {
          print("Print Job Failed $error");
        }
        printJobController?.dispose();
      };
    }

    final jobInfo = await printJobController?.getInfo();
    print(jobInfo);
  }
}
